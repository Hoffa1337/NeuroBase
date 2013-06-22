function EFFECT:Init( data )
local pos = data:GetOrigin()
local emitter = ParticleEmitter( pos )
	for i=0,102 do
		local particle = emitter:Add( "effects/fleck_antlion1", pos + Vector(math.random(-42,42),math.random(-42,42),math.random(5,52)))
			particle:SetVelocity(VectorRand()*100)
			particle:SetDieTime(math.random(3,4))
			particle:SetStartAlpha(240)
			particle:SetEndAlpha(16)
			particle:SetStartSize(math.random(1,2))
			particle:SetEndSize(math.random(1,2))
			particle:SetRoll(math.random(300,600))
			particle:SetRollDelta(math.random(-3,3))
			particle:SetColor(math.random(20,30),math.random(20,30),math.random(20,30))	
			particle:SetCollide( true )
			particle:SetLighting( true	 )
	end
	emitter:Finish()
end
function EFFECT:Think( )
return false
end
function EFFECT:Render()
end



