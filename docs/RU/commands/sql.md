# SQL
Команда `sql` выполняет SQL запрос на лдной из базы данных сервера. Поддерживаются запросы в общую базу данных whitelist, в базу данных персонажей и автомобилей. По умолчанию запрос выполняется в общей базе данных.

## Опции

* `--db {dbname}` - Выбор базы данных. Можно выбрать одну из следующих баз данных: 
  * `whitelist` - общая база данных. В ней хранится белый список игроков, которым разрешен доступ к серверу и база данных банов. Используется по умолчанию.
  * `players` - база данных игроков.
  * `vehicles` - база данных транспорта.

* `--help` - Отображает помощь по использованию команды.

## Команды

    ./server.sh sql "SELECT * FROM bannedid ORDER BY steamid;"
    ./server.sh sql --db whitelist "SELECT count(*) FROM whitelist;"
    ./server.sh sql --db players "SELECT count(*) FROM networkPlayers;"
    ./server.sh sql --db vehicles "SELECT count(*) FROM vehicles;"

## Ограничения на выполнение запросов
Запросы выборки данных доступны без ограничений и поддерживаются все встроенные функции sqlite. Запросы вставки, редактирования и удаления данных доступны только на выключенном сервере. 

    ./server.sh sql "SELECT steamid, count(username) AS c, group_concat(username) FROM whitelist WHERE steamid != '' GROUP BY steamid HAVING c > 2 ORDER BY c DESC;"

> TODO: Добавить планировщик запросов, чтобы можно было в любой момент внести в список запрос, который будет выполнен во время ближайшего рестарта.
