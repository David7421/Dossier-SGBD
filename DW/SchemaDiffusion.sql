-- DIMENSION GENRE

CREATE TABLE DIM_GENRE
(
	GENRE VARCHAR2 CONSTRAINT PK_DIM_GENRE PRIMARY KEY
);



-- DIMENSION GEOGRAPHIQUE

CREATE TABLE DIM_SALLE
(
	SALLE NUMBER CONSTRAINT PK_DIM_SALLE PRIMARY KEY
);

CREATE TABLE DIM_COMPLEXE
(
	COMPLEXE VARCHAR2 CONSTRAINT PK_DIM_COMPLEXE PRIMARY KEY
);

CREATE TABLE DIM_PAYS
(
	PAYS VARCHAR2 CONSTRAINT PK_DIM_PAYS PRIMARY KEY
);



-- DIMENSION NOMBRE DE JOUR DE PROJECTION

CREATE TABLE DIM_NBJOURSPROJ
(
	NBJOURSPROJ NUMBER CONSTRAINT PK_DIM_NBJOURSPROJ PRIMARY KEY
);



-- DIMENSION TEMPORELLE

CREATE TABLE DIM_PERIODE
(
	PERIODE NUMBER CONSTRAINT PK_DIM_PERIODE PRIMARY KEY
);

CREATE TABLE DIM_JOUR
(
	JOUR NUMBER CONSTRAINT PK_DIM_JOUR PRIMARY KEY
);

CREATE TABLE DIM_SEMAINE
(
	SEMAINE NUMBER CONSTRAINT PK_DIM_SEMAINE PRIMARY KEY
);

CREATE TABLE DIM_MOIS
(
	MOIS DATE CONSTRAINT PK_DIM_MOIS PRIMARY KEY
);

CREATE TABLE DIM_ANNEE
(
	ANNEE DATE CONSTRAINT PK_DIM_ANNEE PRIMARY KEY
);





-- FAIT 1A : La nationalité de l'acteur influe-t-elle sur le nombre de jours qu'un film reste à l'affiche ?

CREATE TABLE FAIT_COTE
(
	PAYS			NUMBER CONSTRAINT REF_DIM_PAYS REFERENCES DIM_PAYS(PAYS),
	NBJOURSPROJ 	NUMBER
);


-- FAIT 1B : La nationalité de l'acteur influe-t-elle sur la moyenne des notes que donnent les utilisateurs à un film ?

CREATE TABLE FAIT_COTE
(
	PAYS		NUMBER CONSTRAINT REF_DIM_PAYS REFERENCES DIM_PAYS(PAYS),
	MOYNOTES 	NUMBER -- AVG !!
);


-- FAIT 2 : Quelles sont les popularités des films projetés tenant compte ou non des genres du film, de la salle, de la période de la journée (matin, après-midi, soir) ou encore du jour, de la semaine ou du mois de la projection ?








-- FAIT 3 : La cote d'un film est-elle liée au nombre de jours qu'un film est projeté ?

CREATE TABLE FAIT_COTE
(
	NBJOURSPROJ		NUMBER CONSTRAINT REF_DIM_NBJOURSPROJ REFERENCES DIM_NBJOURSPROJ(NBJOURSPROJ),
	BUDGET_MOYEN 	NUMBER
);


-- FAIT 4 : Quelles sont les proportions de places vendues par salle ou complexe, par mois ou par année ?







-- FAIT 5 : Quel est le turn over des copies au sein des installations tenant compte du genre des films, de la semaine ou de l'année et du pays de production du film ?









