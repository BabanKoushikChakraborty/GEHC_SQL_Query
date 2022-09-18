select distinct prha.org_id "Org Id"
      ,hro.name "Org Name"
      ,prha.segment1 "Requisition#"
      ,to_date(prha.creation_date,'DD-MON-YY') "Creation Date"
      ,mcb.category_concat_segs "UNSPSC"
      ,(select distinct ipp.approval_code 
         from apps.gecm_compliance_tbl ipp
         where  ipp.transaction_id=PRHA.requisition_header_id
         and ipp.transaction_type='REQUISITION'
         and compliance_name='IPP'
         and rownum<2) "PR Approval Code"
      ,prha.AUTHORIZATION_STATUS "Status"
      ,prha.description "Description"
      ,ROUND((select sum(prla.quantity * PRLA.unit_price) from APPS.PO_REQUISITION_LINES_ALL   PRLA 
                where PRLA.REQUISITION_HEADER_ID = PRHA.REQUISITION_HEADER_ID),2) "Amount"
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
         AND SYSDATE BETWEEN papf.effective_start_date AND papf.effective_end_date) "Requestor SSO" 
      ,reqah.sequence_num "Sequence#"
      ,reqah.description "Approver"
      ,reqah.action_code "Action"
      ,to_date(reqah.action_date,'DD-MON-YY') "Action Date"
      ,REQAH.NOTE "Note"
      --,pv.segment1 "Supplier Number" 
      ,pv.segment1||pvs.attribute14 "Supplier GSL" 
      ,pv.vendor_name "Supplier Name"       
      ,PVS.VENDOR_SITE_CODE "Supplier Site" 
      
      from apps.po_requisition_headers_all prha
          ,APPS.PO_REQUISITION_LINES_ALL   PRLA
          ,apps.mtl_categories_V mcb
          ,apps.hr_operating_units  hro
          ,apps.po_vendors pv
          ,apps.po_vendor_sites_all pvs
          ,(select prha.segment1
                  ,poa.SEQUENCE_NUM 
                  ,poa.action_code
                  ,fu.description
                  ,poa.action_date
                  ,poa.note
                from apps.po_action_history poa,
                     apps.po_requisition_headers_all prha,
                     apps.fnd_user fu
                where poa.object_id        = prha.requisition_header_id
                     and poa.employee_id   = fu.employee_id
                     and poa.object_type_code = 'REQUISITION'
                order by prha.segment1,poa.sequence_num) REQAH
                
          
          where PRLA.REQUISITION_HEADER_ID = PRHA.REQUISITION_HEADER_ID(+)
          and prla.category_id = mcb.category_id
          and HRO.ORGANIZATION_ID = PRHA.ORG_ID
          and pv.vendor_id=pvs.vendor_id 
          and PRLA.vendor_id=pv.vendor_id 
          and PRLA.vendor_site_id=pvs.vendor_site_id 
          and prha.segment1 = reqah.segment1
          --and prha.segment1 = '911110120347'
          and prha.org_id = '9174'
          and (select distinct ipp.approval_code 
         from apps.gecm_compliance_tbl ipp
         where  ipp.transaction_id=PRHA.requisition_header_id
         and ipp.transaction_type='REQUISITION'
         and compliance_name='IPP'
         and rownum<2) is not null
         and prha.authorization_status in ('IN PROCESS','PRE-APPROVED','INCOMPLETE')
         
         and  TRUNC(prha.creation_date) BETWEEN '01-OCT-2021' and '31-DEC-2021'
          
    order by prha.segment1, reqah.sequence_num;
