SELECT
    b.id,
    SUBSTRING(b.leader, 7, 1) AS pos06,
    SUBSTRING(b.leader, 8, 1) AS pos07,
    SUBSTRING(b.cf_008, 30, 1) AS cf8_pos29,
    SUBSTRING(b.cf_008, 24, 1) AS cf8_pos23,
    SUBSTRING(b.cf_008, 25, 3) AS cf8_pos24_27,
    s.itemtype,
    s.type
FROM biblios b
JOIN ub_statistics s
  ON CAST(s.biblionumber AS text) = b.id
  AND s.itemtype NOT IN ('13', '16')
  AND s.type IN ('issue', 'onsite_checkout', 'renew')
  AND s.categorycode NOT IN ('BA', 'BE', 'BF', 'BK', 'BL', 'BM', 'BN', 'BU', 'EI')
  AND DATE(s.datetime) BETWEEN '%%QUERY_YEAR%%-01-01' AND '%%QUERY_YEAR%%-12-31'
WHERE 1=1
ORDER BY b.id