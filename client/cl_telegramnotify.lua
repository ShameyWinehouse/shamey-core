
hasTelegrams = false

RegisterNetEvent("rainbow_core:SetHasTelegrams")
AddEventHandler("rainbow_core:SetHasTelegrams", function(_hasTelegrams)
	-- print("rainbow_core:SetHasTelegrams", tostring(_hasTelegrams))
	if hasTelegrams ~= _hasTelegrams then
		hasTelegrams = _hasTelegrams
		-- Send NUI update
		sendNuiUpdate()
	end
end)


function sendNuiUpdate()
	SendNUIMessage({
		type = "telegrams",
		hasTelegrams = hasTelegrams,
	})
end


Citizen.CreateThread(function()
	Citizen.Wait(15000)
	while true do
		Citizen.Wait(60 * 1000)
		TriggerServerEvent("rainbow_core:CheckTelegrams")
	end
end)