VORPutils = {}
TriggerEvent("getUtils", function(utils)
    VORPutils = utils
	print = VORPutils.Print:initialize(print)
end)
VorpCore = {}
TriggerEvent("getCore",function(core)
    VorpCore = core
end)

local VorpInv = exports.vorp_inventory:vorp_inventoryApi()



function DumpTable(o)
	if type(o) == 'table' then
		local s = '{ '
		for k,v in pairs(o) do
		   if type(k) ~= 'number' then k = '"'..k..'"' end
		   s = s .. '['..k..'] = ' .. DumpTable(v) .. ','
		end
		return s .. '} '
	 else
		return tostring(o)
	 end
  end



RegisterNetEvent("rainbow-core:GetAccessibilityItems")
AddEventHandler("rainbow-core:GetAccessibilityItems", function()
	-- print("rainbow-core:GetAccessibilityItems")
    local _source = source

	-- Get the count of an item player has in inventory

	-- Allows the "compass" (rudimentary minimap) to be switched to the expanded, GTA-style minimap. (For IRL impaired vision.)
	local advancedCompassCount = VorpInv.getItemCount(_source, Config.ItemNameAdvancedCompass)
	if advancedCompassCount > 0 then
		-- Set the state bag
		Player(_source).state["accessibility:hasAdvancedCompass"] = true
		-- print("hasAdvancedCompass")
	end
	
	-- (Outdated) Removed minigame from Horse Trainers' wild-horse-catching. (For IRL motor issues.)
	local horseWhistleCount = VorpInv.getItemCount(_source, Config.ItemNameHorseWhistle)
	if horseWhistleCount > 0 then
		-- Set the state bag
		Player(_source).state["accessibility:hasHorseWhistle"] = true
		-- print("hasHorseWhistle")
	end
	
	-- Disables screen flashing from stress. (For photosensitivity.)
	local stressSalveCount = VorpInv.getItemCount(_source, Config.ItemNameStressSalve)
	if stressSalveCount > 0 then
		-- Set the state bag
		Player(_source).state["accessibility:hasStressSalve"] = true
		print("hasStressSalve")
	end
	
	-- Makes minigame for mining easier (read: slower). Does not disable it. (For motor issues.)
	local reinforcedGlovesCount = VorpInv.getItemCount(_source, Config.ItemNameReinforcedGloves)
	if reinforcedGlovesCount > 0 then
		-- Set the state bag
		Player(_source).state["accessibility:hasReinforcedGloves"] = true
		print("hasReinforcedGloves")
	end

	-- Allows "auto-aim" ("Lock-On Mode (On-Foot)" setting) for controller to be enabled. (For motor issues.)
	local enhancedSightsCount = VorpInv.getItemCount(_source, Config.ItemNameEnhancedSights)
	if enhancedSightsCount > 0 then
		-- Set the state bag
		Player(_source).state["accessibility:hasEnhancedSights"] = true
		print("hasEnhancedSights")
	end

end)

RegisterNetEvent("vorp:ImDead")
AddEventHandler("vorp:ImDead", function(isDead)
	local _source = source
	
	local downedCharacter = VorpCore.getUser(_source).getUsedCharacter
    local downedCharIdentifier = downedCharacter.charIdentifier
	local downedFullName = string.format("%s %s", downedCharacter.firstname, downedCharacter.lastname)
	
	if isDead then
		VorpCore.AddWebhook("A person was downed.", Config.DeathWebhook, string.format(
        "**Downed Person:** %s (CharId %s)", downedFullName, downedCharIdentifier))
	end
end)

RegisterNetEvent("rainbow-core:PlayerFullyInited")
AddEventHandler("rainbow-core:PlayerFullyInited", function()
	local _source = source
	local warningStr = "Warning: Our server includes flashing images from stress and drug use, along with violence, gore, and other sensitive content. Please visit GameContentTriggers.com for a full list of RDR2 warnings."
	TriggerClientEvent("vorp:TipBottom", _source, warningStr, 30 * 1000)
end)