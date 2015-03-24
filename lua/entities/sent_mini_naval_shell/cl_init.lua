
include('shared.lua')

function ENT:Initialize()

end

function ENT:Draw()
	-- self.Entity:DrawModel()
	-- local dlight = DynamicLight( self:EntIndex() )
	-- if ( dlight ) then

		-- local c = Color( 191+math.random(-5,5), 64+math.random(-5,5), 0, 100 )

		-- dlight.Pos = self:GetPos()
		-- dlight.r = c.r
		-- dlight.g = c.g
		-- dlight.b = c.b
		-- dlight.Brightness = 1 + math.Rand( 0, 1 )
		-- dlight.Decay = 0.1 + math.Rand( 0.01, 0.1 )
		-- dlight.Size = 128
		-- dlight.DieTime = CurTime() + 0.025

	-- end
end

function ENT:OnRemove()
end



