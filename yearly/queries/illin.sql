SELECT branch,
       type,
       callno,
       LOWER(SUBSTRING_INDEX(SUBSTRING(callno, LOCATE('FJÄRR IN ', callno)+9),' ', 1)) AS sigel,
       datetime,
       itemnumber
  FROM ub_statistics
 WHERE DATE(datetime) BETWEEN '%%QUERY_YEAR%%-01-01' AND '%%QUERY_YEAR%%-12-31'
   AND type IN ('issue', 'renew')
   AND itemtype IN ('13', '16')
