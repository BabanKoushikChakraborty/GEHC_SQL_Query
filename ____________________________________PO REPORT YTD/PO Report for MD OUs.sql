SELECT 
  pha.org_id
  
    ,hro.name org_name
    
        ,xep.name legal_entity
  
   ,prha.segment1 "Requisition #"
  ,to_date(prha.creation_date, 'DD-MON-YY') "Requisition Creation Date"
  ,to_date((select min(action_date) from apps.po_action_history where object_id = PRHA.REQUISITION_HEADER_ID and  object_type_code = 'REQUISITION' and action_code ='SUBMIT'), 'DD-MON-YY') "Req_Submit_Date" 
  ,prha.authorization_status "PR Status"
  ,to_date(prla.need_by_date, 'DD-MON-YY') "Need by Date"
  ,pha.segment1  "PO number"
  ,to_date(pha.creation_date, 'DD-MON-YY') "PO Creation Date"
  ,pha.authorization_status "APPROVAL Status"
  ,pha.closed_code "Po Status"


 ,mc.segment1 || '.' || mc.segment2 || '.' || mc.segment3 || '.' ||
  mc.segment4 || '.' || mc.segment5 "UNSPSC Code"

,(select distinct ipp.approval_code 
  from apps.gecm_compliance_tbl ipp
   where  ipp.transaction_id=PRHA.requisition_header_id
  and ipp.transaction_type='REQUISITION'
  and compliance_name='IPP'
  and rownum<2) "PR Approval Code"

,(select distinct ipp.approval_code 
       from apps.gecm_compliance_tbl ipp
        where  ipp.transaction_id=rt.shipment_header_id
         and compliance_name='IPP'
         and ipp.transaction_type='RECEIPT' and rownum<2) "Receipt Approval Code"


,(select ppa.segment1 from PA_PROJECTS_all ppa where ppa.project_id = pda.project_id) Project_No

,pha.attribute3 EPCARD

  ,pla.item_description "Item Description"


 
 ,papf.full_name  Requestor_name
  ,papf.employee_number "Requestor SSO"

,papf1.full_name "Preparer Name"

,papf1.employee_number "Preparer SSO"

,papf2.full_name "Receiver_name"

,papf2.employee_number "Receiver SSO"

  ,gcc.concatenated_segments "Charge Account"
  
  ,pla.line_num "line Number"
  ,round(pda.quantity_ordered-pda.quantity_cancelled,2) "Quantity ordered"
  ,nvl(pda.quantity_cancelled,0) "Quantity Cancelled"
  ,round(NVL(pda.quantity_delivered,0),2) "Quantity received"
  ,round((pda.quantity_ordered-pda.quantity_cancelled)*pll.Price_Override,2) "PO_Dist_Line_amt"
  
  ,ROUND((case 
when pha.currency_code = 'USD' then 
(pda.quantity_ordered-pda.quantity_cancelled)*pll.Price_Override
else 
(select ((pda.quantity_ordered-pda.quantity_cancelled)*pll.Price_Override)*gdr.conversion_RATE 
from apps.gl_daily_rates gdr 
where to_date(trunc(gdr.CONVERSION_DATE), 'DD-MON-YYYY') = 
to_date(TRUNC(NVL(PHA.rate_date, PHA.creation_date)),'DD-MON-YYYY')  
and upper(conversion_type) = upper('Corporate') 
and FROM_CURRENCY = pha.currency_code 
and TO_CURRENCY = 'USD') 
end),2) "USD Dist_Line_Amt" 

,(select sum((nvl(pda.quantity_ordered,0)-nvl(pda.quantity_cancelled,0))*nvl(pll.Price_Override,0)) from apps.po_line_locations_all pll,APPS.PO_DISTRIBUTIONS_ALL pda   where pda.po_line_id=pll.po_line_id and pda.po_header_id = pha.po_header_id)  "PO_Tot_AMT"
  
 ,ROUND((case when pha.currency_code = 'USD' then (select sum((nvl(pda.quantity_ordered,0)-nvl(pda.quantity_cancelled,0))*nvl(pll.Price_Override,0))
 from apps.po_line_locations_all pll,APPS.PO_DISTRIBUTIONS_ALL pda 
 where pda.po_line_id=pll.po_line_id and pda.po_header_id = pha.po_header_id)
 else (select sum((nvl(pda.quantity_ordered,0)-nvl(pda.quantity_cancelled,0))*(nvl(pll.Price_Override,0)*NVL(gdr.conversion_RATE,0))) 
 from apps.gl_daily_rates gdr ,apps.po_line_locations_all pll,APPS.PO_DISTRIBUTIONS_ALL pda 
 where pda.po_line_id=pll.po_line_id 
 and pda.po_header_id = pha.po_header_id 
 and to_date(trunc(gdr.CONVERSION_DATE),'DD-MON-YYYY')= to_date(TRUNC(NVL(PHA.rate_date, PHA.creation_date)),'DD-MON-YYYY') 
 and upper(conversion_type) = upper('Corporate') and FROM_CURRENCY = pha.currency_code and TO_CURRENCY = 'USD')end),2) "Usd_PO_Tot_Amt" 
  
  
