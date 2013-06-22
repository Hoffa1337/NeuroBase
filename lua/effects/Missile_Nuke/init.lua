// Credits to gb

local tMats = {}
tMats.Glow1 = Material("sprites/flare1")
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
	self.Duration = 0.5
	self.KillTime = CurrentTime + self.Duration
	self.GlowAlpha = 0
	self.GlowSize = 500*self.Scale
	self.FlashAlpha = 0
	self.FlashSize = 500




	local emitter = ParticleEmitter(self.Position)

		self.smokeparticles = {}

		--pillar of dust
		for i=1,math.ceil(self.Scale*150) do

                   local startalpha = math.Rand( 0, 0 )
			local vecang = (self.Normal + VectorRand()*math.Rand(0,1)):GetNormalized()
			local velocity = math.Rand(-200,500)*vecang*self.Scale
			local particle = emitter:Add( "particles/flamelet"..math.random(1,5), self.Position + vecang*math.Rand(-50,200)*self.Scale)
			local dietime = math.Rand(2.7,2.9)*self.Scale
			particle:SetVelocity(velocity)
			particle:SetGravity(Vector(0,0,math.Rand(20,80)))
			particle:SetAirResistance(6)
			particle:SetDieTime(dietime)			
			particle:SetStartAlpha(50)
			particle:SetEndAlpha( 0 )
			particle:SetStartSize(math.Rand(200,700)*self.ScaleSlow)
			particle:SetEndSize(math.Rand(640,1000)*self.ScaleSlow)
			particle:SetRoll(math.Rand(10,10))
			particle:SetRollDelta(0.7*math.random(-1,1))
			particle:SetColor(255,255,255)
                  
			
		end
--Flare
		for i=1,math.ceil(self.Scale*1) do

			local startalpha = math.Rand( 0, 0 )
                  local vecang = (self.Normal + VectorRand()*math.Rand(1,1)):GetNormalized()
			local velocity = math.Rand(700,1100)*vecang*self.Scale
			local particle = emitter:Add( "sprites/flare1", self.Position + vecang*1,1*self.Scale)
			particle:SetVelocity(velocity)
                  particle:SetStartAlpha(100)            
			particle:SetGravity(Vector(0,0,math.Rand(1500,1500)))
			particle:SetAirResistance(200)
			particle:SetDieTime(math.Rand(2.7,2.9)*self.Scale)
			particle:SetStartSize(math.Rand(4000,4000)*self.ScaleSlow)
			particle:SetEndSize(math.Rand(4000,4000)*self.ScaleSlow)
			particle:SetRoll(math.Rand(0,0))
			particle:SetRollDelta(0.0*math.random(-0,0))
			particle:SetColor(200,200,200)
        

		end	

		--Mushroom Cloud
		for i=1,math.ceil(self.Scale*60) do

			local vecang = self.RightAngle
                  local startalpha = math.Rand( 0, 0 )
			vecang:RotateAroundAxis(self.Normal,math.Rand(0,360))
			vecang = vecang:Forward() + VectorRand()*0.1
			local velocity = math.Rand(100,2000)*vecang
			local particle = emitter:Add( "particles/flamelet"..math.random(1,5), self.Position - vecang*32*self.Scale - self.Normal*16)
			local dietime = math.Rand(2.5,2.9)*self.Scale
			particle:SetVelocity(velocity*self.Scale)
			particle:SetGravity(Vector(0,0,math.Rand(0,0)))
			particle:SetAirResistance(50)
			particle:SetDieTime(dietime)
			particle:SetStartAlpha(50)
			particle:SetEndAlpha( 0 )
			particle:SetStartSize(math.Rand(300,300)*self.ScaleSlow)
			particle:SetEndSize(math.Rand(500,500)*self.ScaleSlow)
			particle:SetRoll(math.Rand(10,10))
			particle:SetRollDelta(0.6*math.random(-1,1))
			particle:SetColor(255,255,255)
                  
			
		end
			--Shockwave
		for i=1,math.ceil(self.Scale*200) do

			local vecang = self.RightAngle
                  local startalpha = math.Rand( 0, 0 )
			vecang:RotateAroundAxis(self.Normal,math.Rand(9,9))
			vecang = vecang:Forward() + VectorRand()*0.1
			local velocity = math.Rand(2200,4400)*vecang
			local particle = emitter:Add( "particles/fatsmoke", self.Position - vecang*64*self.Scale - self.Normal*16)
			local dietime = math.Rand(15.7,15.9)*self.Scale
			particle:SetVelocity(velocity*self.Scale)
			particle:SetGravity(Vector(0,0,math.Rand(0,0)))
			particle:SetAirResistance(15) 
                  particle:SetStartAlpha(50)
                  particle:SetEndAlpha( 0 )
			particle:SetDieTime(dietime)
			particle:SetStartSize(math.Rand(1000,1000)*self.ScaleSlow)
			particle:SetEndSize(math.Rand(1000,1000)*self.ScaleSlow)
			particle:SetRoll(math.Rand(10,10))
			particle:SetRollDelta(0.6*math.random(-1,1))
			particle:SetColor(60,50,50)
                  
			
		end
