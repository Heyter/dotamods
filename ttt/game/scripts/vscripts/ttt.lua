--[[== Team Consts ==]]--


PLAYERLIST = {}
TTEAM= {}
ITEAM= {}
DTEAM= {}
DEAD= {}
CURRENT_ROUND = 0
BETWEEN_ROUNDS = true


--[[== ttt libraries ==]]--


--player say library for modifying say rules
require('playersay')
--util library for ttt
require('ttt_util')
--chat filter library for ttt
require('ttt_chatfilter')
--config file for ttt
require('ttt_config')


--[[== Game Start Functions ==]]--


-- Reset Game
function GameMode:ResetGame()
  BETWEEN_ROUNDS = true
  CURRENT_ROUND = CURRENT_ROUND +1
  
  -- Resetting teams
  PLAYERLIST = {}
  TTEAM= {}
  ITEAM= {}
  DTEAM= {}
  DEAD= {}

  -- Resetting heroes
  local heroes = HeroList:GetAllHeroes()
  for _, hero in pairs(heroes) do
    -- Remove all items
    for i=0,6 do
      local item = hero:GetItemInSlot(i)
      hero:RemoveItem(item)
    end

    -- Respawn all heroes
    -- if hero:IsAlive() then hero:ForceKill(false) end
    hero:RespawnUnit()
    hero:Hold()

    -- Give heroes default items
    local item = CreateItem("item_example_item", hero, hero)
    hero:AddItem(item)
    local item = CreateItem("item_ghost", hero, hero)
    hero:AddItem(item)
    local item = CreateItem("item_phase_boots", hero, hero)
    hero:AddItem(item)
  end

  -- Resetting Map
  local items = Entities:FindAllByClassname("dota_item_drop")
  for _, item in pairs(items) do
    item:RemoveSelf()
  end


  -- Allow all players to speak again
  for i, v in pairs(PLAYERLIST) do
    PlayerSay:SendConfig(i, true, true)
  end

  -- Assign Roles for new round round
  GameMode:AssignRoles()

  -- Reset Game End Timer
  GameMode:GameTimer()

  -- Reset Between rounds
  BETWEEN_ROUNDS = false
end

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
  local round = 
  Timers:CreateTimer(0.0, -- Start this timer 0 game-time seconds later
    function()
        DebugPrint("Droping items")
        GameMode:ItemSpawn()
      return SPAWNITEMTIMER -- Rerun this timer every 60 game-time seconds 
    end)
end

function GameMode:GameTimer()

  --Timers:RemoveTimer(1)
  --Timers:RemoveTimer()

  Timers:CreateTimer(1,{endTime = 600.0,
    callback = function()
      Say(nil,"Game Timed Out, Innocents Win!")
      GameMode:ResetGame()
      return nil -- Rerun this timer every 30 game-time seconds 
    end})

  --countdown
  local countdown = 10
  Timers:CreateTimer(2,{endTime = 0.0, -- Start this timer 0 game-time seconds later
    callback = function()
      --DebugPrint("[ttt]", "Countdown:",countdown,"mins left") 
      Say(nil,"Time Remaining: "..countdown.." minutes.",true)
      countdown = countdown - 1
      return 60.0 -- Rerun this timer every 60 game-time seconds 
    end})

end

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
  if BETWEEN_ROUNDS then return true end
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
    herodamaged:ForceKill(true)
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
  if BETWEEN_ROUNDS then return false end
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
    Say(nil,"Innocents Win",false)
    if CURRENT_ROUND == NUMBEROFROUNDS then GameMode:CloseServer() end
    --wait 5 seconds to reset the game
    Timers:CreateTimer(5.0, -- end game
      function()
        GameMode:ResetGame()
        return nil -- Rerun this timer every 30 game-time seconds 
      end)
    return "iwin"

  elseif twin then
    DebugPrint("[ttt]", "T win the game")
    Say(nil,"Terrorists Win",false) 
    if CURRENT_ROUND == NUMBEROFROUNDS then GameMode:CloseServer() end
    --wait 5 seconds to reset the game
    Timers:CreateTimer(5.0, 
      function()
        GameMode:ResetGame()
        return nil 
      end)
    return "twin"

  else
    return nil
  end
end

--Close Server
function GameMode:CloseServer()
  GameRules:SetCustomVictoryMessage("Server Closing")
  GameRules:SetCustomVictoryMessageDuration(10.0)
  GameRules:SetSafeToLeave( true )
  GameRules:SetGameWinner( killerEntity:GetTeam() )
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