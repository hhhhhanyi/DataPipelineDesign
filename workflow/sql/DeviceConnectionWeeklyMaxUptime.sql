SELECT 
  DATE(TIMESTAMP_TRUNC(TIMESTAMP(date), WEEK)) AS week_day,
  device_id,
  CAST(CEIL(SAFE_DIVIDE(SUM(max_uptime_in_min), 1440)) AS INT64) AS max_uptime_in_day,
  MIN(start_time) AS max_uptime_start_time,
  MAX(end_time) AS max_uptime_end_time,
  'DATA_PIPELINE' AS updated_user,
  CURRENT_TIMESTAMP() AS updated_datetime
FROM `alfred-recruitment-test.aggregating.DeviceConnectionSession`
WHERE session_id IS NOT NULL
GROUP BY week_day, device_id
ORDER BY week_day, device_id