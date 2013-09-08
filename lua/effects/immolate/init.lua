

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
		for i=1, 4 do
		
			local particle = emitter:Add( "particles/flamelet"..math.random( 1, 5 ), Pos + Vector(math.random(-2,2),math.random(-2,2),math.random(-2,2)))
				
				if( particle ) then
				
					particle:SetVelocity( Vector(math.random(-30,30),math.random(-30,30),math.random(45,190)) )
					particle:SetDieTime( math.Rand( 0.2, 0.9 ) )
					particle:SetStartAlpha( math.random( 200, 240 ) )
					particle:SetStartSize( 0 )
					particle:SetEndSize( math.random( 28, 94 ) )
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
					
				particle:SetVelocity( Vector(math.random(-60,60),math.random(-66,70),math.random(55,200)) )
				particle:SetDieTime( math.Rand( 2, 7 ) )
				particle:SetStartAlpha( math.random( 35, 55 ) )
				particle:SetEndAlpha( math.random( 0, 1 ) )
				particle:SetStartSize( math.random( 5,20 ) )
				particle:SetEndSize( math.random( 60, 150 ) )
				particle:SetRoll( math.random( 360, 480 ) )
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



