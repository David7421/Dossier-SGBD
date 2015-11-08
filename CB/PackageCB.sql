-------------------
-- SPECIFICATION --
-------------------

CREATE OR REPLACE PACKAGE PACKAGECB
IS
	PROCEDURE AJOUTER_EVALUATION (f IN EVALUATION.IDFILM%TYPE, l IN EVALUATION.LOGIN%TYPE, c IN EVALUATION.COTE%TYPE, a IN EVALUATION.AVIS%TYPE);
	PROCEDURE MODIFIER_EVALUATION (f IN EVALUATION.IDFILM%TYPE, l IN EVALUATION.LOGIN%TYPE, c IN EVALUATION.COTE%TYPE, a IN EVALUATION.AVIS%TYPE);

	PROCEDURE AJOUTER_FILM(id IN NUMBER, titre IN VARCHAR2, titre_original IN VARCHAR2, date_sortie IN FILM.DATE_SORTIE%TYPE, status IN VARCHAR2, note_moyenne IN NUMBER, 
		nbr_note IN NUMBER, runtime IN NUMBER, certification IN VARCHAR2, lien_poster IN VARCHAR2, budget IN NUMBER, revenus IN NUMBER, homepage IN VARCHAR2, 
		tagline IN VARCHAR2, overview IN VARCHAR2);

	PROCEDURE AJOUTER_GENRE(id IN NUMBER, nom IN VARCHAR2);
	PROCEDURE AJOUTER_PRODUCTEUR(id IN NUMBER, nom IN VARCHAR2);
	PROCEDURE AJOUTER_LANGUE(id IN VARCHAR2, nom IN VARCHAR2);
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
			MODIFIER_EVALUATION(f, l, c, a);
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


	PROCEDURE AJOUTER_FILM(id IN NUMBER, titre IN VARCHAR2, titre_original IN VARCHAR2, date_sortie IN FILM.DATE_SORTIE%TYPE, status IN VARCHAR2, note_moyenne IN NUMBER, 
		nbr_note IN NUMBER, runtime IN NUMBER, certification IN VARCHAR2, lien_poster IN VARCHAR2, budget IN NUMBER, revenus IN NUMBER, homepage IN VARCHAR2, 
		tagline IN VARCHAR2, overview IN VARCHAR2)
	AS
		tmp VARCHAR2(4000);

		CheckException				EXCEPTION;
			PRAGMA EXCEPTION_INIT (CheckException, -2290);

		new_titre VARCHAR2(4000);
		new_titre_original VARCHAR2(4000);
		new_certification VARCHAR2(4000);
		new_homepage VARCHAR2(4000);
		new_tagline VARCHAR2(4000);
		new_overview VARCHAR2(4000);

	BEGIN

		new_titre := titre;
		IF LENGTH(titre) > 112 THEN
			RAISE_APPLICATION_ERROR(-20011, 'Champ titre trop long');
			LOGEVENT('AJOUTER_FILM', 'Erreur: champ titre trop long');
		ELSIF LENGTH(titre) > 58 THEN
			tmp := SUBSTR(titre,0,58);
			LOGEVENT('AJOUTER_FILM', 'TITRE ' || titre || ' TRUNCATE AS ' || tmp);
			new_titre := tmp;
		END IF;

		new_titre_original := titre_original;
		IF LENGTH(titre_original) > 113 THEN
			RAISE_APPLICATION_ERROR(-20012, 'Champ titre original trop long');
			LOGEVENT('AJOUTER_FILM', 'Erreur: champ titre original trop long');
		ELSIF LENGTH(titre_original) > 59 THEN
			tmp := SUBSTR(titre_original,0,59);
			LOGEVENT('AJOUTER_FILM', 'TITRE_ORIGINAL ' || titre_original || ' TRUNCATE AS ' || tmp);
			new_titre_original := tmp;
		END IF;

		new_certification := certification;
		IF LENGTH(certification) > 9 THEN
			RAISE_APPLICATION_ERROR(-20013, 'Champ certification trop long');
			LOGEVENT('AJOUTER_FILM', 'Erreur: champ certification trop long');
		ELSIF LENGTH(certification) > 5 THEN
			tmp := SUBSTR(certification,0,5);
			LOGEVENT('AJOUTER_FILM', 'CERTIFICATION ' || certification || ' TRUNCATE AS ' || tmp);
			new_certification := tmp;
		END IF;

		IF LENGTH(lien_poster) > 32 THEN
			RAISE_APPLICATION_ERROR(-20014, 'Champ lien_poster trop long');
			LOGEVENT('AJOUTER_FILM', 'Erreur: champ lien_poster trop long');
		END IF;

		new_homepage := homepage;
		IF LENGTH(homepage) > 359 THEN
			RAISE_APPLICATION_ERROR(-20015, 'Champ homepage trop long');
			LOGEVENT('AJOUTER_FILM', 'Erreur: champ homepage trop long');
		ELSIF LENGTH(homepage) > 122 THEN
			tmp := SUBSTR(homepage,0,122);
			LOGEVENT('AJOUTER_FILM', 'CERTIFICATION ' || homepage || ' TRUNCATE AS ' || tmp);
			new_homepage := tmp;
		END IF;

		new_tagline := tagline;
		IF LENGTH(tagline) > 871 THEN
			RAISE_APPLICATION_ERROR(-20016, 'Champ tagline trop long');
			LOGEVENT('AJOUTER_FILM', 'Erreur: champ tagline trop long');
		ELSIF LENGTH(tagline) > 172 THEN
			tmp := SUBSTR(tagline,0,172);
			LOGEVENT('AJOUTER_FILM', 'TAGLINE ' || tagline || ' TRUNCATE AS ' || tmp);
			new_tagline := tmp;
		END IF;

		new_overview := overview;
		IF LENGTH(overview) > 1000 THEN
			RAISE_APPLICATION_ERROR(-20017, 'Champ overview trop long');
			LOGEVENT('AJOUTER_FILM', 'Erreur: champ overview trop long');
		ELSIF LENGTH(overview) > 949 THEN
			tmp := SUBSTR(overview,0,949);
			LOGEVENT('AJOUTER_FILM', 'OVERVIEW ' || overview || ' TRUNCATE AS ' || tmp);
			new_overview := tmp;
		END IF;

		IF LENGTH(note_moyenne) > 3 THEN
			RAISE_APPLICATION_ERROR(-20018, 'Champ note_moyenne trop long');
			LOGEVENT('AJOUTER_FILM', 'Erreur: champ note_moyenne trop long');
		END IF;

		INSERT INTO FILM VALUES(id, new_titre, new_titre_original, date_sortie, status, note_moyenne, nbr_note, runtime, new_certification, 
			lien_poster, budget, revenus, new_homepage, new_tagline, new_overview);
		COMMIT;

	EXCEPTION

		WHEN CheckException THEN
			IF SQLERRM LIKE '%CK_FILM_STATUS%' THEN RAISE_APPLICATION_ERROR(-20019, 'Valeur invalide pour le status du film'); 
			ELSIF SQLERRM LIKE '%CK_FILM_TITRE%' THEN RAISE_APPLICATION_ERROR(-20020, 'Le titre du film doit être renseigné');
			ELSIF SQLERRM LIKE '%CK_FILM_ORI_TITRE%' THEN RAISE_APPLICATION_ERROR(-20021, 'Le titre original du film doit être renseigné');
			END IF;
			ROLLBACK;

		WHEN DUP_VAL_ON_INDEX THEN 
			RAISE_APPLICATION_ERROR(-20022, 'Le film '||id||' existe déjà dans la base de donnée');
			ROLLBACK;

		WHEN OTHERS THEN RAISE; ROLLBACK;
	END;


	PROCEDURE AJOUTER_GENRE(id IN NUMBER, nom IN VARCHAR2)
	AS
	BEGIN
		IF LENGTH(nom) > 16 THEN
			RAISE_APPLICATION_ERROR(-20023, 'Champ nom trop long');
			LOGEVENT('AJOUTER_GENRE', 'Erreur: champ nom trop long');
		END IF;


		INSERT INTO GENRE VALUES(id, nom);
		COMMIT;

	EXCEPTION

		WHEN DUP_VAL_ON_INDEX THEN 
			RAISE_APPLICATION_ERROR(-20027, 'Le genre '||id||' existe déjà dans la base de donnée');
			ROLLBACK;

		WHEN OTHERS THEN RAISE; ROLLBACK;
	END;


	PROCEDURE AJOUTER_PRODUCTEUR(id IN NUMBER, nom IN VARCHAR2)
	AS
	BEGIN

		IF LENGTH(nom) > 16 THEN
			RAISE_APPLICATION_ERROR(-20023, 'Champ nom trop long');
			LOGEVENT('AJOUTER_PRODUCTEUR', 'Erreur: champ nom trop long');
		END IF;


		INSERT INTO PRODUCTEUR VALUES(id, nom);
		COMMIT;

	EXCEPTION

		WHEN DUP_VAL_ON_INDEX THEN 
			RAISE_APPLICATION_ERROR(-20026, 'Le producteur '||id||' existe déjà dans la base de donnée');
			ROLLBACK;

		WHEN OTHERS THEN RAISE; ROLLBACK;
	END;

	PROCEDURE AJOUTER_LANGUE(id IN VARCHAR2, nom IN VARCHAR2)
	AS
		tmp VARCHAR2(4000);

		new_nom VARCHAR2(4000);

		valueTooLong EXCEPTION;
			PRAGMA EXCEPTION_INIT (valueTooLong, -12899);
	BEGIN

		new_nom := nom;
		IF LENGTH(nom) > 16 THEN
			RAISE_APPLICATION_ERROR(-20024, 'Champ nom trop long');
			LOGEVENT('AJOUTER_LANGUE', 'Erreur: champ nom trop long');
		ELSIF LENGTH(nom) > 15 THEN
			tmp := SUBSTR(nom,0,15);
			LOGEVENT('AJOUTER_LANGUE', 'OVERVIEW ' || nom || ' TRUNCATE AS ' || tmp);
			new_nom := tmp;
		END IF;


		INSERT INTO LANGUE VALUES(id, new_nom);
		COMMIT;

	EXCEPTION

		WHEN DUP_VAL_ON_INDEX THEN 
			RAISE_APPLICATION_ERROR(-20025, 'La langue '||id||' existe déjà dans la base de donnée');
			ROLLBACK;
		WHEN valueTooLong THEN
			RAISE_APPLICATION_ERROR(-20028, 'Le code ISO de la langue est trop long (max 2 lettres)');
			ROLLBACK;

		WHEN OTHERS THEN RAISE; ROLLBACK;
	END;


END;
