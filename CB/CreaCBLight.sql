-- FINK Jérôme et SEEL Océane 
-- CreaCBLight

DROP DATABASE LINK CBB.DBL;
DROP TRIGGER COPIECOTESAVIS;
DROP TABLE EVALUATION;
DROP TABLE UTILISATEUR;


CREATE TABLE FILM
(
	ID 			NUMBER(7) CONSTRAINT PK_FILM_ID PRIMARY KEY,
	TITLE		VARCHAR2(21),
	
);

CREATE TABLE UTILISATEUR
(
	LOGIN		VARCHAR2(10) CONSTRAINT PK_UTILISATEUR_LOGIN PRIMARY KEY,
	PASSWORD	VARCHAR2(10) CONSTRAINT CK_PASSWORD_NOTNULL CHECK (PASSWORD IS NOT NULL),
	TOKEN		VARCHAR2(10) DEFAULT NULL
);


CREATE TABLE EVALUATION
(
	IDFILM		NUMBER(10),
	LOGIN		VARCHAR2(10) CONSTRAINT REF_UTILISATEUR_LOGIN REFERENCES UTILISATEUR (LOGIN),
	COTE		NUMBER(2),
	AVIS		VARCHAR2(1000),
	DATEEVAL	DATE CONSTRAINT CK_DATEEVAL_NOTNULL CHECK (DATEEVAL IS NOT NULL),
	TOKEN		VARCHAR2(10) DEFAULT NULL,
	CONSTRAINT PK_EVALUATION_IFILM_LOGIN  PRIMARY KEY (IDFILM, LOGIN),
	CONSTRAINT CK_COTEAVIS_NOTNULL CHECK ((COTE IS NOT NULL AND AVIS IS NULL) OR (COTE IS NULL AND AVIS IS NOT NULL) OR (COTE IS NOT NULL AND AVIS IS NOT NULL))
);





-- BIDONNAGE DES DONNEES DE BASE


BEGIN

	-- INSERTION DES USERS
	INSERT INTO UTILISATEUR (LOGIN, PASSWORD, TOKEN) VALUES ('JEROME', 'FINK', 'OK');
	INSERT INTO UTILISATEUR (LOGIN, PASSWORD, TOKEN) VALUES ('OCEANE', 'SEEL', 'OK');
	INSERT INTO UTILISATEUR (LOGIN, PASSWORD, TOKEN) VALUES ('AAA', 'AAA', 'OK');
	INSERT INTO UTILISATEUR (LOGIN, PASSWORD, TOKEN) VALUES ('BBB', 'BBB', 'OK');
	INSERT INTO UTILISATEUR (LOGIN, PASSWORD, TOKEN) VALUES ('CCC', 'CCC', 'OK');

	-- INSERTION DES EVALUATION
	INSERT INTO EVALUATION (IDFILM, LOGIN, COTE, AVIS, DATEEVAL, TOKEN) VALUES (1, 'JEROME', 5, NULL, to_timestamp('23/09/15 17:24:00','DD/MM/RR HH24:MI:SSXFF'), 'OK');
	INSERT INTO EVALUATION (IDFILM, LOGIN, COTE, AVIS, DATEEVAL, TOKEN) VALUES (2, 'OCEANE', NULL, 'Film génial', to_timestamp('22/09/15 15:20:00','DD/MM/RR HH24:MI:SSXFF'), 'OK');
	INSERT INTO EVALUATION (IDFILM, LOGIN, COTE, AVIS, DATEEVAL, TOKEN) VALUES (3, 'AAA', 7, NULL, to_timestamp('21/09/15 18:04:00','DD/MM/RR HH24:MI:SSXFF'), 'OK');
	INSERT INTO EVALUATION (IDFILM, LOGIN, COTE, AVIS, DATEEVAL, TOKEN) VALUES (4, 'JEROME', 1, 'J''ai détesté ce film', to_timestamp('22/09/15 09:53:00','DD/MM/RR HH24:MI:SSXFF'), 'OK');
	INSERT INTO EVALUATION (IDFILM, LOGIN, COTE, AVIS, DATEEVAL, TOKEN) VALUES (5, 'OCEANE', 10, NULL, to_timestamp('23/09/15 13:13:00','DD/MM/RR HH24:MI:SSXFF'), 'OK');

	COMMIT;

EXCEPTION
	WHEN OTHERS THEN
		-- LOGEVENT('CB : CREACBLIGHT', 'Bidonnage des données de base => ' || SQLCODE || ' : ' || SQLERRM);
		ROLLBACK;
		RAISE;
END;
/





CREATE DATABASE LINK CBB.DBL CONNECT TO CBB IDENTIFIED BY CBB USING 'CBB';

EXIT;
