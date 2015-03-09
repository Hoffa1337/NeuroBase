function EFFECT:Init( data )
	self.StartPos= data:GetOrigin()
	local Pos = self.StartPos
	local Normal = Vector(0,0,1)
	
	Pos = Pos + Normal * 2
	
	local emitter = ParticleEmitter( Pos )
	
		for i = 1, 20 do
		
			local particle = emitter:Add( "effects/yellowflare", Pos )

			particle:SetVelocity( Vector( math.random(-350,350),math.random(-350,350),math.random(-650,-350) ) )
			particle:SetDieTime( math.Rand( 0.75, 2.45 ) )
			particle:SetStartAlpha( math.Rand( 230, 245 ) )
			particle:SetStartSize( math.Rand( 18, 28 ) )
			particle:SetEndSize( 1 )
			particle:SetRoll( math.Rand( 280, 350 ) )
			particle:SetRollDelta( math.Rand( -1, 1 ) )
			particle:SetColor( 255, 255, 255 )
			--particle:VelocityDecay( true )
			particle:SetAirResistance( 20 )
			
			particle:SetGravity( Vector( math.random(-37,37), math.random(-37,37), math.random( -255, 20 ) ) )
			
		end
		
	emitter:Finish()
	
end

function EFFECT:Think( )
	return false
end

function EFFECT:Render()
end



