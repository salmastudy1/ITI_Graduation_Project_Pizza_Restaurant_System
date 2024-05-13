with customer_spending as (
    select 
        CUSTOMER_ID, 
        sum(total_invoice_amount) as total_spending
    from (
        select 
            CUSTOMER_ID, 
            to_char(ORDER_DATE, 'MM-YYYY') as order_month,
            sum(SUM_OF_QUANTITY * SELLING_PRICE_FOR_DELIVERED) as total_invoice_amount
        from 
            pizzaorders
        group by 
            CUSTOMER_ID, 
            TO_CHAR(ORDER_DATE, 'MM-YYYY')
    )
    group by 
        CUSTOMER_ID
),
customer_ranking as (
    select 
        CUSTOMER_ID,
        total_spending,
        NTILE(5) over (order by total_spending desc) as spending_group,
        case
            when dense_rank() over (order by total_spending desc) = 1 then 'Gold'
            when dense_rank() over (order by total_spending desc) = 2 then 'Silver'
            when dense_rank() over (order by total_spending desc) = 3 then 'Bronze'
            else 'Regular'
        end as customer_tier
    from 
        customer_spending
)
select 
    CUSTOMER_ID,
    round(total_spending),
    spending_group,
    customer_tier
from 
    customer_ranking;