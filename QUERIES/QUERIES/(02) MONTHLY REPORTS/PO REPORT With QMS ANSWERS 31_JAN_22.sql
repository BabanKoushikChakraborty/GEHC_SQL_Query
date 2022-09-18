select   
prha.org_id "Org Id"

,prha.INTERFACE_SOURCE_CODE
,hro.name "Org name"

,prha.segment1 "Requisition Number" 
,to_date(prha.creation_date, 'DD-MON-YY') "Requisition creation Date" 
,prha.authorization_status "PR Status"

,to_number(ph.segment1) "PO Number" 

,to_date(ph.creation_date, 'DD-MON-YY')  "PO Creation Date" 
,mcv.category_concat_segs "UNSPSC Code"
,mcv.description "Commodity Description"


,(select distinct ipp.approval_code 
  from apps.gecm_compliance_tbl ipp
   where  ipp.transaction_id=PRHA.requisition_header_id
  and ipp.transaction_type='REQUISITION'
  and compliance_name='IPP'
  and rownum<2) "PR Approval Code"
  
  ,(select * from (select ipp.approval_code 
  from apps.gecm_compliance_tbl ipp
   where  ipp.transaction_id=PRHA.requisition_header_id
  and ipp.transaction_type='REQUISITION'
  and compliance_name='QMS'
  order by ipp.compliance_id desc)
  where rownum < 2) "PPW Code"


,(select * from (select ipp.answers 
  from apps.gecm_compliance_tbl ipp
   where  ipp.transaction_id=PRHA.requisition_header_id
  and ipp.transaction_type='REQUISITION'
  and compliance_name='QMS'
  order by ipp.compliance_id desc)
  where rownum < 2) "QMS Answers"
  ,(select * from (select ipp.business_name
  from apps.gecm_compliance_tbl ipp
   where  ipp.transaction_id=PRHA.requisition_header_id
  and ipp.transaction_type='REQUISITION'
  and compliance_name='QMS'
  order by ipp.compliance_id desc)
  where rownum < 2) "Business Name"
  
  ,ppa.segment1  Project_No
  , prda.ATTRIBUTE11 "Asset Number"
,pl.item_description "Item Description" 


,papf.full_name  Requestor_name
,papf.employee_number "Requestor SSO"


,papf1.full_name "Preparer Name"

,papf1.employee_number "Preparer SSO"

 , ph.closed_code "PO Status"

,ph.type_lookup_code "Type"

--,ph.ATTRIBUTE7 "PO_Payment Method"  

,ph.authorization_status "PO authorization Status"


,to_date(pll.need_by_date, 'DD-MON-YY') "NEED_BY_DATE" 


,gcc.concatenated_segments charge_account 
,pl.line_num "PO Line Number"
 
,nvl(pl.unit_price,pll.price_override) "Unit Price" 
,(select location_code from hr_locations_all where location_id = pvs.ship_to_location_id) Delivery_to_location
,ph.currency_code 
,decode(pvs.pay_on_code,
        'RECEIPT','ERS',
        pvs.pay_on_code)PAY_ON_CODE


,round((pd.quantity_ordered-pd.quantity_cancelled)*pll.Price_Override,2)  "Distribution_Line_Amount" 

,ROUND((case 
when ph.currency_code = 'USD' then 
(pd.quantity_ordered-pd.quantity_cancelled)*pll.Price_Override
else 
(select ((pd.quantity_ordered-pd.quantity_cancelled)*pll.Price_Override)*gdr.conversion_RATE 
from apps.gl_daily_rates gdr 
where to_char(trunc(gdr.CONVERSION_DATE), 'DD-MON-YYYY') = 
to_char(TRUNC(NVL(PH.rate_date, PH.creation_date)),'DD-MON-YYYY')  
and upper(conversion_type) = upper('Corporate') 
and FROM_CURRENCY = ph.currency_code 
and TO_CURRENCY = 'USD') 
end),2) 
 "USD Distribution Amount" 

--,pll.AMOUNT_RECEIVED " Received Amount"


,round(pd.quantity_ordered-pd.quantity_cancelled,2)  "Quantity Ordered" 

--,nvl(pd.quantity_delivered,0) "Quantity Received"

