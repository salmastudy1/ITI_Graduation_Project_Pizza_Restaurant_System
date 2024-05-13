set serveroutput on
declare
  v_available_table_id varchar2(4000);
  v_total_capacity number;
  v_merge_required varchar2(1);
  o_guest_preferece_location varchar2(255);
begin
  -- Call the procedure and handle the exception
  begin
    core.check_table_availability(
      20,
      'Dine-In',
      'Any',
      o_guest_preferece_location,
      v_available_table_id,
      v_total_capacity,
      v_merge_required
    );
  exception
    when TOO_MANY_ROWS then
      -- Handle the case when the query returns more than one row
      DBMS_OUTPUT.PUT_LINE('Error: Too many rows returned.');
    when others then
      -- Handle other exceptions
      DBMS_OUTPUT.PUT_LINE('Error: ' || SQLERRM);
  end;

  -- Display the output
  if v_available_table_id is not null then
    DBMS_OUTPUT.PUT_LINE('Available Table ID: ' || v_available_table_id);
    DBMS_OUTPUT.PUT_LINE('Total Capacity: ' || v_total_capacity);
    DBMS_OUTPUT.PUT_LINE('Merge Required: ' || v_merge_required);
    DBMS_OUTPUT.PUT_LINE('Location: ' || o_guest_preferece_location);
  else
    DBMS_OUTPUT.PUT_LINE('No available table found.');
  end if;
end;
/
