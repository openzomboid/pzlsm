# Команды

## Базовые команды
| Имя команды                                 | Аргументы       | Команда
| ------------------------------------------- | --------------- | --------------------------
| [install](commands/install.md)              | Не обязательные | `./server.sh install`
| [update](commands/update.md)                | Не обязательные | `./server.sh update`
| [config](commands/config.md)                | Обязательные    | `./server.sh config pull`
| [start](commands/start-stop-restart.md)     | Не обязательные | `./server.sh start`
| [stop](commands/start-stop-restart.md)      | Не обязательные | `./server.sh stop`
| [restart](commands/start-stop-restart.md)   | Не обязательные | `./server.sh restart`
| [autorestart](commands/autorestart.md)      |                 | `./server.sh autorestart`
| [console](commands/console.md)              |                 | `./server.sh console`
| [cmd](commands/cmd.md)                      | Обязательные    | `./server.sh cmd`
| [kickusers](commands/kickusers.md)          |                 | `./server.sh kickusers`
| delete_manifest  |                 | `./server.sh delete_manifest`
| delete_zombies   |                 | `./server.sh delete_zombies`
| map_regen        | Обязательные    | `./server.sh map_regen`
| map_copy         | Обязательные    | `./server.sh map_copy`
| map_copyto       | Обязательные    | `./server.sh map_copyto`
| range            | Обязательные    | `./server.sh range`
| backup           | Не обязательные | `./server.sh backup`
| log              | Обязательные    | `./server.sh log`
| сlog             | Обязательные    | `./server.sh сlog`
| sql              | Обязательные    | `./server.sh sql`
| vehicles         |                 | `./server.sh vehicles`
| restore_players  | Обязательные    | `./server.sh restore_players`

## Глобальные аргументы
| Имя аргумента       | Аргумент
| ------------------- | --------------------------
| --variables, --vars | `./server.sh --variables`
| --version           | `./server.sh --version`
| --help              | `./server.sh --help`
