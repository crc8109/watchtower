#!/bin/bash

#
# setup.sh - Deployment tool for Watchtower
# Released under the MIT License.
#
# https://github.com/jovalle/watchtower
#

VERSION="0.0.1"

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
    install              run create commands
    configure            run create commands
    deploy               run create commands
    uninstall            run create commands
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

install() {
  apt update -y
  apt upgrade -y

  apt install -y \
    dnsutils \
    docker-compose \
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
    zfs-dkms \
    zfsutils-linux
}

#
# Configure zfs, systemd unit
#

configure() {
  command -v zpool 2>/dev/null 1>&2 || abort zpool not installed

  for pool in media misc
  do
    if [[ $(zpool list | tail -n +2 | awk '{print $1}' | grep $pool) ]]
    then
      echo "zfs pool $pool FOUND"
    else
      echo "zfs pool $pool NOT FOUND! Importing..."
      [[ ! -d /mnt/$pool ]] && mkdir -p /mnt/$pool
      zpool import -f $pool
      echo "zfs pool $pool IMPORTED"
    fi
  done

  test -d /etc/watchtower || abort jovalle/watchtower must reside in /etc/watchtower

  if [[ ! -f /etc/systemd/system/docker-compose.service ]]
  then
    pushd /etc/systemd/system
    ln -s /etc/watchtower/config/systemd/docker-compose.service
    popd
  fi
}


#
# Initiate systemd unit and thus watchtower
#

deploy() {
  systemctl daemon-reload
  if [[ $(systemctl status docker-compose) ]]
  then
    systemctl restart docker-compose
    systemctl enable docker-compose
  fi
}

#
# Stop and remove watchtower services
#

uninstall() {
  systemctl stop docker-compose
  systemctl disable docker-compose
  test -f /etc/systemd/system/docker-compose && rm -f /etc/systemd/system/docker-compose
}

#
# Parse argv
#

while test $# -ne 0
do
  arg=$1
  shift
  case $arg in
    -h|--help) usage; exit ;;
    -V|--version) version; exit ;;
    install) install; ;;
    configure) configure; ;;
    deploy) deploy; ;;
    uninstall) uninstall; ;;
    *) usage; exit ;;
  esac
done
