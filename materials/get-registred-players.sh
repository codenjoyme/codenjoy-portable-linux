docker exec -i codenjoy-database psql -U codenjoy -c "SELECT  row_number() OVER(ORDER by city,last_name,first_name) as num, id, first_name, last_name,city,email,phone,skills FROM players;"