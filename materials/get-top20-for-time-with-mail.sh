#example how to use:
#bash get-top20-for-time-with-mail.sh '2020-11-07_17:59:58%'

docker exec -i codenjoy-database psql -U codenjoy -c "SELECT row_number() over(ORDER BY s.score DESC) num, s.time, u.readable_name, u.email, s.score FROM saves AS s INNER JOIN users AS u ON u.id = s.player_id WHERE s.time LIKE '$1%' ORDER BY s.score DESC LIMIT 20;"



