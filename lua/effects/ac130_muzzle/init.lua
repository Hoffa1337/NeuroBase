

/*---------------------------------------------------------
   Initializes the effect. The data is a table of data 
   which was passed from the server.
---------------------------------------------------------*/
function EFFECT:Init( data )

	local Pos = data:GetStart()
	local Scale = data:GetScale()
	local Velocity 	= data:GetNormal()

	Pos = Pos + data:GetNormal() * -32
			
	local emitter = ParticleEmitter( Pos )
		
		for i = 1, 11 do
		
			local particle = emitter:Add( "particles/flamelet"..math.random( 1, 5 ), Pos + Velocity * i * 1 * Scale )

				particle:SetVelocity( Velocity * 0.99 * math.random( 1000, 2200 ) )
				particle:SetDieTime( math.Rand( 0.1, 0.18 ) )
				particle:SetStartAlpha( math.Rand( 240, 250 ) )
				particle:SetStartSize( math.Rand( 22, 30 ) * Scale )
				particle:SetEndSize( math.Rand( 1, 4 ) * Scale )
				particle:SetRoll( math.Rand( 0, 360 ) )
				particle:SetRollDelta( math.Rand( -1, 1 ) )
				particle:SetColor( math.Rand( 240, 255 ), math.Rand( 230, 255 ), 255 )

			end

		for i = 1, 8 do
		
			local particle = emitter:Add( "particles/flamelet"..math.random( 1, 5 ), ( Pos + Velocity * -45 )  + Velocity * i * 16 * Scale )

				particle:SetVelocity( Velocity * math.random( 900, 1000 ) )
				particle:SetDieTime( math.Rand( 0.1, 0.18 ) )
				particle:SetStartAlpha( 255 )
				particle:SetStartSize( math.Rand( 20, 30 ) * Scale )
				particle:SetEndSize( math.Rand( 4, 8 ) * Scale )
				particle:SetRoll( math.Rand( 0, 360 ) )
				particle:SetRollDelta( math.Rand( -0.5, 0.5 ) )
				particle:SetColor( 240,240, 250 )

		end
		
		for i = 1, 12 do
		
			local particle = emitter:Add( "particles/flamelet"..math.random( 1, 5 ), Pos + Velocity * i * 20 * Scale )

				particle:SetVelocity( Velocity * math.random( 900, 1000 ) )
				particle:SetDieTime( math.Rand( 0.11, 0.2 ) )
				particle:SetStartAlpha( 255 )
				particle:SetStartSize( math.Rand( 20, 30 ) * Scale )
				particle:SetEndSize( math.Rand( 4, 8 ) * Scale )
				particle:SetRoll( math.Rand( 0, 360 ) )
				particle:SetRollDelta( math.Rand( -0.5, 0.5 ) )
				particle:SetColor( 120, math.random( 100, 160 ), 255 )
				
		end
				
	emitter:Finish()
	
end


/*---------------------------------------------------------
   THINK
   Returning false makes the entity die
---------------------------------------------------------*/
function EFFECT:Think( )

	-- Die instantly
	return false
	
end


/*---------------------------------------------------------
   Draw the effect
---------------------------------------------------------*/
function EFFECT:Render()

	-- Do nothing - this effect is only used to spawn the particles in Init
	
end



