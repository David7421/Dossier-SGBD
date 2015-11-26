CREATE OR REPLACE PROCEDURE BACKUP
IS
BEGIN

	LOGEVENT('CB : PROCEDURE BACKUP', 'Début du backup');

	-- UTILISATEURS
	INSERT INTO UTILISATEUR@CBB.DBL (LOGIN, PASSWORD, TOKEN) SELECT LOGIN, PASSWORD, 'OK' FROM UTILISATEUR WHERE TOKEN IS NULL;

	--AFFICHES
	INSERT INTO AFFICHE@CBB.DBL(ID, IMAGE) SELECT AFFICHE.ID, IMAGE FROM AFFICHE INNER JOIN FILM ON FILM.AFFICHE = AFFICHE.ID WHERE TOKEN IS NULL;

	--FILMS
	INSERT INTO FILM@CBB.DBL SELECT ID, TITRE, TITRE_ORIGINAL, DATE_SORTIE, STATUT, NOTE_MOYENNE, NOMBRE_NOTE, RUNTIME, CERTIFICATION, 
	AFFICHE, BUDGET, REVENU, HOMEPAGE, TAGLINE, OVERVIEW, NBR_COPIE,'OK' FROM FILM WHERE TOKEN IS NULL;

	--COPIE FILM
	INSERT INTO FILM_COPIE@CBB.DBL (FILM_ID, NUM_COPIE, TOKEN) SELECT FILM_ID, NUM_COPIE, 'OK' FROM FILM_COPIE WHERE TOKEN = 'KO';

	--COPIE GENRE 
	INSERT INTO GENRE@CBB.DBL (ID, NOM, TOKEN) SELECT ID, NOM, 'OK' FROM GENRE WHERE TOKEN IS NULL;

	--COPIE FILM_GENRE
	INSERT INTO FILM_GENRE@CBB.DBL (ID_FILM, ID_GENRE) SELECT ID_FILM, ID_GENRE FROM FILM_GENRE INNER JOIN FILM ON ID = ID_FILM WHERE TOKEN IS NULL;

	--COPIE PRODUCTEURS
	INSERT INTO PRODUCTEUR@CBB.DBL (ID, NOM, TOKEN) SELECT ID, NOM, 'OK' FROM PRODUCTEUR WHERE TOKEN IS NULL;

	--COPIE FILM_PRODUCTEUR
	INSERT INTO FILM_PRODUCTEUR@CBB.DBL (ID_FILM, ID_PRODUCTEUR) SELECT ID_FILM, ID_PRODUCTEUR FROM FILM_PRODUCTEUR INNER JOIN FILM ON ID = ID_FILM 
	WHERE TOKEN IS NULL;

	--COPIE LANGUE
	INSERT INTO LANGUE@CBB.DBL (ID, NOM, TOKEN) SELECT ID, NOM, 'OK' FROM LANGUE WHERE TOKEN IS NULL;

	--COPIE FILM_LANGUE
	INSERT INTO FILM_LANGUE@CBB.DBL (ID_FILM, ID_LANGUE) SELECT ID_FILM, ID_LANGUE FROM FILM_LANGUE INNER JOIN FILM ON ID = ID_FILM WHERE TOKEN IS NULL;

	--COPIE PAYS
	INSERT INTO PAYS@CBB.DBL (ID, NOM, TOKEN) SELECT ID, NOM, 'OK' FROM PAYS WHERE TOKEN IS NULL;

	--COPIE FILM_PAYS
	INSERT INTO FILM_PAYS@CBB.DBL (ID_FILM, ID_PAYS) SELECT ID_FILM, ID_PAYS FROM FILM_PAYS INNER JOIN FILM ON ID = ID_FILM WHERE TOKEN IS NULL;

	--COPIE PERSONNES
	INSERT INTO PERSONNE@CBB.DBL (ID, NOM, PHOTO, TOKEN) SELECT ID, NOM, PHOTO, 'OK' FROM PERSONNE WHERE TOKEN IS NULL;

	--COPIE REALISATEURS
	INSERT INTO EST_REALISATEUR@CBB.DBL (ID_FILM, ID_PERSONNE) SELECT ID_FILM, ID_PERSONNE FROM EST_REALISATEUR INNER JOIN FILM ON ID = ID_FILM 
	WHERE TOKEN IS NULL;

	--COPIE ROLE 
	INSERT INTO ROLE@CBB.DBL (ID, FILM_ASSOCIE, NOM) SELECT ROLE.ID, FILM_ASSOCIE, NOM FROM ROLE INNER JOIN FILM ON FILM.ID = ROLE.FILM_ASSOCIE
	WHERE TOKEN IS NULL;

	--COPIE PERSONNE_ROLE
	INSERT INTO PERSONNE_ROLE@CBB.DBL (ID_PERSONNE, ROLE_FILM, ROLE_ID) SELECT ID_PERSONNE, ROLE_FILM, ROLE_ID FROM PERSONNE_ROLE INNER JOIN FILM ON ID = ROLE_FILM
	WHERE TOKEN IS NULL;

	-- EVALUATIONS
	INSERT INTO EVALUATION@CBB.DBL (IDFILM, LOGIN, COTE, AVIS, DATEEVAL, TOKEN) SELECT IDFILM, LOGIN, COTE, AVIS, DATEEVAL, 'OK' FROM EVALUATION WHERE TOKEN = 'KO';
	

	--MISE A JOUR DES TOKEN
	UPDATE EVALUATION SET TOKEN = 'OK' WHERE TOKEN = 'KO';
	UPDATE FILM_COPIE SET TOKEN = 'OK' WHERE TOKEN = 'KO';
	UPDATE UTILISATEUR SET TOKEN = 'OK' WHERE TOKEN IS NULL;
	UPDATE FILM SET TOKEN = 'OK' WHERE TOKEN IS NULL;
	UPDATE GENRE SET TOKEN = 'OK' WHERE TOKEN IS NULL;
	UPDATE PRODUCTEUR SET TOKEN = 'OK' WHERE TOKEN IS NULL;
	UPDATE LANGUE SET TOKEN = 'OK' WHERE TOKEN IS NULL;
	UPDATE PAYS SET TOKEN = 'OK' WHERE TOKEN IS NULL;
	UPDATE PERSONNE SET TOKEN = 'OK' WHERE TOKEN IS NULL;

	COMMIT;

	LOGEVENT('CB : PROCEDURE BACKUP', 'Backup réussi');

EXCEPTION
	WHEN OTHERS THEN ROLLBACK; LOGEVENT('CB : PROCEDURE BACKUP', 'Backup raté'|| SQLCODE || ' : ' || SQLERRM);

END;
/

EXIT;
