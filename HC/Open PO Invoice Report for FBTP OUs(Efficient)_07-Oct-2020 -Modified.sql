WITH
 FUNCTION get_approval_status(
                 l_invoice_id               IN NUMBER,
                 l_invoice_amount           IN NUMBER,
                 l_payment_status_flag      IN VARCHAR2,
                 l_invoice_type_lookup_code IN VARCHAR2)
    RETURN VARCHAR2 IS

      invoice_approval_status       VARCHAR2(25);
      invoice_approval_flag         VARCHAR2(2);
      distribution_approval_flag    VARCHAR2(1);
      encumbrance_flag              VARCHAR2(1);
      invoice_holds                 NUMBER;
      cancelled_date                DATE;
      sum_distributions             NUMBER;
      dist_var_hold                 NUMBER;
      match_flag_cnt                NUMBER;
      self_match_flag_cnt           NUMBER; --Bug8223290
      l_validated_cnt               NUMBER;
      l_org_id                      FINANCIALS_SYSTEM_PARAMS_ALL.ORG_ID%TYPE;
      l_force_revalidation_flag     VARCHAR2(1);
      --Bugfix: 3854385
      l_dist_variance		    VARCHAR2(20) := 'DIST VARIANCE';
      l_line_variance		    VARCHAR2(20) := 'LINE VARIANCE';

       --9503673
      l_net_of_retainage_flag       VARCHAR2(1);
      l_retained_amt                NUMBER := 0;
   N_flag_count                  NUMBER;
        Z_flag_count                  NUMBER;
        A_flag_count                  NUMBER;
        T_flag_count                  NUMBER;

        cursor status_cnt_cur(l_status varchar2) IS
        select sum(l_count)
        from
        (
        SELECT count(*) l_count
        FROM   ap_invoice_distributions_all
        WHERE  invoice_id = l_invoice_id
          AND nvl(match_status_flag, 'Z') = l_status
        UNION
        SELECT count(*) l_count
        FROM   ap_self_Assessed_tax_dist_All
        WHERE  invoice_id = l_invoice_id
         AND nvl(match_status_flag, 'Z') = l_status
        );
        /* Bug 13608357 end */
    BEGIN


      SELECT NVL(fsp.purch_encumbrance_flag,'N'),
             ai.org_id,
	     ai.force_revalidation_flag,
	     NVL(ai.net_of_retainage_flag,'N')  --9503673
      INTO encumbrance_flag,
           l_org_id,
	   l_force_revalidation_flag,
	   l_net_of_retainage_flag   --9503673
      FROM ap_invoices_all ai,
           financials_system_params_all fsp
      WHERE ai.invoice_id = l_invoice_id
      AND ai.set_of_books_id = fsp.set_of_books_id
      AND ai.org_id = fsp.org_id;

         ---------------------------------------------------------------------
         -- Get the number of holds for the invoice
         --
      SELECT count(*)
      INTO   invoice_holds
      FROM   ap_holds_all
      WHERE  invoice_id = l_invoice_id
      AND    release_lookup_code is NULL;

        SELECT count(*)
      INTO   dist_var_hold
      FROM   ap_holds_all
      WHERE  invoice_id = l_invoice_id
      AND    hold_lookup_code IN  (l_dist_variance, l_line_variance)
      AND    release_lookup_code is NULL;

         ---------------------------------------------------------------------
         -- If invoice is cancelled, return 'CANCELLED'.
         --
      SELECT ai.cancelled_date
      INTO   cancelled_date
      FROM   ap_invoices_all ai
      WHERE  ai.invoice_id = l_invoice_id;

      IF (cancelled_date IS NOT NULL) THEN
        RETURN('CANCELLED');
      END IF;

       SELECT count(*)
      INTO match_flag_cnt
      FROM ap_invoice_distributions_all aid
      WHERE aid.invoice_id = l_invoice_id
      AND aid.match_status_flag IS NOT NULL
      AND rownum < 2;

      SELECT count(*) --Bug8223290
      INTO self_match_flag_cnt
      FROM ap_self_assessed_tax_dist_all aid
      WHERE aid.invoice_id = l_invoice_id
      --AND aid.match_status_flag IS NOT NULL
      AND rownum < 2;

            invoice_approval_flag := 'X';

     IF match_flag_cnt > 0 OR self_match_flag_cnt > 0 THEN --Bug8223290

        /* Bug 13608357 Main change start*/
       OPEN status_cnt_cur('N');
       FETCH status_cnt_cur into N_flag_count;
       CLOSE status_cnt_cur;

       OPEN status_cnt_cur('Z');
       FETCH status_cnt_cur into Z_flag_count;
       CLOSE status_cnt_cur;

       OPEN status_cnt_cur('T');
       FETCH status_cnt_cur into T_flag_count;
       CLOSE status_cnt_cur;

       OPEN status_cnt_cur('A');
       FETCH status_cnt_cur into A_flag_count;
       CLOSE status_cnt_cur;

       IF    N_flag_count > 0 THEN invoice_approval_flag := 'N';
       ELSIF(Z_flag_count > 0 and T_flag_count = 0 and A_flag_count = 0)  THEN invoice_approval_flag := 'NA';
       ELSIF(Z_flag_count > 0 and (T_flag_count > 0 or A_flag_count > 0)) THEN invoice_approval_flag := 'N';
       ELSIF(T_flag_count > 0 and (A_flag_count = 0 or  A_flag_count > 0)) THEN invoice_approval_flag := 'T';
       ELSIF(A_flag_count > 0 ) THEN invoice_approval_flag := 'A';
       ELSE invoice_approval_flag := 'X';
       END IF;
        /* Bug 13608357 Main change end*/
    END IF; -- end of match_flag_cnt

      IF l_force_revalidation_flag = 'Y' THEN
         IF invoice_approval_flag NOT IN ('X','NA') THEN
	    invoice_approval_flag := 'N';
         ELSE
            IF match_flag_cnt > 0 THEN

               SELECT count(*)
                 INTO l_validated_cnt
                 FROM ap_invoice_distributions_all aid
                WHERE aid.invoice_id = l_invoice_id
                  AND aid.match_status_flag = 'N'
                  AND rownum < 2;

               IF l_validated_cnt > 0 THEN
                  invoice_approval_flag := 'N';
               END IF;

            END IF;
         END IF;
      END IF;


     
	IF ((invoice_approval_flag IN  ('A', 'T')) AND
            (dist_var_hold = 0)) THEN

          BEGIN

           SELECT 'N'
           INTO invoice_approval_flag
           FROM ap_invoice_lines_all ail
           WHERE ail.invoice_id = l_invoice_id
           AND ail.amount <>
             ( SELECT NVL(SUM(NVL(aid.amount,0)),0)
      	       FROM ap_invoice_distributions_all aid
	       WHERE aid.invoice_id = ail.invoice_id
	       AND   aid.invoice_line_number = ail.line_number
	       --bugfix:4959567
               AND   ( aid.line_type_lookup_code <> 'RETAINAGE'
                        OR (ail.line_type_lookup_code = 'RETAINAGE RELEASE' AND
                            aid.line_type_lookup_code = 'RETAINAGE') )
               /*
	       AND   (ail.line_type_lookup_code <> 'ITEM'
	              OR (aid.line_type_lookup_code <> 'PREPAY'
	                  and aid.prepay_tax_parent_id IS  NULL)
                     )
               */
	       AND   (AIL.line_type_lookup_code NOT IN ('ITEM', 'RETAINAGE RELEASE')
                      OR (AIL.line_type_lookup_code IN ('ITEM', 'RETAINAGE RELEASE')
                          AND (AID.prepay_distribution_id IS NULL
                               OR (AID.prepay_distribution_id IS NOT NULL
                                   AND AID.line_type_lookup_code NOT IN ('PREPAY', 'REC_TAX', 'NONREC_TAX')))))
	       );

           EXCEPTION WHEN OTHERS THEN
              NULL;
           END;

         END IF;
  IF ((invoice_approval_flag in ('A', 'T')) AND
            (dist_var_hold = 0))  THEN

          BEGIN

	   SELECT 'N'
           INTO   invoice_approval_flag
           FROM   ap_invoice_lines_all AIL, ap_invoices_all A
           WHERE  AIL.invoice_id = A.invoice_id
           AND    AIL.invoice_id = l_invoice_id
           AND    ((AIL.line_type_lookup_code <> 'TAX'
                   and (AIL.line_type_lookup_code NOT IN ('AWT','PREPAY')
                        or NVL(AIL.invoice_includes_prepay_flag,'N') = 'Y') OR
                  (AIL.line_type_lookup_code = 'TAX'
                  /* bug 5222316 */
                   and (AIL.prepay_invoice_id IS NULL
                        or (AIL.prepay_invoice_id is not null
                            and NVL(AIL.invoice_includes_prepay_flag, 'N') = 'Y')))))
               --    and AIL.prepay_invoice_id IS NULL)))
           GROUP BY A.invoice_id, A.invoice_amount, A.net_of_retainage_flag
           HAVING A.invoice_amount <>
                  nvl(SUM(nvl(AIL.amount,0) + decode(A.net_of_retainage_flag,
                                 'Y', nvl(AIL.retained_amount,0),0)),0);

           EXCEPTION WHEN OTHERS THEN
              NULL;
           END;

         END IF;

      IF ((invoice_approval_flag in ('A', 'T')) AND
            (dist_var_hold = 0))  THEN

          BEGIN

	   SELECT 'N'
             INTO invoice_approval_flag
             FROM ap_invoice_lines_all AIL
            WHERE AIL.invoice_id = l_invoice_id
	      AND NVL( AIL.discarded_flag, 'N' ) <> 'Y'
              AND NVL( AIL.cancelled_flag, 'N' ) <> 'Y'
              AND (AIL.AMOUNT <> 0 OR
                  (AIL.AMOUNT = 0 AND AIL.GENERATE_DISTS ='Y')) --ADDED 21907761
              AND NOT EXISTS (SELECT 'distributed line'
                                FROM AP_INVOICE_DISTRIBUTIONS_ALL D5
                               WHERE D5.INVOICE_ID = AIL.INVOICE_ID
                                 AND D5.INVOICE_LINE_NUMBER = AIL.LINE_NUMBER);

           EXCEPTION WHEN OTHERS THEN
              NULL;
           END;

        END IF;


        IF (encumbrance_flag = 'N') THEN
        IF (invoice_approval_flag IN ('A','T') AND invoice_holds = 0) THEN
          invoice_approval_status := 'APPROVED';
        ELSIF ((invoice_approval_flag IN ('A','T') AND invoice_holds > 0) OR
               (invoice_approval_flag = 'N')) THEN
          invoice_approval_status := 'NEEDS REAPPROVAL';
        ELSIF (dist_var_hold >= 1) THEN
          invoice_approval_status := 'NEEDS REAPPROVAL';
        ELSIF (invoice_approval_flag IN ('X','NA') AND dist_var_hold = 0) THEN
                invoice_approval_status := 'NEVER APPROVED';
        END IF;
      END IF;

         ---------------------------------------------------------------------
         -- If this a prepayment, find the appropriate prepayment status
         --

      RETURN(invoice_approval_status);
    END;
