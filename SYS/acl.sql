BEGIN
  DBMS_NETWORK_ACL_ADMIN.CREATE_ACL(acl         => 'http_permission.xml',
                                    description => 'WWW ACL',
                                    principal   => 'CB',
                                    is_grant    => true,
                                    privilege   => 'connect');
 
  DBMS_NETWORK_ACL_ADMIN.ADD_PRIVILEGE(acl       => 'http_permission.xml',
                                       principal => 'CB',
                                       is_grant  => true,
                                       privilege => 'resolve');
 
  DBMS_NETWORK_ACL_ADMIN.ASSIGN_ACL(acl  => 'http_permission.xml',
                                    host => 'image.tmdb.org');
END;
/
COMMIT;

EXIT;
