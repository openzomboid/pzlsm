# Installation
1. Не работайте под root. Создайте пользователя и перейдите в него. Можно воспользоваться пресетом:

       wget -O user.sh https://raw.githubusercontent.com/outdead/randomutils/master/scripts/user/user.sh && sudo bash user.sh create username password sudo; rm user.sh

   > Не забудьте задать свои значения для **username**, **password** и указать будет ли доступна пользователю привилегия **sudo**.  
   
    Или создать пользователя самостоятельно:

       adduser pz
       su - pz

2. Создать папку для сервера и перейти в нее.

       mkdir pz1 && cd pz1

3. Скачать скрипт `server.sh` из [последнего релиза](https://github.com/openzomboid/pzctl/releases/latest) и поместить его на сервер в только что созданную папку.

       wget -O server.sh https://raw.githubusercontent.com/openzomboid/pzlsm/master/server.sh && chmod +x server.sh

4. Установить зависимости и игровой сервер.

       ./server.sh install

