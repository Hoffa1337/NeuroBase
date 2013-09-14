ENT.Spawnable			= false
ENT.AdminSpawnable		= false

include('shared.lua')

local matHeatWave		= Material( "sprites/heatwave" )
local matFire			= Material( "effects/fire_cloud1" )

function ENT:Initialize()

	local pos = self:GetPos() + self:GetForward() * -55
	self.Emitter = ParticleEmitter( pos )
	self.Seed = math.Rand( 0, 10000 )

end

function ENT:Draw()

	self.Entity:DrawModel()
	self.OnStart = self.OnStart or CurTime()
	

	self:EffectDraw_fire()
	
	
end
function ENT:OnRemove()

end

function ENT:EffectDraw_fire()
	
	local pos = self:LocalToWorld( Vector( -55, 0, 11 ) ) -- self:GetPos() + self:GetForward() * -200
	
	for i=1,3 do
	
		local particle = self.Emitter:Add( "particle/smokesprites_000"..math.random(1,9), pos )

		if ( particle ) then
			
			particle:SetVelocity( (self:GetVelocity()/10) *-1 + Vector( math.Rand( -2.5,2.5),math.Rand( -2.5,2.5),math.Rand( 2.5,15.5)  ) + self:GetForward()*-280 )
			particle:SetDieTime( math.Rand( 2, 5 ) )
			particle:SetStartAlpha( math.Rand( 35, 65 ) )
			particle:SetEndAlpha( 0 )
			-- particle:EnableCollisions( true )
			particle:SetStartSize( math.Rand( 15, 17 ) )
			particle:SetEndSize( math.Rand( 125, 255 ) )
			particle:SetRoll( math.Rand( 0, 360 ) )
			particle:SetRollDelta( math.Rand( -1, 1 ) )
			particle:SetColor( math.Rand( 225, 255 ), math.Rand( 225, 255 ), math.Rand( 225, 255 ) ) 
			particle:SetAirResistance( 100 ) 
			particle:SetGravity( self:GetForward() * -500 + VectorRand():GetNormalized()*math.Rand(-140, 140)+Vector(0,0,math.random(-15, 15)) ) 	

		end
		
	end
	
	// Thanks garry :D
	local vOffset = self:GetPos() + self:GetForward() * -55 + self:GetUp()*8
	local vNormal = (vOffset - self:GetPos()):GetNormalized()

	local scroll = self.Seed + (CurTime() * -10)
	
	local Scale = 2 -- math.Clamp( (CurTime() - self.OnStart) * 5, 0, 1 )
		
	render.SetMaterial( matFire )
	
	render.StartBeam( 3 )
		render.AddBeam( vOffset, 32 * Scale, scroll, Color( 0, 0, 255, 128) )
		render.AddBeam( vOffset + vNormal * 60 * Scale, 16 * Scale, scroll + 1, Color( 255, 255, 255, 128) )
		render.AddBeam( vOffset + vNormal * 148 * Scale, 16 * Scale, scroll + 3, Color( 255, 255, 255, 0) )
	render.EndBeam()
	
	scroll = scroll * 0.5
	
	render.UpdateRefractTexture()
	render.SetMaterial( matHeatWave )
	render.StartBeam( 3 )
		render.AddBeam( vOffset, 45 * Scale, scroll, Color( 0, 0, 255, 128) )
		render.AddBeam( vOffset + vNormal * 16 * Scale, 16 * Scale, scroll + 2, Color( 255, 255, 255, 255) )
		render.AddBeam( vOffset + vNormal * 64 * Scale, 24 * Scale, scroll + 5, Color( 0, 0, 0, 0) )
	render.EndBeam()
	
	
	scroll = scroll * 1.3
	render.SetMaterial( matFire )
	render.StartBeam( 3 )
		render.AddBeam( vOffset, 8 * Scale, scroll, Color( 0, 0, 255, 128) )
		render.AddBeam( vOffset + vNormal * 32 * Scale, 8 * Scale, scroll + 1, Color( 255, 255, 255, 128) )
		render.AddBeam( vOffset + vNormal * 108 * Scale, 8 * Scale, scroll + 3, Color( 255, 255, 255, 0) )
	render.EndBeam()
	
end
function ENT:Think()
end

function ENT:OnRestore()
end
