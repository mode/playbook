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

SELECT DATE_TRUNC('{{time_interval}}',u.activated_at) AS signup_date,

{% if time_interval == 'month' %}
       (DATE_PART('year',e.occurred_at) - DATE_PART('year',u.activated_at)) * 12 +
          (DATE_PART('month',e.occurred_at) - DATE_PART('month',u.activated_at)) AS user_period,
{% elsif time_interval == 'week' %}
       TRUNC(DATE_PART('day',e.occurred_at - u.activated_at)/7) AS user_period,
{% elsif time_interval == 'day' %}
       DATE_PART('day',e.occurred_at - u.activated_at) AS user_period,
{% endif %}

       COUNT(DISTINCT e.user_id) AS retained_users
  FROM users u
  JOIN events e
    ON e.user_id = u.user_id
   AND e.occurred_at >= u.activated_at
   AND e.occurred_at <= '2014-10-31'::TIMESTAMP
 WHERE u.activated_at >= '2014-10-31'::TIMESTAMP - INTERVAL '11 {{time_interval}}'
   AND u.activated_at <= '2014-10-31'::TIMESTAMP
 GROUP BY 1,2
 ORDER BY 1,2
LIMIT 100


{% form %}

time_interval:
  type: select
  default: month
  options: [[week, week],
            [month, month]
           ]
           
{% endform %}