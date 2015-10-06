
sqlplus / as sysdba @Sys/CreateUsers.sql
sqlplus / as sysdba @Sys/CreaDirectory.sql

sqlplus CB/CB@localhost:1521/xe @CB/CreaCBLight.sql
sqlplus CB/CB@localhost:1521/xe @CB/CreateLogTable.sql
sqlplus CB/CB@localhost:1521/xe @CB/CreaExternalTable.sql

sqlplus CBB/CBB@localhost:1521/xe @CBB/CreaCBLight.sql
sqlplus CBB/CBB@localhost:1521/xe @CBB/CreateLogTable.sql

sqlplus CB/CB@localhost:1521/xe @CB/BackupCBLightTriggerCB.sql

sqlplus CBB/CBB@localhost:1521/xe @CBB/BackupCBLightTriggerCBB.sql
sqlplus CBB/CBB@localhost:1521/xe @CBB/ProcedureRestore.sql

sqlplus CB/CB@localhost:1521/xe @CB/ProcedureJob.sql
sqlplus CB/CB@localhost:1521/xe @CB/CereaJob.sql