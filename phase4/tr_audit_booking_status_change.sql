-- ============================================================
-- tr_audit_booking_status_change.sql
-- Trigger 1 (UPDATE): Fired AFTER an UPDATE on the BOOKING table.
--                     Logs the transition in booking_audit_log.
--                     If status is changed to CANCELLED, automatically
--                     restores available ticket quantities back to the TICKET table.
-- Features: Loop over booking items, multiple DMLs, conditional status checks.
-- ============================================================

CREATE OR REPLACE FUNCTION fn_audit_booking_status_change()
RETURNS TRIGGER AS $$
DECLARE
    v_ticket_rec RECORD;
    v_affected_count INT := 0;
BEGIN
    -- Only act if the booking status actually changed
    IF OLD.booking_status IS DISTINCT FROM NEW.booking_status THEN
        
        -- If the new status is CANCELLED, restore ticket quantities
        IF NEW.booking_status = 'CANCELLED' THEN
            -- Loop through all tickets linked to this booking
            FOR v_ticket_rec IN 
                SELECT ticket_id, quantity 
                FROM BOOKINGTICKET 
                WHERE booking_id = NEW.booking_id
            LOOP
                -- Restore the available quantity in the TICKET table
                UPDATE TICKET
                SET available_quantity = available_quantity + v_ticket_rec.quantity
                WHERE ticket_id = v_ticket_rec.ticket_id;
                
                v_affected_count := v_affected_count + 1;
            END LOOP;
        END IF;

        -- Insert audit log record
        INSERT INTO booking_audit_log (
            booking_id, 
            old_status, 
            new_status, 
            change_date,
            affected_tickets_count
        )
        VALUES (
            NEW.booking_id, 
            OLD.booking_status, 
            NEW.booking_status, 
            CURRENT_TIMESTAMP,
            v_affected_count
        );
        
    END IF;

    RETURN NEW;
EXCEPTION
    WHEN OTHERS THEN
        RAISE NOTICE 'Error in trigger fn_audit_booking_status_change: %', SQLERRM;
        RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Bind the trigger to the BOOKING table
DROP TRIGGER IF EXISTS tr_audit_booking_status ON BOOKING;
CREATE TRIGGER tr_audit_booking_status
AFTER UPDATE ON BOOKING
FOR EACH ROW
EXECUTE FUNCTION fn_audit_booking_status_change();
