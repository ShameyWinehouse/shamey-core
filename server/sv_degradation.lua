local VORPutils = {}
TriggerEvent("getUtils", function(utils)
    VORPutils = utils
    print = VORPutils.Print:initialize(print) --Initial setup 
end)

local VorpCore = {}
TriggerEvent("getCore",function(core)
    VorpCore = core
end)

local VorpInv = exports.vorp_inventory:vorp_inventoryApi()


-------- THREADS


-------- EVENTS

RegisterServerEvent("rainbow-core:CheckItem")
AddEventHandler("rainbow-core:CheckItem", function(_source, itemName, callbackHasItem)
	local itemObject = VorpInv.getItem(_source, itemName)
	if itemObject ~= nil then
		callbackHasItem(itemObject)
	else
		callbackHasItem(false)
	end
end)

RegisterServerEvent("rainbow-core:DegradeItem")
AddEventHandler("rainbow-core:DegradeItem", function(_source, itemName, degradeAmount, callbackHasItem)

    if Config.ShameyDebugDegradation then print("DegradeItem", _source, itemName) end

    local itemObject = VorpInv.getItem(_source, itemName)
    
    if Config.ShameyDebugDegradation then print("DegradeItem - itemObject", itemObject) end

    if itemObject ~= nil then
        local itemLabel = itemObject.label
		local meta =  itemObject["metadata"]
		if next(meta) == nil then 
			VorpInv.subItem(_source, itemName, 1, {})
			VorpInv.addItem(_source, itemName, 1, {description = generateDurabilityDescription(99.0), durability = 99})
            callbackHasItem(true)
		else
			local durability = tonumber(meta.durability) - tonumber(degradeAmount)
			VorpInv.subItem(_source, itemName, 1, meta)
			if durability <= 0 then 
                -- 50% chance of breaking
				local random = math.random(1,2)
				if random == 1 then 
					alertBroken(_source, string.format("Your %s broke.", itemLabel))
				else
					VorpInv.addItem(_source, itemName, 1, {description = generateDurabilityDescription(1.0), durability = 1})
                    callbackHasItem(true)
				end
			else
				if durability <= 3 then
					alertNearlyBroken(_source, string.format("Your %s is near breaking (%.1f%% durability).", itemLabel, durability))
				end
				VorpInv.addItem(_source, itemName, 1, {description = generateDurabilityDescription(durability), durability = durability})
                callbackHasItem(true)
			end
		end
    else
        callbackHasItem(false)
		TriggerClientEvent("vorp:TipRight", _source, "You don't have the item.", 10 * 1000)
	end
end)

RegisterServerEvent("rainbow-core:GetWeaponDegradation")
AddEventHandler("rainbow-core:GetWeaponDegradation", function(weaponId, cb)

	weaponId = tonumber(weaponId)

	cb(getWeaponDegradation(weaponId))
end)

RegisterServerEvent("rainbow-core:CheckWeapon")
AddEventHandler("rainbow-core:CheckWeapon", function(_source, weapon, incrementAmount, breakThreshold, cb)
	local weaponId = tonumber(weapon.id)

	if Config.ShameyDebugDegradation then print("rainbow-core:CheckWeapon", _source, weapon, weaponId, incrementAmount, breakThreshold) end

	local result = getWeaponDegradation(weaponId)

	if Config.ShameyDebugDegradation then print("rainbow-core:CheckWeapon - result", result) end

	-- If weapon isn't in loadout table
	if not result then

		TriggerEvent("rainbow-core:AddWeaponToDegradationTable", _source, weaponId, 0.0)

	else
		-- Weapon *is* in loadout table

		-- If it should break
		if Config.ShameyDebugDegradation then print("rainbow-core:CheckWeapon - 96 - ", tonumber(result.degradation), tonumber(breakThreshold) ) end
		if (tonumber(result.degradation) + tonumber(incrementAmount)) >= tonumber(breakThreshold) then
			TriggerEvent("rainbow-core:BreakWeapon", _source, weapon)
			cb(false)
			return
		end
	end

	cb(true)
end)

