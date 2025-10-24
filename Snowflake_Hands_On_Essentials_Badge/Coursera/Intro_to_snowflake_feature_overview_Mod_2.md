## Intro to Snowflake Feature Overview
```sql
SHOW TABLES;

---> set the data retention time to 90 days
ALTER TABLE TASTY_BYTES.RAW_POS.TEST_MENU SET DATA_RETENTION_TIME_IN_DAYS = 90;

SHOW TABLES;

---> set the data retention time to 1 day
ALTER TABLE TASTY_BYTES.RAW_POS.TEST_MENU SET DATA_RETENTION_TIME_IN_DAYS = 1;

---> clone the truck table
CREATE OR REPLACE TABLE tasty_bytes.raw_pos.truck_dev 
    CLONE tasty_bytes.raw_pos.truck;

SELECT
    t.truck_id,
    t.year,
    t.make,
    t.model
FROM tasty_bytes.raw_pos.truck_dev t;
    
---> see how the age should have been calculated
SELECT
    t.truck_id,
    t.year,
    t.make,
    t.model,
    (YEAR(CURRENT_DATE()) - t.year) AS truck_age
FROM tasty_bytes.raw_pos.truck_dev t;

---> record the most recent query_id, back when the data was still correct
SET good_data_query_id = LAST_QUERY_ID();

---> view the variable’s value
SELECT $good_data_query_id;

---> record the time, back when the data was still correct
SET good_data_timestamp = CURRENT_TIMESTAMP;

---> view the variable’s value
SELECT $good_data_timestamp;

---> confirm that that worked
SHOW VARIABLES;

---> make the first mistake: calculating the truck’s age incorrectly
SELECT
    t.truck_id,
    t.year,
    t.make,
    t.model,
    (YEAR(CURRENT_DATE()) / t.year) AS truck_age
FROM tasty_bytes.raw_pos.truck_dev t;

---> make the second mistake: calculate age wrong, and overwrite the year!
UPDATE tasty_bytes.raw_pos.truck_dev t
    SET t.year = (YEAR(CURRENT_DATE()) / t.year);

SELECT
    t.truck_id,
    t.year,
    t.make,
    t.model
FROM tasty_bytes.raw_pos.truck_dev t;

---> select the data as of a particular timestamp
SELECT * FROM tasty_bytes.raw_pos.truck_dev
AT(TIMESTAMP => $good_data_timestamp);

SELECT $good_data_timestamp;

---> example code, without a timestamp inserted:

-- SELECT * FROM tasty_bytes.raw_pos.truck_dev
-- AT(TIMESTAMP => '[insert timestamp]'::TIMESTAMP_LTZ);

--->example code, with a timestamp inserted
SELECT * FROM tasty_bytes.raw_pos.truck_dev
AT(TIMESTAMP => '2024-04-04 21:34:31.833 -0700'::TIMESTAMP_LTZ);

---> calculate the right offset
SELECT TIMESTAMPDIFF(second,CURRENT_TIMESTAMP,$good_data_timestamp);

---> Example code, without an offset inserted:

-- SELECT * FROM tasty_bytes.raw_pos.truck_dev
-- AT(OFFSET => -[WRITE OFFSET SECONDS PLUS A BIT]);

---> select the data as of a particular number of seconds back in time
SELECT * FROM tasty_bytes.raw_pos.truck_dev
AT(OFFSET => -45);

SELECT $good_data_query_id;

---> select the data as of its state before a previous query was run
SELECT * FROM tasty_bytes.raw_pos.truck_dev
BEFORE(STATEMENT => $good_data_query_id);

---> drop truck_dev if not dropped previously
DROP TABLE TASTY_BYTES.RAW_POS.TRUCK_DEV;

---> create a transient table
CREATE TRANSIENT TABLE TASTY_BYTES.RAW_POS.TRUCK_TRANSIENT
    CLONE TASTY_BYTES.RAW_POS.TRUCK;

---> create a temporary table
CREATE TEMPORARY TABLE TASTY_BYTES.RAW_POS.TRUCK_TEMPORARY
    CLONE TASTY_BYTES.RAW_POS.TRUCK;

---> show tables that start with the word TRUCK
SHOW TABLES LIKE 'TRUCK%';

---> attempt (successfully) to set the data retention time to 90 days for the standard table
ALTER TABLE TASTY_BYTES.RAW_POS.TRUCK SET DATA_RETENTION_TIME_IN_DAYS = 90;

---> attempt (unsuccessfully) to set the data retention time to 90 days for the transient table
ALTER TABLE TASTY_BYTES.RAW_POS.TRUCK_TRANSIENT SET DATA_RETENTION_TIME_IN_DAYS = 90;

---> attempt (unsuccessfully) to set the data retention time to 90 days for the temporary table
ALTER TABLE TASTY_BYTES.RAW_POS.TRUCK_TEMPORARY SET DATA_RETENTION_TIME_IN_DAYS = 90;

SHOW TABLES LIKE 'TRUCK%';

---> attempt (successfully) to set the data retention time to 0 days for the transient table
ALTER TABLE TASTY_BYTES.RAW_POS.TRUCK_TRANSIENT SET DATA_RETENTION_TIME_IN_DAYS = 0;

---> attempt (successfully) to set the data retention time to 0 days for the temporary table
ALTER TABLE TASTY_BYTES.RAW_POS.TRUCK_TEMPORARY SET DATA_RETENTION_TIME_IN_DAYS = 0;

SHOW TABLES LIKE 'TRUCK%';

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

---> create a clone of the truck table
CREATE OR REPLACE TABLE tasty_bytes.raw_pos.truck_clone 
    CLONE tasty_bytes.raw_pos.truck;

/* look at metadata for the truck and truck_clone tables from the table_storage_metrics view in the information_schema */
SELECT * FROM TASTY_BYTES.INFORMATION_SCHEMA.TABLE_STORAGE_METRICS
WHERE TABLE_NAME = 'TRUCK_CLONE' OR TABLE_NAME = 'TRUCK';

/* look at metadata for the truck and truck_clone tables from the tables view in the information_schema */
SELECT * FROM TASTY_BYTES.INFORMATION_SCHEMA.TABLES
WHERE TABLE_NAME = 'TRUCK_CLONE' OR TABLE_NAME = 'TRUCK';

---> insert the truck table into the clone (thus doubling the clone’s size!)
INSERT INTO tasty_bytes.raw_pos.truck_clone
SELECT * FROM tasty_bytes.raw_pos.truck;

---> now use the tables view to look at metadata for the truck and truck_clone tables again
SELECT * FROM TASTY_BYTES.INFORMATION_SCHEMA.TABLES
WHERE TABLE_NAME = 'TRUCK_CLONE' OR TABLE_NAME = 'TRUCK';

---> clone a schema
CREATE OR REPLACE SCHEMA tasty_bytes.raw_pos_clone
CLONE tasty_bytes.raw_pos;

---> clone a database
CREATE OR REPLACE DATABASE tasty_bytes_clone
CLONE tasty_bytes;

---> clone a table based on an offset (so the table as it was at a certain interval in the past) 
CREATE OR REPLACE TABLE tasty_bytes.raw_pos.truck_clone_time_travel 
    CLONE tasty_bytes.raw_pos.truck AT(OFFSET => -60*10);

SELECT * FROM tasty_bytes.raw_pos.truck_clone_time_travel;

-- Resources
---> create a resource monitor
CREATE RESOURCE MONITOR tasty_test_rm
WITH 
    CREDIT_QUOTA = 20 -- 20 credits
    FREQUENCY = daily -- reset the monitor daily
    START_TIMESTAMP = immediately -- begin tracking immediately
    TRIGGERS 
        ON 80 PERCENT DO NOTIFY -- notify accountadmins at 80%
        ON 100 PERCENT DO SUSPEND -- suspend warehouse at 100 percent, let queries finish
        ON 110 PERCENT DO SUSPEND_IMMEDIATE; -- suspend warehouse and cancel all queries at 110 percent

---> see all resource monitors
SHOW RESOURCE MONITORS;

---> assign a resource monitor to a warehouse
ALTER WAREHOUSE tasty_de_wh SET RESOURCE_MONITOR = tasty_test_rm;

SHOW RESOURCE MONITORS;

---> change the credit quota on a resource monitor
ALTER RESOURCE MONITOR tasty_test_rm
  SET CREDIT_QUOTA=30;

SHOW RESOURCE MONITORS;

---> drop a resource monitor
DROP RESOURCE MONITOR tasty_test_rm;

SHOW RESOURCE MONITORS;

-- User defined functions
---> here’s an example of a function in action!
SELECT ABS(-14);

---> here’s another example of a function in action!
SELECT UPPER('upper');

---> see all functions
SHOW FUNCTIONS;

SELECT MAX(SALE_PRICE_USD) FROM TASTY_BYTES.RAW_POS.MENU;

---> use a particular database
USE DATABASE TASTY_BYTES;

---> create the max_menu_price function
CREATE FUNCTION max_menu_price()
  RETURNS NUMBER(5,2)
  AS
  $$
    SELECT MAX(SALE_PRICE_USD) FROM TASTY_BYTES.RAW_POS.MENU
  $$
  ;

---> run the max_menu_price function by calling it in a select statement
SELECT max_menu_price();

SHOW FUNCTIONS;

---> create a new function, but one that takes in an argument
CREATE FUNCTION max_menu_price_converted(USD_to_new NUMBER)
  RETURNS NUMBER(5,2)
  AS
  $$
    SELECT USD_TO_NEW*MAX(SALE_PRICE_USD) FROM TASTY_BYTES.RAW_POS.MENU
  $$
  ;

SELECT max_menu_price_converted(1.35);

---> create a Python function
CREATE FUNCTION winsorize (val NUMERIC, up_bound NUMERIC, low_bound NUMERIC)
returns NUMERIC
language python
runtime_version = '3.11'
handler = 'winsorize_py'
AS
$$
def winsorize_py(val, up_bound, low_bound):
    if val > up_bound:
        return up_bound
    elif val < low_bound:
        return low_bound
    else:
        return val
$$;

---> run the Python function
SELECT winsorize(12.0, 11.0, 4.0);

---> here’s the reference UDF we’re going to work off of as we make our UDTF
CREATE FUNCTION max_menu_price()
  RETURNS NUMBER(5,2)
  AS
  $$
    SELECT MAX(SALE_PRICE_USD) FROM TASTY_BYTES.RAW_POS.MENU
  $$
  ;

USE DATABASE TASTY_BYTES;
  
---> create a user-defined table function
CREATE FUNCTION menu_prices_above(price_floor NUMBER)
  RETURNS TABLE (item VARCHAR, price NUMBER)
  AS
  $$
    SELECT MENU_ITEM_NAME, SALE_PRICE_USD 
    FROM TASTY_BYTES.RAW_POS.MENU
    WHERE SALE_PRICE_USD > price_floor
    ORDER BY 2 DESC
  $$
  ;
  
---> now you can see it in the list of all functions!
SHOW FUNCTIONS;

---> run the UDTF to see what the output looks like
SELECT * FROM TABLE(menu_prices_above(15));

---> you can use a where clause on the result
SELECT * FROM TABLE(menu_prices_above(15)) 
WHERE ITEM ILIKE '%CHICKEN%';

-- Stored procedures
---> list all procedures
SHOW PROCEDURES;

SELECT * FROM TASTY_BYTES_CLONE.RAW_POS.ORDER_HEADER
LIMIT 100;

---> see the latest and earliest order timestamps so we can determine what we want to delete
SELECT MAX(ORDER_TS), MIN(ORDER_TS) FROM TASTY_BYTES_CLONE.RAW_POS.ORDER_HEADER;

---> save the max timestamp
SET max_ts = (SELECT MAX(ORDER_TS) FROM TASTY_BYTES_CLONE.RAW_POS.ORDER_HEADER);

SELECT $max_ts;

SELECT DATEADD('DAY',-180,$max_ts);

---> determine the necessary cutoff to go back 180 days
SET cutoff_ts = (SELECT DATEADD('DAY',-180,$max_ts));

---> note how you can use the cutoff_ts variable in the WHERE clause
SELECT MAX(ORDER_TS) FROM TASTY_BYTES_CLONE.RAW_POS.ORDER_HEADER
WHERE ORDER_TS < $cutoff_ts;

USE DATABASE TASTY_BYTES;

---> create your procedure
CREATE OR REPLACE PROCEDURE delete_old()
RETURNS BOOLEAN
LANGUAGE SQL
AS
$$
DECLARE
  max_ts TIMESTAMP;
  cutoff_ts TIMESTAMP;
BEGIN
  max_ts := (SELECT MAX(ORDER_TS) FROM TASTY_BYTES_CLONE.RAW_POS.ORDER_HEADER);
  cutoff_ts := (SELECT DATEADD('DAY',-180,:max_ts));
  DELETE FROM TASTY_BYTES_CLONE.RAW_POS.ORDER_HEADER
  WHERE ORDER_TS < :cutoff_ts;
END;
$$
;

SHOW PROCEDURES;

---> see information about your procedure
DESCRIBE PROCEDURE delete_old();

---> run your procedure
CALL DELETE_OLD();

---> confirm that that made a difference
SELECT MIN(ORDER_TS) FROM TASTY_BYTES_CLONE.RAW_POS.ORDER_HEADER;

---> it did! We deleted everything from before the cutoff timestamp
SELECT $cutoff_ts;

-- Role based Access control code
USE ROLE accountadmin;

---> create a role
CREATE ROLE tasty_de;

---> see what privileges this new role has
SHOW GRANTS TO ROLE tasty_de;

---> see what privileges an auto-generated role has
SHOW GRANTS TO ROLE accountadmin;

---> grant a role to a specific user
GRANT ROLE tasty_de TO USER [username];

---> use a role
USE ROLE tasty_de;

---> try creating a warehouse with this new role
CREATE WAREHOUSE tasty_de_test;

USE ROLE accountadmin;

---> grant the create warehouse privilege to the tasty_de role
GRANT CREATE WAREHOUSE ON ACCOUNT TO ROLE tasty_de;

---> show all of the privileges the tasty_de role has
SHOW GRANTS TO ROLE tasty_de;

USE ROLE tasty_de;

---> test to see whether tasty_de can create a warehouse
CREATE WAREHOUSE tasty_de_test;

---> learn more about the privileges each of the following auto-generated roles has

SHOW GRANTS TO ROLE securityadmin;

SHOW GRANTS TO ROLE useradmin;

SHOW GRANTS TO ROLE sysadmin;

SHOW GRANTS TO ROLE public;

-- CLI
pip install snowflake-cli-labs

snow --help

snow --info

cd "/Users/polson/Library/Application Support/snowflake/"

ls

vim config.toml

:q

cd ~

snow --help

snow app

snow --help

snow connection --help

snow --help

snow object --help
```

