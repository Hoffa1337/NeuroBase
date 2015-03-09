

function EFFECT:Init( data )
	
	self.Position = data:GetOrigin()
	local Pos = self.Position
	
	local emitter = ParticleEmitter( Pos )
	
		for i=1, 5 do
		
			local particle = emitter:Add( "particles/flamelet"..math.random( 1, 5 ), Pos)

				particle:SetVelocity( Vector(math.random(-6,6),math.random(-6,6),math.random(-6,6)) )
				particle:SetDieTime( math.Rand( 0.5, 1.5 ) )
				particle:SetStartAlpha( math.Rand( 120, 150 ) )
				particle:SetStartSize( math.Rand(10,20) )
				particle:SetEndSize( math.Rand( 50, 60 ) )
				particle:SetRoll( math.Rand( 360,480 ) )
				particle:SetRollDelta( math.Rand( -1, 1 ) )
				particle:SetColor( math.Rand( 220, 255 ), math.Rand( 100, 150 ), math.Rand( 10, 150 ) )
				--particle:VelocityDecay( true )	
				
			end
		
		for i=1, 5 do
		
			local particle = emitter:Add( "particles/smokey", Pos)

			particle:SetVelocity( Vector(math.random(-6,6),math.random(-6,6),math.random(6,6)) )
			particle:SetDieTime( math.Rand( 2, 4 ) )
			particle:SetStartAlpha( math.Rand( 60, 80 ) )
			particle:SetStartAlpha( math.Rand( 20, 30 ) )
			particle:SetStartSize( math.Rand(10,20) )
			particle:SetEndSize( math.Rand( 50, 60 ) )
			particle:SetRoll( math.Rand( 360, 480 ) )
			particle:SetRollDelta( math.Rand( -1, 1 ) )
			particle:SetColor( 180, 180, 180 )
			--particle:VelocityDecay( true )
		
		end
			
	emitter:Finish()
	
end


function EFFECT:Think( )

return false
		
end


function EFFECT:Render()
	-- Do nothing - this effect is only used to spawn the particles in Init
end



