
Job = tclass("Job")

function Job:init(id, name, grade, label, family)
    self.id = id
    self.name = name
    self.grade = grade
    self.label = label
    self.family = family
end

-- function Window:cap()
--     self.width = math.min(self.width, Window.width)
--     self.height = math.min(self.height, Window.height)
-- end