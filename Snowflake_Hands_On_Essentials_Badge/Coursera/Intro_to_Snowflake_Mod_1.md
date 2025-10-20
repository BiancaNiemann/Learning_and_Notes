## Some code to read through
- cmd + shift + ? will bring up a list of shortcuts

### Module 1
```sql
---> set the Role
USE ROLE accountadmin;

---> set the Warehouse
USE WAREHOUSE compute_wh;

---> create the Tasty Bytes Database
CREATE OR REPLACE DATABASE tasty_bytes_sample_data;

---> create the Raw POS (Point-of-Sale) Schema
CREATE OR REPLACE SCHEMA tasty_bytes_sample_data.raw_pos;

---> create the Raw Menu Table
CREATE OR REPLACE TABLE tasty_bytes_sample_data.raw_pos.menu
(
    menu_id NUMBER(19,0),
    menu_type_id NUMBER(38,0),
    menu_type VARCHAR(16777216),
    truck_brand_name VARCHAR(16777216),
    menu_item_id NUMBER(38,0),
    menu_item_name VARCHAR(16777216),
    item_category VARCHAR(16777216),
    item_subcategory VARCHAR(16777216),
    cost_of_goods_usd NUMBER(38,4),
    sale_price_usd NUMBER(38,4),
    menu_item_health_metrics_obj VARIANT
);

---> confirm the empty Menu table exists
SELECT * FROM tasty_bytes_sample_data.raw_pos.menu;

---> create the Stage referencing the Blob location and CSV File Format
CREATE OR REPLACE STAGE tasty_bytes_sample_data.public.blob_stage
url = 's3://sfquickstarts/tastybytes/'
file_format = (type = csv);

---> query the Stage to find the Menu CSV file
LIST @tasty_bytes_sample_data.public.blob_stage/raw_pos/menu/;

---> copy the Menu file into the Menu table
COPY INTO tasty_bytes_sample_data.raw_pos.menu
FROM @tasty_bytes_sample_data.public.blob_stage/raw_pos/menu/;

---> how many rows are in the table?
SELECT COUNT(*) AS row_count FROM tasty_bytes_sample_data.raw_pos.menu;

---> what do the top 10 rows look like?
SELECT TOP 10 * FROM tasty_bytes_sample_data.raw_pos.menu;

SELECT TRUCK_BRAND_NAME, COUNT(*)
FROM tasty_bytes_sample_data.raw_pos.menu
GROUP BY 1
ORDER BY 2 DESC;
SELECT
    TRUCK_BRAND_NAME,
    MENU_TYPE,
    COUNT(*)
FROM tasty_bytes_sample_data.raw_pos.menu
GROUP BY 1,2
ORDER BY 3 DESC;

CREATE WAREHOUSE give_name; -- will create as XS

SHOW WAREHOUSES;

USE WAREHOUSE another_wh;

---> set warehouse size to medium
ALTER WAREHOUSE warehouse_dash SET warehouse_size=MEDIUM;

USE WAREHOUSE warehouse_dash;

SELECT
    menu_item_name,
   (sale_price_usd - cost_of_goods_usd) AS profit_usd
FROM tasty_bytes_sample_data.raw_pos.menu
ORDER BY 2 DESC;

---> set warehouse size to xsmall
ALTER WAREHOUSE warehouse_dash SET warehouse_size=XSMALL;

---> drop warehouse
DROP WAREHOUSE warehouse_vino;

SHOW WAREHOUSES;

---> create a multi-cluster warehouse (max clusters = 3)
CREATE WAREHOUSE warehouse_vino MAX_CLUSTER_COUNT = 3;

SHOW WAREHOUSES;

---> set the auto_suspend and auto_resume parameters
ALTER WAREHOUSE warehouse_dash SET AUTO_SUSPEND = 180 AUTO_RESUME = FALSE;

SHOW WAREHOUSES;

---> create raw_customer schema
CREATE OR REPLACE SCHEMA tasty_bytes.raw_customer;

---> create harmonized schema
CREATE OR REPLACE SCHEMA tasty_bytes.harmonized;

---> create analytics schema
CREATE OR REPLACE SCHEMA tasty_bytes.analytics;

---> create warehouses
CREATE OR REPLACE WAREHOUSE demo_build_wh
    WAREHOUSE_SIZE = 'xxxlarge'
    WAREHOUSE_TYPE = 'standard'
    AUTO_SUSPEND = 60
    AUTO_RESUME = TRUE
    INITIALLY_SUSPENDED = TRUE
COMMENT = 'demo build warehouse for tasty bytes assets';
    
CREATE OR REPLACE WAREHOUSE tasty_de_wh
    WAREHOUSE_SIZE = 'xsmall'
    WAREHOUSE_TYPE = 'standard'
    AUTO_SUSPEND = 60
    AUTO_RESUME = TRUE
    INITIALLY_SUSPENDED = TRUE
COMMENT = 'data engineering warehouse for tasty bytes';

USE WAREHOUSE tasty_de_wh;

---> file format creation
CREATE OR REPLACE FILE FORMAT tasty_bytes.public.csv_ff 
type = 'csv';

---> stage creation
CREATE OR REPLACE STAGE tasty_bytes.public.s3load
url = 's3://sfquickstarts/frostbyte_tastybytes/'
file_format = tasty_bytes.public.csv_ff;
---> example of creating an internal stage
-- CREATE OR REPLACE STAGE tasty_bytes.public.internal_stage_test;

---> list files in stage
ls @tasty_bytes.public.s3load;

---> country table build
CREATE OR REPLACE TABLE tasty_bytes.raw_pos.country
(
    country_id NUMBER(18,0),
    country VARCHAR(16777216),
    iso_currency VARCHAR(3),
    iso_country VARCHAR(2),
    city_id NUMBER(19,0),
    city VARCHAR(16777216),
    city_population VARCHAR(16777216)
);

---> franchise table build
CREATE OR REPLACE TABLE tasty_bytes.raw_pos.franchise 
(
    franchise_id NUMBER(38,0),
    first_name VARCHAR(16777216),
    last_name VARCHAR(16777216),
    city VARCHAR(16777216),
    country VARCHAR(16777216),
    e_mail VARCHAR(16777216),
    phone_number VARCHAR(16777216) 
);

---> location table build
CREATE OR REPLACE TABLE tasty_bytes.raw_pos.location
(
    location_id NUMBER(19,0),
    placekey VARCHAR(16777216),
    location VARCHAR(16777216),
    city VARCHAR(16777216),
    region VARCHAR(16777216),
    iso_country_code VARCHAR(16777216),
    country VARCHAR(16777216)
);

---> menu table build
CREATE OR REPLACE TABLE tasty_bytes.raw_pos.menu
(
    menu_id NUMBER(19,0),
    menu_type_id NUMBER(38,0),
    menu_type VARCHAR(16777216),
    truck_brand_name VARCHAR(16777216),
    menu_item_id NUMBER(38,0),
    menu_item_name VARCHAR(16777216),
    item_category VARCHAR(16777216),
    item_subcategory VARCHAR(16777216),
    cost_of_goods_usd NUMBER(38,4),
    sale_price_usd NUMBER(38,4),
    menu_item_health_metrics_obj VARIANT
);

---> truck table build 
CREATE OR REPLACE TABLE tasty_bytes.raw_pos.truck
(
    truck_id NUMBER(38,0),
    menu_type_id NUMBER(38,0),
    primary_city VARCHAR(16777216),
    region VARCHAR(16777216),
    iso_region VARCHAR(16777216),
    country VARCHAR(16777216),
    iso_country_code VARCHAR(16777216),
    franchise_flag NUMBER(38,0),
    year NUMBER(38,0),
    make VARCHAR(16777216),
    model VARCHAR(16777216),
    ev_flag NUMBER(38,0),
    franchise_id NUMBER(38,0),
    truck_opening_date DATE
);

---> order_header table build
CREATE OR REPLACE TABLE tasty_bytes.raw_pos.order_header
(
    order_id NUMBER(38,0),
    truck_id NUMBER(38,0),
    location_id FLOAT,
    customer_id NUMBER(38,0),
    discount_id VARCHAR(16777216),
    shift_id NUMBER(38,0),
    shift_start_time TIME(9),
    shift_end_time TIME(9),
    order_channel VARCHAR(16777216),
    order_ts TIMESTAMP_NTZ(9),
    served_ts VARCHAR(16777216),
    order_currency VARCHAR(3),
    order_amount NUMBER(38,4),
    order_tax_amount VARCHAR(16777216),
    order_discount_amount VARCHAR(16777216),
    order_total NUMBER(38,4)
);

---> order_detail table build
CREATE OR REPLACE TABLE tasty_bytes.raw_pos.order_detail 
(
    order_detail_id NUMBER(38,0),
    order_id NUMBER(38,0),
    menu_item_id NUMBER(38,0),
    discount_id VARCHAR(16777216),
    line_number NUMBER(38,0),
    quantity NUMBER(5,0),
    unit_price NUMBER(38,4),
    price NUMBER(38,4),
    order_item_discount_amount VARCHAR(16777216)
);

---> customer loyalty table build
CREATE OR REPLACE TABLE tasty_bytes.raw_customer.customer_loyalty
(
    customer_id NUMBER(38,0),
    first_name VARCHAR(16777216),
    last_name VARCHAR(16777216),
    city VARCHAR(16777216),
    country VARCHAR(16777216),
    postal_code VARCHAR(16777216),
    preferred_language VARCHAR(16777216),
    gender VARCHAR(16777216),
    favourite_brand VARCHAR(16777216),
    marital_status VARCHAR(16777216),
    children_count VARCHAR(16777216),
    sign_up_date DATE,
    birthday_date DATE,
    e_mail VARCHAR(16777216),
    phone_number VARCHAR(16777216)
);

---> orders_v view
CREATE OR REPLACE VIEW tasty_bytes.harmonized.orders_v
    AS
SELECT 
    oh.order_id,
    oh.truck_id,
    oh.order_ts,
    od.order_detail_id,
    od.line_number,
    m.truck_brand_name,
    m.menu_type,
    t.primary_city,
    t.region,
    t.country,
    t.franchise_flag,
    t.franchise_id,
    f.first_name AS franchisee_first_name,
    f.last_name AS franchisee_last_name,
    l.location_id,
    cl.customer_id,
    cl.first_name,
    cl.last_name,
    cl.e_mail,
    cl.phone_number,
    cl.children_count,
    cl.gender,
    cl.marital_status,
    od.menu_item_id,
    m.menu_item_name,
    od.quantity,
    od.unit_price,
    od.price,
    oh.order_amount,
    oh.order_tax_amount,
    oh.order_discount_amount,
    oh.order_total
FROM tasty_bytes.raw_pos.order_detail od
JOIN tasty_bytes.raw_pos.order_header oh
    ON od.order_id = oh.order_id
JOIN tasty_bytes.raw_pos.truck t
    ON oh.truck_id = t.truck_id
JOIN tasty_bytes.raw_pos.menu m
    ON od.menu_item_id = m.menu_item_id
JOIN tasty_bytes.raw_pos.franchise f
    ON t.franchise_id = f.franchise_id
JOIN tasty_bytes.raw_pos.location l
    ON oh.location_id = l.location_id
LEFT JOIN tasty_bytes.raw_customer.customer_loyalty cl
    ON oh.customer_id = cl.customer_id;

---> loyalty_metrics_v view
CREATE OR REPLACE VIEW tasty_bytes.harmonized.customer_loyalty_metrics_v
    AS
SELECT 
    cl.customer_id,
    cl.city,
    cl.country,
    cl.first_name,
    cl.last_name,
    cl.phone_number,
    cl.e_mail,
    SUM(oh.order_total) AS total_sales,
    ARRAY_AGG(DISTINCT oh.location_id) AS visited_location_ids_array
FROM tasty_bytes.raw_customer.customer_loyalty cl
JOIN tasty_bytes.raw_pos.order_header oh
ON cl.customer_id = oh.customer_id
GROUP BY cl.customer_id, cl.city, cl.country, cl.first_name,
cl.last_name, cl.phone_number, cl.e_mail;

---> orders_v view
CREATE OR REPLACE VIEW tasty_bytes.analytics.orders_v
COMMENT = 'Tasty Bytes Order Detail View'
    AS
SELECT DATE(o.order_ts) AS date, * FROM tasty_bytes.harmonized.orders_v o;

---> customer_loyalty_metrics_v view
CREATE OR REPLACE VIEW tasty_bytes.analytics.customer_loyalty_metrics_v
COMMENT = 'Tasty Bytes Customer Loyalty Member Metrics View'
    AS
SELECT * FROM tasty_bytes.harmonized.customer_loyalty_metrics_v;

USE WAREHOUSE demo_build_wh;

---> country table load
COPY INTO tasty_bytes.raw_pos.country
FROM @tasty_bytes.public.s3load/raw_pos/country/;

---> franchise table load
COPY INTO tasty_bytes.raw_pos.franchise
FROM @tasty_bytes.public.s3load/raw_pos/franchise/;

---> location table load
COPY INTO tasty_bytes.raw_pos.location
FROM @tasty_bytes.public.s3load/raw_pos/location/;

---> menu table load
COPY INTO tasty_bytes.raw_pos.menu
FROM @tasty_bytes.public.s3load/raw_pos/menu/;

---> truck table load
COPY INTO tasty_bytes.raw_pos.truck
FROM @tasty_bytes.public.s3load/raw_pos/truck/;

---> customer_loyalty table load
COPY INTO tasty_bytes.raw_customer.customer_loyalty
FROM @tasty_bytes.public.s3load/raw_customer/customer_loyalty/;

---> order_header table load
COPY INTO tasty_bytes.raw_pos.order_header
FROM @tasty_bytes.public.s3load/raw_pos/order_header/;

---> order_detail table load
COPY INTO tasty_bytes.raw_pos.order_detail
FROM @tasty_bytes.public.s3load/raw_pos/order_detail/;

---> drop demo_build_wh
DROP WAREHOUSE IF EXISTS demo_build_wh;

USE WAREHOUSE TASTY_DE_WH;

SELECT file_name, error_count, status, last_load_time FROM snowflake.account_usage.copy_history
  ORDER BY last_load_time DESC
  LIMIT 10;

SELECT * FROM RAW_POS.MENU;

---> see table metadata
SELECT * FROM TASTY_BYTES.INFORMATION_SCHEMA.TABLES;

---> create a test database
CREATE DATABASE test_database;

SHOW DATABASES;

---> drop the database
DROP DATABASE test_database;

---> undrop the database
UNDROP DATABASE test_database;

SHOW DATABASES;

---> use a particular database
USE DATABASE test_database;

---> create a schema
CREATE SCHEMA test_schema;

SHOW SCHEMAS;

---> see metadata about your database
DESCRIBE DATABASE TEST_DATABASE;

---> drop a schema
DROP SCHEMA test_schema;

SHOW SCHEMAS;

---> undrop a schema
UNDROP SCHEMA test_schema;

SHOW SCHEMAS;

---> create a table – note that each column has a name and a data type
CREATE TABLE TEST_TABLE (
	TEST_NUMBER NUMBER,
	TEST_VARCHAR VARCHAR,
	TEST_BOOLEAN BOOLEAN,
	TEST_DATE DATE,
	TEST_VARIANT VARIANT,
	TEST_GEOGRAPHY GEOGRAPHY
);

SELECT * FROM TEST_DATABASE.TEST_SCHEMA.TEST_TABLE;

---> insert a row into the table we just created
INSERT INTO TEST_DATABASE.TEST_SCHEMA.TEST_TABLE
  VALUES
  (28, 'ha!', True, '2024-01-01', NULL, NULL);

SELECT * FROM TEST_DATABASE.TEST_SCHEMA.TEST_TABLE;

---> drop the test table
DROP TABLE TEST_DATABASE.TEST_SCHEMA.TEST_TABLE;

---> see all tables in a particular schema
SHOW TABLES IN TEST_DATABASE.TEST_SCHEMA;

---> undrop the test table
UNDROP TABLE TEST_DATABASE.TEST_SCHEMA.TEST_TABLE;

SHOW TABLES IN TEST_DATABASE.TEST_SCHEMA;

SHOW TABLES;

---> see table storage metadata from the Snowflake database
SELECT * FROM SNOWFLAKE.ACCOUNT_USAGE.TABLE_STORAGE_METRICS; - to check metadata

SHOW TABLES;

---> here’s an example of table we created previously
CREATE TABLE tasty_bytes.raw_pos.order_detail 
(
    order_detail_id NUMBER(38,0),
    order_id NUMBER(38,0),
    menu_item_id NUMBER(38,0),
    discount_id VARCHAR(16777216),
    line_number NUMBER(38,0),
    quantity NUMBER(5,0),
    unit_price NUMBER(38,4),
    price NUMBER(38,4),
    order_item_discount_amount VARCHAR(16777216)
);

---> create the orders_v view – note the “CREATE VIEW view_name AS SELECT” syntax
CREATE VIEW tasty_bytes.harmonized.orders_v
    AS
SELECT 
    oh.order_id,
    oh.truck_id,
    oh.order_ts,
    od.order_detail_id,
    od.line_number,
    m.truck_brand_name,
    m.menu_type,
    t.primary_city,
    t.region,
    t.country,
    t.franchise_flag,
    t.franchise_id,
    f.first_name AS franchisee_first_name,
    f.last_name AS franchisee_last_name,
    l.location_id,
    cl.customer_id,
    cl.first_name,
    cl.last_name,
    cl.e_mail,
    cl.phone_number,
    cl.children_count,
    cl.gender,
    cl.marital_status,
    od.menu_item_id,
    m.menu_item_name,
    od.quantity,
    od.unit_price,
    od.price,
    oh.order_amount,
    oh.order_tax_amount,
    oh.order_discount_amount,
    oh.order_total
FROM tasty_bytes.raw_pos.order_detail od
JOIN tasty_bytes.raw_pos.order_header oh
    ON od.order_id = oh.order_id
JOIN tasty_bytes.raw_pos.truck t
    ON oh.truck_id = t.truck_id
JOIN tasty_bytes.raw_pos.menu m
    ON od.menu_item_id = m.menu_item_id
JOIN tasty_bytes.raw_pos.franchise f
    ON t.franchise_id = f.franchise_id
JOIN tasty_bytes.raw_pos.location l
    ON oh.location_id = l.location_id
LEFT JOIN tasty_bytes.raw_customer.customer_loyalty cl
    ON oh.customer_id = cl.customer_id;

SELECT COUNT(*) FROM tasty_bytes.harmonized.orders_v;

CREATE VIEW tasty_bytes.harmonized.brand_names 
    AS
SELECT truck_brand_name
FROM tasty_bytes.raw_pos.menu;

SHOW VIEWS;

---> drop a view
DROP VIEW tasty_bytes.harmonized.brand_names;

SHOW VIEWS;

---> see metadata about a view
DESCRIBE VIEW tasty_bytes.harmonized.orders_v;

---> create a materialized view
CREATE MATERIALIZED VIEW tasty_bytes.harmonized.brand_names_materialized 
    AS
SELECT DISTINCT truck_brand_name
FROM tasty_bytes.raw_pos.menu;

SELECT * FROM tasty_bytes.harmonized.brand_names_materialized;

SHOW VIEWS;

SHOW MATERIALIZED VIEWS;

---> see metadata about the materialized view we just made
DESCRIBE VIEW tasty_bytes.harmonized.brand_names_materialized;

DESCRIBE MATERIALIZED VIEW tasty_bytes.harmonized.brand_names_materialized;

---> drop the materialized view
DROP MATERIALIZED VIEW tasty_bytes.harmonized.brand_names_materialized;

---> see an example of a column with semi-structured (JSON) data
SELECT MENU_ITEM_NAME
    , MENU_ITEM_HEALTH_METRICS_OBJ
FROM tasty_bytes.RAW_POS.MENU;

DESCRIBE TABLE tasty_bytes.RAW_POS.MENU;


---> check out the data type for the menu_item_health_metrics_obj column – It’s a VARIANT 
CREATE TABLE tasty_bytes.raw_pos.menu
(
    menu_id NUMBER(19,0),
    menu_type_id NUMBER(38,0),
    menu_type VARCHAR(16777216),
    truck_brand_name VARCHAR(16777216),
    menu_item_id NUMBER(38,0),
    menu_item_name VARCHAR(16777216),
    item_category VARCHAR(16777216),
    item_subcategory VARCHAR(16777216),
    cost_of_goods_usd NUMBER(38,4),
    sale_price_usd NUMBER(38,4),
    menu_item_health_metrics_obj VARIANT
);

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

```

