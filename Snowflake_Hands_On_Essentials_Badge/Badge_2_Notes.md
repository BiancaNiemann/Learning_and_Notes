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


``` sql

```
