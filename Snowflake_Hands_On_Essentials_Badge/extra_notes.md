## Snowflake SQL Functions worth remembering

- IFF (capact alternative to CASE WHEN)
```sql
SELECT
  amount,
  IFF(amount > 0, 'Profit', 'Loss') AS status
FROM sales;
```
- QUALIFY (Filter on window function, no sub query needed)
```sql
SELECT
  customer_idd,
  order_date,
  ROW_NUMBER() OVER(
    PARTITION BY custoemr_id
    ORDER BY order_date DESC
  ) AS rn
FROM orders
QUALIFY rn= 1;
```
- Latteral Flatten (Query JSON arrays without ETL
```sql
SELECT
  value:id, value:name
FROM my_table,
LATTERAL FLATTEN (
  input => PARSE_JSON(json_col):items
);
```
- Time SLice (Bucket timestamps into fixed intervals
```sql
SELECT
  TIME_SLICE(event_time, 15, 'MINUTE') AS bucket,
  COUNT(*) AS events
FROM events
GROUP BY bucket;
```
--UUID_STRING() (Generate unique ids)
```sql
SELECT
  product_id, category, brand
  UUID_STRING() AS product_key
FROM products;
```

```sql

```
