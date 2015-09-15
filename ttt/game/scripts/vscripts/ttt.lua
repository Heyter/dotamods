--[[== Team Consts ==]]--


PLAYERLIST = {}
TTEAM= {}
ITEAM= {}
DTEAM= {}
DEAD= {}


--[[== ttt libraries ==]]--


--player say library for modifying say rules
require('playersay')
--util library for ttt
require('ttt_util')
--chat filter library for ttt
require('ttt_chatfilter')
--config file for ttt
require('ttt_config')


--[[== Death Fnctions ==]]--


--Disable gold gain from hero kills (short term)
function GameMode:NoHeroGold(filterTable)
  if filterTable["reason_const"] == DOTA_ModifyGold_HeroKill then
    filterTable["gold"] = 0
    return true
  end
  --Otherwise use normal logic
  return false
end

-- Disable hero kills 
function GameMode:RemoveKill(filterTable)
  DebugPrintTable(filterTable)
  local herodamaged = EntIndexToHScript(filterTable.entindex_victim_const)
  local playerdamaged = herodamaged:GetPlayerID()
  local attacker = EntIndexToHScript(filterTable.entindex_attacker_const)
  local attackerid = attacker:GetPlayerID()
  if attackerid ~= playerdamaged then
    PLAYERLIST[attackerid].lasthit = playerdamaged
  end
  --DebugPrintTable(PLAYERLIST)
  if herodamaged:GetHealth() < filterTable.damage then
    DebugPrint("[ttt]kill info: Killed" ,playerdamaged,"killer", attackerid)
    herodamaged:ForceKill(false)
  end
  return true
end

-- Set Death Causer
function GameMode:CauseOfDeath()
  --PLAYERLIST[playerdamaged].causeofdeath = damagingAbility:GetName()
  --local killedUnit = EntIndexToHScript( keys.entindex_killed )
  --killerEntity = EntIndexToHScript( keys.entindex_attacker )
end

-- Set Player to dead team and drop soul
function GameMode:PlayerDied(killedUnit)
  --drop soul
  local newItem = CreateItem( "item_soul", killedUnit, killedUnit )
  newItem:SetPurchaser( killedUnit )
  local pos = killedUnit:GetAbsOrigin()
  local drop = CreateItemOnPositionSync( pos, newItem )
  --dead message
  local player = killedUnit:GetOwner()
  local playerid = player:GetPlayerID()
  local hero = player:GetAssignedHero()
  Say(player, "You can chat to other dead players using /d", true)
  PlayerSay:SendConfig(player, true, false)
  GameMode:AddToDead(playerid)
  -- give dead player vision (needs work)
  AddFOWViewer(player:GetTeam(), hero:GetOrigin(),  20000.0,  600.0, false)
end

-- Game End Kill Condition
function GameMode:EndCondition()
  local twin = true
  local iwin = true
  --check if all T is dead
  for i,v in pairs(TTEAM) do
    local player = PlayerResource:GetPlayer(v)
    local hero = player:GetAssignedHero()
    if hero:IsAlive() then
      iwin = false
    end
  end

  for i,v in pairs(DTEAM) do
    local player = PlayerResource:GetPlayer(v)
    local hero = player:GetAssignedHero()
    if hero:IsAlive() then
      twin = false
    end
  end

  for i,v in pairs(ITEAM) do
    local player = PlayerResource:GetPlayer(v)
    local hero = player:GetAssignedHero()
    if hero:IsAlive() then
      twin = false
    end
  end

  if iwin then
    DebugPrint("[ttt]", "I win the game") 
    GameRules:SetCustomVictoryMessage("Innocents Win")
    return "iwin"
  elseif twin then
    DebugPrint("[ttt]", "T win the game") 
    GameRules:SetCustomVictoryMessage("Terrorists Win")
    return "twin"
  else
    return nil
  end
end


--[[== Game Start Functions ==]]--


-- Assign roles
function GameMode:AssignRoles()
  local players = PlayerResource:GetPlayerCount()
  local tnum = math.floor(players/3)
  --DebugPrint("[ttt]","players", players)
  --DebugPrint("[ttt]","tnum",tnum)
  for i=0,players-1 do
    table.insert(PLAYERLIST,i,{team = "", playerid = i, lasthit = nil , causeofdeath = nil})
    table.insert(ITEAM,i,i)
  end
  --DebugPrintTable(PLAYERLIST)
  --DebugPrintTable(ITEAM)

  -- Assign Players from I to T
  while #TTEAM<tnum do
    local randnum = randomnumber()
    local newT = math.fmod(randnum, #ITEAM)+1
    local v = table.remove(ITEAM,newT)
    if v then
      table.insert(TTEAM,v)
      
    end
  end
  DebugPrintTable(TTEAM)
  --If 8 players or more then add detective
  if players > DETECTIVE_NUMBER then
    local randnum = randomnumber()
    local detective = math.fmod(randnum, #ITEAM)+1
    DebugPrint("detective: ", detective)
    local newd = table.remove(ITEAM, detective)
    table.insert(DTEAM, newd)
  end
  DebugPrintTable(DTEAM)
  
  for i, v in pairs(ITEAM) do 
    DebugPrint("[ttt]", "I",i, v)
    Say(PlayerResource:GetPlayer(v), "I am an Innocent",true)  
  end

  for i, v in pairs(DTEAM) do 
    DebugPrint("[ttt]", "D",i, v)
    local player = PlayerResource:GetPlayer(v)
    local hero = player:GetAssignedHero()
    Say(player, "I am a Detective",true)
    local item = CreateItem("item_scanner", hero, hero)
    hero:AddItem(item)  
  end

  for i, v in pairs(TTEAM) do 
    DebugPrint("[ttt]", "T",i, v) 
    local item = CreateItem("item_sneak", hero, hero)
    local player = PlayerResource:GetPlayer(v)
    local hero = player:GetAssignedHero()
    hero:AddItem(item) 
    Say(PlayerResource:GetPlayer(v), "I am a Traitor with team: "..GameMode:GetTNames(), true) 
    Say(PlayerResource:GetPlayer(v), "Use /t to talk with other traitors", true) 
  end
end

-- Initialise Item Spawner
function GameMode:ItemSpawner()
  GameRules.DropTable = LoadKeyValues("scripts/npc/item_drops.txt")
  Timers:CreateTimer(0.0, -- Start this timer 0 game-time seconds later
    function()
        DebugPrint("Droping items")
        GameMode:ItemSpawn()
      return SPAWNITEMTIMER -- Rerun this timer every 60 game-time seconds 
    end)


end


--[[== Misc Functions ==]]--


--Spawn Items
function GameMode:ItemSpawn()
  local dropinfo  = GameRules.DropTable
  local spawners = Entities:FindAllByName("itemspawner")
  if dropinfo and spawners then
    for _, spawner in pairs(spawners) do
      for item_name,chance in pairs(dropinfo) do
        if RollPercentage(chance) then
          local item = CreateItem(item_name, nil, nil)
          local pos = spawner:GetAbsOrigin()
          local drop = CreateItemOnPositionSync( pos, item )
          local pos_launch = pos+RandomVector(RandomFloat(150,200))
          item:LaunchLoot(false, 0.9, 0.75, pos_launch)
        end
      end
    end
  end
end

--Send Messages to Chat Filter
function GameMode:OnPlayerChat(keys)
  GameMode:ChatFilter(keys)
end