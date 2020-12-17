#!/bin/bash

#
# setup.sh - Deployment tool for Watchtower
# Released under the MIT License.
#
# https://github.com/jovalle/watchtower
#

VERSION="v1"

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
    deploy               create and start service
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
  apt update
  apt upgrade -y
  apt install -y \
    apache2-utils \
    curl \
    dnsutils \
    docker-compose \
    mediainfo \
    ncdu \
    net-tools \
    rsync \
    software-properties-common \
    vim
}

#
# Configure systemd unit
#

deploy() {
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
    deploy) deploy; ;;
    delete) delete; ;;
    *) usage; exit ;;
  esac
done
