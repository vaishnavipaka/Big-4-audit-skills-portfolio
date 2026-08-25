-- ============================================================
-- Titan Company Ltd. — SQL Anomaly Detection
-- Project 2 of 3, Audit & Finance Skills Portfolio
-- Database: titan_audit_project | Table: titan_payments
-- ============================================================

-- ------------------------------------------------------------
-- Query 1: Duplicate Payment Detection
-- Flags pairs of payments to the same vendor, for the same
-- amount, within 2 days of each other — a classic sign of
-- accidental (or fraudulent) double payment.
-- Result: correctly identified all 4 planted duplicate pairs.
-- ------------------------------------------------------------
SELECT
    a.transaction_id AS txn_1,
    b.transaction_id AS txn_2,
    a.vendor_name,
    a.amount,
    a.payment_date AS date_1,
    b.payment_date AS date_2
FROM titan_payments a
JOIN titan_payments b
    ON a.vendor_name = b.vendor_name
    AND a.amount = b.amount
    AND a.transaction_id < b.transaction_id
    AND ABS(DATEDIFF(a.payment_date, b.payment_date)) <= 2;


-- ------------------------------------------------------------
-- Query 2: Round-Number Amount Detection
-- Flags payments that are exact multiples of Rs 50,000 —
-- real invoices rarely land on perfectly round figures, so
-- this can indicate estimated or manually-entered amounts
-- rather than genuine invoice-derived figures.
-- Result: correctly identified all 5 planted round-number
-- transactions.
-- ------------------------------------------------------------
SELECT
    transaction_id,
    vendor_name,
    amount,
    payment_date
FROM titan_payments
WHERE MOD(amount, 50000) = 0;


-- ------------------------------------------------------------
-- Query 3: Weekend Posting Detection
-- Flags payments recorded on a Saturday or Sunday, when
-- normal approval staff are typically not working — a
-- potential sign of authorization control bypass.
-- Result: correctly identified all 6 planted weekend
-- transactions.
-- ------------------------------------------------------------
SELECT
    transaction_id,
    vendor_name,
    amount,
    payment_date,
    DAYNAME(payment_date) AS day_of_week
FROM titan_payments
WHERE DAYOFWEEK(payment_date) IN (1, 7);


-- ------------------------------------------------------------
-- Query 4: Vendor Concentration Analysis
-- Totals franchisee remittances by vendor to identify any
-- single franchisee receiving an unusually high volume or
-- value of payments compared to others.
-- Result: correctly flagged "Franchisee - Pearl Palace" with
-- 16 transactions, clearly standing out above other
-- franchisees.
-- ------------------------------------------------------------
SELECT
    vendor_name,
    COUNT(*) AS num_transactions,
    SUM(amount) AS total_paid
FROM titan_payments
WHERE payment_type = 'Franchisee Remittance'
GROUP BY vendor_name
ORDER BY total_paid DESC
LIMIT 10;
