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

delete from PM_CFG_MOBILE_CASH_CARD where MERCHANT = @partner

delete from PM_SCRATCH_TYPE_PARTNER where TYPE_ID = @type_id

delete from PM_SCRATCH_TYPE where TYPE_ID = @type_id

delete from PM_SCRATCH_STOCK where BATCH_NO = @batch_no

go

