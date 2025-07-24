local VORPutils = {}
TriggerEvent("getUtils", function(utils)
    VORPutils = utils
    print = VORPutils.Print:initialize(print) --Initial setup 
end)


-------- THREADS


-------- EVENTS

RegisterNetEvent("rainbow-core:AlertWeaponBroken")
AddEventHandler("rainbow-core:AlertWeaponBroken", function(str)

    if Config.ShameyDebugDegradation then print("rainbow-core:AlertWeaponBroken", str) end
	
	TriggerEvent("vorp:TipRight", str, 10 * 1000)

    while not (RequestScriptAudioBank('Ledger') == 1) do
		Citizen.Wait(0)
	end
	
	AddEventHandler('onResourceStop', function (rsc)
		if GetCurrentResourceName() == rsc then
			ReleaseNamedScriptAudioBank('Ledger')
		end
	end)

	PlaySoundFrontend('UNAFFORDABLE', 'Ledger_Sounds', true, 0)

end)

-------- FUNCTIONS

