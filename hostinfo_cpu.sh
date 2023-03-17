#!/bin/bash
# -*- coding: UTF8 -*-
#
# "Bash скрипт инвентаризация Linux системы"
# File: "hostinfo_cpu.sh" (параметры процессора)
# Last update: 2023.03.15
#
# Зависимости:
#  * bash/grep/head/cut/sed
#  * util-linux (lscpu)

# запросы к lscpu
cpu() {
  LC_ALL=C lscpu | grep "$*" | head -n 1 | cut -d ':' -f 2 | sed 's/^[ \t]*//'
}

# CPU. Количество socket
CPU_SOCKETS=`cpu 'Socket(s)'`

# CPU. Количество ядер и потоков
CPU_CORES=`cpu 'Core(s) per socket'`
CPU_THREADS=`cpu 'CPU(s)'`

# CPU. Микроархитектура процессора
CPU_ARCH=`cpu 'Architecture'`

# CPU. Тип процессора (модель)
CPU_MODEL=`cpu 'Model name:'`

# Вывести результат на стандартный вывод
cat << EOF
  "sockets": $CPU_SOCKETS,
  "cores":   $CPU_CORES,
  "threads": $CPU_THREADS,
  "arch":    "$CPU_ARCH",
  "model":   "$CPU_MODEL"
EOF

