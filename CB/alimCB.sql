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

	id varchar2(4000);
	valeur varchar2(4000);
	image varchar2(4000);
	id_role varchar2(4000);
	nom_role varchar2(4000);

	i number := 0;
	j number := 1;
	k number;

	nbrCopie number;

  	chaine varchar2(4000);
  	decompVirgule varchar2(4000);
  	idImage number;
  	lienImage varchar2(4000);
  	tmpChaine varchar2(4000);

  	movieExist NUMBER;
BEGIN
	--faire autrement
	
	FOR s IN (select * from (select * from movies_ext order by dbms_random.value))
	loop
		dbms_output.put_line(s.id);
		dbms_output.put_line(s.poster_path);

		EXIT WHEN i >= nombreAjout;

		nbrCopie := FLOOR(dbms_random.normal * 2 + 5);
		movieExist := 0;

		BEGIN
			newFilm := 	PACKAGECB.verif_film_fields(s.id, s.title, s.original_title, s.release_date, s.status, s.vote_average,
						s.vote_count, s.runtime, s.certification, null, s.budget, s.revenue, s.homepage, s.tagline,
						s.overview, nbrCopie);
			insert into film values newFilm;
		EXCEPTION
			WHEN dup_val_on_index THEN
				movieExist := 1;
			WHEN OTHERS THEN 
				LOGEVENT('Ajout film', 'ERREUR FILM '|| s.id||' REJETE  : ' ||SQLERRM);
				movieExist := 2;
		END;

		--Cas si il y a eu une erreur qui a rejeté le film
		IF movieExist = 2 THEN CONTINUE;
		--Si le film existe déjà
		ELSIF movieExist = 1 THEN
			LOGEVENT('MAJ FILM', 'Mise à jour des copies d''un film existent');
			BEGIN
				UPDATE film SET nbr_copie = nbrCopie WHERE id = s.id;
			EXCEPTION
				WHEN OTHERS THEN LOGEVENT('UPDATE nbr_copie', 'ERREUR FILM '||s.id||' : ' ||SQLERRM);
			END;
			i:=i+1;
			CONTINUE;
		--Le film n'existe pas
		ELSIF movieExist = 0 THEN
			IF LENGTH(s.poster_path) > 0 THEN --Il a un poster
				LOGEVENT('Ajout poster', 'Ajout d''un poster');
				idImage := IDAFFICHE.NEXTVAL;
				lienImage := 'http://image.tmdb.org/t/p/w185'||s.poster_path;

				BEGIN
					insert into affiche values(idImage, httpuritype (lienImage).getblob ());
					UPDATE film SET affiche = idImage WHERE id = s.id;
				EXCEPTION
					WHEN OTHERS THEN
						LOGEVENT('Ajout affiche', 'ERREUR AFFICHE FILM '|| s.id||' REJETE  : ' ||SQLERRM);
				END;
			END IF;
		END IF;

		--GENRES
		chaine := regexp_substr(s.genres, '^\[\[(.*)\]\]$', 1, 1, '', 1);
		loop
			decompVirgule := regexp_substr(chaine, '(.*?)(\|\||$)', 1, j, '', 1);
	        exit when decompVirgule is null;

	        k:=1;
	        LOOP
	          tmpChaine:=regexp_substr(decompVirgule, '(.*?)(,{2,}|$)', 1, k, '', 1);
	          EXIT WHEN tmpChaine IS NULL;

	          IF k=1 THEN
	            id := tmpChaine;
	          ELSIF k=2 THEN
	            valeur:=tmpChaine;
	          END IF;
	          k:=k+1;
	        END LOOP;
	        dbms_output.put_line(id ||'   '|| valeur);
	        BEGIN
	        	newGenre := PACKAGECB.verif_genre_fields(TO_NUMBER(id), valeur);
		        insert into genre values newGenre;
		        insert into film_genre values (newFilm.id, newGenre.id);
		    EXCEPTION
		    	WHEN OTHERS THEN LOGEVENT('insertion genre', 'TUPLE REJETE : ' ||SQLERRM);
		    END;
	        j := j +1;
		end loop;

		j := 1;
		--PRODUCTEUR
		chaine := regexp_substr(s.production_companies, '^\[\[(.*)\]\]$', 1, 1, '', 1);
		loop
			decompVirgule := regexp_substr(chaine, '(.*?)(\|\||$)', 1, j, '', 1);
	        exit when decompVirgule is null;
	        
	        k:=1;
	        LOOP
	          tmpChaine:=regexp_substr(decompVirgule, '(.*?)(,{2,}|$)', 1, k, '', 1);
	          EXIT WHEN tmpChaine IS NULL;

	          IF k=1 THEN
	            id := tmpChaine;
	          ELSIF k=2 THEN
	            valeur:=tmpChaine;
	          END IF;
	          k:=k+1;
	        END LOOP;
	        	
	        BEGIN
	        	newProducteur := PACKAGECB.verif_producteur_fields(TO_NUMBER(id), valeur);
		        insert into producteur values newProducteur;
		        insert into film_producteur values (newFilm.id, newProducteur.id);
		    EXCEPTION
		        WHEN OTHERS THEN LOGEVENT('insérer producteur', 'TUPLE REJETE : ' ||SQLERRM);
		    END;
		        
	        j := j +1;
		end loop;

		j:=1;
		--PAYS
		chaine := regexp_substr(s.PRODUCTION_COUNTRIES, '^\[\[(.*)\]\]$', 1, 1, '', 1);
		loop
			decompVirgule := regexp_substr(chaine, '(.*?)(\|\||$)', 1, j, '', 1);
	        exit when decompVirgule is null;
	        
	        k:=1;
	        LOOP
	          tmpChaine:=regexp_substr(decompVirgule, '(.*?)(,{2,}|$)', 1, k, '', 1);
	          EXIT WHEN tmpChaine IS NULL;

	          IF k=1 THEN
	            id := tmpChaine;
	          ELSIF k=2 THEN
	            valeur:=tmpChaine;
	          END IF;
	          k:=k+1;
	        END LOOP;
	        	
	        BEGIN
	        	newPays := PACKAGECB.verif_pays_fields(id, valeur);
		        insert into pays values newPays;
		        insert into film_pays values (newFilm.id, newPays.id);
		    EXCEPTION
		       	WHEN OTHERS THEN LOGEVENT('inserer pays', 'TUPLE REJETE : ' ||SQLERRM);
		    END;
	        j := j +1;
		end loop;

		j:=1;
		--LANGUE
		chaine := regexp_substr(s.SPOKEN_LANGUAGES, '^\[\[(.*)\]\]$', 1, 1, '', 1);
		loop
			decompVirgule := regexp_substr(chaine, '(.*?)(\|\||$)', 1, j, '', 1);
	        exit when decompVirgule is null;
	        
	        k:=1;
	        LOOP
	          tmpChaine:=regexp_substr(decompVirgule, '(.*?)(,{2,}|$)', 1, k, '', 1);
	          EXIT WHEN tmpChaine IS NULL;

	          IF k=1 THEN
	            id := tmpChaine;
	          ELSIF k=2 THEN
	            valeur:=tmpChaine;
	          END IF;
	          k:=k+1;
	        END LOOP;
	        	
	        BEGIN
	        	newLangue := PACKAGECB.verif_langue_fields(id, valeur);
		        insert into langue values newLangue;
		        insert into film_langue values (newFilm.id, newLangue.id);
		    EXCEPTION
		        WHEN OTHERS THEN LOGEVENT('inserer langue', 'TUPLE REJETE : ' ||SQLERRM);
		    END;

	        j := j +1;
		end loop;

		j:=1;
		--REALISATEUR
		chaine := regexp_substr(s.directors, '^\[\[(.*)\]\]$', 1, 1, '', 1);
		loop
			decompVirgule := regexp_substr(chaine, '(.*?)(\|\||$)', 1, j, '', 1);
	        exit when decompVirgule is null;

	        k:=1;
	        LOOP
	          tmpChaine:=regexp_substr(decompVirgule, '(.*?)(,{2,}|$)', 1, k, '', 1);
	          EXIT WHEN tmpChaine IS NULL;

	          IF k=1 THEN
	            id := tmpChaine;
	          ELSIF k=2 THEN
	            valeur:=tmpChaine;
	          ELSIF k=3 THEN
	            image:=tmpChaine;
	          END IF;
	          k:=k+1;
	        END LOOP;
	        BEGIN
	        	newPersonne := PACKAGECB.verif_personne_fields(TO_NUMBER(id), valeur, image);
		        insert into personne values newPersonne;
		        insert into EST_REALISATEUR values (newFilm.id, newPersonne.id);
		    EXCEPTION
		        WHEN OTHERS THEN LOGEVENT('inserer realisateur', 'TUPLE REJETE : ' ||SQLERRM);
		    END;

	        j := j +1;
		end loop;

		dbms_output.put_line(s.actors);
		j:=1;
		--ACTEUR
		chaine := regexp_substr(s.actors, '^\[\[(.*)\]\]$', 1, 1, '', 1);
		loop
			decompVirgule := regexp_substr(chaine, '(.*?)(\|\||$)', 1, j, '', 1);
	        exit when decompVirgule is null;

	        k:=1;
	        LOOP
	          tmpChaine:=regexp_substr(decompVirgule, '(.*?)(,{2,}|$)', 1, k, '', 1);
	          EXIT WHEN tmpChaine IS NULL;

	          IF k=1 THEN
	            id := tmpChaine;
	          ELSIF k=2 THEN
	            valeur:=tmpChaine;
	          ELSIF k=3 THEN
	            id_role:=tmpChaine;
	          ELSIF k=4 THEN
	            nom_role:=tmpChaine;
	          ELSIF k=5 THEN
	            image:=tmpChaine;
	          END IF;
	          k:=k+1;
	        END LOOP;
	        
	        BEGIN
		        newPersonne := PACKAGECB.verif_personne_fields(TO_NUMBER(id), valeur, image);
		        newRole := PACKAGECB.verif_role_fields(TO_NUMBER(id_role), newFilm.id, nom_role);
		        insert into personne values newPersonne;
		        insert into role values newRole;
		        insert into personne_role values (newPersonne.id, newRole.FILM_ASSOCIE, newRole.id);
		    EXCEPTION
		        WHEN OTHERS THEN LOGEVENT('inserer acteur', 'TUPLE REJETE : ' ||SQLERRM);
		    END;
		    j := j+1;
		end loop;
		i := i+1;
	COMMIT;
	end loop;
EXCEPTION

	WHEN OTHERS THEN ROLLBACK; RAISE;

END;
