#!/bin/bash
# -*- coding: UTF8 -*-
#
# "Bash скрипт инвентаризация Linux системы"
# File: "hostinfo_server.sh" (основные сведения о сервере)
# Last update: 2023.03.15
#
# Зависимости:
#  * bash/grep/head/cut/sed/id/basename
#  * facter
#  * procps (uptime)

# Тип сервера (виртуальный/физический)
VIRTUAL=`facter is_virtual`

# Время запуска хоста
UPTIME=`LC_ALL=C uptime | sed 's/^.*up *//' | cut -d ',' -f 1`

# Список не коробочных пользователей, созданных в ОС
UID_MIN=`grep '^UID_MIN' /etc/login.defs | awk '{print $2}'`
UID_MAX=`grep '^UID_MAX' /etc/login.defs | awk '{print $2}'`
while read LINE
do
  U=`echo $LINE | cut -d ':' -f 1`
  ID=`echo $LINE | cut -d ':' -f 3`

  if [ $ID -ge $UID_MIN ] && [ $ID -le $UID_MAX ]
  then
    if [ "$USERS" ]
    then
      USERS="$USERS "
    fi
    USERS="${USERS}${U}"
  fi 
done < /etc/passwd

# Вывести результат на стандартный вывод
cat << EOF
  "is_virtual": "$VIRTUAL",
  "uptime":     "$UPTIME",
  "users":      "$USERS"
EOF

