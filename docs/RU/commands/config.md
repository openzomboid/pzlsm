# Config


## Команды и аргументы
Команда `config` не может быть вызвана без подкоманд или аргумента `--help`.

### Аргументы

  * `--help` - Отображает помощь по использованию команды.

### Команды

  * `pull` - В PZLSM предусмотрена возможность поместить конфиги сервера в git репозиторий. Поддерживается любой git репозиторий, который позволяет скачивать сырые файлы по прямой ссылке с использованием авторизации по token. Для этого нужно в файле конфигурации указать переменные `GITHUB_CONFIG_REPO` и `GITHUB_ACCESS_TOKEN`. В `GITHUB_CONFIG_REPO` нужно указать "[сырую](https://github.com/orgs/community/discussions/22537)" ссылку на корень репозитория с указанием имени ветки. В `GITHUB_ACCESS_TOKEN` нужно указать [токен доступа](https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/creating-a-personal-access-token).

        # GITHUB_CONFIG_REPO contains link to github repo with pz config files.
        # Leave it blank if you don't plan to use this.
        GITHUB_CONFIG_REPO="https://raw.githubusercontent.com/openzomboid/example-config/master"
        
        # GITHUB_ACCESS_TOKEN contains access token for download server configs from GitHub.
        # Leave it blank if you don't plan to use this.
        GITHUB_ACCESS_TOKEN="" 
        
    Команду можно выполнять на запущенном сервере. Для того чтобы изменения были применены, нужно перезапустить сервер.
    
        ./server.sh config pull
