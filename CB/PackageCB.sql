-------------------
-- SPECIFICATION --
-------------------

CREATE OR REPLACE PACKAGE PACKAGECB
IS
	PROCEDURE AJOUTER_EVALUATION (f IN EVALUATION.IDFILM%TYPE, l IN EVALUATION.LOGIN%TYPE, c IN EVALUATION.COTE%TYPE, a IN EVALUATION.AVIS%TYPE);
	PROCEDURE MODIFIER_EVALUATION (f IN EVALUATION.IDFILM%TYPE, l IN EVALUATION.LOGIN%TYPE, c IN EVALUATION.COTE%TYPE, a IN EVALUATION.AVIS%TYPE);

	PROCEDURE AJOUTER_FILM(i IN NUMBER, t IN VARCHAR2, t_o IN VARCHAR2, d IN FILM.DATE_SORTIE%TYPE, s IN VARCHAR2, nm IN NUMBER, nn IN NUMBER,
		r IN NUMBER, c IN VARCHAR2, lp IN VARCHAR2, b IN NUMBER, re IN NUMBER, h IN VARCHAR2, ta IN VARCHAR2, o IN VARCHAR2);
END;





----------
-- BODY --
----------

CREATE OR REPLACE PACKAGE BODY PACKAGECB
IS

	PROCEDURE AJOUTER_EVALUATION (f IN EVALUATION.IDFILM%TYPE, l IN EVALUATION.LOGIN%TYPE, c IN EVALUATION.COTE%TYPE, a IN EVALUATION.AVIS%TYPE)
	AS

		NotNullException			EXCEPTION;
			PRAGMA EXCEPTION_INIT (NotNullException, -1400);
		CheckException				EXCEPTION;
			PRAGMA EXCEPTION_INIT (CheckException, -2290);
		ForeignKeyException			EXCEPTION;
			PRAGMA EXCEPTION_INIT (ForeignKeyException, -2291);
		-- TimeOutException			EXCEPTION;
		-- 	PRAGMA EXCEPTION_INIT (TimeOutException, -2291);

	BEGIN

		INSERT INTO EVALUATION (IDFILM, LOGIN, COTE, AVIS, DATEEVAL) VALUES (f, l, c, a, CURRENT_DATE);
		COMMIT;

	EXCEPTION

		WHEN DUP_VAL_ON_INDEX THEN
			MODIFIER(f, l, c, a);
			ROLLBACK;

		WHEN NotNullException THEN
			RAISE_APPLICATION_ERROR(-20001, 'Le film et le login ne peuvent pas ne pas être renseignés !');
			ROLLBACK;

		WHEN CheckException THEN
			IF SQLERRM LIKE '%CK_COTEAVIS_NOTNULL%' THEN RAISE_APPLICATION_ERROR(-20002, 'La cote et l''avis ne peuvent pas être simultanément inconnus !'); END IF;
			ROLLBACK;

		WHEN ForeignKeyException THEN
			CASE
				WHEN SQLERRM LIKE '%REF_UTILISATEUR_LOGIN%' THEN RAISE_APPLICATION_ERROR (-20003, 'Le login de l''utilisateur (' || l || ') n''existe pas !');
				-- FK sur IDFILM à rajouter en temps utile
				ROLLBACK;
			END CASE;

		-- WHEN TimeOutException THEN
			-- RAISE_APPLICATION_ERROR(-20005, 'Ajout momentanément impossible, veuillez réessayer d''ici quelques minutes.');
			--	ROLLBACK;

		WHEN OTHERS THEN ROLLBACK; RAISE;

	END;





	PROCEDURE MODIFIER_EVALUATION (f IN EVALUATION.IDFILM%TYPE, l IN EVALUATION.LOGIN%TYPE, c IN EVALUATION.COTE%TYPE, a IN EVALUATION.AVIS%TYPE)
	AS

		NotNullException			EXCEPTION;
			PRAGMA EXCEPTION_INIT (NotNullException, -1400);
		CheckException				EXCEPTION;
			PRAGMA EXCEPTION_INIT (CheckException, -2290);
		-- TimeOutException			EXCEPTION;
		-- 	PRAGMA EXCEPTION_INIT (TimeOutException, -2291);

	BEGIN

		UPDATE EVALUATION SET COTE = c, AVIS = a, DATEEVAL = CURRENT_DATE, TOKEN = NULL WHERE IDFILM = f AND LOGIN = l;
		COMMIT;

	EXCEPTION

		WHEN NotNullException THEN
			RAISE_APPLICATION_ERROR(-20001, 'Le film et le login ne peuvent pas ne pas être renseignés !');
			ROLLBACK;

		WHEN CheckException THEN
			IF SQLERRM LIKE '%CK_COTEAVIS_NOTNULL%' THEN RAISE_APPLICATION_ERROR(-20002, 'La cote et l''avis ne peuvent pas être simultanément inconnus !'); END IF;
			ROLLBACK;

		-- WHEN TimeOutException THEN
			-- RAISE_APPLICATION_ERROR(-20005, 'Ajout momentanément impossible, veuillez réessayer d''ici quelques minutes.');
			-- ROLLBACK;

		WHEN OTHERS THEN ROLLBACK; RAISE;

	END;


	PROCEDURE AJOUTER_FILM(i IN NUMBER, t IN VARCHAR2, t_o IN VARCHAR2, d IN FILM.DATE_SORTIE%TYPE, s IN VARCHAR2, nm IN NUMBER, nn IN NUMBER,
		r IN NUMBER, c IN VARCHAR2, lp IN VARCHAR2, b IN NUMBER, re IN NUMBER, h IN VARCHAR2, ta IN VARCHAR2, o IN VARCHAR2) 
	AS
		tmp VARCHAR2(4000);
	BEGIN

		IF LENGTH(t) > 58 THEN
			tmp := SUBSTR(t,0,58);
			LOGEVENT('FILM', 'TITRE ' || t || ' TRUNCATE AS ' || tmp);
			t := tmp;
		END IF;

		IF LENGTH(t_o) > 59 THEN
			tmp := SUBSTR(t_o,0,59);
			LOGEVENT('FILM', 'TITRE_ORIGINAL ' || t_o || ' TRUNCATE AS ' || tmp);
			t_o := tmp;
		END IF;

		IF LENGTH(c) > 5 THEN
			tmp := SUBSTR(c,0,5);
			LOGEVENT('FILM', 'CERTIFICATION ' || c || ' TRUNCATE AS ' || tmp);
			c := tmp;
		END IF;

		IF LENGTH(ta) > 172 THEN
			tmp := SUBSTR(ta,0,172);
			LOGEVENT('FILM', 'TAGLINE ' || ta || ' TRUNCATE AS ' || tmp);
			ta := tmp;
		END IF;

		IF LENGTH(o) > 949 THEN
			tmp := SUBSTR(o,0,949);
			LOGEVENT('FILM', 'OVERVIEW ' || o || ' TRUNCATE AS ' || tmp);
			o := tmp;
		END IF;

		IF LENGTH(nm) > 3 THEN
			IF nm > 10 THEN
				LOGEVENT('FILM', 'NOTE_MOYENNE = '|| nm||' VALUE TRUNCATE TO 10');
				nm := 10;
			ELSE
				LOGEVENT('FILM', 'NOTE_MOYENNE = '|| nm||' VALUE TRUNCATE TO ' || TRUNC(nm, 1));
				nm := TRUNC(nm, 1);
			END IF;
		END IF;

		INSERT INTO FILM VALUES(i, t, t_o, d, s, nm, nn, r, c, lp, b, re, h, ta, o);
		COMMIT;

	EXCEPTION
		WHEN OTHERS THEN ROLLBACK; RAISE;
	END;

END;