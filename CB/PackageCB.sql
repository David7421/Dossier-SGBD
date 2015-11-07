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
			RAISE_APPLICATION_ERROR(-20011, 'Champs titre trop long');
			LOGEVENT('AJOUTER_FILM', 'Erreur: champs titre trop long');
		ELSIF LENGTH(titre) > 58 THEN
			tmp := SUBSTR(titre,0,58);
			LOGEVENT('AJOUTER_FILM', 'TITRE ' || titre || ' TRUNCATE AS ' || tmp);
			new_titre := tmp;
		END IF;

		new_titre_original := titre_original;
		IF LENGTH(titre_original) > 113 THEN
			RAISE_APPLICATION_ERROR(-20012, 'Champs titre original trop long');
			LOGEVENT('AJOUTER_FILM', 'Erreur: champs titre original trop long');
		ELSIF LENGTH(titre_original) > 59 THEN
			tmp := SUBSTR(titre_original,0,59);
			LOGEVENT('AJOUTER_FILM', 'TITRE_ORIGINAL ' || titre_original || ' TRUNCATE AS ' || tmp);
			new_titre_original := tmp;
		END IF;

		new_certification := certification;
		IF LENGTH(certification) > 9 THEN
			RAISE_APPLICATION_ERROR(-20013, 'Champs certification trop long');
			LOGEVENT('AJOUTER_FILM', 'Erreur: champs certification trop long');
		ELSIF LENGTH(certification) > 5 THEN
			tmp := SUBSTR(certification,0,5);
			LOGEVENT('AJOUTER_FILM', 'CERTIFICATION ' || certification || ' TRUNCATE AS ' || tmp);
			new_certification := tmp;
		END IF;

		IF LENGTH(lien_poster) > 32 THEN
			RAISE_APPLICATION_ERROR(-20014, 'Champs lien_poster trop long');
			LOGEVENT('AJOUTER_FILM', 'Erreur: champs lien_poster trop long');
		END IF;

		new_homepage := homepage;
		IF LENGTH(homepage) > 359 THEN
			RAISE_APPLICATION_ERROR(-20015, 'Champs homepage trop long');
			LOGEVENT('AJOUTER_FILM', 'Erreur: champs homepage trop long');
		ELSIF LENGTH(homepage) > 122 THEN
			tmp := SUBSTR(homepage,0,122);
			LOGEVENT('AJOUTER_FILM', 'CERTIFICATION ' || homepage || ' TRUNCATE AS ' || tmp);
			new_homepage := tmp;
		END IF;

		new_tagline := tagline;
		IF LENGTH(tagline) > 871 THEN
			RAISE_APPLICATION_ERROR(-20016, 'Champs tagline trop long');
			LOGEVENT('AJOUTER_FILM', 'Erreur: champs tagline trop long');
		ELSIF LENGTH(tagline) > 172 THEN
			tmp := SUBSTR(tagline,0,172);
			LOGEVENT('AJOUTER_FILM', 'TAGLINE ' || tagline || ' TRUNCATE AS ' || tmp);
			new_tagline := tmp;
		END IF;

		new_overview := overview;
		IF LENGTH(overview) > 1000 THEN
			RAISE_APPLICATION_ERROR(-20017, 'Champs overview trop long');
			LOGEVENT('AJOUTER_FILM', 'Erreur: champs overview trop long');
		ELSIF LENGTH(overview) > 949 THEN
			tmp := SUBSTR(overview,0,949);
			LOGEVENT('AJOUTER_FILM', 'OVERVIEW ' || overview || ' TRUNCATE AS ' || tmp);
			new_overview := tmp;
		END IF;

		IF LENGTH(note_moyenne) > 3 THEN
			RAISE_APPLICATION_ERROR(-20018, 'Champs note_moyenne trop long');
			LOGEVENT('AJOUTER_FILM', 'Erreur: champs note_moyenne trop long');
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

END;