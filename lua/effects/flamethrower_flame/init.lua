
function EFFECT:Init( data )

	local Pos = data:GetStart()
	local Velocity 	= data:GetNormal()
	local AddVel = data:GetEntity():GetVelocity()*0.5
	local jetlength = data:GetScale()
	
	local maxparticles1 = math.ceil(jetlength/81) + 1
	local maxparticles2 = math.ceil(jetlength/190) + 1

	Pos = Pos + Velocity * 2
	
	local emitter = ParticleEmitter( Pos )
		
		for i=1, maxparticles1 do
		
			local particle = emitter:Add( "particles/flamelet"..math.random( 1, 5 ), Pos + Velocity * i * math.Rand(1.6,3) )
			
			if( particle ) then
			
				local randvel = Velocity + Vector(math.Rand(-0.04,0.04),math.Rand(-0.04,0.04),math.Rand(-0.04,0.04))
				local partvel = randvel * math.Rand( jetlength/0.7, jetlength/0.8 ) + AddVel + Vector( 0,0,32 )
				local partime = jetlength/partvel:Length()
				if partime > 0.85 then partime = 0.85 end
				particle:SetVelocity(partvel)
				particle:SetDieTime(partime)
				particle:SetStartAlpha( math.Rand( 100, 150 ) )
				particle:SetStartSize( 1.7 )
				particle:SetEndSize( math.Rand( 72, 96 ) )
				particle:SetRoll( math.Rand( 0, 360 ) )
				particle:SetRollDelta( math.Rand( -1, 1 ) )
				particle:SetColor( math.Rand( 130, 230 ), math.Rand( 100, 160 ), 120 )
				--particle:VelocityDecay(false)
			
			end
			
		end
		
		for i=0, maxparticles2 do
		
			local particle = emitter:Add( "particles/flamelet"..math.random( 1, 5 ), Pos + Velocity * i * math.Rand(0.3,0.6))
			
			if( particle ) then
			
				particle:SetVelocity(Velocity * math.Rand( 0.42*jetlength/0.3, 0.42*jetlength/0.4 ) + AddVel)
				particle:SetDieTime(math.Rand(0.3,0.4))
				particle:SetStartAlpha( 255 )
				particle:SetStartSize( 0.6*i )
				particle:SetEndSize( math.Rand( 24, 32 ) )
				particle:SetRoll( math.Rand( 0, 360 ) )
				particle:SetRollDelta( math.Rand( -0.5, 0.5 ) )
				particle:SetColor( 30, 15, math.Rand( 190, 225 ) )
				--particle:VelocityDecay(false)
			
			end
			
		end
		for i=4, maxparticles1 do
		
			local particle = emitter:Add( "particles/smokey", Pos + Velocity * i * math.Rand(1.5,2.6) )
			
			if( particle ) then
			
				local partvel = Velocity * math.Rand( jetlength/0.5, jetlength/0.6 ) + AddVel
				local partime = jetlength/partvel:Length()
				if partime > 0.85 then partime = 0.85 end
				particle:SetVelocity(partvel)
				particle:SetDieTime(partime)
				particle:SetStartAlpha( math.Rand( 10, 20 ) )
				particle:SetStartSize( 2 )
				particle:SetEndSize( math.Rand( 96, 128 ) )
				particle:SetRoll( math.Rand( 0, 360 ) )
				particle:SetRollDelta( math.Rand( -1, 1 ) )
				particle:SetColor( 145, math.Rand( 160, 200 ), 70 )
				--particle:VelocityDecay(false)
			
			end
			
			
		end
		
		for i=0, maxparticles2 do
		
			local particle = emitter:Add( "particles/smokey", Pos + Velocity * i * math.Rand(0.35,0.55))
			
			if( particle ) then
			
				particle:SetVelocity(Velocity * math.Rand( 0.6*jetlength/0.3, 0.6*jetlength/0.4 ) + AddVel)
				particle:SetDieTime(math.Rand(0.3,0.4))
				particle:SetStartAlpha( 90 )
				particle:SetStartSize( 0.6*i )
				particle:SetEndSize( math.Rand( 24, 48 ) )
				particle:SetRoll( math.Rand( 0, 360 ) )
				particle:SetRollDelta( math.Rand( -0.5, 0.5 ) )
				particle:SetColor( 135, math.Rand( 120, 140 ), 60 )
				--particle:VelocityDecay(false)
			end
			
		end
		
	emitter:Finish()
	
end


function EFFECT:Think( )
	return false
end

function EFFECT:Render()
end



