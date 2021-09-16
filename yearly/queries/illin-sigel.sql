SELECT LOWER(SUBSTRING_INDEX(
    SUBSTRING(callno, LOCATE('FJÄRR IN ', callno)+9),
    ' ', 1)),
    COUNT(*)
  FROM ub_statistics
 WHERE itemtype IN ('13', '16')
   AND type = 'issue'
 GROUP BY 1
 ORDER BY 2
;
