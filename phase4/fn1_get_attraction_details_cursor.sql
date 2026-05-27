-- ============================================================
-- fn_get_attraction_details_cursor.sql
-- Function 1: Returns a Ref Cursor containing booking and review 
--             details for a specific attraction.
-- Features: Explicit refcursor, existence validation, custom exceptions.
-- ============================================================

CREATE OR REPLACE FUNCTION fn_get_attraction_details_cursor(p_attraction_id INT)
RETURNS refcursor AS $$
DECLARE
    v_cursor_name refcursor := 'attraction_details_cursor';
    v_exists BOOLEAN;
BEGIN
    -- Validate attraction existence
    SELECT EXISTS (
        SELECT 1 FROM ATTRACTION WHERE attraction_id = p_attraction_id
    ) INTO v_exists;
    
    IF NOT v_exists THEN
        RAISE EXCEPTION 'Attraction with ID % does not exist.', p_attraction_id
            USING ERRCODE = 'P0002'; -- Data not found
    END IF;

    -- Open the explicit cursor for the caller
    OPEN v_cursor_name FOR
        SELECT 
            t.ticket_id,
            t.ticket_type,
            t.price AS ticket_price,
            bt.quantity AS tickets_booked,
            b.booking_date,
            b.booking_status,
            r.rating AS review_rating,
            r.title AS review_title
        FROM TICKET t
        LEFT JOIN BOOKINGTICKET bt ON t.ticket_id = bt.ticket_id
        LEFT JOIN BOOKING b ON bt.booking_id = b.booking_id
        LEFT JOIN REVIEW r ON t.attraction_id = r.attraction_id 
                           AND r.customer_id = b.customer_id
                           AND r.is_deleted = FALSE
        WHERE t.attraction_id = p_attraction_id
        ORDER BY b.booking_date DESC;

    RETURN v_cursor_name;
EXCEPTION
    WHEN OTHERS THEN
        RAISE NOTICE 'Error in fn_get_attraction_details_cursor: %', SQLERRM;
        RAISE;
END;
$$ LANGUAGE plpgsql;
