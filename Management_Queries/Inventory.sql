CREATE OR REPLACE PROCEDURE ProcessOrder2(orderID in varchar2)
is
  usedQuantity number(10, 2);
begin
  -- Retrieve order details
  for pizza in (select pizza_id, quantity from order_details where order_id = orderID) loop
  
    -- Retrieve price and calculate usage for each pizza size
    for price in (select Item_id, sizee from prices where pizza_id = pizza.pizza_id) loop 
      for cry in (select r.ingredient_id, r.sizee, r.MEASURE_GMS * pizza.quantity as used_quantity 
                  from recipe r
                  where r.item_id = price.Item_id and r.sizee = price.sizee) loop
    
        -- Update inventory
        update inventory 
        set QUANTITY_GM = QUANTITY_GM - cry.used_quantity
        where ingredient_id = cry.ingredient_id;
         
        -- Check stock levels
        for inv in (select QUANTITY_GM, min_stock_level_gm from inventory where ingredient_id = cry.ingredient_id) loop
          if inv.QUANTITY_GM < inv.min_stock_level_gm then
            -- Mark item as unavailable
            update menu 
            set ITEM_AVAILABILTY = 'no' 
            where item_id in (select item_id from recipe where ingredient_id = cry.ingredient_id);

          end if;
        end loop;
       
      end loop; -- End of inner loop
    end loop; -- End of price loop
  end loop; -- End of outer loop
end;
/
show errors;


INSERT INTO orders (order_id, order_date, order_time, payment_method, order_type, num_guests, order_status, order_left, emp_id, location, cust_id)
VALUES ('207', TO_DATE('2024-04-23', 'YYYY-MM-DD'), TO_TIMESTAMP('08:30:00', 'HH24:MI:SS'), 'will not pay', 'Dine-In', 4, 'Pending', 'No', '1009', 'Main Dining Area', 'C0109');

INSERT INTO order_details (order_details_id, order_id, pizza_id, quantity)
VALUES ('1615', '207', 'calabrese_l', 1000);

INSERT INTO order_details (order_details_id, order_id, pizza_id, quantity)
VALUES ('1611', '203', 'calabrese_m', 1);

CALL ProcessOrder2('207');
