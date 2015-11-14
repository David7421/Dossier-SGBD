-------------------
-- SPECIFICATION --
-------------------

CREATE OR REPLACE PACKAGE PACKAGECB
IS
	PROCEDURE AJOUTER_EVALUATION (f IN EVALUATION.IDFILM%TYPE, l IN EVALUATION.LOGIN%TYPE, c IN EVALUATION.COTE%TYPE, a IN EVALUATION.AVIS%TYPE);
	PROCEDURE MODIFIER_EVALUATION (f IN EVALUATION.IDFILM%TYPE, l IN EVALUATION.LOGIN%TYPE, c IN EVALUATION.COTE%TYPE, a IN EVALUATION.AVIS%TYPE);

	FUNCTION VERIF_FILM_FIELDS(id IN NUMBER, titre IN VARCHAR2, titre_original IN VARCHAR2, date_sortie IN FILM.DATE_SORTIE%TYPE, status IN VARCHAR2, note_moyenne IN NUMBER, 
		nbr_note IN NUMBER, runtime IN NUMBER, certification IN VARCHAR2, lien_poster IN NUMBER, budget IN NUMBER, revenus IN NUMBER, homepage IN VARCHAR2, 
		tagline IN VARCHAR2, overview IN VARCHAR2, nbr_copy IN NUMBER) RETURN film%ROWTYPE;

	FUNCTION VERIF_GENRE_FIELDS(id IN NUMBER, nom IN VARCHAR2) RETURN genre%ROWTYPE;
	FUNCTION VERIF_PRODUCTEUR_FIELDS(id IN NUMBER, nom IN VARCHAR2) RETURN producteur%ROWTYPE;
	FUNCTION VERIF_PAYS_FIELDS(id IN VARCHAR2, nom IN VARCHAR2) RETURN pays%ROWTYPE;
	FUNCTION VERIF_LANGUE_FIELDS(id IN VARCHAR2, nom IN VARCHAR2) RETURN langue%ROWTYPE;
	FUNCTION VERIF_PERSONNE_FIELDS(id IN NUMBER, nom IN VARCHAR2, image IN VARCHAR2) RETURN personne%ROWTYPE;
	FUNCTION VERIF_ROLE_FIELDS(id IN NUMBER,id_film IN FILM.ID%TYPE ,nom IN VARCHAR2) RETURN role%ROWTYPE;
