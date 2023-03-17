#!/bin/bash
# -*- coding: UTF8 -*-
#
# "Bash скрипт инвентаризация Linux системы"
# File: "hostinfo_fs.sh" (сведения блочных устройствах / дисках)
# Last update: 2023.03.15
#
# Зависимости:
#  * bash/grep/tail/head/grep/sort/mktemp/awk/id/basename
#  * util-linux (fdisk, lsblk)

# проверка, что скрипт запущен от root (UID=0)
if [ `id -u` -ne 0 ]
then
  SCRIPT=`basename $0`
  echo "You must run '$SCRIPT' as root; exit" >&2
  exit 1
fi

# запросы к fdisk
fdisk_info() {
  DISK="/dev/$1"
  shift 1
  LC_ALL=C fdisk -l "$DISK" | grep "$*" | head -n 1 | cut -d ':' -f 2 | sed 's/^[ \t]*//' | sed 's/ *$//'
}

# Поданные диски (детали по каждому поданному диску:
# Название, NAA, Производитель, Типа диска, Размер, SCSI Bus ID,
# SCSI Node ID, серийный номер)
DISK_NUM=0
DISK_LIST=''
TMP=`mktemp || echo /tmp/tmp_hostinfo_disk.sh`
LC_ALL=C lsblk -d | tail -n '+2' | sort > "$TMP"
while read DEV NUM RM SIZE RO TYPE MOUNT
do
  if [ "$TYPE" = "disk" ]
  then
    MODEL=`fdisk_info "$DEV" "Disk model"`
    SERIAL=`fdisk_info "$DEV" "Disk identifier"`
    MBR=`fdisk_info "$DEV" "Disklabel type"` # gpt/dos
    SCSI_ID=`lsscsi -b | grep "/dev/$DEV" | head -n 1 | awk '{print $1}'`

    DISK_DATA="\"$DISK_NUM\": {\"dev\": \"$DEV\", \"model\": \"$MODEL\","
    DISK_DATA="$DISK_DATA \"size\": \"$SIZE\", \"serial\": \"$SERIAL\","
    DISK_DATA="$DISK_DATA \"rm\": \"$RM\", \"mbr\": \"$MBR\","
    DISK_DATA="$DISK_DATA \"scsi_id\": \"$SCSI_ID\"}"

    [ "$DISK_NUM" -ne 0 ] && DISK_LIST="$DISK_LIST,\n"

    DISK_LIST="$DISK_LIST    $DISK_DATA"
    DISK_NUM=$(($DISK_NUM + 1))
  fi
done < "$TMP"

rm "$TMP"

[ "$DISK_LIST" ] && DISK_LIST="{\n$DISK_LIST\n  }" \
                 || DISK_LIST="{}"

# Вывести результат на стандартный вывод
RESULT=`cat << EOF
  "num": $DISK_NUM,
  "list": $DISK_LIST
EOF`

echo -e "$RESULT"


