[06:34 pm] Pal, Subhojit (GE Healthcare, consultant)
select distinct prha.org_id "Org Id"
      ,hro.name "Org Name"
      ,xep.name "Legal Entity"
      ,to_number(prha.segment1) "Requisition#"
      ,to_date(prha.creation_date,'DD-MON-YY') "Requisition Creation Date"
      ,prha.AUTHORIZATION_STATUS "Status"
      ,prha.description "Description"
      ,ROUND((select sum(prla.quantity * PRLA.unit_price) from APPS.PO_REQUISITION_LINES_ALL   PRLA
                where PRLA.REQUISITION_HEADER_ID = PRHA.REQUISITION_HEADER_ID),2) "Requisition Amount"
      ,papf.full_name  "Requestor Name"
      ,papf.employee_number "Requestor SSO"
      ,papf1.full_name "Preparer Name"
      ,papf1.employee_number "Preparer SSO"
      --,poa.sequence_num "Sequence#"
      ,fu.description "Approver"
      ,poa.action_code "Action"
      ,to_date(poa.action_date,'DD-MON-YY') "Action Date"
      ,to_number(pha.segment1) "PO#"
      ,to_date(pha.creation_date,'DD-MON-YY') "PO Creation Date"

from apps.po_requisition_headers_all prha
    ,APPS.PO_REQ_DISTRIBUTIONS_ALL   PRDA
    ,APPS.PO_REQUISITION_LINES_ALL   PRLA
    ,apps.po_headers_all pha
    ,apps.po_lines_all pla
    ,APPS.PO_DISTRIBUTIONS_ALL PDA
    ,apps.hr_operating_units  hro
    ,apps.xle_entity_profiles xep
    ,apps.org_organization_definitions ods
    ,apps.per_all_people_f papf
    ,apps.per_all_people_f papf1
    ,apps.po_action_history poa
    ,apps.fnd_user fu

where hro.organization_id = prha.org_id
  and papf.person_id = pda.deliver_to_person_id
  and papf1.person_id(+) = prha.preparer_id
  AND ods.organization_id = prha.org_id
  AND ods.legal_entity = xep.legal_entity_id
  and PLA.ORG_ID = PHA.ORG_ID
  and PLA.PO_HEADER_ID = PHA.PO_HEADER_ID
  and PDA.PO_LINE_ID=PLA.PO_LINE_ID
  and PDA.ORG_ID=PLA.ORG_ID
  AND PDA.REQ_DISTRIBUTION_ID = PRDA.DISTRIBUTION_ID(+)
  AND PDA.ORG_ID = PRDA.ORG_ID(+)
  AND PRDA.requisition_LINE_id = PRLA.requisition_LINE_id(+)
  AND PRDA.ORG_ID = PRLA.ORG_ID(+)
  and PRLA.REQUISITION_HEADER_ID = PRHA.REQUISITION_HEADER_ID(+)
  AND PRLA.ORG_ID = PRHA.ORG_ID(+)
  and poa.object_id        = prha.requisition_header_id
  and poa.employee_id   = fu.employee_id
  and poa.object_type_code = 'REQUISITION'
  and fu.description in ('Dong, Pei(305025315)')
  and poa.action_code not in ('SUBMIT')
  --and prha.segment1 in  ('')
  --and prha.org_id in ('')
  --and papf1.employee_number in ('305025315')
  and  TRUNC(prha.creation_date) BETWEEN '01-Jan-2016' and '31-Dec-2022'
  order by prha.segment1

