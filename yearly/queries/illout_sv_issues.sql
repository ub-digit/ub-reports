SELECT iu.branchcode,
       iu.auto_renew,
       COUNT(*) AS Antal,
       SUM(iu.renewals) AS renewals
  FROM issues iu
  JOIN borrowers b
    ON iu.borrowernumber = b.borrowernumber
 WHERE YEAR(iu.issuedate) = '%%QUERY_YEAR%%'
   AND b.categorycode IN ('BA', 'BE', 'BF', 'BK', 'BL', 'BM', 'EI')
 GROUP BY 1, 2
 