

--Initializes the effect. The data is a table of data 
--which was passed from the server.

-- "particles/flamelet"..math.random( 1, 5 )
--.. "particles/smokey"
function EFFECT:Init( data )
	
	self.Position = data:GetOrigin()
	
	local Pos = self.Position
	local Norm = Vector(0,0,1)
	local scale = data:GetScale() or 1
	Pos = Pos + Norm * 6

	local emitter = ParticleEmitter( Pos )
	
	--firecloud
		for i=1, 6 do
		
			local particle = emitter:Add( "particles/flamelet"..math.random( 1, 5 ), Pos + Vector(math.random(-12,12),math.random(-12,12),math.random(-2,2)) * scale)
				
				if( particle ) then
				
					particle:SetVelocity( Vector(math.random(-15,15),math.random(-15,15),math.random( 5,290 ) ) * scale )
					particle:SetDieTime( math.Rand( 0.5, 0.9 ) * scale/4 )
					particle:SetStartAlpha( math.random( 233, 255 ) * scale )
					particle:SetStartSize( math.random(  10, 15 ) * scale )
					particle:SetEndSize( math.random( 1, 2 ) * scale)
					particle:SetRoll( math.random( 360, 480 ) * scale)
					particle:SetRollDelta( math.Rand( -1, 1 ) * scale)
					particle:SetColor( math.random( 150, 255 ), math.random( 100, 150 ), 100 )
					particle:VelocityDecay( true )
					
				end
				
			end
		
	--smoke cloud
		for i=1, 7 do
		
		local particle = emitter:Add( "particles/smokey", Pos + Vector(math.random(-5,5),math.random(-5,5),math.random(-5,5)))
			
			if( particle ) then
					
				particle:SetVelocity( Vector(math.random(-25,25),math.random(-25,25),math.random(55,200)) * scale )
				particle:SetDieTime( math.Rand( 2, 7 ) * scale )
				particle:SetStartAlpha( math.random( 135, 155 ) * scale )
				particle:SetEndAlpha( math.random( 0, 1 ) * scale)
				particle:SetStartSize( math.random( 5,20 ) * scale )
				particle:SetEndSize( math.random( 60, 150 ) * scale)
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



