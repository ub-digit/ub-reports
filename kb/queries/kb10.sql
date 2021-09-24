SELECT
    b.id,
    SUBSTRING(b.leader, 7, 1) AS pos06,
    SUBSTRING(b.leader, 8, 1) AS pos07,
    SUBSTRING(b.cf_008, 30, 1) AS cf8_pos29,
    SUBSTRING(b.cf_008, 24, 1) AS cf8_pos23,
    SUBSTRING(b.cf_008, 25, 3) AS cf8_pos24_27,
    i.itype,
    EXTRACT(YEAR FROM i.dateaccessioned) AS year
FROM biblios b
JOIN items i
  ON CAST(i.biblionumber AS text) = b.id
  AND i.itype NOT IN ('13', '16')
WHERE 1=1
ORDER BY b.id
