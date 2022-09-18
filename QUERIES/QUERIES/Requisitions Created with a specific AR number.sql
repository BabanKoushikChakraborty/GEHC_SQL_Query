select distinct prha.org_id "Org ID"
               ,hro.name "Org Name"
               ,prha.segment1 "Req#"
               ,to_date(prha.creation_date,'DD-MON-YY') "Creation Date"
               ,prha.authorization_status "Status"
               ,prha.description "Description"
               ,ggr.ar_number "AR Number"
               ,ggr.sub_ar_number "Sub-AR Number"
               --,prla.attribute12 "Sub-AR Number2"
               
from apps.po_requisition_headers_all prha
    ,apps.po_requisition_lines_all prla
    ,apps.hr_operating_units  hro
    ,apps.gecm_gears_data ggr
    
where hro.organization_id = prha.org_id
and prla.requisition_header_id = prha.requisition_header_id(+)
and prla.org_id = prha.org_id(+)
and  ggr.sub_ar_number(+) = PRLA.attribute12
--and prha.segment1 = '14710007668'
and ggr.ar_number = 'AHC204458'