
RegisterCommand("multijob", function(source, args, rawCommand)

    -- if args[1] then
    --     TriggerServerEvent("rainbow_core:Jobs:SwitchJob", args[1])
    -- else
        SwitchJobMenu()
        -- VORPcore.NotifyRightTip(string.format("Your present job is: %s", LocalPlayer.state["Rainbow:Character:PresentJob"]), 6 * 1000)
    -- end
    
end, false)
TriggerEvent("chat:addSuggestion", "/multijob", "Switch between jobs.")

RegisterNetEvent("rainbow_core:Jobs:Admin:Command:multijobAdmin")
AddEventHandler("rainbow_core:Jobs:Admin:Command:multijobAdmin", function(args)

    if Config.DebugPrint then print("rainbow_core:Jobs:Admin:Command:multijobAdmin", args) end

    if args[1] then
        AdminLookup(args[1])
    else
        jo.notif.rightError("You must include a partial name as an argument. For example: /multijobAdmin jo")
    end
end)

--------


if Config.DebugCommands then

    RegisterCommand("debug:Core:loadJobAssignments", function(source, args, rawCommand)

        TriggerServerEvent("rainbow_core:Debug:LoadJobAssignments", args)
        
    end, false)
end

function AdminLookup(searchText)

    if Config.DebugPrint then print("AdminLookup", searchText) end

    jo.callback.triggerServer("CALLBACK:rainbow_core:Admin:Jobs:Lookup", function(result)
        AdminMultijobCharacterSelectionMenu(result)
    end, searchText)
end

--------

function SwitchJobMenu()

    if Config.DebugPrint then print("AdminMultijobRemoveJobAssignmentMenu- characterItem:", characterItem) end

    MenuData.CloseAll()

    -- Get the job assignments
    local result_promise = promise.new()
    jo.callback.triggerServer("CALLBACK:rainbow_core:Admin:Jobs:FetchJobAssignmentsForThisChar", function(result)
        result_promise:resolve(result)
    end)
    local jobAssignments = Citizen.Await(result_promise)

    local elements = {}
    if jobAssignments and jobAssignments[1] then
        for k,v in pairs(jobAssignments) do
            local desc = string.format("Date Assigned: %s  |  Last Active: %s", convertDateValueToHumanReadable(v.dateCreated), convertDateValueToHumanReadable(v.dateLastActive))
            table.insert(elements, { label = v.job.label, value = v.id, desc = desc, info = v })
        end
    else
        table.insert(elements, { label = "NO RESULTS", value = "backup", desc = "You have no job assignments." })
    end

    MenuData.Open("default", GetCurrentResourceName(), "MultijobSwitchJobs", {
		title = "Switch Jobs",
		subtext = "",
		align = "top-left",
		elements = elements,
	},

    function(data, menu)

        -- if data.current == "backup" then
        --     _G[data.trigger](characterItems, characterItem)
        -- else
        if(data.current.value) then

            TriggerServerEvent("rainbow_core:Jobs:SwitchJob", data.current.value)

            menu.close()

        else
            MenuData.CloseAll()
        end

	end,
			
	function(data, menu)
		menu.close()
	end)

end

-------- Admin Menus

function AdminMultijobCharacterSelectionMenu(characterItems)

    if Config.DebugPrint then print("AdminMultijobCharacterSelectionMenu- characterItems:", characterItems) end

    MenuData.CloseAll()

    local elements = {}
    if characterItems and characterItems[1] then
        for k,v in pairs(characterItems) do
            local name = string.format("%s %s", v.firstname, v.lastname)
            local desc = string.format("CharId: %s  |  Last Login: %s", v.charidentifier, convertDateValueToHumanReadable(v.LastLogin))
            table.insert(elements, { label = name, value = k, desc = desc })
        end
    else
        table.insert(elements, { label = "NO RESULTS", value = "backup", desc = "Character names are VERY case-sensitive." })
    end 

    MenuData.Open("default", GetCurrentResourceName(), "AdminMultijobCharSelectionMenu", {
		title = "Admin Multijob - Select",
		subtext = "Select a character",
		align = "top-left",
		elements = elements,
	},

    function(data, menu)

            if(data.current.value) then
            AdminMultijobViewCharacterMenu(characterItems, characterItems[data.current.value])
        else
            MenuData.CloseAll()
        end

	end,
			
	function(data, menu)
		menu.close()
	end)

end

