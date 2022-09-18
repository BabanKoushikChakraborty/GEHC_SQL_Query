select distinct  
prha.org_id "Org Id"

--,prha.INTERFACE_SOURCE_CODE
,hro.name "Org name"

,prha.segment1 "Requisition Number" 
,to_date(prha.creation_date, 'DD-MON-YY') "Requisition creation Date" 
,prha.authorization_status "PR Status"

,ph.segment1 "PO Number" 

,to_date(ph.creation_date, 'DD-MON-YY') "PO Creation Date" 
,mcv.category_concat_segs "UNSPSC Code"


,(select distinct ipp.approval_code 
  from apps.gecm_compliance_tbl ipp
   where  ipp.transaction_id=prha.requisition_header_id
  and ipp.transaction_type='REQUISITION'
  AND ROWNUM<2) "Approval Code"
  
  ,ppa.segment1  Project_No
,pl.item_description "Item Description" 


,papf.full_name  Requestor_name
,papf.employee_number "Requestor SSO"


,papf1.full_name "Preparer Name"

,papf1.employee_number "Preparer SSO"




,papf2.full_name  "Change_by"
,papf2.employee_number "Change_by_SSO"
,to_date(pcr.last_update_DATE, 'DD-MON-YY') "Change_date"        
,PCR.DOCUMENT_LINE_NUMBER "Change on Po line" 
--,pcr.line_level
,pcr.old_quantity
,pcr.new_quantity
,pcr.old_price
,pcr.new_price
,to_date(pcr.old_need_by_date, 'DD-MON-YY') "Old Need by Date"
,to_date(pcr.new_need_by_date, 'DD-MON-YY') "New Need by Date"

 , ph.closed_code "PO Status"

,ph.type_lookup_code "Type"

--,ph.ATTRIBUTE7 "PO_Payment Method"  

,ph.authorization_status "PO authorization Status"


,to_date(pll.need_by_date, 'DD-MON-YY') "Need by Date"


,gcc.concatenated_segments charge_account 
,pl.line_num "PO Line Number"
 
,nvl(pl.unit_price,pll.price_override) "Unit Price" 
,ph.currency_code 


,round((pd.quantity_ordered-pd.quantity_cancelled)*pll.Price_Override,2) "PO_Dist_Line_amt"

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
end),2) "USD Dist_Line_Amt" 

--,pll.AMOUNT_RECEIVED " Received Amount"


,nvl(pd.quantity_ordered,0) "Quantity Ordered" 

--,nvl(pd.quantity_delivered,0) "Quantity Received"

,nvl(pd.quantity_billed,0) "Quantity Billed"

,nvl(pd.quantity_cancelled,0) "Quantity Cancelled"

,nvl(pd.quantity_delivered,0) "Quantity Received"
 
,(select sum((nvl(pda.quantity_ordered,0)-nvl(pda.quantity_cancelled,0))*nvl(pll.Price_Override,0)) from 

apps.po_line_locations_all pll,APPS.PO_DISTRIBUTIONS_ALL pda   where pda.po_line_id=pll.po_line_id and pda.po_header_id = 

ph.po_header_id)  "PO_Tot_AMT"
  
 ,ROUND((case when ph.currency_code = 'USD' then
 (select sum((nvl(pda.quantity_ordered,0)-nvl(pda.quantity_cancelled,0))*nvl(pll.Price_Override,0))
 from apps.po_line_locations_all pll,APPS.PO_DISTRIBUTIONS_ALL pda 
 where pda.po_line_id=pll.po_line_id and pda.po_header_id = ph.po_header_id)
 else (select sum((nvl(pda.quantity_ordered,0)-nvl(pda.quantity_cancelled,0))*(nvl(pll.Price_Override,0)*NVL(gdr.conversion_RATE,0))) 
 from apps.gl_daily_rates gdr ,apps.po_line_locations_all pll,APPS.PO_DISTRIBUTIONS_ALL pda 
 where pda.po_line_id=pll.po_line_id 
 and pda.po_header_id = ph.po_header_id 
 and to_char(trunc(gdr.CONVERSION_DATE),'DD-MON-YYYY')= to_char(TRUNC(NVL(PH.rate_date, PH.creation_date)),'DD-MON-YYYY') 
 and upper(conversion_type) = upper('Corporate') and FROM_CURRENCY = ph.currency_code and TO_CURRENCY = 'USD')end),2) 

"Usd_PO_Tot_Amt" 



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
to_char(ph.creation_date,'DD-MON-RRRR') 
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

 ,decode(pvs.pay_on_code,
        'RECEIPT','ERS',
        pvs.pay_on_code)PAY_ON_CODE



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
apps.per_all_people_f papf2,
 apps.hr_operating_units  hro,
 apps.po_change_requests pcr,

apps.mtl_categories_v mcv 
 
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
and pcr.document_num = ph.segment1  
and PAPF2.PERSON_ID = pcr.requester_id

AND SYSDATE BETWEEN NVL(PAPF1.EFFECTIVE_START_DATE, SYSDATE - 1) AND
   NVL(PAPF1.EFFECTIVE_END_DATE, SYSDATE + 1)
   AND SYSDATE BETWEEN NVL(PAPF2.EFFECTIVE_START_DATE, SYSDATE - 1) AND
   NVL(PAPF2.EFFECTIVE_END_DATE, SYSDATE + 1)

and pcr.Document_type = 'PO'
--AND pcr.document_num = '11020248249'
and pcr.Action_type != 'CANCELLATION'
--AND TRUNC(pcr.last_update_DATE) BETWEEN  '08-oct-2018' AND '31-DEC-2018' 


AND PH.ORG_ID in  (
9166	,
9667	,
9116	,
9090	,
9171	,
9666	,
9165	,
9118	,
9103	,
9098	,
9096	,
9094	,
9101	,
9167	,
9123	,
9172	,
9107	,
9108	,
9125	,
9132	,
9067	,
9104	,
9100	,
9102	,
9231	,
9122	,
9889	,
9944	,
9971	,
9183	,
9180	,
9178	,
9150	,
9176	,
9130	,
9066	,
9127	,
9230	,
9115	,
9142	,
9140	,
9154	,
9185	,
9093	,
9088	,
9089	,
9095	,
9082	,
9113	,
9137	,
9083	,
9110	,
9109	,
9159	,
9179	,
9184	,
9106	,
9182	,
9187	,
9161	,
9126	,
9058	,
9143	,
9186	,
9099	,
9117	,
9061	,
9112	,
9111	,
10041	,
9060	,
9129	,
9134	,
9063	,
9155	,
9152	,
9149	,
9162	,
9168	,
9062	,
9055	,
9056	,
9065	,
9064	,
9059	,
9097	,
9114	,
9114	,
9148	,
9139	,
9177	,
9124	,
9120	,
9128	,
9131	,
9121	,
9092	,
9160	,
9158	,
9105	,
9141	,
9174	,
9057	,
9156	,
9173	,
9170	,
9163	,
9164	,
9169	,
9803	,
9909	,
9910	,
9939	,
9153	,
9145	,
9147	,
9144	,
9119	,
9157	,
9138	,
9146	,
9151	,
9175	,
9188	,
9133	,
9181	,
9267	,
9266	,
9268	,
9270	,
9269	,
9265	,
9796	,
9797	,
9798	,
9879	,
9915	,
9993	,
10000	,
9998	,
9999	,
9989	,
9990	,
10007	,
10009	,
10018	,
10014
)

AND TRUNC(pcr.last_update_DATE) BETWEEN  '26-dec-2018' AND '31-dec-2019' 
  
   ORDER BY PH.SEGMENT1,
    pl.line_num ;
