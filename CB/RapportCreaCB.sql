--RAPPORT FILM

DECLARE
  fichierId  utl_file.file_type;
  TYPE result IS RECORD
  (
    max NUMBER,
    min NUMBER,
    avg NUMBER,
    ecart NUMBER,
    mediane NUMBER,
    totVal  NUMBER
  );

  donnee result;
  valNull NUMBER;
  valVide NUMBER;
  quantile100 NUMBER;
  quantile10000 NUMBER;
BEGIN
  fichierId := utl_file.fopen ('MOVIEDIRECTORY', 'Rapport.txt', 'W');

  utl_file.put_line (fichierId, 'RAPPORT FILM');
  utl_file.put_line (fichierId, '------------');
  utl_file.put_line (fichierId, '                  Titre');
  utl_file.put_line (fichierId, '                  -----');

  SELECT MAX(LENGTH(TITLE)), MIN(LENGTH(TITLE)), AVG(LENGTH(TITLE)), STDDEV(LENGTH(TITLE)), MEDIAN(LENGTH(TITLE)), COUNT(TITLE) INTO donnee 
  FROM MOVIES_EXT;

  SELECT COUNT(*) INTO valNull FROM MOVIES_EXT WHERE TITLE IS NULL;
  SELECT COUNT(*) INTO valVide FROM MOVIES_EXT WHERE LENGTH(TITLE) = 0 OR TITLE = '0';

  SELECT COUNT(*) INTO quantile100
  FROM  ( SELECT NTILE(100) OVER(ORDER BY LENGTH(TITLE)) AS quantile
          FROM MOVIES_EXT)
  WHERE quantile = 99;

  SELECT COUNT(*) INTO quantile10000
  FROM  ( SELECT NTILE(10000) OVER(ORDER BY LENGTH(TITLE)) AS quantile
          FROM MOVIES_EXT)
  WHERE quantile = 9999;

  utl_file.put_line (fichierId, '             MAX:  ' || donnee.max);
  utl_file.put_line (fichierId, '             MIN:  ' || donnee.min);
  utl_file.put_line (fichierId, '         MOYENNE:  ' || ROUND(donnee.avg,2));
  utl_file.put_line (fichierId, '      ECART-TYPE:  ' || ROUND(donnee.ecart,2));
  utl_file.put_line (fichierId, '         MEDIANE:  ' || ROUND(donnee.mediane,2));
  utl_file.put_line (fichierId, '     NBR VALEURS:  ' || ROUND(donnee.totVal,2));
  utl_file.put_line (fichierId, '    VALEURS NULL:  ' || valNull);
  utl_file.put_line (fichierId, 'VALEURS NON NULL:  ' || (donnee.totVal - valNull));
  utl_file.put_line (fichierId, '   VALEURS VIDES:  ' || (valVide));
  utl_file.put_line (fichierId, '    100-QUANTILE:  ' || (quantile100));
  utl_file.put_line (fichierId, '   1000-QUANTILE:  ' || (quantile10000));

  SELECT MAX(LENGTH(ORIGINAL_TITLE)), MIN(LENGTH(ORIGINAL_TITLE)), AVG(LENGTH(ORIGINAL_TITLE)), STDDEV(LENGTH(ORIGINAL_TITLE)), 
  MEDIAN(LENGTH(ORIGINAL_TITLE)), COUNT(ORIGINAL_TITLE) INTO donnee 
  FROM MOVIES_EXT;

  SELECT COUNT(*) INTO valNull FROM MOVIES_EXT WHERE ORIGINAL_TITLE IS NULL;
  SELECT COUNT(*) INTO valVide FROM MOVIES_EXT WHERE LENGTH(ORIGINAL_TITLE) = 0 OR ORIGINAL_TITLE = '0';

  SELECT COUNT(*) INTO quantile100
  FROM  ( SELECT NTILE(100) OVER(ORDER BY LENGTH(ORIGINAL_TITLE)) AS quantile
          FROM MOVIES_EXT)
  WHERE quantile = 99;

  SELECT COUNT(*) INTO quantile10000
  FROM  ( SELECT NTILE(10000) OVER(ORDER BY LENGTH(ORIGINAL_TITLE)) AS quantile
          FROM MOVIES_EXT)
  WHERE quantile = 9999;

  utl_file.put_line (fichierId, '');
  utl_file.put_line (fichierId, '                  Titre Originale');
  utl_file.put_line (fichierId, '                  ---------------');

  utl_file.put_line (fichierId, '             MAX:    ' || donnee.max);
  utl_file.put_line (fichierId, '             MIN:    ' || donnee.min);
  utl_file.put_line (fichierId, '         MOYENNE:    ' || ROUND(donnee.avg,2));
  utl_file.put_line (fichierId, '      ECART-TYPE:    ' || ROUND(donnee.ecart,2));
  utl_file.put_line (fichierId, '         MEDIANE:    ' || ROUND(donnee.mediane,2));
  utl_file.put_line (fichierId, '     NBR VALEURS:    ' || ROUND(donnee.totVal,2));
  utl_file.put_line (fichierId, '    VALEURS NULL:    ' || valNull);
  utl_file.put_line (fichierId, 'VALEURS NON NULL:    ' || (donnee.totVal - valNull));
  utl_file.put_line (fichierId, '   VALEURS VIDES:    ' || (valVide));
  utl_file.put_line (fichierId, '    100-QUANTILE:    ' || (quantile100));
  utl_file.put_line (fichierId, '   1000-QUANTILE:    ' || (quantile10000));

  utl_file.fclose (fichierId);

EXCEPTION
  WHEN OTHERS THEN 
    IF utl_file.is_open(fichierId) then
	   utl_file.fclose (fichierId);
    END IF;

END;
/
