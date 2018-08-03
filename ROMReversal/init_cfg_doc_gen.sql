use PMDB

go

set nocount on

declare @channel_id       unsigned bigint
declare @company_id       unsigned bigint
declare @bop_id           unsigned bigint
declare @document_type_id unsigned bigint
declare @template_id      unsigned bigint
declare @cfg_doc_gen_id   unsigned bigint

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
where DOCUMENT_TYPE = 'C'

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
  (TEMPLATE_NAME, PAPER_SIZE_ID, ACTIVE_BOO, TEMPLATE_VERSION
  , LANGUAGE_ID
  , CREATED_BY, CREATED, LAST_UPD_BY, LAST_UPD)
  values
  ('Template Unit Test', @paper_size_id, 'Y', '1.0'
  , @language_id
  , 'unit', getdate(), 'unit', getdate())

  select @template_id = @@identity

end

print 'init @channel_id=[%1!], @bop_id=[%2!], @company_id=[%3!], @document_type_id=[%4!]', @channel_id, @bop_id, @company_id, @document_type_id

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
else
begin

  update PM_CFG_DOC_GEN set EFFECTIVE_DATE = '20160101', EXPIRY_DATE = null
  where  CFG_DOC_GEN_ID = @cfg_doc_gen_id

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

select @bop_id = BOP_ID from PM_BUSINESS_OF_PAYMENT where BOP_CODE = 'P'

print 'init @channel_id=[%1!], @bop_id=[%2!], @company_id=[%3!], @document_type_id=[%4!]', @channel_id, @bop_id, @company_id, @document_type_id

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
else
begin

  update PM_CFG_DOC_GEN set EFFECTIVE_DATE = '20160101', EXPIRY_DATE = null
  where  CFG_DOC_GEN_ID = @cfg_doc_gen_id

end

select @channel_id = CHANNEL_ID from PM_PAYMENT_CHANNEL where CHANNEL_CODE = 'B'

print 'init @channel_id=[%1!], @bop_id=[%2!], @company_id=[%3!], @document_type_id=[%4!]', @channel_id, @bop_id, @company_id, @document_type_id

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
else
begin

  update PM_CFG_DOC_GEN set EFFECTIVE_DATE = '20160101', EXPIRY_DATE = null
  where  CFG_DOC_GEN_ID = @cfg_doc_gen_id

end

select @channel_id = CHANNEL_ID from PM_PAYMENT_CHANNEL where CHANNEL_CODE = 'A'

select @bop_id = BOP_ID from PM_BUSINESS_OF_PAYMENT where BOP_CODE = 'I'

select @document_type_id = GEN_DOCUMENT_TYPE_ID
from PM_CFG_DOC_ACTION_MAP
where DOCUMENT_TYPE_ID = (select DOCUMENT_TYPE_ID from PM_DOCUMENT_TYPE where DOCUMENT_TYPE='B')
and DOC_ACTION = 'FU'

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

  update PM_CFG_DOC_GEN set EFFECTIVE_DATE = '20160101' where CFG_DOC_GEN_ID = @cfg_doc_gen_id

end

select @bop_id = BOP_ID from PM_BUSINESS_OF_PAYMENT where BOP_CODE = 'P'

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

  update PM_CFG_DOC_GEN set EFFECTIVE_DATE = '20160101' where CFG_DOC_GEN_ID = @cfg_doc_gen_id

end

select @channel_id = CHANNEL_ID from PM_PAYMENT_CHANNEL where CHANNEL_CODE = 'B'

select @bop_id = BOP_ID from PM_BUSINESS_OF_PAYMENT where BOP_CODE = 'I'

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

  update PM_CFG_DOC_GEN set EFFECTIVE_DATE = '20160101' where CFG_DOC_GEN_ID = @cfg_doc_gen_id

end

select @channel_id = CHANNEL_ID from PM_PAYMENT_CHANNEL where CHANNEL_CODE = 'O'

select @bop_id = BOP_ID from PM_BUSINESS_OF_PAYMENT where BOP_CODE = 'P'

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

  update PM_CFG_DOC_GEN set EFFECTIVE_DATE = '20160101' where CFG_DOC_GEN_ID = @cfg_doc_gen_id

end 

print 'init @channel_id=[%1!], @bop_id=[%2!], @company_id=[%3!], @document_type_id=[%4!]', @channel_id, @bop_id, @company_id, @document_type_id

go


