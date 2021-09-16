SELECT oi.branchcode,
       oi.auto_renew,
       COUNT(*) AS Antal,
       SUM(oi.renewals) AS renewals
  FROM old_issues oi
  JOIN borrowers b
    ON (oi.borrowernumber = b.borrowernumber
   AND b.categorycode IN ('BN', 'BU'))
 WHERE YEAR(oi.issuedate) = '%%QUERY_YEAR%%'
 GROUP BY 1, 2
