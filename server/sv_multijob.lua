

-- General list of all jobs
Jobs = {}

-- Keeps track of job-switching cooldowns.
-- The key is the charId. The value is a JobSwitchCooldown object which has the charId, jobId, & cooldown time.
local JobSwitchCooldowns = {}

--------

-- Load all jobs upon load
Citizen.CreateThread(function()
	loadJobs()
end)

jo.callback.register("CALLBACK:rainbow_core:Admin:Jobs:Lookup", function(source, searchText)

    if Config.DebugPrint then print("CALLBACK:rainbow_core:Admin:Jobs:Lookup", searchText) end

    local result = MySQL.query.await("SELECT c.charidentifier,c.firstname,c.lastname,UNIX_TIMESTAMP(c.LastLogin) as LastLogin FROM characters c WHERE LOWER(c.firstname) LIKE LOWER(@searchText) OR LOWER(c.lastname) LIKE LOWER(@searchText) ORDER BY c.firstname", 
	    { ['@searchText'] = "%"..searchText.."%" })

    if Config.DebugPrint then print("CALLBACK:rainbow_core:Admin:Jobs:Lookup - result:", result) end

    return result
end)

jo.callback.register("CALLBACK:rainbow_core:Admin:Jobs:FetchJobAssignmentsForChar", function(source, charId)

    if Config.DebugPrint then print("CALLBACK:rainbow_core:Admin:Jobs:FetchJobAssignmentsForChar", charId) end

    local jobAssignments = fetchJobAssignmentsByCharId(charId)

    -- if Config.DebugPrint then print("CALLBACK:rainbow_core:Admin:Jobs:FetchJobAssignmentsForChar - jobAssignments:", jobAssignments) end

    return jobAssignments
end)

jo.callback.register("CALLBACK:rainbow_core:Admin:Jobs:FetchJobAssignmentsForThisChar", function(source)

    if Config.DebugPrint then print("CALLBACK:rainbow_core:Admin:Jobs:FetchJobAssignmentsForThisChar") end

	local Character = VorpCore.getUser(source).getUsedCharacter
    local charIdentifier = Character.charIdentifier

    local jobAssignments = fetchJobAssignmentsByCharId(charIdentifier)

    -- if Config.DebugPrint then print("CALLBACK:rainbow_core:Admin:Jobs:FetchJobAssignmentsForThisChar - jobAssignments:", jobAssignments) end

    return jobAssignments
end)

jo.callback.register("CALLBACK:rainbow_core:Admin:Jobs:FetchAllJobs", function(source)
    return Jobs
end)

-- We have to do this here bc we can't access `os` on the client.
jo.callback.register("CALLBACK:rainbow_core:ConvertDate", function(source, dateValue)
    if Config.DebugPrint then print("CALLBACK:rainbow_core:ConvertDate", dateValue) end
    -- *t
    if Config.DebugPrint then print("CALLBACK:rainbow_core:ConvertDate - dfsdfs", os.date("*t", dateValue)) end
    return os.date("%m/%d/%Y", dateValue)
end)

-- jo.callback.register("CALLBACK:rainbow_core:Admin:Jobs:AddAssignment", function(source, jobId, charId)
    
	

-- 	return true
-- end)


--------

RegisterCommand("multijobAdmin", function(source, args, rawCommand)

    local _source = source

    if Config.DebugPrint then print("multijobAdmin", args) end

    -- if args[1] then
    --     TriggerServerEvent("rainbow_core:Jobs:SwitchJob", args[1])
    -- else
    --     VORPcore.NotifyRightTip(string.format("Your present job is: %s", LocalPlayer.state["Rainbow:Character:PresentJob"]), 6 * 1000)
    -- end

    

    TriggerClientEvent("rainbow_core:Jobs:Admin:Command:multijobAdmin", _source, args)

    
end, true)

--------

RegisterServerEvent("vorp:SelectedCharacter")
AddEventHandler("vorp:SelectedCharacter", function(_source)
	loadJobAssignments(_source)
end)

if Config.DebugCommands then
	RegisterServerEvent("rainbow_core:Debug:LoadJobAssignments", function(args)
        local _source = source
		loadJobAssignments(_source)
	end)
end

--------

-------- MULTIJOB

