
select
prha.org_id "Org Id"


,(select organization_name from apps.org_organization_definitions org where org.organization_id = prha.org_id ) "Org name"
,ph.segment1 "PO Number" 
,ph.attribute3 
,ph.attribute13
,ph.creation_date "PO Creation Date" 
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
,prha.segment1 "Requisition Number" 

,pll.need_by_date 


,gcc.concatenated_segments charge_account 
,pl.line_num "PO Line Number"

,nvl(pl.unit_price,pll.price_override) "Unit Price" 
,ph.currency_code 
,ROUND((nvl(pd.quantity_ordered,0)*pll.Price_Override),2) "Line Amount" 

,ROUND((case 
when ph.currency_code = 'USD' then 
(nvl(pd.quantity_ordered,0)*pll.Price_Override) 
else 
(select (nvl(pd.quantity_ordered,0)*pll.Price_Override)* 
gdr.conversion_RATE 
from apps.gl_daily_rates gdr 
where to_char(trunc(gdr.CONVERSION_DATE), 'DD-MON-YYYY') = 
to_char(ph.creation_date,'DD-MON-RRRR') 
and upper(conversion_type) = upper('Corporate') 
and FROM_CURRENCY = ph.currency_code 
and TO_CURRENCY = 'USD') 
end),2) "USD Line Amount" 

--,pll.AMOUNT_RECEIVED " Received Amount"


,nvl(pl.quantity,0) "Quantity Ordered" 

--,nvl(pd.quantity_delivered,0) "Quantity Delivered"

,nvl(pd.quantity_billed,0) "Quantity Billed"

,nvl(pd.quantity_cancelled,0) "Quantity Cancelled"
,pll.quantity_received 
,(nvl(pl.quantity,0)*pl.unit_price)"Total Amount"
,(pll.quantity_received*pl.unit_price) "Total Received Amount"
,ph.approved_date "PO Approved Date" 
 
 
 
 
,pv.vendor_name "Supplier Name" 
,pv.segment1 "Supplier Number" 
,pv.segment1||pvs.attribute14 "GSL" 
,PVS.VENDOR_SITE_CODE "Supplier Site" 

,(pvs.ADDRESS_LINE1  || '     '||

pvs.ADDRESS_LINE2 || '    '||

pvs.ADDRESS_LINE3 || '   ' || pvs.STATE || '    ' || pvs.ZIP ) "Address"

,pvs.CITY "City"

,pvs.COUNTRY "Country"

