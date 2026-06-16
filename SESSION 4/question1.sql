WITH monthly_activity AS (
    SELECT
        user_id,
        EXTRACT(MONTH FROM event_date)::int AS month
    FROM user_actions
    WHERE EXTRACT(YEAR FROM event_date) = 2022
      AND event_type IN ('sign-in', 'like', 'comment')
    GROUP BY user_id, EXTRACT(MONTH FROM event_date)
),
active_pairs AS (
    SELECT
        curr.user_id,
        curr.month AS curr_month
    FROM monthly_activity curr
    JOIN monthly_activity prev
      ON curr.user_id = prev.user_id
     AND curr.month = prev.month + 1
)
SELECT
    curr_month AS month,
    COUNT(DISTINCT user_id) AS monthly_active_users
FROM active_pairs
WHERE curr_month = 7
GROUP BY curr_month
ORDER BY curr_month;