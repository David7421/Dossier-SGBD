create or replace TRIGGER COPIEFILM
BEFORE INSERT ON FILM_COPIE
FOR EACH ROW
DECLARE
  checkException exception;
  pragma exception_init(checkException, -2291);
BEGIN
	IF :NEW.TOKEN IS NULL THEN --TOKEN null == la copie du film n'a pas encore été copiée sur CBB
		:NEW.TOKEN := 'OK';
		LOGEVENT('CB : TRIGGER COPIEFILM', 'Debut de copie');

		INSERT INTO FILM_COPIE@CBB.DBL (FILM_ID, NUM_COPIE, TOKEN)
		VALUES (:NEW.FILM_ID, :NEW.NUM_COPIE, :NEW.TOKEN);

		LOGEVENT('CB : TRIGGER COPIEFILM', 'Copie reussie');
	END IF;

EXCEPTION
  	WHEN checkException THEN :NEW.TOKEN := 'KO'; LOGEVENT('CB : TRIGGER COPIEFILM', 'Copie ratee (Foreign Key) => ' || SQLCODE || ' : ' || SQLERRM);
	WHEN OTHERS THEN LOGEVENT('CB : TRIGGER COPIEFILM', 'Copie ratee => ' || SQLCODE || ' : ' || SQLERRM); RAISE;
END;
/

EXIT;