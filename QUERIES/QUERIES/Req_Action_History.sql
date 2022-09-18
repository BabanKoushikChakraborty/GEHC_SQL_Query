select prha.segment1
      ,prha.authorization_status
      --,prha.description
      ,pah.object_type_code
      --,pah.OBJECT_SUB_TYPE_CODE
      ,pah.sequence_num
      ,pah.action_code
      ,to_date(pah.action_date, 'DD-MON-YY') "Action Date"
      ,papf.employee_number "Actioned By"
      ,pah.note
      ,to_date(pah.last_update_date, 'DD-MON-YY') "Last Update Dat"
      
      
      from apps.po_action_history pah
            ,apps.po_requisition_headers_all prha
            ,apps.per_all_people_f papf
where prha.requisition_header_id  = pah.object_id
 and  papf.person_id=pah.employee_id
 and  pah.object_type_code = 'REQUISITION'
 and prha.segment1 = '341010011812'
 order by pah.SEQUENCE_NUM 