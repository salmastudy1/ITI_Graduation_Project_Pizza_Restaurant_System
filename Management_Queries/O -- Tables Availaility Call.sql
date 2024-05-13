-- Tables Availaility Call Test
INSERT INTO core.orders (Order_Date, Order_Time, Payment_Method, Type_of_Order, Number_of_Guests, Status_of_Order, is_left, Emp_ID, Location)
VALUES (SYSDATE, CURRENT_TIMESTAMP, 'Cash', 'Dine-In', 15, 'Delivered', 'N', '1030', 'Any');




select * from core.orders_seating;
select * from core.tables;
select * from core.orders;
