use PMDB

go

set nocount on

delete PM_CREDIT_NOTE
from PM_CREDIT_NOTE CN
inner join PM_PAYMENT_CATEGORY CT on (CN.CATEGORY_CODE = CT.CATEGORY_CODE)
inner join PM_BUSINESS_OF_PAYMENT BOP on (CN.BOP_ID = BOP.BOP_ID)
where CN.CN_DATE = getdate()
and CT.CATEGORY_ABBR = 'PP'
and BOP.BOP_CODE = 'I'

go


