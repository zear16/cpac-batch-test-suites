use PMDB

go

set nocount on

declare @service_id unsigned   bigint
declare @service_name          varchar(200)
declare @channel_group_id      unsigned bigint
declare @recharge_channel_code unsigned bigint
declare @document_type_id      unsigned bigint
declare @category_code         unsigned bigint
declare @map_id                unsigned bigint
declare @service_row_id        unsigned bigint
declare @map_cat_id            unsigned bigint
declare @sub_bop_id            unsigned bigint
declare @transaction_code_id   unsigned bigint

select @document_type_id = DOCUMENT_TYPE_ID
from PM_DOCUMENT_TYPE
where DOCUMENT_TYPE = 'B'

select @category_code = CATEGORY_CODE
from PM_PAYMENT_CATEGORY
where CATEGORY_ABBR = 'TU'

select @sub_bop_id = SUB_BOP_ID
from PM_SUB_BUSINESS_OF_PAYMENT
where SUB_BOP_CODE = 'PT'

-- Invalid Recharge Channel

select @service_name = 'Unit Test Invalid Recharge Channel'
/*
select @channel_group_id = CHANNEL_GROUP_ID
from PM_RECHARGE_CHANNEL_GROUP
where CHANNEL_GROUP_NAME = @service_name
if (@@rowcount = 0)
begin

  insert into PM_RECHARGE_CHANNEL_GROUP
  (CHANNEL_GROUP_NAME, ACTIVE_BOO
   , CREATED_BY, CREATED, LAST_UPD_BY, LAST_UPD, EFFECTIVE_DATE)
  values
  (@service_name, 'Y'
   , 'unit', getdate(), 'unit', getdate(), getdate())

  select @channel_group_id = @@identity

end

select @recharge_channel_code = RECHARGE_CHANNEL_CODE
from PM_RECHARGE_CHANNEL
where RECHARGE_CHANNEL_NAME = @service_name
if (@@rowcount = 0)
begin

  select @recharge_channel_code = 160000

  insert into PM_RECHARGE_CHANNEL
  (RECHARGE_CHANNEL_CODE, RECHARGE_CHANNEL_NAME, CHANNEL_GROUP_ID
   , ACTIVE_BOO, CREATED_BY, CREATED, LAST_UPD_BY, LAST_UPD
   , EFFECTIVE_DATE)
  values
  (@recharge_channel_code, @service_name, @channel_group_id
   , 'Y', 'unit', getdate(), 'unit', getdate()
   , getdate())

end
*/

select @service_id = 160000

select @service_row_id = SERVICE_ROW_ID
from PM_RECHARGE_SERVICE
where SERVICE_ID = @service_id
if (@@rowcount = 0)
begin


  insert into PM_RECHARGE_SERVICE
  (SERVICE_ID, SERVICE_NAME, DOCUMENT_TYPE_ID
   , RECHARGE_BOO, GEN_RECEIPT_BOO, ACTIVE_BOO, EFFECTIVE_DATE
   , CASH_CARD_BOO
   , CREATED_BY, CREATED, LAST_UPD_BY, LAST_UPD)
  values
  (@service_id, @service_name, @document_type_id
   , 'Y', 'Y', 'Y', getdate()
   , 'N'
   , 'unit', getdate(), 'unit', getdate())

  select @service_row_id = @@identity

end
else
begin

  update PM_RECHARGE_SERVICE
  set DOCUMENT_TYPE_ID = @document_type_id
  , RECHARGE_BOO = 'Y'
  , GEN_RECEIPT_BOO = 'Y'
  , CASH_CARD_BOO = 'N'
  , ACTIVE_BOO = 'Y'
  where SERVICE_ROW_ID = @service_row_id

end

delete from PM_CFG_RECHARGE_SERVICE where SERVICE_ROW_ID = @service_row_id

-- GEN_RECEIPT_BOO = 'N'

select @service_name = 'Unit Test Recharge Service Not Gen'

select @service_id = 160001

select @service_row_id = SERVICE_ROW_ID
from PM_RECHARGE_SERVICE
where SERVICE_ID = @service_id
if (@@rowcount = 0)
begin

  insert into PM_RECHARGE_SERVICE
  (SERVICE_ID, SERVICE_NAME, DOCUMENT_TYPE_ID
   , GEN_RECEIPT_BOO, RECHARGE_BOO, ACTIVE_BOO, EFFECTIVE_DATE
   , CASH_CARD_BOO
   , CREATED_BY, CREATED, LAST_UPD_BY, LAST_UPD)
  values
  (@service_id, @service_name, @document_type_id
   , 'N', 'Y', 'Y', getdate()
   , 'N'
   , 'unit', getdate(), 'unit', getdate())

  select @service_row_id = @@identity

