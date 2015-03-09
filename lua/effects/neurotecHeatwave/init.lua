

--Initializes the effect. The data is a table of data 
--which was passed from the server.
function EFFECT:Init( data )
	
	self.Position = data:GetOrigin()
	
	local Pos = self.Position
	local Norm = Vector(0,0,1)
	
	Pos = Pos + Norm * 6

	local emitter = ParticleEmitter( Pos )

		for i=1, 2 do
		
			local particle = emitter:Add( "sprites/heatwave", Pos + Vector(math.random(-20,20),math.random(-20,20),math.random(-30,50)))

				particle:SetVelocity( Vector(math.random(-2,2),math.random(-2,2),math.random(30,50)) )
				particle:SetDieTime( math.Rand( 0.1, 0.2 ) )
				particle:SetStartAlpha( math.Rand( 200, 240 ) )
				particle:SetStartSize( 16 )
				particle:SetEndSize( math.Rand( 2, 10 ) )
				particle:SetRoll( math.Rand( 360, 480 ) )
				particle:SetRollDelta( math.Rand( -1, 1 ) )
				particle:SetColor( math.Rand( 150, 255 ), math.Rand( 100, 150 ), 100 )
				--particle:VelocityDecay(false)
				
			end
			
	emitter:Finish()
	
end

--THINK
-- Returning false makes the entity die
function EFFECT:Think( )
	-- Die instantly
	return false	
end

-- Draw the effect
function EFFECT:Render()
	-- Do nothing - this effect is only used to spawn the particles in Init	
end



