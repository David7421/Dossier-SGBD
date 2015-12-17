INSERT INTO filmSchema VALUES (XMLTYPE.CREATEXML('<?xml version="1.0" encoding="UTF-8"?>
<film>
    <id_film>4848</id_film>
    <titre>incption</titre>
    <titre_original>inception</titre_original>
    <date_sortie>2012/10/12</date_sortie>
    <status>RELEASED</status>
    <note_moyenne>5</note_moyenne>
    <nbr_note>250</nbr_note>
    <runtime>120</runtime>
    <certification>BIDON</certification>
    <!--<affiche>testificateclob</affiche>-->
    <budget>20000</budget>
    <revenus>3000</revenus>
    <homepage>http://me.be</homepage>
    <tagline>un bon film</tagline>
    <overview>un bon film qui parle de reve</overview>
    
    <genres>
        <genre>
            <id_genre>2</id_genre>
            <nom>action</nom>
        </genre>
    </genres>
    
    <producteurs>
        <producteur>
            <id_producteur>1</id_producteur>
            <nom>ankama</nom>
        </producteur>
    </producteurs>
    
    <langues>
        <langue>
            <id_langue>be</id_langue>
            <nom>belge</nom>
        </langue>
    </langues>
    
    
    <listPays>
        <pays>
            <id_pays>fr</id_pays>
            <nom>france</nom>
        </pays>
    </listPays>
    
    <acteurs>
        <acteur>
            <id_acteur>465</id_acteur>
            <nom>john hurt</nom>
            <lien_photo>/hggjufsufdsf</lien_photo>
            <nom_role>dr who</nom_role>
        </acteur>
    </acteurs>
    
    <realisateurs>
        <realisateur>
            <id_realisateur>545</id_realisateur>
            <nom>Quentin Tarantino</nom>
            <lien_photo>/gjhdgdggdusd</lien_photo>
        </realisateur>
    </realisateurs>
    
    <listAvis>
        <avis>
            <note>56</note>
            <commentaire>fgugdyudfgfdgufdgudfgufdgufgyugduf</commentaire>
        </avis>
    </listAvis>
</film>'
));

select EXTRACTVALUE(OBJECT_VALUE,'copie/idFilm'), EXTRACTVALUE(OBJECT_VALUE,'copie/numCopy')  FROM COPIEFILM;

select EXTRACTVALUE(OBJECT_VALUE,'programmation/idFilm'), EXTRACTVALUE(OBJECT_VALUE,'programmation/numCopy')  FROM PROGRAMMATION;


INSERT INTO COPIEFILM VALUES (XMLTYPE.CREATEXML('<?xml version="1.0" encoding="UTF-8"?>
<copie>
    <idFilm>4848</idFilm>
    <numCopy>1</numCopy>
</copie>'
));




INSERT INTO PROGRAMMATION VALUES (XMLTYPE.CREATEXML('<?xml version="1.0" encoding="UTF-8"?>
<programmation>
    <idFilm>4848</idFilm>
    <numCopy>3</numCopy>
    <debut>11/12/15 18:00:00,000000000</debut>
    <fin>11/12/15 18:00:00,000000000</fin>
    <salle>2</salle>
    <nbrSpectateurs>68</nbrSpectateurs>
    <nbrPlaces>100</nbrPlaces>
</programmation>'
));



SELECT s.inst_id,
s.sid,
s.serial#,
p.spid,
s.username,
s.program
FROM gv$session s
JOIN gv$process p ON p.addr = s.paddr AND p.inst_id = s.inst_id
WHERE s.type != 'BACKGROUND ';

ALTER SYSTEM DISCONNECT SESSION '65,253' IMMEDIATE;

ALTER USER cb LOCK ACCOUNT;