end
else
begin

  update PM_RECHARGE_SERVICE
  set DOCUMENT_TYPE_ID = @document_type_id
  , GEN_RECEIPT_BOO = 'N'
  , RECHARGE_BOO = 'Y'
  , CASH_CARD_BOO = 'N'
  , ACTIVE_BOO = 'Y'
  where SERVICE_ROW_ID = @service_row_id

end

select @map_cat_id = MAP_CAT_ID
from PM_CFG_RECHARGE_SERVICE
where SERVICE_ROW_ID = @service_row_id
if (@@rowcount = 0)
begin

  insert into PM_CFG_RECHARGE_SERVICE
  (SERVICE_ROW_ID, CATEGORY_CODE, RC_SUB_BOP_ID, ACTIVE_BOO
   , CREATED_BY, CREATED, LAST_UPD_BY, LAST_UPD)
  values
  (@service_row_id, @category_code, @sub_bop_id, 'Y'
  , 'init', getdate(), 'init', getdate()) 

end


-- Missing Method Code

select @service_name = 'Unit Test Service Without Method'

select @service_id = 160002

select @service_row_id = SERVICE_ROW_ID
from PM_RECHARGE_SERVICE
where SERVICE_ID = @service_id
if (@@rowcount = 0)
begin

  insert into PM_RECHARGE_SERVICE
  (SERVICE_ID, SERVICE_NAME, DOCUMENT_TYPE_ID
   , RECHARGE_BOO, GEN_RECEIPT_BOO, ACTIVE_BOO, EFFECTIVE_DATE
   , CASH_CARD_BOO
   , CREATED_BY, CREATED, LAST_UPD_BY, LAST_UPD)
  values
  (@service_id, @service_name, @document_type_id
   , 'Y', 'Y', 'Y', getdate()
   , 'N'
   , 'unit', getdate(), 'unit', getdate())

  select @service_row_id = @@identity

end
else
begin

  update PM_RECHARGE_SERVICE
  set DOCUMENT_TYPE_ID = @document_type_id
  , RECHARGE_BOO = 'Y'
  , GEN_RECEIPT_BOO = 'Y'
  , ACTIVE_BOO = 'Y'
  where SERVICE_ROW_ID = @service_row_id

end

select @map_cat_id = MAP_CAT_ID
from PM_CFG_RECHARGE_SERVICE
where SERVICE_ROW_ID = @service_row_id
if (@@rowcount = 0)
begin

  insert into PM_CFG_RECHARGE_SERVICE
  (SERVICE_ROW_ID, CATEGORY_CODE, RC_SUB_BOP_ID, ACTIVE_BOO
   , CREATED_BY, CREATED, LAST_UPD_BY, LAST_UPD)
  values
  (@service_row_id, @category_code, @sub_bop_id, 'Y'
  , 'init', getdate(), 'init', getdate())

end

-- Missing Location Code

select @service_name = 'Unit Test Service Without Location'

select @service_id = 160003

select @service_row_id = SERVICE_ROW_ID
from PM_RECHARGE_SERVICE
where SERVICE_ID = @service_id
if (@@rowcount = 0)
begin

  insert into PM_RECHARGE_SERVICE
  (SERVICE_ID, SERVICE_NAME, DOCUMENT_TYPE_ID
   , RECHARGE_BOO, GEN_RECEIPT_BOO, ACTIVE_BOO, EFFECTIVE_DATE
   , CASH_CARD_BOO
   , CREATED_BY, CREATED, LAST_UPD_BY, LAST_UPD)
  values
  (@service_id, @service_name, @document_type_id
   , 'Y', 'Y', 'Y', getdate()
   , 'N'
   , 'unit', getdate(), 'unit', getdate())

  select @service_row_id = @@identity

end
else
begin

  update PM_RECHARGE_SERVICE
  set DOCUMENT_TYPE_ID = @document_type_id
  , RECHARGE_BOO = 'Y'
  , GEN_RECEIPT_BOO = 'Y'
  , ACTIVE_BOO = 'Y'
  where SERVICE_ROW_ID = @service_row_id

end

