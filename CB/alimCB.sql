CREATE OR REPLACE PROCEDURE alimCB(nombreAjout IN NUMBER)
AS
	
	s movies_ext%ROWTYPE;

	newFilm film%ROWTYPE;
	newGenre genre%ROWTYPE;
	newProducteur producteur%ROWTYPE;
	newPays pays%ROWTYPE;
	newLangue langue%ROWTYPE;
	newPersonne personne%ROWTYPE;
	newRole role%ROWTYPE;

	i number := 0;
	j number := 1;

	nbrCopie number;

  	chaine varchar2(4000);
  	decompVirgule varchar2(4000);
  	res owa_text.vc_arr;
  	found boolean;
  	idImage number;
  	lienImage varchar2(4000);
BEGIN
	--faire autrement
	select * into s 
	from (select * from movies_ext order by dbms_random.value)
	where rownum = 1;

	while i < nombreAjout
	loop

		idImage := null;
		dbms_output.put_line(s.poster_path);

		IF s.poster_path <> null THEN
			lienImage := 'http://image.tmdb.org/t/p/w185' || s.poster_path;
			idImage := IDAFFICHE.NEXTVAL;
		END IF;

		nbrCopie := FLOOR(dbms_random.normal * 2 + 5);

		dbms_output.put_line(s.poster_path);

		newFilm := 	PACKAGECB.verif_film_fields(s.id, s.title, s.original_title, s.release_date, s.status, s.vote_average,
					s.vote_count, s.runtime, s.certification, idImage, s.budget, s.revenue, s.homepage, s.tagline,
					s.overview, nbrCopie);

		BEGIN
			IF idImage <> null THEN
				insert into affiche values(idImage, httpuritype (lienImage).getblob ());
			END IF;
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
		        	WHEN OTHERS THEN LOGEVENT('insertion genre', 'TUPLE REJETE : ' ||SQLERRM);
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
		        	WHEN OTHERS THEN LOGEVENT('insérer producteur', 'TUPLE REJETE : ' ||SQLERRM);
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
		        	WHEN OTHERS THEN LOGEVENT('inserer pays', 'TUPLE REJETE : ' ||SQLERRM);
		        END;
	        end if;
	        j := j +1;
		end loop;

		j:=1;
		--LANGUE
		chaine := regexp_substr(s.SPOKEN_LANGUAGES, '^\[\[(.*)\]\]$', 1, 1, '', 1);
		loop
			decompVirgule := regexp_substr(chaine, '(.*?)(\|\||$)', 1, j, '', 1);
	        exit when decompVirgule is null;
	        
	        found := owa_pattern.match(decompVirgule, '^(.*),,(.*)$', res);
	        if found then
	        	
	        	BEGIN
	        		newLangue := PACKAGECB.verif_langue_fields(res(1), res(2));
		            insert into langue values newLangue;
		            insert into film_langue values (newFilm.id, newPays.id);
		        EXCEPTION
		        	WHEN OTHERS THEN LOGEVENT('inserer langue', 'TUPLE REJETE : ' ||SQLERRM);
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
	        		newPersonne := PACKAGECB.verif_personne_fields(TO_NUMBER(res(1)), res(2), res(3));
		            insert into personne values newPersonne;
		            insert into EST_REALISATEUR values (newFilm.id, newPersonne.id);
		        EXCEPTION
		        	WHEN OTHERS THEN LOGEVENT('inserer realisateur', 'TUPLE REJETE : ' ||SQLERRM);
		        END;

	        end if;
	        j := j +1;
		end loop;


		j:=1;
		--ACTEUR
		chaine := regexp_substr(s.actors, '^\[\[(.*)\]\]$', 1, 1, '', 1);
		loop
			decompVirgule := regexp_substr(chaine, '(.*?)(\|\||$)', 1, j, '', 1);
	        exit when decompVirgule is null;
	        
	        found := owa_pattern.match(decompVirgule, '^(.*),{2,}(.*),{2,}(.*),{2,}(.*),{2,}(.*)$', res);
	        if found then
	        	BEGIN
		        	newPersonne := PACKAGECB.verif_personne_fields(TO_NUMBER(res(1)), res(2), res(5));
		        	newRole := PACKAGECB.verif_role_fields(TO_NUMBER(res(3)), newFilm.id, res(4));
		            insert into personne values newPersonne;
		            insert into role values newRole;
		            insert into personne_role values (newPersonne.id, newRole.FILM_ASSOCIE, newRole.id);
		        EXCEPTION
		        	WHEN OTHERS THEN LOGEVENT('inserer acteur', 'TUPLE REJETE : ' ||SQLERRM);
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
