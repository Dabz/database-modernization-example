#! /bin/sh

set -e

cat sql/CDCPrequisites.sql   | docker exec   -i database-modernization-oracle-1 sqlplus 'sys/password' as sysdba
cat sql/Script.sql           | docker exec   -i database-modernization-oracle-1 sqlplus 'sys/password@localhost:1521/ORCLPDB1' as sysdba