,(select name from apps.ap_terms where term_id = pvs.TERMS_ID) "Payment_terms"
,fdt1.long_text as address
from  
apps.po_requisition_headers_all prha, 
apps.po_requisition_lines_all prla, 
apps.po_req_distributions_all prda, 
apps.gl_code_combinations_kfv gcc, 
apps.po_headers_all ph, 
apps.po_lines_all pl, 
apps.po_line_locations_all pll, 
apps.po_distributions_all pd, 
apps.po_vendors pv, 
apps.po_vendor_sites_all pvs, 
apps.fnd_documents_long_text fdt1,
apps.FND_ATTACHED_DOCS_FORM_VL fdt2,

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
--
and fdt2.pk1_value = pll.Line_location_id
and fdt2.pk2_value='ONE_TIME_LOCATION' 
and fdt2.entity_name='PO_SHIPMENTS'
and fdt1.media_id=fdt2.media_id
--and ph.segment1 in ('11020271922','11020271924')  
--and ph.closed_code = 'OPEN'
and fdt2.function_name = 'PO_POXPOEPO' 
AND TRUNC(PH.CREATION_DATE) BETWEEN  '01-Jan-2019' AND  '30-NOV-2019' 
and( ph.attribute3 != 'EPCARD' or ph.attribute3 is null)
--and ph.attribute3 is null
AND PH.ORG_ID in ('9145',
'9101',
'9060',
'9106',
'9102',
'9089',
'9119',
'9146',
'9147',
'9109',
'9129',
'9121',
'9122',
'9114',
'9162',
'9269',
'9230',
'9157',
'9185',
'9148',
'9158',
'9182',
'9915',
'9944',
'9971',
'9993',
'9999',
'9057',
'9055',
'9103',
'9142',
'9112',
'9151',
'9181',
'9180',
'9270',
'9266',
'9164',
'9188',
'9154',
'9144',
'9156',
'9797',
'9879',
'9940',
'9998',
'9107',
'9104',
'9105',
'9088',
'9100',
'9115',
'9111',
'9132',
'9110',
'9231',
'9165',
'9153',
'9149',
'10000',
'9108',
'9093',
'9094',
'9097',
'9128',
'9134',
'9268',
'9174',
'9178',
'9163',
'9160',
'9796',
'9118',
'9909',
'9067',
'9056',
'9066',
'9063',
'9082',
'9133',
'9113',
'9124',
'9123',
'9117',
'9095',
'9138',
'9140',
'9168',
'9798',
'9061',
'9059',
'9065',
'9058',
'9090',
'9116',
'9125',
'9127',
'9265',
'9171',
'9167',
'9141',
'9150',
'9186',
'9170',
'9155',
'9184',
'9161',
'9179',
'9177',
'9172',
'9187',
'9143',
'9183',
'9176',
'9139',
'9169',
'9152',
'9173',
'9910',
'9064',
'9099',
'9098',
'9083',
'9062',
'9096',
'9092',
'9130',
'9126',
'9175',
'9120',
'9131',
'9166',
'9159',
'9267',
'9137',
'9939',
'9889',
'10007',
'10009',
'10014',
'10018') 

  
   ORDER BY PH.SEGMENT1,
    pl.line_num ;


----------------------------------
/*select ph.segment1, pll.Line_location_id , fdt2.pk2_value 
from 
apps.po_headers_all ph, 
apps.po_lines_all pl, 
apps.po_line_locations_all pll 
,apps.FND_ATTACHED_DOCS_FORM_VL fdt2 
where 
ph.po_header_id = pl.po_header_id
and pl.po_line_id = pll.po_line_id 
and fdt2.pk1_value = pll.Line_location_id
--and fdt2.pk2_value='ONE_TIME_LOCATION' 
and fdt2.entity_name='PO_SHIPMENTS'
and fdt2.function_name = 'PO_POXPOEPO' 

and ph.segment1 in ('11020349291','201020003537')


;*/


