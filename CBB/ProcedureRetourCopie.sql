create or replace PROCEDURE RETOUR_COPIE
	AS
	BEGIN

		--On va d'abord renvoyer les copies qui ne sont plus utilisées.
    LOGEVENT('retour copie', 'debut du retour de copies');
		INSERT INTO FILM_COPIE(FILM_ID, NUM_COPIE, TOKEN) 
		SELECT EXTRACTVALUE(XML_COL , 'copie/idFilm'), EXTRACTVALUE(XML_COL , 'copie/numCopy'), NULL FROM tmpXMLCopy@CC.DBL;

		DELETE FROM tmpXMLCopy@CC.DBL;

		COMMIT;
    
    LOGEVENT('retour copie', 'retour commit');
	EXCEPTION
		WHEN OTHERS THEN LOGEVENT('procedure reception', 'ERREUR : ' ||SQLERRM); ROLLBACK;
	END;