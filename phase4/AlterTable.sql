-- ============================================================
-- AlterTable.sql – Phase 4: Database Modifications
-- Adds columns and creates audit/logging tables for Phase 4.
-- ============================================================

-- 1. Enrich CUSTOMER table with suspension status
ALTER TABLE CUSTOMER 
    ADD COLUMN IF NOT EXISTS is_suspended BOOLEAN DEFAULT FALSE;

-- 2. Create Audit Log Table for Moderation Actions
CREATE TABLE IF NOT EXISTS moderation_audit (
    audit_id SERIAL PRIMARY KEY,
    customer_id INT REFERENCES CUSTOMER(customer_id) ON DELETE CASCADE,
    action_taken VARCHAR(100) NOT NULL,
    action_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    reason TEXT NOT NULL
);

-- 3. Create Audit Log Table for Booking Status Changes
CREATE TABLE IF NOT EXISTS booking_audit_log (
    log_id SERIAL PRIMARY KEY,
    booking_id INT,
    old_status VARCHAR(50),
    new_status VARCHAR(50),
    change_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    affected_tickets_count INT DEFAULT 0
);

-- 4. Create Refund Log Table
CREATE TABLE IF NOT EXISTS refund_log (
    refund_id SERIAL PRIMARY KEY,
    booking_id INT,
    refund_amount DECIMAL(10, 2) NOT NULL,
    processed_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    remarks TEXT
);
