SELECT oi.branchcode,
       oi.auto_renew,  
       COUNT(*) AS Antal,  
       SUM(oi.renewals) AS renewals
  FROM old_issues oi
  JOIN borrowers b
    ON oi.borrowernumber = b.borrowernumber
  JOIN items im
    ON oi.itemnumber = im.itemnumber
 WHERE YEAR(oi.issuedate) = '%%QUERY_YEAR%%'
   AND b.categorycode NOT IN ('BA', 'BE', 'BF', 'BK', 'BL', 'BM', 'EI', 'BN', 'BU')
   AND im.itype NOT IN ('13', '16')
 GROUP BY 1, 2 