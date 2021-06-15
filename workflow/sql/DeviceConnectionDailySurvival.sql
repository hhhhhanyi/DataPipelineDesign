SELECT 
  date,
  country,
  platform,
  COUNT(distinct user_id) AS user,
  COUNT(distinct session_id) AS session,
  COUNT(distinct device_id) AS device,
  COUNTIF(max_uptime_in_min >= 60)/COUNT(1) AS survival_1_hr,
  COUNTIF(max_uptime_in_min >= 360)/COUNT(1) AS survival_6_hr,
  COUNTIF(max_uptime_in_min >= 720)/COUNT(1) AS survival_12_hr,
  COUNTIF(max_uptime_in_min >= 1440)/COUNT(1) AS survival_24_hr,
  'DATA_PIPELINE' AS updated_user,
  CURRENT_TIMESTAMP() AS updated_datetime
FROM `alfred-recruitment-test.aggregating.DeviceConnectionSession`
WHERE session_id IS NOT NULL
GROUP BY date, country, platform
ORDER BY date, country
