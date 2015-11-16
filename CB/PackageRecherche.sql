

-------------------
-- SPECIFICATION --
-------------------

CREATE OR REPLACE PACKAGE PACKAGERECHERCHE
IS
	TYPE tabChar IS TABLE OF varchar2(4000);

	FUNCTION recherche_id(p_id IN NUMBER) RETURN SYS_REFCURSOR;
	FUNCTION recherche(p_titre IN varchar2 default NULL, p_acteurs IN tabChar default NULL, p_real IN tabChar default NULL,
	 p_anneeSortie IN number default NULL, p_avant IN number default NULL, p_apres IN number default NULL) RETURN SYS_REFCURSOR;
END;
/


----------
-- BODY --
----------

CREATE OR REPLACE PACKAGE BODY PACKAGERECHERCHE
IS

	FUNCTION recherche_id(p_id IN NUMBER) RETURN SYS_REFCURSOR
	AS
		result SYS_REFCURSOR;
	BEGIN
		OPEN result FOR SELECT id, Titre FROM FILM WHERE id=p_id;
		RETURN result;
	EXCEPTION
		WHEN OTHERS THEN RAISE; --TO DO LOG
	END;

	FUNCTION recherche(p_titre IN varchar2, p_acteurs IN tabChar, p_real IN tabChar, p_anneeSortie IN number, p_avant IN number, 
		p_apres IN number) RETURN SYS_REFCURSOR
	AS
		result SYS_REFCURSOR;
		StringSelect varchar2(4000);
		StringFrom varchar2(4000);
		StringWhere varchar2(4000);
	BEGIN
		StringSelect := 'SELECT id, Titre ';
		StringFrom := 'FROM FILM ';
		StringWhere := 'WHERE ';

		IF p_titre IS NOT NULL THEN
			StringWhere := StringWhere || 'UPPER(Titre) LIKE ''' || p_titre || '%''';
		END IF;

		OPEN result FOR StringSelect || StringFrom || StringWhere;
		RETURN result;

	EXCEPTION
		WHEN OTHERS THEN RAISE; --TO DO LOG
	END;
END;
/

EXIT;
