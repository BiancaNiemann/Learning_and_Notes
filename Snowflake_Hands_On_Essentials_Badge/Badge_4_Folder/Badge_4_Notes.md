# Badge 4 - Datalake Warehouse

#### Keywords:
- Proof of concept - what I propose
- Rapid prototyping - each time fix up what I am proposing a bit more.
- Stages
- Directory Tables
- Structured, Semi Structured and Unstructured data
- Loaded and non-loaded data
- When some data is loaded and some is left in non-loaded state, the 2 types can be joined and queried together, also called a DATA LAKEHOUSE
- Variables and Constants
- UDFs - User Defined Functions
- Materialised views, External Tables and Iceberg tables

#### Using unstructured Data
- Load images into stage
- Then used materialised view to make image and metadata behave like a table

- <img width="536" height="769" alt="image" src="https://github.com/user-attachments/assets/bf08e7f1-4e97-41d9-82fa-812a2ee0fc38" />

- <img width="885" height="546" alt="image" src="https://github.com/user-attachments/assets/938aa1d0-1aa8-441a-8903-7aeef561eb71" />

- <img width="875" height="545" alt="image" src="https://github.com/user-attachments/assets/cdb79b3c-92a3-473c-9098-221a7c070c17" />

When we first learned about stages and the staging of files, we said that Snowflake Internal tables (regular tables) were like the shelving in a real-world warehouse. With tables being a place where we would very deliberately place our data for long-term storage. We also claimed that the yellow areas on the floor of a a warehouse were like stages in Snowflake. 

- <img width="975" height="552" alt="image" src="https://github.com/user-attachments/assets/580565a3-8a8b-4ae4-bc0c-ed916998f31c" />

By the time we finished Badge 3: Data Application Builders Workshop, Mel understood the difference between External and Internal Stages, how to set them up and use them. He also understood that when we talk about "Stages" there are actually 3 parts. The cloud folder is the stage's storage location, the files within those locations are "staged data", and the objects we create in Snowflake are not locations, instead they are connections to cloud folders - which metaphorically can also be called "windows", or shown as loading bay doors on diagrams. 

- <img width="915" height="538" alt="image" src="https://github.com/user-attachments/assets/ff67dc9d-f90c-477a-9e97-ee280ee37608" />

As it turns out, a Snowflake Stage Object can be used to connect to and access files and data you never intend to load!!! 

Zena can create a stage that points to an external or internal bucket. Then, instead of pulling data through the stage into a table, she can reach through the stage to access and analyze the data where it is already sitting.

She does not have to load data, she can leave it where it is already stored, but still access it AND if she uses a File Format, she can make it appear almost as if it is actually loaded! (weird, but true!) 

- <img width="980" height="515" alt="image" src="https://github.com/user-attachments/assets/51608707-07d7-43d9-bfbf-23a9560f9bc4" />

#### REDEFINING THE WORD "STAGE" FOR SNOWFLAKE ADVANCED USE

We already know that in the wider world of Data Warehousing, we can use the word "stage" to mean "a temporary storage location", and we can also use "stage" to mean a cloud folder where data is stored -- but now, more than ever, we should open our mind to the idea that a defined Snowflake Stage Object is most accurately thought of as a named gateway into a cloud folder where, presumably, data files are stored either short OR long term. 

#### Non loaded Data

<img width="1027" height="542" alt="image" src="https://github.com/user-attachments/assets/5a120d24-5af4-405d-b318-f093b0be8517" />

- can even use a newly created column in select in the very next line, no need to use a sub query or a with statement

- <img width="1028" height="560" alt="image" src="https://github.com/user-attachments/assets/8d82a415-f889-4d9e-a0aa-9f429dd7f8a8" />



- <img width="897" height="200" alt="image" src="https://github.com/user-attachments/assets/5517d30c-f174-4c5d-9f7b-5bc0f8f2809c" />

- <img width="1028" height="560" alt="image" src="https://github.com/user-attachments/assets/58c050e2-9524-4c1c-a6ec-869a8c2cf7d3" />

- Materialized Views, and
- External Tables, and 
- Iceberg Tables! 
- Oh My! What are all these things? In short, all of these objects are attempts to make your less-normalized (possibly non-loaded) data look and perform like more-normalized (possibly loaded) data.
- To provide high performance access to data that has not been loaded.

### 📓  Materialized Views
- A Materialized View is like a view that is frozen in place (more or less looks and acts like a table).
- The big difference is that if some part of the underlying data changes,  Snowflake recognizes the need to refresh it, automatically.
- People often choose to create a materialized view if they have a view with intensive logic that they query often but that does NOT change often.
- We can't use a Materialized view on any of our trails data because you can't put a materialized view directly on top of staged data.

### 📓  External Tables
- An External Table is a table put over the top of non-loaded data (sounds like our recent views, right?).
- An External Table points at a stage folder(yep, we know how to do that!) and includes a reference to a file format (or formatting attributes) much like what we've been doing with our views for most of this workshop!
- Seems very straightforward and something within reach-- given what we've already learned in this workshop!
- But, if we look at docs.snowflake.com the syntax for External tables looks intimidating.
- Let's break it down into what we can easily understand and have experience with, and the parts that are little less straightforward.
- <img width="842" height="369" alt="image" src="https://github.com/user-attachments/assets/771aff87-9434-4746-a00b-29d4a5ac972f" />
- There are other parts that are somewhat new, but that don't seem complicated.
- In our views we define the PATH and CAST first and then assign a name by saying AS <column name>.
- For the external table we just flip the order. State the column name first, then AS, then the PATH and CAST column definition.
- Also, there's a property called AUTO_REFRESH -- which seems self-explanatory!
- <img width="854" height="355" alt="image" src="https://github.com/user-attachments/assets/71442a49-a9f3-4de5-a469-e399b4bfebca" />
- But External Tables seem like they have some weird, intense, unfamiliar things, too.
- Partitioning schemes and streaming message notification integrations are going to make more sense for Data Engineers (and the Data Engineering Hands-On Workshop!)
- <img width="912" height="497" alt="image" src="https://github.com/user-attachments/assets/7154af9c-4482-4fd6-9c55-08a96f6e50db" />


### 📓  Apache Iceberg Tables
- Iceberg is an open-source table type.
- The Apache Iceberg technology is owned by Apache and provided using an open-source license.
- Iceberg Tables are a layer of functionality you can lay on top of parquet files (just like the Cherry Creek Trails file we've been using) that will make files behave more like loaded data.
- In this way, it's like a file format, but also MUCH more.
- Iceberg Table data that can be editable via Snowflake! Read that again. Not just the tables are editable (like the table name), but the data they make available (like the data values in columns and rows).
- So, you will be able to create an Iceberg Table in Snowflake, on top of a set of parquet files that have NOT BEEN LOADED into Snowflake, and then run INSERT and UPDATE statements on the data using SQL 🤯.
- Apache Iceberg Tables make Snowflake's Data Lake options incredibly powerful!!

#### THIS CHANGES EVERYTHING

- People sometimes think of Snowflake as a solution for structured, normalized data (which they often call a Data Warehouse).
- For a while, people said Data Lakes were the only path forward. Lately, many people say the best solution is a Data Lakehouse (they're just mushing the two terms together and saying you need both).
- Snowflake can be all of those things and Iceberg tables is an amazing addition.
- Docs - https://docs.snowflake.com/en/user-guide/tutorials/create-your-first-iceberg-table
- 






