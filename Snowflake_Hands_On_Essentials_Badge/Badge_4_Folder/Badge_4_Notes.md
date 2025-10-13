# Badge 4 - Datalake Warehouse

#### Keywords:
- Proof of concept - what I propose
- Rapid prototyping - each time fix up what I am proposing a bit more.
- Stages
- Directory Tables
- Structured, Semi Structured and Unstructured data
- Loaded and non-loaded data
- When some data is loaded and some is left in non-loaded state, the 2 types can be joined and queried together, also called a DATA LAKEHOUSE

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




