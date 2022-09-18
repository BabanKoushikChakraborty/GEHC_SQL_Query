--GEMSMISCBUYER    340678 --
-- PO closed by system --

select  
ph.org_id "Org Id"

,(select organization_name from apps.org_organization_definitions org where org.organization_id = ph.org_id) "Org name"
,ph.segment1 "PO Number" 

,to_date(ph.creation_date, 'DD-MON-YY') "PO Creation Date" 
,mcv.category_concat_segs "UNSPSC Code"


,pl.item_description "Item Desciption" 

,(SELECT papf.full_name
    FROM apps.per_all_people_f papf
    WHERE papf.person_id =pd.deliver_to_person_id
    AND sysdate between papf.effective_start_date and papf.effective_end_date)
 Requestor_name
  ,(SELECT papf.employee_number
    FROM apps.per_all_people_f papf
          ,apps.fnd_user fu
     WHERE 
     papf.person_id =pd.deliver_to_person_id
     AND fu.user_id = ph.created_by
     AND SYSDATE BETWEEN papf.effective_start_date AND papf.effective_end_date) 
"Requestor SSO"

 , ph.closed_code "Status"

,ph.type_lookup_code "Type"

--,ph.ATTRIBUTE7 "PO_Payment Method"  

,ph.authorization_status "PO Status"
--,prha.segment1 "Requisition Number" 

,pll.need_by_date 


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


,ROUND(nvl(pd.QUANTITY_ORDERED,0),3) "Quantity Ordered" 

--,nvl(pd.quantity_delivered,0) "Quantity Delivered"

,nvl(pd.quantity_billed,0) "Quantity Billed"

,nvl(pd.quantity_cancelled,0) "Quantity Cancelled"
,pll.quantity_received 
,round((nvl(pl.quantity,0)*pl.unit_price),2)"Total_Line_Amt"
,round((pll.quantity_received*pl.unit_price),2) "Total_Line_Received_Amt"
,to_date(ph.approved_date, 'DD-MON-YY') "PO Approved Date" 
,to_date(pL.CANCEL_date, 'DD-MON-YY') "PO Cancel Date" 
,POA.NOTE  
 
,pv.vendor_name "Supplier Name" 
,pv.segment1 "Supplier Number" 
,pv.segment1||pvs.attribute14 "GSL" 
,PVS.VENDOR_SITE_CODE "Supplier Site" 

,(pvs.ADDRESS_LINE1  || '     '||

pvs.ADDRESS_LINE2 || '    '||

pvs.ADDRESS_LINE3 || '   ' || pvs.STATE || '    ' || pvs.ZIP ) "Address"

,pvs.CITY "City"

,pvs.COUNTRY "Country"

,(select name from apps.ap_terms where term_id = ph.TERMS_ID) "PO Payment_terms"



from  

apps.gl_code_combinations_kfv gcc, 
apps.po_headers_all ph, 
apps.po_lines_all pl, 
apps.po_line_locations_all pll, 
apps.po_distributions_all pd, 
apps.po_vendors pv, 
apps.po_vendor_sites_all pvs, 

apps.po_action_history poa, 

apps.mtl_categories_v mcv 
--,apps.gecm_gears_data ggr
 
where --prha.requisition_header_id = prla.requisition_header_id 
--and prla.requisition_line_id=prda.requisition_line_id 
 ph.po_header_id = pl.po_header_id 
and pl.po_line_id=pll.po_line_id 
and pll.line_location_id=pd.line_location_id 
and pd.code_combination_id=gcc.code_combination_id 
--and pd.req_distribution_id=prda.distribution_id 
and pl.category_id=mcv.category_id 
and pv.vendor_id=pvs.vendor_id 
and ph.vendor_id=pv.vendor_id 
and ph.vendor_site_id=pvs.vendor_site_id 
and ph.org_id=pvs.org_id 
--and prha.org_id=ph.org_id 
--AND ggr.sub_ar_number(+) = PRLA.attribute12


and poa.object_id=ph.po_header_id
and poa.action_code='CANCEL' 
--and poa.employee_id ='341513'

AND PH.ORG_ID IN (9090,
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
AND TRUNC(ph.creation_date) BETWEEN   '01-JAN-2020' AND '31-DEC-2020'  
--AND POA.NOTE IS NULL


  
   ORDER BY PH.SEGMENT1,
    pl.line_num ;
