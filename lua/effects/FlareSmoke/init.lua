function EFFECT:Init( data )
	self.StartPos= data:GetOrigin()
	local Pos = self.StartPos
	local Normal = Vector(0,0,1)
	
	Pos = Pos + Normal * 2
	
	local emitter = ParticleEmitter( Pos )
		
		for i=1, 4 do
		 
			local particle = emitter:Add( "particles/smokey", Pos + Vector(math.random(-10,10),math.random(-10,10),math.random(1,100)) )

			particle:SetVelocity( Vector(math.Rand(-30,30),math.Rand(-30,30),math.Rand(-30,30)) )
			particle:SetDieTime( math.Rand( 5, 7 ) )
			particle:SetStartAlpha( math.Rand( 30, 45 ) )
			particle:SetStartSize( math.Rand( 52, 62 ) )
			particle:SetEndSize( 2 )
			particle:SetRoll( math.Rand( 280, 350 ) )
			particle:SetRollDelta( math.Rand( -1, 1 ) )
			particle:SetColor( 255, 255, 255 )
			--particle:VelocityDecay( true )
			particle:SetAirResistance( 20 )
			particle:SetGravity( Vector( math.random(-7,7), math.random(-7,7), -100 ) )
			
		end
		
		for i = 1, 10 do
		
			local particle = emitter:Add( "effects/yellowflare", Pos + Vector(math.sin(CurTime())*math.random(-60,60),math.cos(CurTime())*math.random(-60,60),math.sin(CurTime())*math.random(-60,60)))

			particle:SetVelocity( Vector( math.Rand(-25,25), math.Rand(-25,25), math.Rand(-30,-1) ) )
			particle:SetDieTime( math.Rand( 4, 6 ) )
			particle:SetStartAlpha( math.Rand( 230, 245 ) )
			particle:SetStartSize( math.Rand( 30, 45 ) )
			particle:SetEndSize( 2 )
			particle:SetRoll( math.Rand( 280, 350 ) )
			particle:SetRollDelta( math.Rand( -1, 1 ) )
			particle:SetColor( 255, 255, 255 )
			--particle:VelocityDecay( true )
			particle:SetAirResistance( 20 )
			
			particle:SetGravity( Vector( math.random(-17,17), math.random(-17,17), math.random(-155,-50) ) )
			
		end
		
	emitter:Finish()
	
end

function EFFECT:Think( )
	return false
end

function EFFECT:Render()
end



