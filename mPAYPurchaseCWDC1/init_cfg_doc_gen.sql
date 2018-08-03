use PMDB

go

set nocount on

declare @channel_id unsigned bigint
declare @company_id unsigned bigint
declare @bop_id unsigned bigint
declare @document_type_id unsigned bigint
declare @template_id unsigned bigint
declare @cfg_doc_gen_id unsigned bigint

select @channel_id = PC.CHANNEL_ID
from PM_RECHARGE_SERVICE RS
inner join PM_CFG_RECHARGE_SERVICE CRS on (RS.SERVICE_ROW_ID = CRS.SERVICE_ROW_ID)
inner join PM_PAYMENT_CATEGORY PCA on (CRS.CATEGORY_CODE = PCA.CATEGORY_CODE)
inner join PM_PAYMENT_CHANNEL PC on (PCA.CHANNEL_ID = PC.CHANNEL_ID)
left join PM_RECHARGE_SERVICE_MAPPING SM on (RS.SERVICE_ROW_ID = SM.SERVICE_ROW_ID)
where RS.SERVICE_ID = 46

select @company_id = COMPANY_ID
from PM_COMPANY
where COMPANY_ABBR = 'AIS'

select @bop_id = BOP_ID
from PM_BUSINESS_OF_PAYMENT 
where BOP_CODE = 'P'

select @document_type_id = DOCUMENT_TYPE_ID
from PM_DOCUMENT_TYPE
where DOCUMENT_TYPE = 'N'

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
  , getdate(), 'init', getdate(), 'init', getdate())

end

select @channel_id = CHANNEL_ID from PM_V_LOCATION where LOCATION_CODE = 1020

select @document_type_id = DOCUMENT_TYPE_ID
from PM_DOCUMENT_TYPE
where DOCUMENT_TYPE = 'R'

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

select @company_id = COMPANY_ID
from PM_COMPANY
where COMPANY_CODE = 'Z'
if (@@rowcount = 0)
begin

  insert into PM_COMPANY
  (COMPANY_CODE, COMPANY_ABBR, COMPANY_NAME, COMPANY_NAME_TH, ACTIVE_BOO
  , CREATED_BY, CREATED, LAST_UPD_BY, LAST_UPD)
  values
  ('Z', 'ZZZ', 'Z Company', 'บริษัท Z', 'Y'
  , 'test', getdate(), 'test', getdate())

  select @company_id = @@identity

end

select @channel_id = CHANNEL_ID from PM_V_LOCATION where LOCATION_CODE = 1020

select @document_type_id = DOCUMENT_TYPE_ID
from PM_DOCUMENT_TYPE
where DOCUMENT_TYPE = 'R'

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


select @bop_id = 1

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

select @company_id = COMPANY_ID
from PM_COMPANY
where COMPANY_CODE = 'Z'

select @channel_id = CHANNEL_ID
from PM_PAYMENT_CHANNEL
where CHANNEL_CODE = 'A'

select @bop_id = BOP_ID
from PM_BUSINESS_OF_PAYMENT
where BOP_CODE = 'P'

select @document_type_id = DOCUMENT_TYPE_ID
from PM_DOCUMENT_TYPE
where DOCUMENT_TYPE = 'R'

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

select @channel_id = CHANNEL_ID
from PM_PAYMENT_CHANNEL
where CHANNEL_CODE = 'B'

select @document_type_id = DOCUMENT_TYPE_ID
from PM_DOCUMENT_TYPE
where DOCUMENT_TYPE = 'C'

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

select @channel_id = CHN.CHANNEL_ID
from PM_PAYMENT_CATEGORY CAT
inner join PM_PAYMENT_CHANNEL CHN on (CAT.CHANNEL_ID = CHN.CHANNEL_ID)
where CAT.CATEGORY_ABBR = 'MP'

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


