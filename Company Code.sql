select distinct pha.org_id "Org Id", hro.name "Org Name", xep.name "LE Name",  
    (select * from (select gleb.FLEX_SEGMENT_VALUE from apps.gl_legal_entities_bsvs gleb 
        where gleb.legal_entity_id = ods.legal_entity order by gleb.LAST_UPDATE_DATE desc) where rownum <2) "Company Code"
    from 
    apps.xle_entity_profiles    xep
    ,apps.PO_HEADERS_ALL PHA
    ,apps.org_organization_definitions ods
    ,apps.hr_operating_units  hro
    ,apps.gl_legal_entities_bsvs gleb
where 
    ods.organization_id = pha.org_id
    AND ods.legal_entity = xep.legal_entity_id 
    and xep.legal_entity_id = gleb.legal_entity_id
    and pha.org_id = hro.ORGANIZATION_ID
    and pha.org_id in (
    9183,
    9056
    )