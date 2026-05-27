-- ============================================================
-- fn_calculate_customer_loyalty_discount.sql
-- Function 2: Calculates customer loyalty discounts based on 
--             booking spent and community reviews engagement.
-- Features: Explicit cursor, loops, tiered logic, existence verification,
--           moderation check (realigned to unified review reports).
-- ============================================================

CREATE OR REPLACE FUNCTION fn_calculate_customer_loyalty_discount(p_customer_id INT)
RETURNS NUMERIC AS $$
DECLARE
    v_exists BOOLEAN;
    v_suspended BOOLEAN;
    v_total_spent NUMERIC := 0.0;
    v_booking_count INT := 0;
    v_review_count INT := 0;
    v_total_reactions INT := 0;
    v_upheld_reports_count INT := 0;
    v_discount NUMERIC := 0.00;
    
    -- Explicit cursor for customer reviews
    c_customer_reviews CURSOR FOR
        SELECT review_id FROM REVIEW 
        WHERE customer_id = p_customer_id AND is_deleted = FALSE;
        
    v_review_rec RECORD;
    v_reaction_count INT;
BEGIN
    -- 1. Validate customer existence
    SELECT EXISTS (
        SELECT 1 FROM CUSTOMER WHERE customer_id = p_customer_id
    ) INTO v_exists;
    
    IF NOT v_exists THEN
        RAISE EXCEPTION 'Customer with ID % does not exist.', p_customer_id
            USING ERRCODE = 'P0002';
    END IF;

    -- 2. Check suspension state
    SELECT COALESCE(is_suspended, FALSE) INTO v_suspended 
    FROM CUSTOMER WHERE customer_id = p_customer_id;
    
    IF v_suspended THEN
        RETURN 0.00; -- Suspended customers get absolutely no loyalty benefits
    END IF;

    -- 3. Check moderation infractions (upheld review reports)
    SELECT COUNT(*) INTO v_upheld_reports_count
    FROM REVIEWREPORT
    WHERE customer_id = p_customer_id AND admin_decision = 'UPHELD';
    
    IF v_upheld_reports_count > 0 THEN
        RETURN 0.00; -- Customers with verified violations lose loyalty discounts
    END IF;

    -- 4. Calculate booking volume and spend using implicit cursor (SELECT aggregation)
    SELECT COUNT(*), COALESCE(SUM(total_price), 0)
    INTO v_booking_count, v_total_spent
    FROM BOOKING
    WHERE customer_id = p_customer_id AND booking_status IN ('PAID', 'Confirmed');

    -- 5. Calculate review contributions and community engagement using explicit cursor
    OPEN c_customer_reviews;
    LOOP
        FETCH c_customer_reviews INTO v_review_rec;
        EXIT WHEN NOT FOUND;
        
        v_review_count := v_review_count + 1;
        
        -- Get reaction count for this review
        SELECT COUNT(*) INTO v_reaction_count
        FROM REVIEWREACTION
        WHERE review_id = v_review_rec.review_id;
        
        v_total_reactions := v_total_reactions + v_reaction_count;
    END LOOP;
    CLOSE c_customer_reviews;

    -- 6. Apply multi-tier logic (branching)
    -- Tier A: Booking volume
    IF v_booking_count >= 10 THEN
        v_discount := v_discount + 0.08; -- 8%
    ELSIF v_booking_count >= 5 THEN
        v_discount := v_discount + 0.05; -- 5%
    ELSIF v_booking_count >= 2 THEN
        v_discount := v_discount + 0.02; -- 2%
    END IF;

    -- Tier B: Total monetary investment
    IF v_total_spent >= 1000 THEN
        v_discount := v_discount + 0.07; -- 7%
    ELSIF v_total_spent >= 500 THEN
        v_discount := v_discount + 0.04; -- 4%
    ELSIF v_total_spent >= 200 THEN
        v_discount := v_discount + 0.02; -- 2%
    END IF;

    -- Tier C: Review contributions and engagement
    IF v_review_count >= 5 AND v_total_reactions >= 10 THEN
        v_discount := v_discount + 0.05; -- 5%
    ELSIF v_review_count >= 2 THEN
        v_discount := v_discount + 0.02; -- 2%
    END IF;

    -- Cap discount at 20% max
    IF v_discount > 0.20 THEN
        v_discount := 0.20;
    END IF;

    RETURN ROUND(v_discount, 2);
EXCEPTION
    WHEN OTHERS THEN
        RAISE NOTICE 'Error in fn_calculate_customer_loyalty_discount for customer %: %', p_customer_id, SQLERRM;
        RETURN 0.00;
END;
$$ LANGUAGE plpgsql;
