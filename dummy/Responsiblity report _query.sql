SELECT DISTINCT haou.organization_id,  
	   haou.name org_name,  
	   SUBSTR(haou.attribute13,1,(INSTR(haou.attribute13,'|')-1)) AS "Org_Business",  
	   frt.responsibility_name,   
	   ---------------------------------------------------------------------------
	   resp.responsibility_key "Responsibility Key",
	   ---------------------------------------------------------------------------------------
	   (SELECT DISTINCT fpov.profile_option_value VALUE 
        FROM fnd_profile_options fpo, 
			 fnd_profile_option_values fpov, 
			 fnd_profile_options_tl fpot, 
			 fnd_responsibility frsp 
		WHERE fpo.profile_option_id = fpov.profile_option_id 
          AND fpo.profile_option_name = fpot.profile_option_name 
          AND fpot.user_profile_option_name IN ('GESSS Secure Responsibility') 
          AND frsp.application_id = fpov.level_value_application_id 
          AND frsp.responsibility_id = fpov.level_value 
          AND frsp.responsibility_id =frt.responsibility_id
       ) Responsibility_Secured,
	   ------------------------------------------------------------------------------------------------------------------------           
	   fu.user_name                         AS Oracle_User_Name, 
	   --------------------------------------------------------------------------------------------------------------------------
	   (SELECT fpov.profile_option_value
		FROM fnd_profile_options fpo,
			 fnd_profile_option_values fpov
		WHERE fpov.profile_option_id = fpo.profile_option_id
		  AND fpo.profile_option_name = 'GECM_UMX_USER_TYPES'
		  AND fpov.level_value = fu.user_id
		  AND fpov.level_id = 10004) user_type,   
	   ----------------------------------------------------------------------------------------------------------------------
	   TO_CHAR(fu.start_date,'DD-MON-RRRR') AS USER_VALID_FROM,     
	   TO_CHAR(fu.end_date,'DD-MON-RRRR')   AS ORACLE_USER_END_date,  
	   TO_CHAR(furg.end_date,'DD-MON-RRRR') AS USER_RESPONSIBILITY_END_DATE,      
	   TO_CHAR(fu.last_logon_date,'DD-MON-RRRR')AS LAST_LOON_DATE,  
	   fu.email_address  ,       
	   ppf.employee_number "SSO ID",        
	   TO_CHAR(fu.creation_date,'DD-MON-RRRR') CREATION_DATE,      
	   ppf.first_name                       AS EMPLOYEE_FIRST_NAME ,      
	   ppf.last_name                        AS EMPLOYEE_LAST_NAME ,      
	   TO_CHAR(ppf.effective_start_date,'DD-MON-RRRR')  AS EMPLOYEE_START_DATE,      
	   TO_CHAR(ppf.effective_end_date,'DD-MON-RRRR') AS EMPLOYEE_END_DATE,     
	   ----------------------------------------------------------------------------------------------------------------------- -----
	   ppf.attribute1 EMP_IFG,      
	   gdf.attribute40 EMP_IFG_EXT,
	   -----------------------------------------------------------------------------------------------------------------------------
	   ppf.attribute2 EMP_BUSINESS,      
	   -----------------------------------------------------------------------------------------------------------------------------
	   ppf.attribute3 EMP_SUBBUSINESS , 
	   gdf.attribute42 EMP_SUBBUSINESS_EXT,
	   -----------------------------------------------------------------------------------------------------------------------------
	   (SELECT hr.business_group_name
		FROM hrfv_business_groups hr 
		WHERE ppf.business_group_id=hr.business_group_id(+)) EMP_BUSINESS_GROUP,
	   gdf.attribute38 EMP_GE_INTERNAL_ORGANIZATION,
	   ------------------------------------------------------------------------------------------------------------------------------------------
	   (SELECT SUBSTR(concatenated_segments,1,INSTR(concatenated_segments,'.')-1)  
		FROM gl_code_combinations_kfv gcc 
		WHERE gcc.code_combination_id =paa.default_code_comb_id ) AS "Employee BLE",  
	   ------------------------------------------------------------------------------------------------------------------------------------------    
	   ppf.current_employee_flag ,
	   -----------------------------------------------------------------------------------------------------------------------------------------      
	   gdf.attribute27   EMP_JOB_FUNCTION_EXT,
	   (SELECT name FROM per_jobs PS WHERE PS.job_id=paa.job_id ) AS "SSP Job Band",
	   -----------------------------------------------------------------------------------------------------------------------------------------
	   paa.default_code_comb_id ,  
	   c.full_name "Supervisor Full Name" , 
	   c.employee_number "Supervisor SSO" ,
	   c.email_address "Supervisor EMAIL",
	   gdf.attribute20 SUPERVISOR_SSO_EXT ,
