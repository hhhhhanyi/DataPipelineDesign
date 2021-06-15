MERGE `alfred-recruitment-test.aggregating.DeviceConnectionWeeklyMaxUptime` T
USING `alfred-recruitment-test.tmp.DeviceConnectionWeeklyMaxUptimeTmp` S
ON  S.week_day = T.week_day AND S.device_id = T.device_id
WHEN NOT MATCHED THEN
  INSERT (week_day, device_id, max_uptime_in_day, max_uptime_start_time, max_uptime_end_time, updated_user, updated_datetime) 
  VALUES (week_day, device_id, max_uptime_in_day, max_uptime_start_time, max_uptime_end_time, updated_user, updated_datetime)
WHEN MATCHED THEN
  UPDATE SET 
    T.week_day=S.week_day,
    T.device_id=S.device_id,
    T.max_uptime_in_day=S.max_uptime_in_day,
    T.max_uptime_start_time=S.max_uptime_start_time,
    T.max_uptime_end_time=S.max_uptime_end_time,
    T.updated_user=S.updated_user,
    T.updated_datetime=S.updated_datetime