SELECT oi.branchcode,
       oi.auto_renew,
       COUNT(*) AS Antal,
       SUM(oi.renewals) AS renewals
  FROM old_issues oi
  JOIN borrowers b
    ON oi.borrowernumber = b.borrowernumber
 WHERE YEAR(oi.issuedate) = '%%QUERY_YEAR%%'
   AND b.categorycode IN ('BA', 'BE', 'BF', 'BK', 'BL', 'BM', 'EI')
 GROUP BY 1, 2
