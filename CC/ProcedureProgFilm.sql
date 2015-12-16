create or replace PROCEDURE PROGFILM
AS	
 	TYPE tabCol IS TABLE OF xmltype INDEX BY BINARY_INTEGER;
	tabProgra tabCol;	
  	
	cpt number;
	isValid number;

  	XmlValueBuffer varchar2(20);
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

		IF(tabProgra(cpt).extract('progra/idFilm/text()') IS NULL) THEN
			DBMS_OUTPUT.PUT_LINE('NULL');
			--Pas d'ID film : progra non valide
			--TO DO FEEDBACK
			cpt := tabProgra.NEXT(cpt);
			CONTINUE;
		END IF;

		XmlValuebuffer := tabProgra(cpt).extract('progra/idFilm/text()').getStringVal();

		--Test de la valeur de retour
		BEGIN
			SELECT 'ok' INTO resultTest FROM FILMSCHEMA
			WHERE XmlValuebuffer = extractvalue(object_value, 'film/id_film');
		EXCEPTION
			WHEN NO_DATA_FOUND THEN resultTest := 'ko';
		END;

		

		DBMS_OUTPUT.PUT_LINE(resultTest);

    	cpt := tabProgra.NEXT(cpt);
	END LOOP;

EXCEPTION
	WHEN OTHERS THEN LOGEVENT('procedure reception', 'ERREUR : ' ||SQLERRM); ROLLBACK;
END;
