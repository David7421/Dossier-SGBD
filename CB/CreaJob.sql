BEGIN
	DBMS_SCHEDULER.CREATE_JOB
	(
		JOB_NAME => 'JOB_BACKUP',
		JOB_TYPE => 'STORED_PROCEDURE',
		JOB_ACTION => BACKUP,
		START_DATE => SYSTIMESTAMP,
		REPEAT_INTERVAL => 'FREQ=DAILY;BYHOUR=0;BYMINUTE=0;BYSECOND=0;',
		ENABLED => TRUE,
		COMMENTS => 'Backup des nouveaux utilisateurs et leurs évaluations du jour de leur création.'
	);
END;
/
