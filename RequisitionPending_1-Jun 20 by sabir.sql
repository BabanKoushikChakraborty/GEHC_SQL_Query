SELECT DISTINCT prha.org_id
,hro.name org_name 
 ,prha.segment1 "Requisition #"
,prha.creation_date "Requisition Creation Date"
,(select min(action_date) from apps.po_action_history where object_id = PRHA.REQUISITION_HEADER_ID and  object_type_code = 'REQUISITION' and action_code ='SUBMIT') "Req_Submit_Date"
,(select max(action_date) from apps.po_action_history where object_id = PRHA.REQUISITION_HEADER_ID and  object_type_code = 'REQUISITION' ) "Last_Action_Date"
--,prla.line_num
--, GCCK.concatenated_segments "Charge Account"
--, mcb.description "Commodity Description"
--  ,mcb.category_concat_segs "UNSPSC"
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
		
		
--poa.sequence_num ,
papf1.full_name "Pending with Approver", 
papf1.employee_number,
(case when poa.action_code is null then 'Pending' else poa.action_code End) "Action" ,
poa.note

,poa.action_date
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
apps.po_approval_list_headers aplh

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
AND poa.object_type_code='REQUISITION'
--AND prha.segment1 = '331010036861'
and poa.action_code is null
--and apll.attribute5 is not null
--and papf1.employee_number = '212043450'
and prha.org_id In ('9666',
'9667',
'9990',
'10038',
'9055',
'9056',
'9142',
'9110',
'9109',
'9139',
'9057',
'9058',
'9097',
'9140',
'9115',
'9159',
'10033',
'9088',
'10030',
'9092',
'9128',
'9121',
'10045',
'9124',
'9120',
'9131',
'9993',
'9161',
'10035',
'9113',
'9083',
'9137',
'9099',
'9059',
'9168',
'9134',
'9117',
'9095',
'9082',
'10032',
'9155',
'9160',
'9060',
'9153',
'9156',
'9061',
'9162',
'10028',
'9141',
'9174',
'10007',
'9129',
'9062',
'9114',
'9909',
'10031',
'9163',
'9164',
'10018',
'10034',
'9093',
'9154',
'9185',
'9169',
'9939',
'9143',
'9111',
'9112',
'10039',
'9177',
'9089',
'10029',
'9173',
'9179',
'9910',
'9063',
'9182',
'9187',
'9184',
'9064',
'9065',
'9186',
'9148',
'9106',
'9170',
'9998',
'9152',
'9999',
'9158',
'9126',
'9989',
'9183',
'9803',
'9180',
'9127',
'9176',
'9130',
'9178',
'9150',
'9066',
'9230',
'9105',
'9149',
'9103',
'9971',
'9098',
'10043',
'9094',
'9090',
'9116',
'9096',
'10009',
'9122',
'9118',
'9165',
'9172',
'9100',
'9107',
'9171',
'10014',
'9231',
'10000',
'9104',
'10040',
'10041',
'9101',
'9108',
'10044',
'9102',
'9167',
'9123',
'10042',
'9125',
'9132',
'9067',
'9166',
'9944',
'9270',
'9119',
'9268',
'9915',
'9133',
'9138',
'9269',
'9797',
'9879',
'9265',
'9157',
'9151',
'9796',
'9181',
'9146',
'9175',
'9798',
'9267',
'9266',
'9188',
'9144',
'9145',
'9147',
'9889',
'10050',
'10048',
'10047',
'10049',
'10052',
'10051',
'10054',
'10055',
'10053',
'10059')
and to_date(SYSDATE,'DD-MM-YYYY')-to_date((select min(action_date) from apps.po_action_history where object_id = PRHA.REQUISITION_HEADER_ID and  object_type_code = 'REQUISITION'),'DD-MM-YYYY')> 5

and  TRUNC(prha.creation_date) BETWEEN '01-JAN-2017' and '31-DEC-2021'  
  
   ORDER BY PRHA.SEGMENT1 ;
