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
BEGIN
  fichierId := utl_file.fopen ('MOVIEDIRECTORY', 'Rapport.txt', 'W');

  utl_file.put_line (fichierId, 'RAPPORT FILM');
  utl_file.put_line (fichierId, '------------');
  utl_file.put_line (fichierId, '                  Titre');
  utl_file.put_line (fichierId, '                  -----');

  SELECT MAX(LENGTH(TITLE)), MIN(LENGTH(TITLE)), AVG(LENGTH(TITLE)), STDDEV(LENGTH(TITLE)), MEDIAN(LENGTH(TITLE)), COUNT(TITLE) INTO donnee FROM MOVIES_EXT;

  SELECT COUNT(*) INTO valNull FROM MOVIES_EXT WHERE TITLE IS NULL;

  utl_file.put_line (fichierId, '             MAX:  ' || donnee.max);
  utl_file.put_line (fichierId, '             MIN:  ' || donnee.min);
  utl_file.put_line (fichierId, '         MOYENNE:  ' || ROUND(donnee.avg,2));
  utl_file.put_line (fichierId, '      ECART-TYPE:  ' || ROUND(donnee.ecart,2));
  utl_file.put_line (fichierId, '         MEDIANE:  ' || ROUND(donnee.mediane,2));
  utl_file.put_line (fichierId, '     NBR VALEURS:  ' || ROUND(donnee.totVal,2));
  utl_file.put_line (fichierId, '    VALEURS NULL:  ' || valNull);
  utl_file.put_line (fichierId, 'VALEURS NON NULL:  ' || (donnee.totVal - valNull));


  utl_file.fclose (fichierId);

EXCEPTION
  WHEN OTHERS THEN 
    IF utl_file.is_open(fichierId) then
	   utl_file.fclose (fichierId);
    END IF;

END;
/