--	   (SELECT ppf.email_address FROM per_all_people_f ppf WHERE GDF.ATTRIBUTE20=ppf.employee_number) "Supervisor EMAIL EXT",
	   -------------------------------------------------------------------------------------------------------------------------------------        
       TO_CHAR((SELECT MAX(creation_date)
		FROM po_requisition_lines_all prl   
        WHERE prl.to_person_id=ppf.person_id 
        ),'DD-MON-RRRR')AS "Last Req Date(Requester)",    
	   --------------------------------------------------------------------------------------------------------------------------------------       
       TO_CHAR((SELECT MAX(creation_date)
		FROM po_requisition_headers_all prh  
        WHERE prh.preparer_id =ppf.person_id  
       ),'DD-MON-RRRR')AS "Last Req Date(preparer)",  
	   -----------------------------------------------------------------------------------------------------------------------------------------        
	   TO_CHAR((SELECT MAX(action_date)   
		FROM po_action_history pah   
		WHERE action_code='APPROVE'   
		  AND ppf.person_id =pah.employee_id  
	   ),'DD-MON-RRRR') AS "Last Req Date(Approver)",
	   ---------------------------------------------------------------------------------------------------------------------------------------
	  TO_CHAR((SELECT MAX(creation_date)
		FROM po_distributions_all pd   
		WHERE pd.deliver_to_person_id=ppf.person_id  
       ),'DD-MON-RRRR')AS "Last PO Date (requestor)" 
       -------------------------------------------------------------------------------------------------------------------------------      
FROM FND_USER FU,      
	 FND_USER_RESP_GROUPS_DIRECT FURG,      
	 FND_RESPONSIBILITY_TL FRT,    
	 (SELECT responsibility_id,responsibility_key
	  FROM fnd_responsibility
	  WHERE (end_date IS NULL OR end_date >=TRUNC(SYSDATE))) resp,   
	 PER_ALL_PEOPLE_F PPF,             
	 fnd_profile_options fpo,      
	 fnd_profile_option_values fpov,      
	 hr_all_organization_units haou,  
	 (SELECT * FROM per_all_assignments_f
	  WHERE TRUNC(SYSDATE) BETWEEN NVL(effective_start_date,SYSDATE-1) AND NVL(effective_end_date,SYSDATE+1)
	    AND assignment_status_type_id=1) paa,       
	 (SELECT * FROM per_all_people_f WHERE (TRUNC(SYSDATE) BETWEEN effective_start_date AND effective_end_date)) c, 
	 (SELECT * FROM gecm_dff_ext gdf WHERE gdf.primary_table ='PER_ALL_PEOPLE_F') gdf
WHERE ppf.employee_number   =gdf.primary_key(+)
  AND fu.user_id     = furg.user_id  
  AND ppf.person_id(+) = fu.employee_id 
  AND furg.responsibility_id = frt.responsibility_id 
  AND TRUNC(NVL(fu.end_date,SYSDATE+1))>=TRUNC(SYSDATE)       
  AND NVL(furg.end_date,TRUNC(SYSDATE)) >= TRUNC(sysdate)   
  AND TRUNC(SYSDATE) BETWEEN NVL(ppf.effective_start_date,SYSDATE - 1) AND NVL(ppf.effective_end_date,SYSDATE + 1)   
  AND (fu.employee_id IS NULL OR (fu.employee_id IS NOT NULL AND NVL(ppf.current_employee_flag,'N') = 'Y'))
  AND frt.LANGUAGE   = USERENV('LANG')      
  AND fpo.profile_option_name    ='ORG_ID'  
  AND TO_CHAR(haou.organization_id)=fpov.profile_option_value     
  AND fpo.application_id        = fpov.application_id  
  AND Fpov.Profile_Option_Id    = Fpo.Profile_Option_Id   
  AND Fpov.Level_Value          = Frt.Responsibility_Id     
--AND FPOV.level_id=10003   
  AND PPF.person_id = PAA.person_id(+)   
  AND paa.supervisor_id = c.person_id (+)   
  AND frt.responsibility_id=resp.responsibility_id
--AND PPF.EMPLOYEE_NUMBER in ('102002316')
--AND FRT.RESPONSIBILITY_NAME like '%iGate Bank Maintenance%'
  AND SUBSTR(haou.attribute13,1, (instr(haou.attribute13,'|') -1)) in ('Healthcare')
ORDER BY Fu.User_Name,FRT.RESPONSIBILITY_NAME;


