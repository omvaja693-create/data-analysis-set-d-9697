-- ============================================================
-- setup.sql
-- SQL dialect : MySQL 8.0 (MySQL Community Server 8.0.x)
-- Run order   : 1) setup.sql  ->  2) queries.sql
-- Purpose     : Create schema + load base data (12 fact rows,
--               4 lookup rows). Duplicate record 12 is EXCLUDED.
-- ============================================================

DROP DATABASE IF EXISTS delivery_exam;
CREATE DATABASE delivery_exam;
USE delivery_exam;

-- ------------------------------------------------------------
-- Lookup table: routes (parent)
-- ------------------------------------------------------------
CREATE TABLE routes (
    route_id     VARCHAR(5)   NOT NULL,
    route        VARCHAR(50)  NOT NULL,
    service_type VARCHAR(20)  NOT NULL,
    PRIMARY KEY (route_id)
);

-- ------------------------------------------------------------
-- Fact table: deliveries (child)
-- FK: deliveries.route_id -> routes.route_id
-- ------------------------------------------------------------
CREATE TABLE deliveries (
    record_id     INT          NOT NULL,
    month         VARCHAR(3)   NOT NULL,
    route_id      VARCHAR(5)   NOT NULL,
    hub           VARCHAR(30)  NOT NULL,
    promised_days INT          NOT NULL,
    actual_days   INT          NOT NULL,
    PRIMARY KEY (record_id),
    CONSTRAINT fk_deliveries_route
        FOREIGN KEY (route_id) REFERENCES routes (route_id)
);

-- ------------------------------------------------------------
-- Load lookup rows (4)
-- ------------------------------------------------------------
INSERT INTO routes (route_id, route, service_type) VALUES
('R1', 'Metro Link',      'Express'),
('R2', 'City Dash',       'Express'),
('R3', 'Highway Freight', 'Standard'),
('R4', 'Rural Feeder',    'Standard');

-- ------------------------------------------------------------
-- Load fact rows (12). The duplicate second copy of
-- record_id 12 in the source CSV is intentionally NOT inserted.
-- ------------------------------------------------------------
INSERT INTO deliveries (record_id, month, route_id, hub, promised_days, actual_days) VALUES
(1,  'Jan', 'R1', 'Mumbai',  2,  2),
(2,  'Jan', 'R2', 'Chennai', 3,  4),
(3,  'Jan', 'R3', 'Delhi',   5,  8),
(4,  'Jan', 'R4', 'Mumbai',  6, 10),
(5,  'Feb', 'R1', 'Chennai', 2,  5),
(6,  'Feb', 'R2', 'Delhi',   3,  3),
(7,  'Feb', 'R3', 'Delhi',   5, 10),
(8,  'Feb', 'R4', 'Chennai', 6,  7),
(9,  'Mar', 'R1', 'Delhi',   2,  8),
(10, 'Mar', 'R2', 'Mumbai',  3,  5),
(11, 'Mar', 'R3', 'Chennai', 5,  5),
(12, 'Mar', 'R4', 'Mumbai',  6, 15);

-- Sanity check: expect 12 and 4
SELECT COUNT(*) AS deliveries_rows FROM deliveries;
SELECT COUNT(*) AS routes_rows     FROM routes;