<img width="1415" height="750" alt="image" src="https://github.com/user-attachments/assets/c0030863-0993-48a5-a682-0ee80ed306eb" />

<img width="852" height="834" alt="image" src="https://github.com/user-attachments/assets/33991a3a-819f-44e3-9e2c-a07a06562efc" />

<img width="1421" height="781" alt="image" src="https://github.com/user-attachments/assets/21c617e3-fbe0-4db4-8a0a-9f99677ab41f" />

<img width="1185" height="680" alt="image" src="https://github.com/user-attachments/assets/af00c7b5-c7c4-454b-850e-34c8b1d32738" />

<img width="1373" height="718" alt="image" src="https://github.com/user-attachments/assets/ffac3b5a-676c-4ec9-bf98-8e22acd12260" />

<img width="1408" height="907" alt="image" src="https://github.com/user-attachments/assets/c88fe899-9d51-4447-822c-12e12410d717" />

<img width="725" height="629" alt="image" src="https://github.com/user-attachments/assets/1c206a6e-458e-4e40-a3bb-49820dd20ab5" />

<img width="1451" height="795" alt="image" src="https://github.com/user-attachments/assets/f33dc982-42e6-4ce6-b8ae-8a68e1cf99b4" />

### Module 3
```sql
---> create the storage integration
CREATE OR REPLACE STORAGE INTEGRATION S3_role_integration
  TYPE = EXTERNAL_STAGE
  STORAGE_PROVIDER = S3
  ENABLED = TRUE
  STORAGE_AWS_ROLE_ARN = "REMOVED"
  STORAGE_ALLOWED_LOCATIONS = ("s3://intro-to-snowflake-snowpipe/");

---> describe the storage integration to see the info you need to copy over to AWS
DESCRIBE INTEGRATION S3_role_integration;

---> create the database
CREATE OR REPLACE DATABASE S3_db;

---> create the table (automatically in the public schema, because we didn’t specify)
CREATE OR REPLACE TABLE S3_table(food STRING, taste INT);

USE SCHEMA S3_db.public;

---> create stage with the link to the S3 bucket and info on the associated storage integration
CREATE OR REPLACE STAGE S3_stage
  url = ('s3://intro-to-snowflake-snowpipe/')
  storage_integration = S3_role_integration;

SHOW STAGES;

---> see the files in the stage
LIST @S3_stage;

---> select the first two columns from the stage
SELECT $1, $2 FROM @S3_stage;

USE WAREHOUSE COMPUTE_WH;

---> create the snowpipe, copying from S3_stage into S3_table
CREATE PIPE S3_db.public.S3_pipe AUTO_INGEST=TRUE as
  COPY INTO S3_db.public.S3_table
  FROM @S3_db.public.S3_stage;

SELECT * FROM S3_db.public.S3_table;

---> see a list of all the pipes
SHOW PIPES;

DESCRIBE PIPE S3_db.public.S3_pipe;

---> pause the pipe
ALTER PIPE S3_db.public.S3_pipe SET PIPE_EXECUTION_PAUSED = TRUE;

---> drop the pipe
DROP PIPE S3_pipe;

SHOW PIPES;

----------
---> use the mistral-7b model and Snowflake Cortex Complete to ask a question
SELECT SNOWFLAKE.CORTEX.COMPLETE(
    'mistral-7b', 'What are three reasons that Snowflake is positioned to become the go-to data platform?');

---> now send the result to the Snowflake Cortex Summarize function
SELECT SNOWFLAKE.CORTEX.SUMMARIZE(SNOWFLAKE.CORTEX.COMPLETE(
    'mistral-7b', 'What are three reasons that Snowflake is positioned to become the go-to data platform?'));

---> run Snowflake Cortex Complete on multiple rows at once
SELECT SNOWFLAKE.CORTEX.COMPLETE(
    'mistral-7b',
        CONCAT('Tell me why this food is tasty: ', menu_item_name)
) FROM FROSTBYTE_TASTY_BYTES.RAW_POS.MENU LIMIT 5;

---> check out what the table of prompts we’re feeding to Complete (roughly) looks like
SELECT CONCAT('Tell me why this food is tasty: ', menu_item_name)
FROM FROSTBYTE_TASTY_BYTES.RAW_POS.MENU LIMIT 5;

---> give Snowflake Cortex Complete a prompt with history
SELECT SNOWFLAKE.CORTEX.COMPLETE(
    'mistral-7b', -- the model you want to use
    [
        {'role': 'system', 
        'content': 'Analyze this Snowflake review and determine the overall sentiment. Answer with just \"Positive\", \"Negative\", or \"Neutral\"' },
        {'role': 'user',
        'content': 'I love Snowflake because it is so simple to use.'}
    ], -- the array with the prompt history, and your new prompt
    {} -- An empty object of options (we're not specify additional options here)
) AS response;

---> give Snowflake Cortex Complete a prompt with a lengthier history
SELECT SNOWFLAKE.CORTEX.COMPLETE(
    'mistral-7b',
    [
        {'role': 'system', 
        'content': 'Analyze this Snowflake review and determine the overall sentiment. Answer with just \"Positive\", \"Negative\", or \"Neutral\"' },
        {'role': 'user',
        'content': 'I love Snowflake because it is so simple to use.'},
        {'role': 'assistant',
        'content': 'Positive. The review expresses a positive sentiment towards Snowflake, specifically mentioning that it is \"so simple to use.\'"'},
        {'role': 'user',
        'content': 'Based on other information you know about Snowflake, explain why the reviewer might feel they way they do.'}
    ], -- the array with the prompt history, and your new prompt
    {} -- An empty object of options (we're not specify additional options here)
) AS response;

-------
# Note: This is not code you can run in a SQL worksheet. We ran this in a Jupyter notebook

# install these two libraries
!pip install snowflake-ml-python
!pip install snowflake-snowpark-python

# don’t worry too much about this – I created credential.py to hold my login credentials
from credential import params

# if you want guidance on connecting to Snowflake from your IDE, see here:
# https://docs.snowflake.com/en/developer-guide/snowpark/python/creating-session#creating-a-session

# import the libraries you’ll need
from snowflake.snowpark import Session
from snowflake.ml.modeling.xgboost import XGBClassifier
from snowflake.snowpark.functions import col
from snowflake.ml.modeling import preprocessing

# Here’s the neighborhood visiting pattern the truck follows:
# In January, the truck goes to N1 on the 1st, 8th, 15th, 22nd, and 29th, and N2 the other days.

# From February through November, it goes to:
# N1 on the 1st
# N2 on the 2nd
# N3 on the 3rd
# N4 on the 4th
# N5 on the 5th
# N6 on the 6th
# N7 on the 7th
# N1 on the 8th
# N2 on the 9th
# etc.

# Every December, it only goes to N8.

month_days = [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31]

pre = {}

for i,month_length in enumerate(month_days):
    month = i + 1

    for day in range(1,month_length+1):
        
        # In January, it goes to neighborhood 1 on Mondays, and neighborhood 2 the other days.
        if ((month) == 1):
            if (day) % 7 == 1:
                pre[(month,day)] = 1
            else:
                pre[(month,day)] = 2
                
        # From February through November, it goes to neighborhood 1 on the 1st, 2 on the 2nd, 3 on the 3rd,
        # 4 on the 4th, 5 on the 5th, 6 on the 6th, and 7 on the 7th, 1 on the 8th, 2 on the 9th, etc.
        elif ((month) <= 11):
            pre[(month,day)] = ((day-1) % 7) + 1

        # Every December, it only goes to neighborhood 8.
        elif ((month) == 12):
            pre[(month,day)] = 8

# see what the pre dictionary looks like
pre

# Note: Here, I skipped the step of uploading the final “df_clean” dataset to Snowflake

# create a Session with the necessary connection info
session = Session.builder.configs(params).create()

# create a dataframe (though note that this doesn’t pull data into your local machine)
snowpark_df = session.table("test_database.test_schema.df_clean")

# show the first forty rows of the dataframe
snowpark_df.show(n=40)

# count the rows in the dataframe
snowpark_df.count()

# describe the dataframe
snowpark_df.describe().show()

# groupby neighborhood, and show the counts
snowpark_df.group_by("Neighborhood").count().show()

# one way to scale your target (neighborhood) so you can use it in the XGBClassifier model
test = snowpark_df.withColumn('NEIGHBORHOOD2', snowpark_df.neighborhood - 1).drop("Neighborhood")

test.show()

# now use scikit-learn's LabelEncoder -- a more general solution -- through Snowpark ML 
le = LabelEncoder(input_cols=['NEIGHBORHOOD'], output_cols= ['NEIGHBORHOOD2'], drop_input_cols=True)

# apply the LabelEncoder
fitted = le.fit(snowpark_df.select("NEIGHBORHOOD"))

snowpark_df_prepared = fitted.transform(snowpark_df)

snowpark_df_prepared.show()

# split the data into a training set and a test set
train_snowpark_df, test_snowpark_df = snowpark_df_prepared.randomSplit([0.9, 0.1])

# save training data
train_snowpark_df.write.mode("overwrite").save_as_table("df_clean_train")

# save test data
test_snowpark_df.write.mode("overwrite").save_as_table("df_clean_test")

# create and train the XGBClassifier model
FEATURE_COLS = ["MONTH", "DAY"]
LABEL_COLS = ["NEIGHBORHOOD2"]

# Train an XGBoost model on snowflake.
xgboost_model = XGBClassifier(
    input_cols=FEATURE_COLS,
    label_cols=LABEL_COLS
)

xgboost_model.fit(train_snowpark_df)

# check the accuracy using scikit-learn's score functionality through Snowpark ML
accuracy = xgboost_model.score(test_snowpark_df)

print("Accuracy: %.2f%%" % (accuracy * 100.0))

-----
# Import Python Packages

import pandas as pd
import streamlit as st
from snowflake.snowpark.context import get_active_session
import altair as alt

# Get the Current Credentials
session = get_active_session()

# Streamlit App
st.title(":snowflake: Tasty Bytes Streamlit App :snowflake:")
st.write(
    """Tasty Bytes is a fictitious, global food truck network, that is on a mission to serve unique food options with high quality items in a safe, convenient and cost effective way. In order to drive
forward on their mission, Tasty Bytes is beginning to leverage the Snowflake Data Cloud.
    """
)
st.divider()


@st.cache_data
def get_city_sales_data(city_names: list, start_year: int = 2020, end_year: int = 2023):
    sql = f"""
        SELECT
            date,
            primary_city,
            SUM(order_total) AS sum_orders
        FROM tasty_bytes.analytics.orders_v
        WHERE primary_city in ({city_names})
            and year(date) between {start_year} and {end_year}
        GROUP BY date, primary_city
        ORDER BY date DESC
    """
    sales_data = session.sql(sql).to_pandas()
    return sales_data, sql

@st.cache_data
def get_unique_cities():
    sql = """
        SELECT DISTINCT primary_city
        FROM tasty_bytes.analytics.orders_v
        ORDER BY primary_city
    """
    city_data = session.sql(sql).to_pandas()
    return city_data

def get_city_sales_chart(sales_data: pd.DataFrame):
    sales_data["SUM_ORDERS"] = pd.to_numeric(sales_data["SUM_ORDERS"])
    sales_data["DATE"] = pd.to_datetime(sales_data["DATE"])

    # Create an Altair chart object
    chart = (
        alt.Chart(sales_data)
        .mark_line(point=False, tooltip=True)
        .encode(
            alt.X("DATE", title="Date"),
            alt.Y("SUM_ORDERS", title="Total Orders Sum USD"),
            color="PRIMARY_CITY",
        )
    )
    return chart


def format_sql(sql):
    # Remove padded space for visual purposes
    return sql.replace("\n        ", "\n")


first_col, second_col = st.columns(2, gap="large")

with first_col:
    start_year, end_year = st.select_slider(
        "Select date range you want to filter the chart on below:",
        options=range(2020, 2024),
        value=(2020, 2023),
    )
with second_col:
    selected_city = st.multiselect(
        label="Select cities below that you want added to the chart below:",
        options=get_unique_cities()["PRIMARY_CITY"].tolist(),
        default="San Mateo",
    )
if len(selected_city) == 0:
    city_selection = ""
else:
    city_selection = selected_city
city_selection_list = ("'" + "','".join(city_selection) + "'") if city_selection else ""

sales_data, sales_sql = get_city_sales_data(city_selection_list, start_year, end_year)
sales_fig = get_city_sales_chart(sales_data)


chart_tab, dataframe_tab, query_tab = st.tabs(["Chart", "Raw Data", "SQL Query"])
chart_tab.altair_chart(sales_fig, use_container_width=True)
dataframe_tab.dataframe(sales_data, use_container_width=True)
query_tab.code(format_sql(sales_sql), "sql")



```





