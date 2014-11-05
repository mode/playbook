-- For details on how to use this report, visit
-- https://modeanalytics.zendesk.com/hc/en-us/articles/203326184

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

SELECT time_id,



       home_page_visits_users AS home_page_visits,
       searches_users AS searches,
       messages_users AS messages,
       like_message_users AS like_messages,
       view_inbox_users AS view_inbox


       
  FROM (
SELECT DATE_TRUNC('day',e.occurred_at) AS time_id,
       COUNT(DISTINCT CASE WHEN e.event_name = 'home_page' THEN e.user_id ELSE NULL END) AS home_page_visits_users,
       COUNT(DISTINCT CASE WHEN e.event_name = 'search_run' THEN e.user_id ELSE NULL END) AS searches_users,
       COUNT(DISTINCT CASE WHEN e.event_name = 'send_message' THEN e.user_id ELSE NULL END) AS messages_users,
       COUNT(DISTINCT CASE WHEN e.event_name = 'like_message' THEN e.user_id ELSE NULL END) AS like_message_users,
       COUNT(DISTINCT CASE WHEN e.event_name = 'view_inbox' THEN e.user_id ELSE NULL END) AS view_inbox_users,
       COUNT(CASE WHEN e.event_name = 'home_page' THEN e.user_id ELSE NULL END) AS home_page_visits,
       COUNT(CASE WHEN e.event_name = 'search_run' THEN e.user_id ELSE NULL END) AS searches,
       COUNT(CASE WHEN e.event_name = 'send_message' THEN e.user_id ELSE NULL END) AS messages,
       COUNT(CASE WHEN e.event_name = 'like_message' THEN e.user_id ELSE NULL END) AS like_message,
       COUNT(CASE WHEN e.event_name = 'view_inbox' THEN e.user_id ELSE NULL END) AS view_inbox
  FROM users u
  JOIN events e
    ON e.user_id = u.user_id
   AND e.occurred_at >= '2014-01-01'
   AND e.occurred_at <= '2014-10-31'
 GROUP BY 1
 ORDER BY 1
       ) z