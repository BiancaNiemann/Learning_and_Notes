# Badge 3: Data Application Builders Workshop

- Snowflake in 2012, Streamlit in 2018 then in 2022 Snowflake bought Streamlit and now 2 versions
- One version is the original standalone and you dont need Snowflake to use it, the other is integrated with Snowflake and also called 'SiS'
- Create SMOOTHIES database and checke owned by SYSADMIN
- Set default Role to SYSADMIN and default warehouse to COMPUTE_WH

- Create a new order form
- Projects
    - Streamlit - streamlit App
        - Fill in the details and select the database (SMOOTHIS) and schema(PUBLIC) and app warehouse(COMPUTE_WH) (Make sure owner is SYSADMIN)

- you will get a template code (see template_code.js) that you can change to suit what you need
- documentation on https://docs.streamlit.io/develop/api-reference/widgets/st.selectbox
- need to create a table to load a selection of fruit choices
 
``` sql
CREATE TABLE FRUIT_OPTIONS
(
    FRUIT_ID NUMBER,
    FRUIT_NAME VARCHAR(25)
)
```
- Now create a file format to load the txt file
``` sql
create file format smoothies.public.two_headerrow_pct_delim
   type = CSV,
   skip_header = 2,   
   field_delimiter = '%',
   trim_space = TRUE
;
```
- Now create an internal stage and load that text file into it
  - Create - Stage - Snowflake Managed
  - Give it a name eg: my_uploaded_files
  - Client side encryption
  - Select the file and upload
  - Should now see the file in the staged area in the smoothies database
``` sql
SELECT $1, $2, $3, $4, $5
FROM '@"SMOOTHIES"."PUBLIC"."MY_UPLOADED_FILES"/fruits_available_for_smoothies.txt'
(FILE_FORMAT => TWO_HEADERROW_PCT_DELIM);
```
- Will show you what the file looks like
- For more documentation - https://docs.snowflake.com/en/user-guide/data-load-transform#reorder-csv-columns-during-a-load
- This code wont work as the txt file has the fruit_id in the second column
``` sql
COPY INTO smoothies.public.fruit_options
from @smoothies.public.my_uploaded_files
files = ('fruits_available_for_smoothies.txt')
file_format = (format_name = smoothies.public.two_headerrow_pct_delim)
on_error = abort_statement
validation_mode = return_errors
purge = true;
```
- So need to adjust it to look like this
``` sql
COPY INTO smoothies.public.fruit_options
from ( select $2 as FRUIT_ID, $1 as FRUIT_NAME
from @smoothies.public.my_uploaded_files/fruits_available_for_smoothies.txt)
file_format = (format_name = smoothies.public.two_headerrow_pct_delim)
on_error = abort_statement
purge = true;
```
- To see a list of python libraries compatible https://repo.anaconda.com/pkgs/snowflake/
- Not all work with Snowpark so test to see

### Some Lingo
📓  Stakeholders, Customers, Requirements & Prototypes
- First, "STAKEHOLDERS" - Mel, Melanie and Igor are all Stakeholders in this project because their jobs are affected by how the app turns out. 
- For Mel (the Developer), his mom Melanie is his "CUSTOMER" because it is her "REQUIREMENTS" he has to meet. 
- When Melanie says, "I like that font!" or "Can you change the color of the background," she, as the Customer, is expressing "CUSTOMER REQUIREMENTS." 
- Since Mel and Melanie have a strong relationship, he can trust her not to keep changing her mind and claiming she didn't. Because of their relationship their requirements don't require official documentation. But, if Mel were working for someone else, he might want to keep a record of every decision using email or some other written document. 
- A "PROTOTYPE" is a semi-working version of something that helps STAKEHOLDERS discuss project REQUIREMENTS. In the 1980s and 1990s, teams used to spend months writing up an official Requirements Document and only when all stakeholders had "signed off" was the document passed to the developers. This was called a "Waterfall Method" -- you can research SDLC Waterfall Method and read more about it if you are curious. SDLC stands for Systems Development Life Cycle and just means "process or method for developing software."
- Then, Rapid Prototyping (RAD, Agile, and others) became more popular. Mel doesn't realize it, but he's using an ITERATIVE SDLC, and it's based on RAPID PROTOTYPING.
- Using a rapid prototyping approach, Mel just builds whatever he can in a week and then on Saturdays, when Melanie is using her treadmill for her morning run, he gets her feedback.
- So that's what he's doing now; He's presenting his version 1 prototype and getting her opinions on what is good, what needs to be changed, what needs to be added, and what things they forgot to consider. 
- Things to do or changes to make called ACTION ITEMS
- Can COMMIT to doing something, or commit to RESEARCHING or TABLE something till later
- Need to know what are the 'must haves' and the 'nice to haves'
- Short timeframes for planning are called SPRINTS
- With rapid prototyping - no date set in far futre, rather do as much as possible in the time given and then show customer what you have so far and get input for what comes next

