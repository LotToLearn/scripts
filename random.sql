-- RUNNING FOR USER SAUL:

CREATE TABLE SAUL.SAUL_DMBS_SCH_TABLE (id NUMBER, small_number NUMBER(5), big_number NUMBER, bigger_number NUMBER, short_string VARCHAR2(50), long_string VARCHAR2(100), longer_string VARCHAR2(400), short2_string VARCHAR2(50), long2_string VARCHAR2(100), longer2_string VARCHAR2(400), short3_string VARCHAR2(50), long3_string VARCHAR2(100), longer3_string VARCHAR2(400), short4_string VARCHAR2(50), long4_string VARCHAR2(100), longer4_string VARCHAR2(400), short5_string VARCHAR2(50), long5_string VARCHAR2(100), longer5_string VARCHAR2(400), short6_string VARCHAR2(50), long6_string VARCHAR2(100), longer6_string VARCHAR2(400), short7_string VARCHAR2(50), long7_string VARCHAR2(100), longer7_string VARCHAR2(400), short8_string VARCHAR2(50), long8_string VARCHAR2(100), longer8_string VARCHAR2(400), short9_string VARCHAR2(50), long9_string VARCHAR2(100), longer9_string VARCHAR2(400), short10_string VARCHAR2(50), long10_string VARCHAR2(100), longer10_string VARCHAR2(400), created_date DATE, PRIMARY KEY (longer10_string)) ORGANIZATION INDEX INCLUDING longer10_string OVERFLOW PARTITION BY HASH (longer10_string) PARTITIONS 16;
commit;

create or replace PROCEDURE SAULSRANDOMDATA
IS
BEGIN
	INSERT /*+ APPEND */ INTO SAUL.SAUL_DMBS_SCH_TABLE
	SELECT level AS id, TRUNC(DBMS_RANDOM.value(1,5)) AS small_number,
	TRUNC(DBMS_RANDOM.value(25,35)) AS big_number,
	TRUNC(DBMS_RANDOM.value(50,1033)) AS bigger_number,
	DBMS_RANDOM.string('L',TRUNC(DBMS_RANDOM.value(10,20))) AS short_string,
	DBMS_RANDOM.string('L',TRUNC(DBMS_RANDOM.value(30,100))) AS long_string,
	DBMS_RANDOM.string('L',TRUNC(DBMS_RANDOM.value(100,400))) AS longer_string,
	DBMS_RANDOM.string('L',TRUNC(DBMS_RANDOM.value(10,20))) AS short2_string,
	DBMS_RANDOM.string('L',TRUNC(DBMS_RANDOM.value(30,100))) AS long2_string,
	DBMS_RANDOM.string('L',TRUNC(DBMS_RANDOM.value(100,400))) AS longer2_string,
	DBMS_RANDOM.string('L',TRUNC(DBMS_RANDOM.value(10,20))) AS short3_string,
	DBMS_RANDOM.string('L',TRUNC(DBMS_RANDOM.value(30,100))) AS long3_string,
	DBMS_RANDOM.string('L',TRUNC(DBMS_RANDOM.value(100,400))) AS longer3_string,
	DBMS_RANDOM.string('L',TRUNC(DBMS_RANDOM.value(10,20))) AS short4_string,
	DBMS_RANDOM.string('L',TRUNC(DBMS_RANDOM.value(30,100))) AS long4_string,
	DBMS_RANDOM.string('L',TRUNC(DBMS_RANDOM.value(100,400))) AS longer4_string,
	DBMS_RANDOM.string('L',TRUNC(DBMS_RANDOM.value(10,20))) AS short5_string,
	DBMS_RANDOM.string('L',TRUNC(DBMS_RANDOM.value(30,100))) AS long5_string,
	DBMS_RANDOM.string('L',TRUNC(DBMS_RANDOM.value(100,400))) AS longer5_string,
	DBMS_RANDOM.string('L',TRUNC(DBMS_RANDOM.value(10,20))) AS short6_string,
	DBMS_RANDOM.string('L',TRUNC(DBMS_RANDOM.value(30,100))) AS long6_string,
	DBMS_RANDOM.string('L',TRUNC(DBMS_RANDOM.value(100,400))) AS longer6_string,
	DBMS_RANDOM.string('L',TRUNC(DBMS_RANDOM.value(10,20))) AS short7_string,
	DBMS_RANDOM.string('L',TRUNC(DBMS_RANDOM.value(30,100))) AS long7_string,
	DBMS_RANDOM.string('L',TRUNC(DBMS_RANDOM.value(100,400))) AS longer7_string,
	DBMS_RANDOM.string('L',TRUNC(DBMS_RANDOM.value(10,20))) AS short8_string,
	DBMS_RANDOM.string('L',TRUNC(DBMS_RANDOM.value(30,100))) AS long8_string,
	DBMS_RANDOM.string('L',TRUNC(DBMS_RANDOM.value(100,400))) AS longer8_string,
	DBMS_RANDOM.string('L',TRUNC(DBMS_RANDOM.value(10,20))) AS short9_string,
	DBMS_RANDOM.string('L',TRUNC(DBMS_RANDOM.value(30,100))) AS long9_string,
	DBMS_RANDOM.string('L',TRUNC(DBMS_RANDOM.value(100,400))) AS longer9_string,
	DBMS_RANDOM.string('L',TRUNC(DBMS_RANDOM.value(10,20))) AS short10_string,
	DBMS_RANDOM.string('L',TRUNC(DBMS_RANDOM.value(30,100))) AS long10_string,
	DBMS_RANDOM.string('L',TRUNC(DBMS_RANDOM.value(100,400))) AS longer10_string,
	TRUNC(SYSDATE + DBMS_RANDOM.value(0,366)) AS created_date from dual CONNECT BY level <= 50000;
	commit;
END SAULSRANDOMDATA;
/


BEGIN
    DBMS_SCHEDULER.CREATE_JOB (
         job_name => 'GROW_SAULS_DATA',
         job_type => 'STORED_PROCEDURE',
         job_action => 'SAULSRANDOMDATA',
		 start_date => SYSTIMESTAMP,
         repeat_interval => 'FREQ=MINUTELY;INTERVAL=15;',
         enabled => TRUE);
END;
/
