
include('shared.lua')
-- local scale = Vector(0.2, 0.2, 0.2)
function ENT:Initialize()
	
	-- local mat = Matrix()
	-- mat:Scale(scale)
	-- self:EnableMatrix("RenderMultiply", mat )


end

function ENT:Draw()
	
	-- self:SetPos( self:GetPos() - Vector( 0,0,16 ) )
	self:DrawModel()

end

function ENT:OnRemove()
end