## keywords
#### Worksheets
#### Warehouses
#### Stages 
  - internal
  - external
#### Databases (Collection of 1 or schemes)
  - create
  - show
  - drop
  - undrop
  - describe
  - use
#### Schemes (collection of objects like tables and views)
  - create
  - drop
  - undrop
#### Tables
  - create
  - insert into .... values()
  - drop
  - show tables in database.schema
  - show tables
  - Also get dynamic tables, almost like a materialised view but can be refreshed on demand
#### Data Types
  - Numeric
  - String (VARCHAR)
  - Logical
  - Date & Time
  - Semi structured
  - Geospatial
#### Views
  - help write cleaner code
  - Giving someone just view access means they dont have to see whole table
  - Create
  - drop (no undrop becareful)
  - show
  - describe
  - alter
  - 2 types
    - Standard Non Materlialised (basically saves a query)
    - Materialised (saves results alomost like a table but cant create one with joins, costly as updates automatically update)
#### Semi Structured Data
  -  Not normal row col format - need to firgure out what structure is
  -  VARIANT TYPE
      - extremely flexible data type
      - can hold values of any other data type
      - will detect the underlying data type and keep track
      - Can use with structured data as well
      - using SELECT TYPEOF(MENU_ITEM_HEALTH_METRICS_OBJ) will show you what the variant has as the underlying data type
  - OBJECT
    - Like a dictinary in Python
    - Always has a key-value pair
    - The value can be of the variant type
    - Object type can also hold any other date type through variants
    - can pull data from object using key
  - ARRAY
    - List of ordered entries that can be accessed based on that order
    - Also of VARIANT type
    - can pull first entry using name[0]

