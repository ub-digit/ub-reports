SELECT 
SUM(CASE
     WHEN biblang.value REGEXP 'swe' THEN 1
     ELSE 0
     END
) AS "svenska",
SUM(CASE
     WHEN biblang.value REGEXP '(rom|yid|9mk|fin|smn|smj|sme|smi|sms|sma)' THEN 1
     ELSE 0
     END
) AS "minoritet",
SUM(CASE
     WHEN biblang.value NOT REGEXP '(rom|yid|9mk|fin|smn|smj|sme|smi|sms|sma|swe)' THEN 1
     ELSE 0
     END
) AS "ovrigt"
FROM biblio b
JOIN ub_biblio_extra biblang
  ON b.biblionumber = biblang.biblionumber
 AND biblang.label = 'biblang'
JOIN ub_biblio_extra cf8_23
  ON b.biblionumber = cf8_23.biblionumber
 AND cf8_23.label = 'media_23'
 AND cf8_23.value REGEXP '(o|s)'

-- SELECT
-- SUM (CASE
--      WHEN substring(cf_008 from 36 for 3) ~ 'swe' THEN 1
--      ELSE 0
--      END
-- ) AS "svenska",
-- SUM (CASE
--      WHEN substring(cf_008 from 36 for 3) ~ '(rom|yid|9mk|fin|smn|smj|sme|smi|sms|sma)' THEN 1
--      ELSE 0
--      END
-- ) AS "minoritet",
-- SUM (CASE
--      WHEN substring(cf_008 from 36 for 3) !~ '(rom|yid|9mk|fin|smn|smj|sme|smi|sms|sma|swe)' THEN 1
--      ELSE 0
--      END
-- ) AS "ovrigt"
-- FROM biblios
-- WHERE substring(cf_008 from 24 for 1) ~ '(o|s)'