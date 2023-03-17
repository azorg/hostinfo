#!/bin/bash
# -*- coding: UTF8 -*-
#
# "Bash скрипт инвентаризация Linux системы"
# File: "hostinfo_sysctl.sh" (проверка запущенных процессов по списку)
# Last update: 2023.03.16
#
# Зависимости:
#  * bash/id/basename
#  * procps (sysctl)

# FIXME: Нужно задать список интересующих параметров ядра
SYSCTL_OPT=`cat << EOF
net.ipv4.conf.default.forwarding
net.ipv4.conf.default.rp_filter
net.ipv4.conf.all.rp_filter
net.ipv4.tcp_syncookies
net.ipv4.ip_default_ttl
net.ipv4.ip_dynaddr
net.ipv4.tcp_ecn
kernel.sysrq
EOF`

# проверка, что скрипт запущен от root (UID=0)
if [ `id -u` -ne 0 ]
then
  SCRIPT=`basename $0`
  echo "You must run '$SCRIPT' as root; exit" >&2
  exit 1
fi

OPT_NUM=0
OPT_LIST=''
for OPT in $SYSCTL_OPT
do
  if [ -n "$OPT" ]
  then
    #VAL=`sysctl $OPT | sed 's/^.*= *//'`
    VAL=`sysctl -b $OPT`
    OPT_DATA="\"$OPT\": \"$VAL\""
    [ "$OPT_NUM" -ne 0 ] && OPT_LIST="$OPT_LIST,\n"
    OPT_LIST="$OPT_LIST  $OPT_DATA"
    OPT_NUM=$(($OPT_NUM + 1))
  fi
done

# Вывести результат на стандартный вывод
[ "$OPT_LIST" ] && echo -e "$OPT_LIST"


