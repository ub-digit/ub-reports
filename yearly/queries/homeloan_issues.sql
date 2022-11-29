SELECT i.branchcode,
       i.auto_renew,  
       COUNT(*) AS Antal,  
       SUM(i.renewals_count) AS renewals
  FROM issues i
  JOIN borrowers b
    ON i.borrowernumber = b.borrowernumber
  JOIN items im
    ON i.itemnumber = im.itemnumber
 WHERE YEAR(i.issuedate) = '%%QUERY_YEAR%%'
   AND b.categorycode NOT IN ('BA', 'BE', 'BF', 'BK', 'BL', 'BM', 'EI', 'BN', 'BU')
   AND im.itype NOT IN ('13', '16')
 GROUP BY 1, 2 