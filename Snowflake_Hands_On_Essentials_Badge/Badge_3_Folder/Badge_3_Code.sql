CREATE TABLE FRUIT_OPTIONS
(
    FRUIT_ID NUMBER,
    FRUIT_NAME VARCHAR(25)
);

create file format smoothies.public.two_headerrow_pct_delim
   type = CSV,
   skip_header = 2,   
   field_delimiter = '%',
   trim_space = TRUE
;

SELECT $1, $2, $3, $4, $5
FROM '@"SMOOTHIES"."PUBLIC"."MY_UPLOADED_FILES"/fruits_available_for_smoothies.txt'
(FILE_FORMAT => TWO_HEADERROW_PCT_DELIM);

COPY INTO smoothies.public.fruit_options
from @smoothies.public.my_uploaded_files
files = ('fruits_available_for_smoothies.txt')
file_format = (format_name = smoothies.public.two_headerrow_pct_delim)
on_error = abort_statement
validation_mode = return_errors
purge = true;

COPY INTO smoothies.public.fruit_options
from ( select $2 as FRUIT_ID, $1 as FRUIT_NAME
from @smoothies.public.my_uploaded_files/fruits_available_for_smoothies.txt)
file_format = (format_name = smoothies.public.two_headerrow_pct_delim)
on_error = abort_statement
purge = true;

--Create a table to store the order data from SiS
create table SMOOTHIES.PUBLIC.ORDERS
(
ingredients varchar(200)
);

-- test the insert code works
insert into smoothies.public.orders(ingredients) values ( 'Blueberries Cantaloupe ');
select * from orders;

-- this will clear the table
truncate table smoothies.public.orders;

-- add a column for the name of person ordering
alter table smoothies.public.orders add column name_on_order varchar(100);

insert into smoothies.public.orders(ingredients, name_on_order) values ( 'Blueberries Cantaloupe Dragon Fruit ', 'Bianca');

-- add order filled column to the table
alter table smoothies.public.orders add column order_filled BOOLEAN default false;

-- do a test to fill some rows with true
update smoothies.public.orders
set order_filled = true
where name_on_order is null;

-- Add the unique ID
alter table SMOOTHIES.PUBLIC.ORDERS 
add column order_uid integer --adds the column
default smoothies.public.order_seq.nextval  --sets the value of the column to sequence
constraint order_uid unique enforced; --makes sure there is always a unique value in the column

-- Just to check all correct
create or replace table smoothies.public.orders (
       order_uid integer default smoothies.public.order_seq.nextval,
       order_filled boolean default false,
       name_on_order varchar(100),
       ingredients varchar(200),
       constraint order_uid unique (order_uid),
       order_ts timestamp_ltz default current_timestamp()
);



-- setting a variable
set mystery_Bag = 'What is in here';

-- Display the variable
select $mystery_bag;

set var1 = 2;
set var2 = 5;
set var3 = 7;

select $var1+$var2+$var3;

-- Create a function
create function sum_mystery_bag_vars (var1 number, var2 number, var3 number)
returns number as 'select var1+var2+var3';

select sum_mystery_bag_vars($this, $that, $the_other);

set this = -10.5 ;
set that = 2;
set the_other = 1000 ;

set alternating_caps_phrase = 'aLtErNaTiNg CaPs!';
select INITCAP($alternating_caps_phrase);

create function NEUTRALIZE_WHINING (words TEXT)
returns 'select INITCAP(words)';

-- Add Search_On column
alter table SMOOTHIES.PUBLIC.ORDERS 
add column search_on varchar(100); --adds the column

-- removed as on wrong table
alter table SMOOTHIES.PUBLIC.ORDERS 
drop column search_on;

-- Add Search_On column to fruit_options table
alter table fruit_options
add column search_on varchar(100); --adds the column

-- Copy name to seed the columns - then we can edit the rows
update fruit_options
set search_on = fruit_name;

update fruit_options
set search_on = 'Ximenia (Hog Plum)'
where fruit_name = 'Ximenia';

select * from orders;
select * from fruit_options;

