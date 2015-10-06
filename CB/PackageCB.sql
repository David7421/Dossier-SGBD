-------------------
-- SPECIFICATION --
-------------------
CREATE OR REPLACE PACKAGE PACKAGECB
IS
	PROCEDURE AJOUTER (Etud IN ETUDIANTS%ROWTYPE);


	-- PROCEDURE Lister1 (Anneesco IN PARCOURS_HE.ANSCO%TYPE, Referenceformdet IN PARCOURS_HE.REFFORMDET%TYPE);
	-- PROCEDURE Lister2 (Anneesco IN PARCOURS_HE.ANSCO%TYPE, Referenceformdet IN PARCOURS_HE.REFFORMDET%TYPE);
	-- PROCEDURE MODIFIER (var_old IN ETUDIANTS%ROWTYPE, var_new IN ETUDIANTS%ROWTYPE);
	-- FUNCTION Rechercher (Mat IN ETUDIANTS.MATRICULE%TYPE) RETURN ETUDIANTS%ROWTYPE;
	-- FUNCTION Rechercher (Name IN ETUDIANTS.NOM%TYPE, Surname IN ETUDIANTS.PRENOM%TYPE) RETURN ETUDIANTS%ROWTYPE;
	-- PROCEDURE SUPPRIMER (Mat IN ETUDIANTS.MATRICULE%TYPE);

	-- TYPE Etud IS RECORD
	-- 	(Num		ETUDIANTS.MATRICULE%TYPE,
	-- 	Name		ETUDIANTS.NOM%TYPE,
	-- 	Firstname	ETUDIANTS.PRENOM%TYPE);

	-- TYPE TableEtudiant IS TABLE OF Etud INDEX BY BINARY_INTEGER;
	-- TabEtud TableEtudiant;
END;










