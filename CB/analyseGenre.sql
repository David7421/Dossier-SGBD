CREATE OR REPLACE LOCAL TEMPORARY TABLE genre_tmp
(
	id varchar2(1000),
	nom varchar2(1000)
)
ON COMMIT DELETE ROWS;

DECLARE

	TYPE tabChaines IS TABLE OF varchar2(500) INDEX BY BINARY_INTEGER;

	chaineRegex tabChaines;
	id tabChaines;
	nom tabChaines;

	cpt NUMBER;
	i NUMBER := 1;
	parc NUMBER;

	genre varchar2(500);

	result OWA_TEXT.VC_ARR;

BEGIN

	SELECT regexp_substr(genres, '^\[\[(.*)\]\]$', 1, 1, '', 1) BULK COLLECT INTO chaineRegex FROM movies_ext;

	FOR cpt IN chaineRegex.FIRST..chaineRegex.LAST LOOP

		IF(LENGTH(chaineRegex(cpt)) > 0) THEN
			LOOP
				genre := regexp_substr(chaineRegex(cpt), '(.*?)(\|\||$)', 1, i, '', 1);

				EXIT WHEN genre IS NULL;

				IF OWA_PATTERN.MATCH(genre, '^(.*),,(.*)$', result) THEN
					id(i) := result(1);
					nom(i) := result(2);
				END IF;

				i := i+1;
			END LOOP;

			FOR parc IN id.FIRST..id.LAST LOOP
				INSERT INTO genre_tmp VALUES(id(parc), nom(parc));
			END LOOP;

			i := 1;
			id.DELETE;
			nom.DELETE;

		END IF;

	END LOOP;

	SELECT *
	FROM genre_tmp;

EXCEPTION
	WHEN OTHERS THEN RAISE;

END;


