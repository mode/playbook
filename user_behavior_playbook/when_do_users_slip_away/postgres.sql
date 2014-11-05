-- For details on how to use this report, visit
-- https://modeanalytics.zendesk.com/hc/en-us/articles/203326234


WITH 

  events AS (
  
SELECT user_id,
       occurred_at
  FROM tutorial.playbook_events
 WHERE event_name = 'send_message'
 
)

SELECT days_since_last_event AS "Days since last event",




       COUNT(CASE WHEN event_number BETWEEN 1 AND 5 AND event_number < total_events THEN user_id ELSE NULL END)/
          (COUNT(CASE WHEN event_number BETWEEN 1 AND 5 THEN user_id ELSE NULL END) + 1)::FLOAT AS "1-5",
       COUNT(CASE WHEN event_number BETWEEN 6 AND 10 AND event_number < total_events THEN user_id ELSE NULL END)/
          (COUNT(CASE WHEN event_number BETWEEN 6 AND 10 THEN user_id ELSE NULL END) + 1)::FLOAT AS "6-10",
       COUNT(CASE WHEN event_number BETWEEN 11 AND 15 AND event_number < total_events THEN user_id ELSE NULL END)/
          (COUNT(CASE WHEN event_number BETWEEN 11 AND 15 THEN user_id ELSE NULL END) + 1)::FLOAT AS "10-15",
       COUNT(CASE WHEN event_number BETWEEN 16 AND 20 AND event_number < total_events THEN user_id ELSE NULL END)/
          (COUNT(CASE WHEN event_number BETWEEN 16 AND 20 THEN user_id ELSE NULL END) + 1)::FLOAT AS "16-20",
       COUNT(CASE WHEN event_number BETWEEN 21 AND 25 AND event_number < total_events THEN user_id ELSE NULL END)/
          (COUNT(CASE WHEN event_number BETWEEN 21 AND 25 THEN user_id ELSE NULL END) + 1)::FLOAT AS "21-25",
       COUNT(CASE WHEN event_number BETWEEN 26 AND 30 AND event_number < total_events THEN user_id ELSE NULL END)/
          (COUNT(CASE WHEN event_number BETWEEN 26 AND 30 THEN user_id ELSE NULL END) + 1)::FLOAT AS "26-30",
       COUNT(CASE WHEN event_number BETWEEN 31 AND 35 AND event_number < total_events THEN user_id ELSE NULL END)/
          (COUNT(CASE WHEN event_number BETWEEN 31 AND 35 THEN user_id ELSE NULL END) + 1)::FLOAT AS "31-35",
       COUNT(CASE WHEN event_number BETWEEN 36 AND 40 AND event_number < total_events THEN user_id ELSE NULL END)/
          (COUNT(CASE WHEN event_number BETWEEN 36 AND 40 THEN user_id ELSE NULL END) + 1)::FLOAT AS "36-40",
       COUNT(CASE WHEN event_number BETWEEN 41 AND 45 AND event_number < total_events THEN user_id ELSE NULL END)/
          (COUNT(CASE WHEN event_number BETWEEN 41 AND 45 THEN user_id ELSE NULL END) + 1)::FLOAT AS "41-45",
       COUNT(CASE WHEN event_number BETWEEN 46 AND 50 AND event_number < total_events THEN user_id ELSE NULL END)/
          (COUNT(CASE WHEN event_number BETWEEN 46 AND 50 THEN user_id ELSE NULL END) + 1)::FLOAT AS "46-50",
       COUNT(CASE WHEN event_number BETWEEN 51 AND 55 AND event_number < total_events THEN user_id ELSE NULL END)/
          (COUNT(CASE WHEN event_number BETWEEN 51 AND 55 THEN user_id ELSE NULL END) + 1)::FLOAT AS "51-55",
       COUNT(CASE WHEN event_number BETWEEN 56 AND 60 AND event_number < total_events THEN user_id ELSE NULL END)/
          (COUNT(CASE WHEN event_number BETWEEN 56 AND 60 THEN user_id ELSE NULL END) + 1)::FLOAT AS "56-60",
       COUNT(CASE WHEN event_number BETWEEN 61 AND 65 AND event_number < total_events THEN user_id ELSE NULL END)/
          (COUNT(CASE WHEN event_number BETWEEN 61 AND 65 THEN user_id ELSE NULL END) + 1)::FLOAT AS "61-65",
       COUNT(CASE WHEN event_number BETWEEN 66 AND 70 AND event_number < total_events THEN user_id ELSE NULL END)/
          (COUNT(CASE WHEN event_number BETWEEN 66 AND 70 THEN user_id ELSE NULL END) + 1)::FLOAT AS "66-70",
       COUNT(CASE WHEN event_number BETWEEN 71 AND 75 AND event_number < total_events THEN user_id ELSE NULL END)/
          (COUNT(CASE WHEN event_number BETWEEN 71 AND 75 THEN user_id ELSE NULL END) + 1)::FLOAT AS "71-75"




  FROM (

SELECT c.counter AS days_since_last_event,
       x.*
  FROM (SELECT s.a AS counter FROM generate_series(0,100) AS s(a)) c
  LEFT JOIN ( 
       SELECT e.user_id,
              e.occurred_at,
              EXTRACT('day' FROM NOW() - e.occurred_at) AS days_until_now,
              COUNT(*) OVER (PARTITION BY e.user_id) AS total_events,
              ROW_NUMBER() OVER (PARTITION BY e.user_id ORDER BY e.occurred_at) AS event_number,
              COALESCE(
                EXTRACT('DAY' FROM LEAD(e.occurred_at,1) OVER (PARTITION BY e.user_id ORDER BY e.occurred_at) - e.occurred_at),
                EXTRACT('DAY' FROM NOW() - e.occurred_at)
              ) AS days_until_next
         FROM events e
       ) x
    ON x.days_until_next > c.counter
       ) z
 WHERE days_until_now >= 30
   AND days_since_last_event <= 100
   AND event_number <= 75
 GROUP BY 1
 ORDER BY 1