----------
-- BODY --
----------
CREATE OR REPLACE PACKAGE BODY GESTIONETUDIANTS
IS
	PROCEDURE AJOUTER (f IN EVALUATION.IDFILM%TYPE, u IN EVALUATION.LOGIN%TYPE, c IN EVALUATION.COTE%TYPE, a IN EVALUATION.AVIS%TYPE)
	AS

		-- CheckException				EXCEPTION;
		-- 	PRAGMA EXCEPTION_INIT (CheckException, -2290);
		-- NotNullException			EXCEPTION;
		-- 	PRAGMA EXCEPTION_INIT (NotNullException, -1400);
		-- ForeignKeyException			EXCEPTION;
		-- 	PRAGMA EXCEPTION_INIT (ForeignKeyException, -2291);

	BEGIN

		INSERT INTO EVALUATION (IDFILM, LOGIN, COTE, AVIS, DATEEVAL) VALUES (f, u, c, a, CURRENT_DATE);
		COMMIT;

	EXCEPTION

		WHEN DUP_VAL_ON_INDEX THEN
			IF SQLERRM LIKE '%ETUDIANTS_PK%' THEN RAISE_APPLICATION_ERROR(-20001, 'Le matricule n''est pas unique !');
			END IF;

		WHEN CheckException THEN
			CASE
				WHEN SQLERRM LIKE '%ETUDIANTS_NOM_CK%' THEN RAISE_APPLICATION_ERROR(-20011, 'Le nom de l''étudiant doit être renseigné !');
				WHEN SQLERRM LIKE '%ETUDIANTS_PRENOM_CK%' THEN RAISE_APPLICATION_ERROR(-20012, 'Le prénom de l''étudiant doit être renseigné !');
				WHEN SQLERRM LIKE '%ETUDIANTS_NATIONALITE_CK%' THEN RAISE_APPLICATION_ERROR(-20013, 'La nationalité de l''étudiant doit être renseignée !');
				WHEN SQLERRM LIKE '%ETUDIANTS_DATEENTREE_CK%' THEN RAISE_APPLICATION_ERROR(-20014, 'La date d''entrée de l''étudiant doit être renseignée !');
				WHEN SQLERRM LIKE '%ETUDIANTS_DATENAISSANCE_CK%' THEN RAISE_APPLICATION_ERROR(-20015, 'La date de naissance de l''étudiant doit être renseignée !');
				WHEN SQLERRM LIKE '%ETUDIANTS_LIEUNAISSANCE_CK%' THEN RAISE_APPLICATION_ERROR(-20016, 'Le lieu de naissance de l''étudiant doit être renseigné !');
				WHEN SQLERRM LIKE '%ETUDIANTS_CODEPAYSNAISSANCE_CK%' THEN RAISE_APPLICATION_ERROR(-20017, 'Le pays de naissance de l''étudiant doit être renseigné !');
				WHEN SQLERRM LIKE '%ETUDIANTS_LOCALITEDOM_CK%' THEN RAISE_APPLICATION_ERROR(-20018, 'La localité du domicile de l''étudiant doit être renseignée !');
				WHEN SQLERRM LIKE '%ETUDIANTS_CODEPAYSDOM_CK%' THEN RAISE_APPLICATION_ERROR(-20019, 'Le pays du domicile de l''étudiant doit être renseigné !');
				WHEN SQLERRM LIKE '%CK_DATEENTREE_DATENAISSANCE%' THEN RAISE_APPLICATION_ERROR(-20020, 'La date de naissance de l''étudiant (' || Etud.DATENAISSANCE || ') doit être antérieure à sa date d''entrée à l''HEPL (' || Etud.DATEENTREE || ') !');
				WHEN SQLERRM LIKE '%CK_AGE%' THEN RAISE_APPLICATION_ERROR(-20021, 'L''étudiant doit avoir au moins 16 ans lors de son entrée à l''HEPL !');
				WHEN SQLERRM LIKE '%CK_SEXE%' AND Etud.SEXE IS NULL THEN RAISE_APPLICATION_ERROR(-20022, 'Le sexe de l''étudiant doit être renseigné !');
				WHEN SQLERRM LIKE '%CK_SEXE%' AND Etud.SEXE IS NOT NULL THEN RAISE_APPLICATION_ERROR(-20023, 'Le sexe de l''étudiant (' || Etud.SEXE || ') doit valoir soit ''M'' (masculin), soit ''F'' (féminin) !');
				WHEN SQLERRM LIKE '%CK_ETATCIVIL%' THEN RAISE_APPLICATION_ERROR(-20024, 'L''état civil de l''étudiant (' || Etud.ETATCIVIL || ') doit valoir soit ''C'' (célibataire), soit ''M'' (marié(e)) !');
				WHEN SQLERRM LIKE '%CK_SITUATION%' THEN RAISE_APPLICATION_ERROR(-20025, 'La situation de l''étudiant doit (' || Etud.SITUATION || ') doit valoir soit ''I'', soit ''E'', soit ''D'' !');
			END CASE;

		WHEN ForeignKeyException THEN
			CASE
				WHEN SQLERRM LIKE '%ETUDIANTS_PAYSNATIONALITE_FK%' THEN RAISE_APPLICATION_ERROR (-20051, 'La nationalité de l''étudiant (' || Etud.NATIONALITE || ') n''existe pas !');
				WHEN SQLERRM LIKE '%ETUDIANTS_PAYSNAISSANCE_FK%' THEN RAISE_APPLICATION_ERROR (-20052, 'Le pays de naissance de l''étudiant (' || Etud.CODEPAYSNAISSANCE || ') n''existe pas !');
				WHEN SQLERRM LIKE '%ETUDIANTS_PAYSDOM_FK%' THEN RAISE_APPLICATION_ERROR (-20053, 'Le pays du domicile de l''étudiant (' || Etud.CODEPAYSDOM || ') n''existe pas !');
				WHEN SQLERRM LIKE '%ETUDIANTS_COMMUNES_FK%' THEN RAISE_APPLICATION_ERROR (-20054, 'La combinaison code postal - commune du domicile de l''étudiant (' || Etud.CODEPOSTALDOM || ', ' || Etud.LOCALITEDOM || ') n''existe pas !');
			END CASE;

		WHEN OTHERS THEN RAISE;

	END;





	-- PROCEDURE Lister1 (Anneesco IN PARCOURS_HE.ANSCO%TYPE, Referenceformdet IN PARCOURS_HE.REFFORMDET%TYPE)
	-- AS
	-- 	AnneescoNullExcept				EXCEPTION;
	-- 	ReferenceformdetNullExcept		EXCEPTION;
	-- 	IncorrectAnneescoExcept			EXCEPTION;

	-- BEGIN

	-- 	TabEtud.delete;

	-- 	IF(Anneesco IS NULL) THEN RAISE AnneescoNullExcept; END IF;
	-- 	IF(Referenceformdet IS NULL) THEN RAISE ReferenceformdetNullExcept; END IF;
	-- 	IF(Anneesco > EXTRACT(YEAR FROM CURRENT_DATE)) THEN RAISE IncorrectAnneescoExcept; END IF;

	-- 	SELECT DISTINCT	ETUDIANTS.MATRICULE, NOM, PRENOM BULK COLLECT INTO TabEtud
	-- 	FROM			ETUDIANTS, PARCOURS_HE, PARCOURS_HE_SESS
	-- 	WHERE			ETUDIANTS.MATRICULE = PARCOURS_HE.MATRICULE
	-- 	AND				PARCOURS_HE.MATRICULE = PARCOURS_HE_SESS.MATRICULE
	-- 	AND				UPPER(REFFORMDET) = UPPER(Referenceformdet)
	-- 	AND				ANNETUD = 3
	-- 	AND				PARCOURS_HE.ANSCO = Anneesco
	-- 	AND				RESULTAT = 'R60'
	-- 	AND				MENTION NOT IN ('DIS', 'GRD', 'PGD')
	-- 	AND				ETUDIANTS.MATRICULE IN	(SELECT DISTINCT	MATRICULE
	-- 											FROM				PARCOURS_HE_SESS
	-- 											WHERE				MENTION IN ('DIS', 'GRD', 'PGD'))
	-- 	ORDER BY NOM;

	-- 	IF(TabEtud.COUNT() = 0) THEN RAISE NO_DATA_FOUND; END IF;

	-- EXCEPTION
	-- 	WHEN NO_DATA_FOUND THEN RAISE_APPLICATION_ERROR(-20018, 'ERREUR : Pas de résultat.');  
	-- 	WHEN AnneescoNullExcept THEN RAISE_APPLICATION_ERROR(-20019, 'ERREUR : L''annee doit être renseignée.');
	-- 	WHEN ReferenceformdetNullExcept THEN RAISE_APPLICATION_ERROR(-20020, 'ERREUR : La formation doit être renseignée.');
	-- 	WHEN IncorrectAnneescoExcept THEN RAISE_APPLICATION_ERROR(-20021, 'ERREUR : L''annee (' || Anneesco || ') est invalide, elle doit être inférieure à l''année en cours.');
	-- 	WHEN OTHERS THEN RAISE;
	-- END;





	-- PROCEDURE Lister2 (Anneesco IN PARCOURS_HE.ANSCO%TYPE, Referenceformdet IN PARCOURS_HE.REFFORMDET%TYPE)
	-- AS
	-- 	CURSOR C IS		SELECT DISTINCT	ETUDIANTS.MATRICULE, NOM, PRENOM
	-- 					FROM			ETUDIANTS, PARCOURS_HE, PARCOURS_HE_SESS
	-- 					WHERE			ETUDIANTS.MATRICULE = PARCOURS_HE.MATRICULE
	-- 					AND				PARCOURS_HE.MATRICULE = PARCOURS_HE_SESS.MATRICULE
	-- 					AND				UPPER(REFFORMDET) = UPPER(Referenceformdet)
	-- 					AND				ANNETUD = 3
	-- 					AND				PARCOURS_HE.ANSCO = Anneesco
	-- 					AND				RESULTAT = 'R60'
	-- 					AND				MENTION NOT IN ('DIS', 'GRD', 'PGD')
	-- 					AND				ETUDIANTS.MATRICULE IN	(SELECT DISTINCT	MATRICULE
	-- 															FROM				PARCOURS_HE_SESS
	-- 															WHERE				MENTION IN ('DIS', 'GRD', 'PGD'))
	-- 					ORDER BY NOM;

	-- 	AnneescoNullExcept				EXCEPTION;
	-- 	ReferenceformdetNullExcept		EXCEPTION;
	-- 	IncorrectAnneescoExcept			EXCEPTION;

	-- BEGIN

	-- 	TabEtud.delete;

	-- 	IF(Anneesco IS NULL) THEN RAISE AnneescoNullExcept; END IF;
	-- 	IF(Referenceformdet IS NULL) THEN RAISE ReferenceformdetNullExcept; END IF;
	-- 	IF(Anneesco > EXTRACT(YEAR FROM CURRENT_DATE)) THEN RAISE IncorrectAnneescoExcept; END IF;

	-- 	OPEN C;

	-- 	FETCH C BULK COLLECT INTO TabEtud;

	-- 	IF(TabEtud.COUNT() = 0) THEN RAISE NO_DATA_FOUND; END IF;
		      
	-- 	CLOSE C;

	-- EXCEPTION
	-- 	WHEN NO_DATA_FOUND THEN RAISE_APPLICATION_ERROR(-20018, 'ERREUR : Pas de résultat.'); CLOSE C;
	-- 	WHEN AnneescoNullExcept THEN RAISE_APPLICATION_ERROR(-20019, 'ERREUR : L''annee doit être renseignée.');
	-- 	WHEN ReferenceformdetNullExcept THEN RAISE_APPLICATION_ERROR(-20020, 'ERREUR : La formation doit être renseignée.');
	-- 	WHEN IncorrectAnneescoExcept THEN RAISE_APPLICATION_ERROR(-20021, 'ERREUR : L''annee (' || Anneesco || ') est invalide, elle doit être inférieure à l''année en cours.');
	-- 	WHEN OTHERS THEN RAISE; CLOSE C;
	-- END;





	-- PROCEDURE Modifier(var_old IN ETUDIANTS%ROWTYPE, var_new IN ETUDIANTS%ROWTYPE)
	-- AS
	  
	--   	New_Invalid EXCEPTION;
	--   	No_Match EXCEPTION;

	--   	CheckException				EXCEPTION;
	-- 		PRAGMA EXCEPTION_INIT (CheckException, -2290);
	-- 	NotNullException			EXCEPTION;
	-- 		PRAGMA EXCEPTION_INIT (NotNullException, -1400);
	-- 	ForeignKeyException			EXCEPTION;
	-- 		PRAGMA EXCEPTION_INIT (ForeignKeyException, -2291);
	-- 	ImpossibleUpdate			EXCEPTION;
	-- 		PRAGMA EXCEPTION_INIT (ImpossibleUpdate, -0054);

	-- 	var_Test ETUDIANTS%ROWTYPE;
	--   	cpt INTEGER; 

	-- BEGIN

	--     cpt := 0;

	--     WHILE cpt < 3 LOOP
	-- 	    BEGIN

	-- 	        SELECT * INTO var_Test FROM ETUDIANTS WHERE matricule = var_new.matricule FOR UPDATE NOWAIT;

	-- 	        cpt := 3;

	-- 	        EXCEPTION
	-- 	            WHEN ImpossibleUpdate THEN DBMS_LOCK.sleep(3);
	-- 	            cpt := cpt+1;
	-- 	            WHEN OTHERS THEN RAISE;
	--         END; 
	--     END LOOP;

	--     IF(var_Test.matricule IS NULL) THEN RAISE ImpossibleUpdate; END IF;

	--     IF( var_old.matricule <> var_Test.matricule OR
	--         var_old.nom <> var_Test.nom OR
	--         var_old.prenom <> var_Test.prenom OR
	--         var_old.nationalite <> var_Test.nationalite OR
	--         var_old.etatcivil <> var_Test.etatcivil OR
	--         var_old.sexe <> var_Test.sexe OR
	--         var_old.situation <> var_Test.situation OR
	--         var_old.dateentree <> var_Test.dateentree OR
	--         var_old.datenaissance <> var_Test.datenaissance OR
	--         var_old.lieunaissance <> var_Test.lieunaissance OR
	--         var_old.codepaysnaissance <> var_Test.codepaysnaissance OR
	--         var_old.datedeces <> var_Test.datedeces OR
	--         var_old.codepostaldom <> var_Test.codepostaldom OR
	--         var_old.localitedom <> var_Test.localitedom OR
	--         var_old.codepaysdom <> var_Test.codepaysdom)
	--     THEN RAISE New_Invalid; END IF;

	--     UPDATE ETUDIANTS SET ROW = var_new WHERE matricule = var_Test.matricule;

	--     --COMMIT;
	--     ROLLBACK;

	-- EXCEPTION
	--   	WHEN ImpossibleUpdate THEN RAISE_APPLICATION_ERROR (-20002, 'Le tuple est en cours de modification sur une autre session');
	--   	WHEN New_Invalid THEN raise_application_error(-20118,'La modification ne peut pas être faite car la ligne a été modifiée entre temps !');

	-- 	WHEN DUP_VAL_ON_INDEX THEN
	-- 		IF SQLERRM LIKE '%ETUDIANTS_PK%' OR SQLERRM LIKE '%PARCOURS_HE_SESS_PK%' THEN RAISE_APPLICATION_ERROR(-20001, 'Le matricule n''est pas unique !');
	-- 		END IF;

	-- 	WHEN CheckException THEN
	-- 		CASE
	-- 			WHEN SQLERRM LIKE '%ETUDIANTS_NOM_CK%' THEN RAISE_APPLICATION_ERROR(-20011, 'Le nom de l''étudiant doit être renseigné !');
	-- 			WHEN SQLERRM LIKE '%ETUDIANTS_PRENOM_CK%' THEN RAISE_APPLICATION_ERROR(-20012, 'Le prénom de l''étudiant doit être renseigné !');
	-- 			WHEN SQLERRM LIKE '%ETUDIANTS_NATIONALITE_CK%' THEN RAISE_APPLICATION_ERROR(-20013, 'La nationalité de l''étudiant doit être renseignée !');
	-- 			WHEN SQLERRM LIKE '%ETUDIANTS_DATEENTREE_CK%' THEN RAISE_APPLICATION_ERROR(-20014, 'La date d''entrée de l''étudiant doit être renseignée !');
	-- 			WHEN SQLERRM LIKE '%ETUDIANTS_DATENAISSANCE_CK%' THEN RAISE_APPLICATION_ERROR(-20015, 'La date de naissance de l''étudiant doit être renseignée !');
	-- 			WHEN SQLERRM LIKE '%ETUDIANTS_LIEUNAISSANCE_CK%' THEN RAISE_APPLICATION_ERROR(-20016, 'Le lieu de naissance de l''étudiant doit être renseigné !');
	-- 			WHEN SQLERRM LIKE '%ETUDIANTS_CODEPAYSNAISSANCE_CK%' THEN RAISE_APPLICATION_ERROR(-20017, 'Le pays de naissance de l''étudiant doit être renseigné !');
	-- 			WHEN SQLERRM LIKE '%ETUDIANTS_LOCALITEDOM_CK%' THEN RAISE_APPLICATION_ERROR(-20018, 'La localité du domicile de l''étudiant doit être renseignée !');
	-- 			WHEN SQLERRM LIKE '%ETUDIANTS_CODEPAYSDOM_CK%' THEN RAISE_APPLICATION_ERROR(-20019, 'Le pays du domicile de l''étudiant doit être renseigné !');
	-- 			WHEN SQLERRM LIKE '%CK_DATEENTREE_DATENAISSANCE%' THEN RAISE_APPLICATION_ERROR(-20020, 'La date de naissance de l''étudiant (' || var_new.DATENAISSANCE || ') doit être antérieure à sa date d''entrée à l''HEPL (' || var_new.DATEENTREE || ') !');
	-- 			WHEN SQLERRM LIKE '%CK_AGE%' THEN RAISE_APPLICATION_ERROR(-20021, 'L''étudiant doit avoir au moins 16 ans lors de son entrée à l''HEPL !');
	-- 			WHEN SQLERRM LIKE '%CK_SEXE%' AND var_new.SEXE IS NULL THEN RAISE_APPLICATION_ERROR(-20022, 'Le sexe de l''étudiant doit être renseigné !');
	-- 			WHEN SQLERRM LIKE '%CK_SEXE%' AND var_new.SEXE IS NOT NULL THEN RAISE_APPLICATION_ERROR(-20023, 'Le sexe de l''étudiant (' || var_new.SEXE || ') doit valoir soit ''M'' (masculin), soit ''F'' (féminin) !');
	-- 			WHEN SQLERRM LIKE '%CK_ETATCIVIL%' THEN RAISE_APPLICATION_ERROR(-20024, 'L''état civil de l''étudiant (' || var_new.ETATCIVIL || ') doit valoir soit ''C'' (célibataire), soit ''M'' (marié(e)) !');
	-- 			WHEN SQLERRM LIKE '%CK_SITUATION%' THEN RAISE_APPLICATION_ERROR(-20025, 'La situation de l''étudiant doit (' || var_new.SITUATION || ') doit valoir soit ''I'', soit ''E'', soit ''D'' !');
	-- 		END CASE;

	-- 	WHEN ForeignKeyException THEN
	-- 		CASE
	-- 			WHEN SQLERRM LIKE '%ETUDIANTS_PAYSNATIONALITE_FK%' THEN RAISE_APPLICATION_ERROR (-20051, 'La nationalité de l''étudiant (' || var_new.NATIONALITE || ') n''existe pas !');
	-- 			WHEN SQLERRM LIKE '%ETUDIANTS_PAYSNAISSANCE_FK%' THEN RAISE_APPLICATION_ERROR (-20052, 'Le pays de naissance de l''étudiant (' || var_new.CODEPAYSNAISSANCE || ') n''existe pas !');
	-- 			WHEN SQLERRM LIKE '%ETUDIANTS_PAYSDOM_FK%' THEN RAISE_APPLICATION_ERROR (-20053, 'Le pays du domicile de l''étudiant (' || var_new.CODEPAYSDOM || ') n''existe pas !');
	-- 			WHEN SQLERRM LIKE '%ETUDIANTS_COMMUNES_FK%' THEN RAISE_APPLICATION_ERROR (-20054, 'La combinaison code postal - commune du domicile de l''étudiant (' || var_new.CODEPOSTALDOM || ', ' || var_new.LOCALITEDOM || ') n''existe pas !');
	-- 		END CASE;

	-- 	WHEN NO_DATA_FOUND THEN raise_application_error(-20120, 'L''élève que vous essayez de modifier n''existe pas/plus');

	-- 	WHEN OTHERS THEN RAISE;
	-- END;





	-- FUNCTION Rechercher (Mat IN ETUDIANTS.MATRICULE%TYPE)
	-- RETURN ETUDIANTS%ROWTYPE AS 
    
 --    	etud ETUDIANTS%ROWTYPE;
	-- 	MatriculeNullExcept		EXCEPTION;

	-- BEGIN
	-- 	IF(Mat IS NULL) THEN RAISE MatriculeNullExcept; END IF;

	-- 	SELECT	* INTO etud
	-- 	FROM	ETUDIANTS
	-- 	WHERE	MATRICULE = Mat;

	-- 	RETURN etud;

	-- EXCEPTION
	-- 	WHEN NO_DATA_FOUND THEN RAISE_APPLICATION_ERROR(-20011, 'ERREUR : Pas de resultat.'); RETURN NULL;
	-- 	WHEN MatriculeNullExcept THEN RAISE_APPLICATION_ERROR(-20012, 'ERREUR : Le matricule de l''etudiant doit etre renseigne.'); RETURN NULL;
	-- 	WHEN OTHERS THEN RAISE; RETURN NULL;
	-- END;





	-- FUNCTION Rechercher (Name IN ETUDIANTS.NOM%TYPE, Surname IN ETUDIANTS.PRENOM%TYPE)
	-- RETURN ETUDIANTS%ROWTYPE AS etud ETUDIANTS%ROWTYPE;

	-- 	NameNullExcept		EXCEPTION;
	-- 	SurnameNullExcept	EXCEPTION;

	-- BEGIN
	-- 	IF(Name IS NULL) THEN RAISE NameNullExcept; END IF;
	-- 	IF(Surname IS NULL) THEN RAISE SurnameNullExcept; END IF;

	-- 	SELECT	* INTO etud
	-- 	FROM	ETUDIANTS
	-- 	WHERE	UPPER(NOM) LIKE UPPER(Name || '%')
	-- 	AND		UPPER(PRENOM) LIKE UPPER(Surname || '%');

	-- 	RETURN etud;

	-- EXCEPTION
	-- 	WHEN NO_DATA_FOUND THEN RAISE_APPLICATION_ERROR(-20011, 'ERREUR : Pas de resultat.'); RETURN NULL;
	-- 	WHEN NameNullExcept THEN RAISE_APPLICATION_ERROR(-20012, 'ERREUR : Le nom de l''etudiant doit etre renseigne.'); RETURN NULL;
	-- 	WHEN SurnameNullExcept THEN RAISE_APPLICATION_ERROR(-20013, 'ERREUR : Le prenom de l''etudiant doit etre renseigne.'); RETURN NULL;
	-- 	WHEN TOO_MANY_ROWS THEN RAISE_APPLICATION_ERROR (-20014, 'ERREUR : Ces donnees peuvent correspondre a plusieurs etudiants.'); RETURN NULL;
	-- 	WHEN OTHERS THEN RAISE; RETURN NULL;
	-- END;





	-- PROCEDURE SUPPRIMER (Mat IN ETUDIANTS.MATRICULE%TYPE)
	-- AS
	-- 	MatriculeNullExcept		EXCEPTION;
	-- 	PasDonnee				EXCEPTION;

	-- BEGIN
	-- 	IF(Mat IS NULL) THEN RAISE MatriculeNullExcept; END IF;

	-- 	DELETE
	-- 	FROM	ETUDIANTS
	-- 	WHERE	MATRICULE = Mat
	-- 	AND		EXISTS	(SELECT *
	-- 					FROM PARCOURS_HE
	-- 					WHERE DATESORTIE IS NOT NULL
	-- 					AND MATRICULE = Mat
	-- 					AND ANSCO = (SELECT		MAX(ANSCO)
	-- 								FROM		PARCOURS_HE
	-- 								WHERE		MATRICULE = Mat));

	-- 	IF (SQL%NOTFOUND) THEN RAISE PasDonnee; END IF;

	-- EXCEPTION
	-- 	WHEN MatriculeNullExcept THEN RAISE_APPLICATION_ERROR(-20012, 'ERREUR : Le matricule de l''etudiant doit etre renseigne.');
	-- 	WHEN PasDonnee THEN RAISE_APPLICATION_ERROR(-20013, 'ERREUR : Le matricule de l''etudiant (' || Mat || ') ne donne pas de resultat.');
	-- 	WHEN OTHERS THEN RAISE;
	-- END;

END;