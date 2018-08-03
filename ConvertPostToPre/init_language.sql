use PMDB

go

set nocount on

go

create or replace procedure _INSERT_LANGUAGE (
  @code    char(3),
  @name    univarchar(250),
  @active  char(1),
  @lang_id unsigned bigint out
)
as

select @lang_id = LANGUAGE_ID from PM_LANGUAGE where LANGUAGE_CODE = @code
if (@@rowcount = 0)
begin

  insert into PM_LANGUAGE
  (LANGUAGE_CODE, LANGUAGE_NAME, ACTIVE_BOO
  , CREATED_BY, CREATED, LAST_UPD_BY, LAST_UPD)
  values
  (@code, @name, @active
  , 'unit', getdate(), 'unit', getdate())

end

go

declare @language_id unsigned bigint

exec _INSERT_LANGUAGE 'tha', 'Thai small', 'Y', @language_id out
exec _INSERT_LANGUAGE 'lao', 'Lao small', 'Y', @language_id out
exec _INSERT_LANGUAGE 'mya', 'Myanmar small', 'Y', @language_id out
exec _INSERT_LANGUAGE 'eng', 'English small', 'Y', @language_id out

go

drop procedure _INSERT_LANGUAGE

go