FUNCTION gecm_inv_status_fnc(p_invoice_id NUMBER,
				v_invoice_amount ap_invoices_all.invoice_amount%TYPE, 
				v_payment_status_flag ap_invoices_all.payment_status_flag%TYPE,
				v_invoice_type_lookup_code ap_invoices_all.invoice_type_lookup_code%TYPE, 
				v_wfapproval_status ap_invoices_all.wfapproval_status%TYPE
				) RETURN VARCHAR2
IS
v_org_id                   NUMBER;
v_validation_status        VARCHAR2(100);
v_hold_reason              VARCHAR2(30);

--
-- Added the release lookup code condition as a part of iFlow Document Viewer Nov P1 Bug Fixes
CURSOR Hold_reason_cur IS
SELECT DECODE(UPPER(hold_lookup_code), 'QTY REC', 'Receipt Required','QTY ORD','Overbilled')
FROM   ap_holds_all
WHERE  invoice_id = p_invoice_id
AND    UPPER(hold_lookup_code) IN ('QTY REC','QTY ORD')
AND    release_lookup_code IS NULL
ORDER BY DECODE( UPPER(hold_lookup_code),'QTY REC',1,2);
--
BEGIN
--
 BEGIN
--
--
 v_validation_status := get_approval_status( p_invoice_id,
                                             v_invoice_amount,
                                             v_payment_status_flag,
                                               v_invoice_type_lookup_code
                                               );
 EXCEPTION WHEN OTHERS THEN
 RETURN NULL;
 END;
