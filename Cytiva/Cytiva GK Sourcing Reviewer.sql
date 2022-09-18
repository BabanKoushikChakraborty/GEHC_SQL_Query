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

