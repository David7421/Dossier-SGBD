create or replace PROCEDURE PROGFILM
AS	
 	TYPE tabCol IS TABLE OF xmltype INDEX BY BINARY_INTEGER;
	tabProgra tabCol;	

	TYPE tabNumber IS TABLE OF number INDEX BY BINARY_INTEGER;
	tabCopie tabNumber;

	isValid number;

  	idFilm varchar2(20);
  	idCopie varchar2(20);
  	idSalle varchar2(20);

  	heureDebut interval day(0) to second(0);
  	minuteDebut interval day(0) to second(0);

  	dureeProjection interval day(0) to second(0);
  	nbrJours number;

  	dateDebut timestamp with time zone;
  	dateFin timestamp with time zone;

  	testHeureMinute number;
  	runtime number;

  	resultTest varchar2(2);

  	nomFichierFeedback varchar2(50) := 'feedback.xml';
  	xmlFeedBack xmltype := xmltype('<body><programmations></programmations></body>');

  	cpt number;
  	cptCopie number;
  	cpt2 number;

  	tmpXML xmltype;

  	--Interval entre deux films pour ranger la salle etc
  	intervalFilm interval day(0) to second(0) := interval '30' minute;

BEGIN

    WITH xmlt(value) AS(
      SELECT * FROM xmltable('programmations/progra' 
      passing xmltype(BFILENAME('MOVIEDIRECTORY', 'programmations/progra.xml'), nls_charset_id('AL32UTF8')))
    )
    SELECT * bulk collect into tabProgra FROM xmlt;

    LOGEVENT('PROGFILM', 'Debut');
    
  	cpt := tabProgra.FIRST;
	WHILE cpt IS NOT NULL
	LOOP
		SELECT XMLISVALID(tabProgra(cpt), 'http://cc/prograEntrante.xsd') INTO isValid
		FROM DUAL;

		--Si le tag idFilm existe
		IF(tabProgra(cpt).extract('progra/idFilm/text()') IS NULL) THEN

			LOGEVENT('PROGFILM','XML sans idFilm');
			--Pas d'ID film : progra non valide
			select INSERTCHILDXML(tabProgra(cpt), 'progra', 'feedback', xmltype('<feedback>Vous devez indiquer une balise idFilm</feedback>'))
			INTO tabProgra(cpt) FROM DUAL;

			--On construit le xml feedback
			select INSERTCHILDXML(xmlFeedBack, 'body/programmations', 'progra', tabProgra(cpt)) INTO xmlFeedBack FROM DUAL;
			cpt := tabProgra.NEXT(cpt);
			CONTINUE;
		END IF;

		idFilm := tabProgra(cpt).extract('progra/idFilm/text()').getStringVal();

		--récupération du numero de salle

		IF(tabProgra(cpt).extract('progra/numSalle/text()') IS NULL) THEN

			LOGEVENT('PROGFILM','XML sans numSalle');
			--Pas de num salle: progra non valide
			select INSERTCHILDXML(tabProgra(cpt), 'progra', 'feedback', xmltype('<feedback>Vous devez indiquer une balise numSalle</feedback>'))
			INTO tabProgra(cpt) FROM DUAL;

			--Construction du XML feedback
			select INSERTCHILDXML(xmlFeedBack, 'body/programmations', 'progra', tabProgra(cpt)) INTO xmlFeedBack FROM DUAL;
			cpt := tabProgra.NEXT(cpt);
			CONTINUE;
		END IF;

		idSalle := tabProgra(cpt).extract('progra/numSalle/text()').getStringVal();


		--Heure de debut de sceance mentionné

		IF(tabProgra(cpt).extract('progra/heureDebut/text()') IS NULL) THEN
			
			LOGEVENT('PROGFILM','XML sans heureDebut');
			--Pas de num salle: progra non valide
			select INSERTCHILDXML(tabProgra(cpt), 'progra', 'feedback', xmltype('<feedback>Vous devez indiquer une balise heureDebut</feedback>'))
			INTO tabProgra(cpt) FROM DUAL;

			--construction XML 
			select INSERTCHILDXML(xmlFeedBack, 'body/programmations', 'progra', tabProgra(cpt)) INTO xmlFeedBack FROM DUAL;
			cpt := tabProgra.NEXT(cpt);
			CONTINUE;
		END IF;

		--Minute debut de sceance
		IF(tabProgra(cpt).extract('progra/minuteDebut/text()') IS NULL) THEN
			
			LOGEVENT('PROGFILM','XML sans minuteDebut');
			--Pas de num salle: progra non valide
			select INSERTCHILDXML(tabProgra(cpt), 'progra', 'feedback', xmltype('<feedback>Vous devez indiquer une balise minuteDebut</feedback>'))
			INTO tabProgra(cpt) FROM DUAL;

			--construction XML 
			select INSERTCHILDXML(xmlFeedBack, 'body/programmations', 'progra', tabProgra(cpt)) INTO xmlFeedBack FROM DUAL;
			cpt := tabProgra.NEXT(cpt);
			CONTINUE;
		END IF;

		testHeureMinute := TO_NUMBER(tabProgra(cpt).extract('progra/heureDebut/text()').getStringVal());

		IF(testHeureMinute > 23 OR testHeureMinute < 0) THEN
			LOGEVENT('PROGFILM','Heure de debut invalide');
			--Pas de num salle: progra non valide
			select INSERTCHILDXML(tabProgra(cpt), 'progra', 'feedback', xmltype('<feedback>l''heure de debut doit etre comprise entre 0 et 23 h</feedback>'))
			INTO tabProgra(cpt) FROM DUAL;

			--construction XML 
			select INSERTCHILDXML(xmlFeedBack, 'body/programmations', 'progra', tabProgra(cpt)) INTO xmlFeedBack FROM DUAL;
			cpt := tabProgra.NEXT(cpt);
			CONTINUE;
		END IF;

		heureDebut := numtodsinterval(testHeureMinute, 'hour');

		testHeureMinute := TO_NUMBER(tabProgra(cpt).extract('progra/minuteDebut/text()').getStringVal());

		IF(testHeureMinute > 59 OR testHeureMinute < 0) THEN
			LOGEVENT('PROGFILM','Minute de debut invalide');
			--Pas de num salle: progra non valide
			select INSERTCHILDXML(tabProgra(cpt), 'progra', 'feedback', xmltype('<feedback>les minutes de debut doivent etre comprises entre 0 et 59</feedback>'))
			INTO tabProgra(cpt) FROM DUAL;

			--construction XML 
			select INSERTCHILDXML(xmlFeedBack, 'body/programmations', 'progra', tabProgra(cpt)) INTO xmlFeedBack FROM DUAL;
			cpt := tabProgra.NEXT(cpt);
			CONTINUE;
		END IF;

		minuteDebut := numtodsinterval(testHeureMinute, 'minute');

		dateDebut := TRUNC(sysdate + 1) + heureDebut + minuteDebut;

    	nbrJours := FLOOR(dbms_random.normal * 3 + 8);

    	-- Duree de la projection

    	SELECT extractvalue(object_value, 'film/runtime') INTO runtime
    	FROM FILMSCHEMA
    	WHERE extractvalue(object_value, 'film/id_film') = idFilm;

    	dureeProjection := numtodsinterval(runtime, 'minute') + intervalFilm;

    	--Date et heure de fin
    	dateFin := dateDebut + nbrJours + dureeProjection;

    	--La salle est libre à cette heure la pour le film
    	cpt2 := 0;
    	WHILE cpt2 < nbrJours LOOP

    		BEGIN
    			SELECT 'ko' INTO resultTest
    			FROM programmation
    			WHERE extractvalue(object_value, 'programmation/salle') = idSalle
    			AND to_timestamp_tz(extractvalue(object_value, 'programmation/debut'), 'DD/MM/RR HH24:MI:SS') >= dateDebut + cpt2
    			AND to_timestamp_tz(extractvalue(object_value, 'programmation/debut'), 'DD/MM/RR HH24:MI:SS') <= (dateDebut + dureeProjection +cpt2);
    		EXCEPTION
    			WHEN NO_DATA_FOUND THEN resultTest := 'ok';
    		END;

    		IF resultTest =  'ko' THEN
    			EXIT;
    		END IF ;

    		cpt2 := cpt2+1;
    	END LOOP;
    	--On test pour voir si on est sortis de la boucle à cause du break:

    	IF resultTest =  'ko' THEN
    		LOGEVENT('PROGFILM','La salle n''est pas libre');
			--Pas de num salle: progra non valide
			select INSERTCHILDXML(tabProgra(cpt), 'progra', 'feedback', xmltype('<feedback>La salle '||idSalle||' n''est pas libre</feedback>'))
			INTO tabProgra(cpt) FROM DUAL;

			--construction XML 
			select INSERTCHILDXML(xmlFeedBack, 'body/programmations', 'progra', tabProgra(cpt)) INTO xmlFeedBack FROM DUAL;
			cpt := tabProgra.NEXT(cpt);
			CONTINUE;
    	END IF ;

    	--La salle est libre. Quelle copie du film l'est aussi ?
    	resultTest := 'ko';
    	--recuperation des ID copie
    	SELECT extractvalue(object_value, 'copie/numCopy') BULK COLLECT INTO tabCopie
    	FROM COPIEFILM  
    	WHERE extractvalue(object_value, 'copie/idFilm') = idFilm;

      	cptCopie := tabCopie.FIRST;
    	WHILE cptCopie <= tabCopie.LAST
    	LOOP
    		cpt2 := 0;

    		WHILE cpt2 < nbrJours LOOP

	    		BEGIN
	    			SELECT 'ko' INTO resultTest
	    			FROM programmation
	    			WHERE extractvalue(object_value, 'programmation/numCopy') = tabCopie(cptCopie)
	    			AND to_timestamp_tz(extractvalue(object_value, 'programmation/debut'), 'DD/MM/RR HH24:MI:SS') >= dateDebut + cpt2
	    			AND to_timestamp_tz(extractvalue(object_value, 'programmation/debut'), 'DD/MM/RR HH24:MI:SS') <= (dateDebut + dureeProjection +cpt2);
	    		EXCEPTION
	    			WHEN NO_DATA_FOUND THEN resultTest := 'ok';
	    		END;

	    		IF resultTest =  'ko' THEN
    				EXIT;
    			END IF ;

    			cpt2 := cpt2 + 1;

	    	END LOOP;

	    	IF resultTest = 'ok' THEN
	    		idCopie := tabCopie(cptCopie);
	    		EXIT;
	    	END IF;
        cptCopie := cptCopie + 1;
    	END LOOP;

    	IF resultTest =  'ko' THEN
    		LOGEVENT('PROGFILM','Toutes les copies sont deja utilisees');
			--Pas de num salle: progra non valide
			select INSERTCHILDXML(tabProgra(cpt), 'progra', 'feedback', xmltype('<feedback>Aucune copie disponible pour la projection</feedback>'))
			INTO tabProgra(cpt) FROM DUAL;

			--construction XML 
			select INSERTCHILDXML(xmlFeedBack, 'body/programmations', 'progra', tabProgra(cpt)) INTO xmlFeedBack FROM DUAL;
			cpt := tabProgra.NEXT(cpt);
			CONTINUE;
    	END IF ;

    	--On est ici alors c'est ok on va pouvoir générer et insérer les programmations

    	cpt2 := 0;

    	WHILE cpt2 < nbrJours LOOP

    		cptCopie := FLOOR(dbms_random.normal * 2 + 100);

    		SELECT XMLElement(	"programmation", 
						XMLForest(	idFilm AS "idFilm", 
									idCopie AS "numCopy", 
									to_char(dateDebut + cpt2, 'DD/MM/RR HH24:MI:SS') AS "debut",
									to_char(dateDebut + cpt2 + dureeProjection, 'DD/MM/RR HH24:MI:SS') AS "fin",
									idSalle AS "salle",
									cptCopie AS "nbrSpectateurs",
									200 AS "nbrPlaces"
								)
						 )
 			INTO tmpXML
 			FROM DUAL;

 			insert into programmation values(tmpXML);

    		cpt2 := cpt2 + 1;

    	END LOOP;

    	COMMIT;

    	select INSERTCHILDXML(tabProgra(cpt), 'progra', 'feedback', xmltype('<feedback>Insertion reussie</feedback>'))
			INTO tabProgra(cpt) FROM DUAL;

    	select INSERTCHILDXML(xmlFeedBack, 'body/programmations', 'progra', tabProgra(cpt)) INTO xmlFeedBack FROM DUAL;
		cpt := tabProgra.NEXT(cpt);
	END LOOP;


	--Ecriture dans le fichier feedback
	LOGEVENT('PROGFILM', 'avant ajout du CSS');

	--SELECT INSERTXMLBEFORE(xmlFeedBack, 'body/programmations', xmltype('<?xml-stylesheet type="text/css" href="style.css"?>'))
	--INTO xmlFeedBack FROM DUAL;

	LOGEVENT('PROGFILM', 'avant enregistrement du feedback');

	DBMS_XSLPROCESSOR.CLOB2FILE(xmlFeedBack.getClobVal(), 'MOVIEDIRECTORY', nomFichierFeedback, nls_charset_id('AL32UTF8'));


EXCEPTION
	WHEN OTHERS THEN LOGEVENT('procedure reception', 'ERREUR : ' ||SQLERRM); ROLLBACK;
END;