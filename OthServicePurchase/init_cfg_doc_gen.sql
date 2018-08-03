use PMDB

go

create or replace procedure _INSERT_CFG_DOC
  @channel       char(2),
  @bop           char(1),
  @company_code  char(2),
  @document_type char(1)
as

declare @channel_id       unsigned bigint
declare @bop_id           unsigned bigint
declare @company_id       unsigned bigint
declare @document_type_id unsigned bigint
declare @cfg_doc_gen_id   unsigned bigint 
declare @template_id      unsigned bigint

select @channel_id = CHANNEL_ID
from PM_PAYMENT_CHANNEL
where CHANNEL_CODE = @channel

select @company_id = COMPANY_ID
from PM_COMPANY
where COMPANY_CODE = @company_code

select @bop_id = BOP_ID
from PM_BUSINESS_OF_PAYMENT
where BOP_CODE = @bop

select @document_type_id = DOCUMENT_TYPE_ID
from PM_DOCUMENT_TYPE
where DOCUMENT_TYPE = @document_type

select @template_id = TEMPLATE_ID
from PM_TEMPLATE
where TEMPLATE_NAME = 'Template Unit Test'

select @cfg_doc_gen_id = CFG_DOC_GEN_ID
from PM_CFG_DOC_GEN
where CHANNEL_ID = @channel_id
and BOP_ID = @bop_id
and COMPANY_ID = @company_id
and DOCUMENT_TYPE_ID = @document_type_id
and MODE = 'BA'
if (@@rowcount = 0)
begin

  insert into PM_CFG_DOC_GEN
  (CHANNEL_ID, BOP_ID, COMPANY_ID, DOCUMENT_TYPE_ID, MODE, TEMPLATE_TH_ID, TEMPLATE_EN_ID
  , EFFECTIVE_DATE, CREATED_BY, CREATED, LAST_UPD_BY, LAST_UPD)
  values
  (@channel_id, @bop_id, @company_id, @document_type_id, 'BA', @template_id, @template_id
  , '20160101', 'init', getdate(), 'init', getdate())

end
else
begin

  update PM_CFG_DOC_GEN set EFFECTIVE_DATE = '20160101'
  where CFG_DOC_GEN_ID = @cfg_doc_gen_id

end

go

set nocount on

declare @channel_code char(2)
declare @channel_id unsigned bigint
declare @template_id unsigned bigint
declare @cfg_doc_gen_id unsigned bigint

select @channel_code = PC.CHANNEL_CODE
from PM_RECHARGE_SERVICE RS
inner join PM_CFG_RECHARGE_SERVICE CRS on (RS.SERVICE_ROW_ID = CRS.SERVICE_ROW_ID)
inner join PM_PAYMENT_CATEGORY PCA on (CRS.CATEGORY_CODE = PCA.CATEGORY_CODE)
inner join PM_PAYMENT_CHANNEL PC on (PCA.CHANNEL_ID = PC.CHANNEL_ID)
left join PM_RECHARGE_SERVICE_MAPPING SM on (RS.SERVICE_ROW_ID = SM.SERVICE_ROW_ID)
where RS.SERVICE_ID = 46

exec _INSERT_CFG_DOC @channel_code, 'P', 'A', 'N'

select @channel_code = CHANNEL_CODE
from PM_PAYMENT_CHANNEL C
inner join PM_V_LOCATION L on (C.CHANNEL_ID = L.CHANNEL_ID)
where L.LOCATION_CODE = 1020

exec _INSERT_CFG_DOC @channel_code, 'P', 'A', 'R'

/*
if ((select count(*) from PM_COMPANY where COMPANY_CODE = 'W') = 0)
begin

  insert into PM_COMPANY
  (COMPANY_CODE, COMPANY_ABBR, COMPANY_NAME, COMPANY_NAME_TH, ACTIVE_BOO
  , CREATED_BY, CREATED, LAST_UPD_BY, LAST_UPD)
  values
  ('Z', 'ZZZ', 'Z Company', 'บริษัท Z', 'Y'
  , 'test', getdate(), 'test', getdate())

end
*/

exec _INSERT_CFG_DOC @channel_code, 'P', 'Z', 'R'

exec _INSERT_CFG_DOC @channel_code, 'I', 'Z', 'R'

exec _INSERT_CFG_DOC 'A', 'P', 'Z', 'R'

exec _INSERT_CFG_DOC 'B', 'P', 'Z', 'C'

exec _INSERT_CFG_DOC 'P', 'P', 'Z', 'C'

go

drop procedure _INSERT_CFG_DOC

go



