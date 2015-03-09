/* Made by Sakarias88 */
function EFFECT:Init( data )
	
	self.Position = data:GetOrigin()	
	local emitter = ParticleEmitter( self.Position )
	local emittersed = ParticleEmitter( self.Position )

	
		for i=1, 16 do		
			local particle = emitter:Add( "effects/smoke", self.Position )

				particle:SetVelocity(Vector(math.random(-20,20),math.random(-20,20), math.random(-20, 20)))
				particle:SetDieTime( math.Rand( 5, 9 ) )
				particle:SetStartAlpha(255)
				particle:SetEndAlpha(0)
				particle:SetStartSize( math.random( 32,54 ) )
				particle:SetEndSize( math.random( 60, 150 ) )
				particle:SetRoll(math.random(-10,10))
				particle:SetRollDelta(math.random(-3,3))
				particle:SetColor( 180, 180, 180 )
				--particle:VelocityDecay(false)

			
end
//black Smoke cloud from immolate
		for i=1, 11 do
		
		local particle = emitter:Add( "particles/smokey", self.Position + Vector(math.random(-95,95),math.random(-95,25),math.random(-30,95)))

			particle:SetVelocity( Vector(math.random(-60,60),math.random(-66,70),math.random(55,200)) )
			particle:SetDieTime( math.Rand( 2, 5 ) )
			particle:SetStartAlpha( math.random( 120, 190 ) )
			particle:SetEndAlpha( math.random( 0, 10 ) )
			particle:SetStartSize( math.random( 32,54 ) )
			particle:SetEndSize( math.random( 60, 150 ) )
			particle:SetRoll( math.random( 360, 480 ) )
			particle:SetRollDelta( math.Rand( -1, 1 ) )
			particle:SetColor( 120, 120, 120 )
			--particle:VelocityDecay(false)
			
		end

	emitter:Finish()
		end


function EFFECT:Think( )
	return false	
end

function EFFECT:Render()

end



