# discord-powertools

discord-powertools is a collection of powershell scripts to manage your discord server en masse.

## Why powershell?

Powershell runs on any device, and has a large amount of very powerful builtins. Get it [here](https://learn.microsoft.com/en-us/powershell/scripting/install/installing-powershell) from microsoft.

## AddRoleToUsers

**Requires `$DiscordToken` in Vars.ps1**

```powershell
./AddRoleToUsers.ps1 -GuildId <ID of the guild you want to add the role to> -RoleId <ID of role you want to add>
```

Can also take -Remove if you want to remove the role

Reads input from the `-InputFile` (default `./Input/RoleList.txt`)

## ChangeEveryonesNickname

```powershell
./ChangeEveryonesNickname.ps1 -GuildId <ID of the guild you want to nick in> -Nick <name to change to>
```

**Requires `$DiscordToken` in Vars.ps1**

Leave `Nick` blank to reset names

Reads input from the `-InputFile` (default `./Input/NicknameList.txt`)

## Mee6ToUsersTxt

```powershell
./Mee6ToUsersTxt.ps1
```

Reads input from the `-InputFile` (default `./Input/Mee6Leaderboard.json`)

## ScrapeDynoApi

```powershell
./ScrapeDynoApi.ps1 -GuildId <ID of guild whos logs you want to scrape>
```

**Requires `$DynoSid` in Vars.ps1**

You can get your DynoSid from your cookies on [dyno.gg](https://dyno.gg), copy the part after `dynobot.sid=`

## ScrapeMee6Api

```powershell
./ScrapeMee6Api.ps1 -GuildId <ID of guild whos logs you want to scrape> -LastLevel <Level you want to stop once you get all of>
```
