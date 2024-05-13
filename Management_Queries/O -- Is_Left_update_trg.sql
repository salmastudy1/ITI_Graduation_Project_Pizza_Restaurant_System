CREATE OR REPLACE TRIGGER order_after_update_trigger
AFTER UPDATE OF is_left ON core.Orders
FOR EACH ROW
declare
    v_table_id varchar2(100); -- Assuming the table_id is VARCHAR2(100)
begin
    -- Check if the order status indicates that the customer has left
    IF :OLD.is_left <> :NEW.is_left AND :NEW.is_left = 'Y' THEN
        -- Retrieve the table_id for the given Order_id from the Orders_seating table
        select Table_id into v_table_id
        from core.Orders_seating
        where Order_id = :NEW.Order_id;

        -- Update the availability of the table to 'Y'
        update core.tables
        set availability = 'Y'
        where table_id = v_table_id;
    end if;
exception
    when NO_DATA_FOUND then
        DBMS_OUTPUT.PUT_LINE('No record found for the given Order_id.');
    when OTHERS then
        DBMS_OUTPUT.PUT_LINE('Error: ' || SQLERRM);
end;
/
