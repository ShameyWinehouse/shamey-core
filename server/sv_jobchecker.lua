VorpCore = {}
TriggerEvent("getCore", function(core)
    VorpCore = core
end)
local VORPutils = {}
TriggerEvent("getUtils", function(utils)
    VORPutils = utils
    print = VORPutils.Print:initialize(print) --Initial setup 
end)


-------- API

function AbsolutelyHasJobInJoblistServer(_target, jobList)
    local presentJobAssignment = Player(_target).state["Rainbow:Character:PresentJob"]
    if not presentJobAssignment then
        return false
    end
    return _UtilityJobIsInJoblist(presentJobAssignment.job.name, jobList)
end

function AbsolutelyHasJobAndGradeInJobMatrixServer(_target, _jobMatrix)

	local presentJobAssignment = Player(_target).state["Rainbow:Character:PresentJob"]
    if not presentJobAssignment then
        return false
    end
    return _UtilityJobAndGradeIsInJobMatrix(presentJobAssignment.job.name, presentJobAssignment.job.grade, _jobMatrix)
end

function AbsolutelyHasJobAndGradeServer(_target, _job, _jobGrade)
	-- if Config.DebugPrint then print("AbsolutelyHasJobAndGrade", _target, job, _job, jobGrade, tonumber(_jobGrade)) end

	local presentJobAssignment = Player(_target).state["Rainbow:Character:PresentJob"]
	if not presentJobAssignment then
        return false
    end
	
	return presentJobAssignment.job.name == _job and presentJobAssignment.job.grade == tonumber(_jobGrade)
end

--------

function findAllPlayersWithJobInJobArray(jobArray)

	-- if Config.DebugPrint then print("findAllPlayersWithJobInJobArray - jobArray", jobArray) end

	local fullPlayerList = getFullPlayerList()
	
    local playerListWithJob = {}
    for i,v in pairs(fullPlayerList) do 

		local presentJobAssignment = Player(v).state["Rainbow:Character:PresentJob"]

		-- if Config.DebugPrint then print("findAllPlayersWithJobInJobArray - v, presentJobAssignment", v, presentJobAssignment) end

		if presentJobAssignment then

			for c,k in pairs(jobArray) do 
				if presentJobAssignment.job.name == k then
					table.insert(playerListWithJob, v)
				end 
			end

		end
    end

    -- if Config.DebugPrint then print("findAllPlayersWithJobInJobArray - playerListWithJob", playerListWithJob) end
    return playerListWithJob
end




-------- UTILITY

function getFullPlayerList()
	-- if Config.DebugPrint then print("getFullPlayerList: ", GetPlayers()) end
	return GetPlayers()
end

function findJobById(id)
	for k,v in pairs(Jobs) do
		if v.id == id then
			return v
		end
	end
end

function findJobByName(name)
	for k,v in pairs(Jobs) do
		if v.name == name then
			return v
		end
	end
end