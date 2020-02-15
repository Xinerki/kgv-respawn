
alreadyDead = false

function processDeathEvent()
	local time = GetGameTimer()

	while (not HasCollisionLoadedAroundEntity(ped) and (GetGameTimer() - time) < 5000) do
		Citizen.Wait(0)
	end

	ShutdownLoadingScreen()

	if IsScreenFadedOut() then
		DoScreenFadeIn(500)

		while not IsScreenFadedIn() do
			Citizen.Wait(0)
		end
	end
	
    exports.spawnmanager:setAutoSpawn(false)
	
	while true do
		Citizen.Wait (0)
		-- SetPedDropsWeaponsWhenDead(PlayerPedId(), true)
		
		if IsPedDeadOrDying(PlayerPedId()) == 1 then
			if alreadyDead == false then
				alreadyDead = true
				Citizen.CreateThread(onPlayerDead) -- manual respawn
				-- Citizen.CreateThread(onPlayerDeadInstant) -- ominous instant black screen
			end
		end
		
		if IsPedDeadOrDying(PlayerPedId()) == false then
			if alreadyDead == true then
				alreadyDead = false
				Citizen.CreateThread(onPlayerNotDeadAnymore)
			end
		end
	end
end
Citizen.CreateThread(processDeathEvent)

function onPlayerDeadInstant()
	-- TriggerScreenblurFadeIn(1000)
	
	-- SetTimecycleModifier("MP_death_grade")
	-- ShakeGameplayCam("JOLT_SHAKE", 1.0)
	-- PlaySoundFrontend(-1, "Friend_Deliver", "HUD_FRONTEND_MP_COLLECTABLE_SOUNDS", 0 )
	
	Citizen.Wait(750)
	
	DoScreenFadeOut(0)
	
	-- SetTimecycleModifier("MP_death_grade")
	-- TogglePausedRenderphases(false)
	
	PlaySoundFrontend(-1, "Frontend_Beast_Freeze_Screen", "FM_Events_Sasquatch_Sounds", 0 )
	-- PlaySoundFrontend(-1, "Friend_Deliver", "HUD_FRONTEND_MP_COLLECTABLE_SOUNDS", 0 )
	
	Citizen.Wait(1500+500)
	
	local x, y, z = table.unpack(GetEntityCoords(PlayerPedId()))
	
	local x = x + math.random(-50, 50)
	local y = y + math.random(-50, 50)
	
	success, vec3, heading = GetRandomVehicleNode(x,y,z, 50.0, 1, true, true)
	
	if vec3 == vector3(0.0, 0.0, 0.0) then
		x, y, z = table.unpack(GetEntityCoords(PlayerPedId()))
	else
		x, y, z = table.unpack(vec3)
	end
	
	local success, vec3 = GetSafeCoordForPed(x, y, z, false, 16)
	
	if vec3 == vector3(0.0, 0.0, 0.0) then
		x, y, z = table.unpack(GetEntityCoords(PlayerPedId()))
	else
		x, y, z = table.unpack(vec3)
	end
	NetworkResurrectLocalPlayer(x, y, z-1.0, heading, true, false)
	
	ClearTimecycleModifier()
	
	-- TriggerScreenblurFadeOut(0)
	
	DoScreenFadeIn(250)
	
	-- TogglePausedRenderphases(true)
	
	Citizen.Wait(250)
end

function onPlayerDead()
	-- PlaySoundFrontend(-1, "Frontend_Beast_Freeze_Screen", "FM_Events_Sasquatch_Sounds", 0 )
	PlaySoundFrontend(-1, "Friend_Deliver", "HUD_FRONTEND_MP_COLLECTABLE_SOUNDS", 0 )
	
	
	local cam = CreateCam("DEFAULT_SCRIPTED_CAMERA", 1)

	SetCamCoord(cam, GetFinalRenderedCamCoord())
	-- SetCamRot(cam, -5.25, 0.0, 108.5, 2)
	PointCamAtEntity(cam, PlayerPedId(), 0.0, 0.0, 0.0, 1)
	SetCamFov(cam, GetFinalRenderedCamFov())
	ShakeCam(cam, "HAND_SHAKE", 3.0)
	RenderScriptCams(true, true, 1000, true, true)

	SetTransitionTimecycleModifier("MP_death_grade", 1.0)
	-- ShakeGameplayCam("JOLT_SHAKE", 1.0)
	
	-- SetTimecycleModifier("MP_death_grade")
	-- TogglePausedRenderphases(false)

	local killer = GetPedSourceOfDeath(PlayerPedId())
	if killer and IsEntityAPed(killer) and IsPedAPlayer(killer) and killer ~= PlayerPedId() then
		SetGameplayEntityHint(killer, 0.0, 0.0, 1.0, true, -1, 1000, 1000, 1)
		-- AddOwnedExplosion(PlayerPedId(), GetEntityCoords(killer), 29, 1.0, true, false, true)
		
		-- if IsPedAPlayer(killer) then
			-- local pName = GetPlayerName(PlayerPedId())
			-- local kName = GetPlayerName(killer)
			-- chatMessage(kName .. " killed "..pName)
		-- end
	end
	-- print("killer = "..killer or "none!")
	
	Citizen.Wait(1000)
	
	repeat Wait(0) 
		if IsControlJustPressed(0, 51) then
			if killer and IsEntityAPed(killer) and IsPedAPlayer(killer) and killer ~= PlayerPedId() then
				DoScreenFadeOut(250)
				Citizen.Wait(250)
				-- TogglePausedRenderphases(true)
				NetworkSetInSpectatorMode(true, killer)
				StopGameplayHint(true)
				DoScreenFadeIn(250)
			end
		end
	until IsDisabledControlJustPressed(0, 24) or IsDisabledControlJustPressed(0, 22)
	
	DoScreenFadeOut(1500)
	
	Citizen.Wait(1500+500)
	
	local x, y, z = table.unpack(GetEntityCoords(PlayerPedId()))
	
	local x = x + math.random(-50, 50)
	local y = y + math.random(-50, 50)
	
	success, vec3, heading = GetRandomVehicleNode(x,y,z, 50.0, 1, true, true)
	
	if vec3 == vector3(0.0, 0.0, 0.0) then
		x, y, z = table.unpack(GetEntityCoords(PlayerPedId()))
	else
		x, y, z = table.unpack(vec3)
	end
	
	local success, vec3 = GetSafeCoordForPed(x, y, z, false, 16)
	
	if vec3 == vector3(0.0, 0.0, 0.0) then
		x, y, z = table.unpack(GetEntityCoords(PlayerPedId()))
	else
		x, y, z = table.unpack(vec3)
	end
	
	RenderScriptCams(false, false, 0, true, true)
	DestroyCam(cam, false)
		
	NetworkResurrectLocalPlayer(x, y, z-1.0, heading, true, false)
	
	ClearTimecycleModifier()
	NetworkSetInSpectatorMode(false, killer)
	StopGameplayHint(1000)
	
	StopGameplayCamShaking(false)
	DoScreenFadeIn(250)
	
	-- TogglePausedRenderphases(true)
	Citizen.Wait(250)

end

function onPlayerNotDeadAnymore()
	-- ClearTimecycleModifier()
	-- ClearPedBloodDamage(PlayerPedId())
	-- ClearPedFacialDecorations(PlayerPedId())
	-- StartPlayerSwitch(PlayerPedId(), PlayerPedId(), 0, 2)
	-- SwitchInPlayer(PlayerPedId())
end