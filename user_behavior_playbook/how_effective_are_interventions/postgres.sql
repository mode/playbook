-- For details on how to use this report, visit
-- https://modeanalytics.zendesk.com/hc/en-us/articles/203501550

WITH 

  users AS (

SELECT user_id,
       activated_at
  FROM tutorial.playbook_users

),

  events AS (

SELECT user_id,
       occurred_at
  FROM tutorial.playbook_events
 WHERE event_type = 'engagement'
   AND event_name = 'login'

),

  interventions AS (

SELECT user_id,
       occurred_at
  FROM tutorial.playbook_emails
 WHERE action = 'sent_reengagement_email'
)

SELECT z.counter AS time_from_event,
       COUNT(DISTINCT CASE WHEN z.user_age BETWEEN 31 AND 60 AND z.logged_event = TRUE THEN z.user_id ELSE NULL END)/
          COUNT(DISTINCT CASE WHEN z.user_age BETWEEN 31 AND 60 THEN z.user_id ELSE NULL END)::FLOAT AS "31 to 60 days old",
       COUNT(DISTINCT CASE WHEN z.user_age BETWEEN 61 AND 90 AND z.logged_event = TRUE THEN z.user_id ELSE NULL END)/
          COUNT(DISTINCT CASE WHEN z.user_age BETWEEN 61 AND 90 THEN z.user_id ELSE NULL END)::FLOAT AS "61 to 90 days old",
       COUNT(DISTINCT CASE WHEN z.user_age BETWEEN 91 AND 150 AND z.logged_event = TRUE THEN z.user_id ELSE NULL END)/
          COUNT(DISTINCT CASE WHEN z.user_age BETWEEN 91 AND 150 THEN z.user_id ELSE NULL END)::FLOAT AS "91 to 150 days old",
       COUNT(DISTINCT CASE WHEN z.user_age >= 151 AND z.logged_event = TRUE THEN z.user_id ELSE NULL END)/
          COUNT(DISTINCT CASE WHEN z.user_age >= 151 THEN z.user_id ELSE NULL END)::FLOAT AS "151 days and older"
  FROM (
SELECT u.user_id,
       EXTRACT('day' FROM i.occurred_at - u.activated_at) AS user_age,
       i.occurred_at,
       u.activated_at,
       c.counter,
       CASE WHEN e.occurred_at IS NOT NULL THEN TRUE ELSE FALSE END AS logged_event
  FROM interventions i
  JOIN users u
    ON u.user_id = i.user_id
   AND u.activated_at < i.occurred_at
  JOIN (SELECT s.a - 30 AS counter FROM generate_series(0,60) AS s(a)) c
    ON c.counter >= -30
   AND c.counter <= 30
  LEFT JOIN events e
    ON e.user_id = i.user_id
   AND EXTRACT('day' FROM e.occurred_at - i.occurred_at) = c.counter
 WHERE EXTRACT('day' FROM NOW() - i.occurred_at) >= 30
       ) z
 GROUP BY 1
 ORDER BY 1
LIMIT 100