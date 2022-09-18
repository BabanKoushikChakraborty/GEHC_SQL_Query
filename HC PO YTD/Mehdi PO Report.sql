select pha.org_id "Org Id"
      ,prha.segment1 "Requisition #"
      ,to_date(prha.creation_date, 'DD-MON-YY') "Requisition Creation Date"
      ,pha.segment1  "PO number"
      ,to_date(pha.creation_date, 'DD-MON-YY') "PO Creation Date"
      ,pha.authorization_status "Approval Status"
      ,papf.full_name  "Requestor Name"
      ,papf.employee_number "Requestor SSO"
      ,papf1.full_name "Preparer Name"
      ,papf1.employee_number "Preparer SSO"
      ,gcc.concatenated_segments "Charge Account"
      ,round(pda.quantity_ordered-pda.quantity_cancelled,2) "Quantity ordered"
      ,nvl(pda.quantity_cancelled,0) "Quantity Cancelled"
      ,round(NVL(pda.quantity_delivered,0),2) "Quantity received"
      ,(select sum((nvl(pda.quantity_ordered,0)-nvl(pda.quantity_cancelled,0))*nvl(pll.Price_Override,0)) 
         from apps.po_line_locations_all pll,APPS.PO_DISTRIBUTIONS_ALL pda   
         where pda.po_line_id=pll.po_line_id 
         and pda.po_header_id = pha.po_header_id)  "PO_Tot_AMT"
      ,pha.currency_code
      ,pv.segment1||pvs.attribute14 "Supplier GSL" 
      ,pv.vendor_name "Supplier Name"       
      ,PVS.VENDOR_SITE_CODE "Supplier Site" 
      
    from apps.PO_REQUISITION_HEADERS_ALL PRHA
        ,APPS.PO_REQ_DISTRIBUTIONS_ALL   PRDA
        ,APPS.PO_REQUISITION_LINES_ALL   PRLA
        ,apps.po_headers_all pha
        ,APPS.PO_LINES_ALL PLA
        ,APPS.PO_DISTRIBUTIONS_ALL PDA
        ,APPS.GL_CODE_COMBINATIONS_KFV   GCC
        ,apps.per_all_people_f papf
        ,apps.per_all_people_f papf1
        ,apps.po_vendors pv
        ,apps.po_vendor_sites_all pvs
        
    where PLA.PO_HEADER_ID = PHA.PO_HEADER_ID
         and PDA.PO_LINE_ID=PLA.PO_LINE_ID
         and papf.person_id = pda.deliver_to_person_id
         and PAPF1.PERSON_ID(+) = prha.PREPARER_ID
         AND PDA.REQ_DISTRIBUTION_ID = PRDA.DISTRIBUTION_ID(+)
         AND PDA.ORG_ID = PRDA.ORG_ID(+)
         AND PRDA.requisition_LINE_id = PRLA.requisition_LINE_id(+)
         AND PRDA.ORG_ID = PRLA.ORG_ID(+)
         and PRLA.REQUISITION_HEADER_ID = PRHA.REQUISITION_HEADER_ID(+)
         AND PRLA.ORG_ID = PRHA.ORG_ID(+)
         and PDA.CODE_COMBINATION_ID = GCC.CODE_COMBINATION_ID
         and pv.vendor_id=pvs.vendor_id 
         and PRLA.vendor_id=pv.vendor_id 
         and PRLA.vendor_site_id=pvs.vendor_site_id 
         
         AND SYSDATE BETWEEN NVL(PAPF.EFFECTIVE_START_DATE, SYSDATE - 1) AND
         NVL(PAPF.EFFECTIVE_END_DATE, SYSDATE + 1)
  
         AND SYSDATE BETWEEN NVL(PAPF1.EFFECTIVE_START_DATE, SYSDATE - 1) AND
         NVL(PAPF1.EFFECTIVE_END_DATE, SYSDATE + 1)
         
         and  PHA.ORG_ID IN ('9064',
         '9065')
and  TRUNC(pha.creation_date) BETWEEN '01-JAN-2021' and '31-DEC-2021'
order by pha.segment1;