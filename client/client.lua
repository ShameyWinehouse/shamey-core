VORPcore = {}
TriggerEvent("getCore", function(core)
    VORPcore = core
end)
VORPutils = {}
TriggerEvent("getUtils", function(utils)
    VORPutils = utils
	print = VORPutils.Print:initialize(print)
end)
MenuData = {}
TriggerEvent("menuapi:getData",function(call)
    MenuData = call
end)


local hasAdvancedCompass = false

--------

CreateThread(function()
    jo.updateMeTimer(200)
end)

CreateThread(function()
	Citizen.Wait(12000)
	
	-- Force the inner and outer cores to always show
	Citizen.InvokeNative(0x4CC5F2FC1332577F, GetHashKey("HUD_CTX_ITEM_CONSUMPTION_HEALTH"))
	Citizen.InvokeNative(0x4CC5F2FC1332577F, GetHashKey("HUD_CTX_ITEM_CONSUMPTION_HEALTH_CORE"))

end)

--------

-- When player logs in, check for accessibility items
RegisterNetEvent("vorp:SelectedCharacter")
AddEventHandler("vorp:SelectedCharacter", function()
	Citizen.Wait(7000)
    TriggerServerEvent("rainbow-core:GetAccessibilityItems")
	Citizen.Wait(1000)
	updateHasAdvancedCompass()
end)

-- Every 5 mins, check if they have their Advanced Compass
CreateThread(function()
	while true do
		Citizen.Wait(5 * 60 * 1000) -- 5 mins
		updateHasAdvancedCompass()
	end
end)

function updateHasAdvancedCompass()
	if LocalPlayer.state["accessibility:hasAdvancedCompass"] ~= nil and LocalPlayer.state["accessibility:hasAdvancedCompass"] == true then
		hasAdvancedCompass = true
	end
end

-- Every 10 seconds, force simple/compass minimap, unless user has accessibility item
CreateThread(function()
	Citizen.Wait(10 * 1000)
	while true do
	
		if hasAdvancedCompass then return end
	
		Citizen.Wait(10 * 1000) -- 10 secs
		-- Force small minimap
		SetMinimapType(3) -- Simple
	end
end)


-- -- FIXMEEEEEE
-- RegisterCommand("debug:PlayAudioFile", function(source, args, rawCommand)
--     local _source = source
-- 	TriggerEvent("rainbow_core:PlayAudioFile", "higay.ogg")
-- end)

-- Play non-RDR audio files (`.ogg` files in `assets/audio` folder)
RegisterNetEvent("rainbow_core:PlayAudioFile")
AddEventHandler("rainbow_core:PlayAudioFile", function(audioFileName, volume)
	local volume = volume or 0.3
	SendNUIMessage({
		type= "playAudio",
		audioFileName = audioFileName,
		volume = volume,
	})
end)

-- `/c` command
RegisterCommand("c", function(source, args)
	TriggerEvent("ricx_scenarios:StopTasks")
	TriggerEvent("redm_interactions:StopInteractions")
	TriggerEvent("ricx_drugdealer:StopDealing")
	TriggerEvent("rainbow_doctor:StopSmoking")
end)
TriggerEvent("chat:addSuggestion", "/c", "Cancel character tasks immediately (unstuck)")


-------- UTILS

function _UtilitySetPedUnattackable(ped)
	SetEntityCanBeDamaged(ped, false)
	SetEntityInvincible(ped, true)
	Citizen.InvokeNative(0x7A6535691B477C48, ped, false) -- SetPedCanBeKnockedOffVehicle
    SetPedConfigFlag(ped, 82, false) -- PCF_AllowToBeTargetedInAVehicle 
    SetPedConfigFlag(ped, 137, true) -- PCF_CannotBeTakenDown  
    SetPedConfigFlag(ped, 169, true) -- PCF_DisableGrappleByPlayer 
    SetPedConfigFlag(ped, 192, true) -- PCF_DisableShootingAt  
    SetPedConfigFlag(ped, 302, true) -- PCF_DisableMeleeKnockout  
    SetPedConfigFlag(ped, 340, true) -- PCF_DisableAllMeleeTakedowns  
	SetPedConfigFlag(ped, 26, true) -- PCF_DisableMelee  
    Citizen.InvokeNative(0xAE6004120C18DF97, ped, 0, false) -- SET_PED_LASSO_HOGTIE_FLAG -- CanBeLassoed