,nvl(pd.quantity_billed,0) "Quantity Billed"

,nvl(pd.quantity_cancelled,0) "Quantity Cancelled"

,nvl(pd.quantity_delivered,0) "Quantity Received"
 
,ROUND((case when ph.currency_code = 'USD' then (select sum((nvl(pda.quantity_ordered,0)-nvl(pda.quantity_cancelled,0))*nvl(pll.Price_Override,0))
from apps.po_line_locations_all pll,APPS.PO_DISTRIBUTIONS_ALL pda 
 where pda.po_line_id=pll.po_line_id and pda.po_header_id = ph.po_header_id)
else (select sum((nvl(pda.quantity_ordered,0)-nvl(pda.quantity_cancelled,0))*(nvl(pll.Price_Override,0)*NVL(gdr.conversion_RATE,0))) 
 from apps.gl_daily_rates gdr ,apps.po_line_locations_all pll,APPS.PO_DISTRIBUTIONS_ALL pda 
 where pda.po_line_id=pll.po_line_id 
 and pda.po_header_id = ph.po_header_id 
 and to_char(trunc(gdr.CONVERSION_DATE),'DD-MON-YYYY')= to_char(TRUNC(NVL(PH.rate_date, PH.creation_date)),'DD-MON-YYYY') 
 and upper(conversion_type) = upper('Corporate') and FROM_CURRENCY = ph.currency_code and TO_CURRENCY = 'USD')end),2)
 "Usd TOTAL_AMOUNT" 



,ROUND((case 
when ph.currency_code = 'USD' then 
(select sum(pda.quantity_delivered*pll.Price_Override) from apps.po_line_locations_all 
pll,APPS.PO_DISTRIBUTIONS_ALL pda
where pda.po_line_id=pll.po_line_id and pda.po_header_id = ph.po_header_id)

else 
(select sum(pda.quantity_delivered*pll.Price_Override*gdr.conversion_RATE) 
from apps.gl_daily_rates gdr ,apps.po_line_locations_all pll,APPS.PO_DISTRIBUTIONS_ALL pda
where pda.po_line_id=pll.po_line_id and pda.po_header_id = ph.po_header_id and
to_char(trunc(gdr.CONVERSION_DATE), 'DD-MON-YYYY') = 
to_char(TRUNC(NVL(PH.rate_date, PH.creation_date)),'DD-MON-YYYY') 
and upper(conversion_type) = upper('Corporate') 
and FROM_CURRENCY = ph.currency_code 
and TO_CURRENCY = 'USD' )end),2) "USD_TOTAL_AMT_RECEIVED" 


  
--   ,(select sum(pda.quantity_delivered*pll.Price_Override) from apps.po_line_locations_all 
--pll.APPS.PO_DISTRIBUTIONS_ALL pda
 -- where pda.po_line_id=pll.po_line_id and pda.po_header_id = ph.po_header_id)  
--"TOTAL_RECEIVED_AMT"

--,(nvl(pl.quantity,0)*pl.unit_price)"Total Amount"

,to_date(ph.approved_date, 'DD-MON-YY') "PO Approved Date" 
,to_date(PLL.last_update_date, 'DD-MON-YY') "PO_Last_Update_Date" 

 
 
,pv.vendor_name "Supplier Name" 
,pv.segment1 "Supplier Number" 
--,pv.segment1||pvs.attribute14 "GSL" 
,PVS.VENDOR_SITE_CODE "Supplier Site" 
,CASE WHEN pvs.inactive_date IS NULL 
       THEN 'ACTIVE'
       ELSE 'IN-ACTIVE'
END AS SUPPLIER_SITE_STATUS

,(pvs.ADDRESS_LINE1||''||pvs.ADDRESS_LINE2||''||
pvs.ADDRESS_LINE3||''|| pvs.STATE||''||pvs.ZIP) "Address"

,pvs.CITY "City"

,pvs.COUNTRY "Country"

--,(select name from apps.ap_terms where term_id = pvs.TERMS_ID) "Payment_terms"
,(select name from apps.ap_terms where term_id = ph.TERMS_ID) "PO Payment_terms"

