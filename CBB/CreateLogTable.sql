
CREATE TABLE LOG_TABLE
(
	EVENTTIME		TIMESTAMP,
	DESCRIPTION		VARCHAR2(40),
	CONSTRAINT PK_LOG_TABLE  PRIMARY KEY (EVENTTIME, DESCRIPTION)
);

COMMIT;
/

CREATE OR REPLACE PROCEDURE LogEvent(Message IN LOG_TABLE.DESCRIPTION%TYPE)
AS
	PRAGMA AUTONOMOUS_TRANSACTION;

BEGIN

	INSERT INTO LOG_TABLE (EVENTTIME, DESCRIPTION) VALUES (CURRENT_TIMESTAMP, Message);

	COMMIT;

EXCEPTION
	WHEN DUP_VAL_ON_INDEX THEN ROLLBACK; RAISE_APPLICATION_ERROR (-20001, 'Impossible d''ecrire l''entree dans la table log');
	
END;
/

COMMIT;
