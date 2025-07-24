
JobSwitchCooldown = tclass("JobSwitchCooldown")

function JobSwitchCooldown:init(charId, jobId, cooldownExpirationTime)
    self.charId = charId
    self.jobId = jobId
    self.cooldownExpirationTime = cooldownExpirationTime
end

