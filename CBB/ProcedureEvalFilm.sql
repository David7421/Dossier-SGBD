create or replace PROCEDURE EVALFILM(film IN NUMBER, login IN VARCHAR2, note IN NUMBER, commentaire IN VARCHAR2)
IS
BEGIN

	LOGEVENT('CBB : PROCEDURE EVALFILM', ' debut');

	MERGE INTO EVALUATION e
    USING (SELECT film ParamFilm, login ParamLogin, note ParamNote, commentaire ParamCommentaire FROM DUAL) ajout
    ON (e.IDFILM = ajout.ParamFilm AND e.LOGIN = ajout.ParamLogin)
    WHEN MATCHED THEN UPDATE SET e.COTE = ajout.ParamNote, e.AVIS = ajout.ParamCommentaire, e.TOKEN = null
    WHEN NOT MATCHED THEN INSERT (IDFILM, LOGIN, COTE, AVIS, DATEEVAL, TOKEN)
    VALUES(ajout.ParamFilm, ajout.ParamLogin, ajout.ParamNote, ajout.ParamCommentaire, sysdate, null);

	LOGEVENT('CBB : PROCEDURE EVALFILM', ' FIN');

EXCEPTION
	WHEN OTHERS THEN LOGEVENT('CBB : PROCEDURE EVALFILM', 'Copie ratee => ' || SQLCODE || ' : ' || SQLERRM); RAISE;

END;
/

COMMIT;
