#!/bin/bash
# -*- coding: UTF8 -*-
#
# "Bash скрипт инвентаризация Linux системы"
# File: "hostinfo_os.sh" (основные сведения об операционной системе)
# Last update: 2023.03.15
#
# Зависимости:
#  * bash/cut/sed
#  * uname
#  * lsb-release (lsb_release)

# Семейство ОС
OS=`uname -o`

# Версия ядра ОС (kernel release)
KERN_VER=`uname -r`

# Название ОС (distributor's ID)
OS_ID=`lsb_release -i | cut -d ':' -f 2 | sed 's/^[ \t]*//'`

# Версия ОС (release)
OS_VER=`lsb_release -r | cut -d ':' -f 2 | sed 's/^[ \t]*//'`

# Релиз ОС (codename)
OS_REL=`lsb_release -c | cut -d ':' -f 2 | sed 's/^[ \t]*//'`

# Вывести результат на стандартный вывод
cat << EOF
  "type":    "$OS",
  "id":      "$OS_ID",
  "version": "$OS_VER",
  "release": "$OS_REL",
  "kernel":  "$KERN_VER"
EOF

