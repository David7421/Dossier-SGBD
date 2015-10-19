CREATE GLOBAL TEMPORARY TABLE productionComp_tmp
(
	id varchar2(1000),
	nom varchar2(1000)
)
ON COMMIT DELETE ROWS;

DECLARE

	TYPE tabChaines IS TABLE OF varchar2(4000) INDEX BY BINARY_INTEGER;

	chaineRegex tabChaines;
	id tabChaines;
	nom tabChaines;

	cpt NUMBER;
	i NUMBER := 1;
	parc NUMBER;

	morceauRecup varchar2(400);

	resultParse OWA_TEXT.VC_ARR;

BEGIN

	SELECT regexp_substr(PRODUCTION_COMPANIES, '^\[\[(.*)\]\]$', 1, 1, '', 1) BULK COLLECT INTO chaineRegex FROM movies_ext;

  	FOR cpt IN chaineRegex.FIRST..chaineRegex.LAST LOOP

    IF(LENGTH(chaineRegex(cpt)) > 0) THEN
      LOOP
        morceauRecup := regexp_substr(chaineRegex(cpt), '(.*?)(\|\||$)', 1, i, '', 1);

        EXIT WHEN morceauRecup IS NULL;

        IF OWA_PATTERN.MATCH(morceauRecup, '^(.*),,(.*)$', resultParse) THEN
          id(i) := resultParse(1);
          nom(i) := resultParse(2);
        END IF;

        i := i+1;
      END LOOP;

      FOR parc IN id.FIRST..id.LAST LOOP
        INSERT INTO productionComp_tmp VALUES(id(parc), nom(parc));
      END LOOP;

      i := 1;
      id.DELETE;
      nom.DELETE;

    END IF;

  END LOOP;


EXCEPTION
	WHEN OTHERS THEN RAISE;

END;


