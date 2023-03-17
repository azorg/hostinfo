#!/bin/bash
# -*- coding: UTF8 -*-
#
# "Bash скрипт инвентаризация Linux системы"
# File: "hostinfo_ram.sh" (сведения об оперативыной памяти)
# Last update: 2023.03.15
#
# Зависимости:
#  * bash/grep/awk
#  * procps (free)

LC_ALL=C
export LC_ALL

# ОЗУ [ГБ, MБ]
RAM_GB=`free -g | grep 'Mem:' | awk '{print $2}'`
RAM_MB=`free -m | grep 'Mem:' | awk '{print $2}'`

TOTAL=`free | grep 'Mem:' | awk '{print $2}'`
USED=`free | grep 'Mem:' | awk '{print $3}'`
PERCENT=$(($USED * 100 / $TOTAL))

# Вывести результат на стандартный вывод
cat << EOF
  "gb": $RAM_GB,
  "mb": $RAM_MB,
  "used_percent": $PERCENT
EOF

