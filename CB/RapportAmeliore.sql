--RAPPORT FILM

DECLARE
  fichierId  utl_file.file_type;

  TYPE tabChar IS TABLE OF varchar2(20) INDEX BY BINARY_INTEGER;
  nomColonne tabChar;


  TYPE result IS RECORD
  (
    max NUMBER,
    min NUMBER,
    avg NUMBER,
    ecart NUMBER,
    mediane NUMBER,
    totVal NUMBER,
    quantile100 NUMBER,
    quantile1000 NUMBER
  );
  donnee result;
  valNull NUMBER;
  valVide NUMBER;

  cpt NUMBER;

  requeteBlock varchar2(500);
  
BEGIN
  fichierId := utl_file.fopen ('MOVIEDIRECTORY', 'Rapport.txt', 'W');

  utl_file.put_line (fichierId, 'RAPPORT FILM');
  utl_file.put_line (fichierId, '------------');

  SELECT COLUMN_NAME BULK COLLECT INTO nomColonne FROM user_tab_columns WHERE table_name='MOVIES_EXT';

  FOR cpt IN nomColonne.FIRST..nomColonne.LAST LOOP

    utl_file.put_line (fichierId,'');
    utl_file.put_line (fichierId, nomColonne(cpt) || ' :');

    dbms_output.put_line('Avant execute');

    requeteBlock := 'SELECT MAX(LENGTH(:a)), MIN(LENGTH(:a)), AVG(LENGTH(:a)), STDDEV(LENGTH(:a)), 
    MEDIAN(LENGTH(:a)), COUNT(:a), PERCENTILE_CONT(0.99) WITHIN GROUP(ORDER BY LENGTH(:a)), 
    PERCENTILE_CONT(0.999) WITHIN GROUP(ORDER BY LENGTH(:a))
    FROM MOVIES_EXT';

    dbms_output.put_line(nomColonne(cpt));

    EXECUTE IMMEDIATE requeteBlock INTO donnee USING nomColonne(cpt), nomColonne(cpt),nomColonne(cpt),nomColonne(cpt),nomColonne(cpt),nomColonne(cpt),nomColonne(cpt),nomColonne(cpt);

    dbms_output.put_line('apres execute');

    SELECT COUNT(*) INTO valNull FROM MOVIES_EXT WHERE nomColonne(cpt) IS NULL;
    SELECT COUNT(*) INTO valVide FROM MOVIES_EXT WHERE LENGTH(nomColonne(cpt)) = 0 OR nomColonne(cpt) = '0';

    utl_file.put_line (fichierId, '             MAX:  ' || donnee.max);
    utl_file.put_line (fichierId, '             MIN:  ' || donnee.min);
    utl_file.put_line (fichierId, '         MOYENNE:  ' || ROUND(donnee.avg,2));
    utl_file.put_line (fichierId, '      ECART-TYPE:  ' || ROUND(donnee.ecart,2));
    utl_file.put_line (fichierId, '         MEDIANE:  ' || ROUND(donnee.mediane,2));
    utl_file.put_line (fichierId, '     NBR VALEURS:  ' || ROUND(donnee.totVal,2));
    utl_file.put_line (fichierId, '    VALEURS NULL:  ' || valNull);
    utl_file.put_line (fichierId, 'VALEURS NON NULL:  ' || (donnee.totVal - valNull));
    utl_file.put_line (fichierId, '   VALEURS VIDES:  ' || (valVide));
    utl_file.put_line (fichierId, '    100-QUANTILE:  ' || (donnee.quantile100));
    utl_file.put_line (fichierId, '   1000-QUANTILE:  ' || (donnee.quantile1000));


  END LOOP;

  utl_file.fclose (fichierId);

EXCEPTION
  WHEN OTHERS THEN 
    IF utl_file.is_open(fichierId) THEN
     utl_file.fclose (fichierId);
    END IF;
    RAISE;

END;
/

--ListeAg et XMLAG à utiliser le1er pour la table externe et la liste des genres et ne 2eme au XML



