-- ============================================================
-- Supplier Balance — prod_supplier.balance
-- Run once on your MySQL database
-- ============================================================

ALTER TABLE prod_supplier
    ADD COLUMN balance DECIMAL(12,2) NOT NULL DEFAULT 0.00
        COMMENT 'Outstanding supplier balance (purchases + opening - payments)'
        AFTER is_gst;

CREATE TABLE IF NOT EXISTS prod_supplier_balance_log (
    id           INT AUTO_INCREMENT PRIMARY KEY,
    supplier_id  INT NOT NULL,
    amount       DECIMAL(12,2) NOT NULL,
    type         VARCHAR(20) NOT NULL COMMENT 'opening, purchase, payment',
    notes        VARCHAR(255) DEFAULT NULL,
    uid          INT DEFAULT NULL,
    reference_id INT DEFAULT NULL,
    entry_date   DATE NOT NULL,
    entry_time   TIME NOT NULL,
    INDEX idx_supplier_id (supplier_id),
    INDEX idx_type (type)
);

-- One-time sync: load existing purchase balances into supplier master
UPDATE prod_supplier s
SET balance = (
    SELECT COALESCE(SUM(p.balance), 0)
    FROM prod_purchase p
    WHERE p.deal_id = s.id AND p.is_cancelled = 0 AND p.balance > 0 AND p.invno != ''
);
