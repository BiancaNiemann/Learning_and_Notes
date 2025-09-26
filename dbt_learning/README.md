
# 📊 dbt Personal Notes

## 🧠 Learning dbt
- ETL vs ELT
- Models
- Tests (Generic & Singular)
- Macros
- YAML & Jinja
- DAG (Directed Acyclic Graph)

## ⚡ Shortcuts
- `__` → Shows all keyboard shortcuts

## 🛠️ Common Commands
```bash
dbt build
dbt run                       # Updates and loads to Snowflake (or other data warehouse)
dbt run --select model_name   # Runs only a specific model
dbt test
dbt test --select test_type:generic
dbt test --select test_type:singular
dbt test --select model_name
```

## 📁 Project Structure & File Locations
- Models map 1:1 to tables/views in the warehouse
- SQL model files go into the `models/` folder
- Use feature branches for changes (`git`)
- Use modular, reusable staging models like `stg_customers.sql`, `stg_orders.sql`
- Use `ref()` and `source()` functions to maintain clean dependencies

## 🧱 Modularity
- Think like a software engineer: break transformations into logical steps
- Example:
  - `stg_customers` and `stg_orders` (from source)
  - → Used in `dim_customers`

### `ref()` Example
```sql
SELECT * FROM {{ ref('stg_customers') }}
```

### `source()` Example
```sql
SELECT * FROM {{ source('jaffle_shop', 'customers') }}
```

## 🏷️ Naming Conventions

| Type          | Prefix | Description                                                 |
|---------------|--------|-------------------------------------------------------------|
| Source        | (src)  | Raw tables loaded to warehouse                              |
| Staging       | `stg_` | Light transformations, rename columns, standardize, clean   |
| Intermediate  | `int_` | Models between staging and final outputs                    |
| Fact          | `fct_` | Events or transactions (orders, sessions, clicks)           |
| Dimension     | `dim_` | Entities that exist (people, customers, products, etc.)     |

## 🗂️ Reorganize Your Project
- Remove example folders
- Create subfolders in `models/`:
  - `staging/`
  - `marts/` → Can include `marketing/`, `finance/`, etc.
- Update `dbt_project.yml`:

```yaml
models:
  jaffle_shop:
    marts:
      materialized: table
    staging:
      materialized: view
```

## 📦 Understanding Sources

### What are Sources?
- Represent raw data loaded into the warehouse
- Defined in YAML
- Enable features like source freshness checks
- Green nodes in the DAG

### Example `schema.yml`
```yaml
version: 2

sources:
  - name: jaffle_shop
    database: raw
    schema: jaffle_shop
    tables:
      - name: customers
      - name: orders
```

### Referencing with `source()`
```sql
SELECT
    id AS customer_id,
    first_name,
    last_name
FROM {{ source('jaffle_shop', 'customers') }}
```

## ⏰ Source Freshness

### YAML block:
```yaml
freshness:
  warn_after: {count: 6, period: hour}
  error_after: {count: 12, period: hour}
loaded_at_field: _etl_loaded_at
```

### Run freshness check:
```bash
dbt source freshness
```

## ✅ Building Tests

### 🧪 Generic Tests (in YAML)
- `unique`
- `not_null`
- `accepted_values`
- `relationships` (foreign key)

```yaml
columns:
  - name: customer_id
    tests:
      - unique
      - not_null
```

### 🧾 Singular Tests (Custom SQL)
```sql
-- tests/not_active_users.sql
SELECT *
FROM {{ ref('dim_users') }}
WHERE is_active = FALSE AND signup_date IS NULL
```

## 📝 Documentation

- Keep docs next to your code in YAML
- Use descriptions at:
  - Model level
  - Column level
  - Use `docs()` blocks for detailed markdown

### Example:
```yaml
models:
  - name: dim_orders
    description: "This table contains cleaned and joined order data."
    columns:
      - name: order_status
        description: "{{ doc('order_status') }}"
```

```sql
{% docs order_status %}
The status of the order:
- `placed`
- `shipped`
- `returned`
{% enddocs %}
```

### Generate docs:
```bash
dbt docs generate
```
- View docs via the 📘 icon in dbt Cloud
- View lineage graph from raw to final

## 🚀 Deployment

### Development vs. Deployment
- **Development**: Personal branch/schema (`dbt_yourname`)
- **Deployment**: Production schema (`dbt_prod`), default branch (e.g., `main`)

### Environment Setup
- Use separate deployment credentials
- Deployment schema ≠ development schema

### Scheduling Jobs (in dbt Cloud)
- Create a Job:
  - Environment: deployment
  - Commands: e.g., `dbt run`, `dbt test`
  - Schedule: cron or time-based
- Monitor via Job History & Logs

---

🧠 Want more? Explore [Advanced Deployment](https://courses.getdbt.com) for CI/CD, branching workflows, and job orchestration!
