use PMDB

go

set nocount on

declare @company_id unsigned bigint
declare @document_type_id unsigned bigint
declare @template_id unsigned bigint
declare @package_name varchar(200)
declare @package_code unsigned bigint
declare @receipt_id unsigned bigint
declare @receipt_date char(8)
declare @receipt_no char(22)
declare @version_id unsigned bigint
declare @template_code varchar(250)
declare @backward int
declare @yy int
declare @mm int
declare @full_receipt_id unsigned bigint
declare @curr_date date

select @backward = convert(int,FIELD1_VALUE)
from PM_SYSTEM_ATTRIBUTE_DTL
where ATTRIBUTE_CODE = 'CPAC_PARAM'
and DB_VALUE = 'QUERY_RECHARGE_PERIOD'

select @yy = datepart(yy,dateadd(mm,-@backward,getdate()))
, @mm = datepart(mm,dateadd(mm,-@backward,getdate()))
, @curr_date = getdate()

select @receipt_date = convert(char(4),@yy) || 
right(replicate('0',2)+convert(varchar(2),@mm),2) || '01'


select @company_id = COMPANY_ID from PM_COMPANY where COMPANY_CODE = 'Z'
if (@@rowcount = 0)
begin

  insert into PM_COMPANY
  (COMPANY_CODE, COMPANY_ABBR, COMPANY_NAME, COMPANY_NAME_TH, ACTIVE_BOO
  , CREATED_BY, CREATED, LAST_UPD_BY, LAST_UPD)
  values
  ('Z', 'ZZZ', 'Z Company', 'บริษัท Z', 'Y'
  , 'test', getdate(), 'test', getdate())

end

select @document_type_id = DOCUMENT_TYPE_ID from PM_DOCUMENT_TYPE where DOCUMENT_TYPE = 'B'

declare @paper_size_id unsigned bigint
declare @paper_size_name varchar(100)

select @paper_size_name = 'Z'

select @paper_size_id = PAPER_SIZE_ID from PM_PAPER_SIZE where PAPER_SIZE_NAME = @paper_size_name
if (@@rowcount = 0)
begin

  insert into PM_PAPER_SIZE
  (PAPER_SIZE_NAME, WIDTH, HEIGHT, EFFECTIVE_DATE, ACTIVE_BOO
  , CREATED_BY, CREATED, LAST_UPD_BY, LAST_UPD)
  values
  (@paper_size_name, 100, 200, getdate(), 'Y'
  , 'unit', getdate(), 'unit', getdate())

  select @paper_size_id = @@identity

end

select @template_id = TEMPLATE_ID from PM_TEMPLATE where TEMPLATE_NAME = 'Template Unit Test'
if (@@rowcount = 0)
begin

  declare @language_id unsigned bigint

  select @language_id = LANGUAGE_ID
  from PM_LANGUAGE
  where LANGUAGE_CODE = 'THA'

  insert into PM_TEMPLATE
  (TEMPLATE_NAME, TEMPLATE_VERSION, PAPER_SIZE_ID, ACTIVE_BOO
  , LANGUAGE_ID
  , CREATED_BY, CREATED, LAST_UPD_BY, LAST_UPD)
  values
  ('Template Unit Test', '1.0', @paper_size_id, 'Y'
  , @language_id
  , 'unit', getdate(), 'unit', getdate())

  select @template_id = @@identity

end

select @receipt_no = 'Z-PB-A-' || right(convert(char(4),@yy+543),2) || 
right(replicate('0',2)+convert(varchar(2),@mm),2) || '-0000000017'

select @receipt_id = RECEIPT_ID
from PM_RECEIPT
where RECEIPT_NO = @receipt_no
and RECEIPT_DATE = @receipt_date
if (@@rowcount != 0)
begin

  select @full_receipt_id = RECEIPT_ID
  from PM_RECEIPT
  where REF_RECEIPT_ID = @receipt_id
  and RECEIPT_DATE = @receipt_date
  if (@@rowcount = 0)
  begin
    select @full_receipt_id = @receipt_id
  end

  delete PM_CREDIT_NOTE_DTL
  from PM_CREDIT_NOTE_MAP M
  inner join PM_CREDIT_NOTE C on (M.CN_ID = C.CN_ID)
  inner join PM_CREDIT_NOTE_DTL P on (C.CN_ID = P.CN_ID)
  where M.RECEIPT_ID = @full_receipt_id
  and M.RECEIPT_DATE = @receipt_date
  and M.CN_DATE = @curr_date
  and C.CN_DATE = @curr_date
  and P.CN_DATE = @curr_date

  delete PM_CREDIT_NOTE_ADDR
  from PM_CREDIT_NOTE_MAP M
  inner join PM_CREDIT_NOTE C on (M.CN_ID = C.CN_ID)
  inner join PM_CREDIT_NOTE_ADDR P on (C.CN_ID = P.CN_ID)
  where M.RECEIPT_ID = @full_receipt_id
  and M.RECEIPT_DATE = @receipt_date
  and M.CN_DATE = @curr_date
  and C.CN_DATE = @curr_date
  and P.CN_DATE = @curr_date

  delete PM_CREDIT_NOTE_PAYMENT
  from PM_CREDIT_NOTE_MAP M
  inner join PM_CREDIT_NOTE C on (M.CN_ID = C.CN_ID)
  inner join PM_CREDIT_NOTE_PAYMENT P on (C.CN_ID = P.CN_ID)
  where M.RECEIPT_ID = @full_receipt_id
  and M.RECEIPT_DATE = @receipt_date
  and M.CN_DATE = @curr_date
  and C.CN_DATE = @curr_date
  and P.CN_DATE = @curr_date

  delete PM_CREDIT_NOTE
  from PM_CREDIT_NOTE_MAP M
  inner join PM_CREDIT_NOTE C on (M.CN_ID = C.CN_ID)
  where M.RECEIPT_ID = @full_receipt_id
  and M.RECEIPT_DATE = @receipt_date
  and M.CN_DATE = @curr_date
  and C.CN_DATE = @curr_date

  delete PM_CREDIT_NOTE_MAP
  from PM_CREDIT_NOTE_MAP M
  inner join PM_CREDIT_NOTE C on (M.CN_ID = C.CN_ID)
  where M.RECEIPT_ID = @full_receipt_id
  and M.RECEIPT_DATE = @receipt_date
  and M.CN_DATE = @curr_date
  and C.CN_DATE = @curr_date

  delete PM_RECEIPT_PAYMENT
  from PM_RECEIPT R
  inner join PM_RECEIPT_PAYMENT P on (R.RECEIPT_ID = P.RECEIPT_ID)
  where R.RECEIPT_ID in (@full_receipt_id, @receipt_id)
  and R.RECEIPT_DATE = @receipt_date
  and P.RECEIPT_DATE = @receipt_date

  delete PM_RECEIPT_DTL
  from PM_RECEIPT R
  inner join PM_RECEIPT_DTL P on (R.RECEIPT_ID = P.RECEIPT_ID)
  where R.RECEIPT_ID in (@full_receipt_id, @receipt_id)
  and R.RECEIPT_DATE = @receipt_date
  and P.RECEIPT_DATE = @receipt_date

  delete from PM_RECEIPT 
  where RECEIPT_ID in (@full_receipt_id, @receipt_id)
  and RECEIPT_DATE = @receipt_date

end

go

