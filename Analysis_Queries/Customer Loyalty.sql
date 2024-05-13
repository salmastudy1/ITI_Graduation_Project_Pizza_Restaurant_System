with customer_summary as (
    SELECT DISTINCT 
        CUSTOMER_ID,
        count(order_ID) over(partition by CUSTOMER_ID) as Frequency,
        to_date(max(order_date) over(partition by CUSTOMER_ID), 'DD/MM/YYYY') as last_purchase_date,
        ceil(sum(sum_of_quantity * SELLING_PRICE_FOR_DELIVERED) over(partition by CUSTOMER_ID)) as Monetary,
        ceil(MONTHS_BETWEEN(sysdate, to_date(max(order_date) over(partition by CUSTOMER_ID), 'DD/MM/YYYY'))) as Recency_months
    FROM
        pizzaorders
),
ntiles as (
    select
        customer_id,
        Frequency,
        last_purchase_date,
        Monetary,
        Recency_months,
        ntile(5) over(order by Recency_months desc) as r_score,
        ntile(5) over(order by Monetary ) as m_score,
        ntile(5) over(order by Frequency ) as f_score
    from
        customer_summary
),
FM_SCORE as (
    select
        Customer_id,
        Frequency,
        last_purchase_date,
        Monetary,
        Recency_months,
        r_score,
        m_score,
        f_score,
        round((m_score + f_score) / 2) as fm_score
    from  ntiles
)


select
        Customer_id,
        Frequency,
        last_purchase_date,
        Monetary,
        Recency_months,
        r_score,
        m_score,
        f_score,
        fm_score,
        case
          when  (r_score= 5 and  fm_score= 5) or
                     (r_score= 5 and  fm_score= 4) or
                     (r_score= 4 and  fm_score= 5) then 'Champions'
                     
          when (r_score = 5 and fm_score = 3) or
                    (r_score = 4 and fm_score = 4) or
                    (r_score = 3 and fm_score = 5) or
                    (r_score = 3 and fm_score = 4) then 'Loyal Customers'
                   
          when (r_score = 5 and fm_score = 2) or
                    (r_score = 4 and fm_score = 2) or
                    (r_score = 3 and fm_score = 3) or
                    (r_score = 4 and fm_score = 3) then 'Potential Loyalists'
                   
          when (r_score = 5 and fm_score = 1) then 'Recent Customers'
         
          when (r_score = 4 and fm_score = 1) or
                    (r_score = 3 and fm_score = 1) then 'Promising'
                   
          when (r_score = 3 and fm_score = 2) or
                    (r_score = 2 and fm_score = 3) or
                    (r_score = 2 and fm_score = 2) then 'Customers Needing Attention'
                   
          when (r_score = 2 and fm_score = 5) or
                     (r_score = 2 and fm_score = 4) or
                     (r_score = 1 and fm_score = 3) then 'At Risk'
                   
          when (r_score = 1 and fm_score = 5) OR
                     (r_score = 1 and fm_score = 4) then 'Can not lose them'
                   
          when (r_score = 1 and fm_score = 2) then 'Hibernating'
         
          when (r_score = 1 and fm_score = 1) then 'Lost'
         
          else 'Unclassified'
        end as customer_segment

from FM_SCORE
order by customer_id;
