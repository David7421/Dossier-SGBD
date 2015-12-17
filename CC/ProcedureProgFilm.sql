create or replace PROCEDURE PROGFILM
AS	
 	TYPE tabCol IS TABLE OF xmltype INDEX BY BINARY_INTEGER;
	tabProgra tabCol;	
  	
	cpt number;
	isValid number;

  	idFilm varchar2(20);
  	idCopie varchar2(20);
  	idSalle varchar2(20);

  	heureDebut interval day(0) to second(0);
  	minuteDebut interval day(0) to second(0);
  	nbrJours number;

  	dateDebut timestamp with time zone;
  	dateFin timestamp with time zone;

  	testHeureMinute number;

  	resultTest varchar2(2);

  	nomFichierFeedback varchar2(50) := 'feedback.xml';
  	xmlFeedBack xmltype := xmltype('<body><programmations></programmations></body>');

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

		DBMS_OUTPUT.PUT_LINE('test : '||isValid);
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

		--test de la copie du film
		IF(tabProgra(cpt).extract('progra/numCopy/text()') IS NULL) THEN

			LOGEVENT('PROGFILM','XML sans numCopy');
			--Pas de num copy: progra non valide
			select INSERTCHILDXML(tabProgra(cpt), 'progra', 'feedback', xmltype('<feedback>Vous devez indiquer une balise numCopy</feedback>'))
			INTO tabProgra(cpt) FROM DUAL;
			
			--Construction du XML feedback
			select INSERTCHILDXML(xmlFeedBack, 'body/programmations', 'progra', tabProgra(cpt)) INTO xmlFeedBack FROM DUAL;
			cpt := tabProgra.NEXT(cpt);
			CONTINUE;
		END IF;

		idCopie := tabProgra(cpt).extract('progra/numCopy/text()').getStringVal();

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

		--La copie existe-t-elle sur CC?
		BEGIN
			SELECT 'ok' INTO resultTest FROM COPIEFILM
			WHERE idFilm = extractvalue(object_value, 'copie/idFilm')
			AND idCopie = extractvalue(object_value, 'copie/numCopy');
		EXCEPTION
			WHEN NO_DATA_FOUND THEN resultTest := 'ko';
		END;

		IF(resultTest = 'ko') THEN

			LOGEVENT('PROGFILM','La copie choisie n existe pas dans CC');
			--La copie n'existe pas
			select INSERTCHILDXML(tabProgra(cpt), 'progra', 'feedback', xmltype('<feedback>La copie choisie pour la diffusion n''est pas en stock</feedback>'))
			INTO tabProgra(cpt) FROM DUAL;

			select INSERTCHILDXML(xmlFeedBack, 'body/programmations', 'progra', tabProgra(cpt)) INTO xmlFeedBack FROM DUAL;
			cpt := tabProgra.NEXT(cpt);
			CONTINUE;
		END IF;

		dateDebut := TRUNC(sysdate + 1) + heureDebut + minuteDebut;

    	nbrJours := FLOOR(dbms_random.normal * 3 + 8);

    	--Date de fin
    	dateFin := dateDebut + nbrJours;

    	--tester les programmations de ce jour

    	--inserer si ok
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
