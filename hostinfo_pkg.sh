#!/bin/bash
# -*- coding: UTF8 -*-
#
# "Bash скрипт инвентаризация Linux системы"
# File: "hostinfo_pkg.sh" (проверка установки пакетов по списку)
# Last update: 2023.03.15
#
# Зависимости:
#  * bash/grep
#  * dpkg | rpm

# FIXME: нужно задать ТЕ пакеты, которые нужно проверить!
PKG_FILT="mc nmap netcat firefox screen tcpdump make gcc rpm dpkg golang minicom nginx clamav bind9"

# Установленные пакеты (по определенным фильтрам)
# TODO: проверить с RPM!
PKG_LIST=''
PKG_NUM='0'
for PKG in $PKG_FILT
do
  DPKG=`which dpkg` # Debian/Ubuntu/Astra Linux
  RPM=`which rpm`   # Red Hat/Alt Linux
  FLG1=''
  FLG2=''
  if [ "$DPKG" -a -x "$DPKG" ]
  then
    FLG1=`LC_ALL=C dpkg -l $PKG 2>/dev/null | grep "^ii *$PKG"`
  fi
  if [ "$RPM" -a -x "$RPM" ]
  then
    FLG2=`LC_ALL=C rpm -l | grep '$PKG'` # FIXME: debug me!
  fi
  if [ "$FLG1" -o "$FLG2" ]
  then
    [ $PKG_NUM -ne 0 ] && PKG_LIST="$PKG_LIST, "
    PKG_LIST="${PKG_LIST}\"${PKG}\""
    PKG_NUM=$(($PKG_NUM + 1))
  fi
done

# Вывести результат на стандартный вывод
cat << EOF
  "num": $PKG_NUM,
  "list": [$PKG_LIST]
EOF

