#!/bin/bash
# -*- coding: UTF8 -*-
#
# "Bash скрипт инвентаризация Linux системы"
# File: "hostinfo_swap_part.sh" (сведения о swap разделах)
# Last update: 2023.03.15
#
# Зависимости:
#  * bash/grep/awk/id/basename/mktemp
#  * mount (swapon)

# проверка, что скрипт запущен от root (UID=0)
if [ `id -u` -ne 0 ]
then
  SCRIPT=`basename $0`
  echo "You must run '$SCRIPT' as root; exit" >&2
  exit 1
fi

# Сведения о swap разделах
SWAP_NUM=0
SWAP_LIST=''
TMP=`mktemp || echo /tmp/tmp_hostinfo_swap_disk.sh`
LC_ALL=C swapon --show | tail -n '+2' | sort > "$TMP"
while read DEV TYPE SIZE USED PRIO
do
  DEV=`echo $DEV | sed 's|/dev/||'`

  SWAP_DATA="\"$SWAP_NUM\": {\"dev\": \"$DEV\", \"type\": \"$TYPE\","
  SWAP_DATA="$SWAP_DATA \"size\": \"$SIZE\", \"used\": \"$USED\"}"

  if [ "$SWAP_NUM" -ne 0 ]
  then
     SWAP_LIST="$SWAP_LIST,\n"
  fi

  SWAP_LIST="$SWAP_LIST    $SWAP_DATA"
  SWAP_NUM=$(($SWAP_NUM + 1))
done < "$TMP"

rm "$TMP"

if [ "$SWAP_LIST" ]
then
  SWAP_LIST="{\n$SWAP_LIST\n  }"
else
  SWAP_LIST="{}"
fi

# Вывести результат на стандартный вывод
RESULT=`cat << EOF
  "num": $SWAP_NUM,
  "list": $SWAP_LIST
EOF`

echo -e "$RESULT"

