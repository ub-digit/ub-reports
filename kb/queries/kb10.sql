SELECT
  b.biblionumber AS id,
  leader6.value AS pos06,
  leader7.value AS pos07,
  cf8_29.value AS cf8_pos29,
  cf8_23.value AS cf8_pos23,
  cf8_24_27.value AS cf8_pos24_27,
  i.itype,
  YEAR(i.dateaccessioned)
FROM biblio b
JOIN items i
  ON b.biblionumber = i.biblionumber
 AND i.itype NOT IN ('13', '16')
JOIN ub_biblio_extra leader6
  ON b.biblionumber = leader6.biblionumber
 AND leader6.label = 'rtype'
JOIN ub_biblio_extra leader7
  ON b.biblionumber = leader7.biblionumber
 AND leader7.label = 'biblevel'
JOIN ub_biblio_extra cf8_29
  ON b.biblionumber = cf8_29.biblionumber
 AND cf8_29.label = 'media_29'
JOIN ub_biblio_extra cf8_23
  ON b.biblionumber = cf8_23.biblionumber
 AND cf8_23.label = 'media_23'
JOIN ub_biblio_extra cf8_24_27
  ON b.biblionumber = cf8_24_27.biblionumber
 AND cf8_24_27.label = 'media_24_27'
ORDER BY 1

-- SELECT
--     b.id,
--     SUBSTRING(b.leader, 7, 1) AS pos06,
--     SUBSTRING(b.leader, 8, 1) AS pos07,
--     SUBSTRING(b.cf_008, 30, 1) AS cf8_pos29,
--     SUBSTRING(b.cf_008, 24, 1) AS cf8_pos23,
--     SUBSTRING(b.cf_008, 25, 3) AS cf8_pos24_27,
--     i.itype,
--     EXTRACT(YEAR FROM i.dateaccessioned) AS year
-- FROM biblios b
-- JOIN items i
--   ON CAST(i.biblionumber AS text) = b.id
--   AND i.itype NOT IN ('13', '16')
-- WHERE 1=1
-- ORDER BY b.id
