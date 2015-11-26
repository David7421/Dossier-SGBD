create or replace PROCEDURE EVALFILM(film IN NUMBER, login IN VARCHAR2, note IN NUMBER, commentaire IN VARCHAR2)
IS
BEGIN

	LOGEVENT('CBB : EVALFILM', ' debut');

	MERGE INTO EVALUATION e
    USING (SELECT film Nidfilm, login idlog, note eval, commentaire Navis FROM DUAL) ajout
    ON (e.IDFILM = ajout.Nidfilm AND e.LOGIN = ajout.idlog)
    WHEN MATCHED THEN UPDATE SET e.COTE = ajout.eval, e.AVIS = ajout.Navis
    WHEN NOT MATCHED THEN INSERT (IDFILM, LOGIN, COTE, AVIS, DATEEVAL, TOKEN)
    VALUES(ajout.Nidfilm, ajout.idlog, ajout.eval, ajout.Navis, sysdate, null);

	LOGEVENT('CBB : EVALFILM', ' FIN');

EXCEPTION
	WHEN OTHERS THEN LOGEVENT('CBB : TRIGGER EVALFILM', 'Copie ratee => ' || SQLCODE || ' : ' || SQLERRM); RAISE;

END;