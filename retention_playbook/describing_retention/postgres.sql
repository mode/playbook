-- For details on how to use this report, visit
-- https://modeanalytics.zendesk.com/hc/en-us/articles/203484670

WITH 

users AS (
  SELECT customer_id AS user_id,
         signup_date AS activated_at
    FROM benn.sample_customer_table
),
  
events AS (
  SELECT customer_id AS user_id,
         event_name,
         event_date AS occurred_at
    FROM benn.sample_event_table
)


SELECT DATE_TRUNC('day',z.activated_at) AS signup_date,
       z.counter AS user_period,
       COUNT(z.user_id) AS signups,
       COUNT(CASE WHEN events > 0 THEN z.user_id ELSE NULL END) AS retained_users
  FROM (

SELECT u.user_id,
       u.counter,
       u.activated_at,
       u.period_start,
       COUNT(e.user_id) AS events
  FROM (
        SELECT user_id,
               activated_at,
               activated_at + (counter * INTERVAL '1 day') AS period_start,
               activated_at + ((counter + 1) * INTERVAL '1 day') AS period_end,
               counter
          FROM users u
          JOIN (SELECT s.a AS counter FROM generate_series(1,9) AS s(a)) c
            ON c.counter < 10
           AND c.counter > 0
         WHERE u.activated_at >= '2014-10-31'::TIMESTAMP - INTERVAL '11 day'
       ) u
  LEFT JOIN events e
    ON e.user_id = u.user_id
   AND e.occurred_at >= u.period_start
   AND e.occurred_at < u.period_end
   AND e.event_name = 'engagement_event'
   AND e.occurred_at >= '2014-10-31'::TIMESTAMP - INTERVAL '11 day'
 WHERE u.period_start <= '2014-10-31'::TIMESTAMP
 GROUP BY 1,2,3,4
       ) z
 GROUP BY 1,2
 ORDER BY 1,2
LIMIT 100