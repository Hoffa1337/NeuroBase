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

	--fire burst2
	for i=1,math.ceil(self.Scale*60) do
		
		local vecang = (self.Normal + VectorRand()*math.Rand(0.5,1.5)):GetNormalized()
		local velocity = math.Rand(2000,8000)*vecang*self.Scale
		local particle = emitter:Add("effects/fire_cloud"..math.random(1,2),  self.Position - vecang*32*self.Scale)
		particle:SetVelocity(velocity)
		particle:SetDieTime(math.Rand(2,2))
		particle:SetStartAlpha(math.Rand(230,250))
		particle:SetStartSize(math.Rand(20,20)*self.ScaleSlow)
		particle:SetEndSize(math.Rand(20,20)*self.ScaleSlow)
		particle:SetStartLength(math.Rand(300,300)*self.ScaleSlow)
		particle:SetEndLength(math.Rand(300,300)*self.ScaleSlow)
		particle:SetColor(255,255,255)

	end
--Mushroom CloudSmall
	for i=1,math.ceil(self.Scale*500) do

		local vecang = self.RightAngle
		vecang:RotateAroundAxis(self.Normal,math.Rand(0,360))
		vecang = vecang:Forward() + VectorRand()*0.1
		local velocity = math.Rand(0,1500)*vecang
		local particle = emitter:Add("particles/fatsmoke",   self.Position - vecang*32*self.Scale - self.Normal*16)
		local dietime = math.Rand(10.5,10.9)*self.Scale
		particle:SetVelocity(velocity*self.Scale)
		particle:SetGravity(Vector(0,0,-600))
		particle:SetAirResistance(50)
		particle:SetDieTime(dietime)
		particle:SetStartAlpha(200)
		particle:SetEndAlpha(0)
		particle:SetStartSize(math.Rand(50,100)*self.ScaleSlow)
		particle:SetEndSize(math.Rand(50,100)*self.ScaleSlow)
		particle:SetRoll(math.Rand(150,180))
		particle:SetRollDelta(0.6*math.random(-1,1))
		particle:SetColor(200,200,200)
		particle:SetCollide(true)
	
	end

	--Smoke Plumes
	for i=1,math.ceil(self.Scale*100) do
		
		local vecang = VectorRand()*12
		local spawnpos = self.Position 	
		local velocity = math.Rand(50,400)*vecang			
		local particle = emitter:Add("particles/fatsmoke",   spawnpos - vecang*9*k)
		local dietime = math.Rand(10.5,10.9)*self.Scale
		particle:SetVelocity(velocity*self.Scale)
		particle:SetDieTime(dietime)
		particle:SetAirResistance(150)
		particle:SetStartAlpha(200)
		particle:SetStartSize(math.Rand(300,500)*self.ScaleSlow)
		particle:SetEndSize(math.Rand(500,500)*self.ScaleSlow)
		particle:SetRoll( math.Rand( 20, 80 ) )
		particle:SetRoll(math.Rand(150,180))
		particle:SetRollDelta(0.6*math.random(-1,1))
		particle:SetColor(255,255,255)   
	end

	--Smoke Plumes
	for i=1,math.ceil(self.Scale*1) do
		
			local vecang = VectorRand()*4
			local spawnpos = self.Position 	
			local velocity = math.Rand(0,0)*vecang			
			local particle = emitter:Add( "sprites/flare1", spawnpos - vecang*9*k)
			local dietime = math.Rand(0.5,0.9)*self.Scale
			particle:SetVelocity(velocity*self.Scale)
			particle:SetDieTime(dietime)
			particle:SetAirResistance(150)
			particle:SetStartAlpha(200)          
			particle:SetStartSize(math.Rand(4000,4000)*self.ScaleSlow)
			particle:SetEndSize(math.Rand(0,0)*self.ScaleSlow)
			particle:SetRoll( math.Rand( 20, 80 ) )
			particle:SetRoll(math.Rand(150,180))
			particle:SetRollDelta(0.6*math.random(-1,1))
			particle:SetColor(255,255,255)   
					
	end

	emitter:Finish()

	surface.PlaySound("LockOn/ExplodeAir.mp3")
	//self.Entity:EmitSound("ambient/explosions/exp"..math.random(1,4)..".wav")

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

	--base glow
	render.SetMaterial(tMats.Glow1)
	render.DrawSprite(self.Position2,7000*self.GlowSize,5500*self.GlowSize,Color(255,240,220,self.GlowAlpha))

	--blinding flash
	if self.FlashAlpha > 0 then
	
		render.SetMaterial(tMats.Glow2)
		
		render.DrawSprite(self.Position2,self.FlashSize,self.FlashSize,Color(255,245,215,self.FlashAlpha))
		
	end

end



