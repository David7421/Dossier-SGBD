--RAPPORT FILM

DECLARE
  fichierId  utl_file.file_type;
  donnee NUMBER;
BEGIN
  fichierId := utl_file.fopen ('MOVIEDIRECTORY', 'Rapport.txt', 'W');

  utl_file.put_line (fichierId, 'RAPPORT TITRE FILM');
  utl_file.put_line (fichierId, '------------------');

  SELECT MAX(LENGTH(TITLE)) INTO donnee FROM MOVIES_EXT;
  utl_file.put_line (fichierId, 'MAX LONGUEUR : ' || donnee);

  SELECT MIN(LENGTH(TITLE)) INTO donnee FROM MOVIES_EXT;
  utl_file.put_line (fichierId, 'MIN LONGUEUR : ' || donnee);

  SELECT AVG(LENGTH(TITLE)) INTO donnee FROM MOVIES_EXT;
  utl_file.put_line (fichierId, 'MOYENNE LONGUEURS : ' || donnee);



  utl_file.fclose (fichierId);

EXCEPTION
  WHEN OTHERS THEN 
    IF utl_file.is_open(fichierId) then
	   utl_file.fclose (fichierId);
    END IF;

END;
/
