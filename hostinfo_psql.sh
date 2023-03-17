#!/bin/bash
# -*- coding: UTF8 -*-
#
# "Bash скрипт инвентаризация Linux системы"
# File: "hostinfo_psql.sh" (сведения об PostgreSQL)
# Last update: 2023.03.16
#
# Зависимости:
#  * bash/grep/head/cut/sed/awk/wc
#  * whoami/sudo/which
#  * procps (ps)
#  * psql/pg_config/pg_conftool (postgresql)

# PostgreSQL administrator and default DB
PSQL_USER="postgres"
PSQL_DB="postgres"

# имя процесса сервера
PROC="postgres"

# встроенные базы данных, которые не учитывать
EXCLUDE_DB="template0 template1"

# имя пользователя от имени которого запускается psql и выбираемая БД
#RUN_USER="user"
#RUN_DB="userdb"

[ -z "$RUN_USER" ] && RUN_USER="$PSQL_USER"
[ -z "$RUN_DB" ] && RUN_DB="$PSQL_DB"

# установить локаль POSIX
export LC_ALL=C

# запуск psql и выполнение одного SQL запроса от имени заданного пользователя
# обратите внимание на ключ -t (--tuples-only) - можно обойтись без tail/head
sql() {
  USER=`whoami`
  if [ "$USER" = "$RUN_USER" ]
  then
    psql -b "$RUN_DB" -t -c "$*"
  else
    sudo -u "$RUN_USER" bash -c "cd ~ && psql -b \"$RUN_DB\" -t -c \"$*\""
  fi
}

# проверка установки программы
check_cmd() {
  CMD="$1"
  FULL_CMD=`which $CMD`
  if [ -z "$FULL_CMD" -o ! -x "$FULL_CMD" ]
  then
    echo "$CMD not found; exit" >&2
    exit 1
  fi
}

# проверить наличие psql/pg_config/pg_conftool
check_cmd psql
check_cmd pg_config
check_cmd pg_conftool

# проверка наличия доступа к СУБД от имени данного пользователя
if ! sql "\q"
then
  echo "psql return error; exit" >&2
  exit 1
fi

# Версия PostgresSQL
FULL_VERSION=`sql 'SELECT version();' | sed 's/^ *//' | sed 's/ *$//'`
VERSION=`pg_config --version`
NAME=`echo "$FULL_VERSION" | awk '{print $1}'`
SHORT_VERSION=`echo "$FULL_VERSION" | awk '{print $2}'`
BUILD=`echo "$FULL_VERSION" | cut -d ',' -f 2 | sed 's/^ *//' | sed 's/ *$//'`

# Каталоги PostgreSQL
SYSCONFDIR=`pg_config --sysconfdir`
BINDIR=`pg_config --bindir`
DATADIR=`pg_conftool show data_directory | cut -d '=' -f 2 | sed -r "s/^ *'|' *$//g"`

# PID главного процесса сераера
PID=`ps -C "$PROC" -o pid=,command= | grep -v " $PROC: " | awk '{print $1}'| sort | head -n 1`

# Имя пользователя от которого запущен сервер
USR=`ps -p "$PID" -o user=`

# Аргументы командной строки главного процесса сервера
CMD=`ps -p "$PID" -o command=`

# Время запуска сервера (Startup Time
STIME=`echo $(sql 'SELECT pg_postmaster_start_time();')`

# Время работы сервера
UPTIME=`echo $(sql 'SELECT now() - pg_postmaster_start_time();')`
#UPTIME=`ps -p "$PID" -o etime= | sed -r "s/^ *| *$//g"`

# Число процессор Postgres
PROC_NUM=`ps -C "$PROC" -o pid= | wc -l`

# Роли СУБД
TMP=`mktemp || echo /tmp/tmp_hostinfo_psql.sh`
sql '\du' 2>/dev/null > "$TMP"
ROLE_NUM=0
ROLE_LIST=''
while read LINE
do
  ROLE_NAME=`echo $LINE | cut -d '|' -f 1 | sed -r 's/^ *| *$//g'` 
  ROLE_PERM=`echo $LINE | cut -d '|' -f 2 | sed -r 's/^ *| *$//g'` 
  ROLE_MEMB=`echo $LINE | cut -d '|' -f 3 | sed -r 's/^ *\{|\} *$//g'` 
  if [ "$ROLE_NAME" ]
  then
    ROLE_DATA="\"$ROLE_NUM\": {\"name\": \"$ROLE_NAME\", \"perm\": \"$ROLE_PERM\","
    ROLE_DATA="$ROLE_DATA \"member_of\": \"$ROLE_MEMB\"}"
    [ "$ROLE_NUM" -ne 0 ] && ROLE_LIST="$ROLE_LIST,\n"
    ROLE_LIST="$ROLE_LIST    $ROLE_DATA"
    ROLE_NUM=$(($ROLE_NUM + 1))
  fi
done < "$TMP"
[ "$ROLE_LIST" ] && ROLE_LIST="{\n$ROLE_LIST\n  }" \
                 || ROLE_LIST="{}"

# Список и размер БД
sql '\l+' 2>/dev/null > "$TMP"
DB_NUM=0
DB_LIST=''
while read LINE
do
  DB_NAME=`echo  $LINE | cut -d '|' -f 1 | sed -r 's/^ *| *$//g'` 
  DB_OWNER=`echo $LINE | cut -d '|' -f 2 | sed -r 's/^ *| *$//g'` 
  DB_SIZE=`echo  $LINE | cut -d '|' -f 7 | sed -r 's/^ *| *$//g'` 
  if [ "$DB_NAME" -a -z "$(echo \"$EXCLUDE_DB\" | grep \"$DB_NAME\")" ]
  then
    DB_DATA="\"$DB_NUM\": {\"name\": \"$DB_NAME\", \"owner\": \"$DB_OWNER\","
    DB_DATA="$DB_DATA \"size\": \"$DB_SIZE\"}"
    [ "$DB_NUM" -ne 0 ] && DB_LIST="$DB_LIST,\n"
    DB_LIST="$DB_LIST    $DB_DATA"
    DB_NUM=$(($DB_NUM + 1))
  fi
done < "$TMP"
rm "$TMP"
[ "$DB_LIST" ] && DB_LIST="{\n$DB_LIST\n  }" \
               || DB_LIST="{}"


# Вывести результат на стандартный вывод
RESULT=`cat << EOF
  "name":       "$NAME",
  "version":    "$VERSION",
  "build":      "$BUILD",
  "sysconfdir": "$SYSCONFDIR",
  "bindir":     "$BINDIR",
  "datadir":    "$DATADIR",
  "pid":        "$PID",
  "user":       "$USR",
  "cmd":        "$CMD",
  "stime":      "$STIME",
  "uptime":     "$UPTIME",
  "proc_num":   $PROC_NUM,
  "role_num":   $ROLE_NUM,
  "role_list":  $ROLE_LIST,
  "db_num":     $DB_NUM,
  "db_list":    $DB_LIST
EOF`

echo -e "$RESULT"


