

function EFFECT:Init( data )
	
	self.Position = data:GetOrigin()
	local Pos = self.Position		
	local Norm = Vector(0,0,1)
	
	Pos = Pos + Norm * 2
	
	local emitter = ParticleEmitter( Pos )

		for i=1, 14 do
				
			local particle = emitter:Add( "particle/mat1", Pos + Vector( math.random( -50, 50 ), math.random( -50, 50 ), math.random( 10, 150 ) ) ) -- Unser Effekt: (  "PFAD ZUM EFFEKT",  POSITION_DES_EFFEKTES )
				
				particle:SetVelocity( Vector( math.random( -50, 50 ), math.random( -50, 50 ), math.random( -10, 10 ) ) )
				particle:SetDieTime( math.Rand( 2.1, 3.1 ) )
				particle:SetStartAlpha( math.random( 100, 200 ) )
				particle:SetStartSize( math.random( 60, 90 ) )
				particle:SetEndSize( math.random( 0, 10 ) )
				particle:SetRoll( math.random( -360, 360 ) )
				particle:SetRollDelta( math.random( -0.6, 0.6 ) )
				particle:SetColor( 255, 255, 255 )
				particle:VelocityDecay( true )
		end
			
		
		for i=1, 15 do
				
			local particle = emitter:Add( "particle/mat1", Pos + Vector( math.random( -150, 150 ), math.random( -150, 150 ), math.random( 20, 100 ) ) )
				
				particle:SetVelocity( Vector( math.random( -100, 100 ), math.random( -100, 100 ), math.random( -50, 100 ) ) )
				particle:SetDieTime( math.Rand( 1.8, 2.87 ) )
				particle:SetStartAlpha( math.random( 150, 255 ) )
				particle:SetStartSize( math.random( 40, 80 ) )
				particle:SetEndSize( math.random( 0, 10 ) )
				particle:SetRoll( math.random( -360, 360 ) )
				particle:SetRollDelta( math.random( -0.8, 0.8 ) )
				particle:SetColor( 255, 255, 255 )
				particle:VelocityDecay( true )
		end

end

function EFFECT:Think( )

	return false	
end


function EFFECT:Render()
end