,ROUND((case 
when pha.currency_code = 'USD' then 
(select sum(pda.quantity_delivered*pll.Price_Override) from apps.po_line_locations_all 
pll,APPS.PO_DISTRIBUTIONS_ALL pda
where pda.po_line_id=pll.po_line_id and pda.po_header_id = pha.po_header_id)

else 
(select sum(pda.quantity_delivered*pll.Price_Override*gdr.conversion_RATE) 
from apps.gl_daily_rates gdr ,apps.po_line_locations_all pll,APPS.PO_DISTRIBUTIONS_ALL pda
where pda.po_line_id=pll.po_line_id and pda.po_header_id = pha.po_header_id and
to_date(trunc(gdr.CONVERSION_DATE), 'DD-MON-YYYY') = 
to_date(TRUNC(NVL(PHA.rate_date, PHA.creation_date)),'DD-MON-YYYY')  
and upper(conversion_type) = upper('Corporate') 
and FROM_CURRENCY = pha.currency_code 
and TO_CURRENCY = 'USD' )end),2) "USD_TOTAL_AMT_RECEIVED" 
  
    
   ,pha.currency_code "PAYMENT_CURRENCY_CODE"
  
-- , (SELECT currency_code
 --    FROM apps.gl_sets_of_books
 --   WHERE set_of_books_id = hro.set_of_books_id) FUNC_CURRENCY_CODE
         
 
     
    ,RSH.RECEIPT_NUM        "Receipt Number"
   ,to_date(rsh.creation_date, 'DD-MON-YY')   "Receipt date"
   ,rsh.comments "Receipt Comments"
 , to_date(TRUNC(rt.transaction_date), 'DD-MON-YY') Delivery_date
  ,rsl.line_num "Receipt_line_Num"
 , ROUND(pla.unit_price * rt.quantity, 2) "Receipt_amount"
 	 
,ROUND((case 
when pha.currency_code = 'USD' then 
nvl(pla.unit_price,0) * rt.quantity
else 
(select (nvl(pla.unit_price,0) * rt.quantity)* 
gdr.conversion_RATE 
from apps.gl_daily_rates gdr 
where to_date(trunc(gdr.CONVERSION_DATE), 'DD-MON-YYYY') = 
to_date(TRUNC(NVL(PHA.rate_date, PHA.creation_date)),'DD-MON-YYYY')  
and upper(conversion_type) = upper('Corporate') 
and FROM_CURRENCY = pha.currency_code 
and TO_CURRENCY = 'USD') 
end),2) "USD_Receipt_amount" 

 , rt.unit_of_measure "UOM"
  

  ,(select  listagg(papf.full_name||';'||papf.employee_number||';'||apll.attribute5||''||apll.attribute8||' '||apll.response_date ,'|')
            WITHIN GROUP (ORDER BY sequence_num ) approval_list
             FROM apps.po_approval_list_headers aplh
        , apps.po_approval_list_lines apll
        ,apps.per_all_people_f        papf
      WHERE apll.approval_list_header_id = aplh.approval_list_header_id
        AND papf.person_id = apll.approver_id
        AND aplh.latest_revision = 'Y'
        AND aplh.document_type= 'REQUISITION'
        AND aplh.document_id = prha.requisition_header_id
        AND SYSDATE between papf.effective_start_Date and papf.effective_end_date) latest_approver

,decode(pvsa.pay_on_code,
        'RECEIPT','ERS',
        pvsa.pay_on_code)PAY_ON_CODE
        

  ,pv.vendor_name
  ,pvsa.vendor_site_code
  , pv.segment1 GSL
,(select name from apps.ap_terms where term_id = pha.TERMS_ID) "PO Payment_terms"
       
,PVSa.VENDOR_SITE_CODE "Supplier Site" 
,CASE WHEN pvsa.inactive_date IS NULL 
       THEN 'ACTIVE'
       ELSE 'IN-ACTIVE'
END AS SUPPLIER_Site_Status
    ,PVSA.email_address,
    rt.transaction_type
  --  rt.destination_type_code
          
         
