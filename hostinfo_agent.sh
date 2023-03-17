#!/bin/bash
# -*- coding: UTF8 -*-
#
# "Bash скрипт инвентаризация Linux системы"
# File: "hostinfo_agent.sh" (сведения об Агенте)
# Last update: 2023.03.15
#
# Зависимости:
#  * bash/grep/head/cut/sed/id/basename
#  * procps (ps)
#  * systemd (systemctl)
#  * sudo

# FIXME: Название сервиса "Агента"
#AGENT="lightdm"
AGENT="gpm"

# Sudo-права пользователя, из-под которого работает агент
# 1. Выяснить PID, от имени какого пользователя запушен Агент и строку запуска
AGENT_PID=`systemctl status "$AGENT.service" | grep 'Main PID' | cut -d: -f2 | awk '{print $1}'`
if [ $AGENT_PID ]
then
  AGENT_CMD=`ps -p $AGENT_PID -o cmd | tail -n '+2'`
  AGENT_USER=`ps -p $AGENT_PID -o user | tail -n '+2'`
  # 2. выяснить права sudo
  AGENT_SUDO=`LC_ALL=C sudo -l -U $AGENT_USER | tail -n 1 | sed 's/^ *//'`
  if [ `echo $AGENT_SUDO | grep 'is not allowed to run'` ]
  then
    AGENT_SUDO=''
  fi
else
  AGENT_CMD=''
  AGENT_USER=''
  AGENT_SUDO=''
fi

# Вывести результат на стандартный вывод
cat << EOF
  "name":    "$AGENT",
  "pid":     "$AGENT_PID",
  "cmd":     "$AGENT_CMD",
  "user":    "$AGENT_USER",
  "sudoers": "$AGENT_SUDO"
EOF

