function EFFECT:Init( data )
local pos = data:GetOrigin()
local emitter = ParticleEmitter( pos )
	for i=0,50 do
		local shockwave = emitter:Add( "sprites/splodesprite", pos )
			shockwave:SetVelocity( Vector(-10,0,0) )
			shockwave:SetDieTime( 0.02 )
			shockwave:SetStartAlpha(255)
			shockwave:SetEndAlpha(0)
			shockwave:SetStartSize(64)
			shockwave:SetEndSize(0)
			shockwave:SetRoll(math.random(300,600))
			shockwave:SetRollDelta(math.random(-3,3))
			shockwave:SetCollide( true )
			shockwave:SetLighting( true	 )

	end
	emitter:Finish()
end
function EFFECT:Think( )
return false
end
function EFFECT:Render()
end



