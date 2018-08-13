function Commune( event )
	local caster = EntIndexToHScript(event.caster_entindex)
	local playerID = caster:GetPlayerOwnerID()
	local player = PlayerResource:GetPlayer(playerID)
	local ability = event.ability
	local owner = ability:GetPurchaser()
	local ownerID = owner:GetPlayerOwnerID()

	--DebugPrint("item owner",owner, "index", owner:entindex(), "name", owner:GetName() )
	
	if GameMode:PlayerOnD(playerID) then
		local lasthitstring = ""
		if PLAYERLIST[ownerID].lasthit == nil then
			lasthitstring = "This soul never hurt anybody"
		else
			lasthitstring = "This soul last attacked "..PlayerResource:GetPlayerName(PLAYERLIST[ownerID].lasthit)
		end
		Say(player, lasthitstring , true)
		DebugPrint(PLAYERLIST[ownerID].lasthit)
	else
		Say(player, "I'm not a detective", true)
		DebugPrint(PLAYERLIST[ownerID].lasthit)
	end
	caster:Hold()
end

function Scanner( event )
	local casterhero = EntIndexToHScript(event.caster_entindex)
	local pingtime =0
	for i=0,PlayerResource:GetPlayerCount()-1 do
		local player = PlayerResource:GetPlayer(i)
		local hero = player:GetAssignedHero()
		local pos = hero:GetAbsOrigin()
		if hero:IsAlive() then
			pingtime = pingtime+1
			Timers:CreateTimer({
				endTime = (0.5*pingtime),
				callback = function() 
					MinimapEvent(casterhero:GetTeamNumber(), casterhero, pos.x, pos.y,  512, 2)
				end
			})
		end	
	end
	casterhero:Hold()
end