--
 OPEN  hold_reason_cur;
 FETCH hold_reason_cur
 INTO  v_hold_reason;
 CLOSE hold_reason_cur;
--
IF v_validation_status ='NEEDS REAPPROVAL' THEN
 IF v_hold_reason IS NOT NULL THEN
  RETURN('OnHold'||' - '||v_hold_reason);
 ELSE
  RETURN  ('OnHold');
 END IF;
END IF;
--
IF v_validation_status ='APPROVED' AND   v_wfapproval_status IN ('MANUALLY APPROVED',
'NOT REQUIRED','WFAPPROVED') AND NVL(v_payment_status_flag,'N')='Y' THEN
RETURN 'Paid';
--
ELSIF v_validation_status ='APPROVED' AND v_wfapproval_status IN ('MANUALLY APPROVED',
'NOT REQUIRED','WFAPPROVED') THEN
RETURN 'Approved';
END IF;
--
IF v_validation_status <> 'CANCELLED' AND v_wfapproval_status <>'REJECTED' THEN
 RETURN ('In-Process');
END IF;
--
IF v_validation_status='CANCELLED' THEN
 RETURN ('Cancelled');
END IF;
--
IF v_validation_status <> 'CANCELLED' AND v_wfapproval_status='REJECTED' THEN
 RETURN ('Rejected');
