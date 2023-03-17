#!/bin/bash
# -*- coding: UTF8 -*-
#
# "Bash скрипт инвентаризация Linux системы"
# File: "hostinfo.sh" (последовательный запуск всех составных скриптов)
# Last update: 2023.03.16
#

WDIR=`dirname $0`

task() {
  echo "\"$1\": {"
  if [ "$2" = "root" ]
  then
    sudo "$WDIR/hostinfo_$1.sh"
  else
    "$WDIR/hostinfo_$1.sh"
  fi
  echo "}$3"
}

echo "{"
task hw        root ,
task bios      root ,
task cpu       user ,
task ram       user ,
task swap      user ,
task swap_part root ,
task os        user ,
task net       user ,
task net_if    root ,
task fs        user ,
task disk      root ,
task server    user ,
task pkg       user ,
task proc      user ,
task sysctl    root ,
task agent     user ,
task psql      root ,
task sssd      root
echo "}"

