
RegisterNetEvent("rainbow_core:VisualDebugTool")
AddEventHandler("rainbow_core:VisualDebugTool", function(debugPairsTable)
	-- print("rainbow_core:VisualDebugTool", debugPairsTable)
	if debugPairsTable then
		-- Send NUI update
		SendNUIMessage({
            type = "debugTool",
            pairs = json.encode(debugPairsTable),
        })
	end
end)