- Some more stramlit documentation to add a namebox - https://docs.streamlit.io/library/api-reference/widgets/st.text_input

#### Set up a sequence
- In the database, select Create - Sequence
- Use this to create a unique id for each row in the requested table
- Table cannot have any rows so use TRUNCATE to clear the table
``` sql
create sequence order_seq
    start = 1
    increment = 2
    ORDER
    comment = 'Provide a unique id for each smoothie order';
```
- Now add it to the table
``` sql
alter table SMOOTHIES.PUBLIC.ORDERS 
add column order_uid integer --adds the column
default smoothies.public.order_seq.nextval  --sets the value of the column to sequence
constraint order_uid unique enforced; --makes sure there is always a unique value in the column
```

#### Always check everything is owned by SYSADMIN

- To create a maximum limit use max_selections = (amount)

####  Interface
- we use our hands, eyes and ears to interface with our phobes
- Phones use screen and speakers or vibrate to Interface with us
- We use a remote to interface with TV and then TV interfaces with us by changing something on screen or volume
- IOT (Internet of Things) - devices that interface with technology - eg Alexa or Siri

#### Request and responses
- Type in something to search internet and hit enter - send a REQUEST
- What is returned by website is called a RESPONSE
- REQUESTS and RESPONSES are sent using internet protocol called HTTPS
- UI refers to a page that is rendered in a web browser
- GUIs are Graphical User Interfaces
- GUIs amd CLIs have begun to merge (Docker, DBT and Notebooks involve CLI typed commands entered in GUIs)
- GUIs and CLIs are both UIs
- When you search fav website, you interface with a GUI
- when the GUI interfaces with a database to process REQUEST and return a RESULT, the webssite is using an Application Programming Interface(AOI) to interact with the database

#### What is a variable
- Used in computing to change values while code is actually running
- Can create a variable in Snowflake worksheet and us in other commands and long as all run in same worksheet
- A worksheet in snowflake also a 'session'
- $ only used for a local variable
``` sql
-- setting a variable
set mystery_Bag = 'What is in here';

-- Display the variable
select $mystery_bag;

-- more with variables
set var1 = 2;
set var2 = 5;
set var3 = 7;

select $var1+$var2+$var3;
```
#### What is a function
-  function is a way to make your code more organised
-  something you plan to do many times can go in a little module called a FUNCTION
  - Give it a name
  - Tell it what you are sending to it (if anything)
  - Tell it what its job is
  - Tell it what to send back if needed
  - Dont need to use $ unless using a local variable and sending them to the function
``` sql
-- Create a function
create function sum_mystery_bag_vars (var1 number, var2 number, var3 number)
returns number as 'select var1+var2+var3';

select sum_mystery_bag_vars(12, -36, 204);

-- if using a local variable
set this = -10.5 ;
set that = 2;
set the_other = 1000 ;

select sum_mystery_bag_vars($this, $that, $the_other);
```

#### User-Defined function
- Snowflake comes with hundreds of functions already defined.
- when defining own functions can also use system functions as part of logic
- INITCAP() to update a string, makes first letter capital and the rest lower case
``` sql
set alternating_caps_phrase = 'aLtErNaTiNg CaPs!';
select INITCAP($alternating_caps_phrase);
```

#### GitHub is a way to share code with coder friends
- Is a Social Network
- BUT also a version managemnet system
- Can store and share code, and people can ask for an get copies
- Streamlit requires you to have a Github account (not SiS)


#### Keywords
* Streamlit
* File formats
* Stages
* Some basic python code - for loops and if statements
* Rapid prototyping
* Sequences
* max_selections (st.multiselect) Streamlit property
* REQUESTS and RESPONSES
* Variables and Functions



``` sql

```
``` sql

```
``` sql

```
