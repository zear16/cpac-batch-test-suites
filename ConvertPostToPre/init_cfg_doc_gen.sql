use PMDB

go

set nocount on

go

create or replace procedure _INSERT_CFG_DOC_GEN (
  @channel_id       unsigned bigint,
  @bop_id           unsigned bigint,
  @company_id       unsigned bigint,
  @document_type_id unsigned bigint,
  @template_th_id   unsigned bigint,
  @template_en_id   unsigned bigint,
  @cfg_doc_gen_id   unsigned bigint out
)
as

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
  , TEMPLATE_ATTATCH_EN_ID, TEMPLATE_ATTATCH_TH_ID
  , EFFECTIVE_DATE, CREATED_BY, CREATED, LAST_UPD_BY, LAST_UPD)
  values
  (@channel_id, @bop_id, @company_id, @document_type_id, 'BA', @template_th_id, @template_en_id
  , @template_en_id, @template_th_id
  , getdate(), 'unit', getdate(), 'unit', getdate())

  select @cfg_doc_gen_id = @@identity

end
else
begin

  update PM_CFG_DOC_GEN set EFFECTIVE_DATE = '20160615'
  where CFG_DOC_GEN_ID = @cfg_doc_gen_id

end

go

create or replace procedure _INSERT_CFG_DOC_GEN_ADDR (
  @bop_id           unsigned bigint,
  @document_type_id unsigned bigint,
  @language_id      unsigned bigint,
  @cfg_doc_gen_id   unsigned bigint out
)
as

select @cfg_doc_gen_id = CFG_DOC_GEN_ID
from PM_CFG_DOC_GEN_ADDR
where BOP_ID = @bop_id
and DOCUMENT_TYPE_ID = @document_type_id
and LANGUAGE_ID = @language_id
if (@@rowcount = 0)
begin

  insert into PM_CFG_DOC_GEN_ADDR
  (BOP_ID, DOCUMENT_TYPE_ID, LANGUAGE_ID, EFFECTIVE_DATE
  , COM_ADDR1
  , CREATED_BY, CREATED, LAST_UPD_BY, LAST_UPD)
  values
  (@bop_id, @document_type_id, @language_id, '20160615'
  , '{{COMPANY_NAME_TH}} {{COMPANY_TAX_ID_WITH_TEXT_TH}} {{COMPANY_BRANCH_TH}}'
  , 'unit', getdate(), 'unit', getdate())

  select @cfg_doc_gen_id = @@identity

end
else
begin

  update PM_CFG_DOC_GEN_ADDR
  set COM_ADDR1 = '{{COMPANY_NAME_TH}} {{COMPANY_TAX_ID_WITH_TEXT_TH}} {{COMPANY_BRANCH_TH}}'
  , EFFECTIVE_DATE = '20160615'
  where CFG_DOC_GEN_ID = @cfg_doc_gen_id

end

go

declare @service_id       unsigned bigint
declare @channel_id       unsigned bigint
declare @company_id       unsigned bigint
declare @bop_id           unsigned bigint
declare @document_type_id unsigned bigint
declare @template_id      unsigned bigint
declare @cfg_doc_gen_id   unsigned bigint
declare @language_id      unsigned bigint
declare @map_id           unsigned bigint

select @service_id = 52

select @channel_id = PC.CHANNEL_ID
from PM_RECHARGE_SERVICE RS
inner join PM_CFG_RECHARGE_SERVICE CRS on (RS.SERVICE_ROW_ID = CRS.SERVICE_ROW_ID)
inner join PM_PAYMENT_CATEGORY PCA on (CRS.CATEGORY_CODE = PCA.CATEGORY_CODE)
inner join PM_PAYMENT_CHANNEL PC on (PCA.CHANNEL_ID = PC.CHANNEL_ID)
left join PM_RECHARGE_SERVICE_MAPPING SM on (RS.SERVICE_ROW_ID = SM.SERVICE_ROW_ID)
where RS.SERVICE_ID = @service_id

select @bop_id = BOP_ID
from PM_BUSINESS_OF_PAYMENT
where BOP_CODE = 'P'

select @document_type_id = DOCUMENT_TYPE_ID
from PM_DOCUMENT_TYPE
where DOCUMENT_TYPE = 'B'

select @map_id = CFG_DOC_ACTION_MAP_ID
from PM_CFG_DOC_ACTION_MAP
where DOCUMENT_TYPE_ID = @document_type_id
and DOC_ACTION = 'CN'
if (@@rowcount = 0)
begin

  insert into PM_CFG_DOC_ACTION_MAP
  (DOCUMENT_TYPE_ID, DOC_ACTION, GEN_DOCUMENT_TYPE_ID, EFFECTIVE_DATE
  , CREATED_BY, CREATED, LAST_UPD_BY, LAST_UPD)
  select @document_type_id, 'CN', DOCUMENT_TYPE_ID, '20160615'
  , 'unit', getdate(), 'unit', getdate()
  from PM_DOCUMENT_TYPE
  where DOCUMENT_TYPE = 'C'

