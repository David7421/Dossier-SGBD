create or replace PROCEDURE ARCHPROG
AS
	TYPE tabNumber IS TABLE OF number INDEX BY BINARY_INTEGER;
	tabId tabNumber;

	cpt number;

	per number;
	nbrP number;
	nbrCopie number;

	archive xmltype;
BEGIN
	
	LOGEVENT('ARCHPROG', 'debut de l''archivage');

	--Recuperation des films qui ont été programmé
	SELECT DISTINCT extractvalue(object_value, 'programmation/idFilm') bulk collect into tabId
	FROM programmation
	WHERE to_timestamp_tz(extractvalue(object_value, 'programmation/debut')) < current_timestamp;

	--Pour chaque film
	FOR cpt IN tabId.FIRST..tabId.LAST LOOP

		--On prend le nombre de places vendues
		SELECT SUM(extractvalue(object_value, 'programmation/nbrSpectateurs')) INTO nbrP
		FROM programmation
		WHERE extractvalue(object_value, 'programmation/idFilm') = tabId(cpt);

		--Nombre de jour à l'affiche
		SELECT COUNT(*) INTO per
		FROM (	SELECT DISTINCT to_char(to_timestamp_tz(extractvalue(object_value, 'programmation/debut')), 'DD-MM-YYYY')
				FROM programmation WHERE extractvalue(object_value, 'programmation/idFilm') = tabId(cpt)
			 );

		--Nombre de copies ayant ete utilisees
		SELECT COUNT(*) INTO nbrCopie
		FROM (	SELECT DISTINCT extractvalue(object_value, 'programmation/numCopy')
				FROM programmation WHERE extractvalue(object_value, 'programmation/idFilm') = tabId(cpt)
			 );

		SELECT XMLElement(	"archivage", 
								XMLForest(	tabId(cpt) AS "idFilm", 
											per AS "perennite", 
											nbrP AS "nbrPlaces",
											nbrCopie AS "nbrCopies"
										 )
						 )
		INTO archive
		FROM dual;

		BEGIN
			INSERT INTO archives VALUES(archive);
		EXCEPTION
			WHEN OTHERS THEN 
				UPDATE archives set object_value = archive
				WHERE extractvalue(object_value, 'programmation/idFilm') = tabId(cpt);
		END;

	END LOOP;

	LOGEVENT('ARCHPROG', 'fin de l''archivage');

	COMMIT;
	
EXCEPTION
	WHEN OTHERS THEN LOGEVENT('ARCHPROG', 'ERREUR : ' ||SQLERRM); ROLLBACK;
END;
/

COMMIT;
