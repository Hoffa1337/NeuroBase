

local matRefraction	= Material( "refract_ring" )

/*---------------------------------------------------------
   Initializes the effect. The data is a table of data 
   which was passed from the server.
---------------------------------------------------------*/
function EFFECT:Init( data )

	local Pos = data:GetOrigin() + Vector( 0,0,10 )
	local emitter = ParticleEmitter( Pos )

	local effectdata = EffectData()
	effectdata:SetOrigin( Pos )
	effectdata:SetNormal( Vector(0,0,0) )
	effectdata:SetMagnitude( 2.6 )
	effectdata:SetScale( 2.6 )
	effectdata:SetRadius( 93 )
	util.Effect( "Sparks", effectdata, true, true )

	local effectdata = EffectData()
	effectdata:SetOrigin( Pos )
	effectdata:SetNormal( Vector(0,0,0) )
	effectdata:SetMagnitude( 100 )
	effectdata:SetScale( 50 )
	effectdata:SetRadius( 1024 )
	util.Effect( "Explosion", effectdata, true, true )
	
	for i =1,5 do 
		

		local effectdata = EffectData()
		effectdata:SetOrigin( Pos + Vector( math.random(-100,100),math.random(-100,100),math.random(-100,100)) )
		effectdata:SetNormal( Vector(0,0,0) )
		effectdata:SetMagnitude( 100 )
		effectdata:SetScale( 100 )
		effectdata:SetRadius( 400 )
		util.Effect( "HelicopterMegaBomb", effectdata, true, true )

		
	end
	--base explosion
	for i=1,8 do
		local particle = emitter:Add("particles/flamelet3",Pos+Vector(math.random(-150,150),math.random(-150,150),math.random(10,170)))
		particle:SetVelocity(Vector(math.random(-60,70),math.random(-100,70),math.random(70,180)))
		particle:SetDieTime(math.Rand(2.8,4.2))
		particle:SetStartAlpha(math.Rand(220,240))
		particle:SetStartSize(48)
		particle:SetEndSize(math.Rand(168,190))
		particle:SetRoll(math.Rand(360,480))
		particle:SetRollDelta(math.Rand(-1,1))
		particle:SetColor(math.Rand(150,255),math.Rand(100,150),100)
		--particle:VelocityDecay(true)	
	end

	--smoke puff
	for i = 1, 7 do
		local particle = emitter:Add("particles/smokey",Pos+Vector(math.random(-15,150),math.random(-150,15),math.random(-30,10)))
		particle:SetVelocity(Vector(math.random(-60,70),math.random(-100,70),math.random(70,180)))
		particle:SetDieTime(math.Rand(2.9,3.3))
		particle:SetStartAlpha(math.Rand(205,255))
		particle:SetStartSize(math.Rand(100,130))
		particle:SetEndSize(math.Rand(192,256))
		particle:SetRoll(math.Rand(360,480))
		particle:SetRollDelta(math.Rand(-1,1))
		particle:SetColor(170,160,160)
		--particle:VelocityDecay(true)
		particle:SetGravity(Vector(0,0,math.random(-30,-10)))
	end

	--big smoke cloud
	for i = 1, 8 do
		local particle = emitter:Add("particles/smokey",Pos+Vector(math.random(-80,70),math.random(-30,80),math.random(20,280)))
		particle:SetVelocity(Vector(math.random(-60,70),math.random(-100,70),math.random(70,180)))
		particle:SetDieTime(math.Rand(2.5,3.7))
		particle:SetStartAlpha(math.Rand(90,100))
		particle:SetStartSize(math.Rand(55,66))
		particle:SetEndSize(math.Rand(192,256))
		particle:SetRoll(math.Rand(480,540))
		particle:SetRollDelta(math.Rand(-1,1))
		particle:SetColor(170,170,170)
		--particle:VelocityDecay(true)
		particle:SetGravity(Vector(0,0,math.random(-30,-10)))
	end

	self.Refract = 0
	
	self.Size = 4
	
	self:SetRenderBounds( Vector()*-256, Vector()*256 )
	
end


/*---------------------------------------------------------
   THINK
   Returning false makes the entity die
---------------------------------------------------------*/
function EFFECT:Think( )

	return false
	
end


/*---------------------------------------------------------
   Draw the effect
---------------------------------------------------------*/
function EFFECT:Render()
	/*
	local Distance = EyePos():Distance( self:GetPos() )
	local Pos = self:GetPos() + (EyePos()-self:GetPos()):GetNormal() * Distance * (self.Refract^(0.3)) * 0.8

	matRefraction:SetMaterialFloat( "$refractamount", math.sin( self.Refract * math.pi ) * 0.1 )
	render.SetMaterial( matRefraction )
	render.UpdateRefractTexture()
	render.DrawSprite( Pos, self.Size, self.Size )
	*/
end



