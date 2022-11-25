SELECT b.biblionumber AS biblio_id,
  RIGHT(best_intern.value, 1) AS substring,
  i.homebranch,
  i.itype,
  i.permanent_location,
  COUNT(*)
FROM biblio b
JOIN ub_biblio_extra best_intern
  ON b.biblionumber = best_intern.biblionumber
 AND best_intern.label = 'best_intern'
 AND best_intern.value REGEXP 'G[a-z]{0,3}%%QUERY_YEAR_SHORT%%[0-9]{2}(k|f)'
JOIN ub_biblio_extra best_hylla
  ON b.biblionumber = best_hylla.biblionumber
 AND best_hylla.label IN ('best_hylla', 'best_hyllab')
JOIN items i
  ON best_intern.biblionumber = i.biblionumber
 AND SUBSTRING(i.itemcallnumber, 1, 2) COLLATE utf8mb4_general_ci = SUBSTRING(best_hylla.value, 1, 2)
 AND YEAR(i.dateaccessioned) = %%QUERY_YEAR%%
GROUP BY 1, 2, 3, 4, 5
ORDER BY 1, 2, 3, 4, 5