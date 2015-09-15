--Get string with the player names of all players on T
function GameMode:GetTNames()
  local tnames = ""
  for i, v in pairs(TTEAM) do 
    local player = PlayerResource:GetPlayerName(v)
    tnames = tnames..player.." "
  end
  return tnames
end

--return true if player with id is on Innocent
function GameMode:PlayerOnI(id)
  for i, v in pairs(ITEAM) do
    if v == id then
      return true
    end
  end
  return false
end

--return true if player with id is on Detectives
function GameMode:PlayerOnD(id)
  for i, v in pairs(DTEAM) do
    if v == id then
      return true
    end
  end
  return false
end

--return true if player with id is on TTEAM else return false
function GameMode:PlayerOnT(id)
  for i, v in pairs(TTEAM) do
    if v == id then
      return true
    end
  end
  return false
end

--return true if player with id is dead
function GameMode:PlayerDead(id)
  for i, v in pairs(DEAD) do
    if v == id then
      return true
    end
  end
  return false
end

function GameMode:AddToDead( id )
  DebugPrint("adding "..id.."to Dead")
  table.insert(DEAD, id)
end

function randomnumber()
  local timeTxt = string.gsub(string.gsub(GetSystemTime(), ':', ''), '0','')
  math.randomseed(tonumber(timeTxt))
  return timeTxt
end
