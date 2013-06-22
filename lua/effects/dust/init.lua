function EFFECT:Init( data )
local pos = data:GetOrigin()
local emitter = ParticleEmitter( pos )
	for i=0,15 do
		local particle = emitter:Add( "effects/fleck_antlion1", pos + Vector(math.random(-2,2),math.random(-5,1),math.random(0,1)))
			particle:SetVelocity(VectorRand()*10)
			particle:SetDieTime(math.random(6,12))
			particle:SetStartAlpha(100)
			particle:SetEndAlpha(0)
			particle:SetStartSize(0)
			particle:SetEndSize(0)
			particle:SetRoll(math.random(300,600))
			particle:SetRollDelta(math.random(-3,3))
			particle:SetColor(math.random(40,70),math.random(40,70),math.random(40,70))	
			particle:SetCollide( true )
			particle:SetGravity( Vector(0,0,math.random(-200,-100)) )
			particle:SetLighting( true	 )
	end
	emitter:Finish()
end
function EFFECT:Think( )
return false
end
function EFFECT:Render()
end



