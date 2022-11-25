SELECT i.branchcode,
       i.auto_renew,
       COUNT(*) AS Antal,
       SUM(i.renewals_count) AS renewals
  FROM issues i
  JOIN borrowers b
    ON (i.borrowernumber = b.borrowernumber
   AND b.categorycode IN ('BN', 'BU'))
 WHERE YEAR(i.issuedate) = '%%QUERY_YEAR%%'
 GROUP BY 1, 2
