# Data Pipeline Design

## Demo
<img src="https://i.imgur.com/JLlFIXw.gif" width="900"/>

## Introduction
- workflow/*.json：flow 設定檔，用以設定 data pipeline 須執行的流程
- worker.sh: 執行 flow 設定檔，會順著一步一步執行
- workflow.sh: 執行 step 時會用到的 function
    - import_bq: 將資料 export 成檔案做備份，並存入指定 Table
    - exec_bq_sql: 執行指定 SQL file 的語法
    - trigger_flow: 用以 trigger 相關上下游的 flow
- utilities.sh
    - gcloudAuth: GCP 授權，若已有權限會略過
    - createTable: 根據 schema 定義新增 table
    - getFlowStepInfo: 讀取 flow 設定檔各 step 細節

## Workflow

### DeviceConnectionFlow
- Schedule: Every 30 minutes

<img src="https://i.imgur.com/kAqUZ23.png" width="400"/>

### DeviceConnectionReportFlow
- Schedule: Everyday 01:00 am

<img src="https://i.imgur.com/FcRtrje.png" width="900"/>

## Data Structure
### DeviceConnection
- CLUSTER_FIELDS: device_id

| name | type | discribtion | 
| ------ | -----------------------  | ------- | 
| device_id | STRING | 裝置 ID | 
| state | STRING | 裝置狀態 | 
| timestamp | TIMESTAMP | 裝置狀態檢查時間 | 

### DeviceConnectionRealtimeLog
- CLUSTER_FIELDS: timestamp,device_id,session_id"
- PARTITION_FIELDS: timestamp

| name | type | discribtion | 
| ------ | -----------------------  | ------- | 
| device_id | STRING | 裝置 ID | 
| session_id | INTEGER | Session ID | 
| state | STRING | 裝置狀態 | 
| timestamp | TIMESTAMP | 裝置狀態檢查時間 | 
| updated_user | STRING | 資料更新者 | 
| updated_datetime | TIMESTAMP | 資料更新時間 | 

### DeviceConnectionSession
- PARTITION_FIELDS: date

| name | type | discribtion | 
| ------ | -----------------------  | ------- | 
| date | DATE | 日期 | 
| device_id | STRING | 裝置 ID | 
| max_uptime_in_min | INTEGER | 最長連線時間（分） | 
| start_time | TIMESTAMP | 連線開始時間 | 
| end_time | TIMESTAMP | 連線結束時間 | 
| session_id | INTEGER | Session ID | 
| user_id | INTEGER | 使用者 ID | 
| country | STRING | 國家 | 
| platform | STRING | 裝置平台 | 
| ever_timeout | BOOLEAN | 是否 timeout | 
| updated_user | STRING | 資料更新者 | 
| updated_datetime | TIMESTAMP | 資料更新時間 | 

### DeviceConnectionWeeklyMaxUptime
- CLUSTER_FIELDS: week_day, device_id
- PARTITION_FIELDS: week_day

| name | type | discribtion | 
| ------ | -----------------------  | ------- | 
| date | DATE | 日期 | 
| device_id | STRING | 裝置 ID | 
| max_uptime_in_day | INTEGER | 最長連線時間（日） | 
| max_uptime_start_time | TIMESTAMP | 連線開始時間 | 
| max_uptime_end_time | TIMESTAMP | 連線結束時間 | 
| updated_user | STRING | 資料更新者 | 
| updated_datetime | TIMESTAMP | 資料更新時間 | 

### DeviceConnectionDailySurvival
- CLUSTER_FIELDS: date, country, platform
- PARTITION_FIELDS: date

| name | type | discribtion | 
| ------ | -----------------------  | ------- | 
| date | DATE | 日期 | 
| country | STRING | 國家 | 
| platform | STRING | 裝置平台 | 
| user | INTEGER | 使用者數 | 
| session | INTEGER | Session 數 | 
| device | INTEGER | 裝置數 | 
| survival_1_hr | FLOAT64 | 連線 1 小時（含）比例 | 
| survival_6_hr | FLOAT64 | 連線 6 小時（含）比例 | 
| survival_12_hr | FLOAT64 | 連線 12 小時（含）比例 | 
| survival_24_hr | FLOAT64 | 連線 24 小時（含）比例 | 
| updated_user | STRING | 資料更新者 | 
| updated_datetime | TIMESTAMP | 資料更新時間 | 

### DeviceInfo
- CLUSTER_FIELDS: device_id

| name | type | discribtion | 
| ------ | -----------------------  | ------- | 
| device_id | STRING | 裝置 ID | 
| user_id | INTEGER | 使用者 ID | 
| platform | STRING | 裝置平台 | 
| country | STRING | 國家 | 
| updated_user | STRING | 資料更新者 | 
| updated_datetime | TIMESTAMP | 資料更新時間 | 

## Tech Stack
- GKE
- BigQuery
- bash

## Contact
**Han-Yi Lin**<br>
E-mail: hhhhhanyi@gmail.com

