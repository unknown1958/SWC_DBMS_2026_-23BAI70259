CREATE TABLE search_events (
    event_id BIGINT PRIMARY KEY,
    event_timestamp TIMESTAMP WITHOUT TIME ZONE,
    event_type TEXT,
    query TEXT,
    session_id TEXT,
    user_id BIGINT
);
CREATE TABLE accounts (
    country TEXT,
    registration_date DATE,
    user_id BIGINT PRIMARY KEY
);


WITH max_date AS (
    -- Find the most recent date in the dataset
    SELECT MAX(event_timestamp)::date AS max_dt
    FROM search_events
),
user_segments AS (
    -- Classify users as new or existing
    SELECT 
        a.user_id,
        CASE 
            WHEN a.registration_date >= (SELECT max_dt - INTERVAL '30 days' FROM max_date)
            THEN 'new'
            ELSE 'existing'
        END AS user_segment
    FROM accounts a
),
search_with_clicks AS (
    -- Get search events and find first click within 30 seconds
    SELECT 
        s.user_id,
        s.event_id AS search_id,
        s.event_timestamp AS search_time,
        MIN(c.event_timestamp) AS first_click_time
    FROM search_events s
    LEFT JOIN search_events c 
        ON s.user_id = c.user_id
        AND c.event_type = 'click'
        AND c.event_timestamp > s.event_timestamp
        AND c.event_timestamp <= s.event_timestamp + INTERVAL '30 seconds'
    WHERE s.event_type = 'search'
    GROUP BY s.user_id, s.event_id, s.event_timestamp
),
search_success AS (
    -- Determine if each search was successful
    SELECT 
        swc.user_id,
        swc.search_id,
        CASE 
            WHEN swc.first_click_time IS NOT NULL THEN 1
            ELSE 0
        END AS is_successful
    FROM search_with_clicks swc
)
-- Final aggregation by user segment
SELECT 
    us.user_segment,
    COUNT(ss.search_id) AS total_searches,
    SUM(ss.is_successful) AS successful_searches,
    ROUND(SUM(ss.is_successful)::numeric / COUNT(ss.search_id)::numeric * 100, 2) AS success_rate
FROM search_success ss
JOIN user_segments us ON ss.user_id = us.user_id
GROUP BY us.user_segment
ORDER BY us.user_segment;