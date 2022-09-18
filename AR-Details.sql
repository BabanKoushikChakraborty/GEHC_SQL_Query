SELECT DISTINCT prha.org_id
,hro.name org_name 
 ,prha.segment1 "Requisition #"
,prda.code_combination_id
,ggr.AR_NUMBER
,PRLA.attribute12 "Sub-AR Number"
,ggr.AR_DESCRIPTION,ggr.INITIAL_BUDGET,ggr.AR_REMAINING_BUDGET,ggr.PR_REMAINING_BUDGET,ggr.SUB_AR_STATUS
,prha.creation_date "Requisition Creation Date"
,prla.line_num
, GCCK.concatenated_segments "Charge Account"
 , mcb.description "Commodity Description"
  ,mcb.category_concat_segs "UNSPSC"
,prla.item_description
,PRHA.AUTHORIZATION_STATUS STATUS

,(SELECT papf.full_name
    FROM apps.per_all_people_f papf
    WHERE papf.person_id =prla.to_person_id
    AND sysdate between papf.effective_start_date and papf.effective_end_date) "Requestor Name"


  ,(SELECT papf.employee_number
    FROM apps.per_all_people_f papf        
     WHERE 
     papf.person_id =prla.to_person_id
     AND SYSDATE BETWEEN papf.effective_start_date AND papf.effective_end_date) 
"Requestor SSO" 

,prla.quantity "PR Quantity"
, nvl(PRLA.currency_unit_price,PRLA.unit_price) "Unit Price" 

,(select sum(prla.quantity * PRLA.unit_price) from APPS.PO_REQUISITION_LINES_ALL   PRLA 
                where PRLA.REQUISITION_HEADER_ID = PRHA.REQUISITION_HEADER_ID) "Amount" 

,ROUND((case 
when CURR.currency_code = 'USD' then 
ROUND(prla.quantity * prla.unit_price,3) 
else 
(select prla.quantity * prla.unit_price * gdr.conversion_RATE 
from apps.gl_daily_rates gdr 
where to_char(trunc(gdr.CONVERSION_DATE), 'DD-MON-YYYY') = 
to_char(prha.creation_date,'DD-MON-RRRR') 
and upper(conversion_type) = upper('Corporate') 
and FROM_CURRENCY = CURR.currency_code 
and TO_CURRENCY = 'USD') 
end),3) "USD Line Amount" 
,CURR.currency_code  FUNC_CURRENCY_CODE

,pv.vendor_name "Supplier Name" 
,pv.segment1 "Supplier Number" 
,pv.segment1||pvs.attribute14 "GSL" 
,PVS.VENDOR_SITE_CODE "Supplier Site" 
,( select at.description
    from apps.ap_terms at
     where term_id = pvs.terms_id
     and rownum < 2) "Payment Terms"
  ,(select  listagg(papf.full_name||';'||papf.employee_number||';'||apll.attribute5||' 
'||apll.attribute8||' '||apll.response_date ,'|')
            WITHIN GROUP (ORDER BY sequence_num ) approval_list
             FROM apps.po_approval_list_headers aplh
        , apps.po_approval_list_lines apll
        ,apps.per_all_people_f        papf
      WHERE apll.approval_list_header_id = aplh.approval_list_header_id
        AND papf.person_id = apll.approver_id
        AND aplh.latest_revision = 'Y'
        AND aplh.document_type= 'REQUISITION'
        AND aplh.document_id = prha.requisition_header_id
        AND SYSDATE between papf.effective_start_Date and papf.effective_end_date
        
        ) All_approvers
FROM 
APPS.PO_REQUISITION_LINES_ALL   PRLA,
apps.PO_REQUISITION_HEADERS_ALL PRHA,
apps.gl_code_combinations_kfv GCCK ,
apps.po_req_distributions_all prda,
apps.mtl_categories_V mcb,
apps.hr_operating_units  hro,
apps.gl_sets_of_books CURR,
apps.po_vendors pv, 
apps.po_vendor_sites_all pvs
,apps.gecm_gears_data ggr
where
HRO.ORGANIZATION_ID = PRHA.ORG_ID
and PRLA.REQUISITION_HEADER_ID = PRHA.REQUISITION_HEADER_ID(+)
AND prda.requisition_line_id = PRLA.requisition_line_id
AND PRLA.ORG_ID = PRHA.ORG_ID(+)
AND CURR.set_of_books_id = hro.set_of_books_id(+)
AND prda.code_combination_id = GCCK.code_combination_id
AND prla.category_id = mcb.category_id
and pv.vendor_id=pvs.vendor_id 
and PRLA.vendor_id=pv.vendor_id 
and PRLA.vendor_site_id=pvs.vendor_site_id 
and ggr.SUB_AR_NUMBER=PRLA.attribute12
--and ggr.INACTIVE_DATE is null  
AND prha.segment1 = '331010080748'
and ROWNUM<2
ORDER BY PRHA.SEGMENT1
   