--SmokeMushroomExplosion
		for i=1,math.ceil(self.Scale*100) do

			local startalpha = math.Rand( 0, 0 )
                  local vecang = (self.Normal + VectorRand()*math.Rand(2,2)):GetNormalized()
			local velocity = math.Rand(700,1100)*vecang*self.Scale
			local particle = emitter:Add( "particles/flamelet"..math.random(1,5), self.Position + vecang*1500,1500*self.Scale)
			particle:SetVelocity(velocity)
                  particle:SetStartAlpha(50)
                  particle:SetEndAlpha( 0 )
			particle:SetGravity(Vector(0,0,math.Rand(1250,1250)))
			particle:SetAirResistance(200)
			particle:SetDieTime(math.Rand(2.7,2.9)*self.Scale)
			particle:SetStartSize(math.Rand(1000,1000)*self.ScaleSlow)
			particle:SetEndSize(math.Rand(1000,1000)*self.ScaleSlow)
			particle:SetRoll(math.Rand(10,10))
			particle:SetRollDelta(0.6*math.random(-1,1))
			particle:SetColor(255,255,255)
                  

		end	
--SmokeMushroomExplosion
		for i=1,math.ceil(self.Scale*26) do

			local startalpha = math.Rand( 0, 0 )
                  local vecang = (self.Normal + VectorRand()*math.Rand(2,2)):GetNormalized()
			local velocity = math.Rand(700,1100)*vecang*self.Scale
			local particle = emitter:Add( "particles/fatsmoke", self.Position + vecang*1500,1500*self.Scale)
			particle:SetVelocity(velocity)
                  particle:SetStartAlpha(startalpha)
                  particle:SetEndAlpha( 250 + startalpha )
			particle:SetGravity(Vector(0,0,math.Rand(1250,1250)))
			particle:SetAirResistance(200)
			particle:SetDieTime(math.Rand(15.7,15.9)*self.Scale)
			particle:SetStartSize(math.Rand(1000,1000)*self.ScaleSlow)
			particle:SetEndSize(math.Rand(2000,2000)*self.ScaleSlow)
			particle:SetRoll(math.Rand(10,10))
			particle:SetRollDelta(0.6*math.random(-1,1))
			particle:SetColor(100,100,100)
                  table.insert(self.smokeparticles,particle)

		end	
		--pillar of dust
		for i=1,math.ceil(self.Scale*50) do

                   local startalpha = math.Rand( 0, 0 )
			local vecang = (self.Normal + VectorRand()*math.Rand(0,1)):GetNormalized()
			local velocity = math.Rand(-200,500)*vecang*self.Scale
			local particle = emitter:Add( "particles/fatsmoke", self.Position + vecang*math.Rand(-50,25)*self.Scale)
			local dietime = math.Rand(15.7,15.9)*self.Scale
			particle:SetVelocity(velocity)
			particle:SetGravity(Vector(0,0,math.Rand(20,80)))
			particle:SetAirResistance(6)
			particle:SetDieTime(dietime)			
                  particle:SetStartAlpha(startalpha)
                  particle:SetEndAlpha( 250 + startalpha )
			particle:SetStartSize(math.Rand(200,200)*self.ScaleSlow)
			particle:SetEndSize(math.Rand(600,600)*self.ScaleSlow)
			particle:SetRoll(math.Rand(10,10))
			particle:SetRollDelta(0.7*math.random(-1,1))
			particle:SetColor(100,100,100)
                   table.insert(self.smokeparticles,particle)

			
		end


		--Mushroom Cloud
		for i=1,math.ceil(self.Scale*30) do

			local vecang = self.RightAngle
                  local startalpha = math.Rand( 0, 0 )
			vecang:RotateAroundAxis(self.Normal,math.Rand(0,360))
			vecang = vecang:Forward() + VectorRand()*0.1
			local velocity = math.Rand(100,2000)*vecang
			local particle = emitter:Add( "particles/fatsmoke", self.Position - vecang*32*self.Scale - self.Normal*16)
			local dietime = math.Rand(15.5,15.9)*self.Scale
			particle:SetVelocity(velocity*self.Scale)
			particle:SetGravity(Vector(0,0,math.Rand(0,0)))
			particle:SetAirResistance(50)
			particle:SetDieTime(dietime)
	            particle:SetStartAlpha(startalpha)
                  particle:SetEndAlpha( 250 + startalpha )
			particle:SetStartSize(math.Rand(300,300)*self.ScaleSlow)
			particle:SetEndSize(math.Rand(900,900)*self.ScaleSlow)
			particle:SetRoll(math.Rand(10,10))
			particle:SetRollDelta(0.6*math.random(-1,1))
			particle:SetColor(100,100,100)
                   table.insert(self.smokeparticles,particle)

			
		end

		
		
			--Shockwave
		for i=1,math.ceil(self.Scale*100) do

			local vecang = self.RightAngle
                  local startalpha = math.Rand( 0, 0 )
			vecang:RotateAroundAxis(self.Normal,math.Rand(9,9))
			vecang = vecang:Forward() + VectorRand()*0.1
			local velocity = math.Rand(10000,10000)*vecang
			local particle = emitter:Add( "particles/fatsmoke", self.Position - vecang*64*self.Scale - self.Normal*16)
			local dietime = math.Rand(5.7,5.9)*self.Scale
			particle:SetVelocity(velocity*self.Scale)
			particle:SetGravity(Vector(0,0,math.Rand(0,0)))
			particle:SetAirResistance(5) 
                  particle:SetStartAlpha(50)
                  particle:SetEndAlpha( 0 )
			particle:SetDieTime(dietime)
			particle:SetStartSize(math.Rand(1000,1000)*self.ScaleSlow)
			particle:SetEndSize(math.Rand(1000,1000)*self.ScaleSlow)
			particle:SetRoll(math.Rand(10,10))
			particle:SetRollDelta(0.6*math.random(-1,1))
			particle:SetColor(60,50,50)
                  
			
		end






	emitter:Finish()
	
	if self.Scale > 0 then
		surface.PlaySound("ambient/explosions/explode_6.wav")

	elseif self.Scale > 11 then
		surface.PlaySound("ambient/explosions/explode_8.wav")
		self.Entity:EmitSound("ambient/explosions/explode_1.wav")
	
	elseif self.Scale > 23 then
		surface.PlaySound("ambient/explosions/exp1.wav")
		surface.PlaySound("ambient/explosions/explode_4.wav")
		
	elseif self.Scale > 35 then
		surface.PlaySound("ambient/explosions/exp2.wav")
		surface.PlaySound("ambient/explosions/explode_6.wav")
	
	else
		self.Entity:EmitSound("ambient/explosions/explode_4.wav")
	end
	
end


--THINK
-- Returning false makes the entity die
function EFFECT:Think()
	local TimeLeft = self.KillTime - CurTime()
	local TimeScale = TimeLeft/self.Duration
	local FTime = FrameTime()
	if TimeLeft > 0 then 

		self.FlashAlpha = self.FlashAlpha - 250
		self.FlashSize = 500
		
		self.GlowAlpha = 200*TimeScale
		self.GlowSize = 500
            
            
		return true
	else
		for __,particle in pairs(self.smokeparticles) do
		particle:SetStartAlpha( 200 )
		particle:SetEndAlpha( 0 )
		end
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









