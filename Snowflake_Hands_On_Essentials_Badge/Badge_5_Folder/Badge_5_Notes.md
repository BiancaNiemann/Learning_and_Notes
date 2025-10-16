# Badge 5: Data Engineering Workshop

- create a database and scheme
- create a stage to load the json file
- create a file format to read the json file
- Copy data into the raw table in the scheme we created
- create a view with the data sorted into columns using JSON parsing

- Worksheet also reffered to as a session

- if time in denver was 2022-10-15T19:22:00 (Denver time is 6 hours behind UTC) so that would mean in UTC timezone it is 2022-10-16T1:22:00

```sql
select tod_name, listagg(hour,',') 
from time_of_day_lu
group by tod_name;
```
- Using listagg(col, seperator will create a list of all values when you use groupby

### Schedule Task
<img width="1035" height="597" alt="image" src="https://github.com/user-attachments/assets/892049ad-e3e5-4cbe-a2bd-21e22004e0ef" />
<img width="929" height="573" alt="image" src="https://github.com/user-attachments/assets/1085ab84-c0ee-4f25-81b3-3460a4cc97a9" />

- IDEMPOTENCY. 
- In short, it means, Kishore can't just write cool stuff that loads data, he has to design a solution that ONLY loads each record one time.
- Snowflake has some built in help for IDEMPOTENCY, especially when the file is first picked up from the stage, and we'll talk more about how Snowflake can help with that, but right now we'll focus on making this particular step IDEMPOTENT.

### 📓 We Have A Data Pipeline!
By "data pipeline" we mean:
- A series of steps...
- that move data from one place to another...
- in a repeated way.

### 📓 Cloud-Based Services for Modern Data Pipelines
- Modern data pipelines depend on cloud-based services offered by major cloud providers like Amazon Web Services (AWS), Microsoft Azure, and Google Cloud Platform (GCP). 
- Creating an Event-Driven Pipeline in Snowflake depends on 3 types of services created and managed by the cloud providers.
- <img width="966" height="333" alt="image" src="https://github.com/user-attachments/assets/3fc261e4-09ff-484a-b096-7ab006a43ad2" />

#### STORAGE
- AWS - S3 Buckets
- Azure - Blob Storage
- GCP - GCS Buckets

#### PUBLISH & SUBSCRIBE NOTIFICATION SERVICES (Hub & Spoke)
- AWS - Simple Notification Services (SNS)
- Azure - Azure Web PubSub and Azure Event Hub
- GCP - Cloud Pub/Sub

#### MESSAGE QUEUING  (Linear Messaging)
- AWS - Simple Queue Services (SQS)
- Azure - Azure Storage Queues and Azure Service Bus Queues
- GCP - Cloud Tasks

### 📓 A Closer Look at Pub/Sub Services
- Publish and Subscribe services are based on a Hub and Spoke pattern.
- The HUB is a central controller that manages the receiving and sending of messages.
- The SPOKES are the solutions and services that either send or receive notifications from the HUB. 
- If a SPOKE is a PUBLISHER, that means they send messages to the HUB.
- If a SPOKE is a SUBSCRIBER, that means they receive messages from the HUB.
- A SPOKE can be both a publisher and a subscriber.
- <img width="753" height="435" alt="image" src="https://github.com/user-attachments/assets/e9ff1131-886a-47ab-a26f-fab41cb0a54a" />
- With messages flowing into and out of a Pub/Sub service from so many places, it could get confusing, fast.
- So Pub/Sub services have EVENT NOTIFICATIONS and TOPICS.
- A topic is a collection of event types.
- A SPOKE publishes NOTIFICATIONS to a TOPIC and subscribes to a TOPIC, which is a stream of NOTIFICATIONS. 
- <img width="854" height="336" alt="image" src="https://github.com/user-attachments/assets/04efa1b8-a86b-4ab9-88e3-f0d5be0219c5" />
- <img width="1046" height="551" alt="image" src="https://github.com/user-attachments/assets/5751fc18-64e8-42a8-9f84-3c8a5682bf5d" />
- <img width="942" height="538" alt="image" src="https://github.com/user-attachments/assets/66a5f8a3-89ed-48f8-b901-6354e5fd30e7" />
- <img width="963" height="592" alt="image" src="https://github.com/user-attachments/assets/29eb8782-73db-4942-83a3-3926b1194441" />
- <img width="923" height="550" alt="image" src="https://github.com/user-attachments/assets/b99f764a-2374-4cc7-81e4-7ec11f721e21" />
Here is a video to watch the process : https://www.youtube.com/watch?v=RjSW75YsBMM&t=1096s
- <img width="966" height="671" alt="image" src="https://github.com/user-attachments/assets/75d8123b-e208-4cf2-8df9-4f6a56c3d577" />
- <img width="931" height="662" alt="image" src="https://github.com/user-attachments/assets/fef6ef4b-fe1a-46ff-8bf6-1b983c30e1e3" />
- <img width="960" height="503" alt="image" src="https://github.com/user-attachments/assets/91953c0f-d5f4-4dbf-88ed-cbb6e11c6e71" />
- <img width="956" height="570" alt="image" src="https://github.com/user-attachments/assets/1bd7612e-423b-461b-97e5-550841fc1541" />
- <img width="965" height="696" alt="image" src="https://github.com/user-attachments/assets/7c737de6-6ec4-4375-9601-cfa88eb82695" />
- <img width="997" height="578" alt="image" src="https://github.com/user-attachments/assets/3457712c-526a-45bc-882b-7f87271065cc" />
- <img width="937" height="637" alt="image" src="https://github.com/user-attachments/assets/ae12aa2d-c7fd-4201-abc8-2f7d2cd2aabf" />
- When you start building pipelines with smart triggers and lots of fancy logic, that's called ORCHESTRATION!
- ORCHESTRATION is WOW!














