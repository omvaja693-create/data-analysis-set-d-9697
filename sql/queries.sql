-- ============================================================
-- queries.sql
-- SQL dialect : MySQL 8.0 (MySQL Community Server 8.0.x)
-- Prerequisite: run setup.sql first.
-- delay_days = GREATEST(actual_days - promised_days, 0)
--   (GREATEST is the MySQL equivalent of MAX(x, 0) across values)
-- ============================================================
USE delivery_exam;

-- ------------------------------------------------------------
-- S2a: Total delay_days by service type (highest first)
-- ------------------------------------------------------------
SELECT
    r.service_type,
    SUM(GREATEST(d.actual_days - d.promised_days, 0)) AS total_delay_days
FROM deliveries AS d
JOIN routes     AS r ON r.route_id = d.route_id
GROUP BY r.service_type
ORDER BY total_delay_days DESC;

-- ------------------------------------------------------------
-- S2b: Routes with significant delay (summed delay_days > 8)
-- ------------------------------------------------------------
SELECT
    d.route_id,
    r.route,
    SUM(GREATEST(d.actual_days - d.promised_days, 0)) AS total_delay_days
FROM deliveries AS d
JOIN routes     AS r ON r.route_id = d.route_id
GROUP BY d.route_id, r.route
HAVING SUM(GREATEST(d.actual_days - d.promised_days, 0)) > 8
ORDER BY total_delay_days DESC, d.route_id;

-- ------------------------------------------------------------
-- S2c: Top two hubs by summed delay_days
--      Ties broken by alphabetical hub order
-- ------------------------------------------------------------
SELECT
    hub,
    SUM(GREATEST(actual_days - promised_days, 0)) AS total_delay_days
FROM deliveries
GROUP BY hub
ORDER BY total_delay_days DESC, hub ASC
LIMIT 2;

-- ------------------------------------------------------------
-- S3: Data integrity check (LEFT JOIN diagnostic)
--     Every deliveries.route_id must match a routes row.
--     Expected result: unmatched_rows = 0
-- ------------------------------------------------------------
SELECT
    COUNT(*) AS unmatched_rows
FROM deliveries AS d
LEFT JOIN routes AS r ON r.route_id = d.route_id
WHERE r.route_id IS NULL;
