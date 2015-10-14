--RAPPORT FILM

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
    quantile1000 NUMBER,
    valNull NUMBER,
    valVide NUMBER
  );
  donnee result;

  cpt NUMBER;

  requeteBlock varchar2(500);
  
BEGIN
  fichierId := utl_file.fopen ('MOVIEDIRECTORY', 'Rapport.txt', 'W');

  utl_file.put_line (fichierId, 'RAPPORT FILM');
  utl_file.put_line (fichierId, '------------');

  SELECT COLUMN_NAME, DATA_TYPE BULK COLLECT INTO nomColonne FROM user_tab_columns WHERE table_name='MOVIES_EXT';

  FOR cpt IN nomColonne.FIRST..nomColonne.LAST LOOP

    IF nomColonne(cpt).type != 'CLOB' THEN

      utl_file.put_line (fichierId,'');
      utl_file.put_line (fichierId, nomColonne(cpt).nom || ' :');

      IF nomColonne(cpt).type != 'VARCHAR2' THEN
        requeteBlock := 'SELECT MAX(LENGTH('||nomColonne(cpt).nom ||')), MIN(LENGTH('||nomColonne(cpt).nom ||')), 
        AVG(LENGTH('||nomColonne(cpt).nom ||')), STDDEV(LENGTH('||nomColonne(cpt).nom ||')), 
        MEDIAN(LENGTH('||nomColonne(cpt).nom ||')), COUNT('||nomColonne(cpt).nom ||'), 
        PERCENTILE_CONT(0.99) WITHIN GROUP(ORDER BY LENGTH('||nomColonne(cpt).nom ||')), 
        PERCENTILE_CONT(0.999) WITHIN GROUP(ORDER BY LENGTH('||nomColonne(cpt).nom ||')), 
        COUNT(NVL2('||nomColonne(cpt).nom||', NULL, 1)), COUNT(NVL2('||nomColonne(cpt).nom||', \'\', 1))
        FROM MOVIES_EXT';

        EXECUTE IMMEDIATE (requeteBlock) INTO donnee;
      END IF;

      IF nomColonne(cpt).type != 'NUMBER' THEN
        requeteBlock := 'SELECT MAX(LENGTH('||nomColonne(cpt).nom ||')), MIN(LENGTH('||nomColonne(cpt).nom ||')), 
        AVG(LENGTH('||nomColonne(cpt).nom ||')), STDDEV(LENGTH('||nomColonne(cpt).nom ||')), 
        MEDIAN(LENGTH('||nomColonne(cpt).nom ||')), COUNT('||nomColonne(cpt).nom ||'), 
        PERCENTILE_CONT(0.99) WITHIN GROUP(ORDER BY LENGTH('||nomColonne(cpt).nom ||')), 
        PERCENTILE_CONT(0.999) WITHIN GROUP(ORDER BY LENGTH('||nomColonne(cpt).nom ||')), 
        COUNT(NVL2('||nomColonne(cpt).nom||', NULL, 1)), COUNT(NVL2('||nomColonne(cpt).nom||', 0, 1))
        FROM MOVIES_EXT';

        EXECUTE IMMEDIATE (requeteBlock) INTO donnee;
      END IF;

      --SELECT COUNT(*) INTO valVide FROM MOVIES_EXT WHERE LENGTH(nomColonne(cpt)) = 0 OR nomColonne(cpt) = '0';

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

    END IF;
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



