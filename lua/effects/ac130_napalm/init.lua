

function EFFECT:Init( data )
	local Pos = data:GetOrigin()+Vector(0,0,1)*2
	local emitter = ParticleEmitter(Pos)

	--big firecloud
	for i=1,7 do
		local particle = emitter:Add("particles/flamelet2",Pos+Vector(math.random(-150,150),math.random(-150,150),math.random(0,180)))
		particle:SetVelocity(Vector(math.random(-60,160),math.random(-60,160),math.random(150,400)))
		particle:SetDieTime(math.Rand(5.4,7.7))
		particle:SetStartAlpha(math.Rand(220,240))
		particle:SetStartSize(56)
		particle:SetEndSize(math.Rand(360,392))
		particle:SetRoll(math.Rand(360,480))
		particle:SetRollDelta(math.Rand(-1,1))
		particle:SetColor(math.Rand(170,255),math.Rand(120,160),100)
		particle:VelocityDecay(true)
		particle:SetGravity(Vector(0,0,-600))
	end

	--small firecloud
	for i=1,8 do
		local particle = emitter:Add("particles/flamelet1",Pos+Vector(math.random(-150,150),math.random(-150,150),math.random(-30,150)))
		particle:SetVelocity(Vector(math.random(-120,150),math.random(-120,150),math.random(170,270)))
		particle:SetDieTime(math.Rand(5,7.4))
		particle:SetStartAlpha(math.Rand(220,240))
		particle:SetStartSize(32)
		particle:SetEndSize(math.Rand(328,360))
		particle:SetRoll(math.Rand(360,480))
		particle:SetRollDelta(math.Rand(-1,1))
		particle:SetColor(math.Rand(150,255),math.Rand(100,150),100)
		particle:VelocityDecay(true)
		particle:SetGravity(Vector(0,0,-600))
	end
	for i=1,11 do
		local particle = emitter:Add("particles/flamelet1",Pos+Vector(math.random(-150,150),math.random(-150,150),math.random(-40,50)))
		particle:SetVelocity(Vector(math.random(-60,60),math.random(-60,60),math.random(30,70)))
		particle:SetDieTime(math.Rand(5,7.4))
		particle:SetStartAlpha(math.Rand(270,340))
		particle:SetStartSize(32)
		particle:SetEndSize(math.Rand(228,260))
		particle:SetRoll(math.Rand(360,480))
		particle:SetRollDelta(math.Rand(-1,1))
		particle:SetColor(math.Rand(150,255),math.Rand(100,150),100)
		particle:VelocityDecay(true)
		particle:SetGravity(Vector(0,0,-600))
	end

	--base explosion
	for i=1,8 do
		local particle = emitter:Add("particles/flamelet3",Pos+Vector(math.random(-150,150),math.random(-150,150),math.random(10,170)))
		particle:SetVelocity(Vector(math.random(-200,200),math.random(-200,200),math.random(-20,180)))
		particle:SetDieTime(math.Rand(5.8,6.2))
		particle:SetStartAlpha(math.Rand(220,240))
		particle:SetStartSize(48)
		particle:SetEndSize(math.Rand(168,190))
		particle:SetRoll(math.Rand(360,480))
		particle:SetRollDelta(math.Rand(-1,1))
		particle:SetColor(math.Rand(150,255),math.Rand(100,150),100)
		particle:VelocityDecay(true)	
	end

	--smoke puff
	for i=1,7 do
		local particle = emitter:Add("particles/smokey",Pos+Vector(math.random(-15,150),math.random(-150,15),math.random(-30,10)))
		particle:SetVelocity(Vector(math.random(-180,180),math.random(-180,180),math.random(0,110)))
		particle:SetDieTime(math.Rand(2.9,3.3))
		particle:SetStartAlpha(math.Rand(205,255))
		particle:SetStartSize(math.Rand(42,68))
		particle:SetEndSize(math.Rand(192,256))
		particle:SetRoll(math.Rand(360,480))
		particle:SetRollDelta(math.Rand(-1,1))
		particle:SetColor(170,160,160)
		particle:VelocityDecay(true)
		particle:SetGravity(Vector(0,0,math.random(-30,-10)))
	end

	--big smoke cloud
	for i=1, 5 do
		local particle = emitter:Add("particles/smokey",Pos+Vector(math.random(-80,70),math.random(-30,80),math.random(20,280)))
		particle:SetVelocity(Vector(math.random(-180,180),math.random(-180,180),math.random(160,240)))
		particle:SetDieTime(math.Rand(6.5,6.7))
		particle:SetStartAlpha(math.Rand(90,100))
		particle:SetStartSize(math.Rand(32,48))
		particle:SetEndSize(math.Rand(192,256))
		particle:SetRoll(math.Rand(480,540))
		particle:SetRollDelta(math.Rand(-1,1))
		particle:SetColor(170,170,170)
		particle:VelocityDecay(true)
		particle:SetGravity(Vector(0,0,math.random(-30,-10)))
	end

	for i=1, 10 do
		local particle = emitter:Add("particles/smokey",Pos+Vector(math.random(-40,40),math.random(-40,50),math.random(20,280)))
		particle:SetVelocity(Vector(math.random(-180,280),math.random(-180,280),math.random(160,240)))
		particle:SetDieTime(math.Rand(6.5,6.7))
		particle:SetStartAlpha(math.Rand(140,160))
		particle:SetStartSize(math.Rand(32,48))
		particle:SetEndSize(math.Rand(192,256))
		particle:SetRoll(math.Rand(480,540))
		particle:SetRollDelta(math.Rand(-1,1))
		particle:SetColor(170,170,170)
		particle:VelocityDecay(true)
		particle:SetGravity(Vector(0,0,math.random(-30,-10)))
	end

	-- small smoke cloud
	for i=1, 4 do
		local particle = emitter:Add("particles/smokey",Pos+Vector(math.random(-200,200),math.random(-200,200),math.random(5,10)))
		particle:SetVelocity(Vector(math.random(-200,200),math.random(-200,200),math.random(120,200)))
		particle:SetDieTime(math.Rand(6.1,6.4))
		particle:SetStartAlpha(math.Rand(200,255))
		particle:SetStartSize(math.Rand(42,68))
		particle:SetEndSize(math.Rand(192,256))
		particle:SetRoll(math.Rand(480,540))
		particle:SetRollDelta(math.Rand(-1,1))
		particle:SetColor(170,170,170)
		particle:VelocityDecay(true)
		particle:SetGravity(Vector(0,0,math.random(-30,-10)))
	end
	
	emitter:Finish()
	
end

function EFFECT:Think()
	return false	
end

function EFFECT:Render()
end
