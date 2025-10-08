# Badge 2 - Hands-On Essentials: Collaboration, Marketplace & Cost Estimation Workshop
## Lesson 3
### How to Test Whether You Set Up Your Table in the Right Place with the Right Name
``` sql
select count(*) as OBJECTS_FOUND
from INTL_DB.INFORMATION_SCHEMA.TABLES 
where table_schema='PUBLIC'
and table_name= 'INT_STDS_ORG_3166';
```
###  How to Test That You Loaded the Expected Number of Rows
``` sql
select row_count
from INTL_DB.INFORMATION_SCHEMA.TABLES 
where table_schema='PUBLIC'
and table_name= 'INT_STDS_ORG_3166';
```

### 🥋 Convert the Select Statement into a View
 - You can convert any SELECT into a VIEW by adding a CREATE VIEW command in front of the SELECT statement. 
``` sql
create view intl_db.public.NATIONS_SAMPLE_PLUS_ISO 
( iso_country_name
  ,country_name_official
  ,alpha_code_2digit
  ,region) AS
  <put select statement here>
;
```
- Creating a view makes a select statement behave like a table.
- If you find yourself using the logic of a select statement over and over again, it can be more convenient to wrap the statement in a view, and run simple queries on the view. 
- Views can make your code more modular and organized.
- A view can capture a complex select statement and make it simple to run repeatedly.
``` sql
select *
from intl_db.public.NATIONS_SAMPLE_PLUS_ISO;
```
## Lesson 4

### Sharing Data with Other accounts
- On the sharer side, select Data Sharing then Provider Studio
- Create listing -> Specified Consumers
- Gove the listing a name and save
- Select add data product button
- Drill down till you have the database you want to share and select the relevant tables -> Done and Save
- Select Access Type - Free
- Select Legal terms -> Standard Option -> Save
- Give the data product a description
- Click Add Consumer - Add Organisatio and Account name of receiver -> Save
- Select data dictionary and selet the tables
- if error 'Error: Cannot set replication schedule for listing 'INTERNATIONAL_CURRENCIES': account not set up for auto-fulfillment' Run:
``` sql
USE ROLE ORGADMIN;
SELECT SYSTEM$ENABLE_GLOBAL_DATA_SHARING_FOR_ACCOUNT(' < senders accountname >');
```
- Also make sure sender is setup for sharing (Code below should return TRUE)
``` sql
SELECT SYSTEM$IS_GLOBAL_DATA_SHARING_ENABLED_FOR_ACCOUNT(' < sender accountname >');
```
- On receivers side - Data Products - private Sharing - Click GET button for the Listing you want
- A listing is a vehicle for sharing, Data Dictionary added above helps receiver understand the data, also add the column descriptions
- Adding a Quick Start example helps when the receiver uses the listing
- Once listing has been replicated on receivers end, click on it and it will open lastest table
- Select the blue GET button if it asks to Get the latest
- Make sure SYSADMIN and ACCOUNTADMIN have access
- Click Query to open a SQL Query

### Convert regular Views to Secure Views
- On sender side, in ORGADMIN

``` sql
alter view intl_db.public.NATIONS_SAMPLE_PLUS_ISO
set secure; 

alter view intl_db.public.SIMPLE_CURRENCY
set secure; 
```
- Add new secure views to the Outbound share (as ACCOUNTSADMIN)
- Data Products - provider Studio - Listings -  Select Listing
- Select product on Right hand side
- Select edit data and add the shared secure views
- Remember you cant share a share


## Lesson 5
### Understanding Snowflake costs
- https://docs.snowflake.com/en/user-guide/warehouses-overview
- https://www.snowflake.com/en/pricing-options
- https://docs.snowflake.com/en/user-guide/cost-understanding-overall

## Lesson 6
### Snowflake Marketplace

- Marketshare
- Look for teh dataset you want
- Get for free
- Roles are ACCOUNTADMIN and SYSADMIN
- GET & Query the data
- Will open up a waroksheet with some sample queries
- Rename the datasource to what you want
``` sql
alter database GLOBAL_WEATHER__CLIMATE_DATA_FOR_BI
rename to WEATHERSOURCE;

```
## Lesson 7
### Exploring the Data
- Can filter the marketplace data to have exactly what is needed and then save as a view in a new dtabase
- Now able to join own data to this view and run queries

## Lesson 8
### Auto Data Unlimited
- make sure you have SYSADMIN role and that it owns everything.
- One way to encapsulate logic is to create a function.
- This function needs to be SECURE so you can share it. So when you type "CREATE FUNCTION" be sure to add the word "SECURE", as in "CREATE SECURE FUNCTION"
- To create a SECURE function:
- Be sure to use the SECURE keyword.
- Give the function a name 
- Tell the function what information you will be passing into it. 
- Tell the function what type of information you expect it to pass back to you (Return).
- We name the value to use 'this_vin' so when we run the select statement we use 'this_vin'


