select distinct prha.segment1 "Requisition #", 
poa.sequence_num , 
papf.full_name, 
papf.employee_number 
,poa.action_code "Action" 
--,poa.note 
,NVL(apll.attribute5,(Select 'Preparer' from dual where poa.employee_id=prha.preparer_id)) "Approver_type"
/*,NVL(apll.attribute5,
        (case when poa.employee_id=prha.preparer_id then
            'Preparer' 
         else
            (select apll2.attribute5 from apps.po_approval_list_lines apll2 where apll2.approver_id=apll.approver_id and apll2.attribute5 is not null and rownum <2)
         end
        )
    ) "Approver_type"*/
,poa.action_date 
,(select apll2.attribute5 from apps.po_approval_list_lines apll2 where apll2.approver_id=apll.approver_id and apll2.attribute5 is not null and rownum <2) "test"

from 
apps.po_approval_list_headers aplh, 
apps.po_approval_list_lines apll, 
apps.po_action_history poa, 
apps.po_requisition_headers_all prha, 
apps.per_all_people_f papf 
where 
poa.employee_id = papf.person_id 
and prha.requisition_header_id = poa.object_id 
AND prha.segment1 = '301010006454' and poa.object_type_code='REQUISITION'
and apll.approval_list_header_id(+) = aplh.approval_list_header_id 
AND papf.person_id = apll.approver_id(+) 
AND aplh.document_id(+) = prha.requisition_header_id
AND SYSDATE between papf.effective_start_Date and papf.effective_end_date
--and apll.attribute5 is not null 
--and poa.action_code is null
order by poa.sequence_num desc;