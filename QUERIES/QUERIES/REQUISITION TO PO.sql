SELECT 
  pha.org_id
  
    ,hro.name org_name
    
  
   ,prha.segment1 "Requisition #"
  ,to_date(prha.creation_date, 'DD-MON-YY') "Requisition Creation Date"
  ,to_date((select min(action_date) from apps.po_action_history where object_id = PRHA.REQUISITION_HEADER_ID and  object_type_code = 'REQUISITION' and action_code ='SUBMIT'), 'DD-MON-YY') "Req_Submit_Date" 
  ,prha.authorization_status "PR Status"

  ,to_number(pha.segment1)  "PO number"
  ,to_date(pha.creation_date, 'DD-MON-YY') "PO Creation Date"
  ,pha.authorization_status "APPROVAL Status"
  ,pha.closed_code "PO Status"

 
 ,papf.full_name  Requestor_name
  ,papf.employee_number "Requestor SSO"

,papf1.full_name "Preparer Name"

,papf1.employee_number "Preparer SSO"


  
  

  
,to_date(regexp_substr(prha.attribute5,'[^,]+',1,1),'MM-DD-YY') as START_DATE
,to_date(regexp_substr(prha.attribute5,'[^,]+',1,2),'MM-DD-YY') as END_DATE

          
         
FROM
  apps.hr_operating_units  hro,
  apps.PO_HEADERS_ALL PHA,
APPS.PO_LINES_ALL PLA,
APPS.PO_DISTRIBUTIONS_ALL PDA,
  APPS.PO_REQ_DISTRIBUTIONS_ALL   PRDA,
  APPS.PO_REQUISITION_LINES_ALL   PRLA,
  apps.PO_REQUISITION_HEADERS_ALL PRHA
,apps.per_all_people_f papf
,apps.per_all_people_f papf1


WHERE
      PLA.ORG_ID = PHA.ORG_ID
  and PLA.PO_HEADER_ID = PHA.PO_HEADER_ID
  and PDA.PO_LINE_ID=PLA.PO_LINE_ID
  and PDA.ORG_ID=PLA.ORG_ID
  AND PDA.REQ_DISTRIBUTION_ID = PRDA.DISTRIBUTION_ID(+)
  AND PDA.ORG_ID = PRDA.ORG_ID(+)
  AND PRDA.requisition_LINE_id = PRLA.requisition_LINE_id(+)
  AND PRDA.ORG_ID = PRLA.ORG_ID(+)
  and PRLA.REQUISITION_HEADER_ID = PRHA.REQUISITION_HEADER_ID(+)
  AND PRLA.ORG_ID = PRHA.ORG_ID(+)
  
 and   HRO.ORGANIZATION_ID = PHA.ORG_ID

  and papf.person_id = pda.deliver_to_person_id
  and PAPF1.PERSON_ID(+) = prha.PREPARER_ID

  
  
  AND SYSDATE BETWEEN NVL(PAPF.EFFECTIVE_START_DATE, SYSDATE - 1) AND
   NVL(PAPF.EFFECTIVE_END_DATE, SYSDATE + 1)
  
   AND SYSDATE BETWEEN NVL(PAPF1.EFFECTIVE_START_DATE, SYSDATE - 1) AND
   NVL(PAPF1.EFFECTIVE_END_DATE, SYSDATE + 1)
   
   
   and prha.segment1 in ()

--and  PHA.ORG_ID IN ( )
--and  TRUNC(pha.creation_date) BETWEEN '01-JAN-2021' and '31-DEC-2021'

  
--and  TRUNC(pha.creation_date) BETWEEN '01-JAN-2017' and '31-JAN-2017'
ORDER BY prha.segment1,PHA.SEGMENT1;





