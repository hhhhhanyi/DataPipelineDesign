WITH followedTime AS (
  SELECT
    device_id,
    state,
    timestamp,
    LEAD(timestamp) OVER (PARTITION BY device_id ORDER BY timestamp ASC) AS followed_timestamp
  FROM `alfred-recruitment-test.raw.DeviceConnection`
),
sessionStartEndTime AS (
  SELECT 
    device_id,
    timestamp,
    followed_timestamp,
    CASE
      WHEN state='Started' THEN 'min'
      WHEN followed_timestamp IS NULL OR TIMESTAMP_DIFF(followed_timestamp, timestamp, MINUTE) > 30 THEN 'max'
      ELSE 'med'
    END AS sessionTime
  FROM followedTime
),
session AS (
  SELECT 
    dc.device_id,
    min.timestamp AS min,
    max.timestamp AS max,
    ARRAY_AGG(dc.timestamp ORDER BY min.timestamp) arr,
    ROW_NUMBER() OVER (PARTITION BY dc.device_id, min.timestamp ORDER BY max.timestamp) rank
  FROM `alfred-recruitment-test.raw.DeviceConnection` dc
  CROSS JOIN (SELECT device_id, timestamp FROM sessionStartEndTime WHERE sessionTime = 'min') min
  CROSS JOIN (SELECT device_id, timestamp FROM sessionStartEndTime WHERE sessionTime = 'max') max
  WHERE dc.device_id = min.device_id 
    AND dc.timestamp >= min.timestamp
    AND dc.device_id = max.device_id
    AND dc.timestamp <= max.timestamp
  GROUP BY dc.device_id, min, max
  QUALIFY rank = 1
),
addTimeout as (
  SELECT
    s.device_id,
    IF(state != 'Timeout', ARRAY_CONCAT(arr, [TIMESTAMP_ADD(max, INTERVAL 30 MINUTE)]), arr) timestamp_list,
    ROW_NUMBER() OVER (PARTITION BY s.device_id ORDER BY min) session_id
  FROM session s
  JOIN `alfred-recruitment-test.raw.DeviceConnection` dc
    ON s.max = dc.timestamp and s.device_id = dc.device_id 
)

SELECT
  a.device_id,
  session_id,
  IFNULL(state, 'Timeout') state,
  timestamp,
  'DATA_PIPELINE' AS updated_user,
  CURRENT_TIMESTAMP() AS updated_datetime
FROM addTimeout a, UNNEST(timestamp_list) timestamp
LEFT JOIN `alfred-recruitment-test.raw.DeviceConnection` dc
  ON a.device_id = dc.device_id AND timestamp = dc.timestamp
