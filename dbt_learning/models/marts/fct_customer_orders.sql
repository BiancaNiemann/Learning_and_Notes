with

    -- Import CTEs
    orders as (select * from {{ ref("int_orders") }}),

    customers as (select * from {{ ref("stg_jaffle_shop_customers") }}),

    -- -
    customer_orders as (
        select
            orders.*,
            customers.full_name,
            customers.surname,
            customers.givenname,

            -- customer level aggregation
            min(orders.order_date) over (
                partition by orders.customer_id
            ) as customer_first_order_date,

            min(orders.valid_order_date) over (
                partition by orders.customer_id
            ) as customer_first_non_returned_order_date,

            max(orders.valid_order_date) over (
                partition by orders.customer_id
            ) as customer_most_recent_non_returned_order_date,

            count(*) over (partition by orders.customer_id) as customer_order_count,

            sum(nvl2(orders.valid_order_date, 1, 0)) over (
                partition by orders.customer_id
            ) as customer_non_returned_order_count,

            sum(nvl2(orders.valid_order_date, orders.order_value_dollars, 0)) over (
                partition by orders.customer_id
            ) as customer_total_lifetime_value,

            array_agg(distinct orders.order_id) over (
                partition by orders.customer_id
            ) as customer_order_ids

        from orders
        inner join customers on orders.customer_id = customers.customer_id

    ),

    add_avg_order_values as (
        select
            *,
            customer_total_lifetime_value
            / customer_non_returned_order_count as customer_avg_non_returned_order_value
        from customer_orders
    ),

    final as (

        select
            customer_id,
            order_id,
                        surname as customer_last_name,
            givenname as customer_first_name,
            customer_first_order_date as order_placed_at,
            order_status,
            order_value_dollars as total_amount_paid,
            row_number() over (order by order_id) as transaction_seq,
            row_number() over (
                partition by customer_id order by order_id
            ) as customer_sales_seq,
            --customer_order_count as order_count,
            --customer_total_lifetime_value as total_lifetime_value,
            customer_total_lifetime_value as customer_lifetime_value,
            customer_first_order_date as fdos

            --payment_status

        from add_avg_order_values

    )

-- Simple Select Statement
select *
from final
