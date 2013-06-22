

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
		
			local particle = emitter:Add( "particles/flamelet"..math.random( 1, 5 ), Pos + Vector(math.random(-20,20),math.random(-20,20),math.random(-30,50)))
				
				if( particle ) then
				
					particle:SetVelocity( Vector(math.random(-30,30),math.random(-30,30),math.random(45,190)) )
					particle:SetDieTime( math.Rand( 1.9, 2.4 ) )
					particle:SetStartAlpha( math.random( 200, 240 ) )
					particle:SetStartSize( 16 )
					particle:SetEndSize( math.random( 48, 64 ) )
					particle:SetRoll( math.random( 360, 480 ) )
					particle:SetRollDelta( math.Rand( -1, 1 ) )
					particle:SetColor( math.random( 150, 255 ), math.random( 100, 150 ), 100 )
					particle:VelocityDecay( false )
					
				end
				
			end
		
	--smoke cloud
		for i=1, 7 do
		
		local particle = emitter:Add( "particles/smokey", Pos + Vector(math.random(-95,95),math.random(-95,25),math.random(5,95)))
			
			if( particle ) then
					
				particle:SetVelocity( Vector(math.random(-60,60),math.random(-66,70),math.random(55,200)) )
				particle:SetDieTime( math.Rand( 5, 9 ) )
				particle:SetStartAlpha( math.random( 35, 55 ) )
				particle:SetEndAlpha( math.random( 0, 1 ) )
				particle:SetStartSize( math.random( 32,54 ) )
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



