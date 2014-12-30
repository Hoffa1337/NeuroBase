ENT.Spawnable			= false
ENT.AdminSpawnable		= false

include('shared.lua')

local emitter = ParticleEmitter(Vector(0, 0, 0))
function ENT:Initialize()
	self.lifetime = RealTime()
	self.cooltime = CurTime()
end

function ENT:Draw()
	self:DrawModel()
end

function ENT:Think()
	
	local dlight = DynamicLight( self:EntIndex() )
	if ( dlight ) then

		local c = Color( 250+math.random(-5,5), 170+math.random(-5,5), 0, 100 )

		dlight.Pos = self:GetPos()
		dlight.r = c.r
		dlight.g = c.g
		dlight.b = c.b
		dlight.Brightness = 1
		dlight.Decay = 0.1
		dlight.Size = 2048
		dlight.DieTime = CurTime() + 0.15

	end
		
	if true then return end
	
		local dist = 245
		if (self.lifetime > RealTime()) then
			if (self.cooltime < CurTime()) then
			local smoke = emitter:Add("effects/smoke_a", self:GetPos() + self:GetForward()*-dist)
			smoke:SetVelocity(self:GetForward()*-800)
			smoke:SetDieTime(math.Rand(.9,2.2))
			smoke:SetStartAlpha(math.Rand(200,240))
			smoke:SetEndAlpha(0)
			smoke:SetStartSize(math.random(44,68))
			smoke:SetEndSize(math.random(176,229))
			smoke:SetRoll(math.Rand(180,480))
			smoke:SetRollDelta(math.Rand(-1.55,1.52))
			smoke:SetGravity( Vector( 0, math.random(1,90), math.random(51,155) ) )
			smoke:SetColor(50, 50, 50)
			smoke:SetAirResistance(60)
			-- smoke:SetCollide(true)
			local fire = emitter:Add("effects/smoke_a", self:GetPos() + self:GetForward()*-dist)
			fire:SetVelocity(self:GetForward()*-10)
			fire:SetDieTime(math.Rand(.075,.15))
			fire:SetStartAlpha(math.Rand(222,255))
			fire:SetEndAlpha(0)
			fire:SetStartSize(math.random(31,44))
			fire:SetEndSize(math.random(60,73))
			fire:SetAirResistance(150)
			fire:SetRoll(math.Rand(180,480))
			fire:SetRollDelta(math.Rand(-3,3))
			fire:SetStartLength(15)
			fire:SetColor(255,100,0)
			fire:SetEndLength(math.Rand(100, 150))
			-- fire:SetCollide(true)
			
			fire = emitter:Add("effects/smoke_a", self:GetPos() + self:GetForward()*-dist)
			fire:SetVelocity(self:GetForward()*-10)
			fire:SetDieTime(math.Rand(.075,.15))
			fire:SetStartAlpha(math.Rand(222,255))
			fire:SetEndAlpha(0)
			fire:SetStartSize(math.random(25,35))
			fire:SetEndSize(math.random(45,55))
			fire:SetAirResistance(150)
			fire:SetRoll(math.Rand(180,480))
			fire:SetRollDelta(math.Rand(-3,3))
			fire:SetColor(255,110,0)
			-- fire:SetCollide(true)
			
			fire = emitter:Add("effects/yellowflare", self:GetPos() + self:GetForward()*-dist)
			fire:SetVelocity(self:GetForward()*-10)
			fire:SetDieTime(math.Rand(.03,.05))
			fire:SetStartAlpha(math.Rand(222,255))
			-- fire:SetCollide(true)
			fire:SetEndAlpha(0)
			fire:SetStartSize(math.random(77,88))
			fire:SetEndSize(math.random(99,100))
			fire:SetAirResistance(150)
			fire:SetRoll(math.Rand(180,480))
			fire:SetRollDelta(math.Rand(-3,3))
			fire:SetColor(255,120,0)

			self.cooltime = CurTime() + .02
			end
		
	else
		self.lifetime = RealTime() + 1
	end
end

function ENT:OnRestore()
end
