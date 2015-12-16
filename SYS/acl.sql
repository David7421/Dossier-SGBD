

BEGIN
  
  BEGIN
    DBMS_NETWORK_ACL_ADMIN.drop_acl('http.xml');
  EXCEPTION
    WHEN OTHERS THEN DBMS_OUTPUT.PUT_LINE('ACL not exist');
  END;

  --Creation de l'ACL
  DBMS_NETWORK_ACL_ADMIN.CREATE_ACL(acl         => 'http.xml', --Nom de l'ACL dans la BDD
                                    description => 'WWW ACL', 
                                    principal   => 'CB', --Nom de l'utilisateur associé à cette ACL
                                    is_grant    => true,
                                    privilege   => 'resolve');
 
  DBMS_NETWORK_ACL_ADMIN.ADD_PRIVILEGE(acl       => 'http.xml',
                                       principal => 'CB',
                                       is_grant  => true,
                                       privilege => 'connect'); --Ajout du privilege de connection à un site web
 
  DBMS_NETWORK_ACL_ADMIN.ASSIGN_ACL(acl  => 'http.xml',
                                    host => '*'); -- Adresse du site autorisé (* = tous)
END;
/
COMMIT;
