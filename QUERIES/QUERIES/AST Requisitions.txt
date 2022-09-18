select distinct prha.org_id "Org ID"
               ,hro.name "Org Name"
               ,prha.interface_source_code "Interface Source Code"
               ,prha.segment1 "Req#"
               ,to_date(prha.last_update_date,'DD-MON-YY') "Last Update Date"
               ,prha.authorization_status "Status"
               
from apps.po_requisition_headers_all prha
    ,apps.hr_operating_units  hro
where hro.organization_id = prha.org_id
and prha.interface_source_code = 'SSS GWY - AST'
and prha.authorization_status in ('CANCELLED',
'REJECTED')
and trunc(prha.creation_date) between '01-JAN-2022' and '31-DEC-2022' 
order by prha.segment1;