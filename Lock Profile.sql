select 
gsrat.context_value "Rule Profile"
,gsrat.object_name OBJECT_NAME
,gsmt.rule_type RULE_TYPE
,gsmt.from1 EMP_SSO
,gsmt.to1 LOCK_EMP
,gsmt.to2 LOCK_JOB
,gsmt.to3 LOCK_SUPERVISOR
,gsmt.to4 LOCK_LOCATION
,gsmt.to5 LOCK_EMAIL
,gsmt.to6 LOCK_COA
,gsmt.to7 LOCK_HR_ORG
,gsmt.to8 LOCK_HR_RULE_PROFILE
,gsmt.to9 LOCK_IFG
,gsmt.to10 LOCK_BUSINESS_SEGMENT
,gsmt.to11 RESP_DEASSIGN
 
from 
    apps.gecm_std_mapping_tbl gsmt,
    GECM_STD_RULE_ASSIGN_TBL gsrat
where    
    gsrat.assign_id=gsmt.assign_id
    and sysdate between nvl(gsmt.date_to, sysdate - 1)
                and nvl(gsmt.date_to, sysdate + 1)
    and gsmt.from1 in (
    '100001216'    
    )

