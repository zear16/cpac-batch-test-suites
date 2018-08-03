use PMDB

go

set nocount on

declare @service_id       unsigned bigint
declare @channel_id       unsigned bigint
declare @company_id       unsigned bigint
declare @bop_id           unsigned bigint
declare @document_type_id unsigned bigint
declare @template_id      unsigned bigint
declare @cfg_doc_gen_id   unsigned bigint

select @service_id = 46

select @channel_id = PC.CHANNEL_ID
from PM_RECHARGE_SERVICE RS
inner join PM_CFG_RECHARGE_SERVICE CRS on (RS.SERVICE_ROW_ID = CRS.SERVICE_ROW_ID)
inner join PM_PAYMENT_CATEGORY PCA on (CRS.CATEGORY_CODE = PCA.CATEGORY_CODE)
inner join PM_PAYMENT_CHANNEL PC on (PCA.CHANNEL_ID = PC.CHANNEL_ID)
left join PM_RECHARGE_SERVICE_MAPPING SM on (RS.SERVICE_ROW_ID = SM.SERVICE_ROW_ID)
where RS.SERVICE_ID = @service_id

select @company_id = COMPANY_ID
from PM_COMPANY
where COMPANY_ABBR = 'DPC'

select @bop_id = BOP_ID
from PM_BUSINESS_OF_PAYMENT 
where BOP_CODE = 'P'

select @document_type_id = DOCUMENT_TYPE_ID
from PM_DOCUMENT_TYPE
where DOCUMENT_TYPE = 'B'

select @template_id = TEMPLATE_ID
from PM_TEMPLATE
where TEMPLATE_NAME = 'Template1'

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
  , getdate(), 'init', getdate(), 'init', getdate())

end

select @channel_id = PC.CHANNEL_ID
from PM_RECHARGE_SERVICE RS
inner join PM_CFG_RECHARGE_SERVICE CRS on (RS.SERVICE_ROW_ID = CRS.SERVICE_ROW_ID)
inner join PM_PAYMENT_CATEGORY PCA on (CRS.CATEGORY_CODE = PCA.CATEGORY_CODE)
inner join PM_PAYMENT_CHANNEL PC on (PCA.CHANNEL_ID = PC.CHANNEL_ID)
left join PM_RECHARGE_SERVICE_MAPPING SM on (RS.SERVICE_ROW_ID = SM.SERVICE_ROW_ID)
where RS.SERVICE_ID = 160004

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
  , getdate(), 'init', getdate(), 'init', getdate())

end

go


