create or replace TRIGGER COPIECOTESAVIS
BEFORE INSERT OR UPDATE ON EVALUATION
FOR EACH ROW
DECLARE
  checkException exception;
  pragma exception_init(checkException, -2291);
BEGIN
	IF :NEW.TOKEN IS NULL THEN
		:NEW.TOKEN := 'OK';
		LOGEVENT('CB : TRIGGER COPIECOTESAVIS', 'DÃ©but de copie');

			IF (INSERTING) THEN
				INSERT INTO EVALUATION@CBB.DBL (IDFILM, LOGIN, COTE, AVIS, DATEEVAL, TOKEN)
				VALUES (:NEW.IDFILM, :NEW.LOGIN, :NEW.COTE, :NEW.AVIS, :NEW.DATEEVAL, :NEW.TOKEN);
			END IF;

			IF (UPDATING) THEN
				UPDATE EVALUATION@CBB.DBL
				SET	COTE = :NEW.COTE,
					AVIS = :NEW.AVIS,
					DATEEVAL = :NEW.DATEEVAL,
					TOKEN = :NEW.TOKEN
				WHERE	IDFILM = :NEW.IDFILM AND LOGIN = :NEW.LOGIN;
			END IF;

		LOGEVENT('CB : TRIGGER COPIECOTESAVIS', 'Copie rÃ©ussie');
	END IF;

EXCEPTION
  WHEN checkException THEN :NEW.TOKEN := 'KO'; LOGEVENT('CB : TRIGGER COPIECOTESAVIS', 'Copie ratÃ©e (Foreign Key) => ' || SQLCODE || ' : ' || SQLERRM);
	WHEN OTHERS THEN LOGEVENT('CB : TRIGGER COPIECOTESAVIS', 'Copie ratÃ©e => ' || SQLCODE || ' : ' || SQLERRM); RAISE;
END;
/

EXIT;
