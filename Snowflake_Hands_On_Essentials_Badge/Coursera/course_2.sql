SELECT MENU_ITEM_NAME
    , MENU_ITEM_HEALTH_METRICS_OBJ
FROM tasty_bytes.RAW_POS.MENU;

DESCRIBE TABLE tasty_bytes.RAW_POS.MENU;

---> create the test_menu table with just a variant column in it, as a test
CREATE TABLE tasty_bytes.RAW_POS.TEST_MENU (cost_of_goods_variant)
AS SELECT cost_of_goods_usd::VARIANT
FROM tasty_bytes.RAW_POS.MENU;

---> notice that the column is of the VARIANT type
DESCRIBE TABLE tasty_bytes.RAW_POS.TEST_MENU;

---> but the typeof() function reveals the underlying data type
SELECT TYPEOF(cost_of_goods_variant) FROM tasty_bytes.raw_pos.test_menu;

---> Snowflake lets you perform operations based on the underlying data type
SELECT cost_of_goods_variant, cost_of_goods_variant*2.0 FROM tasty_bytes.raw_pos.test_menu;

DROP TABLE tasty_bytes.raw_pos.test_menu;

---> you can use the colon to pull out info from menu_item_health_metrics_obj
SELECT MENU_ITEM_HEALTH_METRICS_OBJ:menu_item_health_metrics FROM tasty_bytes.raw_pos.menu;

---> use typeof() to see the underlying type
SELECT TYPEOF(MENU_ITEM_HEALTH_METRICS_OBJ) FROM tasty_bytes.raw_pos.menu;

SELECT MENU_ITEM_HEALTH_METRICS_OBJ, MENU_ITEM_HEALTH_METRICS_OBJ['menu_item_id'] FROM tasty_bytes.raw_pos.menu;

SELECT MENU_ITEM_HEALTH_METRICS_OBJ['menu_item_health_metrics'] FROM tasty_bytes.raw_pos.menu;

CREATE TABLE TASTY_BYTES.RAW_POS.TEST_MENU1(ingredients)
AS SELECT MENU_ITEM_HEALTH_METRICS_OBJ 
FROM tasty_bytes.raw_pos.menu;

select *
from TASTY_BYTES.RAW_POS.TEST_MENU1;

describe table TASTY_BYTES.RAW_POS.TEST_MENU1;

select typeof(ingredients) from TASTY_BYTES.RAW_POS.TEST_MENU1;
-- from above can see the type is an object so use the follwoing code to get one layer deeper

create table TASTY_BYTES.RAW_POS.TEST_MENU2(ingredients)
AS select MENU_ITEM_HEALTH_METRICS_OBJ['menu_item_health_metrics']
from tasty_bytes.raw_pos.menu;

select * from TASTY_BYTES.RAW_POS.TEST_MENU2;

select typeof(ingredients)from TASTY_BYTES.RAW_POS.TEST_MENU2;
-- Above shows it is an Array so need to use code below to get to it

create table TASTY_BYTES.RAW_POS.TEST_MENU3(ingredients)
AS select MENU_ITEM_HEALTH_METRICS_OBJ['menu_item_health_metrics'][0]
from tasty_bytes.raw_pos.menu;

select * from TASTY_BYTES.RAW_POS.TEST_MENU3;

select typeof(ingredients)from TASTY_BYTES.RAW_POS.TEST_MENU3;
-- Shows an OBJECT type so need to pull up the ingredient

create table TASTY_BYTES.RAW_POS.TEST_MENU4(ingredients)
AS select MENU_ITEM_HEALTH_METRICS_OBJ['menu_item_health_metrics'][0]['ingredients']
from tasty_bytes.raw_pos.menu;

select * from TASTY_BYTES.RAW_POS.TEST_MENU4;

select typeof(ingredients)from TASTY_BYTES.RAW_POS.TEST_MENU4;
-- LEFT with just an array of the actual ingredients

-- USe following to get first ingredient of every array in each row
create table TASTY_BYTES.RAW_POS.TEST_MENU5(ingredients)
AS select MENU_ITEM_HEALTH_METRICS_OBJ['menu_item_health_metrics'][0]['ingredients'][0]
from tasty_bytes.raw_pos.menu;

select * from TASTY_BYTES.RAW_POS.TEST_MENU5;

select typeof(ingredients)from TASTY_BYTES.RAW_POS.TEST_MENU5;
--in this case its a VARCHAR type

-- To pull it up without creating a new table
SELECT MENU_ITEM_HEALTH_METRICS_OBJ['menu_item_health_metrics'][0]['ingredients'][0]
from tasty_bytes.raw_pos.menu;

