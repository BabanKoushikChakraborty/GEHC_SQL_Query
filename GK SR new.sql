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
to_date(assu.creation_date, 'DD-MON-YY') "Creation_Date",
to_date(assu.inactive_date, 'DD-MON-YY') "Site_Inactive_Date",
to_date (asu.end_date_active, 'DD-MON-YY') "Supplier_End_Date",




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
 
assu.org_id in (

'9124',
'9120',
'9128',
'9131',
'9121',
'9092',
'9133',
'9160',
'9158',
'9109',
'9270',
'9097',
'9060',
'9161',
'9099',
'9117',
'9153',
'9162',
'9179',
'9182',
'9184',
'9187',
'9106',
'9142',
'9140',
'9115',
'9119',
'9088',
'9915',
'9993',
'9154',
'9185',
'9093',
'10029',
'9910',
'9667',
'9990',
'9183',
'9176',
'9178',
'9150',
'9127',
'9230',
'9180',
'9130',
'9066',
'9147',
'9145',
'9139',
'9057',
'10045',
'9141',
'9174',
'10028',
'9156',
'9114',
'10059',
'9163',
'9164',
'9181',
'9169',
'10039',
'9177',
'9173',
'9148',
'10018',
'9170',
'9105',
'9059',
'9168',
'10007',
'9062',
'9909',
'9939',
'9065',
'9064',
'9149',
'9998',
'9152',
'9999',
'10035',
'9055',
'9056',
'9269',
'9265',
'9666',
'9138',
'9061',
'9151',
'9143',
'9146',
'9112',
'9111',
'9175',
'9186',
'9267',
'9126',
'9989',
'10053',
'10055',
'9188',
'9058',
'9095',
'9082',
'10051',
'9157',
'9113',
'9137',
'9083',
'10052',
'9155',
'9129',
'10054',
'9796',
'9063',
'9798',
'9134',
'9879',
'9797',
'9159',
'9268',
'10060',
'10080',
'10030',
'10100'



)

--AND ppl.employee_number IS NOT NULL
;

