BEGIN
  PACKAGECB.AJOUTER_FILM(325,
    'azertyuiopqsdfghjklmwxcvbnazertyuiopqsdfghjklmdsqdqsdqsdtestificate',
    'testificate',
    to_date('03-OCT-88', 'DD-MON-YY'),
    'RUMORED',
    7,
    156,
    31,
    'blabla',
    'blabjifdssj',
    45464,
    456,
    'dfjksfhdfs',
    'ffhdjsnfj',
    'fdsfqsdfdsqfs');
EXCEPTION
  WHEN OTHERS THEN DBMS_OUTPUT.PUT_LINE(SQLERRM);
END;