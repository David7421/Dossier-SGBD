create or replace TYPE nestedChar IS TABLE OF varchar2(4000);
/

DECLARE
  fichierId  utl_file.file_type;


  TYPE colonne IS RECORD
  (
    nom  varchar2(50),
    type varchar2(50)
  );

  TYPE tabCol IS TABLE OF colonne INDEX BY BINARY_INTEGER;
  nomColonne tabCol;


  TYPE result IS RECORD
  (
    max NUMBER,
    min NUMBER,
    avg NUMBER,
    ecart NUMBER,
    mediane NUMBER,
    totVal NUMBER,
    quantile100 NUMBER,
    quantile10000 NUMBER,
    valNull NUMBER
  );
  donnee result;

  valVide NUMBER;

  cpt NUMBER;
  parc NUMBER;
  i NUMBER;
  j NUMBER;

  TYPE resultChain IS TABLE OF varchar2(4000) INDEX BY BINARY_INTEGER;
  valeursUniques resultChain;
  chaineRegex resultChain;

  id nestedChar := nestedChar();
  nom nestedChar := nestedChar();
  image nestedChar := nestedChar();
  idPerso nestedChar := nestedChar();
  nomPerso nestedChar := nestedChar();

  listeColonne2Champs nestedChar := nestedChar('GENRES', 'PRODUCTION_COMPANIES', 'PRODUCTION_COUNTRIES', 'SPOKEN_LANGUAGES');

  requeteBlock varchar2(500);
  morceauRecup varchar2(10000);
  tmpChaine varchar2(10000);

  resultParse OWA_TEXT.VC_ARR;
  
BEGIN
  fichierId := utl_file.fopen ('MOVIEDIRECTORY', 'Rapport.txt', 'W');

  utl_file.put_line (fichierId, 'RAPPORT FILM');
  utl_file.put_line (fichierId, '------------');

  SELECT COLUMN_NAME, DATA_TYPE BULK COLLECT INTO nomColonne 
  FROM user_tab_columns 
  WHERE table_name='MOVIES_EXT'
  AND COLUMN_NAME != 'GENRES'
  AND COLUMN_NAME != 'DIRECTORS'
  AND COLUMN_NAME != 'ACTORS'
  AND COLUMN_NAME != 'PRODUCTION_COMPANIES'
  AND COLUMN_NAME != 'PRODUCTION_COUNTRIES'
  AND COLUMN_NAME != 'SPOKEN_LANGUAGES';

  utl_file.put_line (fichierId, 'TABLE FILM : ');

  FOR cpt IN nomColonne.FIRST..nomColonne.LAST LOOP

    utl_file.put_line (fichierId,'');
    utl_file.put_line (fichierId, nomColonne(cpt).nom || ' :');

    requeteBlock := 'SELECT MAX(LENGTH('||nomColonne(cpt).nom ||')), MIN(LENGTH('||nomColonne(cpt).nom ||')), 
    AVG(LENGTH('||nomColonne(cpt).nom ||')), STDDEV(LENGTH('||nomColonne(cpt).nom ||')), 
    MEDIAN(LENGTH('||nomColonne(cpt).nom ||')), COUNT('||nomColonne(cpt).nom ||'), 
    PERCENTILE_CONT(0.99) WITHIN GROUP(ORDER BY LENGTH('||nomColonne(cpt).nom ||')), 
    PERCENTILE_CONT(0.9999) WITHIN GROUP(ORDER BY LENGTH('||nomColonne(cpt).nom ||')), 
    COUNT(NVL2('||nomColonne(cpt).nom||', NULL, 1))
    FROM MOVIES_EXT';

    EXECUTE IMMEDIATE (requeteBlock) INTO donnee;

    IF(nomColonne(cpt).type = 'NUMBER') THEN
      requeteBlock := 'SELECT COUNT(*) FROM MOVIES_EXT WHERE ' || nomColonne(cpt).nom || ' = 0';
    ELSE
      requeteBlock := 'SELECT COUNT(*) FROM MOVIES_EXT WHERE ' || nomColonne(cpt).nom || ' = '''' ';
    END IF;

    EXECUTE IMMEDIATE (requeteBlock) INTO valVide;

    utl_file.put_line (fichierId, '             MAX:  ' || donnee.max);
    utl_file.put_line (fichierId, '             MIN:  ' || donnee.min);
    utl_file.put_line (fichierId, '         MOYENNE:  ' || ROUND(donnee.avg,2));
    utl_file.put_line (fichierId, '      ECART-TYPE:  ' || ROUND(donnee.ecart,2));
    utl_file.put_line (fichierId, '         MEDIANE:  ' || ROUND(donnee.mediane,2));
    utl_file.put_line (fichierId, '     NBR VALEURS:  ' || (donnee.totVal + donnee.valNull));
    utl_file.put_line (fichierId, '    VALEURS NULL:  ' || donnee.valNull);
    utl_file.put_line (fichierId, 'VALEURS NON NULL:  ' || donnee.totVal);
    utl_file.put_line (fichierId, '   VALEURS VIDES:  ' || (valVide));
    utl_file.put_line (fichierId, '    100-QUANTILE:  ' || (donnee.quantile100));
    utl_file.put_line (fichierId, '   10000-QUANTILE:  ' || (donnee.quantile10000));
    --traitement des colonnes dont on veut connaitre les valeurs
    IF(nomColonne(cpt).nom = 'STATUS' OR nomColonne(cpt).nom = 'CERTIFICATION') THEN

      requeteBlock := 'SELECT DISTINCT '|| nomColonne(cpt).nom || ' FROM MOVIES_EXT';
      EXECUTE IMMEDIATE(requeteBlock) BULK COLLECT INTO valeursUniques;

      utl_file.put_line(fichierId,'NOMBRE VALEURS UNIQUES : ' || valeursUniques.COUNT);
      utl_file.put_line(fichierId,'               VALEURS : ');

      FOR i IN valeursUniques.FIRST..valeursUniques.LAST LOOP
        utl_file.put_line(fichierId,'                      ' || valeursUniques(i));
      END LOOP;

      valeursUniques.DELETE;
    END IF;

  END LOOP;

    utl_file.fclose (fichierId);

  utl_file.fclose (fichierId);

EXCEPTION
  WHEN OTHERS THEN 
    IF utl_file.is_open(fichierId) THEN
     utl_file.fclose (fichierId);
    END IF;
    RAISE;

END;
/
