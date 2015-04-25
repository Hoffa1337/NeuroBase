
include('shared.lua')
-- local scale = Vector(0.2, 0.2, 0.2)
function ENT:Initialize()
	
	-- local mat = Matrix()
	-- mat:Scale(scale)
	-- self:EnableMatrix("RenderMultiply", mat )
	self.Emitter = ParticleEmitter( self:GetPos() )

end

function ENT:Draw()
	
	-- self:SetPos( self:GetPos() - Vector( 0,0,16 ) )
	self:DrawModel()
	local scale = .5
	local particle = self.Emitter:Add( "particle/water/waterdrop_001a", self:LocalToWorld( Vector(-15,0,0) )  )
	if ( particle && self:WaterLevel()>1) then
	-- print("?=?=")
		particle:SetVelocity( self:GetVelocity()*-1 + self:GetRight() * math.random(-16,16)*scale )
		particle:SetDieTime( math.Rand( 1, 3 ) )
		particle:SetStartAlpha( math.Rand( 5, 11 ) )
		particle:SetEndAlpha( 0 )
		particle:SetStartSize( math.Rand( 5, 12 ) * scale )
		particle:SetEndSize( math.Rand( 21, 32 ) ) 
		particle:SetRoll( math.Rand(-11.1, 11.1) * scale )
		particle:SetRollDelta( math.Rand(-1, 1) )
		particle:SetColor( 255,255,255 ) 
		particle:SetAirResistance( 150 ) 
		particle:SetGravity( Vector(math.random(-35,35),math.random(-35,35),15) )
		
	end 
			
end

function ENT:OnRemove()
end