/*
SELECT distinct pha.org_id Org_Id,hro.name Organisation_Name,prha.segment1 Req_No,pha.segment1 PO_No,to_date(pha.creation_date, 'DD-MON-YY') PO_Creation_Date,pla.line_num PO_Line_num, 
pla.QUANTITY PO_Quantity,pll.quantity_received PO_Qty_Received,nvl(pla.unit_price,pll.price_override) Unit_price,RSH.RECEIPT_NUM Receipt_No,rsl.line_num Receipt_Line 
,rsl.QUANTITY_RECEIVED QTY_Received, pv.segment1 Vendor_GSL,papf.employee_number Requestor_SSO,to_char(pll.need_by_date, 'DD.MM.YY') Need_by_Date,hla.location_code Ship_To_Location, hla1.location_code bill_To_Location 

,DECODE((select count(fdt2.pk2_value) 
from 
apps.FND_ATTACHED_DOCUMENTS fdt2 
where 
fdt2.pk1_value = pll.Line_location_id
and fdt2.entity_name='PO_SHIPMENTS'
--and fdt2.function_name = 'PO_POXPOEPO' 
),0,'Non-OTST','OTST') Status
FROM 
apps.hr_operating_units hro,APPS.po_headers_all PHA, APPS.po_lines_all PLA,APPS.po_distributions_all PDA,APPS.po_line_locations_all pll,APPS.po_req_distributions_all PRDA, APPS.po_requisition_lines_all 
PRLA,APPS.po_requisition_headers_all PRHA,APPS.PO_VENDORS PV,apps.rcv_transactions rt 
,APPS.PO_VENDOR_SITES_ALL PVSA,APPS.RCV_SHIPMENT_HEADERS RSH,apps.RCV_SHIPMENT_LINES RSL,APPS.GL_CODE_COMBINATIONS_KFV GCC, 
apps.per_all_people_f papf,apps.hr_locations hla,apps.hr_locations hla1 
WHERE 
PV.VENDOR_ID = PHA.VENDOR_ID AND pvsa.VENDOR_ID = PV.VENDOR_ID AND pvsa.VENDOR_SITE_ID = PHA.VENDOR_SITE_ID AND pvsa.ORG_ID = PHA.ORG_ID AND PLA.ORG_ID = PHA.ORG_ID 
and PLA.PO_HEADER_ID = PHA.PO_HEADER_ID and PDA.PO_LINE_ID=PLA.PO_LINE_ID AND PLL.PO_HEADER_ID=PLA.PO_HEADER_ID AND PLL.PO_LINE_ID=PLA.PO_LINE_ID and PDA.ORG_ID=PLA.ORG_ID 
AND PDA.REQ_DISTRIBUTION_ID =PRDA.DISTRIBUTION_ID(+) AND PDA.ORG_ID = PRDA.ORG_ID(+) AND PRDA.requisition_LINE_id = PRLA.requisition_LINE_id(+) AND PRDA.ORG_ID = PRLA.ORG_ID(+) 
and PRLA.REQUISITION_HEADER_ID = PRHA.REQUISITION_HEADER_ID(+) AND PRLA.ORG_ID = PRHA.ORG_ID(+) AND RSL.PO_HEADER_ID(+)=PHA.PO_HEADER_ID AND RSL.PO_LINE_ID(+)=PLA.PO_LINE_ID 
and RSL.PO_DISTRIBUTION_ID(+)=PDA.PO_DISTRIBUTION_ID and RSH.SHIPMENT_HEADER_ID(+)=RSL.SHIPMENT_HEADER_ID AND RT.SHIPMENT_LINE_ID(+) = RSL.SHIPMENT_LINE_ID AND rsh.shipment_header_id(+) = rt.shipment_header_id 
AND rt.po_header_id(+) = pla.po_header_id AND rt.po_line_id(+) = pla.po_line_id and PDA.CODE_COMBINATION_ID = GCC.CODE_COMBINATION_ID and HRO.ORGANIZATION_ID = PHA.ORG_ID 
and rt.destination_context(+) = 'RECEIVING' and papf.person_id = pda.deliver_to_person_id 
AND pha.ship_to_location_id = hla.location_id and pha.BILL_TO_LOCATION_ID=hla1.location_id
and pha.segment1='201020003537'


*/

