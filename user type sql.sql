select
    pp.FIRST_NAME "FIRST_NAME", pp.LAST_NAME "LAST_NAME", pp.MIDDLE_NAMES "MIDDLE_NAME",
    pp.employee_number "Employee SSO",
    pp.EFFECTIVE_START_DATE "Employee Start Date",
    fu.email_address "Employee Email Address",
    URSP.RESPONSIBILITY_NAME "Responsibility Name",
    fu.start_date "Start Date",
    fu.end_date "End Date",
    pp.d_person_type_id "Employee Type",
    ( select * from (select * from APPS.fnd_profile_option_values fpov where fpov.level_value=fu.user_id order by fpov.last_update_date desc)  where rownum <2) "User Type",
    to_char(pp.EFFECTIVE_END_DATE,'DD-Mon-YYYY') "Employee End Date"
from 
    apps.PER_PEOPLE_V7 pp,
    apps.fnd_user fu,
    APPS.GECM_USER_RESP_ORG_MV URSP
where 
    pp.employee_number(+) = fu.user_name
    and URSP.EMPLOYEE_NUMBER(+)=fu.user_name
    and fu.user_name in (
    '502768876'
    ) 
--    order by fu.user_name, URSP.RESPONSIBILITY_NAME;





select * from apps.fnd_user fu where fu.USER_NAME='502650506'

select * from (select fpov.profile_option_value from APPS.fnd_profile_option_values fpov where fpov.level_value=fu.user_id order by fpov.last_update_date desc)  where rownum <2






