WITH sent_requests AS (
    SELECT 
        date,
        user_id_sender,
        user_id_receiver
    FROM fb_friend_requests
    WHERE action = 'sent'
),
accepted_requests AS (
    SELECT 
        date,
        user_id_sender,
        user_id_receiver
    FROM fb_friend_requests
    WHERE action = 'accepted'
)
SELECT 
    s.date,
    COUNT(DISTINCT a.user_id_sender, a.user_id_receiver) AS accepted_count,
    COUNT(DISTINCT s.user_id_sender, s.user_id_receiver) AS sent_count,
    ROUND(
        COUNT(DISTINCT a.user_id_sender, a.user_id_receiver) * 100.0 / 
        COUNT(DISTINCT s.user_id_sender, s.user_id_receiver), 
        2
    ) AS acceptance_rate
FROM sent_requests s
LEFT JOIN accepted_requests a 
    ON s.user_id_sender = a.user_id_sender 
    AND s.user_id_receiver = a.user_id_receiver
GROUP BY s.date
HAVING COUNT(DISTINCT s.user_id_sender, s.user_id_receiver) > 0 
    AND COUNT(DISTINCT a.user_id_sender, a.user_id_receiver) > 0 [page:1];