/*
SELECT distinct pha.org_id Org_Id,hro.name Organisation_Name,PRHA.REQUISITION_HEADER_ID,prha.segment1 Req_No,pha.segment1 PO_No,to_date(pha.creation_date, 'DD-MON-YY') PO_Creation_Date,pla.line_num PO_Line_num, 
pla.QUANTITY PO_Quantity,pll.quantity_received PO_Qty_Received,nvl(pla.unit_price,pll.price_override) Unit_price,RSH.RECEIPT_NUM Receipt_No,rsl.line_num Receipt_Line 
,rsl.QUANTITY_RECEIVED QTY_Received, pv.segment1 Vendor_GSL,papf.employee_number Requestor_SSO,to_char(pll.need_by_date, 'DD.MM.YY') Need_by_Date,hla.location_code Ship_To_Location, hla1.location_code bill_To_Location 

,DECODE((select count(fdt2.pk2_value) 
from 
apps.FND_ATTACHED_DOCUMENTS fdt2 
where 
fdt2.pk1_value = pll.Line_location_id
and fdt2.entity_name='PO_SHIPMENTS'
--and fdt2.function_name = 'PO_POXPOEPO' 
),0,'Non-OTST','OTST') Status
,case (select count(fdt2.pk2_value) 
from 
apps.FND_ATTACHED_DOCUMENTS fdt2 
where 
fdt2.pk1_value = pll.Line_location_id
and fdt2.entity_name='PO_SHIPMENTS'
--and fdt2.function_name = 'PO_POXPOEPO' 
) WHEN 0 THEN hla.location_code
ELSE (select * from (select piav.attribute1||';'||piav.attribute2||';'||piav.attribute3||';'||piav.attribute4||';'||piav.attribute5 from apps.por_item_attribute_values piav where piav.REQUISITION_HEADER_ID = PRHA.REQUISITION_HEADER_ID ) where ROWNUM<2)
END Status_2
FROM 
apps.hr_operating_units hro,APPS.po_headers_all PHA, APPS.po_lines_all PLA,APPS.po_distributions_all PDA,APPS.po_line_locations_all pll,APPS.po_req_distributions_all PRDA, APPS.po_requisition_lines_all 
PRLA,APPS.po_requisition_headers_all PRHA,APPS.PO_VENDORS PV,apps.rcv_transactions rt 
,APPS.PO_VENDOR_SITES_ALL PVSA,APPS.RCV_SHIPMENT_HEADERS RSH,apps.RCV_SHIPMENT_LINES RSL,APPS.GL_CODE_COMBINATIONS_KFV GCC, 
apps.per_all_people_f papf,apps.hr_locations hla,apps.hr_locations hla1 
WHERE 
PV.VENDOR_ID = PHA.VENDOR_ID AND pvsa.VENDOR_ID = PV.VENDOR_ID AND pvsa.VENDOR_SITE_ID = PHA.VENDOR_SITE_ID AND pvsa.ORG_ID = PHA.ORG_ID AND PLA.ORG_ID = PHA.ORG_ID 
and PLA.PO_HEADER_ID = PHA.PO_HEADER_ID and PDA.PO_LINE_ID=PLA.PO_LINE_ID AND PLL.PO_HEADER_ID=PLA.PO_HEADER_ID AND PLL.PO_LINE_ID=PLA.PO_LINE_ID and PDA.ORG_ID=PLA.ORG_ID 
AND PDA.REQ_DISTRIBUTION_ID =PRDA.DISTRIBUTION_ID(+) AND PDA.ORG_ID = PRDA.ORG_ID(+) AND PRDA.requisition_LINE_id = PRLA.requisition_LINE_id(+) AND PRDA.ORG_ID = PRLA.ORG_ID(+) 
and PRLA.REQUISITION_HEADER_ID = PRHA.REQUISITION_HEADER_ID(+) AND PRLA.ORG_ID = PRHA.ORG_ID(+) AND RSL.PO_HEADER_ID(+)=PHA.PO_HEADER_ID AND RSL.PO_LINE_ID(+)=PLA.PO_LINE_ID 
and RSL.PO_DISTRIBUTION_ID(+)=PDA.PO_DISTRIBUTION_ID and RSH.SHIPMENT_HEADER_ID(+)=RSL.SHIPMENT_HEADER_ID AND RT.SHIPMENT_LINE_ID(+) = RSL.SHIPMENT_LINE_ID AND rsh.shipment_header_id(+) = rt.shipment_header_id 
AND rt.po_header_id(+) = pla.po_header_id AND rt.po_line_id(+) = pla.po_line_id and PDA.CODE_COMBINATION_ID = GCC.CODE_COMBINATION_ID and HRO.ORGANIZATION_ID = PHA.ORG_ID 
and rt.destination_context(+) = 'RECEIVING' and papf.person_id = pda.deliver_to_person_id 
AND pha.ship_to_location_id = hla.location_id and pha.BILL_TO_LOCATION_ID=hla1.location_id
and pha.segment1 in ('201020003537','11020349291')


*/