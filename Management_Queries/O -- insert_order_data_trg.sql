CREATE OR REPLACE TRIGGER order_insert_trigger
BEFORE INSERT ON core.Orders -- Trigger fires before insertion
FOR EACH ROW
begin
    select Order_id_seq.NEXTVAL into orders_package.g_current_order_id from dual;
    :new.Order_id := orders_package.g_current_order_id;
    -- Call the procedure to handle the insertion of order data
    insert_order_data_proc(
        :NEW.Order_id,
        :NEW.Order_Date,
        :NEW.Order_Time,
        :NEW.Payment_Method,
        :NEW.Type_of_Order,
        :NEW.Number_of_Guests,
        :NEW.Status_of_Order,
        :NEW.is_left,
        :NEW.Emp_ID,
        :NEW.Location
    );
end;
/show errors