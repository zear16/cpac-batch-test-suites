use PMDB

go

set nocount on

declare @cfg_doc_action_id unsigned bigint
declare @document_type_id unsigned bigint
declare @bop_id unsigned bigint
declare @doc_status char(1)

select @doc_status = 'N'

select @document_type_id = DOCUMENT_TYPE_ID
from PM_DOCUMENT_TYPE
where DOCUMENT_TYPE = 'B'

select @bop_id = BOP_ID
from PM_BUSINESS_OF_PAYMENT
where BOP_CODE = 'P'

select @cfg_doc_action_id = CFG_DOC_ACTION_ID
from PM_CFG_DOC_ACTION
where DOCUMENT_TYPE_ID = @document_type_id
and BOP_ID = @bop_id
and DOC_STATUS = @doc_status
if (@@rowcount = 0)
begin
  insert into PM_CFG_DOC_ACTION
  (DOCUMENT_TYPE_ID, BOP_ID, DOC_STATUS
  , ACTION_CANCEL_BOO, ACTION_CN_BOO, ACTION_COPY_BOO, ACTION_REPRINT_BOO
  , ACTION_FULL_BOO, ACTION_CHANGE_VAT_BOO, ACTION_CHANGE_BILL_BOO
  , ACTION_WT_REFUND_BOO, ACTION_PRINT_ABLE_BOO
  , EFFECTIVE_DATE, CREATED_BY, CREATED, LAST_UPD_BY, LAST_UPD)
  values
  (@document_type_id, @bop_id, @doc_status
  , 'N', 'Y', 'N', 'N'
  , 'N', 'N', 'N'
  , 'N', 'N'
  , '20120101', 'unit', getdate(), 'unit', getdate())
end
else
begin
  update PM_CFG_DOC_ACTION set ACTION_CN_BOO = 'Y'
  where CFG_DOC_ACTION_ID = @cfg_doc_action_id 
end

select @doc_status = 'P'

select @document_type_id = DOCUMENT_TYPE_ID
from PM_DOCUMENT_TYPE
where DOCUMENT_TYPE = 'B'

select @bop_id = BOP_ID
from PM_BUSINESS_OF_PAYMENT
where BOP_CODE = 'P'

select @cfg_doc_action_id = CFG_DOC_ACTION_ID
from PM_CFG_DOC_ACTION
where DOCUMENT_TYPE_ID = @document_type_id
and BOP_ID = @bop_id
and DOC_STATUS = @doc_status
if (@@rowcount = 0)
begin
  insert into PM_CFG_DOC_ACTION
  (DOCUMENT_TYPE_ID, BOP_ID, DOC_STATUS
  , ACTION_CANCEL_BOO, ACTION_CN_BOO, ACTION_COPY_BOO, ACTION_REPRINT_BOO
  , ACTION_FULL_BOO, ACTION_CHANGE_VAT_BOO, ACTION_CHANGE_BILL_BOO
  , ACTION_WT_REFUND_BOO, ACTION_PRINT_ABLE_BOO
  , EFFECTIVE_DATE, CREATED_BY, CREATED, LAST_UPD_BY, LAST_UPD)
  values
  (@document_type_id, @bop_id, @doc_status
  , 'N', 'Y', 'N', 'N'
  , 'N', 'N', 'N'
  , 'N', 'N'
  , '20120101', 'unit', getdate(), 'unit', getdate())
end
else
begin
  update PM_CFG_DOC_ACTION set ACTION_CN_BOO = 'Y'
  where CFG_DOC_ACTION_ID = @cfg_doc_action_id
end

select @doc_status = 'N'

select @document_type_id = DOCUMENT_TYPE_ID
from PM_DOCUMENT_TYPE
where DOCUMENT_TYPE = 'R'

select @bop_id = BOP_ID
from PM_BUSINESS_OF_PAYMENT
where BOP_CODE = 'P'

select @cfg_doc_action_id = CFG_DOC_ACTION_ID
from PM_CFG_DOC_ACTION
where DOCUMENT_TYPE_ID = @document_type_id
and BOP_ID = @bop_id
and DOC_STATUS = @doc_status
if (@@rowcount = 0)
begin
  insert into PM_CFG_DOC_ACTION
  (DOCUMENT_TYPE_ID, BOP_ID, DOC_STATUS
  , ACTION_CANCEL_BOO, ACTION_CN_BOO, ACTION_COPY_BOO, ACTION_REPRINT_BOO
  , ACTION_FULL_BOO, ACTION_CHANGE_VAT_BOO, ACTION_CHANGE_BILL_BOO
  , ACTION_WT_REFUND_BOO, ACTION_PRINT_ABLE_BOO
  , EFFECTIVE_DATE, CREATED_BY, CREATED, LAST_UPD_BY, LAST_UPD)
  values
  (@document_type_id, @bop_id, @doc_status
  , 'N', 'Y', 'N', 'N'
  , 'N', 'N', 'N'
  , 'N', 'N'
  , '20120101', 'unit', getdate(), 'unit', getdate())
end
else
begin
  update PM_CFG_DOC_ACTION set ACTION_CN_BOO = 'Y'
  where CFG_DOC_ACTION_ID = @cfg_doc_action_id
end

select @doc_status = 'P'

select @document_type_id = DOCUMENT_TYPE_ID
from PM_DOCUMENT_TYPE
where DOCUMENT_TYPE = 'R'

select @bop_id = BOP_ID
from PM_BUSINESS_OF_PAYMENT
where BOP_CODE = 'P'

select @cfg_doc_action_id = CFG_DOC_ACTION_ID
from PM_CFG_DOC_ACTION
where DOCUMENT_TYPE_ID = @document_type_id
and BOP_ID = @bop_id
and DOC_STATUS = @doc_status
if (@@rowcount = 0)
begin
  insert into PM_CFG_DOC_ACTION
  (DOCUMENT_TYPE_ID, BOP_ID, DOC_STATUS
  , ACTION_CANCEL_BOO, ACTION_CN_BOO, ACTION_COPY_BOO, ACTION_REPRINT_BOO
  , ACTION_FULL_BOO, ACTION_CHANGE_VAT_BOO, ACTION_CHANGE_BILL_BOO
  , ACTION_WT_REFUND_BOO, ACTION_PRINT_ABLE_BOO
  , EFFECTIVE_DATE, CREATED_BY, CREATED, LAST_UPD_BY, LAST_UPD)
  values
  (@document_type_id, @bop_id, @doc_status
  , 'N', 'Y', 'N', 'N'
  , 'N', 'N', 'N'
  , 'N', 'N'
  , '20120101', 'unit', getdate(), 'unit', getdate())
end
else
begin
  update PM_CFG_DOC_ACTION set ACTION_CN_BOO = 'Y'
  where CFG_DOC_ACTION_ID = @cfg_doc_action_id
end

go


