SELECT b.borrowernumber, ba.attribute
  FROM borrowers b
  LEFT JOIN borrower_attributes ba
  ON b.borrowernumber = ba.borrowernumber
  AND ba.code = 'PNR'
  JOIN issues iss
  ON iss.borrowernumber = b.borrowernumber
  AND DATE(iss.issuedate) BETWEEN '%%QUERY_YEAR%%-01-01' AND '%%QUERY_YEAR%%-12-13'
UNION
SELECT b.borrowernumber, ba.attribute
  FROM borrowers b
  LEFT JOIN borrower_attributes ba
  ON b.borrowernumber = ba.borrowernumber
  AND ba.code = 'PNR'
  JOIN old_issues oiss
  ON oiss.borrowernumber = b.borrowernumber
  AND DATE(oiss.issuedate) BETWEEN '%%QUERY_YEAR%%-01-01' AND '%%QUERY_YEAR%%-12-13'
