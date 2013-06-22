function EFFECT:Init( data )
	self.StartPos = data:GetOrigin()
	local Pos = self.StartPos
	local Normal = Vector(0,0,1)
	
	Pos = Pos + Normal * 2
	
	local emitter = ParticleEmitter( Pos )
		
		for i=1, 4 do
		
			local particle = emitter:Add( "particles/smokey", Pos + Vector(math.Rand(-50,50),math.Rand(-50,50),math.Rand(14,70)))
			
			if( particle ) then
			
				particle:SetVelocity( Vector(math.Rand(-30,30),math.Rand(-30,30),math.Rand(-30,30)) )
				particle:SetDieTime( math.Rand( 1, 2 ) )
				particle:SetStartAlpha( math.Rand( 50, 75 ) )
				particle:SetStartSize( math.Rand( 32, 48 ) )
				particle:SetEndSize( math.Rand( 162, 230 ) )
				particle:SetRoll( math.Rand( 480, 540 ) )
				particle:SetRollDelta( math.Rand( -1, 1 ) )
				particle:SetColor( 150, 150, 150 )
				particle:VelocityDecay( false )
				particle:SetAirResistance( 40 )
				particle:SetGravity( Vector( 70, 120, 158 ) )
				
			end
			
		end
	emitter:Finish()
			-- for i=1, 30 do
		
			-- local particle = emitter:Add( "particles/flamelet"..math.Rand(1,4), Pos + Vector(-80,math.Rand(-10,10),math.Rand(-24,10)))

			-- particle:SetVelocity( Vector(math.random(-20,30),math.random(-10,30),math.random(-10,10)) )
			-- particle:SetDieTime( math.Rand( 0.7,1.2 ) )
			-- particle:SetStartAlpha( math.Rand( 80, 125 ) )
			-- particle:SetStartSize( math.Rand( 30, 60 ) )
			-- particle:SetEndSize( math.Rand( 1, 8 ) )
			-- particle:SetRoll( math.Rand( 180, 240 ) )
			-- particle:SetRollDelta( math.Rand( -1, 1 ) )
			-- particle:SetColor( 230, 230, 230 )
			-- particle:VelocityDecay( false )
			-- particle:SetAirResistance( 40 )
			-- particle:SetGravity( Vector( 0, 0, 128 ) )
			
		-- end
	-- emitter:Finish()
end

function EFFECT:Think( )
	return false
end

function EFFECT:Render()
end



