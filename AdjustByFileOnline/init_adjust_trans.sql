use PMDB

go

set nocount on

declare @adjust_id     unsigned bigint
declare @so_nbr        varchar(64)
declare @run_date      date
declare @template_code varchar(64)
declare @file_id       unsigned bigint
declare @order_id      unsigned bigint

select @template_code = 'UNIT_ADJ_BY_FILE_ONL'
, @run_date = '20160616'

delete from PM_JOB_ORDER where RUN_DATE = @run_date and TEMPLATE_CODE = @template_code

-- Original Order
insert into PM_JOB_ORDER
(ORDER_TYPE, TEMPLATE_CODE, ORDER_MODE, RUN_DATE, DATA_DATE_FR, DATA_DATE_TO
, ORDER_STATUS, FILE_PATH
, ORIGINAL_FILE_NAME)
values
('E', @template_code, 'A', @run_date, dateadd(dd, -1, @run_date), dateadd(dd, -1, @run_date)
, 'W', '/export/home/MNT_NFS/bos1/BSSBRoker/input/AdjustBalance'
, 'UnitTest-AdjustBalance_20160616_000000.dat')

select @order_id = @@identity

select @so_nbr = 'Unit Test Adjust By File Online'

delete from PM_ADJUST_TRANSACTION where SO_NBR = @so_nbr

insert into PM_FILE_ADJUST
(ORDER_ID, FILE_NAME, OVER_MAX_BOO, SEND_SMS_BOO
, CREATED_BY, CREATED, LAST_UPD_BY, LAST_UPD)
values
(@order_id, 'UnitTest-AdjustBalance_20160616_000000.dat', 'N', 'N'
, 'unit', getdate(), 'unit', getdate())

select @file_id = @@identity

insert into PM_ADJUST_TRANSACTION
(SO_NBR, MOBILE_NO, ADJUST_AMT, ADJUST_VALIDITY, ADJUST_STATUS, BILLING_SYSTEM
, FILE_ID, ACCOUNT_NO, REMARK
, ADJUST_DTM, ADJUST_DATE, TRANSPARENT_DATA1, TRANSPARENT_DATA2
, CREATED_BY, CREATED, LAST_UPD_BY, LAST_UPD)
values
(@so_nbr, '0910021160', 938, null, 'SC', 'BOS'
, @file_id, '201607210090464', '16061600000000000000'
, '20160615', '20160615', 'cPAC', 'ADJ_BY_FILE'
, 'unit', '20160615', 'unit', '20160615')

print '%1!', @order_id

go

