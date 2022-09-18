SELECT DISTINCT prha.org_id
,hro.name org_name 
 ,prha.segment1 "Requisition #"
,prha.creation_date "Requisition Creation Date"
,(select min(action_date) from apps.po_action_history where object_id = PRHA.REQUISITION_HEADER_ID and  object_type_code = 'REQUISITION' and action_code ='SUBMIT') "Req_Submit_Date"
,(select max(action_date) from apps.po_action_history where object_id = PRHA.REQUISITION_HEADER_ID and  object_type_code = 'REQUISITION' ) "Last_Action_Date"
--,prla.line_num
--, GCCK.concatenated_segments "Charge Account"
--, mcb.description "Commodity Description"
,mcb.category_concat_segs "UNSPSC"
--,prla.item_description
,PRHA.AUTHORIZATION_STATUS STATUS
,PRHA.description
--,prla.line_num
,(SELECT papf.full_name
    FROM apps.per_all_people_f papf
    WHERE papf.person_id =prla.to_person_id
    AND sysdate between papf.effective_start_date and papf.effective_end_date) "Requestor Name"


  ,(SELECT papf.employee_number
    FROM apps.per_all_people_f papf
        --  ,apps.fnd_user fu
     WHERE 
     papf.person_id =prla.to_person_id
     --AND fu.user_id = prha.created_by
     AND SYSDATE BETWEEN papf.effective_start_date AND papf.effective_end_date) 
"Requestor SSO" 

--,prla.quantity "PR Quantity"
--,prla.unit_price "PR Unit Price"
--,(prla.unit_price * prla.quantity) "Req_amount"
--, nvl(PRLA.currency_unit_price,PRLA.unit_price) "Unit Price" 
,ROUND((select sum(prla.quantity * PRLA.unit_price) from APPS.PO_REQUISITION_LINES_ALL   PRLA 
                where PRLA.REQUISITION_HEADER_ID = PRHA.REQUISITION_HEADER_ID),2) "Amount" 

--,ROUND(prla.quantity * nvl(PRLA.currency_unit_price,PRLA.unit_price),3) "Line Amount"
--,prla.currency_code

/*,ROUND((case 
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
end),3) "USD Line Amount" */
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
'||apll.attribute8||' '||apll.response_date)
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
        
        ) All_approvers,
        reqah.last_action,
--poa.sequence_num ,
papf1.full_name "Pending with Approver", 
papf1.employee_number,
(case when poa.action_code is null then 'Pending' else poa.action_code End) "Action" ,
poa.note

,poa.action_date
,NVL(apll.attribute5,
(case when poa.employee_id=prha.preparer_id then
'Preparer'
else
(select apll2.attribute5 from apps.po_approval_list_lines apll2 where apll2.approver_id=apll.approver_id and apll2.attribute5 is not null and rownum <2)
end
)
) "Approver_type"
--,apll.attribute5 "Approver_type"
,to_date(SYSDATE,'DD-MM-YYYY')-to_date((select max(action_date) from apps.po_action_history where object_id = PRHA.REQUISITION_HEADER_ID and  object_type_code = 'REQUISITION'),'DD-MM-YYYY') as Aging        
--,to_date(SYSDATE,'DD-MM-YYYY')-to_date(prha.creation_date,'DD-MM-YYYY')     
        
        
        
FROM 
APPS.PO_REQUISITION_LINES_ALL   PRLA,
 apps.PO_REQUISITION_HEADERS_ALL PRHA,
apps.gl_code_combinations_kfv GCCK ,
apps.po_req_distributions_all prda,
apps.mtl_categories_V mcb,
apps.hr_operating_units  hro,
apps.gl_sets_of_books CURR,
apps.po_vendors pv, 
apps.po_vendor_sites_all pvs,
apps.po_action_history poa,
apps.per_all_people_f papf1,
apps.po_approval_list_lines apll,
apps.po_approval_list_headers aplh,
(select prha.segment1,
( poa.action_code||' | '||fu.description||' | '||poa.action_date) LAST_ACTION
from apps.po_action_history poa,
     apps.po_requisition_headers_all prha,
     apps.fnd_user fu
     where poa.object_id           = prha.requisition_header_id
     and poa.employee_id   = fu.employee_id
     and poa.object_type_code = 'REQUISITION'
     and poa.sequence_num =(SELECT MAX(sequence_num)-1
                              FROM apps.po_action_history poa1
                             WHERE poa1.object_id = poa.object_id
                               AND poa1.object_type_code ='REQUISITION')
     order by poa.sequence_num) REQAH

where

HRO.ORGANIZATION_ID = PRHA.ORG_ID
and PRLA.REQUISITION_HEADER_ID = PRHA.REQUISITION_HEADER_ID(+)
AND prda.requisition_line_id = PRLA.requisition_line_id
AND PRLA.ORG_ID = PRHA.ORG_ID(+)
AND CURR.set_of_books_id = hro.set_of_books_id(+)
AND PRHA.AUTHORIZATION_STATUS IN ('IN PROCESS','PRE-APPROVED','INCOMPLETE')
AND prda.code_combination_id = GCCK.code_combination_id
AND prla.category_id = mcb.category_id
and pv.vendor_id=pvs.vendor_id 
and PRLA.vendor_id=pv.vendor_id 
and PRLA.vendor_site_id=pvs.vendor_site_id 
---and prha.org_id IN ('9095')
and poa.employee_id = papf1.person_id
and prha.requisition_header_id = poa.object_id
and apll.approval_list_header_id(+) = aplh.approval_list_header_id
AND papf1.person_id = apll.approver_id(+)
AND aplh.document_id(+) = prha.requisition_header_id
AND reqah.segment1 = prha.segment1
AND poa.object_type_code='REQUISITION'
--AND prha.segment1 = '331010036861'
and poa.action_code is null
AND aplh.latest_revision = 'Y'
--and apll.attribute5 is not null
--and papf1.employee_number = '212043450'
and prha.org_id In ('9059',
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
'9105')
and to_date(SYSDATE,'DD-MM-YYYY')-to_date((select max(action_date) from apps.po_action_history where object_id = PRHA.REQUISITION_HEADER_ID and  object_type_code = 'REQUISITION'),'DD-MM-YYYY')> 5

and  TRUNC(prha.creation_date) BETWEEN '01-JAN-2017' and '31-DEC-2021'  
  
   ORDER BY PRHA.SEGMENT1 ;
