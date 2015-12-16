create or replace PROCEDURE PROGFILM
AS	
 	TYPE tabCol IS TABLE OF xmltype INDEX BY BINARY_INTEGER;
	tabProgra tabCol;	
  	
	cpt number;
	isValid number;

  	idFilm varchar2(20);
  	idCopie varchar2(20);
  	idSalle varchar2(20);
  	heure varchar2(20);

  	resultTest varchar2(2);

BEGIN

    WITH xmlt(value) AS(
      SELECT * FROM xmltable('programmations/progra' 
      passing xmltype(BFILENAME('MOVIEDIRECTORY', 'programmations/progra.xml'), nls_charset_id('AL32UTF8')))
    )
    SELECT * bulk collect into tabProgra FROM xmlt;
    
  
  	cpt := tabProgra.FIRST;
	WHILE cpt IS NOT NULL
	LOOP
		SELECT XMLISVALID(tabProgra(cpt), 'http://cc/prograEntrante.xsd') INTO isValid
		FROM DUAL;

		DBMS_OUTPUT.PUT_LINE('test : '||isValid);
		--Si le tag idFilm existe
		IF(tabProgra(cpt).extract('progra/idFilm/text()') IS NULL) THEN
			DBMS_OUTPUT.PUT_LINE('NULL');
			--Pas d'ID film : progra non valide
			--TO DO FEEDBACK
			cpt := tabProgra.NEXT(cpt);
			CONTINUE;
		END IF;

		idFilm := tabProgra(cpt).extract('progra/idFilm/text()').getStringVal();

		--test de la copie du film
		IF(tabProgra(cpt).extract('progra/numCopy/text()') IS NULL) THEN
			DBMS_OUTPUT.PUT_LINE('numcopynull');
			--Pas d'ID film : progra non valide
			--TO DO FEEDBACK
			cpt := tabProgra.NEXT(cpt);
			CONTINUE;
		END IF;

		idCopie := tabProgra(cpt).extract('progra/numCopy/text()').getStringVal();

		--récupération du numero de salle

		IF(tabProgra(cpt).extract('progra/numSalle/text()') IS NULL) THEN
			DBMS_OUTPUT.PUT_LINE('numcopynull');
			--Pas d'ID film : progra non valide
			--TO DO FEEDBACK
			cpt := tabProgra.NEXT(cpt);
			CONTINUE;
		END IF;

		idSalle := tabProgra(cpt).extract('progra/numSalle/text()').getStringVal();


		--récupération de la date et de l'heure du debut de sceance

		IF(tabProgra(cpt).extract('progra/heureDebut/text()') IS NULL) THEN
			DBMS_OUTPUT.PUT_LINE('numcopynull');
			--Pas d'ID film : progra non valide
			--TO DO FEEDBACK
			cpt := tabProgra.NEXT(cpt);
			CONTINUE;
		END IF;

		heure := tabProgra(cpt).extract('progra/heureDebut/text()').getStringVal();


		--La copie existe-t-elle sur CC?
		BEGIN
			SELECT 'ok' INTO resultTest FROM COPIEFILM
			WHERE idFilm = extractvalue(object_value, 'copie/idFilm')
			AND idCopie = extractvalue(object_value, 'copie/numCopy');
		EXCEPTION
			WHEN NO_DATA_FOUND THEN resultTest := 'ko';
		END;

		IF(resultTest = 'ko') THEN
			DBMS_OUTPUT.PUT_LINE('copie de film pas sur CC invalide');
			--Pas d'ID film : progra non valide
			--TO DO FEEDBACK
			cpt := tabProgra.NEXT(cpt);
			CONTINUE;
		END IF;
		

    	cpt := tabProgra.NEXT(cpt);
	END LOOP;

EXCEPTION
	WHEN OTHERS THEN LOGEVENT('procedure reception', 'ERREUR : ' ||SQLERRM); ROLLBACK;
END;
