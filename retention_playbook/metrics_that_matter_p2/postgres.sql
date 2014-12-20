-- For details on how to use this report, visit
-- https://modeanalytics.zendesk.com/hc/en-us/articles/203317944

WITH 
  users AS (

SELECT user_id,
       activated_at
  FROM tutorial.playbook_users

),

  events AS (

SELECT user_id,
       event_name,
       occurred_at
  FROM tutorial.playbook_events
)

SELECT u.user_id,
       u.activated_at,
       MAX(CASE WHEN e.occurred_at >= u.activated_at + INTERVAL '7 DAY' THEN 1 ELSE 0 END) AS retained,
       COUNT(CASE WHEN e.event_name = 'home_page' THEN e.user_id ELSE NULL END) AS home_page_visits,
       COUNT(CASE WHEN e.event_name = 'search_run' THEN e.user_id ELSE NULL END) AS searches,
       COUNT(CASE WHEN e.event_name = 'send_message' THEN e.user_id ELSE NULL END) AS messages,
       COUNT(CASE WHEN e.event_name = 'like_message' THEN e.user_id ELSE NULL END) AS like_message,
       COUNT(CASE WHEN e.event_name = 'view_inbox' THEN e.user_id ELSE NULL END) AS view_inbox
  FROM users u
  JOIN events e
    ON e.user_id = u.user_id
   AND e.occurred_at >= u.activated_at
   AND e.occurred_at < u.activated_at + INTERVAL '14 DAY'
 GROUP BY 1,2