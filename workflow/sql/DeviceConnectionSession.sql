WITH dailySession AS (
  SELECT 
    device_id,
    DATE(timestamp) date,
    session_id,
    MIN(timestamp) start_time,
    IF(COUNTIF(state='timeout')=0 AND MIN(timestamp)!=MAX(timestamp), TIMESTAMP(DATE(MIN(timestamp))+1), MAX(timestamp)) end_time,
    COUNTIF(state='timeout') timeoutTime
  FROM `alfred-recruitment-test.staging.DeviceConnectionRealtimeLog` 
  WHERE DATE(timestamp) >= '{{startDate}}' AND DATE(timestamp) <= '{{endDate}}'
  GROUP BY device_id, date, session_id
),
maxUptimeCalculate AS (
  SELECT
    ds.device_id,
    date,
    IF(TIMESTAMP_DIFF(end_time, start_time, MINUTE)=0, NULL, TIMESTAMP_DIFF(end_time, start_time, MINUTE)) max_uptime_in_min,
    IF(start_time=end_time, NULL, start_time) start_time,
    IF(start_time=end_time, NULL, end_time) end_time,
    IF(start_time=end_time, NULL, session_id) session_id,
    IF(timeoutTime=0, FALSE, TRUE) ever_timeout,
    ROW_NUMBER() OVER (PARTITION BY ds.device_id, date ORDER BY TIMESTAMP_DIFF(end_time, start_time, MINUTE) desc, end_time desc) rank
  FROM dailySession ds
  WHERE 1=1 
  QUALIFY rank = 1
)

SELECT 
    muc.* EXCEPT(rank, ever_timeout),
    di.user_id,
    di.platform,
    di.country,
    muc.ever_timeout,
    'DATA_PIPELINE' updated_user,
    CURRENT_TIMESTAMP() updated_datetime
FROM maxUptimeCalculate muc
LEFT JOIN alfred-recruitment-test.raw.DeviceInfo di
  ON muc.device_id = di.device_id
ORDER BY device_id, date