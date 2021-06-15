MERGE `alfred-recruitment-test.aggregating.DeviceConnectionSession` T
USING `alfred-recruitment-test.tmp.DeviceConnectionSessionTmp` S
ON S.date = T.date AND S.device_id = T.device_id
WHEN NOT MATCHED THEN
  INSERT (device_id, date, max_uptime_in_min, start_time, end_time, session_id, user_id, platform, country, ever_timeout, updated_user, updated_datetime) 
  VALUES (device_id, date, max_uptime_in_min, start_time, end_time, session_id, user_id, platform, country, ever_timeout, updated_user, updated_datetime)
WHEN MATCHED THEN
  UPDATE SET 
    T.device_id=S.device_id,
    T.date=S.date,
    T.max_uptime_in_min=S.max_uptime_in_min,
    T.start_time=S.start_time,
    T.end_time=S.end_time,
    T.session_id=S.session_id,
    T.user_id=S.user_id,
    T.platform=S.platform,
    T.country=S.country,
    T.ever_timeout=S.ever_timeout,
    T.updated_user=S.updated_user,
    T.updated_datetime=S.updated_datetime