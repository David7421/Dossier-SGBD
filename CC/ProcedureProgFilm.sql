create or replace PROCEDURE PROGFILM
AS	
	programmation XMLTYPE;	

BEGIN

--with xmlt AS()
--	SELECT * FROM xmltable('programmations/progra' passing BFILE('MOVIEDIRECTORY', nls_charset_id('AL32UTF8')))
--	);

	select XMLTYPE(BFILENAME('MOVIEDIRECTORY', 'programmations/progra.xml'), nls_charset_id('AL32UTF8')) INTO programmation
	FROM DUAL;

EXCEPTION
	WHEN OTHERS THEN LOGEVENT('procedure reception', 'ERREUR : ' ||SQLERRM); ROLLBACK;
END;