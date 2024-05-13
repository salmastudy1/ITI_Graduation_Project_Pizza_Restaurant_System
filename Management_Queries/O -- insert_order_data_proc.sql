CREATE OR REPLACE PROCEDURE insert_order_data_proc (
    p_order_id in varchar2,
    p_order_date in date,
    p_order_time in date,
    p_payment_method in varchar2,
    p_type_of_order in varchar2,
    p_number_of_guests in number,
    p_status_of_order in varchar2,
    p_is_left in varchar2,
    p_emp_id in varchar2,
    p_location in varchar2,
) as
    v_available_table_id varchar2,(100);
    v_total_capacity number,
    v_merge_required varchar2,(1);
    v_guest_preferece_location varchar2,(255);
begin
if p_type_of_order = 'Dine-In' then
    -- Check table availability
    core.check_table_availability(
        p_number_of_guests,
        p_type_of_order,
        p_location,
        v_guest_preferece_location,
        v_available_table_id,
        v_total_capacity,
        v_merge_required
    );

    -- If no available table found, raise an exception
    if v_available_table_id is null then
        RAISE_APPLICATION_ERROR(-20001, 'No suitable table available for the order.');
    end if;

    -- Insert data into Orders_seating table
    insert into core.orders_seating (Order_id, Table_id) VALUES (p_order_id, v_available_table_id);

    -- Update the availability of the assigned table to 'N'
    update core.tables
    set availability = 'N'
    where table_id = v_available_table_id;
  end if;
end;
/ show errors
