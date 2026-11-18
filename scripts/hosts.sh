#!/usr/bin/env bash
# Додає імена всіх машин лабораторії в /etc/hosts, щоб працювало `ping web1`.
set -euo pipefail

add_host() {
  grep -qE "^$1[[:space:]]" /etc/hosts || echo "$1 $2" >> /etc/hosts
}

add_host 192.168.56.10 control
add_host 192.168.56.11 web1
add_host 192.168.56.12 web2
add_host 192.168.56.13 db
