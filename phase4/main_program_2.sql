-- ============================================================
-- main_program_2.sql
-- Main Program 2: Executes moderation accounts cleanup, then retrieves
--                  and consumes a Ref Cursor of attraction bookings.
-- Features: Procedure call, Ref Cursor fetching, formatted printing loop,
--           resource cleanup (CLOSE cursor).
-- ============================================================

DO $$
DECLARE
    v_attraction_id INT := 12;
    v_details_cursor refcursor;
    
    -- Variables to hold cursor data
    v_ticket_id INT;
    v_ticket_type VARCHAR(50);
    v_price DECIMAL(10, 2);
    v_booked INT;
    v_booking_date TIMESTAMP;
    v_status VARCHAR(50);
    v_rating FLOAT;
    v_title VARCHAR(200);
    
    v_counter INT := 0;
BEGIN
    RAISE NOTICE '============================================================';
    RAISE NOTICE 'RUNNING MAIN PROGRAM 2 – moderation cleanup & cursor consumption';
    RAISE NOTICE '============================================================';
    
    -- 1. Execute moderation cleanup with upheld reports threshold = 1
    RAISE NOTICE 'Invoking pr_moderator_review_cleanup...';
    CALL pr_moderator_review_cleanup(1);
    
    RAISE NOTICE '------------------------------------------------------------';
    
    -- 2. Call fn_get_attraction_details_cursor to retrieve cursor
    RAISE NOTICE 'Opening attraction details cursor for Attraction ID %...', v_attraction_id;
    v_details_cursor := fn_get_attraction_details_cursor(v_attraction_id);
    
    RAISE NOTICE 'Reading records from cursor:';
    RAISE NOTICE '------------------------------------------------------------';
    RAISE NOTICE 'ID   | Type       | Price   | Booked | Date       | Status    | Rating | Title';
    RAISE NOTICE '------------------------------------------------------------';
    
    LOOP
        FETCH NEXT FROM v_details_cursor INTO 
            v_ticket_id, v_ticket_type, v_price, v_booked, 
            v_booking_date, v_status, v_rating, v_title;
            
        EXIT WHEN NOT FOUND;
        
        v_counter := v_counter + 1;
        RAISE NOTICE '% | % | % | % | % | % | % | %',
            RPAD(v_ticket_id::TEXT, 4, ' '),
            RPAD(v_ticket_type::TEXT, 10, ' '),
            RPAD(v_price::TEXT, 7, ' '),
            RPAD(COALESCE(v_booked::TEXT, '0'), 6, ' '),
            RPAD(COALESCE(v_booking_date::DATE::TEXT, 'N/A'), 10, ' '),
            RPAD(COALESCE(v_status::TEXT, 'N/A'), 9, ' '),
            RPAD(COALESCE(v_rating::TEXT, 'N/A'), 6, ' '),
            COALESCE(v_title, 'No Review');
            
        -- Limit printout to 10 rows to avoid cluttering notices
        EXIT WHEN v_counter >= 10;
    END LOOP;
    
    CLOSE v_details_cursor;
    RAISE NOTICE '------------------------------------------------------------';
    RAISE NOTICE 'Total records printed from cursor: %', v_counter;
    RAISE NOTICE '============================================================';
EXCEPTION
    WHEN OTHERS THEN
        RAISE NOTICE 'Execution Failed in Main Program 2: %', SQLERRM;
END;
$$;
