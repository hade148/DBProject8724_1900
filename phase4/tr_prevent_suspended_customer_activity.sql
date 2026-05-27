-- ============================================================
-- tr_prevent_suspended_customer_activity.sql
-- Trigger 2 (BEFORE INSERT): Bound to BOOKING, REVIEW, and REVIEWREACTION.
--                            Validates that the customer is not suspended before 
--                            allowing them to perform key actions.
-- Features: Trigger sharing, custom exception raising, BEFORE INSERT enforcement.
-- ============================================================

CREATE OR REPLACE FUNCTION fn_prevent_suspended_customer_activity()
RETURNS TRIGGER AS $$
DECLARE
    v_suspended BOOLEAN := FALSE;
BEGIN
    -- Query the customer is_suspended status based on the NEW record customer_id
    SELECT COALESCE(is_suspended, FALSE) INTO v_suspended
    FROM CUSTOMER
    WHERE customer_id = NEW.customer_id;

    IF v_suspended THEN
        RAISE EXCEPTION 'Action Denied. Customer with ID % is currently suspended due to moderation violations.', 
            NEW.customer_id
            USING ERRCODE = 'D0001'; -- Custom application error state
    END IF;

    RETURN NEW;
EXCEPTION
    WHEN OTHERS THEN
        -- Re-raise our custom suspension exception to abort transaction
        IF SQLSTATE = 'D0001' THEN
            RAISE;
        END IF;
        -- Otherwise log notice and allow to continue
        RAISE NOTICE 'Error in fn_prevent_suspended_customer_activity: %', SQLERRM;
        RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Bind the trigger BEFORE INSERT on BOOKING
DROP TRIGGER IF EXISTS tr_prevent_suspended_booking ON BOOKING;
CREATE TRIGGER tr_prevent_suspended_booking
BEFORE INSERT ON BOOKING
FOR EACH ROW
EXECUTE FUNCTION fn_prevent_suspended_customer_activity();

-- Bind the trigger BEFORE INSERT on REVIEW
DROP TRIGGER IF EXISTS tr_prevent_suspended_review ON REVIEW;
CREATE TRIGGER tr_prevent_suspended_review
BEFORE INSERT ON REVIEW
FOR EACH ROW
EXECUTE FUNCTION fn_prevent_suspended_customer_activity();

-- Bind the trigger BEFORE INSERT on REVIEWREACTION
DROP TRIGGER IF EXISTS tr_prevent_suspended_reaction ON REVIEWREACTION;
CREATE TRIGGER tr_prevent_suspended_reaction
BEFORE INSERT ON REVIEWREACTION
FOR EACH ROW
EXECUTE FUNCTION fn_prevent_suspended_customer_activity();
