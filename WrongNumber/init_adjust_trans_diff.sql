use PMDB

go

set nocount on

declare @adjust_id      unsigned bigint
declare @so_nbr         varchar(64)
declare @bank_code      unsigned bigint
declare @trans_no       int
declare @sub_cause_code varchar(10)
declare @sub_cause_id   unsigned bigint

select @bank_code = BANK_CODE from PM_BANK where BANK_ABBR = 'WRM'

select @trans_no = 1

select @sub_cause_code = FIELD1_VALUE
from PM_SYSTEM_ATTRIBUTE_DTL
where ATTRIBUTE_CODE = 'CPAC_PARAM'
and DB_VALUE = 'WRONG_NUMBER_SUB_CAUSE'

select @sub_cause_id = SUB_CAUSE_ID
from PM_SUB_CAUSE
where SUB_CAUSE_CODE = @sub_cause_code

select @so_nbr = 'Unit Test Adjust Wrong Number 2'

delete from PM_ADJUST_TRANSACTION where SO_NBR = @so_nbr

insert into PM_ADJUST_TRANSACTION
(SO_NBR, MOBILE_NO, ADJUST_AMT, ADJUST_VALIDITY, ADJUST_STATUS, BILLING_SYSTEM
, ADJUST_DTM, ADJUST_DATE, BANK_CODE
, TRANS_NO, GEN_CN_BOO, SUB_CAUSE_ID
, CREATED_BY, CREATED, LAST_UPD_BY, LAST_UPD)
values
(@so_nbr, '0817053436', 18, null, 'SC', 'BOS'
, '20160615', '20160615', @bank_code
, @trans_no, 'Y', @sub_cause_id
, 'unit', '20160615', 'unit', '20160615')

select @so_nbr = 'Unit Test Adjust Wrong Number 3'

delete from PM_ADJUST_TRANSACTION where SO_NBR = @so_nbr

insert into PM_ADJUST_TRANSACTION
(SO_NBR, MOBILE_NO, ADJUST_AMT, ADJUST_VALIDITY, ADJUST_STATUS, BILLING_SYSTEM
, ADJUST_DTM, ADJUST_DATE, BANK_CODE
, TRANS_NO, GEN_CN_BOO, REF_MOBILE_NO, SUB_CAUSE_ID
, CREATED_BY, CREATED, LAST_UPD_BY, LAST_UPD)
values
(@so_nbr, '0811097495', 18, null, 'SC', 'BOS'
, '20160615', '20160615', @bank_code
, @trans_no, 'N', '0817053436', @sub_cause_id
, 'unit', '20160615', 'unit', '20160615')


go

