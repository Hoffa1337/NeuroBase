function EFFECT:Init( data )
	self.StartPos= data:GetOrigin()
	local Pos = self.StartPos
	local Normal = Vector(0,0,1)
	
	Pos = Pos + Normal * 2
	
	local emitter = ParticleEmitter( Pos )
		
		for i=1, 6 do
		
			local particle = emitter:Add( "particles/smokey", Pos + Vector(math.Rand(-150,150),math.Rand(-150,150),math.Rand(-25,70)))

			particle:SetVelocity( Vector(math.Rand(-30,30),math.Rand(-30,30),math.Rand(-30,30)) )
			particle:SetDieTime( math.Rand( 5, 7 ) )
			particle:SetStartAlpha( math.Rand( 110, 125 ) )
			particle:SetStartSize( math.Rand( 102, 128 ) )
			particle:SetEndSize( math.Rand( 60, 70 ) )
			particle:SetRoll( math.Rand( 480, 540 ) )
			particle:SetRollDelta( math.Rand( -1, 1 ) )
			particle:SetColor( 255, 255, 255 )
			--particle:VelocityDecay( true )
			particle:SetAirResistance( 10 )
			particle:SetGravity( Vector( math.random(-70,70), 120, -198 ) )
			
		end
	emitter:Finish()
end

function EFFECT:Think( )
	return false
end

function EFFECT:Render()
end