END IF;
--
IF  NVL(v_payment_status_flag,'N')!='Y' AND v_validation_status='APPROVED' THEN
 RETURN ('ReadyToPay');
END IF;
--
IF NVL(v_payment_status_flag,'N')='Y' THEN
 RETURN ('Paid');
END IF;
RETURN NULL;
END ;
select   
DISTINCT 
prha.org_id "Org Id"

,prha.INTERFACE_SOURCE_CODE
,hro.name "Org name"

,to_number(prha.segment1) "Requisition Number" 
,to_date(prha.creation_date, 'DD-MON-YY') "Requisition creation Date" 
,prha.authorization_status "PR Status"
,to_number(ph.segment1) "PO Number"
,to_date(ph.creation_date, 'DD-MON-YY')  "PO Creation Date" 
,mcv.category_concat_segs "UNSPSC Code"


,(select distinct ipp.approval_code 
  from apps.gecm_compliance_tbl ipp
   where  ipp.transaction_id=prha.requisition_header_id
  and ipp.transaction_type='REQUISITION'
  AND ROWNUM<2) "Approval Code"
  
  ,ppa.segment1  Project_No
  , prda.ATTRIBUTE11 "Asset Number"
,pl.item_description "Item Description" 


,papf.full_name  Requestor_name
,papf.employee_number "Requestor SSO"


,papf1.full_name "Preparer Name"

,papf1.employee_number "Preparer SSO"

, ph.closed_code "PO Status"

,ph.type_lookup_code "Type"

--,ph.ATTRIBUTE7 "PO_Payment Method"  

,ph.authorization_status "PO authorization Status"


,to_date(pll.need_by_date, 'DD-MON-YY') "NEED_BY_DATE" 


,gcc.concatenated_segments charge_account 
,pl.line_num "PO Line Number"

,nvl(pl.unit_price,pll.price_override) "Unit Price" 
,ph.currency_code 
,decode(pvs.pay_on_code,
        'RECEIPT','ERS',
        pvs.pay_on_code)PAY_ON_CODE


,round((pd.quantity_ordered-pd.quantity_cancelled)*pll.Price_Override,2)  "Distribution_Line_Amount" 

,ROUND((case 
when ph.currency_code = 'USD' then 
(pd.quantity_ordered-pd.quantity_cancelled)*pll.Price_Override
else 
(select ((pd.quantity_ordered-pd.quantity_cancelled)*pll.Price_Override)*gdr.conversion_RATE 
from apps.gl_daily_rates gdr 
where to_date(trunc(gdr.CONVERSION_DATE), 'DD-MON-YYYY') = 
to_date(TRUNC(NVL(PH.rate_date, PH.creation_date)),'DD-MON-YYYY')  
and upper(conversion_type) = upper('Corporate') 
and FROM_CURRENCY = ph.currency_code 
and TO_CURRENCY = 'USD') 
end),2) 
 "USD Distribution Amount" 

--,pll.AMOUNT_RECEIVED " Received Amount"


,round(pd.quantity_ordered-pd.quantity_cancelled,2)  "Quantity Ordered" 

