

--Initializes the effect. The data is a table of data 
--which was passed from the server.

-- "particles/flamelet"..math.random( 1, 5 )
--.. "particles/smokey"
function EFFECT:Init( data )
	
	self.Position = data:GetOrigin()
	
	local Pos = self.Position
	local Norm = Vector(0,0,1)
	
	Pos = Pos + Norm * 6

	local emitter = ParticleEmitter( Pos )
	
	--firecloud
		for i=1, 6 do
		
			local particle = emitter:Add( "particles/flamelet"..math.random( 1, 5 ), Pos + Vector(math.random(-12,12),math.random(-12,12),math.random(-2,2)))
				
				if( particle ) then
				
					particle:SetVelocity( Vector(math.random(-30,30),math.random(-30,30),math.random( -50,290 ) ) )
					particle:SetDieTime( math.Rand( 0.5, 0.9 ) )
					particle:SetStartAlpha( math.random( 233, 255 ) )
					particle:SetStartSize( math.random(  15, 31 ) )
					particle:SetEndSize( math.random( 1, 2 ) )
					particle:SetRoll( math.random( 360, 480 ) )
					particle:SetRollDelta( math.Rand( -1, 1 ) )
					particle:SetColor( math.random( 150, 255 ), math.random( 100, 150 ), 100 )
					particle:VelocityDecay( false )
					
				end
				
			end
		
	--smoke cloud
		for i=1, 7 do
		
		local particle = emitter:Add( "particles/smokey", Pos + Vector(math.random(-5,5),math.random(-5,5),math.random(-5,5)))
			
			if( particle ) then
					
				particle:SetVelocity( Vector(math.random(-25,25),math.random(-25,25),math.random(55,200)) )
				particle:SetDieTime( math.Rand( 2, 7 ) )
				particle:SetStartAlpha( math.random( 135, 155 ) )
				particle:SetEndAlpha( math.random( 0, 1 ) )
				particle:SetStartSize( math.random( 5,20 ) )
				particle:SetEndSize( math.random( 60, 150 ) )
				particle:SetRoll( math.random( 1, 480 ) )
				particle:SetRollDelta( math.Rand( -1, 1 ) )
				particle:SetColor( 20, 20, 20 )
				particle:VelocityDecay( false )
				
			end
			
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



