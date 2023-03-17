#!/bin/bash
# -*- coding: UTF8 -*-
#
# "Bash скрипт инвентаризация Linux системы"
# File: "hostinfo_proc.sh" (проверка запущенных процессов по списку)
# Last update: 2023.03.15
#
# Зависимости:
#  * bash/grep/head/cut/sed/id/basename
#  * facter
#  * procps (uptime, ps)
#  * dpkg | rpm
#  * systemd (systemctl)

# FIXME: нужно задать ТЕ процессы, которые нужно проверить!
PROC_FILT="kasper drweb mc firefox-esr vim screen lowriter python3 postgres"

# Запущенные экземпляры ПО (по определенным фильтрам по процессам:
# инфраструктурные агенты, антивирус, экземпляры ПО из техстека Организации:
# Название, Версия, Process CMD Line)
TMP=`mktemp || echo /tmp/tmp_hostinfo_proc.sh`
PROC_LIST=''
PROC_NUM=0
for PROC in $PROC_FILT
do
  LC_ALL=C ps -C "$PROC" -o pid=,command= | grep -v " $PROC: " > "$TMP"
  LINE=`head -n 1 "$TMP"`
  if [ "$LINE" ]
  then
    VERSION=`LC_ALL=C $PROC --version 2>/dev/null | head -n 1` # FIXME
    while read PID CMD
    do
      PROC_DATA="\"$PROC_NUM\": {\"name\": \"$PROC\", \"cmd\": \"$CMD\", \"pid\": \"$PID\", \"version\": \"$VERSION\"}"
      [ $PROC_NUM -ne 0 ] && PROC_LIST="$PROC_LIST,\n"
      PROC_LIST="$PROC_LIST    $PROC_DATA"
      PROC_NUM=$(($PROC_NUM + 1))
    done < "$TMP"
  fi
done
rm "$TMP"
[ $PROC_NUM -ne 0 ] && PROC_LIST="{\n$PROC_LIST\n  }" \
                    || PROC_LIST="{}"

# Вывести результат на стандартный вывод
RESULT=`cat << EOF
  "num": $PROC_NUM,
  "list": $PROC_LIST
EOF`

echo -e "$RESULT"


