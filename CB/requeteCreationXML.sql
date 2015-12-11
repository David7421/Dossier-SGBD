SELECT XMLElement(	"film", 
					XMLForest(	film.id AS "id_film", 
								film.titre AS "titre", 
								film.titre_original AS "titre_original",
								TO_CHAR(film.date_sortie, 'YYYY/MM/DD') AS "date_sortie",
								film.statut AS "status",
								film.note_moyenne AS "note_moyenne",
								film.nombre_note AS "nbr_note",
								film.runtime AS "runtime",
								film.certification AS "certification",
								(SELECT image FROM film INNER JOIN affiche ON id_poster = affiche.id where id = jdjkfsj) AS "affiche",
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
										WHERE film.id = 272947
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
										WHERE film.id = 272947
									)
								),

					XMLElement	("listPays", (SELECT XMLAgg( XMLElement("pays",
																		XMLForest(pays.id AS "id_pays", pays.nom AS "nom")))
										FROM film
										INNER JOIN film_pays ON film.id = film_pays.id_film
										INNER JOIN pays ON film_pays.id_pays = pays.id
										WHERE film.id = 272947
									)
								),

					XMLElement	("acteurs", (SELECT XMLAgg( XMLElement("acteur",
																	XMLForest(personne.id AS "id_acteur", personne.nom AS "nom", personne.photo AS "lien_photo", role.nom AS "nom_role")))
										FROM film
										INNER JOIN personne_role ON film.id = personne_role.role_film
										INNER JOIN personne ON personne_role.id_personne = personne.id
										INNER JOIN role ON role.id = personne_role.role_id AND role.film_associe = personne_role.role_film
										WHERE film.id = 272947
									)
								),

					XMLElement	("realisateurs", (SELECT XMLAgg( XMLElement("realisateur",
																	XMLForest(personne.id AS "id_realisateur", personne.nom AS "nom", personne.photo AS "lien_photo")))
										FROM film
										INNER JOIN est_realisateur ON film.id = est_realisateur.id_film
										INNER JOIN personne ON est_realisateur.id_personne = personne.id
										WHERE film.id = 272947
									)
								),

					XMLElement	("listAvis", (SELECT XMLAgg( XMLElement("avis",
																	XMLForest(evaluation.cote AS "note", evaluation.avis AS "commentaire")))
										FROM film
										INNER JOIN evaluation ON film.id = evaluation.idfilm
										WHERE film.id = 272947
									)
								)
				)
FROM film
WHERE id = 272947;