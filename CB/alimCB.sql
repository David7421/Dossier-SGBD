CREATE OR REPLACE PROCEDURE alimCB(nombreAjout IN NUMBER)
AS
	
	s movies_ext%ROWTYPE;

	newFilm film%ROWTYPE;
	newGenre genre%ROWTYPE;
	newProducteur producteur%ROWTYPE;
	newPays pays%ROWTYPE;
	newLangue langue%ROWTYPE;

	TYPE directors IS TABLE OF realisateur%ROWTYPE;
	newRealisateurs directors := directors();

	TYPE acteurs IS TABLE OF acteur%ROWTYPE;
	newActeurs acteurs := acteurs();

	TYPE roles IS TABLE OF role%ROWTYPE;
	newRoles roles := roles();


	i number := 0;
	j number := 1;

  	chaine varchar2(4000);
  	decompVirgule varchar2(4000);
  	res owa_text.vc_arr;
  	found boolean;

BEGIN

	while i < nombreAjout
	loop

		select * into s 
		from (select * from movies_ext order by dbms_random.value)
		where rownum = 1;

		dbms_output.put_line(s.PRODUCTION_COUNTRIES);

		newFilm := 	PACKAGECB.verif_film_fields(s.id, s.title, s.original_title, s.release_date, s.status, s.vote_average,
					s.vote_count, s.runtime, s.certification, s.poster_path, s.budget, s.revenue, s.homepage, s.tagline,
					s.overview, 5);

		BEGIN
			insert into film values newFilm;
		EXCEPTION
			WHEN OTHERS THEN LOGEVENT('Ajout film', SQLERRM); --NOTE IL FAUT FAIRE UN TRUC POUR QUE L'INSERTION SOIT MARQUEE RATEE
		END;

		--GENRES
		chaine := regexp_substr(s.genres, '^\[\[(.*)\]\]$', 1, 1, '', 1);
		loop
			decompVirgule := regexp_substr(chaine, '(.*?)(\|\||$)', 1, j, '', 1);
	        exit when decompVirgule is null;
	        
	        found := owa_pattern.match(decompVirgule, '^(.*),,(.*)$', res);
	        if found then
	        	BEGIN
		        	newGenre := PACKAGECB.verif_genre_fields(TO_NUMBER(res(1)), res(2));
		            insert into genre values newGenre;
		            insert into film_genre values (newFilm.id, newGenre.id);
		        EXCEPTION
		        	WHEN OTHERS THEN LOGEVENT('Ajout genre', SQLERRM);
		       	END;
	        end if;
	        j := j +1;
		end loop;

		j := 1;
		--PRODUCTEUR
		chaine := regexp_substr(s.production_companies, '^\[\[(.*)\]\]$', 1, 1, '', 1);
		loop
			decompVirgule := regexp_substr(chaine, '(.*?)(\|\||$)', 1, j, '', 1);
	        exit when decompVirgule is null;
	        
	        found := owa_pattern.match(decompVirgule, '^(.*),,(.*)$', res);
	        if found then
	        	BEGIN
		        	newProducteur := PACKAGECB.verif_producteur_fields(TO_NUMBER(res(1)), res(2));
		            insert into producteur values newProducteur;
		            insert into film_producteur values (newFilm.id, newProducteur.id);
		        EXCEPTION
		        	WHEN OTHERS THEN LOGEVENT('Ajout genre', SQLERRM);
		        END;
	        end if;
	        j := j +1;
		end loop;

		j:=1;
		--PAYS
		chaine := regexp_substr(s.PRODUCTION_COUNTRIES, '^\[\[(.*)\]\]$', 1, 1, '', 1);
		loop
			decompVirgule := regexp_substr(chaine, '(.*?)(\|\||$)', 1, j, '', 1);
	        exit when decompVirgule is null;
	        
	        found := owa_pattern.match(decompVirgule, '^(.*),,(.*)$', res);
	        if found then
	        	BEGIN
		        	newPays := PACKAGECB.verif_pays_fields(res(1), res(2));
		            insert into pays values newPays;
		            insert into film_pays values (newFilm.id, newPays.id);
		        EXCEPTION
		        	WHEN OTHERS THEN LOGEVENT('Ajout genre', SQLERRM);
		        END;
	        end if;
	        j := j +1;
		end loop;


		j:=1;
		--PAYS
		chaine := regexp_substr(s.PRODUCTION_COUNTRIES, '^\[\[(.*)\]\]$', 1, 1, '', 1);
		loop
			decompVirgule := regexp_substr(chaine, '(.*?)(\|\||$)', 1, j, '', 1);
	        exit when decompVirgule is null;
	        
	        found := owa_pattern.match(decompVirgule, '^(.*),,(.*)$', res);
	        if found then
	        	BEGIN
		        	newPays := PACKAGECB.verif_pays_fields(res(1), res(2));
		            insert into pays values newPays;
		            insert into film_pays values (newFilm.id, newPays.id);
		        EXCEPTION
		        	WHEN OTHERS THEN LOGEVENT('Ajout genre', SQLERRM);
		        END;
	        end if;
	        j := j +1;
		end loop;


		i := i+1;
	COMMIT;
	end loop;
EXCEPTION

	WHEN OTHERS THEN ROLLBACK; RAISE;

END;
