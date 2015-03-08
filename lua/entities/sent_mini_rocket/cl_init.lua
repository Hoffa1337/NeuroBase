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
	if (self.cooltime < CurTime()) then
		local smoke = emitter:Add("effects/smoke_a", self:GetPos() + self:GetForward()*-50)
		smoke:SetVelocity(self:GetForward()*-800)
		smoke:SetDieTime(math.Rand(.9,1.2))
		smoke:SetStartAlpha(math.Rand(200,240))
		smoke:SetEndAlpha(0)
		smoke:SetStartSize(math.random(5,8))
		smoke:SetEndSize(math.random(4,8))
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
		fire:SetStartSize(math.random(1,2))
		fire:SetEndSize(math.random(5,9))
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
		fire:SetStartSize(math.random(4,5))
		fire:SetEndSize(math.random(1,2))
		fire:SetAirResistance(150)
		fire:SetRoll(math.Rand(180,480))
		fire:SetRollDelta(math.Rand(-3,3))
		fire:SetColor(255,110,0)

		local fire = emitter:Add("effects/yellowflare", self:GetPos() + self:GetForward()*-50)
		fire:SetVelocity(self:GetForward()*-10)
		fire:SetDieTime(math.Rand(.03,.05))
		fire:SetStartAlpha(math.Rand(222,255))
		fire:SetEndAlpha(0)
		fire:SetStartSize(math.random(1,4))
		fire:SetEndSize(math.random(16,29))
		fire:SetAirResistance(150)
		fire:SetRoll(math.Rand(180,480))
		fire:SetRollDelta(math.Rand(-3,3))
		fire:SetColor(255,120,0)

		self.cooltime = CurTime() 
	end
end
function ENT:OnRemove()

end


function ENT:Think()

end

function ENT:OnRestore()
end
