create or replace procedure Add_Update_New_Customer(
    v_CustomerName in varchar2,
    v_Gender in varchar2,
    v_PhoneNumber in varchar2,
    v_DateOfBirth in date,
    v_FavoriteSinger in varchar2
)
is
    v_CustID hr.Customer.CUSTID%type;
begin
    -- Check if the customer exists
    select CUSTID into v_CustID
    from hr.Customer
    where PHONENUMBER = v_PhoneNumber;

    if v_CustID is null then
        -- Insert new customer
        insert into hr.Customer (CUSTID, CUSTOMERNAME, GENDER, TOTALORDERS, LASTORDERAT, PHONENUMBER, DATEOFBIRTH, FAVORITESINGER)
        values (customer_id_seq.NEXTVAL, v_CustomerName, v_Gender, 1, CURRENT_TIMESTAMP, v_PhoneNumber, v_DateOfBirth, v_FavoriteSinger);
        
        -- Get the last inserted customer ID
        select CUSTID into v_CustID from hr.Customer where PHONENUMBER = v_PhoneNumber;
    else
        -- Update existing customer's TotalOrders and LastOrderAt
        update hr.Customer
        set TOTALORDERS = TOTALORDERS + 1, LASTORDERAT = CURRENT_TIMESTAMP
        where CUSTID = v_CustID;
    end if;

    commit; 
exception 
    when NO_DATA_FOUND then
        DBMS_OUTPUT.PUT_LINE('No customer found for the given phone number.');
    when TOO_MANY_ROWS then
        DBMS_OUTPUT.PUT_LINE('Multiple customers found for the given phone number. Data integrity issue.');
    when others then
        DBMS_OUTPUT.PUT_LINE('An error occurred: ' || SQLERRM);
        rollback; 
end;

begin
    Add_Update_New_Customer('Salma Osama', 'Female', '1111111118', TO_DATE('2000-08-03', 'YYYY-MM-DD'), 'Mohamed Mounir');
end;
         
    begin
 Add_Update_New_Customer('Esraa Kamel', 'female', '1111111116', TO_DATE('1995-06-09', 'YYYY-MM-DD'), 'Mohamed Mounir');
    end;
    
    Begin
    Add_Update_New_Customer('Fatimeh Adel', 'Female', '1111111112', TO_DATE('2000-06-05', 'YYYY-MM-DD'), 'Mohamed Mounir');
    end;
    begin
    Add_Update_New_Customer('Salma Osama', 'Female', '1111111113', TO_DATE('2000-08-03', 'YYYY-MM-DD'), 'Mohamed Mounir');
    end;
    Add_Update_New_Customer('George Yohana', 'Male', '1111111114', TO_DATE('2000-06-09', 'YYYY-MM-DD'), 'Mohamed Mounir');
end;
         
         