FROM
  apps.hr_operating_units  hro,
  apps.PO_HEADERS_ALL PHA,
  APPS.PO_LINES_ALL PLA,
  APPS.PO_DISTRIBUTIONS_ALL PDA,
  apps.po_line_locations_all pll,
  APPS.PO_REQ_DISTRIBUTIONS_ALL   PRDA,
  APPS.PO_REQUISITION_LINES_ALL   PRLA,
  apps.PO_REQUISITION_HEADERS_ALL PRHA,
  APPS.PO_VENDORS PV,
  apps.xle_entity_profiles          xep,
  apps.org_organization_definitions ods,
 apps.rcv_transactions             rt 
 ,APPS.PO_VENDOR_SITES_ALL PVSA,
  APPS.RCV_SHIPMENT_HEADERS RSH,
  apps.RCV_SHIPMENT_LINES RSL
  ,APPS.GL_CODE_COMBINATIONS_KFV   GCC
  , apps.MTL_CATEGORIES mc
,apps.per_all_people_f papf
,apps.per_all_people_f papf1
,apps.per_all_people_f papf2
--,APPS.AP_PAYMENT_SCHEDULES_ALL PSA

WHERE PV.VENDOR_ID = PHA.VENDOR_ID
  AND pvsa.VENDOR_ID = PV.VENDOR_ID
  AND pvsa.VENDOR_SITE_ID = PHA.VENDOR_SITE_ID
  AND pvsa.ORG_ID = PHA.ORG_ID
  AND PLA.ORG_ID = PHA.ORG_ID
  and PLA.PO_HEADER_ID = PHA.PO_HEADER_ID
  and PDA.PO_LINE_ID=PLA.PO_LINE_ID
  AND PLL.PO_HEADER_ID=PLA.PO_HEADER_ID
  AND PLL.PO_LINE_ID=PLA.PO_LINE_ID
  and PDA.ORG_ID=PLA.ORG_ID
  AND PDA.REQ_DISTRIBUTION_ID = PRDA.DISTRIBUTION_ID(+)
  AND PDA.ORG_ID = PRDA.ORG_ID(+)
  AND PRDA.requisition_LINE_id = PRLA.requisition_LINE_id(+)
  AND PRDA.ORG_ID = PRLA.ORG_ID(+)
  and PRLA.REQUISITION_HEADER_ID = PRHA.REQUISITION_HEADER_ID(+)
  AND PRLA.ORG_ID = PRHA.ORG_ID(+)
  AND RSL.PO_HEADER_ID(+)=PHA.PO_HEADER_ID
  AND RSL.PO_LINE_ID(+)=PLA.PO_LINE_ID
     AND ods.organization_id = pha.org_id
       AND ods.legal_entity = xep.legal_entity_id
  and RSL.PO_DISTRIBUTION_ID(+)=PDA.PO_DISTRIBUTION_ID 
  and RSH.SHIPMENT_HEADER_ID(+)=RSL.SHIPMENT_HEADER_ID 
  AND RT.SHIPMENT_LINE_ID(+) = RSL.SHIPMENT_LINE_ID
  AND rsh.shipment_header_id(+) = rt.shipment_header_id
  AND rt.po_header_id(+) = pla.po_header_id
  AND rt.po_line_id(+) = pla.po_line_id
 and  rt.destination_context(+) = 'RECEIVING'
  and PDA.CODE_COMBINATION_ID = GCC.CODE_COMBINATION_ID
  AND pla.category_id = mc.CATEGORY_ID
 and   HRO.ORGANIZATION_ID = PHA.ORG_ID

  and papf.person_id = pda.deliver_to_person_id
  and PAPF1.PERSON_ID(+) = prha.PREPARER_ID
  and papf2.person_id(+)=RSL.employee_id
  
  
  AND SYSDATE BETWEEN NVL(PAPF.EFFECTIVE_START_DATE, SYSDATE - 1) AND
   NVL(PAPF.EFFECTIVE_END_DATE, SYSDATE + 1)
  
   AND SYSDATE BETWEEN NVL(PAPF1.EFFECTIVE_START_DATE, SYSDATE - 1) AND
   NVL(PAPF1.EFFECTIVE_END_DATE, SYSDATE + 1)
   
    AND SYSDATE BETWEEN NVL(PAPF2.EFFECTIVE_START_DATE, SYSDATE - 1) AND
   NVL(PAPF2.EFFECTIVE_END_DATE, SYSDATE + 1)

and  PHA.ORG_ID IN (9145	,
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
9266
)


  
and  TRUNC(pha.creation_date) BETWEEN '01-JAN-2019' and '31-DEC-2019'


  
--and  TRUNC(pha.creation_date) BETWEEN '01-JAN-2017' and '31-JAN-2017'
ORDER BY PHA.SEGMENT1,pla.line_num,RSH.RECEIPT_NUM,rsl.line_num;





