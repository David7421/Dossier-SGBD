--RAPPORT FILM

DECLARE
  fichierId  utl_file.file_type;
  TYPE result IS RECORD
  (
    maxTitle NUMBER,
    minTitle NUMBER,
    avgTitle NUMBER,
    ecartTitle NUMBER,
    medianeTitle NUMBER,
    totValTitle  NUMBER,
    maxOTitle NUMBER,
    minOTitle NUMBER,
    avgOTitle NUMBER,
    ecartOTitle NUMBER,
    medianeOTitle NUMBER,
    totValOTitle  NUMBER,
    maxHome NUMBER,
    minHome NUMBER,
    avgHom NUMBER,
    ecartHome NUMBER,
    medianeHome NUMBER,
    totValHome  NUMBER
  );

  donnee result;
  valNull NUMBER;
  valVide NUMBER;
  quantile100 NUMBER;
  quantile1000 NUMBER;
BEGIN
  fichierId := utl_file.fopen ('MOVIEDIRECTORY', 'Rapport.txt', 'W');

  utl_file.put_line (fichierId, 'RAPPORT FILM');
  utl_file.put_line (fichierId, '------------');
  utl_file.put_line (fichierId, '                  Titre');
  utl_file.put_line (fichierId, '                  -----');

  SELECT MAX(LENGTH(TITLE)), MIN(LENGTH(TITLE)), AVG(LENGTH(TITLE)), STDDEV(LENGTH(TITLE)), MEDIAN(LENGTH(TITLE)), COUNT(TITLE),
   MAX(LENGTH(ORIGINAL_TITLE)), MIN(LENGTH(ORIGINAL_TITLE)), AVG(LENGTH(ORIGINAL_TITLE)), STDDEV(LENGTH(ORIGINAL_TITLE)), 
  MEDIAN(LENGTH(ORIGINAL_TITLE)), COUNT(ORIGINAL_TITLE),
  MAX(LENGTH(HOMEPAGE)), MIN(LENGTH(HOMEPAGE)), AVG(LENGTH(HOMEPAGE)), STDDEV(LENGTH(HOMEPAGE)), MEDIAN(LENGTH(HOMEPAGE)), COUNT(HOMEPAGE) INTO donnee 
  FROM MOVIES_EXT;

  SELECT COUNT(*) INTO valNull FROM MOVIES_EXT WHERE TITLE IS NULL;
  SELECT COUNT(*) INTO valVide FROM MOVIES_EXT WHERE LENGTH(TITLE) = 0 OR TITLE = '0';

  SELECT PERCENTILE_CONT(0.99) WITHIN GROUP(ORDER BY LENGTH(TITLE)) INTO quantile100
  FROM MOVIES_EXT;

  SELECT PERCENTILE_CONT(0.999) WITHIN GROUP(ORDER BY LENGTH(TITLE)) INTO quantile1000
  FROM MOVIES_EXT;

  utl_file.put_line (fichierId, '             MAX:  ' || donnee.maxTitle);
  utl_file.put_line (fichierId, '             MIN:  ' || donnee.minTitle);
  utl_file.put_line (fichierId, '         MOYENNE:  ' || ROUND(donnee.avgTitle,2));
  utl_file.put_line (fichierId, '      ECART-TYPE:  ' || ROUND(donnee.ecartTitle,2));
  utl_file.put_line (fichierId, '         MEDIANE:  ' || ROUND(donnee.medianeTitle,2));
  utl_file.put_line (fichierId, '     NBR VALEURS:  ' || ROUND(donnee.totValTitle,2));
  utl_file.put_line (fichierId, '    VALEURS NULL:  ' || valNull);
  utl_file.put_line (fichierId, 'VALEURS NON NULL:  ' || (donnee.totValTitle - valNull));
  utl_file.put_line (fichierId, '   VALEURS VIDES:  ' || (valVide));
  utl_file.put_line (fichierId, '    100-QUANTILE:  ' || (quantile100));
  utl_file.put_line (fichierId, '  1000-QUANTILE:   ' || (quantile1000));


  SELECT COUNT(*) INTO valNull FROM MOVIES_EXT WHERE ORIGINAL_TITLE IS NULL;
  SELECT COUNT(*) INTO valVide FROM MOVIES_EXT WHERE LENGTH(ORIGINAL_TITLE) = 0 OR ORIGINAL_TITLE = '0';

  SELECT PERCENTILE_CONT(0.99) WITHIN GROUP(ORDER BY LENGTH(ORIGINAL_TITLE)) INTO quantile100
  FROM MOVIES_EXT;

  SELECT PERCENTILE_CONT(0.999) WITHIN GROUP(ORDER BY LENGTH(ORIGINAL_TITLE)) INTO quantile1000
  FROM MOVIES_EXT;

  utl_file.put_line (fichierId, '');
  utl_file.put_line (fichierId, '                  Titre Originale');
  utl_file.put_line (fichierId, '                  ---------------');

  utl_file.put_line (fichierId, '             MAX:    ' || donnee.maxOTitle);
  utl_file.put_line (fichierId, '             MIN:    ' || donnee.minOTitle);
  utl_file.put_line (fichierId, '         MOYENNE:    ' || ROUND(donnee.avgOTitle,2));
  utl_file.put_line (fichierId, '      ECART-TYPE:    ' || ROUND(donnee.ecartOTitle,2));
  utl_file.put_line (fichierId, '         MEDIANE:    ' || ROUND(donnee.medianeOTitle,2));
  utl_file.put_line (fichierId, '     NBR VALEURS:    ' || ROUND(donnee.totValOTitle,2));
  utl_file.put_line (fichierId, '    VALEURS NULL:    ' || valNull);
  utl_file.put_line (fichierId, 'VALEURS NON NULL:    ' || (donnee.totValOTitle - valNull));
  utl_file.put_line (fichierId, '   VALEURS VIDES:    ' || (valVide));
  utl_file.put_line (fichierId, '    100-QUANTILE:    ' || (quantile100));
  utl_file.put_line (fichierId, '   1000-QUANTILE:    ' || (quantile1000));

  utl_file.fclose (fichierId);

EXCEPTION
  WHEN OTHERS THEN 
    IF utl_file.is_open(fichierId) then
	   utl_file.fclose (fichierId);
    END IF;

END;
/

--ListeAg et XMLAG à utiliser le1er pour la table externe et la liste des genres et ne 2eme au XML
