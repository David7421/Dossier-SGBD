-------------------
-- SPECIFICATION --
-------------------

CREATE OR REPLACE PACKAGE GESTIONCB
IS
	PROCEDURE BACKUP;
END;










----------
-- BODY --
----------

CREATE OR REPLACE PACKAGE BODY GESTIONCB
IS

	PROCEDURE BACKUP

	BEGIN

		INSERT INTO UTILISATEUR@CBB.DBL (LOGIN, PASSWORD, TOKEN)
		VALUES ();

		INSERT INTO EVALUATION


		IF (TabGroupesIn.COUNT() = 0) THEN RAISE TabInVideExcept; END IF;

		FORALL i IN INDICES OF TabGroupesIn SAVE EXCEPTIONS
			INSERT INTO GROUPES
			VALUES TabGroupesIn(i)
            RETURNING REFGROUPE, REFFORMDET, ANNETUD, ANSCO, REFIMPLAN BULK COLLECT INTO TabOkOut;

		ROLLBACK;
		-- COMMIT; normalement vu qu'on doit soit tout accepter soit tout refuser mais ca salirait ma base de données pour le reste des exercices

	EXCEPTION
		WHEN TabInVideExcept THEN RAISE_APPLICATION_ERROR(-20001, 'ERREUR : Le tableau renseigne doit contenir les renseignements d''un ou plusieurs groupes.');
		WHEN OTHERS THEN
			ROLLBACK;
			TabOKOut.DELETE;
			FOR i IN 1..SQL%BULK_EXCEPTIONS.COUNT LOOP
				IF (SQL%BULK_EXCEPTIONS(i).ERROR_INDEX = 1) THEN IndexError := TabGroupesIn.FIRST;
					ELSE IndexError := TabGroupesIn.NEXT(SQL%BULK_EXCEPTIONS(i).ERROR_INDEX);
				END IF;
				TabFailOut(i).Num := SQL%BULK_exceptions(i).ERROR_CODE;
				TabFailOut(i).Groupe.REFGROUPE := TabGroupesIn(IndexError).REFGROUPE;
				TabFailOut(i).Groupe.REFFORMDET := TabGroupesIn(IndexError).REFFORMDET;
				TabFailOut(i).Groupe.ANNETUD := TabGroupesIn(IndexError).ANNETUD;
				TabFailOut(i).Groupe.ANSCO := TabGroupesIn(IndexError).ANSCO;
				TabFailOut(i).Groupe.REFIMPLAN := TabGroupesIn(IndexError).REFIMPLAN;
			END LOOP;
	END;

END;
