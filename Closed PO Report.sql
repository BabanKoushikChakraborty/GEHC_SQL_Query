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
  ,(select POA.NOTE from apps.po_action_history POA where action_code='CLOSE' AND POA.object_id=pha.po_header_id AND POA.ACTION_DATE= pha.closed_date and rownum<2) "SOURCE"

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

AND PHA.ORG_ID IN (9183,
9180,
9178,
9150,
9176,
9130,
9066,
9127,
9230,
9115,
9142,
9140,
9154,
9185,
9093,
9088,
9089,
9095,
9082,
9113,
9137,
9083,
9110,
9109,
9159,
9179,
9184,
9106,
9182,
9187,
9161,
9126,
9058,
9143,
9186,
9099,
9117,
9061,
9112,
9111,
9060,
9129,
9134,
9063,
9155,
9152,
9149,
9162,
9168,
9062,
9055,
9056,
9065,
9064,
9059,
9097,
9114,
9148,
9139,
9177,
9124,
9120,
9128,
9131,
9121,
9092,
9160,
9158,
9105,
9141,
9174,
9057,
9156,
9173,
9170,
9163,
9164,
9169,
9909,
9910,
9939,
9153,
9993,
9998,
9999,
10007,
9889,
10018,
9166	,
9116	,
9090	,
9171	,
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
9944	,
9971	,
10000	,
10009	,
10014	,
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
9667,
9666,
9803,
9989,
9990,
9266)


and pha.closed_code = 'CLOSED'
  
and  TRUNC(pha.closed_date) BETWEEN '01-JAN-2019' and '31-DEC-2019'
ORDER BY PHA.SEGMENT1;
