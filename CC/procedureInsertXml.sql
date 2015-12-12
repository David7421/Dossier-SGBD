CREATE OR REPLACE PROCEDURE RECEPTION_FILM
AS
BEGIN

	INSERT INTO FILMSCHEMA SELECT * FROM TMPXML@CB.DBL;

	COMMIT;

EXCEPTION
	WHEN OTHERS THEN LOGEVENT('procedure alimCC', 'ERREUR : ' ||SQLERRM); ROLLBACK;
END;

