

--Check messages, if player is on team T send message to all team T if the message is to allies only
function GameMode:ChatFilter(keys)
  if self.vUserIds[keys.userid] == nil then return false end
  local playerid = self.vUserIds[keys.userid]:GetPlayerID()
  DebugPrint("Message sent - text:"..keys.text.." playerid: "..self.vUserIds[keys.userid]:GetPlayerID().." team only: "..keys.teamonly)
  local text = keys.text
  if keys.userid == -1 then return false end
  local teamonly = keys.teamonly
  local allHeroes = HeroList:GetAllHeroes()
  local player = self.vUserIds[keys.userid]
  local hero = player:GetAssignedHero()

  --Get Players Role
  if text == "-role" then
    if GameMode:PlayerOnI(playerid) then
      Say(player, "I am an Innocent", true)
    elseif GameMode:PlayerOnT(playerid) then
      Say(player, "I am a Traitor", true)
    elseif GameMode:PlayerOnD(playerid) then
      Say(player, "I am a Detective", true)  
    else 
      Say(player, "Roles not assigned yet.", true)
    end

  --Show members of Tteam if on Tteam or if testing
  elseif text == "-team" then
    Tnames = GameMode:GetTNames()
    if GameMode:PlayerOnT(playerid) then
      Say(player, "Players: "..Tnames.."are Traitors", true)
    elseif GameMode:PlayerOnI(playerid) then
      Say(player, "I am an Innocent, cannot see team", true)
    elseif GameMode:PlayerOnD(playerid) then
      Say(player, "I am a Detective, cannot see team", true)
    end

  --Show number of players in the game
  elseif text == "-players" then
    Say(player, "There are "..PlayerResource:GetPlayerCount().."players in this game.", true)

  --T Chat
  elseif string.sub(text,1,2) == "/t" and GameMode:PlayerOnT(playerid) then
    DebugPrint("message to /t")
    for i, v in pairs(TTEAM) do
      Say(PlayerResource:GetPlayer(v), PlayerResource:GetPlayerName(playerid).." said: "..string.sub(text,3  ,-1), true)
    end

  --Dead Chat
  elseif (string.sub(text,1,2) == "/d") and GameMode:PlayerDead(playerid) then
    DebugPrint("message to /d")
    for i, v in pairs(DEAD) do
      Say(PlayerResource:GetPlayer(v), PlayerResource:GetPlayerName(playerid).." said: "..string.sub(text,3  ,-1), true)
    end

  --Warn Dead players they cannot talk
  elseif GameMode:PlayerDead(player) then
    Say(player, "Can only talk to other dead players with /d in allied chat",true)

  end

end