function AdminMultijobViewCharacterMenu(characterItems, characterItem)

    if Config.DebugPrint then print("AdminMultijobViewCharacterMenu- characterItems:", characterItems) end
    if Config.DebugPrint then print("AdminMultijobViewCharacterMenu- characterItem:", characterItem) end

    MenuData.CloseAll()

    local elements = {}
    table.insert(elements, { label = "View Job Assignments", value = "ViewJobAssignments", desc = "View this character's job assignments." })
    table.insert(elements, { label = "Add Job Assignment", value = "AddJobAssignment", desc = "Add a new job assignment." })
    table.insert(elements, { label = "Remove Job Assignment", value = "RemoveJobAssignment", desc = "Remove an existing job assignment." })

    MenuData.Open("default", GetCurrentResourceName(), "AdminMultijobViewCharMenu", {
		title = "Admin Multijob - Character",
		subtext = string.format("%s %s", characterItem.firstname, characterItem.lastname),
		align = "top-left",
		elements = elements,
        lastmenu = "AdminMultijobCharacterSelectionMenu",
	},

    function(data, menu)

        if data.current == "backup" then
            _G[data.trigger](characterItems)
        elseif (data.current.value) then
            if data.current.value == "ViewJobAssignments" then
                AdminMultijobViewCharacterJobAssignmentsMenu(characterItems, characterItem)
            elseif data.current.value == "AddJobAssignment" then
                AdminMultijobAddJobAssignmentMenu(characterItems, characterItem)
            elseif data.current.value == "RemoveJobAssignment" then
                AdminMultijobRemoveJobAssignmentMenu(characterItems, characterItem)
            end
        else
            MenuData.CloseAll()
        end

	end,
			
	function(data, menu)
		menu.close()
	end)

end

function AdminMultijobViewCharacterJobAssignmentsMenu(characterItems, characterItem)

    if Config.DebugPrint then print("AdminMultijobViewCharacterMenu- characterItem:", characterItem) end

    MenuData.CloseAll()

    -- Get the job assignments
    local result_promise = promise.new()
    jo.callback.triggerServer("CALLBACK:rainbow_core:Admin:Jobs:FetchJobAssignmentsForChar", function(result)
        result_promise:resolve(result)
    end, characterItem.charidentifier)
    local jobAssignments = Citizen.Await(result_promise)

    local elements = {}
    if jobAssignments and jobAssignments[1] then
        for k,v in pairs(jobAssignments) do
            local desc = string.format("Date Assigned: %s  |  Last Active: %s", convertDateValueToHumanReadable(v.dateCreated), convertDateValueToHumanReadable(v.dateLastActive))
            table.insert(elements, { label = v.job.label, value = "none", desc = desc })
        end
    else
        table.insert(elements, { label = "NO RESULTS", value = "backup", desc = "This character has no job assignments." })
    end

    MenuData.Open("default", GetCurrentResourceName(), "AdminMultijobCharSelectionMenu", {
		title = "Admin Multijob - View Assi's",
		subtext = string.format("%s %s", characterItem.firstname, characterItem.lastname),
		align = "top-left",
		elements = elements,
        lastmenu = "AdminMultijobViewCharacterMenu",
	},

    function(data, menu)

        if data.current == "backup" then
            _G[data.trigger](characterItems, characterItem)
        elseif(data.current.value) then
            print(data.current.value)
            -- TODO: nothing?
        else
            MenuData.CloseAll()
        end

	end,
			
	function(data, menu)
		menu.close()
	end)

end

function AdminMultijobAddJobAssignmentMenu(characterItems, characterItem)

    if Config.DebugPrint then print("AdminMultijobAddJobAssignmentMenu- characterItem:", characterItem) end

    MenuData.CloseAll()

    -- Get all jobs
    local result_promise = promise.new()
    jo.callback.triggerServer("CALLBACK:rainbow_core:Admin:Jobs:FetchAllJobs", function(result)
        result_promise:resolve(result)
    end)
    local jobs = Citizen.Await(result_promise)

    if Config.DebugPrint then print("AdminMultijobAddJobAssignmentMenu- jobs:", jobs) end

    -- sort by label
    table.sort(jobs, function(a, b)
        return a.label:lower() < b.label:lower()
    end)

    local elements = {}
    for k,v in pairs(jobs) do
        local desc = string.format("%s %s (%s)", v.name, v.grade, v.family)
        table.insert(elements, { label = v.label, value = v.id, desc = desc })
    end

    local characterName = string.format("%s %s", characterItem.firstname, characterItem.lastname)

    MenuData.Open("default", GetCurrentResourceName(), "AdminMultijobAddJobAssignmentMenu", {
		title = "Admin Multijob - Add Assi.",
		subtext = characterName,
		align = "top-left",
		elements = elements,
        lastmenu = "AdminMultijobViewCharacterMenu",
	},

    function(data, menu)

        if data.current == "backup" then
            _G[data.trigger](characterItems, characterItem)
        elseif(data.current.value) then

            local isConfirmed = dialogConfirmAddAssignment(data.current.label, characterName)

            if isConfirmed then
                if Config.DebugPrint then print("isConfirmed") end

                -- Send to server for adding
                TriggerServerEvent("rainbow_core:Jobs:Admin:AddAssignment", data.current.value, characterItem.charidentifier, characterName)
            end

            menu.close()

        else
            MenuData.CloseAll()
        end

	end,
			
	function(data, menu)
		menu.close()
	end)

