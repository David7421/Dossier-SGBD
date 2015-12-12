create or replace PROCEDURE RECEPTION_FILM
AS
BEGIN

	--On va d'abord renvoyer les copies qui ne sont plus utilisées.

	INSERT INTO tmpXMLCopy SELECT * FROM copieFilm;

	INSERT INTO FILMSCHEMA SELECT * FROM tmpXMLMovie@CB.DBL
  	WHERE EXTRACTVALUE(XML_COL , 'film/if_film') NOT IN (select extractvalue(object_value, 'film/id_film') FROM FILMSCHEMA);

	INSERT INTO COPIEFILM SELECT * FROM tmpXMLCopy@CB.DBL;

	DELETE FROM tmpXMLMovie@CB.DBL;
	DELETE FROM tmpXMLCopy@CB.DBL;

	COMMIT;

	RETOUR_COPIE@CB.DBL;
	

EXCEPTION
	WHEN OTHERS THEN LOGEVENT('procedure reception', 'ERREUR : ' ||SQLERRM); ROLLBACK;
END;


 --MERGE INTO FILMSCHEMA
	--USING (SELECT * FROM tmpXMLMovie@CB.DBL) cbf
	--ON (FILMSCHEMA.EXTRACT(OBJECT_VALUE,'film/id_film/text()') = cbf.EXTRACT(OBJECT_VALUE,'film/id_film/text()'))
	--WHEN MATCHED THEN update SET object_value = updatexml(object_value, 'film/listAvis', cbf.EXTRACT(OBJECT_VALUE,'film/listAvis'))
  --WHEN NOT MATCHED THEN INSERT VALUES cbf;

