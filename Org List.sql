
	
	/*******************************************************************************/
select distinct 
    regexp_substr(haou.attribute13,'[^|]+',1,1) "Business",    
    regexp_substr(haou.attribute13,'[^|]+',1,2) "Pole",
    org.ORGANIZATION_ID, org.ORGANIZATION_NAME, (select * from (select gleb.FLEX_SEGMENT_VALUE from apps.gl_legal_entities_bsvs gleb, apps.org_organization_definitions ods
        where gleb.legal_entity_id = org.LEGAL_ENTITY order by gleb.LAST_UPDATE_DATE desc) where rownum <2) Company_Code
        ,BKD.CURRENCY_CODE
        ,(select xep.name from apps.xle_entity_profiles xep where xep.LEGAL_ENTITY_ID=org.LEGAL_ENTITY) "LE Name"
        ,haou.attribute17 "Type"
        ,haou.attribute11 "ERP"
        ,org.DISABLE_DATE
    from apps.org_organization_definitions org, apps.gl_sets_of_books BKD, hr_all_organization_units haou  
    where org.organization_id = haou.organization_id
    and SUBSTR(haou.attribute13,1, (instr(haou.attribute13,'|') -1)) in ('Healthcare')
    and ORG.set_of_books_id = BKD.set_of_books_id
    and org.DISABLE_DATE is null
    and haou.attribute11 is not null
    order by org.ORGANIZATION_ID
	/**/
    	select distinct 
        regexp_substr(haou.attribute13,'[^|]+',1,1) "Business",    
        regexp_substr(haou.attribute13,'[^|]+',1,2) "Pole",
        org.ORGANIZATION_ID, org.ORGANIZATION_NAME, (select * from (select gleb.FLEX_SEGMENT_VALUE from apps.gl_legal_entities_bsvs gleb, apps.org_organization_definitions ods
            where gleb.legal_entity_id = org.LEGAL_ENTITY order by gleb.LAST_UPDATE_DATE desc) where rownum <2) Company_Code
            ,BKD.CURRENCY_CODE
            ,(select xep.name from apps.xle_entity_profiles xep where xep.LEGAL_ENTITY_ID=org.LEGAL_ENTITY) "LE Name"
            ,haou.attribute17 "Type"
            ,haou.attribute11 "ERP"
            ,org.DISABLE_DATE
            ,(select count(pha.segment1) from apps.PO_HEADERS_ALL PHA where PHA.ORG_ID=org.ORGANIZATION_ID
            and TRUNC(pha.creation_date) BETWEEN '01-JAN-2022' and '31-DEC-2022') "count"
            ,case when (select count(pha.segment1) from apps.PO_HEADERS_ALL PHA where PHA.ORG_ID=org.ORGANIZATION_ID
            and TRUNC(pha.creation_date) BETWEEN '01-JAN-2022' and '31-DEC-2022') > 1
            then 'Active'
            else 'Inactive'
            end "Active Status"
        from apps.org_organization_definitions org, apps.gl_sets_of_books BKD, hr_all_organization_units haou  
        where org.organization_id = haou.organization_id
        and SUBSTR(haou.attribute13,1, (instr(haou.attribute13,'|') -1)) in ('Healthcare')
        and ORG.set_of_books_id = BKD.set_of_books_id
        and org.DISABLE_DATE is null
        order by org.ORGANIZATION_ID
        