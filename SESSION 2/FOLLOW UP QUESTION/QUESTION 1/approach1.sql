-- 1) Drop if exists (optional, for reruns)
DROP TABLE IF EXISTS amazon_transactions;

-- 2) Create table
CREATE TABLE amazon_transactions (
    id        BIGINT PRIMARY KEY,
    user_id   BIGINT,
    item      TEXT,
    revenue   BIGINT,
    created_at DATE
);

-- 3) Sample data (you can change/extend this)
INSERT INTO amazon_transactions (id, user_id, item, revenue, created_at) VALUES
    (1, 101, 'item_a', 20, '2024-01-01'),
    (2, 101, 'item_b', 30, '2024-01-03'),   -- 2 days after first -> should count
    (3, 101, 'item_c', 40, '2024-01-10'),   -- 9 days after first -> ignored

    (4, 102, 'item_a', 15, '2024-02-01'),
    (5, 102, 'item_b', 25, '2024-02-01'),   -- same day -> ignored
    (6, 102, 'item_c', 35, '2024-02-05'),   -- 4 days after first -> should count

    (7, 103, 'item_a', 50, '2024-03-01'),
    (8, 103, 'item_b', 60, '2024-03-10');   -- 9 days after first -> ignored


WITH ordered_tx AS (
    SELECT
        user_id,
        created_at,
        ROW_NUMBER() OVER (
            PARTITION BY user_id
            ORDER BY created_at, id
        ) AS rn
    FROM amazon_transactions
),
first_and_second AS (
    SELECT
        f.user_id,
        f.created_at AS first_date,
        s.created_at AS second_date
    FROM ordered_tx f
    JOIN ordered_tx s
        ON f.user_id = s.user_id
       AND f.rn = 1           -- first purchase
       AND s.rn = 2           -- second purchase
)
SELECT DISTINCT user_id
FROM first_and_second
WHERE second_date > first_date      -- ignore same‑day
  AND second_date <= first_date + INTERVAL '7 days'
ORDER BY user_id;