RegisterServerEvent("rainbow_core:Jobs:SwitchJob")
AddEventHandler("rainbow_core:Jobs:SwitchJob", function(jobAssignmentId)
    local _source = source


	-- Get all of the player's job assignments
	local playersJobAssignments = Player(_source).state["Rainbow:Character:JobAssignments"]

	-- Get the target job assignment
	local targetJobAssignment
	for k,v in pairs(playersJobAssignments) do
		if v.id == jobAssignmentId then
			targetJobAssignment = v
			break
		end
	end

	if not targetJobAssignment then
		print("Couldn't find job assignment:", _source, jobAssignmentId)
		return
	end


	-- FIRST, check that this character CAN switch into this job.
	local canSwitchToThisJob = false

	local Character = VorpCore.getUser(_source).getUsedCharacter
    local charIdentifier = Character.charIdentifier

	if Config.DebugPrint then print("JobSwitchCooldowns", JobSwitchCooldowns) end
	if Config.DebugPrint then print("JobSwitchCooldowns[charIdentifier]", JobSwitchCooldowns[charIdentifier]) end

	-- Check the cooldown
	if not JobSwitchCooldowns[charIdentifier] then
		-- No cooldown for this character
		if Config.DebugPrint then print("no cooldown") end
		canSwitchToThisJob = true
	else

		-- There is a cooldown. But are they just switching back into the same job? (we need to accommodate relogs)

		local cooldown = JobSwitchCooldowns[charIdentifier]

		if targetJobAssignment.job.id == cooldown.jobId then
			-- It's the same job; cooldown doesn't apply
			if Config.DebugPrint then print("same job") end
			canSwitchToThisJob = true
		else

			local currentTime = os.time()
			if Config.DebugPrint then print("currentTime", currentTime) end

			-- If the cooldown is still in effect
			if JobSwitchCooldowns[charIdentifier].cooldownExpirationTime > currentTime then
				-- Get the remaining time
				local timeLeft = JobSwitchCooldowns[charIdentifier].cooldownExpirationTime - currentTime
				local timeLeftInMilliseconds = math.tointeger(timeLeft * 1000)
				if Config.DebugPrint then print("timeLeft", timeLeft, timeLeftInMilliseconds) end
				-- Alert & abort
				jo.notif.rightError(_source, string.format("You can switch jobs again in: %s", jo.date.convertMsToInterval(timeLeftInMilliseconds)))
				return
			else
				-- Cooldown is expired; clear it
				if Config.DebugPrint then print("cooldown expired") end
				JobSwitchCooldowns[charIdentifier] = nil
				canSwitchToThisJob = true
			end
		end
	end

	if not canSwitchToThisJob then
		-- Alert & abort
		jo.notif.rightError(_source, "You cannot switch jobs.")
		return
	end


	-- Check they're not "switching" to the already-present job
	if Player(_source).state["Rainbow:Character:PresentJob"] and Player(_source).state["Rainbow:Character:PresentJob"].id then
		if jobAssignmentId == Player(_source).state["Rainbow:Character:PresentJob"].id then
			jo.notif.rightError(_source, "You can't switch to the job in which you're already present.")
			return
		end
	end

	
	-- All checks complete. Moving forward!


	-- Set the "present" job on the player statebag
	Player(_source).state["Rainbow:Character:PresentJob"] = targetJobAssignment

	-- Give the player a noti
	TriggerClientEvent("vorp:TipRight", _source, string.format("You have switched jobs to: %s", targetJobAssignment.job.label), 10 * 1000)
	
	-- Set the cooldown time (and don't reset it if it already exists)
	if not JobSwitchCooldowns[charIdentifier] then
		local cooldownExpirationTime = (os.time() + (Config.Multijob.CooldownTimeInMinutes * (60))) -- NOTE: os.time() is in seconds
		JobSwitchCooldowns[charIdentifier] = JobSwitchCooldown:new(charIdentifier, targetJobAssignment.job.id, cooldownExpirationTime)
	end

	-- Alert other scripts (both server and client sides)
	TriggerEvent("rainbow_core:Jobs:Server:OnSwitchedJob", _source, targetJobAssignment)
	TriggerClientEvent("rainbow_core:Jobs:Client:OnSwitchedJob", _source, targetJobAssignment)

	-- Log to Discord
	logJobSwitch(_source, targetJobAssignment)

	-- Update the `date_last_active` column
	updateJobActivity(targetJobAssignment.id)

end)

RegisterServerEvent("rainbow_core:Jobs:Admin:AddAssignment")
AddEventHandler("rainbow_core:Jobs:Admin:AddAssignment", function(jobId, charId, characterName)
    local _source = source

	if Config.DebugPrint then print("rainbow_core:Jobs:Admin:AddAssignment", jobId, charId) end

	-- TODO: Double-check they've got the admin rights

	-- Double-check the character doesn't have the maximum num. of jobs
	local currentJobAssignmentsPreAdding = fetchJobAssignmentsByCharId(charId)
	if currentJobAssignmentsPreAdding and #currentJobAssignmentsPreAdding >= 2 then
		-- Let the admin know that we can't do this
		TriggerClientEvent("vorp:TipRight", _source, "NOTICE: Could not add the assignment. The character already has the maximum number of jobs.", 10 * 1000)
		return
	end

	
	-- Insert the new record into the DB
	insertJobAssignment(jobId, charId)


	-- Check if the target user is currently online
	local user = VorpCore.getUserByCharId(charId)
	if Config.DebugPrint then print("rainbow_core:Jobs:Admin:AddAssignment - user:", DumpTable(user)) end
	if user then
		local userSource = user.source
		if Config.DebugPrint then print("rainbow_core:Jobs:Admin:AddAssignment - userSource:", userSource) end
		if userSource then
			-- Reload the job assignments for the target user
			loadJobAssignments(userSource)
			Wait(100)
			-- Let the target user know
			TriggerClientEvent("vorp:TipRight", userSource, "NOTICE: An admin has changed your job assignments.", 10 * 1000)
		end
	end


	-- Let the admin know it was successful
	TriggerClientEvent("vorp:TipRight", _source, "The new job assignment was successfully added.", 10 * 1000)

	-- Log to Discord
	logAdminAddAssignment(_source, charId, characterName, jobId)
end)

RegisterServerEvent("rainbow_core:Jobs:Admin:RemoveAssignment")
AddEventHandler("rainbow_core:Jobs:Admin:RemoveAssignment", function(jobAssignmentId, charId, characterName, jobAssignment)
    local _source = source

	if Config.DebugPrint then print("rainbow_core:Jobs:Admin:RemoveAssignment", jobAssignmentId, charId) end

	-- TODO: Double-check they've got the admin rights


	-- Delete the record from the DB
	deleteJobAssignment(jobAssignmentId)


	-- Check if the target user is currently online
	local user = VorpCore.getUserByCharId(charId)
	if user then
		local userSource = user.source
		if Config.DebugPrint then print("rainbow_core:Jobs:Admin:RemoveAssignment - userSource:", userSource) end
		if userSource then
			-- Reload the job assignments for the target user
			loadJobAssignments(userSource)
			Wait(100)
			-- Let the target user know
			TriggerClientEvent("vorp:TipRight", userSource, "NOTICE: An admin has changed your job assignments.", 10 * 1000)
		end
	end


	-- Let the admin know it was successful
	TriggerClientEvent("vorp:TipRight", _source, "The job assignment was successfully removed.", 10 * 1000)

	-- Log to Discord
	logAdminRemoveAssignment(_source, charId, characterName, jobAssignment.job.id)
end)

-- RegisterServerEvent("rainbow_core:Admin:Jobs:Lookup")
-- AddEventHandler("rainbow_core:Admin:Jobs:Lookup", function(searchText)
--     local _source = source

--     local result = MySQL.query.await("SELECT c.charidentifier,c.firstname,c.lastname,c.LastLogin FROM characters c WHERE c.firstname LIKE '%@searchText%' OR c.lastname LIKE '%@searchText%' ORDER BY c.firstname", 
-- 	    { ['@searchText'] = searchText })

--     if result then

--     end
-- end)


-------- FUNCTIONS


function logJobSwitch(_source, jobAssignment)

	local Character = VorpCore.getUser(_source).getUsedCharacter
    local charIdentifier = Character.charIdentifier
    local fullName = string.format("%s %s", Character.firstname, Character.lastname)

	VorpCore.AddWebhook("A character switched into a job.", Config.MultijobWebhook, string.format(
        "**Character:** %s (CharId %s)\n**Job Assignment:** \"%s\" (`%s %s`)", 
        fullName, charIdentifier, jobAssignment.job.label, jobAssignment.job.name, jobAssignment.job.grade))
end

function logAdminAddAssignment(_source, charId, characterName, jobId)

	local AdminCharacter = VorpCore.getUser(_source).getUsedCharacter
    local AdminCharIdentifier = AdminCharacter.charIdentifier
	local AdminSteamName = GetPlayerName(_source)
    local AdminCharacterFullName = string.format("%s %s", AdminCharacter.firstname, AdminCharacter.lastname)

	local job = findJobById(jobId)

	VorpCore.AddWebhook("An admin added a job assignment.", Config.MultijobWebhook, string.format(
        "**Target Character:** %s (CharId %s)\n**Job Assignment:** \"%s\" (`%s %s`)\n**Admin Steam Identifier:** `%s`\n**Admin Steam Name:** `%s`\n**Admin Character:** %s (CharId %s)", 
        characterName, charId, job.label, job.name, job.grade, AdminCharacter.identifier, AdminSteamName, AdminCharacterFullName, AdminCharIdentifier))
end

function logAdminRemoveAssignment(_source, charId, characterName, jobId)

	local AdminCharacter = VorpCore.getUser(_source).getUsedCharacter
    local AdminCharIdentifier = AdminCharacter.charIdentifier
	local AdminSteamName = GetPlayerName(_source)
    local AdminCharacterFullName = string.format("%s %s", AdminCharacter.firstname, AdminCharacter.lastname)

	local job = findJobById(jobId)

	VorpCore.AddWebhook("An admin removed a job assignment.", Config.MultijobWebhook, string.format(
        "**Target Character:** %s (CharId %s)\n**Job Assignment:** \"%s\" (`%s %s`)\n**Admin Steam Identifier:** `%s`\n**Admin Steam Name:** `%s`\n**Admin Character:** %s (CharId %s)", 
        characterName, charId, job.label, job.name, job.grade, AdminCharacter.identifier, AdminSteamName, AdminCharacterFullName, AdminCharIdentifier))
end

--------

-- Loads all the jobs for reference
function loadJobs()

    if Config.DebugPrint then print("loadJobs()") end


    local result = MySQL.query.await("SELECT * FROM jobs", { })

	if Config.DebugPrint then print("loadJobs() - result", result) end

	if result then
		local foundJobs = {}
		for k,v in pairs(result) do
			local foundJob = Job:new(v.id, v.name, v.grade, v.label, v.family)
			table.insert(foundJobs, foundJob)
		end
		Jobs = foundJobs
	end

	if Config.DebugPrint then print("loadJobs() - Jobs[1]:", Jobs[1]) end

end

-- Loaded per-character
function loadJobAssignments(_source)

    if Config.DebugPrint then print("loadJobAssignments()", _source) end

	local Character = VorpCore.getUser(_source).getUsedCharacter
	local charIdentifier = Character.charIdentifier

    local jobAssignments = fetchJobAssignmentsByCharId(charIdentifier)
    if jobAssignments then
        Player(_source).state["Rainbow:Character:JobAssignments"] = jobAssignments
    else
        Player(_source).state["Rainbow:Character:JobAssignments"] = nil
    end

	if Config.DebugPrint then print("loadJobAssignments() - Player(_source).state['Rainbow:Character:JobAssignments']", Player(_source).state["Rainbow:Character:JobAssignments"]) end

end

function fetchJobAssignmentsByCharId(charIdentifier)

    if Config.DebugPrint then print("fetchJobAssignmentsByCharId") end

    local result = MySQL.query.await("SELECT id,job_id,character_id,UNIX_TIMESTAMP(date_created) as date_created,UNIX_TIMESTAMP(date_last_active) as date_last_active FROM job_assignments WHERE character_id = @charIdentifier", 
	    { ['@charIdentifier'] = charIdentifier })

	if result then
		local CharJobAssignments = {}
		for k,v in pairs(result) do
			local jobAssignment = JobAssignment:new(v.id, v.character_id, findJobById(v.job_id), v.date_created, v.date_last_active)
			table.insert(CharJobAssignments, jobAssignment)
		end
        return CharJobAssignments
	end

    return false

end

function insertJobAssignment(jobId, charId)

    if Config.DebugPrint then print("insertJobAssignment") end

    local result = MySQL.query.await("INSERT INTO job_assignments(job_id, character_id) VALUES(@jobId, @charIdentifier)", 
	    { ['@jobId'] = jobId, ['@charIdentifier'] = charId })

	if result then
		return true
	end

    return false

end

function deleteJobAssignment(jobAssignmentId)

	if Config.DebugPrint then print("deleteJobAssignment") end

    local result = MySQL.query.await("DELETE FROM job_assignments WHERE id=@jobAssignmentId", 
	    { ['@jobAssignmentId'] = jobAssignmentId })

	if result then
		return true
	end

    return false
	
end

function updateJobActivity(jobAssignmentId)
	if Config.DebugPrint then print("updateJobActivity") end

    local result = MySQL.query.await("UPDATE job_assignments SET date_last_active=NOW() WHERE id=@jobAssignmentId", 
	    { ['@jobAssignmentId'] = jobAssignmentId })

	if result then
		return true
	end

    return false
end