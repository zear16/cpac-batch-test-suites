use PMDB

go

set nocount on

declare @trans_date date

select @trans_date = dateadd(dd, -1, '20160616')

delete CPDB..SFF_ORDER_SERVICE_INSTANCE
from CPDB..SFF_ORDER O
inner join CPDB..SFF_ORDER_SERVICE_INSTANCE OI on (O.ROW_ID = OI.ORDER_ID)
where O.ORDER_TYPE = 'Convert Postpaid to Prepaid'
and O.STATUS_DT = @trans_date

delete from CPDB..SFF_ORDER
where ORDER_TYPE = 'Convert Postpaid to Prepaid'
and STATUS_DT = @trans_date

go


