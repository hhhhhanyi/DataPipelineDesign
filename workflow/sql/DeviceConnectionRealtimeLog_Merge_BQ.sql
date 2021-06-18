MERGE `alfred-recruitment-test.staging.DeviceConnectionRealtimeLog` T
USING `alfred-recruitment-test.tmp.DeviceConnectionRealtimeLogTmp` S
ON T.device_id = S.device_id AND T.timestamp=S.timestamp
WHEN NOT MATCHED THEN
  INSERT (device_id, session_id, state, timestamp, updated_user, updated_datetime) 
  VALUES (device_id, session_id, state, timestamp, updated_user, updated_datetime)
WHEN MATCHED THEN
  UPDATE SET 
    T.device_id=S.device_id,
    T.session_id=S.session_id,
    T.state=S.state,
    T.timestamp=S.timestamp,
    T.updated_user=S.updated_user,
    T.updated_datetime=S.updated_datetime