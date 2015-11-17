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

	i number := 0;
	j number := 1;
	k number;

	nbrCopie number;

  	chaine varchar2(4000);
  	decompVirgule varchar2(4000);
  	idImage number;
  	lienImage varchar2(4000);
  	tmpChaine varchar2(4000);

  	found boolean;
  	res owa_text.vc_arr;
  	movieExist NUMBER;
  	flag boolean;
  	lastNbrCopy number;
BEGIN
	--faire autrement
	--order by dbms_random.value
	FOR s IN (select * from movies_ext WHERE rownum = 1)
	LOOP
		EXIT WHEN i >= nombreAjout;

		nbrCopie := FLOOR(dbms_random.normal * 2 + 5);
		movieExist := 0;
		lastNbrCopy := 0;
		flag := false;
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
				SELECT nbr_copie INTO lastNbrCopy FROM film WHERE id = s.id;
				nbrCopie := nbrCopie + lastNbrCopy;
				UPDATE film SET nbr_copie = nbrCopie WHERE id = s.id;
			EXCEPTION
				WHEN OTHERS THEN LOGEVENT('UPDATE nbr_copie', 'ERREUR FILM '||s.id||' : ' ||SQLERRM);
			END;
			i:=i+1;
			flag := true;
		--Le film n'existe pas
		ELSIF movieExist = 0 THEN
			IF LENGTH(s.poster_path) > 0 THEN --Il a un poster
				LOGEVENT('Ajout poster', 'Ajout d''un poster');
				idImage := IDAFFICHE.NEXTVAL;
				lienImage := 'http://image.tmdb.org/t/p/w185'||s.poster_path;

				BEGIN
					insert into affiche values(idImage, httpuritype(lienImage).getblob());
					UPDATE film SET affiche = idImage WHERE id = s.id;
				EXCEPTION
					WHEN OTHERS THEN
						LOGEVENT('Ajout affiche', 'ERREUR AFFICHE FILM '|| s.id||' REJETE  : ' ||SQLERRM);
				END;
			END IF;
		END IF;

		--INSERTION DES NOUVELLES COPIES DE FILM
		k:=lastNbrCopy;

		LOOP
			k:= k+1;
			BEGIN
		        insert into film_copie values (s.id, k);
		    EXCEPTION
		    	WHEN dup_val_on_index THEN LOGEVENT('Insertion film_copie', 'Doublon dans les copies');
		    	WHEN OTHERS THEN LOGEVENT('insertion film_copie', 'TUPLE REJETE : ' ||SQLERRM);
		    END;

		    EXIT WHEN k >= nbrCopie;
		END LOOP;

		IF flag THEN
			COMMIT;
			CONTINUE;
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
	          --récupération des valeurs
	          IF k=1 THEN
	            id := tmpChaine;
	          ELSIF k=2 THEN
	            valeur:=tmpChaine;
	          END IF;
	          k:=k+1;
	        END LOOP;
	        
	        BEGIN
	        	newGenre := PACKAGECB.verif_genre_fields(TO_NUMBER(id), valeur);
		        insert into genre values newGenre;
		    EXCEPTION
		    	WHEN dup_val_on_index THEN LOGEVENT('Insertion genre', 'Le genre '||valeur||' existe déjà');
		    	WHEN OTHERS THEN LOGEVENT('insertion genre', 'TUPLE REJETE : ' ||SQLERRM);
		    END;

		    BEGIN
		    	insert into film_genre values (newFilm.id, newGenre.id);
		    EXCEPTION
		    	WHEN OTHERS THEN LOGEVENT('insertion film_genre', 'TUPLE REJETE : ' ||SQLERRM);
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
		    EXCEPTION
		    	WHEN dup_val_on_index THEN LOGEVENT('Insertion producteur', 'Le producteur '||valeur||' existe déjà');
		        WHEN OTHERS THEN LOGEVENT('insérer producteur', 'TUPLE REJETE : ' ||SQLERRM);
		    END;

		    BEGIN
		    	insert into film_producteur values (newFilm.id, newProducteur.id);
		    EXCEPTION
		    	WHEN OTHERS THEN LOGEVENT('insertion film_producteur', 'TUPLE REJETE : ' ||SQLERRM);
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
		    EXCEPTION
		    	WHEN dup_val_on_index THEN LOGEVENT('Insertion pays', 'Le pays '||valeur||' existe déjà');
		       	WHEN OTHERS THEN LOGEVENT('inserer pays', 'TUPLE REJETE : ' ||SQLERRM);
		    END;

		    BEGIN
		    	insert into film_pays values (newFilm.id, newPays.id);
		    EXCEPTION
		    	WHEN OTHERS THEN LOGEVENT('insertion film_pays', 'TUPLE REJETE : ' ||SQLERRM);
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
		    EXCEPTION
		    	WHEN dup_val_on_index THEN LOGEVENT('Insertion langue', 'La langue '||valeur||' existe déjà');
		        WHEN OTHERS THEN LOGEVENT('inserer langue', 'TUPLE REJETE : ' ||SQLERRM);
		    END;

		    BEGIN
		    	insert into film_langue values (newFilm.id, newLangue.id);
		    EXCEPTION
		    	WHEN OTHERS THEN LOGEVENT('insertion film_pays', 'TUPLE REJETE : ' ||SQLERRM);
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
		    EXCEPTION
		    	WHEN dup_val_on_index THEN LOGEVENT('Insertion realisateur', 'Le realisateur '||valeur||' existe déjà');
		        WHEN OTHERS THEN LOGEVENT('inserer realisateur', 'TUPLE REJETE : ' ||SQLERRM);
		    END;

		    BEGIN
		    	insert into EST_REALISATEUR values (newFilm.id, newPersonne.id);
		    EXCEPTION
		    	WHEN OTHERS THEN LOGEVENT('insertion est_realisateur', 'TUPLE REJETE : ' ||SQLERRM);
		    END;

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

	        	flag := true;

	            BEGIN
			        newPersonne := PACKAGECB.verif_personne_fields(TO_NUMBER(res(1)), res(2), res(5));
			        insert into personne values newPersonne;
			    EXCEPTION
			    	WHEN dup_val_on_index THEN LOGEVENT('Insertion acteur', 'L''acteur '||valeur||' existe déjà');
			        WHEN OTHERS THEN 
			        	LOGEVENT('inserer acteur', 'TUPLE REJETE : ' ||SQLERRM);
			        	flag := false;
			    END;

			    IF flag THEN
				    BEGIN
				    	newRole := PACKAGECB.verif_role_fields(TO_NUMBER(res(3)), newFilm.id, res(4));
			    		insert into role values newRole;
				    EXCEPTION
				    	WHEN OTHERS THEN 
				    		LOGEVENT('insertion est_realisateur', 'TUPLE REJETE : ' ||SQLERRM);
				    		flag := false;
				    END;

				    IF flag THEN
					    BEGIN
				    		insert into personne_role values (newPersonne.id, newRole.FILM_ASSOCIE, newRole.id);
					    EXCEPTION
					    	WHEN OTHERS THEN LOGEVENT('insertion est_realisateur', 'TUPLE REJETE : ' ||SQLERRM);
					    END;
					END IF;
				END IF;
	        end if;
		    j := j+1;
		end loop;
		i := i+1;
		COMMIT;
	END LOOP;
EXCEPTION
	WHEN OTHERS THEN ROLLBACK; RAISE;
END;
/
EXIT;
