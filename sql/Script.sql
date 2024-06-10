CREATE USER SALES IDENTIFIED BY password;
GRANT UNLIMITED TABLESPACE TO SALES;
ALTER USER SALES quota unlimited on USERS;

ALTER SESSION SET CONTAINER=ORCLPDB1;
ALTER SESSION SET current_schema = SALES;

CREATE SEQUENCE SALES_SEQ
 START WITH     1
 INCREMENT BY   1
 NOCACHE
 NOCYCLE;


CREATE TABLE CHANNELS 
    ( 
     CHANNEL_ID NUMBER  NOT NULL , 
     CHANNEL_DESC VARCHAR2 (20 BYTE)  NOT NULL
    ); 
    
    
ALTER TABLE CHANNELS 
    ADD CONSTRAINT CHANNELS_PK PRIMARY KEY ( CHANNEL_ID ) NOVALIDATE ;

CREATE TABLE CUSTOMERS 
    ( 
     CUST_ID NUMBER  NOT NULL , 
     CUST_FIRST_NAME VARCHAR2 (20 BYTE)  NOT NULL , 
     CUST_LAST_NAME VARCHAR2 (40 BYTE)  NOT NULL , 
     CUST_EFF_FROM DATE , 
     CUST_EFF_TO DATE , 
     CUST_VALID VARCHAR2 (1 BYTE) 
    );
 
ALTER TABLE CUSTOMERS 
    ADD CONSTRAINT CUSTOMERS_PK PRIMARY KEY ( CUST_ID ) NOVALIDATE ;
   
   
 CREATE TABLE PRODUCTS 
    ( 
     PROD_ID NUMBER (6)  NOT NULL , 
     PROD_NAME VARCHAR2 (50 BYTE)  NOT NULL , 
     PROD_DESC VARCHAR2 (4000 BYTE)  NOT NULL , 
     PROD_EFF_FROM DATE , 
     PROD_EFF_TO DATE , 
     PROD_VALID VARCHAR2 (1 BYTE) 
    )
;  
 
ALTER TABLE PRODUCTS 
    ADD CONSTRAINT PRODUCTS_PK PRIMARY KEY ( PROD_ID ) NOVALIDATE ;
   
   
CREATE TABLE "SALES"
    ( 
     SALES_ID NUMBER (6) NOT NULL,
     PROD_ID NUMBER (6)  NOT NULL , 
     CUST_ID NUMBER  NOT NULL , 
     CHANNEL_ID NUMBER  NOT NULL , 
     PROMO_ID NUMBER (6)  NOT NULL , 
     QUANTITY_SOLD NUMBER (10,2)  NOT NULL , 
     AMOUNT_SOLD NUMBER (10,2)  NOT NULL 
    );
    
 ALTER TABLE SALES.SALES
    ADD CONSTRAINT SALES_PK PRIMARY KEY ( SALES_ID ) NOVALIDATE ;
    
CREATE TABLE PROMOTIONS 
    ( 
     PROMO_ID NUMBER (6)  NOT NULL , 
     PROMO_NAME VARCHAR2 (30 BYTE)  NOT NULL , 
     PROMO_TOTAL VARCHAR2 (15 BYTE)  NOT NULL , 
     PROMO_TOTAL_ID NUMBER  NOT NULL 
    ) LOGGING 
;


ALTER TABLE PROMOTIONS 
    ADD CONSTRAINT PROMO_PK PRIMARY KEY ( PROMO_ID ) NOVALIDATE ;


