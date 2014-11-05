-- For details on how to use this report, visit
-- https://modeanalytics.zendesk.com/hc/en-us/articles/203503600

WITH 

users AS (
  SELECT user_id,
         activated_at
    FROM tutorial.playbook_users
),

events AS (
  SELECT user_id,
         occurred_at,
         event_name
    FROM tutorial.playbook_events
   WHERE event_type = 'engagement'
)

SELECT CASE WHEN dow = 0 THEN 'Sunday'
            WHEN dow = 1 THEN 'Monday'
            WHEN dow = 2 THEN 'Tuesday'
            WHEN dow = 3 THEN 'Wednesday'
            WHEN dow = 4 THEN 'Thursday'
            WHEN dow = 5 THEN 'Friday'
            WHEN dow = 6 THEN 'Saturday'
            ELSE 'error' END AS "Signup day",
       COUNT(*) AS users,
       COUNT(CASE WHEN z.activated_at <= NOW() - INTERVAL '2 DAY' AND z.r_1_day > 0 THEN z.user_id ELSE NULL END)/
          (COUNT(CASE WHEN z.activated_at <= NOW() - INTERVAL '2 DAY' THEN z.user_id ELSE NULL END) + 1)::FLOAT AS "1 day retention",
       COUNT(CASE WHEN z.activated_at <= NOW() - INTERVAL '14 DAY' AND z.r_7_day > 0 THEN z.user_id ELSE NULL END)/
          (COUNT(CASE WHEN z.activated_at <= NOW() - INTERVAL '14 DAY' THEN z.user_id ELSE NULL END) + 1)::FLOAT AS "7 day retention",
       COUNT(CASE WHEN z.activated_at <= NOW() - INTERVAL '21 DAY' AND z.r_14_day > 0 THEN z.user_id ELSE NULL END)/
          (COUNT(CASE WHEN z.activated_at <= NOW() - INTERVAL '21 DAY' THEN z.user_id ELSE NULL END) + 1)::FLOAT AS "14 day retention",
       COUNT(CASE WHEN z.activated_at <= NOW() - INTERVAL '35 DAY' AND z.r_28_day > 0 THEN z.user_id ELSE NULL END)/
          (COUNT(CASE WHEN z.activated_at <= NOW() - INTERVAL '35 DAY' THEN z.user_id ELSE NULL END) + 1)::FLOAT AS "28 day retention"
  FROM (
SELECT u.user_id,
       EXTRACT('DOW' FROM u.activated_at) AS dow,
       u.activated_at,
       COUNT(CASE WHEN e.occurred_at >= u.activated_at + INTERVAL '1 DAY' AND e.occurred_at < u.activated_at + INTERVAL '2 DAY' 
                  THEN u.user_id ELSE NULL END) AS r_1_day,
       COUNT(CASE WHEN e.occurred_at >= u.activated_at + INTERVAL '7 DAY' AND e.occurred_at < u.activated_at + INTERVAL '14 DAY' 
                  THEN u.user_id ELSE NULL END) AS r_7_day,
       COUNT(CASE WHEN e.occurred_at >= u.activated_at + INTERVAL '14 DAY' AND e.occurred_at < u.activated_at + INTERVAL '21 DAY' 
                  THEN u.user_id ELSE NULL END) AS r_14_day,
       COUNT(CASE WHEN e.occurred_at >= u.activated_at + INTERVAL '28 DAY' AND e.occurred_at < u.activated_at + INTERVAL '35 DAY' 
                  THEN u.user_id ELSE NULL END) AS r_28_day
  FROM users u
  LEFT JOIN events e
    ON e.user_id = u.user_id
   AND e.occurred_at >= u.activated_at
   AND e.occurred_at < u.activated_at + INTERVAL '35 DAY'
 WHERE u.activated_at IS NOT NULL
 GROUP BY 1,2,3
       ) z
 GROUP BY dow
 ORDER BY dow
LIMIT 100