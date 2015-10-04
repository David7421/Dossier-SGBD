BEGIN
	DBMS_SCHEDULER.CREATE_JOB
	(
		JOB_NAME => 'JOB_BACKUP',
		JOB_TYPE => 'STORED_PROCEDURE',
		JOB_ACTION => PACKAGECB.BACKUP,
		START_DATE => SYSTIMESTAMP,
		REPEAT_INTERVAL => 'FREQ=DAILY;BYHOUR=24',
		ENABLED => TRUE,
		COMMENTS => 'Backup des nouveaux utilisateurs et leurs évaluations du jour de leur création.'
	);
END;
/