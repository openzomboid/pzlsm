# Range
Команда `range` строит регулярное выражение, помогающие искать в логах по диапазону координат. 

Для работы команды нужна внешняя библиотека [regex-range-builder](https://github.com/outdead/regex-range-builder). Для ее установки нужно выполнить команду [install](install.md) с аргументом `utils`.

## Опции

* `--help` - Выводит помощь по команде.

## Аргументы
Команда `range {top} {bottom}` имеет следующие аргументы:

* `top` - верхняя правая XY координата с символом 'x' в качестве разделителя. Например, 10626x10600.
* `bottom` - левая нижняя XY координата с символом 'x' в качестве разделителя. Например, 10679x10661.

```bash
./server.sh range 10626x10600 10679x10661
```

В ответ будет выведено регулярное выражение
```text
(1062[6-9]|106[3-7][0-9]),(106[0-5][0-9]|1066[01])
```

Его можно вставить в аргументы команды [log](log.md) и выполнить поиск внутри заданных координат
```bash
./server.sh log "(1062[6-9]|106[3-7][0-9]),(106[0-5][0-9]|1066[01])"
```
