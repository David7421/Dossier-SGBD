CREATE OR REPLACE PROCEDURE RESTORE
AS
	eval EVALUATION%ROWTYPE;
BEGIN

	LOGEVENT('CBB : PROCEDURE RESTORE', 'Début');

	-- UTILISATEURS
	INSERT INTO UTILISATEUR@CB.DBL (LOGIN, PASSWORD, TOKEN) SELECT LOGIN, PASSWORD, 'OK' FROM UTILISATEUR WHERE TOKEN IS NULL;
	UPDATE UTILISATEUR SET TOKEN = 'OK' WHERE TOKEN IS NULL;

	-- COPIE
	INSERT INTO FILM_COPIE@CB.DBL (FILM_ID, NUM_COPIE, TOKEN) SELECT FILM_ID, NUM_COPIE, 'OK' FROM FILM_COPIE WHERE TOKEN = 'KO';
	UPDATE UTILISATEUR SET TOKEN = 'OK' WHERE TOKEN='KO';

	-- EVALUATIONS
	FOR eval IN(SELECT IDFILM, LOGIN, COTE, AVIS, DATEEVAL, 'OK' FROM EVALUATION WHERE TOKEN = 'KO')
	LOOP
		BEGIN
			INSERT INTO EVALUATION@CB.DBL VALUES eval;
		EXCEPTION
			WHEN dup_val_on_index THEN
				LOGEVENT('CBB : PROCEDURE RESTORE', '(Dupval) Le commentaire existe déjà => UPDATE');
				UPDATE EVALUATION@CB.DBL SET COTE = eval.COTE, AVIS = eval.AVIS, TOKEN = 'OK' WHERE IDFILM = eval.IDFILM AND LOGIN = eval.LOGIN; 
			WHEN OTHERS THEN 
				LOGEVENT('CBB : PROCEDURE RESTORE', 'Insert rate => ' || SQLCODE || ' : ' || SQLERRM); RAISE;
		END;
	END LOOP;


	UPDATE EVALUATION SET TOKEN = 'OK' WHERE TOKEN = 'KO';

	COMMIT;

	LOGEVENT('CBB : PROCEDURE RESTORE', 'Fin');

EXCEPTION
	WHEN OTHERS THEN LOGEVENT('CBB : PROCEDURE RESTORE', 'Copie ratee => ' || SQLCODE || ' : ' || SQLERRM); RAISE;

END;
/

COMMIT;
