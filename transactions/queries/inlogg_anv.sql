SELECT s.type AS type,
       TRIM(IF(firstname = 'Bokomat', CONCAT(b.firstname,' ', b.surname), 
               IF(b.categorycode = 'TJ', CONCAT(b.firstname,' ', b.surname), 
                  IF(b.categorycode = 'TN', 'Nyförvärvslista', 'Övrig personal')))) AS performer,
       COUNT(*) AS antal
FROM ub_statistics s
JOIN borrowers b
ON s.borrowernumber = b.borrowernumber
WHERE s.type IN ('issue', 'onsite_checkout', 'return')
AND DATE(s.datetime) BETWEEN '%%QUERY_YEAR%%-01-01' AND '%%QUERY_YEAR%%-12-31'
AND s.categorycode IS NOT NULL
GROUP BY 1, 2
ORDER BY 2
