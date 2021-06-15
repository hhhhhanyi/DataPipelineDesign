MERGE `alfred-recruitment-test.aggregating.DeviceConnectionDailySurvival` T
USING `alfred-recruitment-test.tmp.DeviceConnectionDailySurvivalTmp` S
ON S.date = T.date AND S.country = T.country AND S.platform = T.platform
WHEN NOT MATCHED THEN
  INSERT (date, country, platform, user, session, device, survival_1_hr, survival_6_hr, survival_12_hr, survival_24_hr, updated_user, updated_datetime) 
  VALUES (date, country, platform, user, session, device, survival_1_hr, survival_6_hr, survival_12_hr, survival_24_hr, updated_user, updated_datetime)
WHEN MATCHED THEN
  UPDATE SET 
    T.date = S.date,
    T.country = S.country,
    T.platform = S.platform,
    T.user = S.user,
    T.session = S.session,
    T.device = S.device,
    T.survival_1_hr = S.survival_1_hr,
    T.survival_6_hr = S.survival_6_hr,
    T.survival_12_hr = S.survival_12_hr,
    T.survival_24_hr = S.survival_24_hr,
    T.updated_user = S.updated_user,
    T.updated_datetime = S.updated_datetime
