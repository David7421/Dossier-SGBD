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


