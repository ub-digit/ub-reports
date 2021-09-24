SELECT COUNT(*) AS antal
FROM datafields df1
INNER JOIN subfields sf1 ON df1.id = sf1.datafield_id
INNER JOIN items i ON df1.biblio_id = CAST(i.biblionumber AS text)
WHERE df1.tag = '082'
AND sf1.code = 'a'
AND sf1.value LIKE '8%'