use PMDB

go

set nocount on

declare @trans_date date

select @trans_date = dateadd(dd, -1, '20160616')

delete PM_RECEIPT_ADDR
from CPDB..SFF_ORDER O
inner join CPDB..SFF_ORDER_SERVICE_INSTANCE OI on (O.ROW_ID = OI.ORDER_ID)
inner join CPDB..SFF_ACCOUNT A on (OI.BILLING_ACCNT_ID = A.ROW_ID)
inner join PMDB..PM_EXCESS_BALANCE E on (A.ACCNT_NO = E.BA_NO)
inner join PMDB..PM_RECEIPT_DTL D on (E.RECEIPT_DTL_ID = D.RECEIPT_DTL_ID
and E.EXCESS_DATE = D.RECEIPT_DATE)
inner join PMDB..PM_RECEIPT R on (D.RECEIPT_ID = R.RECEIPT_ID
and D.RECEIPT_DATE = R.RECEIPT_DATE)
inner join PMDB..PM_RECEIPT_ADDR AD on (R.RECEIPT_ID = AD.RECEIPT_ID
and R.RECEIPT_DATE = AD.RECEIPT_DATE)
where O.STATUS_DT = @trans_date

delete PM_RECEIPT
from CPDB..SFF_ORDER O
inner join CPDB..SFF_ORDER_SERVICE_INSTANCE OI on (O.ROW_ID = OI.ORDER_ID)
inner join CPDB..SFF_ACCOUNT A on (OI.BILLING_ACCNT_ID = A.ROW_ID)
inner join PMDB..PM_EXCESS_BALANCE E on (A.ACCNT_NO = E.BA_NO)
inner join PMDB..PM_RECEIPT_DTL D on (E.RECEIPT_DTL_ID = D.RECEIPT_DTL_ID
and E.EXCESS_DATE = D.RECEIPT_DATE)
inner join PMDB..PM_RECEIPT R on (D.RECEIPT_ID = R.RECEIPT_ID
and D.RECEIPT_DATE = R.RECEIPT_DATE)
where O.STATUS_DT = @trans_date

delete PM_RECEIPT_DTL
from CPDB..SFF_ORDER O
inner join CPDB..SFF_ORDER_SERVICE_INSTANCE OI on (O.ROW_ID = OI.ORDER_ID)
inner join CPDB..SFF_ACCOUNT A on (OI.BILLING_ACCNT_ID = A.ROW_ID)
inner join PMDB..PM_EXCESS_BALANCE E on (A.ACCNT_NO = E.BA_NO)
inner join PMDB..PM_RECEIPT_DTL D on (E.RECEIPT_DTL_ID = D.RECEIPT_DTL_ID
and E.EXCESS_DATE = D.RECEIPT_DATE)
where O.STATUS_DT = @trans_date

delete PM_EXCESS_BALANCE
from CPDB..SFF_ORDER O
inner join CPDB..SFF_ORDER_SERVICE_INSTANCE OI on (O.ROW_ID = OI.ORDER_ID)
inner join CPDB..SFF_ACCOUNT A on (OI.BILLING_ACCNT_ID = A.ROW_ID)
inner join PMDB..PM_EXCESS_BALANCE E on (A.ACCNT_NO = E.BA_NO)
where O.STATUS_DT = @trans_date

delete CPDB..SFF_ORDER_SERVICE_INSTANCE
from CPDB..SFF_ORDER O
inner join CPDB..SFF_ORDER_SERVICE_INSTANCE OI on (O.ROW_ID = OI.ORDER_ID)
where O.ORDER_TYPE = 'Convert Postpaid to Prepaid'
and O.STATUS_DT = @trans_date

delete from CPDB..SFF_ORDER
where ORDER_TYPE = 'Convert Postpaid to Prepaid'
and STATUS_DT = @trans_date

delete from PM_EXCESS_BALANCE where BA_NO = '201607272500199'

go


