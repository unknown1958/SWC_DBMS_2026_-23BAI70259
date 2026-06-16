SELECT DISTINCT user_id
FROM (
    SELECT
        user_id,
        created_at,
        ROW_NUMBER() OVER (
            PARTITION BY user_id
            ORDER BY created_at, id
        ) AS rn
    FROM amazon_transactions
) t
MATCH_RECOGNIZE (
    PARTITION BY user_id
    ORDER BY created_at, id
);