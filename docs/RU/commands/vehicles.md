# Vehicles
PZLSM предоставляет отдельную группу команд для манипуляций с файлом баз данных транспорта `vehicles.db`.

## Глобальные опции
* `--help` - Отображает помощь по использованию команды.

## Команды

### List
Команда `list` отображает координаты всех машин на сервере.

#### Использование
```bash
./server.sh vehicles list
```

### SQL
Команда `sql` выполняет SQL запрос в базе данных транспорта.

#### Использование
```bash
./server.sh vehicles sql {query}
```
```bash
./server.sh vehicles sql "SELECT count(*) FROM vehicles"
```
