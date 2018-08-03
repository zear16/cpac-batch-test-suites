use PMDB

go

set nocount on

declare @mobile_no    varchar(20)
declare @type_id      varchar(4)
declare @scratch_type char(1)
declare @sc_type_id   unsigned bigint
declare @sc_stock_id unsigned bigint
declare @batch_no    varchar(10)
declare @start       unsigned bigint
declare @qty         unsigned int
declare @value       decimal(14,2)
declare @partner     univarchar(100)

select @batch_no = '16001'
, @start = 0
, @qty = 100
, @value = 100
, @partner = 'UNIT'
, @type_id = 'UNIT'
, @scratch_type = 'S'

select @sc_stock_id = SC_STOCK_ID
from PM_SCRATCH_STOCK
where BATCH_NO = @batch_no
and START_SERIAL_NO = 0
if (@@rowcount = 0)
begin

  insert into PM_SCRATCH_STOCK
  (BATCH_NO, START_SERIAL_NO, BATCH_QTY, FACE_VALUE, TYPE_ID
   , COMMERCE_BOO
   , CREATED_BY, CREATED, LAST_UPD_BY, LAST_UPD)
  values
  (@batch_no, @start, @qty, @value, @type_id
   , 'Y'
   , 'unit', getdate(), 'unit', getdate())

end
else
begin

  update PM_SCRATCH_STOCK set START_SERIAL_NO = @start
  , BATCH_QTY = @qty
  , FACE_VALUE = @value
  , TYPE_ID = @type_id
  , COMMERCE_BOO = 'Y'
  where SC_STOCK_ID = @sc_stock_id

end

select @sc_type_id = SC_TYPE_ID
from PM_SCRATCH_TYPE
where TYPE_ID = @type_id
if (@@rowcount = 0)
begin

  insert into PM_SCRATCH_TYPE
  (TYPE_ID, TYPE_DESCRIPTION, SCRATCH_TYPE
  , CREATED_BY, CREATED, LAST_UPD_BY, LAST_UPD)
  values
  (@type_id, 'UNIT TEST', @scratch_type
  , 'init', getdate(), 'init', getdate()) 

end

if ((select count(*)
    from PM_SCRATCH_TYPE_PARTNER
    where TYPE_ID = @type_id
    and SCRATCH_TYPE = @scratch_type 
    and BATCH_NO = @batch_no
    and PARTNER_DESCRIPTION = @partner) = 0)
begin

  insert into PM_SCRATCH_TYPE_PARTNER
  (TYPE_ID, TYPE_DESCRIPTION, SCRATCH_TYPE, BATCH_NO, PARTNER_DESCRIPTION, GENTEXT_AMC
  , CREATED_BY, CREATED, LAST_UPD_BY, LAST_UPD)
  values
  (@type_id, 'UNIT', @scratch_type, @batch_no, @partner, 'AMC#016'
  , 'init', getdate(), 'init', getdate())

end

declare @cfg_mobile_cc_id unsigned bigint

/* GEN_BOO = 'Y' */
select @mobile_no = '0854005112'

select @cfg_mobile_cc_id = CFG_MOBILE_CC_ID
from PM_CFG_MOBILE_CASH_CARD
where MOBILE_NO = @mobile_no and MERCHANT = @partner
if (@@rowcount = 0)
begin

  insert PM_CFG_MOBILE_CASH_CARD
  (MOBILE_NO, MERCHANT, GEN_BOO, EFFECTIVE_DATE, ACTIVE_BOO
  , CREATED_BY, CREATED, LAST_UPD_BY, LAST_UPD)
  values
  (@mobile_no, @partner, 'Y', '20160101', 'Y'
  , 'init', getdate(), 'init', getdate())

end
else
begin

  update PM_CFG_MOBILE_CASH_CARD
  set GEN_BOO = 'Y'
  where CFG_MOBILE_CC_ID = @cfg_mobile_cc_id

end

/* GEN_BOO = 'N' */
select @mobile_no = '0901002598'

select @cfg_mobile_cc_id = CFG_MOBILE_CC_ID
from PM_CFG_MOBILE_CASH_CARD
where MOBILE_NO = @mobile_no and MERCHANT = @partner
if (@@rowcount = 0)
begin

  insert PM_CFG_MOBILE_CASH_CARD
  (MOBILE_NO, MERCHANT, GEN_BOO, EFFECTIVE_DATE, ACTIVE_BOO
  , CREATED_BY, CREATED, LAST_UPD_BY, LAST_UPD)
  values
  (@mobile_no, @partner, 'N', '20160101', 'Y'
  , 'init', getdate(), 'init', getdate())

end
else
begin

  update PM_CFG_MOBILE_CASH_CARD
  set GEN_BOO = 'N'
  where CFG_MOBILE_CC_ID = @cfg_mobile_cc_id

end

go

