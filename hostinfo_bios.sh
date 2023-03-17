#!/bin/bash
# -*- coding: UTF8 -*-
#
# "Bash скрипт инвентаризация Linux системы"
# File: "hostinfo_bios.sh" (основные сведения об BIOS)
# Last update: 2023.03.15
#
# Зависимости:
#  * bash/grep/head/cut/sed/id/basename/awk
#  * dmidecode (https://nongnu.org/dmidecode/)

# проверка, что скрипт запущен от root (UID=0)
if [ `id -u` -ne 0 ]
then
  SCRIPT=`basename $0`
  echo "You must run '$SCRIPT' as root; exit" >&2
  exit 1
fi

# запросы к dmidecode
dmi() {
  TYPE="$1"
  shift 1
  dmidecode -t "$TYPE" | grep -i "$*" | head -n 1 | cut -d ':' -f 2 | sed 's/^ *//'
}

# Версия BIOS
BIOS_VENDOR=`dmi bios Vendor`
BIOS_VERSION=`dmi bios Version`
BIOS_DATE=`dmi bios 'Release Date'`

# BIOS UUID
BIOS_SERIAL=`dmi system Serial`

# Вывести результат на стандартный вывод
cat << EOF
  "vendor":  "$BIOS_VENDOR",
  "version": "$BIOS_VERSION",
  "date":    "$BIOS_DATE",
  "serial":  "$BIOS_SERIAL"
EOF