--,nvl(pd.quantity_delivered,0) "Quantity Received"

,nvl(pd.quantity_billed,0) "Quantity Billed"

,nvl(pd.quantity_cancelled,0) "Quantity Cancelled"

,nvl(pd.quantity_delivered,0) "Quantity Received"

,ROUND((case when ph.currency_code = 'USD' then (select sum((nvl(pda.quantity_ordered,0)-nvl(pda.quantity_cancelled,0))*nvl(pll.Price_Override,0))
from apps.po_line_locations_all pll,APPS.PO_DISTRIBUTIONS_ALL pda 
 where pda.po_line_id=pll.po_line_id and pda.po_header_id = ph.po_header_id)
else (select sum((nvl(pda.quantity_ordered,0)-nvl(pda.quantity_cancelled,0))*(nvl(pll.Price_Override,0)*NVL(gdr.conversion_RATE,0))) 
 from apps.gl_daily_rates gdr ,apps.po_line_locations_all pll,APPS.PO_DISTRIBUTIONS_ALL pda 
 where pda.po_line_id=pll.po_line_id 
 and pda.po_header_id = ph.po_header_id 
 and to_date(trunc(gdr.CONVERSION_DATE),'DD-MON-YYYY')= to_date(TRUNC(NVL(PH.rate_date, PH.creation_date)),'DD-MON-YYYY') 
 and upper(conversion_type) = upper('Corporate') and FROM_CURRENCY = ph.currency_code and TO_CURRENCY = 'USD')end),2)
"Usd TOTAL_AMOUNT" 



,ROUND((case 
when ph.currency_code = 'USD' then 
(select sum(pda.quantity_delivered*pll.Price_Override) from apps.po_line_locations_all 
pll,APPS.PO_DISTRIBUTIONS_ALL pda
where pda.po_line_id=pll.po_line_id and pda.po_header_id = ph.po_header_id)

else 
(select sum(pda.quantity_delivered*pll.Price_Override*gdr.conversion_RATE) 
from apps.gl_daily_rates gdr ,apps.po_line_locations_all pll,APPS.PO_DISTRIBUTIONS_ALL pda
where pda.po_line_id=pll.po_line_id and pda.po_header_id = ph.po_header_id and
to_date(trunc(gdr.CONVERSION_DATE), 'DD-MON-YYYY') = 
to_date(TRUNC(NVL(PH.rate_date, PH.creation_date)),'DD-MON-YYYY') 
and upper(conversion_type) = upper('Corporate') 
and FROM_CURRENCY = ph.currency_code 
and TO_CURRENCY = 'USD' )end),2) "USD_TOTAL_AMT_RECEIVED" 


  
--   ,(select sum(pda.quantity_delivered*pll.Price_Override) from apps.po_line_locations_all 
--pll.APPS.PO_DISTRIBUTIONS_ALL pda
-- where pda.po_line_id=pll.po_line_id and pda.po_header_id = ph.po_header_id)  
--"TOTAL_RECEIVED_AMT"

--,(nvl(pl.quantity,0)*pl.unit_price)"Total Amount"

,to_date(ph.approved_date, 'DD-MON-YY') "PO Approved Date" 
,to_date(PLL.last_update_date, 'DD-MON-YY') "PO_Last_Update_Date" 


 
,pv.vendor_name "Supplier Name" 
,pv.segment1 "Supplier Number" 
--,pv.segment1||pvs.attribute14 "GSL" 
,PVS.VENDOR_SITE_CODE "Supplier Site" 
,CASE WHEN pvs.inactive_date IS NULL 
       THEN 'ACTIVE'
       ELSE 'IN-ACTIVE'
END AS SUPPLIER_SITE_STATUS

,(pvs.ADDRESS_LINE1||''||pvs.ADDRESS_LINE2||''||
pvs.ADDRESS_LINE3||''|| pvs.STATE||''||pvs.ZIP) "Address"

,pvs.CITY "City"

,pvs.COUNTRY "Country"

--,(select name from apps.ap_terms where term_id = pvs.TERMS_ID) "Payment_terms"
,(select name from apps.ap_terms where term_id = ph.TERMS_ID) "PO Payment_terms"

,pll.closed_code "Shipment_Status"
,prla.suggested_vendor_product_code "Supplier Item Number"