END;
/




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


	FUNCTION VERIF_FILM_FIELDS(id IN NUMBER, titre IN VARCHAR2, titre_original IN VARCHAR2, date_sortie IN FILM.DATE_SORTIE%TYPE, status IN VARCHAR2, note_moyenne IN NUMBER, 
		nbr_note IN NUMBER, runtime IN NUMBER, certification IN VARCHAR2, lien_poster IN NUMBER, budget IN NUMBER, revenus IN NUMBER, homepage IN VARCHAR2, 
		tagline IN VARCHAR2, overview IN VARCHAR2, nbr_copy IN NUMBER) RETURN film%ROWTYPE
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
		new_note_moyenne NUMBER;
		new_nbr_note NUMBER;
		new_runtime NUMBER;
		new_budget NUMBER;
		new_revenus NUMBER;


		returnValue film%ROWTYPE;

	BEGIN

		new_titre := titre;
		IF LENGTH(titre) > 112 THEN
			RAISE_APPLICATION_ERROR(-20011, 'Champ titre trop long');
			LOGEVENT('VERIF_FILM_FIELD', 'Erreur: champ titre trop long');
		ELSIF LENGTH(titre) > 58 THEN
			tmp := SUBSTR(titre,0,58);
			LOGEVENT('VERIF_FILM_FIELD', 'TITRE ' || titre || ' TRUNCATE AS ' || tmp);
			new_titre := tmp;
		END IF;

		new_titre_original := titre_original;
		IF LENGTH(titre_original) > 113 THEN
			RAISE_APPLICATION_ERROR(-20012, 'Champ titre original trop long');
			LOGEVENT('VERIF_FILM_FIELD', 'Erreur: champ titre original trop long');
		ELSIF LENGTH(titre_original) > 59 THEN
			tmp := SUBSTR(titre_original,0,59);
			LOGEVENT('VERIF_FILM_FIELD', 'TITRE_ORIGINAL ' || titre_original || ' TRUNCATE AS ' || tmp);
			new_titre_original := tmp;
		END IF;

		new_certification := certification;
		IF certification IN ('tt2058001', 'None', 'Not Rated', 'Unrated', '2009', 'undefined', '-', ' ') THEN
			new_certification := NULL;
			LOGEVENT('VERIF_FILM_FIELD', 'Valeur certification invalide. Champ mis à NULL');
		ELSIF LENGTH(certification) > 9 THEN
			new_certification := NULL;
			LOGEVENT('VERIF_FILM_FIELD', 'Erreur: champ certification trop long. Champ mis à NULL');
		ELSIF LENGTH(certification) > 5 THEN
			tmp := SUBSTR(certification,0,5);
			LOGEVENT('VERIF_FILM_FIELD', 'CERTIFICATION ' || certification || ' TRUNCATE AS ' || tmp);
			new_certification := tmp;
		END IF;

		new_homepage := homepage;
		IF LENGTH(homepage) > 122 THEN
			LOGEVENT('VERIF_FILM_FIELD', 'Home page trop longue. Valeur mise à null');
			new_homepage := NULL;
		END IF;

		new_tagline := tagline;
		IF LENGTH(tagline) > 871 THEN
			new_tagline := NULL;
			LOGEVENT('VERIF_FILM_FIELD', 'champ tagline trop long. Mis à NULL');
		ELSIF LENGTH(tagline) > 172 THEN
			tmp := SUBSTR(tagline,0,172);
			LOGEVENT('VERIF_FILM_FIELD', 'TAGLINE ' || tagline || ' TRUNCATE AS ' || tmp);
			new_tagline := tmp;
		END IF;

		new_overview := overview;
		IF LENGTH(overview) > 1000 THEN
			new_overview := NULL;
			LOGEVENT('VERIF_FILM_FIELD', 'champ overview trop long. Mis à');
		ELSIF LENGTH(overview) > 949 THEN
			tmp := SUBSTR(overview,0,949);
			LOGEVENT('VERIF_FILM_FIELD', 'OVERVIEW ' || overview || ' TRUNCATE AS ' || tmp);
			new_overview := tmp;
		END IF;

		new_note_moyenne := note_moyenne;
		IF LENGTH(note_moyenne) > 3 THEN
			new_note_moyenne := NULL;
			LOGEVENT('VERIF_FILM_FIELD', 'Erreur: champ note moyenne incorrecte valeur mise à NULL');
		END IF;

		new_nbr_note := nbr_note;
		IF nbr_note < 0 THEN
			new_nbr_note := 0;
			LOGEVENT('VERIF_FILM_FIELD', 'Erreur: Nombre de notes négatif. Valeur mise à 0');
		END IF;

		new_runtime := runtime;
		IF runtime <= 0 THEN
			new_runtime := NULL;
			LOGEVENT('VERIF_FILM_FIELD', 'Erreur: runtime négatif ou 0 valeur mise à NULL');
		END IF;

		new_budget := budget;
		IF LENGTH(budget)>9 THEN
			new_budget := NULL;
			LOGEVENT('VERIF_FILM_FIELD', 'Budget trop gros pour '||id||' Budget mis à NULL');
		END IF;

		new_revenus := revenus;
		IF LENGTH(revenus)>10 THEN
			new_revenus := NULL;
			LOGEVENT('VERIF_FILM_FIELD', 'Revenus trop gros pour '||id||' Revenus mis à NULL');
		END IF;


		returnValue.id := id;
		returnValue.titre := new_titre;
		returnValue.titre_original := new_titre_original;
		returnValue.date_sortie := date_sortie;
		returnValue.statut := UPPER(status);
		returnValue.note_moyenne := new_note_moyenne;
		returnValue.nombre_note := new_nbr_note;
		returnValue.runtime := new_runtime;
		returnValue.certification := new_certification;
		returnValue.affiche := lien_poster;
		returnValue.budget := new_budget;
		returnValue.revenu := new_revenus;
		returnValue.homepage := new_homepage;
		returnValue.tagline :=new_tagline;
		returnValue.overview := new_overview;
		returnValue.nbr_copie := nbr_copy;

		RETURN returnValue;

	EXCEPTION

		WHEN CheckException THEN
			IF SQLERRM LIKE '%CK_FILM_STATUS%' THEN RAISE_APPLICATION_ERROR(-20019, 'Valeur invalide pour le status du film'); 
			ELSIF SQLERRM LIKE '%CK_FILM_TITRE%' THEN RAISE_APPLICATION_ERROR(-20020, 'Le titre du film doit être renseigné');
			ELSIF SQLERRM LIKE '%CK_FILM_ORI_TITRE%' THEN RAISE_APPLICATION_ERROR(-20021, 'Le titre original du film doit être renseigné');
			END IF;

		WHEN OTHERS THEN RAISE;
	END;


	FUNCTION VERIF_GENRE_FIELDS(id IN NUMBER, nom IN VARCHAR2) RETURN genre%ROWTYPE
	AS
		returnValue genre%ROWTYPE;
	BEGIN
		IF LENGTH(nom) > 16 THEN
			RAISE_APPLICATION_ERROR(-20023, 'Champ nom trop long');
			LOGEVENT('VERIF_GENRE_FIELDS', 'Erreur: champ nom trop long');
		END IF;

		returnValue.id := id;
		returnValue.nom := nom;

		RETURN returnValue;

	EXCEPTION

		WHEN OTHERS THEN RAISE;
	END;


	FUNCTION VERIF_PRODUCTEUR_FIELDS(id IN NUMBER, nom IN VARCHAR2) RETURN producteur%ROWTYPE
	AS
		returnValue producteur%ROWTYPE;
		tmp VARCHAR2(45);
		new_nom VARCHAR2(4000);
	BEGIN
		new_nom := nom;
		IF LENGTH(nom) > 90 THEN
			RAISE_APPLICATION_ERROR(-20023, 'Champ nom trop long');
			LOGEVENT('VERIF_PRODUCTEUR_FIELDS', 'Erreur: champ nom trop long');
		ELSIF LENGTH(nom) > 45 THEN
			tmp := SUBSTR(nom,0,45);
			LOGEVENT('VERIF_PRODUCTEUR_FIELDS', 'NOM ' || nom || ' TRUNCATE AS ' || tmp);
			new_nom := tmp;
		END IF;

		returnValue.id := id;
		returnValue.nom := new_nom;
		
		RETURN returnValue;

	EXCEPTION
		WHEN OTHERS THEN RAISE; 
	END;


	FUNCTION VERIF_PAYS_FIELDS(id IN VARCHAR2, nom IN VARCHAR2) RETURN pays%ROWTYPE
	AS
		returnValue pays%ROWTYPE;
		tmp VARCHAR2(31);
		new_nom VARCHAR2(4000);
	BEGIN
		new_nom := nom;
		IF LENGTH(nom) > 38 THEN
			new_nom := NULL;
			LOGEVENT('VERIF_PAYS_FIELDS', 'Nom du champ pays trop long. Nom = null');
		ELSIF LENGTH(nom) > 31 THEN
			tmp := SUBSTR(nom,0,31);
			LOGEVENT('VERIF_PAYS_FIELDS', 'NOM ' || nom || ' TRUNCATE AS ' || tmp);
			new_nom := tmp;
		END IF;

		returnValue.id := id;
		returnValue.nom := new_nom;
		
		RETURN returnValue;
	EXCEPTION
		WHEN OTHERS THEN RAISE;
	END;



	FUNCTION VERIF_LANGUE_FIELDS(id IN VARCHAR2, nom IN VARCHAR2) RETURN langue%ROWTYPE
	AS
		tmp VARCHAR2(4000);
		new_nom VARCHAR2(4000);
		returnValue langue%ROWTYPE;
	BEGIN

		new_nom := nom;
		IF LENGTH(nom) > 16 THEN
			new_nom := NULL;
			LOGEVENT('VERIF_PAYS_FIELDS', 'Nom du champ langue trop long. Nom = null');
		ELSIF LENGTH(nom) > 15 THEN
			tmp := SUBSTR(nom,0,15);
			LOGEVENT('VERIF_LANGUE_FIELDS', 'NOM: ' || nom || ' TRUNCATE AS ' || tmp);
			new_nom := tmp;
		END IF;

		returnValue.id := id;
		returnValue.nom := new_nom;

		RETURN returnValue;
		
	EXCEPTION
		WHEN OTHERS THEN RAISE;
	END;


	FUNCTION VERIF_PERSONNE_FIELDS(id IN NUMBER, nom IN VARCHAR2, image IN VARCHAR2) RETURN personne%ROWTYPE
	AS
		tmp VARCHAR2(4000);
		new_nom VARCHAR2(4000);
		new_image VARCHAR2(4000);
		returnValue personne%ROWTYPE;
	BEGIN

		new_image := image;
		IF LENGTH(image) > 32 THEN
			LOGEVENT('VERIF_REALISATEUR_FIELDS', 'Lien trop grand : NULL');
			new_image := NULL;
		END IF;

		new_nom := nom;
		IF LENGTH(nom) > 35 THEN
			RAISE_APPLICATION_ERROR(-20024, 'Champ nom trop long');
			LOGEVENT('VERIF_REALISATEUR_FIELDS', 'Erreur: champ nom trop long');
		ELSIF LENGTH(nom) > 23 THEN
			tmp := SUBSTR(nom,0,23);
			LOGEVENT('VERIF_REALISATEUR_FIELDS', 'NOM: ' || nom || ' TRUNCATE AS ' || tmp);
			new_nom := tmp;
		END IF;

		returnValue.id := id;
		returnValue.nom := new_nom;
		returnValue.photo := new_image;

		RETURN returnValue;
		
	EXCEPTION
		WHEN OTHERS THEN RAISE;
	END;


	FUNCTION VERIF_ROLE_FIELDS(id IN NUMBER, id_film IN FILM.ID%TYPE ,nom IN VARCHAR2) RETURN role%ROWTYPE
	AS
		tmp VARCHAR2(4000);
		new_nom VARCHAR2(4000);
		returnValue role%ROWTYPE;
	BEGIN

		new_nom := nom;
		IF nom IS NULL THEN
			RAISE_APPLICATION_ERROR(-20024, 'le nom est null');
			LOGEVENT('VERIF_REALISATEUR_FIELDS', 'nom null : rejeté');
		ELSIF LENGTH(nom) > 35 THEN
			RAISE_APPLICATION_ERROR(-20024, 'Champ nom trop long');
			LOGEVENT('VERIF_REALISATEUR_FIELDS', 'Erreur: champ nom trop long');
		ELSIF LENGTH(nom) > 23 THEN
			tmp := SUBSTR(nom,0,23);
			LOGEVENT('VERIF_REALISATEUR_FIELDS', 'NOM: ' || nom || ' TRUNCATE AS ' || tmp);
			new_nom := tmp;
		END IF;

		returnValue.id := id;
		returnValue.FILM_ASSOCIE := id_film;
		returnValue.nom := new_nom;

		RETURN returnValue;
		
	EXCEPTION
		WHEN OTHERS THEN RAISE;
	END;


END;
/

EXIT;
