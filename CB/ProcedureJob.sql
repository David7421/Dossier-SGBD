CREATE OR REPLACE PROCEDURE BACKUP
IS
BEGIN

	-- On bloque les tables en I/U/D pour être sûr que les tuples ne se modifient pas durant le backup, se termine au commit
	LOCK TABLE EVALUATION IN SHARE ROW EXCLUSIVE MODE; 
	LOCK TABLE UTILISATEUR IN SHARE ROW EXCLUSIVE MODE;

	-- UTILISATEURS
	INSERT INTO UTILISATEUR@CBB.DBL (LOGIN, PASSWORD, TOKEN) SELECT LOGIN, PASSWORD, 'OK' FROM UTILISATEUR WHERE TOKEN IS NULL;
	UPDATE UTILISATEUR SET TOKEN = 'OK' WHERE TOKEN IS NULL;

	-- EVALUATIONS
	INSERT INTO EVALUATION@CBB.DBL (IDFILM, LOGIN, COTE, AVIS, DATEEVAL, TOKEN) SELECT IDFILM, LOGIN, COTE, AVIS, DATEEVAL, 'OK' FROM EVALUATION WHERE TOKEN = 'KO';
	UPDATE EVALUATION SET TOKEN = 'OK' WHERE TOKEN = 'KO';

	COMMIT;

	LOGEVENT('CB : Backup');

END;
/

EXIT;
