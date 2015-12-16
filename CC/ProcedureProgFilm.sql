create or replace PROCEDURE PROGFILM
AS	
 	TYPE tabCol IS TABLE OF xmltype INDEX BY BINARY_INTEGER;
	tabProgra tabCol;	
  	
	cpt number;
	isValid number;

  	tmp varchar2(20);
BEGIN

    WITH xmlt(value) AS(
      SELECT * FROM xmltable('programmations/progra' 
      passing xmltype(BFILENAME('MOVIEDIRECTORY', 'programmations/progra.xml'), nls_charset_id('AL32UTF8')))
    )
    SELECT * bulk collect into tabProgra FROM xmlt;
    
  
  	cpt := tabProgra.FIRST;
	WHILE cpt IS NOT NULL
	LOOP
		--isValid := tabProgra(cpt).isSchemaValid('http://cc/prograEntrante.xsd');

		SELECT XMLISVALID(tabProgra(cpt), 'http://cc/prograEntrante.xsd') INTO isValid
		FROM DUAL;

		DBMS_OUTPUT.PUT_LINE('test : '||isValid);

		

		
    	cpt := tabProgra.NEXT(cpt);
	END LOOP;

EXCEPTION
	WHEN OTHERS THEN LOGEVENT('procedure reception', 'ERREUR : ' ||SQLERRM); ROLLBACK;
END;
