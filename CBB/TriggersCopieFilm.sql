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

		INSERT INTO FILM_COPIE@CB.DBL (FILM_ID, NUM_COPIE, TOKEN)
		VALUES (:NEW.FILM_ID, :NEW.NUM_COPIE, :NEW.TOKEN);

		LOGEVENT('CB : TRIGGER COPIEFILM', 'Copie reussie');
	END IF;

EXCEPTION
  	WHEN checkException THEN :NEW.TOKEN := 'KO'; LOGEVENT('CBB : TRIGGER COPIEFILM', 'Copie ratee (Foreign Key) => ' || SQLCODE || ' : ' || SQLERRM);
	WHEN OTHERS THEN LOGEVENT('CBB : TRIGGER COPIEFILM', 'Copie ratee => ' || SQLCODE || ' : ' || SQLERRM); RAISE;
END;
/



create or replace TRIGGER DELETECOPIE
AFTER DELETE ON FILM_COPIE
FOR EACH ROW
DECLARE
BEGIN

	DELETE FROM FILM_COPIE@CB.DBL
	WHERE FILM_ID = :OLD.FILM_ID
	AND NUM_COPIE = :OLD.NUM_COPIE;

EXCEPTION
	WHEN OTHERS THEN 
		LOGEVENT('CBB : TRIGGER DELETECOPIE', 'Delete ratee => ' || SQLCODE || ' : ' || SQLERRM);
END;
/

COMMIT;
