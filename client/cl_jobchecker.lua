VORPutils = {}
TriggerEvent("getUtils", function(utils)
    VORPutils = utils
    print = VORPutils.Print:initialize(print) --Initial setup 
end)


function _AbsolutelyHasJobInJoblistClient(jobList)
    local presentJobAssignment = LocalPlayer.state["Rainbow:Character:PresentJob"]
    if not presentJobAssignment then
        return false
    end
    return _UtilityJobIsInJoblist(presentJobAssignment.job.name, jobList)
end

function _AbsolutelyHasJobAndGradeInJobMatrixClient(jobMatrix)
    local presentJobAssignment = LocalPlayer.state["Rainbow:Character:PresentJob"]
    if not presentJobAssignment then
        return false
    end
    return _UtilityJobAndGradeIsInJobMatrix(presentJobAssignment.job.name, presentJobAssignment.job.grade, jobMatrix)
end

function _AbsolutelyHasJobAndGradeClient(_job, _jobGrade)
	-- if Config.DebugPrint then print("AbsolutelyHasJobAndGrade", job, _job, jobGrade, tonumber(_jobGrade)) end
    local presentJobAssignment = LocalPlayer.state["Rainbow:Character:PresentJob"]
    if not presentJobAssignment then
        return false
    end
    return _UtilityAbsolutelyJobAndGradeMatch(presentJobAssignment.job.name, _job, presentJobAssignment.job.grade, _jobGrade)
end

