// Credits goes to Failure for the original effect, I just made a new texture for it and renamed it to avoid naming collisions.
local tMats = {}
tMats.Glow1 = Material("sprites/light_glow02")
tMats.Glow2 = Material("sprites/flare1")

for _,mat in pairs(tMats) do

	mat:SetInt("$spriterendermode",9)
	mat:SetInt("$ignorez",1)
	mat:SetInt("$illumfactor",8)
	
end

local SmokeParticleUpdate = function(particle)

	if particle:GetStartAlpha() == 0 and particle:GetLifeTime() >= 0.5*particle:GetDieTime() then
		particle:SetStartAlpha(particle:GetEndAlpha())
		particle:SetEndAlpha(0)
		particle:SetNextThink(-1)
	else
		particle:SetNextThink(CurTime() + 0.1)
	end

	return particle

end


function EFFECT:Init(data)

	self.Scale = data:GetScale()
	self.ScaleSlow = math.sqrt(self.Scale)
	self.ScaleSlowest = math.sqrt(self.ScaleSlow)
	self.Normal = data:GetNormal()
	self.RightAngle = self.Normal:Angle():Right():Angle()
	self.Position = data:GetOrigin() - 12*self.Normal
	self.Position2 = self.Position + self.Scale*64*self.Normal

	local CurrentTime = CurTime()
	self.Duration = 0.5*self.Scale 
	self.KillTime = CurrentTime + self.Duration
	self.GlowAlpha = 200
	self.GlowSize = 100*self.Scale
	self.FlashAlpha = 100
	self.FlashSize = 0

	local emitter = ParticleEmitter(self.Position)

	--Smoke Plumes
	if( emitter ) then
	
		for i=1,math.ceil(self.Scale*100) do
			
			local vecang = VectorRand()*12
			local spawnpos = self.Position 	
			local velocity = math.Rand(50,400)*vecang			
			local particle = emitter:Add("particles/fatsmoke",   spawnpos - vecang*9*k)
			local dietime = math.Rand(10.5,10.9)*self.Scale
			
			particle:SetVelocity( velocity * self.Scale/8)
			particle:SetDieTime(dietime * 2 )
			particle:SetAirResistance(50)
			particle:SetStartAlpha(150)
			particle:SetEndAlpha( math.random( 0, 1 ) )
			particle:SetStartSize( math.random( 0, 50 ) )
			particle:SetEndSize(math.Rand( 500,800 )*self.ScaleSlow)
			particle:SetRoll( math.Rand( 20, 80 ) )
			particle:SetRoll(math.Rand(150,180))
			particle:SetRollDelta(0.6*math.random(-1,1))
			particle:SetColor(255,255,255)   
			particle:SetGravity( Vector( -150 + math.cos( CurTime() ) * 35, math.sin( CurTime() ) * 45, math.random(-5,15) ) )
			
		end

		emitter:Finish()
		
	end
	
end

function EFFECT:Think()

	local TimeLeft = self.KillTime - CurTime()
	
	local TimeScale = TimeLeft/self.Duration
	
	local FTime = FrameTime()
	
	if TimeLeft > 0 then 

		self.FlashAlpha = self.FlashAlpha - 200*FTime
		self.FlashSize = self.FlashSize + 60000*FTime
		
		self.GlowAlpha = 200*TimeScale
		self.GlowSize = TimeLeft*self.Scale

		return true
		
	else
	
		return false	
		
	end
	
end



-- Draw the effect
function EFFECT:Render()


end



