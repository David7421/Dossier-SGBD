echo SYS

sqlplus / as sysdba @Sys/scriptCreationSys.sql

echo CB1

sqlplus CB/CB@localhost:1521/xe @CB/ScriptCreationCB1.sql

echo CBB1

sqlplus CBB/CBB@localhost:1521/xe @CBB/ScriptCreationCBB1.sql

echo CB2

sqlplus CB/CB@localhost:1521/xe @CB/ScriptCreationCB2.sql

echo CBB2

sqlplus CBB/CBB@localhost:1521/xe @CBB/ScriptCreationCBB2.sql

echo CC1

sqlplus CC/CC@localhost:1521/xe @CC/ScriptCreationCC1.sql

echo CB3

sqlplus CB/CB@localhost:1521/xe @CB/ScriptCreationCB3.sql

echo CBB3

sqlplus CBB/CBB@localhost:1521/xe @CBB/ScriptCreationCBB3.sql

echo CC2

sqlplus CC/CC@localhost:1521/xe @CC/ScriptCreationCC2.sql

echo CB4

sqlplus CB/CB@localhost:1521/xe @CB/ScriptCreationCB4.sql


echo MKT1

sqlplus MKT/MKT@localhost:1521/xe @MKT/ScriptCreationMKT1.sql

echo DW1

sqlplus DW/DW@localhost:1521/xe @DW/ScriptCreationDw1.sql


echo INSTALLATION TERMINEE

pause