-- ============================================================
-- pr_bulk_process_refunds_and_moderation.sql
-- Procedure 1: Performs bulk cancellation and ticket refunds for an attraction
--              on a specific date (e.g. operational closure).
--              Updates payments, bookings, refund logs, and soft-deletes invalid reviews.
-- Features: Explicit cursors, loop processing, diagnostics, dual-table updates.
-- ============================================================

CREATE OR REPLACE PROCEDURE pr_bulk_process_refunds_and_moderation(
    p_attraction_id INT,
    p_target_date DATE
) AS $$
DECLARE
    v_exists BOOLEAN;
    v_booking_count INT := 0;
    v_review_count INT := 0;
    v_refund_rec RECORD;
    v_refund_amount DECIMAL(10, 2);
    
    -- Explicit cursor for bookings to cancel and refund
    c_bookings CURSOR FOR
        SELECT 
            b.booking_id,
            b.payment_id,
            b.total_price,
            SUM(bt.quantity * t.price) AS attraction_tickets_value
        FROM BOOKING b
        JOIN BOOKINGTICKET bt ON b.booking_id = bt.booking_id
        JOIN TICKET t ON bt.ticket_id = t.ticket_id
        WHERE t.attraction_id = p_attraction_id 
          AND t.valid_date = p_target_date
          AND b.booking_status IN ('PAID', 'Confirmed', 'Pending')
        GROUP BY b.booking_id, b.payment_id, b.total_price;
BEGIN
    -- 1. Validate attraction existence
    SELECT EXISTS (
        SELECT 1 FROM ATTRACTION WHERE attraction_id = p_attraction_id
    ) INTO v_exists;
    
    IF NOT v_exists THEN
        RAISE EXCEPTION 'Attraction with ID % does not exist.', p_attraction_id;
    END IF;

    RAISE NOTICE 'Starting bulk refund process for Attraction % on Date %...', p_attraction_id, p_target_date;

    -- 2. Process bookings refunds
    OPEN c_bookings;
    LOOP
        FETCH c_bookings INTO v_refund_rec;
        EXIT WHEN NOT FOUND;
        
        v_booking_count := v_booking_count + 1;
        v_refund_amount := v_refund_rec.attraction_tickets_value;
        
        -- A. Insert into refund log
        INSERT INTO refund_log (booking_id, refund_amount, processed_date, remarks)
        VALUES (
            v_refund_rec.booking_id, 
            v_refund_amount, 
            CURRENT_TIMESTAMP, 
            'Attraction closure refund. Attraction ID: ' || p_attraction_id || ' Date: ' || p_target_date
        );
        
        -- B. Update PAYMENT (deduct refunded amount)
        UPDATE PAYMENT
        SET amount = GREATEST(amount - v_refund_amount, 0)
        WHERE payment_id = v_refund_rec.payment_id;
        
        -- C. Update BOOKING status to Cancelled (This will fire the trigger to restore ticket quantities!)
        UPDATE BOOKING
        SET booking_status = 'CANCELLED',
            total_price = GREATEST(total_price - v_refund_amount, 0)
        WHERE booking_id = v_refund_rec.booking_id;
        
        RAISE NOTICE 'Refunded % for Booking ID %.', v_refund_amount, v_refund_rec.booking_id;
    END LOOP;
    CLOSE c_bookings;

    -- 3. Soft-delete negative reviews written on that date for this attraction
    -- (Since the attraction was closed/cancellation happened, reviews on this date are invalid)
    UPDATE REVIEW
    SET is_deleted = TRUE,
        deleted_date = CURRENT_DATE,
        comment = '[Auto-Cancelled Due to Attraction Closure] ' || COALESCE(comment, '')
    WHERE attraction_id = p_attraction_id 
      AND review_date = p_target_date
      AND is_deleted = FALSE;
      
    GET DIAGNOSTICS v_review_count = ROW_COUNT;
    
    RAISE NOTICE 'Completed. Total Bookings Affected: %, Reviews Soft-Deleted: %.', v_booking_count, v_review_count;

EXCEPTION
    WHEN OTHERS THEN
        RAISE NOTICE 'Error during bulk refund procedure: %', SQLERRM;
        RAISE;
END;
$$ LANGUAGE plpgsql;
