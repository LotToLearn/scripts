#!/bin/bash
# Copyright (C) 2020 NOAH HORNER (https://github.com/LotToLearn)
# Scripts expressed are my own and do not represent anyone else

# steps on Linux
# vi restore_micros.sh
# hit i, then paste all of this
# chmod 777 restore_micros.sh
# nohup ./restore_micros.sh &
# hit enter
# tail -100f nohup.out


export NLS_DATE_FORMAT='DD-MON-YY HH24:MI:SS'
export DATE=$(date +%Y-%m-%d-%H-%M-%S)
export LOGS_DIR=/home/oracle/
echo
echo =========================================================================================================
echo "RUNNING FULL DATABASE RESTORE!!!!"
echo =========================================================================================================
echo


rman target / << EOF | tee ${LOGS_DIR}RMAN_DB_RESTORE_${DATE}.log
set dbid 2823475299;
show all;
exit
EOF
