
DECLARE

TYPE result IS RECORD
  (
    max NUMBER,
    min NUMBER,
    avg NUMBER,
    ecart NUMBER,
    mediane NUMBER,
    totVal NUMBER,
    quantile100 NUMBER,
    quantile1000 NUMBER,
    valNull NUMBER
  );
  donnee result;

  valVide NUMBER;
 
  TYPE TabVarchar IS TABLE OF VARCHAR2(4000);
  chaineRegex TabVarchar;
  varTmp varchar2(4000);
  parseTmp varchar2(1000);

  i INTEGER;
  j INTEGER;
  cpt INTEGER;

  id nestedChar := nestedChar();
  nom nestedChar := nestedChar();
  image nestedChar := nestedChar();
  idPerso nestedChar := nestedChar();
  nomPerso nestedChar := nestedChar();

  morceauRecup varchar2(4000);
  resultParse OWA_TEXT.VC_ARR;
  fichierId  utl_file.file_type;
BEGIN

    fichierId := utl_file.fopen ('MOVIEDIRECTORY', 'Rapport.txt', 'W');
    
    utl_file.put_line (fichierId, 'RAPPORT FILM');
    utl_file.put_line (fichierId, '------------');

    i:=1;
    SELECT regexp_substr(actors, '^\[\[(.*)\]\]$', 1, 1, '', 1) BULK COLLECT INTO chaineRegex FROM movies_ext WHERE ROWNUM <= 1000;

    FOR cpt IN chaineRegex.FIRST..chaineRegex.LAST LOOP
   
    IF(LENGTH(chaineRegex(cpt)) > 0) THEN
     
      LOOP
        varTmp := regexp_substr(chaineRegex(cpt), '(.*?)(\|\||$)', 1, i, '', 1);
        EXIT WHEN varTmp IS NULL;
        j:=1;
        LOOP
          parseTmp:=regexp_substr(varTmp, '(.*?)(,{2,}|$)', 1, j, '', 1);
          EXIT WHEN parseTmp IS NULL;

          IF j=1 AND parseTmp MEMBER OF id THEN
            EXIT;
          END IF;

          IF j=1 THEN
            id.extend();
            nom.extend();
            image.extend();
            idPerso.extend();
            nomPerso.extend();
            id(id.COUNT):=parseTmp;
          ELSIF j=2 THEN
            nom(nom.COUNT):=parseTmp;
          ELSIF j=3 THEN
            image(image.COUNT):=parseTmp;
          ELSIF j=4 THEN
            idPerso(idPerso.COUNT):=parseTmp;
          ELSIF j=5 THEN
            nomPerso(nomPerso.COUNT):= parseTmp;
          END IF;
 
          j:=j+1;
 
        END LOOP;
        i := i+1;
      END LOOP;
      i := 1;
    END IF;
  END LOOP;

  SELECT MAX(LENGTH(COLUMN_VALUE)), MIN(LENGTH(COLUMN_VALUE)), AVG(LENGTH(COLUMN_VALUE)), STDDEV(LENGTH(COLUMN_VALUE)), 
  MEDIAN(LENGTH(COLUMN_VALUE)), COUNT(COLUMN_VALUE), PERCENTILE_CONT(0.99) WITHIN GROUP(ORDER BY LENGTH(COLUMN_VALUE)), 
  PERCENTILE_CONT(0.999) WITHIN GROUP(ORDER BY LENGTH(COLUMN_VALUE)), COUNT(NVL2(COLUMN_VALUE, NULL, 1)) INTO donnee
  FROM TABLE(id);

  SELECT COUNT(*) INTO valVide FROM TABLE(id) WHERE COLUMN_VALUE = '';

  utl_file.put_line (fichierId, '');
  utl_file.put_line (fichierId, 'id :');

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
  utl_file.put_line (fichierId, '   1000-QUANTILE:  ' || (donnee.quantile1000));

  SELECT MAX(LENGTH(COLUMN_VALUE)), MIN(LENGTH(COLUMN_VALUE)), AVG(LENGTH(COLUMN_VALUE)), STDDEV(LENGTH(COLUMN_VALUE)), 
  MEDIAN(LENGTH(COLUMN_VALUE)), COUNT(COLUMN_VALUE), PERCENTILE_CONT(0.99) WITHIN GROUP(ORDER BY LENGTH(COLUMN_VALUE)), 
  PERCENTILE_CONT(0.999) WITHIN GROUP(ORDER BY LENGTH(COLUMN_VALUE)), COUNT(NVL2(COLUMN_VALUE, NULL, 1)) INTO donnee
  FROM TABLE(nom);

  SELECT COUNT(*) INTO valVide FROM TABLE(nom) WHERE COLUMN_VALUE = '';

  utl_file.put_line (fichierId, '');
  utl_file.put_line (fichierId, 'nom');

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
  utl_file.put_line (fichierId, '   1000-QUANTILE:  ' || (donnee.quantile1000));

  SELECT MAX(LENGTH(COLUMN_VALUE)), MIN(LENGTH(COLUMN_VALUE)), AVG(LENGTH(COLUMN_VALUE)), STDDEV(LENGTH(COLUMN_VALUE)), 
  MEDIAN(LENGTH(COLUMN_VALUE)), COUNT(COLUMN_VALUE), PERCENTILE_CONT(0.99) WITHIN GROUP(ORDER BY LENGTH(COLUMN_VALUE)), 
  PERCENTILE_CONT(0.999) WITHIN GROUP(ORDER BY LENGTH(COLUMN_VALUE)), COUNT(NVL2(COLUMN_VALUE, NULL, 1)) INTO donnee
  FROM TABLE(image);

  SELECT COUNT(*) INTO valVide FROM TABLE(nom) WHERE COLUMN_VALUE = '';

  utl_file.put_line (fichierId, '');
  utl_file.put_line (fichierId, 'image');

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
  utl_file.put_line (fichierId, '   1000-QUANTILE:  ' || (donnee.quantile1000));

  SELECT MAX(LENGTH(COLUMN_VALUE)), MIN(LENGTH(COLUMN_VALUE)), AVG(LENGTH(COLUMN_VALUE)), STDDEV(LENGTH(COLUMN_VALUE)), 
  MEDIAN(LENGTH(COLUMN_VALUE)), COUNT(COLUMN_VALUE), PERCENTILE_CONT(0.99) WITHIN GROUP(ORDER BY LENGTH(COLUMN_VALUE)), 
  PERCENTILE_CONT(0.999) WITHIN GROUP(ORDER BY LENGTH(COLUMN_VALUE)), COUNT(NVL2(COLUMN_VALUE, NULL, 1)) INTO donnee
  FROM TABLE(idPerso);

  SELECT COUNT(*) INTO valVide FROM TABLE(nom) WHERE COLUMN_VALUE = '';

  utl_file.put_line (fichierId, '');
  utl_file.put_line (fichierId, 'nom');

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
  utl_file.put_line (fichierId, '   1000-QUANTILE:  ' || (donnee.quantile1000));

  SELECT MAX(LENGTH(COLUMN_VALUE)), MIN(LENGTH(COLUMN_VALUE)), AVG(LENGTH(COLUMN_VALUE)), STDDEV(LENGTH(COLUMN_VALUE)), 
  MEDIAN(LENGTH(COLUMN_VALUE)), COUNT(COLUMN_VALUE), PERCENTILE_CONT(0.99) WITHIN GROUP(ORDER BY LENGTH(COLUMN_VALUE)), 
  PERCENTILE_CONT(0.999) WITHIN GROUP(ORDER BY LENGTH(COLUMN_VALUE)), COUNT(NVL2(COLUMN_VALUE, NULL, 1)) INTO donnee
  FROM TABLE(nomPerso);

  SELECT COUNT(*) INTO valVide FROM TABLE(nom) WHERE COLUMN_VALUE = '';

  utl_file.put_line (fichierId, '');
  utl_file.put_line (fichierId, 'image');

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
  utl_file.put_line (fichierId, '   1000-QUANTILE:  ' || (donnee.quantile1000));

  utl_file.fclose (fichierId);

  EXCEPTION
WHEN OTHERS THEN RAISE;
END RECUPTABREGEXP;