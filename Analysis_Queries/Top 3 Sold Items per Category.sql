select category, name, total_sold
from (
    select category, name, total_sold,
           row_number() over (partition by category order by total_sold desc) as name_rank
    from (
        select category, name, sum(sum_of_quantity) as total_sold
        from pizzaorders inner join menu on substr(pizza_id, 1, length(pizza_id) - instr(reverse(pizza_id), '_')) = menu_id
        group by category, name
    ) sales_by_category
) ranked_names
where name_rank <= 3;