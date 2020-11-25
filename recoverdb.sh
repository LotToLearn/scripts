#!/bin/bash
# Copyright (C) 2020 NOAH HORNER (https://github.com/LotToLearn)
# Scripts expressed are my own and do not represent anyone else

# steps on Linux
# vi recoverdb.sh
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
echo "RUNNING FULL DATABASE RECOVERY!!!!"
echo =========================================================================================================
echo

# allocate channel c5..c6..etc device type sbt PARMS 'SBT_LIBRARY=/home/oracle/lib/libopc.so, SBT_PARMS=(OPC_PFILE=/home/oracle/config)';
rman target / << EOF | tee ${LOGS_DIR}RMAN_DB_RESTORE_${DATE}.log
set controlfile autobackup format for device type sbt to '%F';
run {
  allocate channel c1 device type sbt PARMS 'SBT_LIBRARY=/home/oracle/lib/libopc.so, SBT_PARMS=(OPC_PFILE=/home/oracle/config)';
  allocate channel c2 device type sbt PARMS 'SBT_LIBRARY=/home/oracle/lib/libopc.so, SBT_PARMS=(OPC_PFILE=/home/oracle/config)';
  allocate channel c3 device type sbt PARMS 'SBT_LIBRARY=/home/oracle/lib/libopc.so, SBT_PARMS=(OPC_PFILE=/home/oracle/config)';
  allocate channel c4 device type sbt PARMS 'SBT_LIBRARY=/home/oracle/lib/libopc.so, SBT_PARMS=(OPC_PFILE=/home/oracle/config)';
  switch datafile all;
  switch tempfile all;
  RECOVER DATABASE;
   }

exit
EOF
