-- ============================================================
-- main_program_1.sql
-- Main Program 1: Executes loyalty discount calculations for customers,
--                  then invokes the bulk attraction refund procedure.
-- Features: Variable declarations, function invocations, procedure calling,
--           error isolation block.
-- ============================================================

DO $$
DECLARE
    v_cust_id_1 INT := 105; -- An active customer ID from the database
    v_cust_id_2 INT := 210; -- Another customer
    v_discount_1 NUMERIC;
    v_discount_2 NUMERIC;
    
    v_attraction_id INT := 12; -- Attraction to refund
    v_target_date DATE := '2026-05-15'; -- Operational issue date
BEGIN
    RAISE NOTICE '============================================================';
    RAISE NOTICE 'RUNNING MAIN PROGRAM 1 – loyalty discount & bulk refunds';
    RAISE NOTICE '============================================================';
    
    -- 1. Invoke fn_calculate_customer_loyalty_discount
    v_discount_1 := fn_calculate_customer_loyalty_discount(v_cust_id_1);
    v_discount_2 := fn_calculate_customer_loyalty_discount(v_cust_id_2);
    
    RAISE NOTICE 'Loyalty Discount for Customer ID %: %%%', v_cust_id_1, (v_discount_1 * 100);
    RAISE NOTICE 'Loyalty Discount for Customer ID %: %%%', v_cust_id_2, (v_discount_2 * 100);

    RAISE NOTICE '------------------------------------------------------------';
    
    -- 2. Invoke pr_bulk_process_refunds_and_moderation
    CALL pr_bulk_process_refunds_and_moderation(v_attraction_id, v_target_date);
    
    RAISE NOTICE '============================================================';
EXCEPTION
    WHEN OTHERS THEN
        RAISE NOTICE 'Execution Failed in Main Program 1: %', SQLERRM;
END;
$$;
