  SELECT  
  pha.org_id
  
    ,hro.name org_name
    
        ,xep.name legal_entity
  
   , prha.segment1 "Requisition #"
   ,prha.authorization_status "PR Status"
  ,to_date(prha.creation_date, 'DD-MON-YY') "Requisition Creation Date"
   ,to_date(prla.need_by_date, 'DD-MON-YY') "Need_By_Date"
  --,prla.need_by_date "Need by Date"
  , pha.segment1  "PO number"
  ,to_date(pha.creation_date, 'DD-MON-YY') "PO Creation Date"
  ,pha.closed_code "Status"
  ,to_date(pha.closed_date, 'DD-MON-YY') "PO Closed Date"
  ,(select listagg('Date: '||poah.action_date||', Action: '||poah.action_code ||', Note: '|| poah.NOTE ||' By: '|| papf.employee_number ||'; ') 
        WITHIN GROUP (ORDER BY poah.sequence_num ) action_list 
        from apps.po_action_history poah
            ,apps.per_all_people_f        papf
        where
            poah.object_id=pha.po_header_id
            and poah.object_type_code = 'PO'
            AND papf.person_id=poah.employee_id
            ) "All Actions Taken"
  ,(select POA.NOTE from apps.po_action_history POA where action_code='OPEN' AND POA.object_id=pha.po_header_id and rownum<2) "SOURCE"

 ,mc.segment1 || '.' || mc.segment2 || '.' || mc.segment3 || '.' ||
  mc.segment4 || '.' || mc.segment5 "UNSPSC Code"

,gcc.concatenated_segments "Charge Account"

,(SELECT approval_code
  FROM apps.gecm_compliance_tbl
  WHERE transaction_id = PRHA.requisition_header_id
  AND transaction_type = 'REQUISITION'
  and COMPLIANCE_NAME  = 'IPP'
  and rownum<2) High_Risk_code 

,ppa.segment1 Project_No
, prda.ATTRIBUTE11 "Asset Number"
 -- ,pla.item_description "Item Description"
 
  ,papf.full_name  Requestor_name
  , papf.employee_number "Requestor SSO"

,papf1.full_name "Preparer Name"

, papf1.employee_number "Preparer SSO"

  
 -- 
  
 -- ,pla.line_num "line Number"
  --,pll.Price_Override
 -- ,pda.quantity_ordered "Quantity ordered"
 -- ,pda.quantity_delivered "Quantity received"
 -- ,round((nvl(pda.quantity_ordered,0)*nvl(pll.Price_Override,0)),2) "PO_Dist_Line_amt"
  
   ,(select sum((nvl(pda.quantity_ordered,0)-nvl(pda.quantity_cancelled,0))*nvl(pll.Price_Override,0)) from apps.po_line_locations_all pll,APPS.PO_DISTRIBUTIONS_ALL pda   where pda.po_line_id=pll.po_line_id and pda.po_header_id = pha.po_header_id) "PO_TOTAL_AMOUNT"
  
    ,(select sum(PLL.quantity_cancelled*pll.Price_Override) from apps.po_line_locations_all pll
  where  pll.po_header_id = pha.po_header_id)  "PO_CANCELLED_AMT"
  
   ,(select sum(pll.quantity_received*pll.Price_Override) from apps.po_line_locations_all pll
  where  pll.po_header_id = pha.po_header_id)  "PO_TOTAL_RECEIVED_AMT"
  
 
  
  
    


,pha.currency_code "PAYMENT_CURRENCY_CODE"
  

,decode(pvsa.pay_on_code,
        'RECEIPT','ERS',
        pvsa.pay_on_code)PAY_ON_CODE

  ,pv.vendor_name
  ,pvsa.vendor_site_code
  ,pv.segment1 "Supplier Number"
 
    
 
,(select name from apps.ap_terms where term_id = pha.TERMS_ID) "PO Payment_terms"
     ,CASE WHEN pvsa.inactive_date IS NULL 
       THEN 'ACTIVE'
       ELSE 'IN-ACTIVE'
END AS SUPPLIER_SITE_STATUS
    ,PVSA.email_address
 
          
         
FROM
  apps.hr_operating_units  hro,
  apps.PO_HEADERS_ALL PHA,
  APPS.PO_LINES_ALL PLA,
 APPS.PO_DISTRIBUTIONS_ALL PDA,
 -- apps.po_line_locations_all pll,
  APPS.PO_REQ_DISTRIBUTIONS_ALL   PRDA,
  APPS.PO_REQUISITION_LINES_ALL   PRLA,
  apps.PO_REQUISITION_HEADERS_ALL PRHA,
  APPS.PO_VENDORS PV,
  apps.xle_entity_profiles          xep,
  apps.org_organization_definitions ods,
 APPS.PO_VENDOR_SITES_ALL PVSA,
 APPS.GL_CODE_COMBINATIONS_KFV   GCC
   ,apps.MTL_CATEGORIES mc
,apps.per_all_people_f papf,
apps.per_all_people_f papf1
,PA_PROJECTS_all ppa


WHERE PV.VENDOR_ID = PHA.VENDOR_ID
  AND pvsa.VENDOR_ID = PV.VENDOR_ID
  AND pvsa.VENDOR_SITE_ID = PHA.VENDOR_SITE_ID
  AND pvsa.ORG_ID = PHA.ORG_ID
  AND PLA.ORG_ID = PHA.ORG_ID
 and PLA.PO_HEADER_ID = PHA.PO_HEADER_ID
  and PDA.PO_LINE_ID=PLA.PO_LINE_ID
--  AND PLL.PO_HEADER_ID=PLA.PO_HEADER_ID
--  AND PLL.PO_LINE_ID=PLA.PO_LINE_ID
  and PDA.ORG_ID=PLA.ORG_ID
  AND PDA.REQ_DISTRIBUTION_ID = PRDA.DISTRIBUTION_ID(+)
  AND PDA.ORG_ID = PRDA.ORG_ID(+)
  AND PRDA.requisition_LINE_id = PRLA.requisition_LINE_id
  AND PRDA.ORG_ID = PRLA.ORG_ID
  and PRLA.REQUISITION_HEADER_ID = PRHA.REQUISITION_HEADER_ID(+)
  AND PRLA.ORG_ID = PRHA.ORG_ID(+)
  AND ods.organization_id = pha.org_id
  AND ods.legal_entity = xep.legal_entity_id
  and ppa.project_id(+) = pda.project_id

 -- and poa.action_code='CLOSE'

  and PDA.CODE_COMBINATION_ID = GCC.CODE_COMBINATION_ID
  AND pla.category_id = mc.CATEGORY_ID
  and HRO.ORGANIZATION_ID = PHA.ORG_ID
 
and papf.person_id = pda.deliver_to_person_id
and PAPF1.PERSON_ID = prha.PREPARER_ID
  
AND SYSDATE BETWEEN NVL(PAPF.EFFECTIVE_START_DATE, SYSDATE - 1) AND
NVL(PAPF.EFFECTIVE_END_DATE, SYSDATE + 1)
  
AND SYSDATE BETWEEN NVL(PAPF1.EFFECTIVE_START_DATE, SYSDATE - 1) AND
NVL(PAPF1.EFFECTIVE_END_DATE, SYSDATE + 1)

AND pha.segment1 in ()



  

ORDER BY PHA.SEGMENT1;
