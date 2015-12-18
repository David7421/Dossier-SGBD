-------------------
-- SPECIFICATION --
-------------------

CREATE OR REPLACE PACKAGE ALIMDW
IS
	PROCEDURE LOAD;
END;
/





----------
-- BODY --
----------

CREATE OR REPLACE PACKAGE BODY ALIMDW
IS
	-- Procédure alimentant tout le schéma (idéal pour un job)
	PROCEDURE LOAD
	AS 
	BEGIN
		ALIMDW.LOAD_DIMENSIONS;
		ALIMDW.LOAD_FAITS;
	EXCEPTION
		WHEN OTHERS THEN LOGEVENT('ALIMDW - PROCEDURE LOAD', 'ERREUR : ' ||SQLERRM); ROLLBACK;
	END;


	-- Procédure alimentant toutes les dimensions
	PROCEDURE LOAD_DIMENSIONS
	AS

	BEGIN

	EXCEPTION
		WHEN OTHERS THEN LOGEVENT('ALIMDW - PROCEDURE LOAD_DIMENSIONS', 'ERREUR : ' ||SQLERRM); ROLLBACK;
	END;


	-- Procédure alimentant tous les faits
	PROCEDURE LOAD_FAITS
	AS

	BEGIN

	EXCEPTION
		WHEN OTHERS THEN LOGEVENT('ALIMDW - PROCEDURE LOAD_FAITS', 'ERREUR : ' ||SQLERRM); ROLLBACK;
	END;
END;
/