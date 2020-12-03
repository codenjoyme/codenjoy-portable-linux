#example how to use:
#bash get-top20-not-winners.sh '2020-11-07_17:59:58%'


docker exec -i codenjoy-database psql -U codenjoy -c "SELECT row_number() over(ORDER BY s.score DESC) num, s.time, s.score, s.winner, s.id,
p.first_name, p.last_name, p.city, p.email, p.phone, p.skills
FROM scores AS s
INNER JOIN players AS p ON p.id = s.id
WHERE (s.time LIKE '$1%')
AND (s.winner=0)
AND (s.id NOT IN (SELECT id from scores where winner=1))
ORDER BY s.score DESC LIMIT 20;"