end

function _GetTimeOfOneFrame()
    local frameTime = GetFrameTime()
    local frame = 1.0 / frameTime

    local time = 1.0
    local fpsTable = {
        {upperLimit = 30, value = 15/2},
        {upperLimit = 40, value = 12.5/2},
        {upperLimit = 50, value = 10/2},
        {upperLimit = 60, value = 7.5/2},
        {upperLimit = 80, value = 5/2},
        {upperLimit = 100, value = 2.5/2},
        {upperLimit = math.huge, value = 0}
    }
    
    local tableSize = #fpsTable
    for i = 1, tableSize do
        local v = fpsTable[i]
        if frame < v.upperLimit then
            time = v.value
            break
        end
    end
    
    return time
end

function _IsPositionInsidePolygon(playerPos, polyPoints, debug, issmall)

    local oddNodes = false
    local x, y = playerPos.x, playerPos.y

    for i = 1, #polyPoints do
        if debug then
            local start = vector3(polyPoints[i].x, polyPoints[i].y, polyPoints[i].z + 4.5)
            local finish = vector3(polyPoints[i % #polyPoints + 1].x, polyPoints[i % #polyPoints + 1].y, polyPoints[i % #polyPoints + 1].z + 4.5)
            local label = tostring(i)
            gumApi.drawMe(polyPoints[i].x, polyPoints[i].y, polyPoints[i].z + 1.0, label, 4.0)
            Citizen.InvokeNative(0x2A32FAA57B937173, -1795314153, polyPoints[i].x, polyPoints[i].y, polyPoints[i].z - 1.0, 0, 0, 0, 0, 0, 0, 0.05, 0.05, 4.0, 255, 255, 255, 100, 0, 0, 2, 0, 0, 0, 0)
        end

        if issmall then
            local start = vector3(polyPoints[i].x, polyPoints[i].y, polyPoints[i].z + 0.2)
            local finish = vector3(polyPoints[i % #polyPoints + 1].x, polyPoints[i % #polyPoints + 1].y, polyPoints[i % #polyPoints + 1].z + 0.2)
            Citizen.InvokeNative(0x2A32FAA57B937173, -1795314153, polyPoints[i].x, polyPoints[i].y, polyPoints[i].z - 1.0, 0, 0, 0, 0, 0, 0, 0.01, 0.01, 4.0, 255, 255, 255, 100, 0, 0, 2, 0, 0, 0, 0)
        end

        local j = i % #polyPoints + 1
        if ((polyPoints[i].y <= y and polyPoints[j].y > y) or (polyPoints[j].y <= y and polyPoints[i].y > y)) then
            if (polyPoints[i].x + (y - polyPoints[i].y) / (polyPoints[j].y - polyPoints[i].y) * (polyPoints[j].x - polyPoints[i].x) < x) then
                oddNodes = not oddNodes
            end
        end
    end

    return oddNodes

end

function _CanPedStartInteraction(ped)
	local isHogtied = (Citizen.InvokeNative(0x3AA24CCC0D451379, ped) ~= false) -- IsPedHogtied
	local isHandcuffed = Citizen.InvokeNative(0x74E559B3BC910685, ped) -- IsPedCuffed
	return not isHogtied and not isHandcuffed and not IsPedOnMount(ped) and not IsPedDeadOrDying(ped) and not IsPedInCombat(ped) and not IsPedInAnyVehicle(ped) and not IsPedSwimming(ped) and not IsPedClimbing(ped) and not IsPedFalling(ped)
end
