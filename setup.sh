#!/bin/bash

#
# setup.sh - Deployment tool for Watchtower
# Released under the MIT License.
#
# https://github.com/jovalle/watchtower
#

VERSION="v0.0.2"

#
# Output usage information
#

usage() {
  cat <<-EOF
  Usage: setup.sh [options] [command]
  Options:
    -V, --version        output program version
    -h, --help           output help information
  Commands:
    prepare              install required packages
    start                onboard zfs pools and service
    delete               stop and disable service
EOF
}

#
# Output fatal error
#

abort() {
  echo
  echo "  $@" 1>&2
  echo
  exit 1
}

#
# Output version
#

version() {
  echo $VERSION
}

#
# Update/upgrade/install packages
#

prepare() {
  apt update -y
  apt upgrade -y

  apt install -y \
    dnsutils \
    git \
    glances \
    net-tools \
    samba \
    software-properties-common \
    tmux \
    vim

  add-apt-repository 'deb http://deb.debian.org/debian buster-backports main contrib non-free'
  apt update
  apt install -y \
    docker-compose \
    htop \
    iotop \
    mediainfo \
    ncdu \
    zfs-dkms \
    zfsutils-linux

  modprobe zfs
}

#
# Configure zfs, systemd unit
#

start() {
  command -v zpool 2>/dev/null 1>&2 || abort zpool not installed

  for pool in media misc; do
    if [[ $(zpool list $pool) ]]; then
      echo "zfs pool $pool FOUND"
    else
      echo "zfs pool $pool NOT FOUND! Importing..."
      [[ ! -d /mnt/$pool ]] && mkdir -p /mnt/$pool
      zpool import -f $pool
      [[ $? ]] && echo "zfs pool $pool IMPORTED" || abort "zfs pool $pool IMPORT FAILED"
    fi
  done

  test -d /etc/watchtower || abort "jovalle/watchtower must reside in /etc/watchtower"

  if [[ ! -f /etc/systemd/system/watchtower.service ]]; then
    pushd /etc/systemd/system
    ln -s /etc/watchtower/watchtower.service
    popd
  fi

  test -f /etc/systemd/system/watchtower.service && systemctl daemon-reload || abort "watchtower.service not found"

  systemctl status watchtower &>/dev/null
  if [[ $? -ne 0 ]]; then
    echo "Watchtower NOT running. Restarting service..."
    systemctl restart watchtower
  else
    echo "Watchtower running"
  fi

  systemctl enable watchtower
}

#
# Stop and remove watchtower services
#

delete() {
  systemctl stop watchtower
  systemctl disable watchtower
  test -f /etc/systemd/system/watchtower.service && rm -f /etc/systemd/system/watchtower.service
}

#
# Parse argv
#

while test $# -ne 0; do
  arg=$1
  shift
  case $arg in
    -h|--help) usage; exit ;;
    -v|--version) version; exit ;;
    prepare) prepare; ;;
    start) start; ;;
    delete) delete; ;;
    *) usage; exit ;;
  esac
done
