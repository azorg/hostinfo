#!/bin/bash
# -*- coding: UTF8 -*-
#
# "Bash скрипт инвентаризация Linux системы"
# File: "hostinfo_net_if.sh" (сетевые интерфейсы)
# Last update: 2023.03.15
#
# Зависимости:
#  * bash/grep/head/cut/sed/awk/id/basename
#  * net-tools (ifconfig)
#  * ethtool

# проверка, что скрипт запущен от root (UID=0)
if [ `id -u` -ne 0 ]
then
  SCRIPT=`basename $0`
  echo "You must run '$SCRIPT' as root; exit" >&2
  exit 1
fi

# Сетевые интерфейсы
# (детали по каждому интерфейсу: имя, IP-адрес, Маска подсети, MAC-адрес, скорость)
IF_LIST=`ifconfig | grep -v '^ ' | grep -v '^$' | cut -d: -f1 | grep -v lo | sort`
IF_NUM=0
IFACES=''
for IF in $IF_LIST
do
  IFIP=`ifconfig $IF | grep 'inet' | grep 'netmask' | awk '{print $2}'`
  MASK=`ifconfig $IF | grep 'inet' | grep 'netmask' | awk '{print $4}'`
  MAC=`ifconfig  $IF | grep 'ether' | awk '{print $2}'`
  SPEED=`ethtool $IF | grep 'Speed' | cut -d ':' -f 2 | sed 's/^ *//'`
  IF_DATA="\"$IF_NUM\": {\"if\": \"$IF\", \"ip\": \"$IFIP\", \"mask\": \"$MASK\","
  IF_DATA="$IF_DATA \"mac\": \"$MAC\", \"speed\": \"$SPEED\"}"
  [ "$IFACES" ] && IFACES="$IFACES,\n"
  IFACES="$IFACES    $IF_DATA"
  IF_NUM=$(($IF_NUM + 1))
done
[ "$IFACES" ] && IFACES="{\n$IFACES\n  }" \
              || IFACES="{}"

# Вывести результат на стандартный вывод
RESULT=`cat << EOF
  "num": $IF_NUM,
  "list": $IFACES
EOF`

echo -e "$RESULT"

