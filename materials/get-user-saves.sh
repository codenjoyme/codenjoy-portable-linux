docker exec -i codenjoy-database psql -U codenjoy -c "SELECT s.time, s.score, s.save FROM saves AS s WHERE s.player_id = (SELECT u.id FROM users AS u WHERE u.readable_name = '$1') ORDER BY s.time ASC;"