end

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

  insert into PM_TEMPLATE
  (TEMPLATE_NAME, PAPER_SIZE_ID, ACTIVE_BOO, TEMPLATE_VERSION
  , CREATED_BY, CREATED, LAST_UPD_BY, LAST_UPD)
  values
  ('Template Unit Test', @paper_size_id, 'Y', '1.0'
  , 'unit', getdate(), 'unit', getdate())

  select @template_id = @@identity

end

select @language_id = LANGUAGE_ID
from PM_LANGUAGE
where LANGUAGE_CODE = 'THA'

select @company_id = convert(unsigned bigint,FIELD1_VALUE)
from PM_SYSTEM_ATTRIBUTE_DTL
where ATTRIBUTE_CODE = 'NETWORK_TYPE_COMPANY'
and DB_VALUE = 'GSM Advance'

exec _INSERT_CFG_DOC_GEN @channel_id, @bop_id, @company_id, @document_type_id, @template_id, @template_id, @cfg_doc_gen_id out

exec _INSERT_CFG_DOC_GEN_ADDR @bop_id, @document_type_id, @language_id, @cfg_doc_gen_id out

select @company_id = convert(unsigned bigint,FIELD1_VALUE)
from PM_SYSTEM_ATTRIBUTE_DTL
where ATTRIBUTE_CODE = 'NETWORK_TYPE_COMPANY'
and DB_VALUE = 'GSM1800'

exec _INSERT_CFG_DOC_GEN @channel_id, @bop_id, @company_id, @document_type_id, @template_id, @template_id, @cfg_doc_gen_id out

exec _INSERT_CFG_DOC_GEN_ADDR @bop_id, @document_type_id, @language_id, @cfg_doc_gen_id out

select @company_id = convert(unsigned bigint,FIELD1_VALUE)
from PM_SYSTEM_ATTRIBUTE_DTL
where ATTRIBUTE_CODE = 'NETWORK_TYPE_COMPANY'
and DB_VALUE = '3G'

exec _INSERT_CFG_DOC_GEN @channel_id, @bop_id, @company_id, @document_type_id, @template_id, @template_id, @cfg_doc_gen_id out

exec _INSERT_CFG_DOC_GEN_ADDR @bop_id, @document_type_id, @language_id, @cfg_doc_gen_id out

select @document_type_id = DOCUMENT_TYPE_ID
from PM_DOCUMENT_TYPE
where DOCUMENT_TYPE = 'C'

select @channel_id = CHANNEL_ID
from PM_PAYMENT_CHANNEL
where CHANNEL_CODE = 'B'

select @bop_id = BOP_ID
from PM_BUSINESS_OF_PAYMENT
where BOP_CODE = 'I'

select @company_id = COMPANY_ID
from PM_COMPANY
where COMPANY_CODE = 'Z'

exec _INSERT_CFG_DOC_GEN @channel_id, @bop_id, @company_id, @document_type_id, @template_id, @template_id, @cfg_doc_gen_id out

exec _INSERT_CFG_DOC_GEN_ADDR @bop_id, @document_type_id, @language_id, @cfg_doc_gen_id out

select @bop_id = BOP_ID
from PM_BUSINESS_OF_PAYMENT
where BOP_CODE = 'P'

select @document_type_id = DOCUMENT_TYPE_ID
from PM_DOCUMENT_TYPE
where DOCUMENT_TYPE = 'B'

select @language_id = LANGUAGE_ID
from PM_LANGUAGE
where LANGUAGE_CODE = 'tha'

exec _INSERT_CFG_DOC_GEN @channel_id, @bop_id, @company_id, @document_type_id, @template_id, @template_id, @cfg_doc_gen_id out

exec _INSERT_CFG_DOC_GEN_ADDR @bop_id, @document_type_id, @language_id, @cfg_doc_gen_id out

select @bop_id = BOP_ID
from PM_BUSINESS_OF_PAYMENT
where BOP_CODE = 'P'

select @document_type_id = DOCUMENT_TYPE_ID
from PM_DOCUMENT_TYPE
where DOCUMENT_TYPE = 'B'

select @language_id = LANGUAGE_ID
from PM_LANGUAGE
where LANGUAGE_CODE = 'mya'

exec _INSERT_CFG_DOC_GEN @channel_id, @bop_id, @company_id, @document_type_id, @template_id, @template_id, @cfg_doc_gen_id out

exec _INSERT_CFG_DOC_GEN_ADDR @bop_id, @document_type_id, @language_id, @cfg_doc_gen_id out

select @document_type_id = DOCUMENT_TYPE_ID
from PM_DOCUMENT_TYPE
where DOCUMENT_TYPE = 'C'

select @channel_id = CHANNEL_ID
from PM_PAYMENT_CHANNEL
where CHANNEL_CODE = 'Q'

select @bop_id = BOP_ID
from PM_BUSINESS_OF_PAYMENT
where BOP_CODE = 'I'

select @company_id = COMPANY_ID
from PM_COMPANY
where COMPANY_CODE = 'Z'

exec _INSERT_CFG_DOC_GEN @channel_id, @bop_id, @company_id, @document_type_id, @template_id, @template_id, @cfg_doc_gen_id out

go

drop procedure _INSERT_CFG_DOC_GEN

drop procedure _INSERT_CFG_DOC_GEN_ADDR

go


