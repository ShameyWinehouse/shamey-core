
-- `job` should be a string of the job
-- `jobList` should be a simple table of job strings (e.g. {"blacksmith",})
exports("UtilityJobIsInJoblist", _UtilityJobIsInJoblist)
function _UtilityJobIsInJoblist(job, jobList)
	-- if Config.DebugPrint then print("UtilityJobIsInJoblist", job, jobList) end

    if jobList and jobList ~= 0 and #jobList > 0 then
        for k, v in pairs(jobList) do
			-- if Config.DebugPrint then print("UtilityJobIsInJoblist - v == job: ", v, job) end
            if v == job then
                return true
            end
        end
    end

    return false
end

exports("UtilityJobAndGradeIsInJobMatrix", _UtilityJobAndGradeIsInJobMatrix)
function _UtilityJobAndGradeIsInJobMatrix(job, grade, jobMatrix)

    if jobMatrix and jobMatrix ~= 0 and #jobMatrix > 0 then
        for k, v in pairs(jobMatrix) do
            if v.job == job and v.jobGrade == grade then
                return true
            end
        end
    end

    return false
end

exports("UtilityAbsolutelyJobAndGradeMatch", _UtilityAbsolutelyJobAndGradeMatch)
function _UtilityAbsolutelyJobAndGradeMatch(_job1, _job2, _jobGrade1, _jobGrade2)
	return _job1 == _job2 and tonumber(_jobGrade1) == tonumber(_jobGrade2)
end