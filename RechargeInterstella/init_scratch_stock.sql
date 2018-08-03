use PMDB

go

set nocount on

declare @sc_stock_id unsigned bigint
declare @batch_no    varchar(10)
declare @start       unsigned bigint
declare @qty         unsigned int
declare @value       decimal(14,2)

select @batch_no = '16000'
, @start = 0
, @qty = 100
, @value = 100

select @sc_stock_id = SC_STOCK_ID
from PM_SCRATCH_STOCK
where BATCH_NO = @batch_no
and START_SERIAL_NO = 0
if (@@rowcount = 0)
begin

  insert into PM_SCRATCH_STOCK
  (BATCH_NO, START_SERIAL_NO, BATCH_QTY, FACE_VALUE
   , CREATED_BY, CREATED, LAST_UPD_BY, LAST_UPD)
  values
  (@batch_no, @start, @qty, @value
   , 'unit', getdate(), 'unit', getdate()) 

end
else
begin

  update PM_SCRATCH_STOCK set START_SERIAL_NO = @start
  , BATCH_QTY = @qty
  , FACE_VALUE = @value
  where SC_STOCK_ID = @sc_stock_id

end

go


