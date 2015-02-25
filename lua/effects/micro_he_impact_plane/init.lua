
function EFFECT:Init(data)

	self:ImpactPlane(data)

	
end
 
function EFFECT:ImpactPlane(data)
	
	local pos		= data:GetOrigin()			
	local normal 	= data:GetNormal()			
	local scale 		= data:GetScale()			
	local emitter 		= ParticleEmitter( pos )	
	
	emitter = ParticleEmitter( pos )
	for i=0, 4*scale do
	
		local Smoke = emitter:Add( "particle/smokesprites_000"..math.random(1,9), pos)
		
		if (Smoke) then
		
			Smoke:SetVelocity( normal * math.random( 20,70*scale) + VectorRand():GetNormalized()*150*scale )
			Smoke:SetDieTime( math.Rand( 3 , 7 )*scale )
			Smoke:SetStartAlpha( math.Rand( 20, 30 ) )
			Smoke:SetEndAlpha( 0 )
			Smoke:SetStartSize( 30*scale )
			Smoke:SetEndSize( 40*scale )
			Smoke:SetRoll( math.Rand(150, 360) )
			Smoke:SetRollDelta( math.Rand(-2, 2) )			
			Smoke:SetAirResistance( 300 ) 			 
			Smoke:SetGravity( Vector( math.Rand(-70, 70) * scale, math.Rand(-70, 70) * scale, math.Rand(0, -100) ) ) 			
			Smoke:SetColor( 100,100,100 )
			
		end
		
	end

	for i=0,3 do 
	
		local Flash = emitter:Add( "effects/muzzleflash"..math.random(1,4), pos)
		
			if (Flash) then
			Flash:SetVelocity( normal*100 )
			Flash:SetAirResistance( 200 )
			Flash:SetDieTime( 0.1 )
			Flash:SetStartAlpha( 255 )
			Flash:SetEndAlpha( 0 )
			Flash:SetStartSize( math.Rand( 20, 30 )*scale^2 )
			Flash:SetEndSize( 0 )
			Flash:SetRoll( math.Rand(180,480) )
			Flash:SetRollDelta( math.Rand(-1,1) )
			Flash:SetColor(255,255,255)	
			
		end
		
	end

 
	for i=0, 20*scale do 
	
		local particle = emitter:Add( "particles/Fire7", pos) 
		
		if (particle) then 
		
			particle:SetVelocity( ((normal*0.75)+VectorRand()) * math.Rand(50, 300)*scale ) 
			particle:SetDieTime( math.Rand(0.3, 0.5) ) 				 
			particle:SetStartAlpha( 255 )  				 
			particle:SetStartSize( math.Rand(1, 2)*scale ) 
			particle:SetEndSize( 0 ) 				 
			particle:SetRoll( math.Rand(0, 360) ) 
			particle:SetRollDelta( math.Rand(-5, 5) ) 				 
			particle:SetAirResistance( 20 ) 
			particle:SetGravity( Vector( 0, 0, -600 ) ) 
			
		end 
		
	end 
		
end

function EFFECT:Think( )
return false
end


function EFFECT:Render()

end