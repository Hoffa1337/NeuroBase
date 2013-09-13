
include('shared.lua')

function ENT:Initialize()
end

function ENT:Draw()
	self.Entity:DrawModel()
end


function ENT:OnRemove()
	
	surface.PlaySound( "weapons/mortar/mortar_explode2.wav" )
	

end


