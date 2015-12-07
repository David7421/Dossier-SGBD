SELECT XMLElement(	'film', 
					XMLForest(f.id AS 'id_film'), 
					XMLForest(f.titre AS 'titre'), 
					XMLForest(f.titre AS 'titre_originale'))
FROM film f
WHERE film.id = 272947;


