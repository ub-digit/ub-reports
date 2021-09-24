SELECT
SUM (CASE
     WHEN substring(cf_008 from 36 for 3) ~ 'swe' THEN 1
     ELSE 0
     END
) AS "svenska",
SUM (CASE
     WHEN substring(cf_008 from 36 for 3) ~ '(rom|yid|9mk|fin|smn|smj|sme|smi|sms|sma)' THEN 1
     ELSE 0
     END
) AS "minoritet",
SUM (CASE
     WHEN substring(cf_008 from 36 for 3) !~ '(rom|yid|9mk|fin|smn|smj|sme|smi|sms|sma|swe)' THEN 1
     ELSE 0
     END
) AS "ovrigt"
FROM biblios
WHERE substring(cf_008 from 24 for 1) !~ '(o|s)'