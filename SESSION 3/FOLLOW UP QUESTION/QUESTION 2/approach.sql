WITH monthly_trend AS (
    SELECT 
        product_id,
        product_name,
        month_start,
        monthly_active_users,
        LAG(monthly_active_users, 1) OVER (PARTITION BY product_id ORDER BY month_start) AS prev_users
    FROM product_engagement
),
decline_growth_flag AS (
    SELECT 
        product_id,
        product_name,
        month_start,
        monthly_active_users,
        CASE 
            WHEN monthly_active_users < prev_users THEN 'decline'
            WHEN monthly_active_users > prev_users THEN 'growth'
            ELSE 'stable'
        END AS trend
    FROM monthly_trend
),
consecutive_streaks AS (
    SELECT 
        product_id,
        product_name,
        month_start,
        monthly_active_users,
        trend,
        month_start - ROW_NUMBER() OVER (
            PARTITION BY product_id, trend 
            ORDER BY month_start
        ) * INTERVAL '1 month' AS streak_group
    FROM decline_growth_flag
    WHERE trend IN ('decline', 'growth')
),
streak_lengths AS (
    SELECT 
        product_id,
        product_name,
        streak_group,
        trend,
        MIN(month_start) AS streak_start,
        MAX(month_start) AS streak_end,
        COUNT(*) AS streak_length,
        MIN(monthly_active_users) AS min_users,
        MAX(monthly_active_users) AS max_users
    FROM consecutive_streaks
    GROUP BY product_id, product_name, streak_group, trend
),
decline_streaks AS (
    SELECT * FROM streak_lengths 
    WHERE trend = 'decline' AND streak_length >= 3
),
growth_streaks AS (
    SELECT * FROM streak_lengths 
    WHERE trend = 'growth' AND streak_length >= 3
),
paired_turnarounds AS (
    SELECT 
        d.product_id,
        d.product_name,
        d.streak_start AS decline_start_month,
        g.streak_start AS growth_resumed_month,
        d.min_users AS lowest_users,
        g.max_users AS peak_users
    FROM decline_streaks d
    JOIN growth_streaks g ON d.product_id = g.product_id
    WHERE g.streak_start > d.streak_end
),
ranked_turnarounds AS (
    SELECT 
        product_id,
        product_name,
        decline_start_month,
        growth_resumed_month,
        lowest_users,
        peak_users,
        ROW_NUMBER() OVER (PARTITION BY product_id ORDER BY decline_start_month DESC) AS rn
    FROM paired_turnarounds
)

SELECT 
    product_name,
    decline_start_month,
    growth_resumed_month,
    (peak_users - lowest_users) / lowest_users AS growth_ratio
FROM ranked_turnarounds
WHERE rn = 1
ORDER BY product_name;