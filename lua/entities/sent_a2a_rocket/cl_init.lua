ENT.Spawnable			= false
ENT.AdminSpawnable		= false

include('shared.lua')

local matHeatWave		= Material( "sprites/heatwave" )
local matFire			= Material( "effects/fire_cloud1" )
local emitter = ParticleEmitter(Vector(0, 0, 0))

function ENT:Initialize()

	local pos = self:GetPos() + self:GetForward() * -55
	self.Emitter = ParticleEmitter( pos, false )
	self.Seed = math.Rand( 0, 10000 )
	self.cooltime = CurTime()

end

function ENT:Draw()

	self.Entity:DrawModel()
	self.OnStart = self.OnStart or CurTime()
	

	self:EffectDraw_fire()
	
	
end
function ENT:OnRemove()

end

function ENT:EffectDraw_fire()
	/*
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
	*/
end

function ENT:Think()
	if (self.cooltime < CurTime()) then
		local smoke = emitter:Add("effects/smoke_a", self:GetPos() + self:GetForward()*-50)
		smoke:SetVelocity(self:GetForward()*-800)
		smoke:SetDieTime(math.Rand(.9,1.2))
		smoke:SetStartAlpha(math.Rand(200,240))
		smoke:SetEndAlpha(0)
		smoke:SetStartSize(math.random(14,18))
		smoke:SetEndSize(math.random(66,99))
		smoke:SetRoll(math.Rand(180,480))
		smoke:SetRollDelta(math.Rand(-2,2))
		smoke:SetGravity( Vector( 0, math.random(1,90), math.random(51,155) ) )
		smoke:SetColor(50, 50, 50)
		smoke:SetAirResistance(60)

		local fire = emitter:Add("effects/smoke_a", self:GetPos() + self:GetForward()*-50)
		fire:SetVelocity(self:GetForward()*-10)
		fire:SetDieTime(math.Rand(.05,.1))
		fire:SetStartAlpha(math.Rand(222,255))
		fire:SetEndAlpha(0)
		fire:SetStartSize(math.random(11,14))
		fire:SetEndSize(math.random(20,33))
		fire:SetAirResistance(150)
		fire:SetRoll(math.Rand(180,480))
		fire:SetRollDelta(math.Rand(-3,3))
		fire:SetStartLength(15)
		fire:SetColor(255,100,0)
		fire:SetEndLength(math.Rand(100, 150))

		local fire = emitter:Add("effects/smoke_a", self:GetPos() + self:GetForward()*-50)
		fire:SetVelocity(self:GetForward()*-10)
		fire:SetDieTime(math.Rand(.05,.1))
		fire:SetStartAlpha(math.Rand(222,255))
		fire:SetEndAlpha(0)
		fire:SetStartSize(math.random(11,14))
		fire:SetEndSize(math.random(20,33))
		fire:SetAirResistance(150)
		fire:SetRoll(math.Rand(180,480))
		fire:SetRollDelta(math.Rand(-3,3))
		fire:SetColor(255,110,0)

		local fire = emitter:Add("effects/yellowflare", self:GetPos() + self:GetForward()*-50)
		fire:SetVelocity(self:GetForward()*-10)
		fire:SetDieTime(math.Rand(.03,.05))
		fire:SetStartAlpha(math.Rand(222,255))
		fire:SetEndAlpha(0)
		fire:SetStartSize(math.random(77,88))
		fire:SetEndSize(math.random(99,100))
		fire:SetAirResistance(150)
		fire:SetRoll(math.Rand(180,480))
		fire:SetRollDelta(math.Rand(-3,3))
		fire:SetColor(255,120,0)

		self.cooltime = CurTime() + .025
	end
end

function ENT:OnRestore()
end
