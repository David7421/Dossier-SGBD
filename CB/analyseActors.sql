--RAPPORT FILM

CREATE GLOBAL TEMPORARY TABLE directors_tmp
(
  id varchar2(1000),
  nom varchar2(1000),
  image varchar2(1000)
)
ON COMMIT DELETE ROWS;

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
    valNull NUMBER
  );
  donnee result;

  cpt NUMBER;
  i NUMBER;
  valVide NUMBER;
  parc NUMBER;

  TYPE resultChain IS TABLE OF varchar2(4000) INDEX BY BINARY_INTEGER;
  valeursUniques resultChain;
  chaineRegex resultChain;
  id resultChain;
  nom resultChain;
  image resultChain;

  requeteBlock varchar2(500);

  morceauRecup varchar2(500);

  resultParse OWA_TEXT.VC_ARR;
  
BEGIN
  fichierId := utl_file.fopen ('MOVIEDIRECTORY', 'Rapport.txt', 'W');

  utl_file.put_line (fichierId, 'RAPPORT FILM');
  utl_file.put_line (fichierId, '------------');

  i := 1;
  SELECT regexp_substr(DIRECTORS, '^\[\[(.*)\]\]$', 1, 1, '', 1) BULK COLLECT INTO chaineRegex FROM movies_ext;

  FOR cpt IN chaineRegex.FIRST..chaineRegex.LAST LOOP

    IF(LENGTH(chaineRegex(cpt)) > 0) THEN
      LOOP
        morceauRecup := regexp_substr(chaineRegex(cpt), '(.*?)(\|\||$)', 1, i, '', 1);

        EXIT WHEN morceauRecup IS NULL;

        IF OWA_PATTERN.MATCH(morceauRecup, '^(.*),,(.*),,(.*)$', resultParse) THEN
          id(i) := resultParse(1);
          nom(i) := resultParse(2);
          image(i) := resultParse(3);
        END IF;

        i := i+1;
      END LOOP;

      FOR parc IN id.FIRST..id.LAST LOOP
        INSERT INTO directors_tmp VALUES(id(parc), nom(parc), image(i));
      END LOOP;

      i := 1;
      id.DELETE;
      nom.DELETE;
      image.DELETE;

    END IF;

  END LOOP;

  -- nomColonne.DELETE;

  -- SELECT COLUMN_NAME, DATA_TYPE BULK COLLECT INTO nomColonne 
  -- FROM user_tab_columns 
  -- WHERE table_name='DIRECTORS_TMP';
  
  -- utl_file.put_line (fichierId, '');
  -- utl_file.put_line (fichierId, '');
  -- utl_file.put_line (fichierId, 'TABLE DIRECTORS : ');

  -- FOR cpt IN nomColonne.FIRST..nomColonne.LAST LOOP

  --   utl_file.put_line (fichierId,'');
  --   utl_file.put_line (fichierId, nomColonne(cpt).nom || ' :');

  --   requeteBlock := 'SELECT MAX(LENGTH('||nomColonne(cpt).nom ||')), MIN(LENGTH('||nomColonne(cpt).nom ||')), 
  --   AVG(LENGTH('||nomColonne(cpt).nom ||')), STDDEV(LENGTH('||nomColonne(cpt).nom ||')), 
  --   MEDIAN(LENGTH('||nomColonne(cpt).nom ||')), COUNT('||nomColonne(cpt).nom ||'), 
  --   PERCENTILE_CONT(0.99) WITHIN GROUP(ORDER BY LENGTH('||nomColonne(cpt).nom ||')), 
  --   PERCENTILE_CONT(0.999) WITHIN GROUP(ORDER BY LENGTH('||nomColonne(cpt).nom ||')), 
  --   COUNT(NVL2('||nomColonne(cpt).nom||', NULL, 1))
  --   FROM DIRECTORS_TMP';

  --   EXECUTE IMMEDIATE (requeteBlock) INTO donnee;

  --   requeteBlock := 'SELECT COUNT(*) FROM DIRECTORS_TMP WHERE ' || nomColonne(cpt).nom || ' = '''' ';

  --   EXECUTE IMMEDIATE (requeteBlock) INTO valVide;

  --   utl_file.put_line (fichierId, '             MAX:  ' || donnee.max);
  --   utl_file.put_line (fichierId, '             MIN:  ' || donnee.min);
  --   utl_file.put_line (fichierId, '         MOYENNE:  ' || ROUND(donnee.avg,2));
  --   utl_file.put_line (fichierId, '      ECART-TYPE:  ' || ROUND(donnee.ecart,2));
  --   utl_file.put_line (fichierId, '         MEDIANE:  ' || ROUND(donnee.mediane,2));
  --   utl_file.put_line (fichierId, '     NBR VALEURS:  ' || (donnee.totVal + donnee.valNull));
  --   utl_file.put_line (fichierId, '    VALEURS NULL:  ' || donnee.valNull);
  --   utl_file.put_line (fichierId, 'VALEURS NON NULL:  ' || donnee.totVal);
  --   utl_file.put_line (fichierId, '   VALEURS VIDES:  ' || (valVide));
  --   utl_file.put_line (fichierId, '    100-QUANTILE:  ' || (donnee.quantile100));
  --   utl_file.put_line (fichierId, '   1000-QUANTILE:  ' || (donnee.quantile1000));

  -- END LOOP;


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
