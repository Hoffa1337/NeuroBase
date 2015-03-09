
function EFFECT:Init( data )
	
	local Pos = data:GetOrigin()
	local emitter = ParticleEmitter( Pos )
	local entity = data:GetEntity()
	
	local particle = emitter:Add( "models/effects/portalrift_sheet", Pos + Vector( math.random(-16,16), math.random(-16,16), 0) )
	if( IsValid( entity ) ) then
		particle:SetVelocity( entity:GetVelocity()  )
	else
		particle:SetVelocity( Vector(math.random(-2,2),math.random(-2,2),math.random(-2,2)) )
	end
	particle:SetDieTime( math.Rand( 1, 2 ) )
	particle:SetStartAlpha( math.Rand( 240, 255 ) )
	particle:SetStartSize( math.random(25,32) )
	particle:SetEndSize( 0 )
	particle:SetRoll( math.Rand( -1, 1 ) )
	particle:SetRollDelta( math.Rand( -3, 3 ) )
	particle:SetColor( 1,1,1,255 )
	--particle:VelocityDecay(false)
	
	emitter:Finish()
	
end

function EFFECT:Think( )
	return false	
end

function EFFECT:Render()
end