```sql
CREATE OR REPLACE VIEW tasty_bytes.analytics.menu_v
    AS
SELECT m.menu_item_health_metrics_obj:menu_item_id::integer AS menu_item_id,
    value:"is_healthy_flag"::VARCHAR(1) AS is_healthy_flag,
    value:"is_gluten_free_flag"::VARCHAR(1) AS is_gluten_free_flag,
    value:"is_dairy_free_flag"::VARCHAR(1) AS is_dairy_free_flag,
    value:"is_nut_free_flag"::VARCHAR(1) AS is_nut_free_flag
FROM tasty_bytes.raw_pos.menu m,
    LATERAL FLATTEN (input => m.menu_item_health_metrics_obj:menu_item_health_metrics);

SELECT COUNT(DISTINCT menu_item_id) AS total_menu_items,
    SUM(CASE WHEN is_healthy_flag = 'Y' THEN 1 ELSE 0 END) AS healthy_item_count,
    SUM(CASE WHEN is_gluten_free_flag = 'Y' THEN 1 ELSE 0 END) AS healthy_item_count,
    SUM(CASE WHEN is_dairy_free_flag = 'Y' THEN 1 ELSE 0 END) AS healthy_item_count,
    SUM(CASE WHEN is_nut_free_flag = 'Y' THEN 1 ELSE 0 END) AS healthy_item_count
FROM tasty_bytes.analytics.menu_v;
```


### Snowflakes 4 architectural layers
- Storage (access data all in one place wether structured, unstructured or semi structured)
- Compute (near infinitly scalable)
- Cloud services (manages files and file metadata enabling time travel and cloning)
- Snowgrid (makes it easy to share in different regions and clouds)

<img width="1625" height="961" alt="image" src="https://github.com/user-attachments/assets/2ad4872e-e1f0-4805-ad8d-5790d074b5e0" />
<img width="1743" height="995" alt="image" src="https://github.com/user-attachments/assets/989a675d-f79b-4e6e-80e2-3bc856c12cf1" />
<img width="1728" height="967" alt="image" src="https://github.com/user-attachments/assets/2fd9dba1-cb01-48ef-b029-782c14d47ee2" />
<img width="1741" height="1016" alt="image" src="https://github.com/user-attachments/assets/316934f8-cbba-49a0-b12b-0f441b2da8b4" />
<img width="1703" height="944" alt="image" src="https://github.com/user-attachments/assets/624229a4-4b5b-4ad0-a94e-b504437d00cb" />