``` sql
create or replace secure function vin.decode.parse_and_enhance_vin(this_vin varchar(25))
returns table (
    VIN varchar(25)
    , manuf_name varchar(25)
    , vehicle_type varchar(25)
    , make_name varchar(25)
    , plant_name varchar(25)
    , model_year varchar(25)
    , model_name varchar(25)
    , desc1 varchar(25)
    , desc2 varchar(25)
    , desc3 varchar(25)
    , desc4 varchar(25)
    , desc5 varchar(25)
    , engine varchar(25)
    , drive_type varchar(25)
    , transmission varchar(25)
    , mpg varchar(25)
)
as $$
select VIN
, manuf_name
, vehicle_type
, make_name
, plant_name
, model_year_name as model_year
, model_name
, desc1
, desc2
, desc3
, desc4
, desc5
, engine
, drive_type
, transmission
, mpg
from
  ( SELECT THIS_VIN as VIN
  , LEFT(THIS_VIN,3) as WMI
  , SUBSTR(THIS_VIN,4,5) as VDS
  , SUBSTR(THIS_VIN,10,1) as model_year_code
  , SUBSTR(THIS_VIN,11,1) as plant_code
  ) vin
JOIN vin.decode.wmi_to_manuf w 
    ON vin.wmi = w.wmi
JOIN vin.decode.manuf_to_make m
    ON w.manuf_id=m.manuf_id
JOIN vin.decode.manuf_plants p
    ON vin.plant_code=p.plant_code
    AND m.make_id=p.make_id
JOIN vin.decode.model_year y
    ON vin.model_year_code=y.model_year_code
JOIN vin.decode.make_model_vds vds
    ON vds.vds=vin.vds 
    AND vds.make_id = m.make_id
$$;

```
- now when we run this code it will use the VIN we give it

``` sql
select *
from table(vin.decode.PARSE_AND_ENHANCE_VIN('SAJAJ4FX8LCP55916'));
```
- Did you know that to create a share, you don't have to include any data?
- One thing to keep in mind: a function can only be shared if it is a SECURE function so if your function doesn't appear, you may need to review the previous pages.
- To create a listing
  - While in the selected account, go to Data Sharing > Provider Studio. 
  - Use the blue [+ Listing] button.
  - Name your listing:   Any_name_you_like
  - You will only be sharing with a certain account (a specific consumer, not the Marketplace). 
  - Put in the real email of your choice.
 
🥋 Combining the Table Data with the Function Data

``` sql
-- This scripting block runs very slow, but it shows how blocks work for people who are new to using them
DECLARE
    update_stmt varchar(2000);
    res RESULTSET;
    cur CURSOR FOR select vin from stock.unsold.lotstock where manuf_name is null;
BEGIN
    OPEN cur;
    FOR each_row IN cur DO
        update_stmt := 'update stock.unsold.lotstock t '||
            'set manuf_name = s.manuf_name ' ||
            ', vehicle_type = s.vehicle_type ' ||
            ', make_name = s.make_name ' ||
            ', plant_name = s.plant_name ' ||
            ', model_year = s.model_year ' ||
            ', desc1 = s.desc1 ' ||
            ', desc2 = s.desc2 ' ||
            ', desc3 = s.desc3 ' ||
            ', desc4 = s.desc4 ' ||
            ', desc5 = s.desc5 ' ||
            ', engine = s.engine ' ||
            ', drive_type = s.drive_type ' ||
            ', transmission = s.transmission ' ||
            ', mpg = s.mpg ' ||
            'from ' ||
            '(       select ls.vin, pf.manuf_name, pf.vehicle_type ' ||
                    ', pf.make_name, pf.plant_name, pf.model_year ' ||
                    ', pf.desc1, pf.desc2, pf.desc3, pf.desc4, pf.desc5 ' ||
                    ', pf.engine, pf.drive_type, pf.transmission, pf.mpg ' ||
                'from stock.unsold.lotstock ls ' ||
                'join ' ||
                '(   select' || 
                '     vin, manuf_name, vehicle_type' ||
                '    , make_name, plant_name, model_year ' ||
                '    , desc1, desc2, desc3, desc4, desc5 ' ||
                '    , engine, drive_type, transmission, mpg ' ||
                '    from table(ADU_VIN.DECODE.PARSE_AND_ENHANCE_VIN(\'' ||
                  each_row.vin || '\')) ' ||
                ') pf ' ||
                'on pf.vin = ls.vin ' ||
            ') s ' ||
            'where t.vin = s.vin;';
        res := (EXECUTE IMMEDIATE :update_stmt);
    END FOR;
    CLOSE cur;   
END;
```



📓  What's Next? 
- You can find more information on scripting here:  https://docs.snowflake.com/en/sql-reference-snowflake-scripting
- Most people put scripting blocks into Stored Procedures, which are another way to encapsulate different bits of code. 
- Snowflake was designed for loading and updating large record sets with a single statement, not for updating one row at a time, using a FOR LOOP. There are more efficient ways to achieve the result we achieved above, but this lesson's example allowed you to see how each part became a building block for the next. 




``` sql

```
``` sql

```
