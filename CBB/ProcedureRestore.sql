CREATE OR REPLACE PROCEDURE RESTORE
IS
BEGIN

	LOGEVENT('CBB : Restore', 'DEBUT');

	-- UTILISATEURS
	INSERT INTO UTILISATEUR@CB.DBL (LOGIN, PASSWORD, TOKEN) SELECT LOGIN, PASSWORD, 'OK' FROM UTILISATEUR WHERE TOKEN IS NULL;
	UPDATE UTILISATEUR SET TOKEN = 'OK' WHERE TOKEN IS NULL;

	-- EVALUATIONS
	INSERT INTO EVALUATION@CB.DBL (IDFILM, LOGIN, COTE, AVIS, DATEEVAL, TOKEN) SELECT IDFILM, LOGIN, COTE, AVIS, DATEEVAL, 'OK' FROM EVALUATION WHERE TOKEN = 'KO';
	UPDATE EVALUATION SET TOKEN = 'OK' WHERE TOKEN = 'KO';

	COMMIT;

	LOGEVENT('CBB : Restore', 'Fin');

EXCEPTION
	WHEN OTHERS THEN LOGEVENT('CBB : RESTORE', 'Copie ratee => ' || SQLCODE || ' : ' || SQLERRM); RAISE;

END;
/
EXIT;
