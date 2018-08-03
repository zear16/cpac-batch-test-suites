use PMDB

go

set nocount on

declare @rf_trans_id unsigned bigint
declare @session_id  varchar(100)

select @session_id = 'UnitTestTerminateRefundReconcile'

select @rf_trans_id = RF_TRANS_ID from PM_REFUND_TRANSACTION where SESSION_ID = @session_id
if (@@rowcount = 0)
begin

  insert into PM_REFUND_TRANSACTION
  (SESSION_ID, REFUND_TYPE, PROJECT_CODE, BA_NO
  , REFUND_DTM, REFUND_DATE
  , MOBILE_NO, AMOUNT, USER_ID, COMPANY_ABBR, SYSTEM
  , VAT_POSTAL_CD, LOCATION_CODE, REFUND_STATUS, GEN_CN_BOO
  , CREATED_BY, CREATED, LAST_UPD_BY, LAST_UPD)
  values
  (@session_id, 'T', '', ''
  , '20160615', '20160615'
  , '0817053436', 16, 'unit', 'AIS', 'CPAC'
  , '10170', 1020, 'SC', 'Y'
  , 'unit', '20160615', 'unit', '20160615')

end

go