RegisterServerEvent("rainbow-core:DegradeWeapon")
AddEventHandler("rainbow-core:DegradeWeapon", function(_source, weapon, incrementAmount, breakThreshold)

	local weaponId = tonumber(weapon.id)

	if Config.ShameyDebugDegradation then print("rainbow-core:DegradeWeapon", _source, weapon, weaponId, incrementAmount, breakThreshold) end

	local result = getWeaponDegradation(weaponId)

	TriggerEvent("rainbow-core:CheckWeapon", _source, weapon, incrementAmount, breakThreshold, function(res)
		if result then
			if res == true then
				-- Degrade it
				local degradation = result.degradation + incrementAmount
				degradeWeapon(_source, weaponId, degradation)
			end
		else
			print("WARNING: `rainbow-core:DegradeWeapon` failed because getWeaponDegradation failed. Source, weapon:", _source, weapon)
		end
	end)

end)

RegisterServerEvent("rainbow-core:BreakWeapon")
AddEventHandler("rainbow-core:BreakWeapon", function(_source, weapon)

	if Config.ShameyDebugDegradation then print("rainbow-core:BreakWeapon", _source, weapon) end

	local weaponHash = weapon["name"]
	local weaponName = GetWeaponName(_source, weaponHash)
	alertBroken(_source, string.format("Your %s broke.", weaponName))
	-- TriggerClientEvent("rainbow-core:AlertWeaponBroken", _source, "test")
	VorpInv.subWeapon(_source, weapon["id"])
end)

RegisterServerEvent("rainbow-core:AddWeaponToDegradationTable")
AddEventHandler("rainbow-core:AddWeaponToDegradationTable", function(_source, weaponId, degradation)
	if Config.ShameyDebugDegradation then print("rainbow-core:AddWeaponToDegradationTable", _source, weaponId, degradation) end
	addWeaponToTable(_source, weaponId, degradation)
end)


-------- FUNCTIONS

function generateDurabilityDescription(durability)
    return string.format("Durability = %.1f%%", tonumber(durability))
end

function getWeaponDegradation(weaponId)
	local result_promise = promise.new()

	exports.ghmattimysql:execute('SELECT degradation FROM loadout_props WHERE id = @id' , {['id'] = weaponId}, function(result)
		if result then 
			result = result[1]
		end
		result_promise:resolve(result)
	end)

	return Citizen.Await(result_promise)
end

function addWeaponToTable(_source, weaponId, degradation)

	if Config.ShameyDebugDegradation then print("addWeaponToTable()", _source, weaponId, degradation) end

	exports.ghmattimysql:execute('INSERT INTO loadout_props (id) VALUES (@id)' , {
		['id'] = weaponId,
		['degradation'] = degradation,
	}, function (done)
		if not done then
			return print('[VORP] %s tried to create weapon (%s) entry in DB.', _source, weaponId)
		end
		
		print(string.format('[VORP] %s created weapon (%s) entry in DB.', _source, weaponId))
	end)
end

function degradeWeapon(_source, weaponId, degradation)

	if Config.ShameyDebugDegradation then print("degradeWeapon()", _source, weaponId, degradation) end

	exports.ghmattimysql:execute('UPDATE loadout_props SET degradation = @degradation WHERE id = @id' , {
		['degradation'] = degradation,
		['id'] = weaponId,
	}, function (done)
		if not done then
			return print(string.format('[VORP] %s tried to UPDATE weapon (%s) entry in DB.', _source, weaponId))
		end
		
		print(string.format('[VORP] %s updated weapon (%s) entry in DB.', _source, weaponId))
		TriggerEvent("rainbow-core:WeaponDegraded", _source, weaponId, degradation)
	end)
end

function alertBroken(_source, str)

	if Config.ShameyDebugDegradation then print("alertBroken", _source, str) end

	TriggerClientEvent("rainbow-core:AlertWeaponBroken", _source, str)
	
end

function alertNearlyBroken(_source, str)

	if Config.ShameyDebugDegradation then print("alertNearlyBroken", _source, str) end

	TriggerClientEvent("vorp:TipRight", _source, str, 5 * 1000)
end

function GetWeaponName(_source, weaponHash)

	if Config.ShameyDebugDegradation then print("GetWeaponName()", _source, weaponHash) end

	return VorpInv.GetWeaponLabel(weaponHash)
end


--------

