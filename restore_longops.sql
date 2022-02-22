REM RMAN Progress
alter session set nls_date_format='dd/mm/yy hh24:mi:ss'
/
select SID, START_TIME,TOTALWORK, sofar, (sofar/totalwork) * 100 done,
sysdate + TIME_REMAINING/3600/24 end_at
from v$session_longops
where totalwork > sofar
AND opname NOT LIKE '%aggregate%'
AND opname like 'RMAN%'
/

REM RMAN wiats
set lines 120
column sid format 9999
column spid format 99999
column client_info format a25
column event format a30
column secs format 9999
col opname for a45
set lines 300 pages 499
SELECT SID, SPID, CLIENT_INFO, event, seconds_in_wait secs, p1, p2, p3
  FROM V$PROCESS p, V$SESSION s
  WHERE p.ADDR = s.PADDR
  and CLIENT_INFO like 'rman channel=%'
/

 SELECT name, free_mb, total_mb, free_mb/total_mb*100 as percentage
     FROM v$asm_diskgroup;

TTITLE LEFT '% Completed. Aggregate is the overall progress:'
SET LINE 132
SELECT opname,sofar,totalwork, round(sofar/totalwork*100) "% Complete",start_time,sysdate + TIME_REMAINING/3600/24 end_at
  FROM gv$session_longops
 WHERE opname LIKE 'RMAN%'
   AND totalwork != 0
   AND sofar <> totalwork
 ORDER BY 1;

select SID, START_TIME,TOTALWORK, sofar, (sofar/totalwork) * 100 done,
sysdate + TIME_REMAINING/3600/24 end_at
from v$session_longops
where totalwork > sofar
AND opname NOT LIKE '%aggregate%'
AND opname like 'RMAN%'
