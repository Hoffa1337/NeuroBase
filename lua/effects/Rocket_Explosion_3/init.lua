function EFFECT:Init( data )
	local pos = data:GetOrigin() -- not same as below
	local Pos = data:GetOrigin() -- not same as above
	local rVec = VectorRand()*5
	local pos = pos + 128*rVec
	local emitter = ParticleEmitter( pos )
	
	for i=1,5 do
		
		rVec = VectorRand()*math.random(-5,5)
		
		for j=1, 7 do
			
			local particle = emitter:Add( "particles/flamelet"..math.Rand( 1, 5 ), pos - rVec * 6 * j )
			particle:SetVelocity( rVec*math.Rand( 2, 3 ) )
			particle:SetDieTime( math.Rand( 1.5, 3.5 ) )
			particle:SetStartAlpha( math.Rand( 230, 250 ) )
			particle:SetStartSize( j*math.Rand( 4, 5 ) )
			particle:SetEndSize( j*math.Rand( 1, 3 ) )
			particle:SetRoll( math.Rand( -1, 1 ) )
			particle:SetRollDelta( math.Rand( -1, 1 ) )
			particle:SetColor( 150, math.Rand( 90, 134 ), math.Rand( 220, 255 ) )
			particle:VelocityDecay( true )
			
			local eparticle = emitter:Add( "particles/flamelet"..math.Rand( 1, 5 ), pos - rVec * 6 * j )
			eparticle:SetVelocity( rVec*math.Rand( 2, 3 ) )
			eparticle:SetDieTime( math.Rand( 1.6, 3.6 ) )
			eparticle:SetStartAlpha( math.Rand(230, 250) )
			eparticle:SetStartSize( j*math.Rand( 4, 6 ) )
			eparticle:SetEndSize( j*math.Rand( 1, 3 ) )
			eparticle:SetRoll( math.Rand( -1, 1 ) )
			eparticle:SetRollDelta( math.Rand( -1, 1 ) )
			eparticle:SetColor( 90, math.Rand( 64, 108 ), math.Rand( 130, 255 ) )
			eparticle:VelocityDecay( true )
			
		end
		
	end
		
	emitter:Finish()
	
end

function EFFECT:Think( )
	return false
end

function EFFECT:Render()
end