CREATE OR REPLACE PROCEDURE POPULATE_DATA_PKG AS 
BEGIN 
	
	INSERT INTO SALES.CUSTOMERS (
	    CUST_ID, 
     	CUST_FIRST_NAME, 
     	CUST_LAST_NAME, 
     	CUST_EFF_FROM, 
     	CUST_EFF_TO, 
     	CUST_VALID)
     VALUES (
     	0,
     	'Damien',
     	'Gasparina',
     	SYSDATE,
     	'',
     	'A'
     );
     
     INSERT INTO SALES.CUSTOMERS (
	    CUST_ID, 
     	CUST_FIRST_NAME, 
     	CUST_LAST_NAME, 
     	CUST_EFF_FROM, 
     	CUST_EFF_TO, 
     	CUST_VALID)
     VALUES (
     	1,
     	'Jon',
     	'Doe',
     	SYSDATE,
     	'',
     	'A'
     );
    
    INSERT INTO SALES.CHANNELS (
        CHANNEL_ID, 
     	CHANNEL_DESC)
     VALUES (
       0,
       'WEB'
     );
    
     INSERT INTO SALES.CHANNELS (
        CHANNEL_ID, 
     	CHANNEL_DESC)
     VALUES (
       1,
       'MARKETPLACE'
     );
     
    INSERT INTO SALES.PROMOTIONS (
        PROMO_ID, 
     	PROMO_NAME, 
     	PROMO_TOTAL, 
     	PROMO_TOTAL_ID)
     VALUES (
      	0,
      	'400$ free voucher',
      	'400',
      	'400'
     );
    
     INSERT INTO SALES.PRODUCTS (
    	PROD_ID, 
    	PROD_NAME, 
     	PROD_DESC, 
     	PROD_EFF_FROM, 
     	PROD_EFF_TO, 
     	PROD_VALID)
     VALUES (
        0,
        'ConfluentCloud',
        'Confluent Cloud, Stream data on any cloud, on any scale in minutes',
        SYSDATE ,
        '',
        'A'
     );
      
 END POPULATE_DATA_PKG;	  
/

 CREATE OR REPLACE PROCEDURE UPDATE_SALES AS 
 BEGIN 
	 INSERT INTO SALES.SALES ( 
     	SALES_ID,
     	PROD_ID, 
     	CUST_ID, 
     	CHANNEL_ID, 
     	PROMO_ID, 
     	QUANTITY_SOLD, 
     	AMOUNT_SOLD)
    VALUES (
    	SALES_SEQ.NEXTVAL,
    	0,
    	floor(dbms_random.value(1, 3)),
    	floor(dbms_random.value(1, 3)),
    	floor(dbms_random.value(0, 2)),
    	floor(dbms_random.value(1, 5000)),
    	floor(dbms_random.value(1, 50000))
    );
   
   UPDATE SALES.SALES SET AMOUNT_SOLD = AMOUNT_SOLD * 2 WHERE SALES_ID IN (
    SELECT SALES_ID FROM (
        SELECT SALES_ID FROM SALES.SALES ORDER BY dbms_random.value
    ) RNDM WHERE rownum < 2
   );
    
 END UPDATE_SALES;
/



CALL DBMS_SCHEDULER.CREATE_PROGRAM (
   program_name      => 'PROG_UPDATE_SALES',
   program_action    => 'UPDATE_SALES',
   program_type      => 'STORED_PROCEDURE');

CALL DBMS_SCHEDULER.CREATE_SCHEDULE (
 schedule_name   => 'UPDATE_SALES_5_SEC',
 start_date    => SYSTIMESTAMP,
 repeat_interval  => 'FREQ=SECONDLY; INTERVAL=10',
 comments     => 'Every 10 seconds');

CALL DBMS_SCHEDULER.CREATE_JOB (
  job_name     => 'UPDATE_SALES_JOB',
  program_name   => 'PROG_UPDATE_SALES',
  schedule_name   => 'UPDATE_SALES_5_SEC');

CALL dbms_scheduler.enable('PROG_UPDATE_SALES');
CALL dbms_scheduler.enable('UPDATE_SALES_JOB');



CALL SALES.POPULATE_DATA_PKG();


CALL  DBMS_SCHEDULER.CREATE_JOB (
   job_name           =>  'update_sales',
   job_type           =>  'STORED_PROCEDURE',
   job_action         =>  'SALES.UPDATE_SALES',
   repeat_interval    =>  'FREQ=SECOND;INTERVAL=10',
   auto_drop          =>   FALSE,
   job_class          =>  'batch_update_jobs',
   comments           =>  'Simulating updating and inserting rows');
  

