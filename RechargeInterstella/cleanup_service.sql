use PMDB

go

set nocount on

declare @service_name   varchar(250)
declare @service_id     unsigned bigint
declare @service_row_id unsigned bigint

select @service_name = 'Unit Test Invalid Recharge Channel'

select @service_id = SERVICE_ID from PM_RECHARGE_SERVICE where SERVICE_NAME = @service_name

delete from PM_RECHARGE_SERVICE where SERVICE_ID = @service_id

--delete from PM_RECHARGE_CHANNEL where RECHARGE_CHANNEL_NAME = @service_name

--delete from PM_RECHARGE_CHANNEL_GROUP where CHANNEL_GROUP_NAME = @service_name

select @service_name = 'Unit Test Recharge Service Not Gen'

select @service_row_id = SERVICE_ID from PM_RECHARGE_SERVICE where SERVICE_NAME = @service_name

delete from PM_RECHARGE_SERVICE_MAPPING where SERVICE_ROW_ID = @service_row_id

delete from PM_RECHARGE_SERVICE where SERVICE_ID = @service_id

--delete from PM_RECHARGE_CHANNEL where RECHARGE_CHANNEL_NAME = @service_name

--delete from PM_RECHARGE_CHANNEL_GROUP where CHANNEL_GROUP_NAME = @service_name

select @service_name = 'Unit Test Service Without Method'

select @service_row_id = SERVICE_ROW_ID from PM_RECHARGE_SERVICE where SERVICE_NAME = @service_name

delete from PM_RECHARGE_SERVICE_MAPPING where SERVICE_ROW_ID = @service_row_id

delete from PM_RECHARGE_SERVICE where SERVICE_ID = @service_id

--delete from PM_RECHARGE_CHANNEL where RECHARGE_CHANNEL_NAME = @service_name

--delete from PM_RECHARGE_CHANNEL_GROUP where CHANNEL_GROUP_NAME = @service_name

select @service_name = 'Unit Test Service Without Location'

select @service_row_id = SERVICE_ROW_ID from PM_RECHARGE_SERVICE where SERVICE_NAME = @service_name

delete from PM_RECHARGE_SERVICE_MAPPING where SERVICE_ROW_ID = @service_row_id

delete from PM_RECHARGE_SERVICE where SERVICE_ID = @service_id

--delete from PM_RECHARGE_CHANNEL where RECHARGE_CHANNEL_NAME = @service_name

--delete from PM_RECHARGE_CHANNEL_GROUP where CHANNEL_GROUP_NAME = @service_name

go

