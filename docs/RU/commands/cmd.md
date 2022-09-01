# CMD
Команда `cmd` выполняет игровую команду на сервере. По умолчанию используется rcon протокол. Но можно отправить запрос в [screen сессию](console.md).  

## Аргументы

  * `-r|--rcon` - Использует протокол rcon. Ответ на команду отображается в терминале. Используется по умолчанию.
  * `-s|--screen` - Вызывает команду в консоли игры через сессию в screen. Ответ на команду не выводится в терминале. чтобы увидеть ответ, нужно открыть [консоль](console.md).

## Команды

    ./server.sh cmd command
    ./server.sh cmd "command with spaces"
    ./server.sh cmd -s command

## Доступные игровые команды
Список доступных команд пополняется с обновлениями игры. Чтобы посмотреть актуальный список, выполните запрос:

    ./server.sh cmd help

В ответ на нее будет выведено сообщение:
```text
List of server commands : 
* additem : Give an item to a player. If no username is given then you will receive the item yourself. Count is optional. Use: /additem "username" "module.item" count. Example: /additem "rj" Base.Axe 5
* adduser : Use this command to add a new user to a whitelisted server. Use: /adduser "username" "password"
* addvehicle : Spawn a vehicle. Use: /addvehicle "script" "user or x,y,z", ex /addvehicle "Base.VanAmbulance" "rj"
* addxp : Give XP to a player. Use /addxp "playername" perkname=xp. Example /addxp "rj" Woodwork=2
* alarm : Sound a building alarm at the Admin's position. (Must be in a room)
* banid : Ban a SteamID. Use /banid SteamID
* banuser : Ban a user. Add a -ip to also ban the IP. Add a -r "reason" to specify a reason for the ban. Use: /banuser "username" -ip -r "reason". For example: /banuser "rj" -ip -r "spawn kill"
* changeoption : Change a server option. Use: /changeoption optionName "newValue"
* chopper : Place a helicopter event on a random player
* createhorde : Spawn a horde near a player. Use : /createhorde count "username". Example /createhorde 150 "rj" Username is optional except from the server console. With no username the horde will be created around you
* createhorde2 : UI_ServerOptionDesc_CreateHorde2
* godmod : Make a player invincible. If no username is set, then you will become invincible yourself. Use: /godmode "username" -value, ex /godmode "rj" -true (could be -false)
* gunshot : Place a gunshot sound on a random player
* help : Help
* invisible : Make a player invisible to zombies. If no username is set then you will become invisible yourself. Use: /invisible "username" -value, ex /invisible "rj" -true (could be -false)
* kick : Kick a user. Add a -r "reason" to specify a reason for the kick. Use: /kickuser "username" -r "reason"
* lightning : Use /lightning "username", username is optional except from the server console
* log : Set log level. Use /log %1 %2
* noclip : Makes a player pass through walls and structures. Toggles with no value. Use: /noclip "username" -value. Example /noclip "rj" -true (could be -false)
* players : List all connected players
* quit : Save and quit the server
* releasesafehouse : Release a safehouse you own. Use /releasesafehouse
* reloadlua : Reload a Lua script on the server. Use /reloadlua "filename"
* reloadoptions : Reload server options (ServerOptions.ini) and send to clients
* removeuserfromwhitelist : Remove a user from the whitelist. Use: /removeuserfromwhitelist "username"
* removezombies : UI_ServerOptionDesc_RemoveZombies
* replay : Record and play replay for moving player. Use /replay "playername" -record|-play|-stop filename. Example: /replay user1 -record stadion.bin
* save : Save the current world
* servermsg : Broadcast a message to all connected players. Use: /servermsg "My Message"
* setaccesslevel : Set access level of a player. Current levels: Admin, Moderator, Overseer, GM, Observer. Use /setaccesslevel "username" "accesslevel". Example /setaccesslevel "rj" "moderator"
* showoptions : Show the list of current server options and values.
* startrain : Starts raining on the server. Use /startrain "intensity", optional intensity is from 1 to 100
* startstorm : Starts a storm on the server. Use /startstorm "duration", optional duration is in game hours
* stats : Set and clear server statistics. Use /stats none|file|console|all period. Example /stats file 10
* stoprain : Stop raining on the server
* stopweather : Stop weather on the server
* teleport : Teleport to a player. Once teleported, wait for the map to appear. Use /teleport "playername" or /teleport "player1" "player2". Example /teleport "rj" or /teleport "rj" "toUser"
* teleportto : Teleport to coordinates. Use /teleportto x,y,z. Example /teleportto 10000,11000,0
* thunder : Use /thunder "username", username is optional except from the server console
* unbanid : Unban a SteamID. Use /unbanid SteamID
* unbanuser : Unban a player. Use /unbanuser "username"
* voiceban : Block voice from user "username". Use /voiceban "username" -value. Example /voiceban "rj" -true (could be -false)
```
