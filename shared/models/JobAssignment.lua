
JobAssignment = tclass("JobAssignment")

function JobAssignment:init(id, characterId, job, dateCreated, dateLastActive)
    self.id = id
    self.characterId = name
    self.job = job
    self.dateCreated = dateCreated
    self.dateLastActive = dateLastActive
end

-- function Window:cap()
--     self.width = math.min(self.width, Window.width)
--     self.height = math.min(self.height, Window.height)
-- end