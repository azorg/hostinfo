#!/bin/bash
# -*- coding: UTF8 -*-
#
# "Bash скрипт инвентаризация Linux системы"
# File: "hostinfo_sssd.sh" (сведения о доменных группах sssd-ad)
# Last update: 2023.03.17
#
# Зависимости:
#  * bash/id/basename/mktemp/which
#  * sssd-tools (sssctl)
#  * sssd-ad (?)

# FIXME: СЦЕНАРИЙ ПОКА НЕ ГОТОВ!
# FIXME: пока просто выдаем в JSON то, что выдал sssctl КАК-ЕСТЬ
# TODO: Нужно посмотреть какой вывод будет на подопытных машинах

# проверка, что скрипт запущен от root (UID=0)
if [ `id -u` -ne 0 ]
then
  SCRIPT=`basename $0`
  echo "You must run '$SCRIPT' as root; exit" >&2
  exit 1
fi

# проверка установки программы
check_cmd() {
  CMD="$1"
  FULL_CMD=`which $CMD`
  if [ -z "$FULL_CMD" -o ! -x "$FULL_CMD" ]
  then
    echo "$CMD not found; exit" >&2
    exit 2
  fi
}

# временная функция для упаковки ВСЕХ строк выдавамых командой в JSON массив
stdout2json() {
  LIST=''
  TMP=`mktemp || echo /tmp/tmp_hostinfo_sssd.sh`
  #$* 2>/dev/null > "$TMP"
  $* > "$TMP"
  while read LINE
  do
    if [ -n "$LINE" ]
    then
      [ -n "$LIST" ] && LIST="$LIST,\n"
      LIST="$LIST    \"$LINE\""
    fi
  done < "$TMP"
  rm "$TMP"
  [ "$LIST" ] && LIST="[\n$LIST\n  ]" \
              || LIST="[]"
  echo -e "$LIST"
}

# проверить, что sssctl установлен в системе
check_cmd sssctl

# FIXME: пока просто упаковываем все строки выданные sssctl в JSON массив!
# ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

# SSSD Status:
SSSD_DOMAIN=`stdout2json sssctl domain-list`   # available domains SSSD
SSSD_STATUS=`stdout2json sssctl domain-status` # information about domain
SSSD_CHECKS=`stdout2json sssctl user-checks`   # information about a user and check authentication
SSSD_ACCESS=`stdout2json sssctl access-report` # access report for a domain

# Information about cached content:
SSSD_USER=`  stdout2json sssctl user-show`     # information about cached user
SSSD_GROUP=` stdout2json sssctl group-show`    # information about cached group
SSSD_NET=`   stdout2json sssctl netgroup-show` # information about cached netgroup

#...

# Configuration files tools:
SSSD_CONFIG=`stdout2json sssctl config-check` # static analysis of SSSD configuration 

# Certificate related tools:
SSSD_CERT=`stdout2json sssctl cert-show` # information about the certificate
SSSD_MAP=` stdout2json sssctl cert-map`  # show users mapped to the certificate

# Вывести результат на стандартный вывод
RESULT=`cat << EOF
  "domain": $SSSD_DOMAIN,
  "status": $SSSD_STATUS,
  "checks": $SSSD_CHECKS,
  "access": $SSSD_ACCESS,
  "user":   $SSSD_USER,
  "group":  $SSSD_GROUP,
  "net":    $SSSD_NET,
  "config": $SSSD_CONFIG,
  "cert":   $SSSD_CERT,
  "map":    $SSSD_MAP
EOF`

echo -e "$RESULT"

