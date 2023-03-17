#!/bin/bash
# -*- coding: UTF8 -*-
#
# "Bash скрипт инвентаризация Linux системы"
# File: "hostinfo_fs.sh" (сведения о файловых системах)
# Last update: 2023.03.15
#
# Зависимости:
#  * bash/grep/tail/head/grep/sort/sed/mktemp
#  * coreutils (df)

# Файловые системы
# (детали по каждой файловой системе: Название, Точка монтирования, Размер, Тип ФС, )
FS_NUM=0
FS_LIST=''
TMP=`mktemp || echo /tmp/tmp_hostinfo_fs.sh`
LC_ALL=C df -Tlh  2>/dev/null | tail -n '+2' | grep -v '^tmpfs' | grep -v '^udev' | sort > "$TMP"
while read DEV TYPE SIZE USED FREE PERCENT MOUNT
do
  DEV=`echo $DEV | sed 's|/dev/||'`
  FS_DATA="\"$FS_NUM\": {\"dev\": \"$DEV\", \"mount\": \"$MOUNT\","
  FS_DATA="$FS_DATA \"size\": \"$SIZE\", \"used\": \"$USED\", \"type\": \"$TYPE\"}"
  [ "$FS_NUM" -ne 0 ] && FS_LIST="$FS_LIST,\n"
  FS_LIST="$FS_LIST    $FS_DATA"
  FS_NUM=$(($FS_NUM + 1))
done < "$TMP"
rm "$TMP"
[ "$FS_LIST" ] && FS_LIST="{\n$FS_LIST\n  }" \
               || FS_LIST="{}"

# Вывести результат на стандартный вывод
RESULT=`cat << EOF
  "num": $FS_NUM,
  "list": $FS_LIST
EOF`

echo -e "$RESULT"


