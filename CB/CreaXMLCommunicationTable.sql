CREATE TABLE tmpXMLMovie (xml_col XMLType)
  XMLTYPE xml_col STORE AS BINARY XML;

CREATE TABLE tmpXMLCopy (xml_col XMLType)
  XMLTYPE xml_col STORE AS BINARY XML;

COMMIT;
