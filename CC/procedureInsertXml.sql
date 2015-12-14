create or replace PROCEDURE RECEPTION_FILM
AS
BEGIN

	--On va d'abord renvoyer les copies qui ne sont plus utilisées.

	LOGEVENT('RECEPTION_FILM', 'debut de la reception');

	--On remplit la table des copies à retourner avec les copies qui ne sont plus programmées
	INSERT INTO tmpXMLCopy SELECT * FROM copieFilm;


	--On supprime les copies retournées de CC
	DELETE FROM COPIEFILM 
	WHERE EXTRACTVALUE(object_value , 'copie/idFilm') IN (SELECT EXTRACTVALUE(XML_COL , 'copie/idFilm') FROM tmpXMLCopy)
	AND EXTRACTVALUE(object_value , 'copie/numCopy') IN (SELECT EXTRACTVALUE(XML_COL , 'copie/numCopy') FROM tmpXMLCopy);

	--Insertion des copies mises en attente sur CB
	INSERT INTO FILMSCHEMA SELECT * FROM tmpXMLMovie@CB.DBL
  	WHERE EXTRACTVALUE(XML_COL , 'film/id_film') NOT IN (select extractvalue(object_value, 'film/id_film') FROM FILMSCHEMA);

	INSERT INTO COPIEFILM SELECT * FROM tmpXMLCopy@CB.DBL;

	DELETE FROM tmpXMLMovie@CB.DBL;
	DELETE FROM tmpXMLCopy@CB.DBL;

	COMMIT;

	--RETOUR_COPIE@CB.DBL;

	LOGEVENT('RECEPTION_FILM', 'Fin de la reception');
EXCEPTION
	WHEN OTHERS THEN LOGEVENT('procedure reception', 'ERREUR : ' ||SQLERRM); ROLLBACK;
END;

/*
SELECT extractvalue(object_value, 'copie/idFilm'), extractvalue(object_value, 'copie/numCopy') from COPIEFILM
WHERE extractvalue(object_value, 'copie/idFilm')=
          (SELECT extractvalue(object_value, 'programmation/idFilm')
          FROM PROGRAMMATION 
          WHERE current_timestamp < to_timestamp_tz(extractvalue(object_value, 'programmation/debut')));*/

