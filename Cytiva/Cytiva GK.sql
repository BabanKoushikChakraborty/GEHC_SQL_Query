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






..................................................................

   

/*SOURCING REVIEWER*/


select DISTINCT               
assu.org_id , 
(select organization_name from apps.org_organization_definitions org where org.organization_id = assu.org_id ) "Org name",
ppl.employee_number as GATEKEEPER_SSO,
ppl.full_name as GATEKEEPER_NAME,
assu.attribute2 as THRESHOLD,
asu.segment1 || SUBSTR(assu.vendor_site_code,-3) GSL_NUMBER ,

assu.LAST_UPDATE_DATE,
(select user_name from apps.fnd_user where user_id = assu.LAST_UPDATED_BY)UPDATED_BY_SSO,

assu.vendor_id,

asu.vendor_name,
asu.vendor_name_alt,
assu.vendor_site_code as SUPPLIER_SITE_CODE,
assu.inactive_date,


assu.attribute11 as site_laguage,

(select location_code from hr_locations_all where location_id = assu.ship_to_location_id) ship_to_location,

  iep.remit_advice_delivery_method,
assu.language             
from apps.ap_supplier_sites_all assu
inner join apps.ap_suppliers asu on asu.vendor_id = assu.vendor_id
inner join apps.iby_external_payees_all iep on iep.payee_party_id = asu.party_id and iep.supplier_site_id = assu.vendor_site_id and iep.org_id = assu.org_id
left join apps.PER_PEOPLE_F ppl on ppl.person_id=assu.attribute1
left join apps.po_vendor_contacts pvc on pvc.VENDOR_SITE_ID = assu.vendor_site_id
--inner join apps.org_organization_definitions org on 
where 
--asu.vendor_name = 'GREAT LAKES PACKAGING CORP'
--AND ppl.employee_number in ('212563569')
 
assu.org_id in (9090,
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
;

............................................................