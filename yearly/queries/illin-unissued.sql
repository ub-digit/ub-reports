SELECT itemnumber,
       LOWER(SUBSTRING_INDEX(SUBSTRING(itemcallnumber, LOCATE('FJÄRR IN ', itemcallnumber)+9),' ', 1)) AS sigel
FROM deleteditems
WHERE itype IN ('13', '16')
AND YEAR(dateaccessioned) = '%%QUERY_YEAR%%'
AND datelastborrowed IS NULL
GROUP BY 1
;