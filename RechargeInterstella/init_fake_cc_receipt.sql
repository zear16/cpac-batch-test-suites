use PMDB

go

set nocount on

insert into PM_CASH_CARD_RECEIPT
(MOBILE_NO, SERVICE_ID, RECHARGE_DTM, CARD_BATCH_ID, CARD_SERIAL_NO
, RECEIPT_NO, BILLING_SYSTEM
, CREATED_BY, CREATED, LAST_UPD_BY, LAST_UPD)
values
('0637822537', 160004, '20160616', '16000', '10'
, 'D-B-P-5906-0000000007', 'BOS'
, 'unit', getdate(), 'unit', getdate())

go

 
