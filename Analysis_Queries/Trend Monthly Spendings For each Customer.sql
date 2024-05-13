select 
    CUSTOMER_ID,
    to_char(ORDER_DATE, 'MM-YYYY') as month_year,
    round(sum(SELLING_PRICE_FOR_DELIVERED)) as monthly_spending,
    rank() over (partition by CUSTOMER_ID order by to_char(ORDER_DATE, 'MM-YYYY')) as month_rank
from 
    pizzaorders
group by 
    CUSTOMER_ID, to_char(ORDER_DATE, 'MM-YYYY')
order by 
    CUSTOMER_ID, to_char(ORDER_DATE, 'MM-YYYY');