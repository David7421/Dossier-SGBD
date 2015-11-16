

-------------------
-- SPECIFICATION --
-------------------

CREATE OR REPLACE PACKAGE PACKAGERECHERCHE
IS
	FUNCTION recherche(p_id IN NUMBER) RETURN SYS_REFCURSOR;
END;
/


----------
-- BODY --
----------

CREATE OR REPLACE PACKAGE BODY PACKAGERECHERCHE
IS

	FUNCTION recherche(p_id IN NUMBER) RETURN SYS_REFCURSOR
	AS
		result SYS_REFCURSOR;
		--requete varchar2(4000);
	BEGIN
		--requete := 'SELECT id, Titre FROM FILM WHERE id='||p_id;
		OPEN result FOR SELECT id, Titre FROM FILM WHERE id=p_id;
		RETURN result;
	EXCEPTION
		WHEN OTHERS THEN RAISE; --TO DO LOG
	END;

END;
/

EXIT;
