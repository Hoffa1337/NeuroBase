
include('shared.lua')
local matHeatWave		= Material( "sprites/heatwave" )
local matFire			= Material( "effects/fire_cloud1" )

function ENT:Initialize()
	
	local pos = self:GetPos()
	self.Emitter = ParticleEmitter( pos )
	self.Seed = math.Rand( 0, 10000 )
	
end

function ENT:Draw()

	self.Entity:DrawModel()
	self.OnStart = self.OnStart or CurTime()
	self:EffectDraw_fire()
	
end

function ENT:EffectDraw_fire()
	
	for i=1,3 do
	
		local particle = self.Emitter:Add( "particle/smokesprites_000"..math.random(1,9), self:GetPos() )

		if ( particle ) then
			
			particle:SetVelocity( self:GetVelocity() + self:GetForward() * -100 + Vector( math.Rand( -1.5,1.5),math.Rand( -1.5,1.5),math.Rand( 2.5,15.5)  ) )
			particle:SetDieTime( math.Rand( 4, 7 ) )
			particle:SetStartAlpha( math.Rand( 45, 55 ) )
			particle:SetEndAlpha( 0 )
			particle:SetStartSize( math.Rand( 5, 8 ) )
			particle:SetEndSize( math.Rand( 160, 210 ) )
			particle:SetRoll( math.Rand( 0, 360 ) )
			particle:SetRollDelta( math.Rand( -1, 1 ) )
			particle:SetColor( math.Rand( 35, 45 ), math.Rand( 35, 45 ), math.Rand( 35, 45 ) ) 
			particle:SetAirResistance( 100 ) 
			particle:SetGravity( VectorRand():GetNormalized()*math.Rand(10, 15)+Vector(0,0,math.random(110, 190)) ) 	

		end
		
	end
	
	// Thanks garry :D
	local vOffset = self:GetPos() + self:GetForward() * -83
	local vNormal = (vOffset - self:GetPos()):GetNormalized()

	local scroll = self.Seed + (CurTime() * -10)
	
	local Scale = math.Clamp( (CurTime() - self.OnStart) * 5, 0, 1 )
		
	render.SetMaterial( matFire )
	
	render.StartBeam( 3 )
		render.AddBeam( vOffset, 8 * Scale, scroll, Color( 0, 0, 255, 128) )
		render.AddBeam( vOffset + vNormal * 60 * Scale, 16 * Scale, scroll + 1, Color( 255, 255, 255, 128) )
		render.AddBeam( vOffset + vNormal * 148 * Scale, 16 * Scale, scroll + 3, Color( 255, 255, 255, 0) )
	render.EndBeam()
	
	scroll = scroll * 0.5
	
	render.UpdateRefractTexture()
	render.SetMaterial( matHeatWave )
	render.StartBeam( 3 )
		render.AddBeam( vOffset, 8 * Scale, scroll, Color( 0, 0, 255, 128) )
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
