

function dump(o)
   if type(o) == 'table' then
      local s = '{ '
      for k,v in pairs(o) do
         if type(k) ~= 'number' then k = '"'..k..'"' end
         s = s .. '['..k..'] = ' .. dump(v) .. ','
      end
      return s .. '} '
   else
      return tostring(o)
   end
end



RegisterNetEvent("rainbow_core:CheckTelegrams")
AddEventHandler("rainbow_core:CheckTelegrams", function()

	
	
	local _source = source
	local Character = VorpCore.getUser(_source).getUsedCharacter
    local charIdentifier = Character.charIdentifier
	
	-- print("rainbow_core:CheckTelegrams:  ", dump(charIdentifier))
	
	exports.oxmysql:execute("SELECT t1.id FROM telegrams AS t1 JOIN user_telegram AS ut ON t1.receiver=ut.telegram WHERE ut.charid=@charidentifier and t1.open=0;"
			, { ["@charidentifier"] = charIdentifier, }, function(result)
			
			-- print("rainbow_core:CheckTelegrams - result", dump(result))

			local hasTelegram = #result > 0
			TriggerClientEvent("rainbow_core:SetHasTelegrams", _source, hasTelegram)

	end)
end)