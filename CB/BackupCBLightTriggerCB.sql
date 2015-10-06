CREATE OR REPLACE TRIGGER COPIECOTESAVIS
BEFORE INSERT OR UPDATE ON EVALUATION
FOR EACH ROW
BEGIN
	IF :NEW.TOKEN IS NULL THEN
		:NEW.TOKEN := 'OK';

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
	END IF;

EXCEPTION
	WHEN OTHERS THEN
		IF SQLCODE = -2291 THEN :NEW.TOKEN := 'KO';
		ELSE RAISE;
		END IF;
END;
/

EXIT;
