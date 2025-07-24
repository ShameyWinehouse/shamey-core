
local pvpOn = false

-------- THREADS

-- Automatically turn on PVP if they fire a gun
Citizen.CreateThread(function ()
    Wait(10 * 1000)
    while true do

        local sleep = 250

        local playerPed = PlayerPedId()
        local hasWeapon, weaponHash = GetCurrentPedWeapon(playerPed, true, 0, false)

        if not pvpOn and hasWeapon and isWeaponDangerousAndNonMelee(weaponHash) then
            sleep = 0
            if IsControlJustPressed(0, `INPUT_ATTACK`) then
                if Config.DebugPrint then print("attack") end
                TriggerEvent("rainbow-core:SetPvp", true)
            end
        end

        Wait(sleep)
    end
end)


-------- EVENTS

RegisterNetEvent("rainbow-core:TogglePvp")
AddEventHandler("rainbow-core:TogglePvp", function()
    if Config.DebugPrint then print("rainbow-core:TogglePvp") end
    TriggerEvent("rainbow-core:SetPvp", not pvpOn)
end)

RegisterNetEvent("rainbow-core:SetPvp")
AddEventHandler("rainbow-core:SetPvp", function(wantPvpOn)

    if Config.DebugPrint then print("rainbow-core:SetPvp", wantPvpOn) end

    pvpOn = wantPvpOn

    enforceCurrentPvp()

    -- Update the VORP UI
    TriggerEvent("vorp:setPVPUi", pvpOn)

    -- Show a noti
    local noti = "PVP is now on."
    if not wantPvpOn then
        noti = "PVP is now off."
    end
    TriggerEvent("vorp:TipRight", noti, 6000)

end)

RegisterNetEvent("rainbow-core:EnforceCurrentPvp")
AddEventHandler("rainbow-core:EnforceCurrentPvp", function()
    if Config.DebugPrint then print("rainbow-core:EnforceCurrentPvp") end
    enforceCurrentPvp()
end)

function enforceCurrentPvp()
    if Config.DebugPrint then print("enforceCurrentPvp() - pvpOn", pvpOn) end

    -- ALWAYS have friendly-fire on, no matter what
    NetworkSetFriendlyFireOption(true)

    -- Set "relationship" to control melee aggression
    local playerHash = joaat("PLAYER")
    if pvpOn then
        SetRelationshipBetweenGroups(5, playerHash, playerHash) -- 5 = "hate"
    else
        SetRelationshipBetweenGroups(1, playerHash, playerHash) -- 1 = "like"
    end
end


-------- FUNCTIONS

function isWeaponDangerousAndNonMelee(weaponHash)
    return _IsWeaponAGun(weaponHash) or _IsWeaponBow(weaponHash) or _IsWeaponThrowable(weaponHash) or _IsWeaponLasso(weaponHash) or _IsWeaponMeleeWeapon(weaponHash)
end


-------- NATIVES
function _IsWeaponAGun(...)
    return Citizen.InvokeNative(0x705BE297EEBDB95D, ...)
end

function _IsWeaponBow(...)
    return Citizen.InvokeNative(0xC4DEC3CA8C365A5D, ...)
end

function _IsWeaponThrowable(...)
    return Citizen.InvokeNative(0x30E7C16B12DA8211, ...)
end

function _IsWeaponLasso(...)
    return Citizen.InvokeNative(0x6E4E1A82081EABED, ...)
end

function _IsWeaponMeleeWeapon(...)
    return Citizen.InvokeNative(0x959383DCD42040DA, ...)
end
