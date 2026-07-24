-- ============================================================
-- Customer Opening Due — manual starting balance per customer
-- Run once on your MySQL database
-- ============================================================
CREATE TABLE IF NOT EXISTS customer_opening_due (
    id             INT AUTO_INCREMENT PRIMARY KEY,
    customer_id    INT NOT NULL,
    due_date       DATE NOT NULL,
    amount         DECIMAL(12,2) NOT NULL DEFAULT 0.00,
    balance_after  DECIMAL(12,2) NOT NULL DEFAULT 0.00,
    notes          VARCHAR(255) DEFAULT NULL,
    uid            INT DEFAULT NULL,
    entry_date     DATE NOT NULL,
    entry_time     TIME NOT NULL,
    is_active      TINYINT(1) NOT NULL DEFAULT 1,
    INDEX idx_customer_date (customer_id, due_date),
    INDEX idx_active_customer (is_active, customer_id),
    FOREIGN KEY (customer_id) REFERENCES customers(id) ON DELETE CASCADE
);
