SELECT DISTINCT ai.invoice_num invoiceNum,
  hr.name orgName ,
  pv.vendor_name Supplier ,
  pv.segment1 SupplierNumber ,
  pvs.vendor_site_code Suppliersite,
  ai.DESCRIPTION Description,
  TO_CHAR( ai.invoice_amount,fnd_currency.safe_get_format_mask(ai.invoice_currency_code,30)) invoiceAmount,
  ai.invoice_date invoiceDate ,
  ai.invoice_type_lookup_code invoiceType,
  GECM_INVOICE_APIT_BULK_CSS_PKG.gecm_inv_status_fnc(ai.INVOICE_ID) invValidationStatus,
  
  ai.AUTHORIZED_BY Authorizer,
  TO_CHAR( apsa.discount_amount_available) discountAmount ,
  apsa.discount_date discountDate,
  apsa.due_date AS invoiceDueDate,
  ifv.document_id iFlowNumber
FROM ap_invoices_all ai ,
  ap_invoice_distributions_all aida,
  hr_all_organization_units hr ,
  po_vendors pv ,
  po_vendor_sites_all pvs,
  ap_payment_schedules_all apsa,
  iflow.ifl_doc_v ifv,
  po_headers_all pha,
  po_distributions_all pda
WHERE hr.organization_id    = ai.org_id
AND aida.invoice_id         = ai.invoice_id
AND aida.po_distribution_id = pda.po_distribution_id
AND pha.po_header_id        = pda.po_header_id
AND ai.vendor_site_id       = pvs.vendor_site_id
AND apsa.invoice_id         = ai.invoice_id
AND ai.vendor_id            = pv.vendor_id(+)
AND ifv.invoice_id(+)       = ai.INVOICE_ID
AND pha.segment1            = '14120017938'
AND IFv.attribute1          = 'I'
ORDER BY ai.invoice_date DESC