end

function AdminMultijobRemoveJobAssignmentMenu(characterItems, characterItem)

    if Config.DebugPrint then print("AdminMultijobRemoveJobAssignmentMenu- characterItem:", characterItem) end

    MenuData.CloseAll()

    -- Get the job assignments
    local result_promise = promise.new()
    jo.callback.triggerServer("CALLBACK:rainbow_core:Admin:Jobs:FetchJobAssignmentsForChar", function(result)
        result_promise:resolve(result)
    end, characterItem.charidentifier)
    local jobAssignments = Citizen.Await(result_promise)

    local elements = {}
    if jobAssignments and jobAssignments[1] then
        for k,v in pairs(jobAssignments) do
            local desc = string.format("Date Assigned: %s  |  Last Active: %s", convertDateValueToHumanReadable(v.dateCreated), convertDateValueToHumanReadable(v.dateLastActive))
            table.insert(elements, { label = v.job.label, value = v.id, desc = desc, info = v })
        end
    else
        table.insert(elements, { label = "NO RESULTS", value = "backup", desc = "This character has no job assignments." })
    end

    local characterName = string.format("%s %s", characterItem.firstname, characterItem.lastname)

    MenuData.Open("default", GetCurrentResourceName(), "AdminMultijobRemoveJobAssignmentMenu", {
		title = "Admin Multijob - Remove Assi.",
		subtext = characterName,
		align = "top-left",
		elements = elements,
        lastmenu = "AdminMultijobViewCharacterMenu",
	},

    function(data, menu)

        if data.current == "backup" then
            _G[data.trigger](characterItems, characterItem)
        elseif(data.current.value) then

            local isConfirmed = dialogConfirmRemoveAssignment(data.current.label, characterName)

            if isConfirmed then
                if Config.DebugPrint then print("isConfirmed") end

                -- Send to server for removing
                TriggerServerEvent("rainbow_core:Jobs:Admin:RemoveAssignment", data.current.value, characterItem.charidentifier, characterName, data.current.info)
            end

            menu.close()

        else
            MenuData.CloseAll()
        end

	end,
			
	function(data, menu)
		menu.close()
	end)

end

---------

function dialogConfirmAddAssignment(jobLabel, characterName)
    local dialog = exports['rsg-input']:ShowInput({
        header = "Confirm?",
        submitText = "Confirm",
        inputs = {
            {
                text = string.format("Are you sure you want to add a job assignment of \"%s\" to character \"%s\"?", jobLabel, characterName),
                name = "confirmAdd",
                type = "radio",
                options = {
                    { value = "yes", text = "Yes, add." },
                    { value = "no", text = "No, nevermind." },
                },
            },
        },
    })

    if dialog ~= nil then
        if dialog.confirmAdd and dialog.confirmAdd == "yes" then
            return true
        end
    end

    return false
end

function dialogConfirmRemoveAssignment(jobLabel, characterName)
    local dialog = exports['rsg-input']:ShowInput({
        header = "Confirm?",
        submitText = "Confirm",
        inputs = {
            {
                text = string.format("Are you sure you want to remove the job assignment of \"%s\" from character \"%s\"?", jobLabel, characterName),
                name = "confirmRemove",
                type = "radio",
                options = {
                    { value = "yes", text = "Yes, remove." },
                    { value = "no", text = "No, nevermind." },
                },
            },
        },
    })

    if dialog ~= nil then
        if dialog.confirmRemove and dialog.confirmRemove == "yes" then
            return true
        end
    end

    return false
end

------------------------------------

AddEventHandler("onResourceStop", function(resourceName)
	if (GetCurrentResourceName() ~= resourceName) then
	  return
	end

    MenuData.CloseAll()

end)

function convertDateValueToHumanReadable(dateValue)
    local result_promise = promise.new()
    jo.callback.triggerServer("CALLBACK:rainbow_core:ConvertDate", function(result)
        result_promise:resolve(result)
    end, dateValue)
    return Citizen.Await(result_promise)
end