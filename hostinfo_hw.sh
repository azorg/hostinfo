#!/bin/bash
# -*- coding: UTF8 -*-
#
# "Bash скрипт инвентаризация Linux системы"
# File: "hostinfo_hw.sh" (основные сведения об аппаратуре)
# Last update: 2023.03.15
#
# Зависимости:
#  * bash/grep/head/cut/sed/id/basename
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

# Серийный номер / UUID
UUID=`dmi system UUID`
SERIAL=`dmi baseboard Serial`

# Производитель
VENDOR=`dmi baseboard Manufacture`

# Модель (Product Name (Version))
PRODUCT_NAME=`dmi baseboard 'Product Name'`
PRODUCT_VERSION=`dmi baseboard Version`
test "$PRODUCT_NAME" || PRODUCT_NAME="Unknown"
MODEL="$PRODUCT_NAME ($PRODUCT_VERSION)"

# Вывести результат на стандартный вывод
cat << EOF
  "uuid":   "$UUID",
  "serial": "$SERIAL",
  "vendor": "$VENDOR",
  "model":  "$MODEL"
EOF

