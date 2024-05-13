select 
    customer_id, 
    order_date, 
    round(total_invoice_amount,2),
    round(lag(total_invoice_amount) over (partition by customer_id order by to_date(order_date, 'DD-MON-YY') asc),2) as previous_invoice_total_amount,
    round(total_invoice_amount - lag(total_invoice_amount) over (partition by customer_id order by to_date(order_date, 'DD-MON-YY') asc),2) as amount_change,
    to_char(to_date(order_date, 'DD-MON-YY'), 'Month') as purchase_month
from 
(
    select 
        customer_id, 
        order_date, 
        sum(sum_of_quantity * SELLING_PRICE_FOR_DELIVERED) over (partition by customer_id, to_char(to_date(order_date, 'DD-MON-YY'))) as total_invoice_amount
    from 
        pizzaorders
) invoice_totals;