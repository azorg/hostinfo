#!/bin/bash
# -*- coding: UTF8 -*-
#
# "Bash скрипт инвентаризация Linux системы"
# File: "hostinfo_net.sh" (основные сетевые настройки)
# Last update: 2023.03.15
#
# Зависимости:
#  * bash/grep/head/cut/sed/awk
#  * uname/hostanme/domainname
#  * iproute2 (ip)
#  * net-tools (ifconfig)
#  * ethtool

# разделитель списка IP адресов (в т.ч. DNS)
IP_SEP=''

# получить список адресов IP4
ips4() {
  FLG=
  ip -4 addr show | grep inet | grep -v 127.0.0 | awk '{print $2}' | cut -d '/' -f 1 | \
  while read IP
  do
     if [ "$FLG" ]
     then
       echo -n "$IP_SEP "
     else
       FLG=1
     fi
     echo -n "$IP"
  done
}

# получить список DNS серверов
name_servers() {
  grep "nameserver" /etc/resolv.conf | awk '{print $2}' | \
  while read IP
  do
     if [ "$FLG" ]
     then
       echo -n "$IP_SEP "
     else
       FLG=1
     fi
     echo -n "$IP"
  done
}

# Наименование хоста
NAME=`uname -n`

# FQDN
FQDN=`hostname --fqdn`

# Домен
DOMAIN=`domainname`

# IP-адреса (v4)
IPS=`ips4`

# Основной IP-адрес
IP=`hostname -I | awk '{print $1}'`

# Шлюз по умолчанию (default gateway)
GW=`ip route | grep '^default' | awk '{print $3}'`

# DNS-серверы
DNS=`name_servers`

# Вывести результат на стандартный вывод
cat << EOF
  "name":    "$NAME",
  "fqdn":    "$FQDN",
  "domain":  "$DOMAIN",
  "ip_list": "$IPS",
  "ip":      "$IP",
  "gw":      "$GW",
  "dns":     "$DNS"
EOF

