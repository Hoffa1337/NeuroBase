function EFFECT:Init( data )
	
	self.Pos = data:GetOrigin()
	self.Size = data:GetScale()
	
	
end

function EFFECT:Think( )
			
		local Size = self.Size
		local Pos = self.Pos
		self.Emitter = ParticleEmitter( Pos )
		for i=1, math.Clamp(Size, 10, 50) do
			
			local particle = self.Emitter:Add( "modulus/particles/Smoke"..math.random(1,6), Pos ) 
			particle:SetVelocity(VectorRand() * Size * 10)
			particle:SetDieTime( math.Rand( 0.5, 1 ) )
			particle:SetStartAlpha( math.Rand(200, 255) )
			particle:SetEndAlpha( 0 )
			particle:SetStartSize( Size / 2 )
			particle:SetEndSize( Size )
			particle:SetAirResistance( 200 )
			particle:SetRoll( 10 )
			particle:VelocityDecay( true )
			
			local particle2 = self.Emitter:Add( "modulus/particles/Fire"..math.random(1,8), Pos ) 
			particle2:SetVelocity( VectorRand() * Size * 10 ) 		
			particle2:SetDieTime( 0.3 ) 		 
			particle2:SetStartAlpha( math.Rand(200, 255) ) 
			particle2:SetEndAlpha( 0 ) 	 
			particle2:SetStartSize( Size / 2 ) 
			particle2:SetEndSize( Size ) 		 
			particle2:SetRoll( 10 ) 
			particle2:SetAirResistance( 200 ) 			


		end
			self.Emitter:Finish()
		return false
end

function EFFECT:Render()

end