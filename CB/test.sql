BEGIN
  alimcb(55);
EXCEPTION
  WHEN OTHERS THEN DBMS_OUTPUT.PUT_LINE(SQLERRM);
END;


BEGIN
  PACKAGERECHERCHE.recherche(p_titre=>'Nu');
EXCEPTION
  WHEN OTHERS THEN DBMS_OUTPUT.PUT_LINE(SQLERRM);
END;


SELECT id, titre FROM FILM INNER JOIN 


insert into AFFICHE(image) values (httpuritype ('http://image.tmdb.org/t/p/w185/uU9R1byS3USozpzWJ5oz7YAkXyk.jpg').getblob ());


//getDBUSERCursor is a stored procedure
String getDBUSERCursorSql = "{call getDBUSERCursor(?,?)}";
callableStatement = dbConnection.prepareCall(getDBUSERCursorSql);
callableStatement.setString(1, "mkyong");
callableStatement.registerOutParameter(2, OracleTypes.CURSOR);

// execute getDBUSERCursor store procedure
callableStatement.executeUpdate();

// get cursor and cast it to ResultSet
rs = (ResultSet) callableStatement.getObject(2);

// loop it like normal
while (rs.next()) {
	String userid = rs.getString("USER_ID");
	String userName = rs.getString("USERNAME");
}			

SELECT film.id, film.titre, personne.nom FROM film 
INNER JOIN role ON film.id = role.film_associe
INNER JOIN personne_role ON role.film_associe = personne_role.role_film AND role.id = personne_role.role_id
INNER JOIN est_realisateur ON film.id = est_realisateur.id_film
INNER JOIN personne ON personne_role.id_personne = personne.id OR personne.id = est_realisateur.id_personne;


"SELECT id, Titre FROM film WHERE UPPER(film.Titre) LIKE 'E%' 
	INTERSECT 
	SELECT id, Titre FROM film WHERE id IN (SELECT DISTINCT film.id FROM film INNER JOIN role ON film.id = role.film_associe
				 INNER JOIN personne_role ON role.film_associe = personne_role.role_film AND role.id = personne_role.role_id
				 INNER JOIN personne ON personne_role.id_personne = personne.id 
				 WHERE UPPER(personne.nom) IN ( 'PETER CUSHING' ))"