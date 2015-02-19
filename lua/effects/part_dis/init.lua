function EFFECT:Init( data )
local pos = data:GetOrigin()
local scale = data:GetScale() or 1 
local emitter = ParticleEmitter( pos )
	for i=0,math.ceil(102*scale) do
		local particle = emitter:Add( "effects/fleck_antlion"..math.random(1,2), pos + (Vector(math.random(-42,42),math.random(-42,42),math.random(5,52))*scale))
			particle:SetVelocity(VectorRand()*100 * scale )
			particle:SetDieTime(math.random(3,4) )
			particle:SetStartAlpha(240)
			particle:SetEndAlpha(16)
			particle:SetStartSize(math.random(1,2) * scale)
			particle:SetEndSize(math.random(1,2) * scale )
			particle:SetRoll(math.random(300,600) * scale )
			particle:SetRollDelta(math.random(-3,3))
			particle:SetColor(math.random(20,30),math.random(20,30),math.random(20,30))	
			particle:SetCollide( false )
			particle:SetLighting( true	 )
	end
	emitter:Finish()
end
function EFFECT:Think( )
return false
end
function EFFECT:Render()
end



