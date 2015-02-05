
function EFFECT:Init(data)
	
	self:ImpactGround(data)
	
end
 
function EFFECT:ImpactGround(data)
 
	local pos		= data:GetOrigin()			
	local normal 	= data:GetNormal()			
	local scale 		= data:GetScale()			
	local emitter 		= ParticleEmitter( pos )	

	emitter = ParticleEmitter( pos )
	
	sound.Play( "Bullet.Flesh", pos)
	
	for i=0, math.ceil( (10)*scale ) do

		local Spray = self.Emitter:Add( "particle/particle_composite", pos )
		
		if ( Spray ) then
			
			Spray:SetVelocity( (normal*i*scale*40) + (VectorRand():GetNormalized()*30*scale) )
			Spray:SetDieTime( math.Rand( 0.3 , 0.9 ) )
			Spray:SetStartAlpha( 100 )
			Spray:SetEndAlpha( 0 )
			Spray:SetStartSize( 15*scale )
			Spray:SetEndSize( 35*scale )
			Spray:SetRoll( math.Rand(150, 360) )
			Spray:SetRollDelta( math.Rand(-3, 3) )			
			Spray:SetAirResistance( 400 ) 			 		
			Spray:SetColor( 70,35,35 )
			
		end
		
	end

	for i=0, math.ceil( (15)*scale) do
	
		local Mist = self.Emitter:Add( "particle/smokesprites_000"..math.random(1,9), pos )
		
		if ( Mist ) then
		
			Mist:SetVelocity( (normal*i*scale*35) + (VectorRand():GetNormalized()*30*scale) )
			Mist:SetDieTime( math.Rand( 0.3 , 1.5 ) )
			Mist:SetStartAlpha( 80 )
			Mist:SetEndAlpha( 0 )
			Mist:SetStartSize( 10*scale )
			Mist:SetEndSize( 30*scale )
			Mist:SetRoll( math.Rand(150, 360) )
			Mist:SetRollDelta( math.Rand(-2, 2) )			
			Mist:SetAirResistance( 300 ) 			 
			Mist:SetGravity( Vector( math.Rand(-50, 50) * scale, math.Rand(-50, 50) * scale, math.Rand(-100, -400) ) ) 			
			Mist:SetColor( 70,35,35 )
			
		end
		
	end

	for i=0, math.ceil((25)*scale) do
	
		local Chunks = self.Emitter:Add( "effects/fleck_cement"..math.random(1,2), pos )
		
		if ( Chunks ) then
		
			Chunks:SetVelocity ( (normal*scale*math.Rand(-100, 300)) + (VectorRand():GetNormalized()*50*scale) )
			Chunks:SetDieTime( math.random( 0.3, 0.8) )
			Chunks:SetStartAlpha( 255 )
			Chunks:SetEndAlpha( 0 )
			Chunks:SetStartSize( 3*scale )
			Chunks:SetEndSize( 3*scale )
			Chunks:SetRoll( math.Rand(0, 360) )
			Chunks:SetRollDelta( math.Rand(-5, 5) )			
			Chunks:SetAirResistance( 30 ) 			 			
			Chunks:SetColor( 70,35,35 )
			Chunks:SetGravity( Vector( 0, 0, -600) ) 
			Chunks:SetCollide( true )
			Chunks:SetBounce( 0.01 )	
			
		end
		
	end

	for i=0, math.ceil( 8*scale) do
	
		local Smoke = self.Emitter:Add( "particle/smokesprites_000"..math.random(1,9), pos )
		
		if ( Smoke ) then
		
			Smoke:SetVelocity( self.DirVec*math.random( 10,30*scale) + VectorRand():GetNormalized()*120*scale )
			Smoke:SetDieTime( math.Rand( 0.5 , 3 )*scale )
			Smoke:SetStartAlpha( math.Rand( 40, 50 ) )
			Smoke:SetEndAlpha( 0 )
			Smoke:SetStartSize( 20*scale )
			Smoke:SetEndSize( 30*scale )
			Smoke:SetRoll( math.Rand(150, 360) )
			Smoke:SetRollDelta( math.Rand(-1, 1) )			
			Smoke:SetAirResistance( 200 ) 			 
			Smoke:SetColor( 100,100,100 )
			
		end
		
	end

 end


function EFFECT:Think( )
return false
end


function EFFECT:Render()

end