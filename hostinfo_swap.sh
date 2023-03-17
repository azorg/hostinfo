#!/bin/bash
# -*- coding: UTF8 -*-
#
# "Bash скрипт инвентаризация Linux системы"
# File: "hostinfo_swap.sh" (сведения о swap)
# Last update: 2023.03.15
#
# Зависимости:
#  * bash/grep/awk
#  * procps (free)
#  * mount (swapon)

LC_ALL=C
export LC_ALL

# SWAP [ГБ, МБ]
SWAP_GB=`free -g | grep 'Swap:' | head -n 1 | awk '{print $2}'`
SWAP_MB=`free -m | grep 'Swap:' | head -n 1 | awk '{print $2}'`

TOTAL=`free | grep 'Swap:' | head -n 1 | awk '{print $2}'`
USED=`free | grep 'Swap:' | head -n 1 | awk '{print $3}'`

if [ $TOTAL -ne 0 ]
then
  PERCENT=$(($USED * 100 / $TOTAL))
else
  PERCENT='0'
fi

# Вывести результат на стандартный вывод
cat << EOF
  "gb": $SWAP_GB,
  "mb": $SWAP_MB,
  "used_percent": $PERCENT
EOF

