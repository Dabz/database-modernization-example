/*
 * CDCPrequisites.sql
 * Copyright (C) 2024 damiengasparina <>
 *
 * Distributed under terms of the MIT license.
 */

ALTER SESSION SET CONTAINER=cdb$root;
ALTER DATABASE ADD SUPPLEMENTAL LOG DATA (ALL) COLUMNS;

ALTER SESSION SET CONTAINER=CDB$ROOT;
CREATE ROLE C##CDC_PRIVS;
CREATE USER C##CDC IDENTIFIED BY password CONTAINER=ALL;
ALTER USER C##CDC QUOTA UNLIMITED ON USERS;
ALTER USER C##CDC SET CONTAINER_DATA = (CDB$ROOT, ORCLPDB1) CONTAINER=CURRENT;
GRANT C##CDC_PRIVS to C##CDC CONTAINER=ALL;

GRANT CONNECT TO C##CDC_PRIVS CONTAINER=ALL;
GRANT CREATE SESSION TO C##CDC_PRIVS CONTAINER=ALL;
GRANT LOGMINING TO C##CDC_PRIVS CONTAINER=ALL;

GRANT SELECT ON V_$DATABASE TO C##CDC_PRIVS CONTAINER=ALL;
GRANT SELECT ON V_$INSTANCE to C##CDC_PRIVS CONTAINER=ALL;
GRANT SELECT ON V_$THREAD TO C##CDC_PRIVS CONTAINER=ALL;
GRANT SELECT ON V_$PARAMETER TO C##CDC_PRIVS CONTAINER=ALL;
GRANT SELECT ON V_$NLS_PARAMETERS TO C##CDC_PRIVS CONTAINER=ALL;
GRANT SELECT ON V_$TIMEZONE_NAMES TO C##CDC_PRIVS CONTAINER=ALL;

GRANT SELECT ON DBA_PDBS TO C##CDC_PRIVS CONTAINER=ALL;
GRANT SELECT ON CDB_TABLES TO C##CDC_PRIVS CONTAINER=ALL;
GRANT SELECT ON CDB_TAB_PARTITIONS TO C##CDC_PRIVS CONTAINER=ALL;

ALTER SESSION SET CONTAINER=ORCLPDB1;
GRANT SELECT ANY TABLE TO C##CDC_PRIVS;

ALTER SESSION SET CONTAINER=CDB$ROOT;
GRANT SELECT ON V_$LOG TO C##CDC_PRIVS CONTAINER=ALL;
GRANT SELECT ON V_$LOGFILE TO C##CDC_PRIVS CONTAINER=ALL;
GRANT SELECT ON V_$LOGMNR_CONTENTS TO C##CDC_PRIVS CONTAINER=ALL;
GRANT SELECT ON V_$ARCHIVED_LOG TO C##CDC_PRIVS CONTAINER=ALL;
GRANT SELECT ON V_$ARCHIVE_DEST_STATUS TO CDC_PRIVS CONTAINER=ALL;

GRANT EXECUTE ON SYS.DBMS_LOGMNR TO C##CDC_PRIVS CONTAINER=ALL;
GRANT EXECUTE ON SYS.DBMS_LOGMNR_D TO C##CDC_PRIVS CONTAINER=ALL;


ALTER SESSION SET CONTAINER=ORCLPDB1;
GRANT FLASHBACK TO C##CDC;
GRANT FLASHBACK ANY TABLE TO C##CDC;
GRANT SELECT ANY TABLE TO C##CDC_PRIVS;

-- vim:et
