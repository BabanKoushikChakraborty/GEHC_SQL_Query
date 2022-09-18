/* FOR ALL GATEKEEPERS EXCLUDING SOURCING REVIEWER*/

SELECT  PCGA.ORG_ID"ORG_ID", BKD.CURRENCY_CODE "LOCAL_CURRENCY", PCGA.CONTROL_GROUP_NAME "APPROVAL GROUP NAME", PCGA.DESCRIPTION, PCGA.ENABLED_FLAG,
PCR.OBJECT_CODE "OBJECT", PCR.RULE_TYPE_CODE "TYPE", PCR. AMOUNT_LIMIT "AMOUNT LIMIT",
PCR.SEGMENT1_LOW ||'.'||PCR.SEGMENT2_LOW||'.'||PCR.SEGMENT3_LOW||'.'||PCR.SEGMENT4_LOW||'.'
||PCR.SEGMENT5_LOW||'.'||PCR.SEGMENT6_LOW||'.'||PCR.SEGMENT7_LOW||'.'||PCR.SEGMENT8_LOW
||'.'||PCR.SEGMENT9_LOW||'.'||PCR.SEGMENT10_LOW||'.'||PCR.SEGMENT11_LOW as ACCOUNT_LOW,

PCR.SEGMENT1_HIGH ||'.'||PCR.SEGMENT2_HIGH||'.'||PCR.SEGMENT3_HIGH||'.'||PCR.SEGMENT4_HIGH||'.'
||PCR.SEGMENT5_HIGH||'.'||PCR.SEGMENT6_HIGH||'.'||PCR.SEGMENT7_HIGH||'.'||PCR.SEGMENT8_HIGH
||'.'||PCR.SEGMENT9_HIGH||'.'||PCR.SEGMENT10_HIGH||'.'||PCR.SEGMENT11_HIGH as ACCOUNT_HIGH,


PAPF.EMPLOYEE_NUMBER,
PAPF.FULL_NAME "CATEGORY APPROVER NAME",
PCR.ATTRIBUTE2 "BEFORE/AFTER", 
PCR.ATTRIBUTE3 "APPROVER TYPE",
PCR.ATTRIBUTE4 "SEQUENCE"
--PCR.LAST_UPDATE_DATE,
--(select user_name from apps.fnd_user where user_id = PCR.LAST_UPDATED_BY)UPDATED_BY_SSO

FROM APPS.PO_CONTROL_GROUPS_ALL PCGA, 
APPS.PO_CONTROL_RULES PCR, 
APPS.PER_ALL_PEOPLE_F PAPF,
apps.org_organization_definitions ORG,
apps.gl_sets_of_books BKD

WHERE
ORG.operating_unit = PCGA.ORG_ID 
AND ORG.set_of_books_id = BKD.set_of_books_id
--AND PCR.SEGMENT2_LOW = '5210101405'
--
and (PCGA.CONTROL_GROUP_NAME like '%FIN_APPROVER%' or PCGA.CONTROL_GROUP_NAME like '%FINANCE_APPROVER%')
AND PCGA.ORG_ID in (9090,
9094,
9096,
9098,
9100,
9101,
9103,
9104,
9107,
9116,
9118,
9122,
9123,
9125,
9132,
9165,
9166,
9167,
9171,
9172,
9944,
9971,
9889,
10000,
10009,
10014,
10040,
10041,
10042,
10043,
10044,
10047,
10048,
10049,
10050)
--AND PAPF.EMPLOYEE_NUMBER = ''

AND PCGA.CONTROL_GROUP_ID = PCR.CONTROL_GROUP_ID

AND PAPF.CURRENT_EMPLOYEE_FLAG = 'Y'
AND PCR.ATTRIBUTE1 = PAPF.PERSON_ID

ORDER BY PCGA.CONTROL_GROUP_NAME DESC ;

