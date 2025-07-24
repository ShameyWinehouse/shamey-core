


function _StartParticleFx(entity, dict, name)
    StartParticleFxSpecific(entity, dict, name, 0.0, 0.0, 0.0, -90.0, 0.0, 0.0, 1.0, 0, 0, 0)
end

function _StartParticleFxSpecific(entity, dict, name, ptfx_offcet_x, ptfx_offcet_y, ptfx_offcet_z, ptfx_rot_x, ptfx_rot_y, ptfx_rot_z, ptfx_scale, ptfx_axis_x, ptfx_axis_y, ptfx_axis_z)
    current_ptfx_dictionary = dict
    current_ptfx_name = name
    if not Citizen.InvokeNative(0x65BB72F29138F5D6, GetHashKey(current_ptfx_dictionary)) then -- HasNamedPtfxAssetLoaded
        Citizen.InvokeNative(0xF2B2353BBC0D4E8F, GetHashKey(current_ptfx_dictionary))  -- RequestNamedPtfxAsset
        local counter = 0
        while not Citizen.InvokeNative(0x65BB72F29138F5D6, GetHashKey(current_ptfx_dictionary)) and counter <= 300 do  -- while not HasNamedPtfxAssetLoaded
            Citizen.Wait(10)
        end
    end
    if Citizen.InvokeNative(0x65BB72F29138F5D6, GetHashKey(current_ptfx_dictionary)) then  -- HasNamedPtfxAssetLoaded
        Citizen.InvokeNative(0xA10DB07FC234DD12, current_ptfx_dictionary) -- UseParticleFxAsset

        -- current_ptfx_handle_id = Citizen.InvokeNative(0x9C56621462FFE7A6,current_ptfx_name,PlayerPedId(),ptfx_offcet_x,ptfx_offcet_y,ptfx_offcet_z,ptfx_rot_x,ptfx_rot_y,ptfx_rot_z,bone_index,ptfx_scale,ptfx_axis_x,ptfx_axis_y,ptfx_axis_z) -- StartNetworkedParticleFxLoopedOnEntityBone
        current_ptfx_handle_id =  Citizen.InvokeNative(0xBD41E1440CE39800, current_ptfx_name, entity, ptfx_offcet_x, ptfx_offcet_y, ptfx_offcet_z, ptfx_rot_x, ptfx_rot_y, ptfx_rot_z, ptfx_scale, ptfx_axis_x, ptfx_axis_y, ptfx_axis_z)    -- StartParticleFxLoopedOnEntity

		return current_ptfx_handle_id
    else
        print("cant load ptfx dictionary!")
    end
	
	return false
end

function _StopThisParticleFx(ptfxHandleId)
    if ptfxHandleId then
        if Citizen.InvokeNative(0x9DD5AFF561E88F2A, ptfxHandleId) then   -- DoesParticleFxLoopedExist
            Citizen.InvokeNative(0x459598F579C98929, ptfxHandleId, false)   -- RemoveParticleFx
        end
    end
end



AddEventHandler("onResourceStop", function(resourceName)
	if (GetCurrentResourceName() ~= resourceName) then
	    return
	end

    _StopAllParticleFx()
end)