--------------------------------------------------------------------------------------------------------------
,ai.invoice_num invoiceNum,
  ai.invoice_amount invoiceAmount,
  to_date(ai.invoice_date, 'DD-MON-YY') invoiceDate ,
  ai.invoice_type_lookup_code invoiceType,
  gecm_inv_status_fnc(
        ai.invoice_id,
        ai.invoice_amount , 
				ai.payment_status_flag ,
				ai.invoice_type_lookup_code , 
				ai.wfapproval_status

    )          invValidationStatus,
  
  ai.AUTHORIZED_BY Authorizer,
  TO_CHAR(apsa.discount_amount_available) discountAmount ,
  to_date(apsa.discount_date, 'DD-MON-YY') discountDate,
  to_date(apsa.due_date, 'DD-MON-YY') AS invoiceDueDate,
  ifv.document_id iFlowNumber
,ggr.ar_number "AR Number"
,PRLA.attribute12 "SUB-AR Number"


--(select pvs1.VENDOR_SITE_CODE from apps.po_vendor_sites_all pvs1 where ai.vendor_site_id = pvs1.vendor_site_id)

--------------------------------------------------------------------------------------------------------------
--,prha.Attribute5


from  
apps.po_requisition_headers_all prha, 
PA_PROJECTS_all ppa,
apps.po_requisition_lines_all prla, 
apps.po_req_distributions_all prda, 
apps.gl_code_combinations_kfv gcc, 
apps.po_headers_all ph, 
apps.po_lines_all pl, 
apps.po_line_locations_all pll, 
apps.po_distributions_all pd, 
apps.po_vendors pv, 
apps.po_vendor_sites_all pvs, 
apps.per_all_people_f papf1,
apps.per_all_people_f papf,
apps.hr_operating_units  hro,
apps.mtl_categories_v mcv,
ap_invoices_all ai ,
ap_invoice_distributions_all aida, 
ap_payment_schedules_all apsa,
iflow.ifl_doc_v ifv
,apps.gecm_gears_data ggr


where prha.requisition_header_id = prla.requisition_header_id 
and prla.requisition_line_id=prda.requisition_line_id 
and ph.po_header_id = pl.po_header_id 
and pl.po_line_id=pll.po_line_id 
and pll.line_location_id=pd.line_location_id
and pd.code_combination_id=gcc.code_combination_id 
and pd.req_distribution_id=prda.distribution_id
and pl.category_id=mcv.category_id 
and pv.vendor_id=pvs.vendor_id 
and ph.vendor_id=pv.vendor_id 
and ph.vendor_site_id=pvs.vendor_site_id 
and ph.org_id=pvs.org_id 
and prha.org_id=ph.org_id
and HRO.ORGANIZATION_ID = PH.ORG_ID
and PAPF1.PERSON_ID = prha.PREPARER_ID
AND ppa.project_id(+) = pd.project_id
and papf.person_id = pd.deliver_to_person_id
AND ggr.sub_ar_number(+) = PRLA.attribute12
and ggr.INACTIVE_DATE is null
----------------------------------------------------------------------------------------------

AND aida.invoice_id         = ai.invoice_id
AND aida.po_distribution_id = pd.po_distribution_id
and Pd.ORG_ID                  = aida.ORG_ID
AND apsa.invoice_id        = ai.invoice_id
--AND ai.vendor_id          = pv.vendor_id
AND ifv.invoice_id(+)         = ai.INVOICE_ID




----------------------------------------------------------------------------------------------
  
AND SYSDATE BETWEEN NVL(PAPF1.EFFECTIVE_START_DATE, SYSDATE - 1) AND
   NVL(PAPF1.EFFECTIVE_END_DATE, SYSDATE + 1)
AND SYSDATE BETWEEN NVL(PAPF.EFFECTIVE_START_DATE, SYSDATE - 1) AND
   NVL(PAPF.EFFECTIVE_END_DATE, SYSDATE + 1)
-- AND ph.segment1            = '14120017938'
   
and ph.org_id in ('9666',
'9667',
'9990',
'9989',
'9803',
'10052',
'10051',
'10054',
'10055',
'10053')
and ph.closed_code = 'OPEN'

AND TRUNC(PH.CREATION_DATE) BETWEEN  '01-JAN-2015' AND '31-DEC-2022' 


  
   ORDER BY PH.SEGMENT1,
    pl.line_num  ;
