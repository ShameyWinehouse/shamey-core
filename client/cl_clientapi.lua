
exports("initiate", function()
    local self = {}
    
    self.AbsolutelyHasJobInJoblistClient = _AbsolutelyHasJobInJoblistClient
    self.AbsolutelyHasJobAndGradeInJobMatrixClient = _AbsolutelyHasJobAndGradeInJobMatrixClient
    self.AbsolutelyHasJobAndGradeClient = _AbsolutelyHasJobAndGradeClient
	self.UtilityJobIsInJoblist = _UtilityJobIsInJoblist
	self.UtilityAbsolutelyJobAndGradeMatch = _UtilityAbsolutelyJobAndGradeMatch
	self.UtilitySetPedUnattackable = _UtilitySetPedUnattackable
    self.GetTimeOfOneFrame = _GetTimeOfOneFrame
    self.IsPositionInsidePolygon = _IsPositionInsidePolygon
    self.CanPedStartInteraction = _CanPedStartInteraction

    self.StartParticleFx = _StartParticleFx
    self.StartParticleFxSpecific = _StartParticleFxSpecific
    self.StopThisParticleFx = _StopThisParticleFx

    return self
end)