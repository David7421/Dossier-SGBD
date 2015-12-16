-------------------
-- SPECIFICATION --
-------------------

CREATE OR REPLACE PACKAGE ALIMCC
IS
	--Procedure qui permet de générer le XML pour les films et copies de film.
	--Paramètre : id du film à envoyer.
	PROCEDURE MOVIE_COPY_GENERATOR(v_film_id IN NUMBER);

	--Procedure parcourant tous les films contenus dans CB pour envoyer des copies à CC
	PROCEDURE JOB;
END;
/





----------
-- BODY --
----------

CREATE OR REPLACE PACKAGE BODY ALIMCC
IS
	--Paramètre : Id du film à envoyer
	PROCEDURE MOVIE_COPY_GENERATOR(v_film_id IN NUMBER)
	AS
		nbrCopieDispo NUMBER;
		nbrCopieTransfert NUMBER;
		documentXML XMLTYPE;


		TYPE tabCopy IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
		copy tabCopy;

		parc NUMBER;

	BEGIN
		--Génération du nombre de copie à envoyer sur base du nombre de copies présentes sur CB
		SELECT COUNT(*) INTO nbrCopieDispo FROM FILM_COPIE WHERE FILM_ID = v_film_id;

		nbrCopieTransfert := FLOOR(dbms_random.value(0, nbrCopieDispo/2));


		IF nbrCopieTransfert > 0 THEN
			--Generation des infos du film en XML
			SELECT XMLElement(	"film", 
								XMLForest(	film.id AS "id_film", 
											film.titre AS "titre", 
											film.titre_original AS "titre_original",
											TO_CHAR(film.date_sortie, 'YYYY/MM/DD') AS "date_sortie",
											film.statut AS "status",
											to_char(film.note_moyenne,'000.000') AS "note_moyenne",
											film.nombre_note AS "nbr_note",
											film.runtime AS "runtime",
											film.certification AS "certification",
											(SELECT image FROM film INNER JOIN affiche ON film.AFFICHE = affiche.id where film.id = v_film_id) AS "affiche",
											film.budget AS "budget",
											film.revenu AS "revenus",
											film.homepage AS "homepage",
											film.tagline AS "tagline",
											film.overview AS "overview"),
								XMLElement	("genres", (SELECT XMLAgg( XMLElement(	"genre",
																					XMLForest(genre.id AS "id_genre", genre.nom AS "nom")))
													FROM film
													INNER JOIN film_genre ON film.id = film_genre.id_film
													INNER JOIN genre ON film_genre.id_genre = genre.id
													WHERE film.id = v_film_id
												)
											),
								XMLElement	("producteurs", (SELECT XMLAgg( XMLElement("producteur",
																						XMLForest(producteur.id AS "id_producteur", producteur.nom AS "nom")))
													FROM film
													INNER JOIN film_producteur ON film.id = film_producteur.id_film
													INNER JOIN producteur ON film_producteur.id_producteur = producteur.id
													WHERE film.id = 272947
												)
											),

								XMLElement	("langues", (SELECT XMLAgg( XMLElement("langue",
																					XMLForest(langue.id AS "id_langue", langue.nom AS "nom")))
													FROM film
													INNER JOIN film_langue ON film.id = film_langue.id_film
													INNER JOIN langue ON film_langue.id_langue = langue.id
													WHERE film.id = v_film_id
												)
											),

								XMLElement	("listPays", (SELECT XMLAgg( XMLElement("pays",
																					XMLForest(pays.id AS "id_pays", pays.nom AS "nom")))
													FROM film
													INNER JOIN film_pays ON film.id = film_pays.id_film
													INNER JOIN pays ON film_pays.id_pays = pays.id
													WHERE film.id = v_film_id
												)
											),

								XMLElement	("acteurs", (SELECT XMLAgg( XMLElement("acteur",
																				XMLForest(personne.id AS "id_acteur", personne.nom AS "nom", personne.photo AS "lien_photo", role.nom AS "nom_role")))
													FROM film
													INNER JOIN personne_role ON film.id = personne_role.role_film
													INNER JOIN personne ON personne_role.id_personne = personne.id
													INNER JOIN role ON role.id = personne_role.role_id AND role.film_associe = personne_role.role_film
													WHERE film.id = v_film_id
												)
											),

								XMLElement	("realisateurs", (SELECT XMLAgg( XMLElement("realisateur",
																				XMLForest(personne.id AS "id_realisateur", personne.nom AS "nom", personne.photo AS "lien_photo")))
													FROM film
													INNER JOIN est_realisateur ON film.id = est_realisateur.id_film
													INNER JOIN personne ON est_realisateur.id_personne = personne.id
													WHERE film.id = v_film_id
												)
											),

								XMLElement	("listAvis", (SELECT XMLAgg( XMLElement("avis",
																				XMLForest(evaluation.cote AS "note", evaluation.avis AS "commentaire")))
													FROM film
													INNER JOIN evaluation ON film.id = evaluation.idfilm
													WHERE film.id = v_film_id
												)
											)
							)
			INTO documentXML
			FROM film
			WHERE id = v_film_id;

			--Insertion du XML généré dans la table de communication avec CC
			INSERT INTO tmpXMLMovie
			VALUES(documentXML);

			--generation des copies de film à envoyer sur CC
			LOGEVENT('ALIMCC', 'AJOUT DE ' || nbrCopieTransfert ||' COPIES DU FILM ' || v_film_id);

			SELECT NUM_COPIE BULK COLLECT INTO copy
			FROM (SELECT NUM_COPIE, ROWNUM FROM FILM_COPIE WHERE FILM_ID = v_film_id)
			WHERE ROWNUM <= nbrCopieTransfert;

			FOR parc IN copy.FIRST..copy.LAST LOOP
			
				SELECT XMLElement("copie", XMLForest(	v_film_id AS "idFilm", 
														copy(parc) AS "numCopy"))
				INTO documentXML
				FROM DUAL;

				INSERT INTO tmpXMLCopy VALUES(documentXML); --Insertion de la copie sélectionnée dans la table de communicaiton avec CC
				DELETE FROM FILM_COPIE WHERE FILM_ID = v_film_id AND NUM_COPIE = copy(parc);--Suppression sur CB de la copie envoyée

			END LOOP;

		END IF;

	EXCEPTION
		WHEN OTHERS THEN LOGEVENT('procedure alimCC', 'ERREUR : ' ||SQLERRM); ROLLBACK;
	END;



	PROCEDURE JOB
	AS
		f FILM%ROWTYPE;
	BEGIN
		--Boucle sur tous les films présents dans CB
		FOR f IN (SELECT * FROM FILM) LOOP

			ALIMCC.MOVIE_COPY_GENERATOR(f.id);

		END LOOP;

		COMMIT;

		RECEPTION_FILM@CC.DBL; --Demande à CC de lire la table remplie lors de MOVIE_COPY_GENERATOR

	EXCEPTION
		WHEN OTHERS THEN LOGEVENT('procedure alimCC JOB', 'ERREUR : ' ||SQLERRM); ROLLBACK;
	END;

END;
/

COMMIT;

