SELECT 
    DATE_FORMAT(s.datetime, '%Y-%m') AS datum,  
    s.branch AS bibl,  
    s.categorycode AS kategori, 
    CASE WHEN s.type = 'onsite_checkout' THEN 
      'issue'  
    ELSE 
      s.type 
    END AS transaktionstyp, 
    s.itemtype AS exemplartyp, 
    SUBSTRING(location, 1,2) AS agande_bibl, 
    COUNT(*) AS antal 
  FROM ub_statistics s 
  WHERE DATE(s.datetime) BETWEEN '%%QUERY_YEAR%%-01-01' AND '%%QUERY_YEAR%%-12-31' 
    AND s.type IN ('issue', 'renew', 'onsite_checkout') 
  GROUP BY YEAR(s.datetime), MONTH(s.datetime), s.branch, s.categorycode, s.type, s.itemtype, SUBSTRING(location,1,2) 
