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
--Pivot out first five events in each session
SELECT user_id,
       session,
       MAX(CASE WHEN event_number = 1 THEN event_name ELSE NULL END) AS e1,
       MAX(CASE WHEN event_number = 2 THEN event_name ELSE NULL END) AS e2,
       MAX(CASE WHEN event_number = 3 THEN event_name ELSE NULL END) AS e3,
       MAX(CASE WHEN event_number = 4 THEN event_name ELSE NULL END) AS e4,
       MAX(CASE WHEN event_number = 5 THEN event_name ELSE NULL END) AS e5
  FROM (
       -- Find event number in session
       SELECT z.*,
              ROW_NUMBER() OVER (PARTITION BY user_id, session ORDER BY occurred_at) AS event_number
         FROM (
              -- Sum breaks to find sessions
              SELECT y.*,
                     SUM(break) OVER (ORDER BY user_id,occurred_at ROWS UNBOUNDED PRECEDING) AS session
                FROM (
                     -- Add flag if last event was more than 10 minutes ago
                     SELECT x.*,
                            CASE WHEN last_event IS NULL OR occurred_at >= last_event + INTERVAL '10 MINUTE' THEN 1 ELSE 0 END AS break
                       FROM (
                            -- Find last event
                            SELECT *,
                                   LAG(occurred_at,1) OVER (PARTITION BY user_id ORDER BY occurred_at) AS last_event
                              FROM events
                              
                            ) x
                     ) y
              ) z
       ) a
 WHERE event_number <= 5
 GROUP BY 1,2
       ) final
 GROUP BY 1,2,3,4,5
 ORDER BY 6 DESC