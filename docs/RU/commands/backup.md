# Backup
PZLSM предоставляет несколько команд для создания бекапов сервера. Поддерживаются как полный бекап мира, так и частичные бакапы. 

После каждого успешного бекапа PZLSM удаляет самый старый сделанный бекап. Таким образом происходит ротация бекапав, чтобы они не занимали слишком много места. Временем жизни букапов можно управлять при помощи переменных `CLEAR_BACKUPS_DAY` и `CLEAR_TIME_MACHINE_DAY` в файле конфигурации PZLSM.

## Опции

* `--help` - Выводит помощь по команде.

## Аргументы
Команда `backup {command}` имеет следующие аргументы:

* `fast` - выполняет быстрый бекап всех основных элементов сохранения мира за исключением чанков карты. Во время выполнения бекпа создается архив вида `servername_20220905_190001.tar.gz` в папке `backups/timemachine/`. В файле конфигурации за время жизни этих бекапов отвечает переменная `CLEAR_TIME_MACHINE_DAY`.

      ./server.sh backup fast

* `players` - выполняет быстрый бекап базы даных персонажей `players.db` в папку `backups/players/`. В файле конфигурации за время жизни этих бекапов отвечает переменная `CLEAR_TIME_MACHINE_DAY`.

      ./server.sh backup players

* `world` - выполняет максимально полный бекап всех файлов сохранения мира, включая файлы чанков. Во время выполнения бекпа создается архив вида `servername_20220905_190001.tar.gz` в папке `backups/zomboid/`. В файле конфигурации за время жизни этих бекапов отвечает переменная `CLEAR_BACKUPS_DAY`.

      ./server.sh backup world

* `pzlsd` - выполняет бекап файлов демона pzlsd. Во время выполнения бекпа создается архив вида `servername_pzlsd_20220905_190001.tar.gz` в папке `backups/pzlsd/`. В файле конфигурации за время жизни этих бекапов отвечает переменная `CLEAR_BACKUPS_DAY`.

      ./server.sh backup pzlsd

## Cron task
Команда `backup` может быть добавлена в cron и выполняться регулярно раз в равный промежуток времени

    crontab -e

> Замените **pzuser** на имя вашего пользователя в системе, **pz1** на название папки, в которой установлена игра.

* Выполнять бекап всех персонажей каждые 10 минут.

      */10 * * * * /home/outdead/pz1/server.sh backup players

* Выполнять быстрый бекап всех ключевых элементов сохранения мира, за исключением файлов чанков каждый час.

      0 */1 * * * /home/outdead/pz1/server.sh backup fast

> Не рекомендуется ставить на cron полный бекап чанков карты, так как его лучше выполнять на выключенном сервере. Такой бекап выполняется во время штатных остановок сервера. Подробнее в [start-stop-restart](start-stop-restart.md).
