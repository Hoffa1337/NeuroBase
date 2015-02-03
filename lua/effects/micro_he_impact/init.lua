
function EFFECT:Init(data)

	local pos		= data:GetOrigin()			
	local normal 	= data:GetNormal()			
	local scale 		= data:GetScale()			
	local emitter 		= ParticleEmitter( self.Pos )	

	emitter = ParticleEmitter( self.Pos )
		
	for i=0, 15*scale do
		local Smoke = emitter:Add( "particle/smokesprites_000"..math.random(1,9), pos )
		if (Smoke) then
		Smoke:SetVelocity( normal * math.random( 20,500*scale) + VectorRand():GetNormalized()*100*scale )
		Smoke:SetDieTime( math.Rand( 1 , 3 )*scale )
		Smoke:SetStartAlpha( math.Rand( 80, 100 ) )
		Smoke:SetEndAlpha( 0 )
		Smoke:SetStartSize( 15*scale )
		Smoke:SetEndSize( 35*scale )
		Smoke:SetRoll( math.Rand(150, 360) )
		Smoke:SetRollDelta( math.Rand(-2, 2) )			
		Smoke:SetAirResistance( 300 ) 			 
		Smoke:SetGravity( Vector( math.Rand(-70, 70) * scale, math.Rand(-70, 70) * scale, math.Rand(0, -100) ) ) 			
		Smoke:SetColor( 90,83,68 )
		end
	end

	for i=0, 10*scale do
		local Smoke = emitter:Add( "particle/particle_composite", pos )
		if (Smoke) then
		Smoke:SetVelocity( normal * math.random( 0,400*scale) + VectorRand():GetNormalized()*5*scale )
		Smoke:SetDieTime( math.Rand( 0.5 , 1.5 )*scale )
		Smoke:SetStartAlpha( 200 )
		Smoke:SetEndAlpha( 0 )
		Smoke:SetStartSize( 20*scale )
		Smoke:SetEndSize( 30*scale )
		Smoke:SetRoll( math.Rand(150, 360) )
		Smoke:SetRollDelta( math.Rand(-2, 2) )			
		Smoke:SetAirResistance( 400 ) 			 
		Smoke:SetGravity( Vector( math.Rand(-50, 50) * scale, math.Rand(-50, 50) * scale, math.Rand(0, -100) ) ) 			
		Smoke:SetColor( 90,83,68 )
		end
	end

	for i=0, 15*scale do
		local Debris = emitter:Add( "effects/fleck_cement"..math.random(1,2),pos )
		if (Debris) then
		Debris:SetVelocity ( normal * math.random(200,300*scale) + VectorRand():GetNormalized() * 300*scale )
		Debris:SetDieTime( math.random( 0.75, 1.25) )
		Debris:SetStartAlpha( 255 )
		Debris:SetEndAlpha( 0 )
		Debris:SetStartSize( math.random(3,7*scale) )
		Debris:SetRoll( math.Rand(0, 360) )
		Debris:SetRollDelta( math.Rand(-5, 5) )			
		Debris:SetAirResistance( 50 ) 			 			
		Debris:SetColor( 90,83,68 )
		Debris:SetGravity( Vector( 0, 0, -600) ) 
		Debris:SetCollide( true )
		Debris:SetBounce( 1 )			
		end
	end

	for i=0,1 do 
		local Flash = emitter:Add( "effects/muzzleflash"..math.random(1,4), pos )
		if (Flash) then
		Flash:SetVelocity( normal*100 )
		Flash:SetAirResistance( 200 )
		Flash:SetDieTime( 0.1 )
		Flash:SetStartAlpha( 255 )
		Flash:SetEndAlpha( 0 )
		Flash:SetStartSize( math.Rand( 10, 20 )*scale )
		Flash:SetEndSize( 0 )
		Flash:SetRoll( math.Rand(180,480) )
		Flash:SetRollDelta( math.Rand(-1,1) )
		Flash:SetColor(255,255,255)	
		end
	end
	
end
 

function EFFECT:Think( )
return false
end


function EFFECT:Render()

end