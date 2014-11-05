-- For details on how to use this report, visit
-- https://modeanalytics.zendesk.com/hc/en-us/articles/203501570

WITH 

  events AS (

SELECT user_id,
       event_name,
       occurred_at
  FROM tutorial.playbook_events
 WHERE event_type = 'engagement'
)

SELECT e1,
       e2,
       e3,
       e4,
       e5,
       COUNT(*) AS occurrances
  FROM (
SELECT user_id,
       session_number,
       MAX(CASE WHEN event_number = 1 THEN event_name ELSE NULL END) AS e1,
       MAX(CASE WHEN event_number = 2 THEN event_name ELSE NULL END) AS e2,
       MAX(CASE WHEN event_number = 3 THEN event_name ELSE NULL END) AS e3,
       MAX(CASE WHEN event_number = 4 THEN event_name ELSE NULL END) AS e4,
       MAX(CASE WHEN event_number = 5 THEN event_name ELSE NULL END) AS e5
  FROM (
SELECT e.user_id,
       e.occurred_at,
       s.session_number,
       e.event_name,
       ROW_NUMBER() OVER (PARTITION BY e.user_id, s.session_number ORDER BY e.occurred_at) AS event_number
  FROM (
       SELECT user_id,
              occurred_at AS session_start,
              COALESCE(LEAD(occurred_at,1) OVER (PARTITION BY user_id ORDER BY occurred_at),'2020-01-01') AS session_end,
              ROW_NUMBER() OVER (PARTITION BY user_id ORDER BY occurred_at) AS session_number
         FROM (
              SELECT user_id,
                     occurred_at,
                     EXTRACT(
                      'EPOCH' FROM occurred_at - LAG(occurred_at,1) OVER (PARTITION BY user_id ORDER BY occurred_at)
                     )/60 AS time_to_last_event
                FROM events
              ) bounds
        WHERE time_to_last_event > 30
           OR time_to_last_event IS NULL
       ) s
  JOIN events e
    ON e.user_id = s.user_id
   AND e.occurred_at >= s.session_start
   AND e.occurred_at < s.session_end 
       ) x
 GROUP BY 1,2
       ) z
 GROUP BY 1,2,3,4,5
 ORDER BY 6 DESC
LIMIT 100