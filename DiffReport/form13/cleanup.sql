use PMDB

go

declare @data_date date
declare @bank_code unsigned bigint

select @data_date = O.DATA_DATE_FR
from PM_JOB_ORDER O
where O.TEMPLATE_CODE = 'PE_WRONG_NUMBER_RECONCILE'
and O.RUN_DATE = convert(date, getdate())

select @bank_code = 804

-- clean up

-- delete receipt
delete PM_RECEIPT_DTL_PREPAID
from PM_RECEIPT_DTL_PREPAID RDP
inner join PM_RECEIPT_DTL RD on (RDP.RECEIPT_DTL_ID = RD.RECEIPT_DTL_ID)
inner join PM_RECEIPT R on (RD.RECEIPT_ID = R.RECEIPT_ID and RD.RECEIPT_DATE = R.RECEIPT_DATE)
where R.MOBILE_NO in ('0811059704', '0817083406', '0901057702', '0901038440', '0810022038', '0811023605', '0818055111', '0812014318', '0819090911', '0810037545', '0800023526', '0901067996', '0802081089')
and R.BANK_CODE = @bank_code
and R.RECEIPT_DATE = @data_date
and R.CREATED_BY = 'SUYADA'


delete PM_RECEIPT_DTL 
from PM_RECEIPT_DTL RD
inner join PM_RECEIPT R on (RD.RECEIPT_ID = R.RECEIPT_ID and RD.RECEIPT_DATE = R.RECEIPT_DATE)
where R.MOBILE_NO in ('0811059704', '0817083406', '0901057702', '0901038440', '0810022038', '0811023605', '0818055111', '0812014318', '0819090911', '0810037545', '0800023526', '0901067996', '0802081089')
and R.BANK_CODE = @bank_code
and R.RECEIPT_DATE = @data_date
and R.CREATED_BY = 'SUYADA'

print 'delete PM_RECEIPT_DTL %1! records', @@rowcount

delete PM_RECEIPT
from PM_RECEIPT R
where R.MOBILE_NO in ('0811059704', '0817083406', '0901057702', '0901038440', '0810022038', '0811023605', '0818055111', '0812014318', '0819090911', '0810037545', '0800023526', '0901067996', '0802081089')
and R.BANK_CODE = @bank_code
and R.RECEIPT_DATE = @data_date
and R.CREATED_BY = 'SUYADA'

print 'delete PM_RECEIPT %1! records', @@rowcount

---------------------
-- delete credit note
delete PM_CREDIT_NOTE_MAP
from PM_CREDIT_NOTE_MAP M
inner join PM_CREDIT_NOTE CN on (M.CN_ID = CN.CN_ID and M.CN_DATE = CN.CN_DATE)
where CN.MOBILE_NO in ('0819043982', '0901071169', '0901046801', '0810044940', '0910000321', '0812017135', '0810012111', '0817073209', '0802093509', '0854060142', '0810054477', '0811012334', '0818084421')
and CN.BANK_CODE = @bank_code
and CN.CN_DATE = @data_date
and CN.CREATED_BY = 'SUYADA'

print 'delete PM_CREDIT_NOTE_MAP %1! records', @@rowcount

delete PM_CREDIT_NOTE_DTL
from PM_CREDIT_NOTE_DTL CD
inner join PM_CREDIT_NOTE CN on (CD.CN_ID = CN.CN_ID and CD.CN_DATE = CN.CN_DATE)
where CN.MOBILE_NO in ('0819043982', '0901071169', '0901046801', '0810044940', '0910000321', '0812017135', '0810012111', '0817073209', '0802093509', '0854060142', '0810054477', '0811012334', '0818084421')
and CN.BANK_CODE = @bank_code
and CN.CN_DATE = @data_date
and CN.CREATED_BY = 'SUYADA'

print 'delete PM_CREDIT_NOTE_DTL %1! records', @@rowcount

delete PM_CREDIT_NOTE
from PM_CREDIT_NOTE CN
where CN.MOBILE_NO in ('0819043982', '0901071169', '0901046801', '0810044940', '0910000321', '0812017135', '0810012111', '0817073209', '0802093509', '0854060142', '0810054477', '0811012334', '0818084421')
and CN.BANK_CODE = @bank_code
and CN.CN_DATE = @data_date
and CN.CREATED_BY = 'SUYADA'

print 'delete PM_CREDIT_NOTE %1! records', @@rowcount

---------------------

delete PM_ADJUST_TRANSACTION
from PM_ADJUST_TRANSACTION AD
where (AD.MOBILE_NO in ('0811059704', '0817083406', '0901057702', '0901038440', '0810022038', '0811023605', '0818055111', '0812014318', '0819090911', '0810037545', '0800023526', '0901067996', '0802081089')
or AD.REF_MOBILE_NO in ('0811059704', '0817083406', '0901057702', '0901038440', '0810022038', '0811023605', '0818055111', '0812014318', '0819090911', '0810037545', '0800023526', '0901067996', '0802081089'))
and AD.ADJUST_DATE = @data_date

print 'delete PM_ADJUST_TRANSACTION %1! records', @@rowcount


go