select @map_id = MAP_ID
from PM_RECHARGE_SERVICE_MAPPING
where SERVICE_ROW_ID = @service_row_id
if (@@rowcount = 0)
begin

  select @transaction_code_id = TRANSACTION_CODE_ID
  from PM_TRANSACTION_CODE
  where TRANSACTION_CODE = 'CA'

  insert into PM_RECHARGE_SERVICE_MAPPING
  (SERVICE_ROW_ID, METHOD_CODE, ACTIVE_BOO, EFFECTIVE_DATE
  , TRANSACTION_CODE_ID
  , CREATED_BY, CREATED, LAST_UPD_BY, LAST_UPD)
  values
  (@service_row_id, 2, 'Y', getdate()
  , @transaction_code_id
  , 'unit', getdate(), 'unit', getdate())

  select @map_id = @@identity

end

select @map_cat_id = MAP_CAT_ID
from PM_CFG_RECHARGE_SERVICE
where SERVICE_ROW_ID = @service_row_id
if (@@rowcount = 0)
begin

  insert into PM_CFG_RECHARGE_SERVICE
  (SERVICE_ROW_ID, CATEGORY_CODE, RC_SUB_BOP_ID, ACTIVE_BOO
   , CREATED_BY, CREATED, LAST_UPD_BY, LAST_UPD)
  values
  (@service_row_id, @category_code, @sub_bop_id, 'Y'
  , 'init', getdate(), 'init', getdate())

end

-- Cash Card

select @service_name = 'Unit Test Service Cash Card'

select @service_id = 160004

select @service_row_id = SERVICE_ROW_ID
from PM_RECHARGE_SERVICE
where SERVICE_ID = @service_id
if (@@rowcount = 0)
begin


  insert into PM_RECHARGE_SERVICE
  (SERVICE_ID, SERVICE_NAME, DOCUMENT_TYPE_ID
   , RECHARGE_BOO, GEN_RECEIPT_BOO, CASH_CARD_BOO, ACTIVE_BOO, EFFECTIVE_DATE
   , CREATED_BY, CREATED, LAST_UPD_BY, LAST_UPD)
  values
  (@service_id, @service_name, @document_type_id
   , 'Y', 'Y', 'Y', 'Y', getdate()
   , 'unit', getdate(), 'unit', getdate())

  select @service_row_id = @@identity

end
else
begin

  update PM_RECHARGE_SERVICE
  set DOCUMENT_TYPE_ID = @document_type_id
  , RECHARGE_BOO = 'Y'
  , GEN_RECEIPT_BOO = 'Y'
  , CASH_CARD_BOO = 'Y'
  , ACTIVE_BOO = 'Y'
  where SERVICE_ROW_ID = @service_row_id

end

select @map_id = MAP_ID
from PM_RECHARGE_SERVICE_MAPPING
where SERVICE_ROW_ID = @service_row_id
if (@@rowcount = 0)
begin

  select @transaction_code_id = TRANSACTION_CODE_ID
  from PM_TRANSACTION_CODE
  where TRANSACTION_CODE = 'CA'

  insert into PM_RECHARGE_SERVICE_MAPPING
  (SERVICE_ROW_ID, METHOD_CODE, LOCATION_CODE, ACTIVE_BOO, EFFECTIVE_DATE
  , TRANSACTION_CODE_ID
  , CREATED_BY, CREATED, LAST_UPD_BY, LAST_UPD)
  values
  (@service_row_id, 2, 1020, 'Y', getdate()
  , @transaction_code_id
  , 'unit', getdate(), 'unit', getdate())

  select @map_id = @@identity

end
else
begin

  update PM_RECHARGE_SERVICE_MAPPING set METHOD_CODE = 2, LOCATION_CODE = 1020
  where SERVICE_ROW_ID = @service_row_id

end

select @map_cat_id = MAP_CAT_ID
from PM_CFG_RECHARGE_SERVICE
where SERVICE_ROW_ID = @service_row_id
if (@@rowcount = 0)
begin

  insert into PM_CFG_RECHARGE_SERVICE
  (SERVICE_ROW_ID, CATEGORY_CODE, RC_SUB_BOP_ID, ACTIVE_BOO
   , CREATED_BY, CREATED, LAST_UPD_BY, LAST_UPD)
  values
  (@service_row_id, @category_code, @sub_bop_id, 'Y'
  , 'init', getdate(), 'init', getdate())

end

go

