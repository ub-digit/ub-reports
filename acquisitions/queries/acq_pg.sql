SELECT df1.biblio_id,
  SUBSTRING(sf1.value, char_length(sf1.value), 1),
  i.homebranch,
  i.itype,
  i.location,
  COUNT(*)
FROM datafields df1
JOIN subfields sf1 ON sf1.datafield_id = df1.id
JOIN subfields sf2 ON sf2.datafield_id = df1.id
JOIN items i
  ON (CAST(i.biblionumber AS text) = df1.biblio_id AND SUBSTRING(i.itemcallnumber, 1, 2) = SUBSTRING(sf2.value, 1, 2))
WHERE df1.tag = '852'
  AND sf1.code = 'x'
  AND sf1.value ~ 'G[a-z]{0,3}%%QUERY_YEAR_SHORT%%[0-9]{2}(k|f)'
  AND sf2.code IN ('h','j')
  AND EXTRACT(year FROM i.dateaccessioned) = %%QUERY_YEAR%%
GROUP BY 1, 2, 3, 4, 5
ORDER BY 1, 2, 3, 4, 5