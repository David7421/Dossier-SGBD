SELECT XMLElement(	"film", 
					XMLForest(film.id AS "id_film"), 
					XMLForest(film.titre AS "titre"), 
					XMLForest(film.titre_original AS "titre_originale"),
					XMLForest(film.date_sortie AS "date_sortie"),
					XMLForest(film.statut AS "status"),
					XMLForest(film.note_moyenne AS "note_moyenne"),
					XMLForest(film.nombre_note AS "nbr_note"),
					XMLForest(film.runtime AS "runtime"),
					XMLForest(film.certification AS "certification"),
					--XMLForest(film.affiche),
					XMLForest(film.budget AS "budget"),
					XMLForest(film.revenu AS "revenus"),
					XMLForest(film.homepage AS "homepage"),
					XMLForest(film.tagline AS "tagline"),
					XMLForest(film.overview AS "overview")
					--XMLForest(numCopy)
				)
FROM film
WHERE id = 272947;




