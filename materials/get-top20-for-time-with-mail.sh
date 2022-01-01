#!/usr/bin/env bash

###
# #%L
# Codenjoy - it's a dojo-like platform from developers to developers.
# %%
# Copyright (C) 2012 - 2022 Codenjoy
# %%
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as
# published by the Free Software Foundation, either version 3 of the
# License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public
# License along with this program.  If not, see
# <http://www.gnu.org/licenses/gpl-3.0.html>.
# #L%
###

#example how to use:
#bash get-top20-for-time-with-mail.sh '2020-11-07_17:59:58%'

docker exec -i codenjoy-database psql -U codenjoy -c "SELECT row_number() over(ORDER BY s.score DESC) num, s.time, u.readable_name, u.email, s.score FROM saves AS s INNER JOIN users AS u ON u.id = s.player_id WHERE s.time LIKE '$1%' ORDER BY s.score DESC LIMIT 20;"



