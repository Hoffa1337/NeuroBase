
include('shared.lua')

function ENT:Initialize()
	
	self:SetLegacyTransform( false )
	self:SetModelScale( .15, .1 )
	
end

function ENT:Draw()
	
	
	self:DrawModel()

end

function ENT:OnRemove()
end



