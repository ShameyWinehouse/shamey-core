

RegisterNetEvent("rainbow_core:PingForZone")
AddEventHandler("rainbow_core:PingForZone", function()

    -- Abort if they're not in session (character selected) yet
    if not LocalPlayer.state.IsInSession then
        return
    end

    local zone = GetMostVagueZone()
    local zoneName = getMapData(zone)
    -- print(zoneName)
    TriggerServerEvent("rainbow_core:ReturnPingForZone", zoneName)

end)


function GetMostVagueZone()

    local player = PlayerPedId()
    local x, y, z = table.unpack(GetEntityCoords(player))

    local zone
    
    local temptown = _GetMapZoneAtCoords(x, y, z, 1)
    -- print("temptown", temptown)
    if temptown then
        zone = temptown
    end

    local tempdistrict = _GetMapZoneAtCoords(x, y, z, 10)
    -- print("tempdistrict", tempdistrict)
    if tempdistrict then
        zone = tempdistrict
    end

    local tempprint = _GetMapZoneAtCoords(x, y, z, 12)
    -- print("tempprint", tempprint)
    if tempprint then
        zone = tempprint
    end

    local tempwritten = _GetMapZoneAtCoords(x, y, z, 13)
    -- print("tempwritten", tempwritten)
    if tempwritten then
        zone = tempwritten
    end

    local tempstate = _GetMapZoneAtCoords(x, y, z, 0)
    -- print("tempstate", tempstate)
    if tempstate then
        zone = tempstate
    end

    return zone
end

function getMapData(hash)
	if hash ~= false then
		local sd = Config.MapData[hash]
		if sd then
            if sd.ZoneTypeName == "STATE" or sd.ZoneTypeName == "DISTRICT" then
			    return sd.ZoneNamePretty or sd.ZoneName
            else
                return "Not Available"
            end
		else
			-- print('No data for:', hash)
			return 'Unknown'
		end
	else
		return 'Unknown'
	end
end


function _GetMapZoneAtCoords(...)
    return Citizen.InvokeNative(0x43AD8FC02B429D33, ...)
end