,pll.closed_code "Shipment_Status"
,prla.suggested_vendor_product_code "Supplier Item Number"
--,prha.Attribute5
,to_date(regexp_substr(prha.attribute5,'[^,]+',1,1),'MM-DD-YY') as START_DATE
,to_date(regexp_substr(prha.attribute5,'[^,]+',1,2),'MM-DD-YY') as END_DATE
,ggr.ar_number "AR Number"
,PRLA.attribute12 "SUB-AR Number"
from  
apps.po_requisition_headers_all prha, 
PA_PROJECTS_all ppa,
apps.po_requisition_lines_all prla, 
apps.po_req_distributions_all prda, 
apps.gl_code_combinations_kfv gcc, 
apps.po_headers_all ph, 
apps.po_lines_all pl, 
apps.po_line_locations_all pll, 
apps.po_distributions_all pd, 
apps.po_vendors pv, 
apps.po_vendor_sites_all pvs, 
apps.per_all_people_f papf1,
apps.per_all_people_f papf,
 apps.hr_operating_units  hro,

apps.mtl_categories_v mcv 
,apps.gecm_gears_data ggr
 
where prha.requisition_header_id = prla.requisition_header_id 
and prla.requisition_line_id=prda.requisition_line_id 
and ph.po_header_id = pl.po_header_id 
and pl.po_line_id=pll.po_line_id 
and pll.line_location_id=pd.line_location_id 
and pd.code_combination_id=gcc.code_combination_id 
and pd.req_distribution_id=prda.distribution_id 
and pl.category_id=mcv.category_id 
and pv.vendor_id=pvs.vendor_id 
and ph.vendor_id=pv.vendor_id 
and ph.vendor_site_id=pvs.vendor_site_id 
and ph.org_id=pvs.org_id 
and prha.org_id=ph.org_id
and HRO.ORGANIZATION_ID = PH.ORG_ID
and PAPF1.PERSON_ID = prha.PREPARER_ID
AND ppa.project_id(+) = pd.project_id
and papf.person_id = pd.deliver_to_person_id
  
AND SYSDATE BETWEEN NVL(PAPF1.EFFECTIVE_START_DATE, SYSDATE - 1) AND
   NVL(PAPF1.EFFECTIVE_END_DATE, SYSDATE + 1)
AND SYSDATE BETWEEN NVL(PAPF.EFFECTIVE_START_DATE, SYSDATE - 1) AND
   NVL(PAPF.EFFECTIVE_END_DATE, SYSDATE + 1)
AND ggr.sub_ar_number(+) = PRLA.attribute12
and ggr.INACTIVE_DATE is null
AND PH.ORG_ID in ('9059',
'9142',
'9139',
'9109',
'9270',
'9057',
'9058',
'9140',
'9097',
'9115',
'9119',
'9088',
'9915',
'9124',
'9120',
'9128',
'9131',
'9121',
'9092',
'10045',
'9133',
'9993',
'9060',
'9161',
'9099',
'9269',
'9168',
'9117',
'9265',
'9095',
'9082',
'10051',
'9157',
'9666',
'9113',
'9137',
'9083',
'10052',
'9138',
'9155',
'9160',
'9153',
'9141',
'9174',
'10028',
'9156',
'10007',
'9061',
'9151',
'9162',
'9129',
'10054',
'9796',
'9114',
'10059',
'9062',
'9909',
'9163',
'9164',
'9181',
'9169',
'9154',
'9185',
'9093',
'10039',
'9143',
'9146',
'9177',
'9939',
'9112',
'9111',
'9175',
'10029',
'9173',
'9179',
'9063',
'9798',
'9910',
'9182',
'9184',
'9065',
'9064',
'9187',
'9148',
'9106',
'9149',
'9134',
'9879',
'9797',
'10018',
'9186',
'10060',
'9267',
'9159',
'9268',
'9158',
'9170',
'9998',
'9152',
'9999',
'10035',
'9055',
'9056',
'9126',
'9989',
'10053',
'10055',
'9188',
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
'9105',
'10080',
'10030',
'10100')


--and ph.closed_code = 'OPEN'
 
AND TRUNC(PH.CREATION_DATE) BETWEEN  '01-JAN-2022' AND '31-DEC-2022' 


  
   ORDER BY PH.SEGMENT1,
    pl.line_num  ;