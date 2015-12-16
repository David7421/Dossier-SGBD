-------------------
-- SPECIFICATION --
-------------------

CREATE OR REPLACE PACKAGE PACKAGERECHERCHE
IS
	TYPE tabChar IS TABLE OF varchar2(4000);

	FUNCTION recherche_id(p_id IN NUMBER) RETURN SYS_REFCURSOR;
	FUNCTION recherche(p_titre IN varchar2 default NULL, p_acteurs IN tabChar default NULL, p_real IN tabChar default NULL,
	 p_anneeSortie IN number default NULL, p_avant IN number default NULL, p_apres IN number default NULL) RETURN SYS_REFCURSOR;
	FUNCTION getAfficheFilm(p_id IN number) RETURN SYS_REFCURSOR;
	FUNCTION getNoteUtilisateurFilm(p_id IN number) RETURN SYS_REFCURSOR;
	FUNCTION getActeursFilm(p_id IN number) RETURN SYS_REFCURSOR;
	FUNCTION getRealisateursFilm(p_id IN number) RETURN SYS_REFCURSOR;
	FUNCTION getAvisFilm(p_id IN number, p_page IN number) RETURN SYS_REFCURSOR;
END;
/





----------
-- BODY --
----------

CREATE OR REPLACE PACKAGE BODY PACKAGERECHERCHE
IS
	
	/*
		paramètres :
		IN : ID du film recherché
		OUT : Curseur contenant le film trouvé
	*/
	FUNCTION recherche_id(p_id IN NUMBER) RETURN SYS_REFCURSOR
	AS
		result SYS_REFCURSOR;
	BEGIN
		OPEN result FOR SELECT * FROM FILM WHERE id=p_id;
		RETURN result;
	EXCEPTION
		WHEN OTHERS THEN LOGEVENT('Package recherche function recherche_id', SQLERRM);
	END;


	/*
		paramètres :
		IN : titre, liste d'acteur, liste realisateur, date de sortie recherche, data de sortie max, date de sortie min
		OUT : Curseur contenant les films trouvés

		PROCESS : Construction d'une requête sur base des informations fournies. Cette requête retournera tous les
		films répondant à tous les critères.
	*/
	FUNCTION recherche(p_titre IN varchar2, p_acteurs IN tabChar, p_real IN tabChar, p_anneeSortie IN number, p_avant IN number, 
		p_apres IN number) RETURN SYS_REFCURSOR
	AS
		result SYS_REFCURSOR;
		StringRequest varchar2(4000);
		v_index NUMBER;
	BEGIN

		--Si on précise un titre : 
		IF p_titre IS NOT NULL THEN
			StringRequest := 'SELECT * FROM film WHERE UPPER(film.Titre) LIKE ''' || p_titre || '%''';
		END IF;

		--TRAITEMENT DE LA REQUETE DES ACTEURS
		IF p_acteurs IS NOT NULL THEN
			IF StringRequest IS NOT NULL THEN
				--Si ce n'est pas le début de la requête
				StringRequest := StringRequest || ' INTERSECT ';
			END IF;

			StringRequest := StringRequest || 'SELECT * FROM film WHERE id IN (SELECT DISTINCT film.id FROM film INNER JOIN role ON film.id = role.film_associe
				 INNER JOIN personne_role ON role.film_associe = personne_role.role_film AND role.id = personne_role.role_id
				 INNER JOIN personne ON personne_role.id_personne = personne.id 
				 WHERE UPPER(personne.nom) IN ( ';
			v_index := p_acteurs.FIRST;
			StringRequest := StringRequest || '''' || p_acteurs(v_index) || '''';
			v_index := p_acteurs.NEXT(v_index);
			WHILE v_index IS NOT NULL
			LOOP
				StringRequest := StringRequest || ',''' || p_acteurs(v_index) || '''';
				v_index := p_acteurs.NEXT(v_index);
			END LOOP;
			StringRequest := StringRequest || ' ))';
		END IF;

		--Liste des realisateur
		IF p_real IS NOT NULL THEN
			IF StringRequest IS NOT NULL THEN
				--Si ce n'est pas le début de la requete
				StringRequest := StringRequest || ' INTERSECT ';
			END IF;

			StringRequest := StringRequest || 'SELECT * FROM film WHERE id IN (SELECT DISTINCT film.id FROM film
				 INNER JOIN est_realisateur ON film.id = est_realisateur.id_film
				 INNER JOIN personne ON personne.id = est_realisateur.id_personne
				 WHERE UPPER(personne.nom) IN ( ';
			--On boucle sur la liste des réalisateurs pour les ajouter à la clause IN
			v_index := p_real.FIRST;
			StringRequest := StringRequest || '''' || p_real(v_index) || '''';
			v_index := p_real.NEXT(v_index);
			WHILE v_index IS NOT NULL
			LOOP
				StringRequest := StringRequest || ',''' || p_real(v_index) || '''';
				v_index := p_real.NEXT(v_index);
			END LOOP;
			StringRequest := StringRequest || ' ))';
		END IF;

		--Si on précise une année de sorties
		IF p_anneeSortie IS NOT NULL THEN
			IF StringRequest IS NOT NULL THEN
				StringRequest := StringRequest || ' INTERSECT ';
			END IF;

			StringRequest := StringRequest || 'SELECT * FROM film WHERE EXTRACT(YEAR FROM date_sortie) = '|| p_anneeSortie || ' AND date_sortie IS NOT NULL';

		ELSE
			IF p_apres IS NOT NULL THEN --Si on a une date apres
				IF StringRequest IS NOT NULL THEN
					StringRequest := StringRequest || ' INTERSECT ';
				END IF;

				StringRequest := StringRequest || 'SELECT * FROM film WHERE EXTRACT(YEAR FROM date_sortie) > '|| p_apres || ' AND date_sortie IS NOT NULL';
			END IF;

			IF p_avant IS NOT NULL THEN --Si on a une date apres
				IF StringRequest IS NOT NULL THEN
					StringRequest := StringRequest || ' INTERSECT ';
				END IF;

				StringRequest := StringRequest || 'SELECT * FROM film WHERE EXTRACT(YEAR FROM date_sortie) < '|| p_avant || ' AND date_sortie IS NOT NULL';
			END IF;

		END IF;

		LOGEVENT('package recherche ', StringRequest);

		--retour du curseur de résultat
		OPEN result FOR StringRequest;
		RETURN result;

	EXCEPTION
		WHEN OTHERS THEN LOGEVENT('Package recherche function recherche', SQLERRM);
	END;


	/*
		paramètres :
		IN : ID du film dont on veut l'affiche
		OUT : Curseur contenant l'affiche trouvée

		PROCESS : Va chercher l'affiche correspondant au film 
	*/
	FUNCTION getAfficheFilm(p_id IN number) RETURN SYS_REFCURSOR
	AS
		result SYS_REFCURSOR;
	BEGIN
		OPEN result FOR SELECT image FROM FILM INNER JOIN AFFICHE ON film.affiche = affiche.id WHERE film.id=p_id;
		RETURN result;
	EXCEPTION
		WHEN OTHERS THEN LOGEVENT('Package recherche function getAfficheFilm', SQLERRM);
	END;


	/*
		paramètres :
		IN : ID du film dont on veut la moyenne des notes et le nombre de notes
		OUT : Curseur contenant la moyenne et le nombre de notes

		PROCESS : Calcul la moyenne et recupération du total de notes pour le film donné
	*/
	FUNCTION getNoteUtilisateurFilm(p_id IN number) RETURN SYS_REFCURSOR
	AS
		result SYS_REFCURSOR;
	BEGIN
		OPEN result FOR SELECT COUNT(cote), AVG(cote) FROM film INNER JOIN evaluation ON film.id = evaluation.idfilm WHERE id=p_id;
		RETURN result;
	EXCEPTION
		WHEN OTHERS THEN LOGEVENT('Package recherche function getNoteFilm', SQLERRM);
	END;


	/*
		paramètres :
		IN : ID du film 
		OUT : Curseur contenant la liste des acteurs jouant dans ce film

		PROCESS : Recupere les acteurs du film passé en paramètre
	*/
	FUNCTION getActeursFilm(p_id IN number) RETURN SYS_REFCURSOR
	AS
		result SYS_REFCURSOR;
	BEGIN
		OPEN result FOR SELECT personne.nom FROM film INNER JOIN role ON film.id = role.film_associe 
						INNER JOIN personne_role ON role.film_associe = personne_role.role_film AND role.id = personne_role.role_id
						INNER JOIN personne ON personne_role.id_personne = personne.id
						WHERE film.id=p_id;
		RETURN result;
	EXCEPTION
		WHEN OTHERS THEN LOGEVENT('Package recherche function getActeursFilm', SQLERRM);
	END;

	/*
		paramètres :
		IN : ID du film 
		OUT : Curseur contenant la liste des réalisateurs jouant dans ce film

		PROCESS : Recupere les réalisateurs du film passé en paramètre
	*/
	FUNCTION getRealisateursFilm(p_id IN number) RETURN SYS_REFCURSOR
	AS
		result SYS_REFCURSOR;
	BEGIN
		OPEN result FOR SELECT personne.nom FROM film INNER JOIN est_realisateur ON film.id = est_realisateur.id_film
						INNER JOIN personne ON personne.id = est_realisateur.id_personne
						WHERE film.id=p_id;
		RETURN result;
	EXCEPTION
		WHEN OTHERS THEN LOGEVENT('Package recherche function getRealisateursFilm', SQLERRM);
	END;


	/*
		paramètres :
		IN : ID du film, numero de page
		OUT : Curseur contenant la liste des avis pour ce film et cette page

		PROCESS : Recupere 5 commentaires correspondant au film. (5 commentaires étant le maximum pour une page)
	*/
	FUNCTION getAvisFilm(p_id IN number, p_page IN number) RETURN SYS_REFCURSOR
	AS
		result SYS_REFCURSOR;
		debut number;
		fin number;
	BEGIN
		debut := p_page*5 - 4;
		fin := debut + 5;
		OPEN result FOR SELECT login, avis FROM
							(SELECT login, avis, ROWNUM r FROM film INNER JOIN evaluation ON film.id = evaluation.idfilm WHERE film.id=p_id) 
						WHERE r >= debut AND r < fin;
		RETURN result;
	EXCEPTION
		WHEN OTHERS THEN LOGEVENT('Package recherche function getAvisFilm', SQLERRM);
	END;
END;
/

COMMIT;
