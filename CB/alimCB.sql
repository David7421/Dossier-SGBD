CREATE OR REPLACE PROCEDURE alimCB(nombreAjout IN NUMBER)
AS
	
	s movies_ext%ROWTYPE;

	newFilm film%ROWTYPE;
	newGenre genre%ROWTYPE;
	newProducteur producteur%ROWTYPE;
	newPays pays%ROWTYPE;
	newLangue langue%ROWTYPE;
	newRealisateur realisateur%ROWTYPE;
	newActeur acteur%ROWTYPE;
	newRole role%ROWTYPE;

	i number := 0;
	j number := 1;

	nbrCopie number;

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

		nbrCopie := FLOOR(dbms_random.normal * 2 + 5);

		dbms_output.put_line(s.PRODUCTION_COUNTRIES);

		newFilm := 	PACKAGECB.verif_film_fields(s.id, s.title, s.original_title, s.release_date, s.status, s.vote_average,
					s.vote_count, s.runtime, s.certification, s.poster_path, s.budget, s.revenue, s.homepage, s.tagline,
					s.overview, nbrCopie);

		BEGIN
			insert into film values newFilm;
		EXCEPTION
			WHEN OTHERS THEN LOGEVENT('Ajout film', 'TUPLE REJETE : ' ||SQLERRM); --NOTE IL FAUT FAIRE UN TRUC POUR QUE L'INSERTION SOIT MARQUEE RATEE
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
		        	WHEN OTHERS THEN LOGEVENT('Ajout genre', 'TUPLE REJETE : ' ||SQLERRM);
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
		        	WHEN OTHERS THEN LOGEVENT('Ajout genre', 'TUPLE REJETE : ' ||SQLERRM);
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
		        	WHEN OTHERS THEN LOGEVENT('Ajout genre', 'TUPLE REJETE : ' ||SQLERRM);
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
		        	WHEN OTHERS THEN LOGEVENT('Ajout genre', 'TUPLE REJETE : ' ||SQLERRM);
		        END;
	        end if;
	        j := j +1;
		end loop;


		j:=1;
		--REALISATEUR
		chaine := regexp_substr(s.directors, '^\[\[(.*)\]\]$', 1, 1, '', 1);
		loop
			decompVirgule := regexp_substr(chaine, '(.*?)(\|\||$)', 1, j, '', 1);
	        exit when decompVirgule is null;
	        
	        found := owa_pattern.match(decompVirgule, '^(.*),{2,}(.*),{2,}(.*)$', res);
	        if found then
	        	BEGIN
		        	newRealisateur := PACKAGECB.verif_realisateur_fields(TO_NUMBER(res(1)), res(2), res(3));
		            insert into realisateur values newRealisateur;
		            insert into film_realisateur values (newFilm.id, newRealisateur.id);
		        EXCEPTION
		        	WHEN OTHERS THEN LOGEVENT('Ajout genre', 'TUPLE REJETE : ' ||SQLERRM);
		        END;
	        end if;
	        j := j +1;
		end loop;


		j:=1;
		--ACTEUR
		chaine := regexp_substr(s.directors, '^\[\[(.*)\]\]$', 1, 1, '', 1);
		loop
			decompVirgule := regexp_substr(chaine, '(.*?)(\|\||$)', 1, j, '', 1);
	        exit when decompVirgule is null;
	        
	        found := owa_pattern.match(decompVirgule, '^(.*),{2,}(.*),{2,}(.*),{2,}(.*),{2,}(.*)$', res);
	        if found then
	        	BEGIN
		        	newActeur := PACKAGECB.verif_acteur_fields(TO_NUMBER(res(1)), res(2), res(5));
		        	newRole := PACKAGECB.verif_role_fields(TO_NUMBER(res(3)), newFilm.id, res(4));
		            insert into acteur values newActeur;
		            insert into role values newRole;
		            insert into acteur_role values (newActeur.id, newRole.FILM_ASSOCIE, newRole.id);
		        EXCEPTION
		        	WHEN OTHERS THEN LOGEVENT('Ajout genre', 'TUPLE REJETE : ' ||SQLERRM);
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
