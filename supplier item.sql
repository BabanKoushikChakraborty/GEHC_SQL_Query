Select pha.segment1 "PO_NUMBER",
       pla.item_description,
       pla.VENDOR_PRODUCT_NUM
from apps. PO_HEADERS_ALL pha,
     apps. PO_LINES_ALL pla
where pha.po_header_id=pla.po_header_id
--pha.org_id in
     and pha.segment1 in ('551020034176')
Order by pha.segment1;