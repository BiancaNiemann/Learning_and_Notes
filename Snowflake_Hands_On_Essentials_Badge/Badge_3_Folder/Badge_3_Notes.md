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
  




#### Keyword
* Streamlit
* File formats
* Stages
* Some basic python code - for loops and if statements
* Rapid prototyping
  









``` sql

```
``` sql

```
``` sql

```
