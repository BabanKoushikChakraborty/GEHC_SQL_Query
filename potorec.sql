select distinct pha.segment1 "PO No.", pha.REVISION_NUM "Rev No.", pha.cancel_flag, pha.closed_code "Status", 
 pha.org_id,
 (select 
    organization_name 
    from apps.org_organization_definitions org 
    where org.organization_id = pha.org_id ) "Org name",
    pla.line_num "PO Line No.",
    pll.shipment_num "PO Shipment No.",
    pda.distribution_num  "PO Distribution No.",
    PLA.QUANTITY "Line QTY", PDA.QUANTITY_ORDERED "Dist QTY", PLA.UNIT_PRICE, 
 rsh.receipt_num, rsl.line_num, rsl.QUANTITY_SHIPPED, rsl.QUANTITY_RECEIVED,
      (select sum(rsl.QUANTITY_RECEIVED) from apps.rcv_shipment_lines rsl where pha.po_header_id = rsl.po_header_id
            and rsl.shipment_header_id = rsh.shipment_header_id) "Total Qty received",
            (rsl.QUANTITY_RECEIVED - rsl.QUANTITY_SHIPPED) "Difference",
	TO_CHAR(pll.need_by_date,'DD-MON-YYYY HH24:MI:SS') "Need by Date"
 
from 
  apps.PO_HEADERS_ALL PHA,
  APPS.PO_LINES_ALL PLA,
  APPS.PO_DISTRIBUTIONS_ALL PDA,
  apps.po_line_locations_all pll,
  apps.rcv_transactions rt ,  
  APPS.RCV_SHIPMENT_HEADERS RSH,
  apps.RCV_SHIPMENT_LINES RSL
where 
  /*pha.po_header_id = rsl.po_header_id (+)
  and rsl.shipment_header_id = rsh.shipment_header_id (+)
  and pha.po_header_id = pl.po_header_id 
  and pl.po_line_id=pll.po_line_id 
  and pll.line_location_id=pd.line_location_id 
  */
  PLA.ORG_ID = PHA.ORG_ID
  and PLA.PO_HEADER_ID = PHA.PO_HEADER_ID
  and PDA.PO_LINE_ID=PLA.PO_LINE_ID
  AND PLL.PO_HEADER_ID=PLA.PO_HEADER_ID
  AND PLL.PO_LINE_ID=PLA.PO_LINE_ID 
  AND RSL.PO_HEADER_ID(+)=PHA.PO_HEADER_ID
  AND RSL.PO_LINE_ID(+)=PLA.PO_LINE_ID 
  and RSL.PO_DISTRIBUTION_ID(+)=PDA.PO_DISTRIBUTION_ID 
  and RSH.SHIPMENT_HEADER_ID(+)=RSL.SHIPMENT_HEADER_ID 
  AND RT.SHIPMENT_LINE_ID(+) = RSL.SHIPMENT_LINE_ID
  AND rsh.shipment_header_id(+) = rt.shipment_header_id
  AND rt.po_header_id(+) = pla.po_header_id
  AND rt.po_line_id(+) = pla.po_line_id
  and pha.segment1=trim('&n')
  order by pla.line_num,pda.distribution_num,rsh.receipt_num;