--OR
SELECT *
from tasty_bytes.raw_pos.menu m,
    LATERAL FLATTEN (input => m.MENU_ITEM_HEALTH_METRICS_OBJ:MENU_ITEM_HEALTH_METRICS;


DESCRIBE TABLE tasty_bytes.raw_pos.menu;

select typeof(MENU_ITEM_HEALTH_METRICS_OBJ) from tasty_bytes.raw_pos.menu;

SELECT MENU_ITEM_HEALTH_METRICS_OBJ['menu_item_health_metrics'][0]['ingredients'][0]
FROM tasty_bytes.raw_pos.menu
WHERE MENU_ITEM_NAME = 'Mango Sticky Rice';

-- Cloning
CREATE DATABASE tasty_bytes_clone
    CLONE tasty_bytes;

create table tasty_bytes.raw_pos.truck_clone
    clone tasty_bytes.raw_pos.truck;

SELECT * FROM TASTY_BYTES.INFORMATION_SCHEMA.TABLE_STORAGE_METRICS
WHERE (TABLE_NAME = 'TRUCK_CLONE' OR TABLE_NAME = 'TRUCK')
AND TABLE_CATALOG = 'TASTY_BYTES';

SHOW RESOURCE MONITORS;

CREATE RESOURCE MONITOR tasty_test_rm
WITH
    CREDIT_QUOTA = 15
    FREQUENCY = daily
    START_TIMESTAMP = immediately
    TRIGGERS
        ON 90 PERCENT DO NOTIFY;
        
SHOW RESOURCE MONITORS;

CREATE WAREHOUSE tasty_test_wh;
ALTER WAREHOUSE tasty_test_wh SET RESOURCE_MONITOR = tasty_test_rm;
SHOW RESOURCE MONITORS;

ALTER RESOURCE MONITOR tasty_test_rm
  SET CREDIT_QUOTA=20;

SHOW FUNCTIONS;

use database tasty_bytes;

create function min_menu_price()
    returns NUMBER(5,2)
    as
    $$
        SELECT MIN(SALE_PRICE_USD) FROM TASTY_BYTES.RAW_POS.MENU
    $$
;

SELECT min_menu_price();

create function menu_prices_below(price_ceiling NUMBER)
    returns table (item VARCHAR, price NUMBER)
    as
    $$
        SELECT MENU_ITEM_NAME, SALE_PRICE_USD
        FROM TASTY_BYTES.RAW_POS.MENU
        WHERE SALE_PRICE_USD < price_ceiling
        ORDER BY 2 DESC
    $$
;

select * from table(menu_prices_below(3));

use database tasty_bytes_clone;

CREATE OR REPLACE PROCEDURE increase_prices()
RETURNS BOOLEAN
LANGUAGE SQL
AS
$$
BEGIN
  UPDATE tasty_bytes_clone.raw_pos.menu
  SET SALE_PRICE_USD = menu.SALE_PRICE_USD + 1;
END;
$$
;

call increase_prices();

DESCRIBE PROCEDURE increase_prices();

show procedures;

CREATE PROCEDURE decrease_mango_sticky_rice_price()
RETURNS BOOLEAN
LANGUAGE SQL
AS
$$
BEGIN
  UPDATE tasty_bytes_clone.raw_pos.menu
  SET SALE_PRICE_USD = menu.SALE_PRICE_USD - 1
  WHERE MENU_ITEM_NAME = 'Mango Sticky Rice' ;
END;
$$
;

-- Roles
CREATE ROLE tasty_de;

SHOW GRANTS TO ROLE tasty_de;

SHOW GRANTS TO ROLE accountadmin;

GRANT ROLE tasty_de TO USER BIANCANIEMANN; 

USE ROLE tasty_de;

CREATE WAREHOUSE tasty_de_test2;

USE ROLE accountadmin;

GRANT CREATE WAREHOUSE ON ACCOUNT TO ROLE tasty_de;

CREATE WAREHOUSE tasty_de_test2;

SHOW GRANTS TO ROLE tasty_de; 

SHOW GRANTS TO ROLE securityadmin;

SHOW GRANTS TO ROLE useradmin;

SHOW GRANTS TO ROLE sysadmin;

SHOW GRANTS TO ROLE public;

CREATE ROLE tasty_role;

GRANT CREATE DATABASE ON ACCOUNT TO ROLE tasty_role;

SHOW GRANTS TO ROLE tasty_role;

SELECT CURRENT_USER;

GRANT ROLE tasty_role TO USER BIANCANIEMANN;

USE ROLE tasty_role;

CREATE WAREHOUSE tasty_test_wh;

USE ROLE ACCOUNTADMIN;

SHOW GRANTS TO USER BIANCANIEMANN;

SHOW GRANTS TO ROLE useradmin;

CREATE TABLE tasty_bytes.raw_pos.truck_dev
    CLONE tasty_bytes.raw_pos.truck;
SELECT * FROM tasty_bytes.raw_pos.truck_dev;
SET saved_query_id = LAST_QUERY_ID();
SET saved_timestamp = CURRENT_TIMESTAMP;
UPDATE tasty_bytes.raw_pos.truck_dev t
    SET t.year = (YEAR(CURRENT_DATE()) -1000);

show variables;

SELECT * FROM tasty_bytes.raw_pos.truck_dev
AT(TIMESTAMP => $saved_timestamp::TIMESTAMP_LTZ);

SELECT * FROM tasty_bytes.raw_pos.truck_dev
BEFORE(STATEMENT => $saved_query_id );

SELECT SNOWFLAKE.CORTEX.SUMMARIZE(SNOWFLAKE.CORTEX.COMPLETE(
    'mistral-7b', 'What kind of literature was Marianne Moore known for?'));

SELECT SNOWFLAKE.CORTEX.COMPLETE(
    'mistral-7b',
        CONCAT('Describe this food: ', menu_item_name)
) FROM FROSTBYTE_TASTY_BYTES.RAW_POS.MENU LIMIT 5;
