/*
201: Control Purchasing PERIOD
101: Open and Close Period
*/


/*
first check which orgs are not opened yet
after 1st run, change SHOW_STATUS to 'Open' 
O should be  Capital
It will show the org, which are open,
=> conditional format=> search for single org ID ( Orgs in a pair are perfect )
look for application ID, if 101 present, then problem should be in 201 and vice versa
*/


/*
Finally check 2 org list
1st on top: OPEN and close period
2nd below: inventory a/c period
conditional format
remember, SHOW_STATUS should be 'Open' before fetching the report

*/

select * from 
GL_PERIOD_STATUSES_V pp,
apps.org_organization_definitions org
where SHOW_STATUS in ('Never Opened', 'Future - Entry')
AND pp.SET_OF_BOOKS_ID = org.SET_OF_BOOKS_ID
AND ORGANIZATION_ID in('9666',
'9667',
'9990',
'9055',
'9056',
'9142',
'9110',
'9109',
'9139',
'9057',
'9058',
'9097',
'9140',
'9115',
'9159',
'10033',
'9088',
'10030',
'9092',
'9128',
'9121',
'9124',
'9120',
'9131',
'9993',
'9161',
'10035',
'9113',
'9083',
'9137',
'9099',
'9059',
'9168',
'9134',
'9117',
'9095',
'9082',
'10032',
'9155',
'9160',
'9060',
'9153',
'9156',
'9061',
'9162',
'10028',
'9141',
'9174',
'10007',
'9129',
'9062',
'9114',
'9909',
'10031',
'9163',
'9164',
'10018',
'10034',
'9093',
'9154',
'9185',
'9169',
'9939',
'9143',
'9111',
'9112',
'9177',
'9089',
'10029',
'9173',
'9179',
'9910',
'9063',
'9182',
'9187',
'9184',
'9064',
'9065',
'9186',
'9148',
'9106',
'9170',
'9998',
'9152',
'9999',
'9158',
'9126',
'9989',
'9183',
'9803',
'9180',
'9127',
'9176',
'9130',
'9178',
'9150',
'9066',
'9230',
'9105',
'9149',
'9103',
'9971',
'9098',
'9094',
'9090',
'9116',
'9096',
'10009',
'9122',
'9118',
'9165',
'9172',
'9100',
'9107',
'9171',
'10014',
'9231',
'10000',
'9104',
'9101',
'9108',
'9102',
'9167',
'9123',
'9125',
'9132',
'9067',
'9166',
'9944',
'9270',
'9119',
'9268',
'9915',
'9133',
'9138',
'9269',
'9797',
'9879',
'9265',
'9157',
'9151',
'9796',
'9181',
'9146',
'9175',
'9798',
'9267',
'9266',
'9188',
'9145',
'9147',
'9889',
'10038',
'10039',
'10040',
'10041',
'10042',
'10043',
'10044',
'10045',
'10047',
'10048',
'10049',
'10050'
)
AND pp.PERIOD_NAME = 'OCT-19'
AND APPLICATION_ID in ('201','101')

