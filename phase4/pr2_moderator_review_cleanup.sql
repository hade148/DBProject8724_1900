-- ============================================================
-- pr_moderator_review_cleanup.sql
-- Procedure 2: Auto-scans and suspends customer accounts exceeding a threshold 
--              of upheld review reports. Soft-deletes all their content and audits.
-- Features: Explicit cursors, loops, conditional DML updates, custom audit insertions.
-- ============================================================

CREATE OR REPLACE PROCEDURE pr_moderator_review_cleanup(
    p_report_threshold INT
) AS $$
DECLARE
    v_customer_rec RECORD;
    v_violation_count INT;
    v_deleted_reviews_count INT;
    v_suspended_count INT := 0;
    
    -- Explicit cursor for customers with reported reviews
    c_reported_customers CURSOR FOR
        SELECT DISTINCT c.customer_id, c.first_name || ' ' || COALESCE(c.last_name, '') AS full_name
        FROM CUSTOMER c
        JOIN REVIEW r ON c.customer_id = r.customer_id
        JOIN REVIEWREPORT rr ON r.review_id = rr.review_id
        WHERE c.is_suspended = FALSE;
BEGIN
    IF p_report_threshold <= 0 THEN
        RAISE EXCEPTION 'Report threshold must be a positive integer.';
    END IF;

    RAISE NOTICE 'Starting moderation cleanup process (Threshold: % Upheld Reports)...', p_report_threshold;

    OPEN c_reported_customers;
    LOOP
        FETCH c_reported_customers INTO v_customer_rec;
        EXIT WHEN NOT FOUND;

        -- Count UPHELD reports for this customer
        SELECT COUNT(*) INTO v_violation_count
        FROM REVIEWREPORT rr
        WHERE rr.customer_id = v_customer_rec.customer_id 
          AND rr.admin_decision = 'UPHELD';

        IF v_violation_count > p_report_threshold THEN
            RAISE NOTICE 'Customer % (ID %) has exceeded threshold with % upheld reports! Suspending...', 
                v_customer_rec.full_name, v_customer_rec.customer_id, v_violation_count;
            
            -- A. Suspend the customer
            UPDATE CUSTOMER
            SET is_suspended = TRUE
            WHERE customer_id = v_customer_rec.customer_id;

            -- B. Log the action in moderation audit
            INSERT INTO moderation_audit (customer_id, action_taken, reason)
            VALUES (
                v_customer_rec.customer_id, 
                'ACCOUNT_SUSPENSION', 
                'Suspended due to ' || v_violation_count || ' upheld content reports (Threshold: ' || p_report_threshold || ').'
            );

            -- C. Soft-delete all their reviews
            UPDATE REVIEW
            SET is_deleted = TRUE,
                deleted_date = CURRENT_DATE,
                comment = '[Suspended Content] ' || COALESCE(comment, '')
            WHERE customer_id = v_customer_rec.customer_id AND is_deleted = FALSE;

            GET DIAGNOSTICS v_deleted_reviews_count = ROW_COUNT;
            
            v_suspended_count := v_suspended_count + 1;
            
            RAISE NOTICE 'Suspension completed for %. % reviews soft-deleted.', 
                v_customer_rec.full_name, v_deleted_reviews_count;
        END IF;
    END LOOP;
    CLOSE c_reported_customers;

    RAISE NOTICE 'Moderation cleanup complete. Total customers suspended: %', v_suspended_count;

EXCEPTION
    WHEN OTHERS THEN
        RAISE NOTICE 'Error during moderation review cleanup: %', SQLERRM;
        RAISE;
END;
$$ LANGUAGE plpgsql;
