#!/usr/bin/env bash
# Провізія керованих машин (web1, web2, db): довіряємо SSH-ключу з control.
set -euo pipefail

PUB=/vagrant/.keys/control.pub
AUTH=/home/vagrant/.ssh/authorized_keys

if [ ! -f "$PUB" ]; then
  echo "ПОМИЛКА: не знайдено $PUB. Спочатку підніміть control: vagrant up control" >&2
  exit 1
fi

grep -qxF "$(cat "$PUB")" "$AUTH" || cat "$PUB" >> "$AUTH"
echo ">>> $(hostname): ключ control додано"
