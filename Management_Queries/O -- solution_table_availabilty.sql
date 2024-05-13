CREATE OR REPLACE PROCEDURE core.check_table_availability (
  p_guest_count in number,  
  p_type_of_order in varchar2,
  p_guest_preferece_location in varchar2,
  o_guest_preferece_location out varchar2,
  p_available_table_id out varchar2,
  p_total_capacity out number,  
  p_merge_required out varchar2,
) is
  -- Flag to indicate if merging tables is required
  v_merge_required varchar2,(1) := 'N'; -- Initialize as 'N' for false
  v_total_seats number;  
  max_num_of_seats number;  
  c_max_capacity number;  

  cursor available_combinations_Any is
    select LTRIM(SYS_CONNECT_BY_PATH(table_id, ','), ',') AS Path, LTRIM(SYS_CONNECT_BY_PATH(number_of_seats, ','), ',') AS Seats
    from core.tables
    where availability = 'Y'
    START WITH availability = 'Y'
    CONNECT BY PRIOR table_id < table_id AND PRIOR availability = 'Y';
    
    
  cursor available_combinations_Spec is
      select LTRIM(SYS_CONNECT_BY_PATH(table_id, ','), ',') AS Path, LTRIM(SYS_CONNECT_BY_PATH(number_of_seats, ','), ',') AS Seats
    from core.tables
    where availability = 'Y' AND location = p_guest_preferece_location
    START WITH availability = 'Y'  AND location = p_guest_preferece_location
    CONNECT BY PRIOR table_id < table_id AND PRIOR availability = 'Y'  AND location = p_guest_preferece_location;

begin
  if p_guest_count >= 1 then
  if p_type_of_order = 'Dine-In' then
    if (p_guest_preferece_location in ('Indoor', 'Outdoor', 'Any')) then
      -- Get the maximum number of seats and the sum of seats
      if (p_guest_preferece_location = 'Any') then
        select max(NUMBER_OF_SEATS), sum(NUMBER_OF_SEATS) into max_num_of_seats, c_max_capacity
        from core.tables
        where availability = 'Y';
      else
        select max(NUMBER_OF_SEATS), sum(NUMBER_OF_SEATS) into max_num_of_seats, c_max_capacity
        from core.tables
        where availability = 'Y' AND location = p_guest_preferece_location;
      end if;

      -- Check if the guest count exceeds the maximum capacity
      if p_guest_count > c_max_capacity then
        RAISE_APPLICATION_ERROR(-20001, 'Total seats exceed maximum capacity.');
      end if;

      -- If guest count does not exceed maximum capacity, continue checking for available tables
      if (p_guest_preferece_location = 'Any') then
        if p_guest_count < max_num_of_seats then
          -- Check for a single table that can accommodate the guest count
          select *
          into p_available_table_id, p_total_capacity, o_guest_preferece_location
          from (
            select t1.table_id, t1.NUMBER_OF_SEATS, t1.Location
            from core.tables t1
            where t1.AVAILABILITY = 'Y'
              and t1.NUMBER_OF_SEATS >= p_guest_count
            order by t1.NUMBER_OF_SEATS asc
          )
          where ROWNUM = 1;
        else
          -- If no single table found, check for combinations using a cursor
          for combo_2 in available_combinations_Any loop
            v_total_seats := 0; -- Initialize total seats for each iteration

            -- Loop through the seats for the current path and calculate the total
            for seat in (
              select TO_NUMBER(regexp_substr(combo_2.Seats, '[^,]+', 1, LEVEL)) as seat
              from DUAL
              CONNECT BY LEVEL <= REGEXP_COUNT(combo_2.Seats, ',') + 1
            )
            loop
              v_total_seats := v_total_seats + seat.seat; -- Add each seat to the total
            end loop;

            -- Check if the total seats are sufficient
            if v_total_seats >= p_guest_count then
              p_available_table_id := combo_2.Path; -- Concatenate available table IDs
              p_total_capacity := v_total_seats; -- Set total capacity to combined capacity
              v_merge_required := 'Y';  -- Set flag if merging tables is needed
              o_guest_preferece_location:='Any';
              exit;  -- Exit loop if a suitable combination is found
            end if;
          end loop;
        end if;
      else
              if p_guest_count < max_num_of_seats then
        -- Check for a single table that can accommodate the guest count
          select *
          into p_available_table_id, p_total_capacity, o_guest_preferece_location
          from (
            select t1.table_id, t1.NUMBER_OF_SEATS, t1.location
            from core.tables t1
            where t1.AVAILABILITY = 'Y' AND location = p_guest_preferece_location
              AND t1.NUMBER_OF_SEATS >= p_guest_count
            ORDER BY t1.NUMBER_OF_SEATS ASC
          )
          where ROWNUM = 1;
        else
          -- If no single table found, check for combinations using a cursor
          for combo in available_combinations_Spec loop
            v_total_seats := 0; -- Initialize total seats for each iteration

            -- Loop through the seats for the current path and calculate the total
            for seat in (
              select TO_NUMBER(regexp_substr(combo.Seats, '[^,]+', 1, LEVEL)) AS seat
              from DUAL
              CONNECT BY LEVEL <= REGEXP_COUNT(combo.Seats, ',') + 1
            )
            loop
              v_total_seats := v_total_seats + seat.seat; -- Add each seat to the total
            end loop;

            -- Check if the total seats are sufficient
            if v_total_seats >= p_guest_count then
              p_available_table_id := combo.Path; -- Concatenate available table IDs
              p_total_capacity := v_total_seats; -- Set total capacity to combined capacity
              o_guest_preferece_location:= p_guest_preferece_location;
              v_merge_required := 'Y';  -- Set flag if merging tables is needed
              exit;  -- Exit loop if a suitable combination is found
            end if;
          end loop;
       end if;
      end if;

      -- Set output based on the findings
      if p_available_table_id IS NULL then
        p_total_capacity := NULL; -- No table found, set capacity to NULL
        p_merge_required := NULL; -- No table found, set merge required to NULL
      else
        p_merge_required := v_merge_required;  -- Reset flag if a single or merged table is found
      end if;

    else
      RAISE_APPLICATION_ERROR(-20002, 'Invalid Location. Please Enter (Indoor / Outdoor / Any).');
    end if;

 else
    RAISE_APPLICATION_ERROR(-20007, 'Should Dine_In.');
  end if;
  else
    RAISE_APPLICATION_ERROR(-20003, 'Invalid Guest Number.');
  end if;
end;
/
