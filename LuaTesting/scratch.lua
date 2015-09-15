

-- funcution definition
function test()
	print("func")
end

-- for iteration var, max value, increment size
function forfunc()
	for i=1,10,2
		do print(i)
	end
end

--prints out globals
function globals()
	for n in pairs(_G) do print(n) end
end

--prints out table
function printtable(table)
	for n in pairs(table) do print(n) end
end


function randomnumber()
  return math.random(1000)
end

function Assign_T()
  players = 8
  Tnum = math.floor(players/3)

  for i=1,players do
    Iteam[i] = i
  end

  while #Tteam<Tnum do
    randnum =randomnumber()
    print(randnum)
    newT = math.fmod(randnum, #Iteam)
    v = table.remove(Iteam,newT)
    table.insert(Tteam,v)
  end
end