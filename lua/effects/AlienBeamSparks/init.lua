function EFFECT:Init( data )
	self.StartPos= data:GetOrigin()
	local Pos = self.StartPos
	local Normal = Vector(0,0,1)
	
	Pos = Pos + Normal * 2
	
	local emitter = ParticleEmitter( Pos )
		for i = 1, 2 do
		
			local particle = emitter:Add( "effects/yellowflare", Pos + Vector(math.sin(CurTime())*math.random(-60,60),math.cos(CurTime())*math.random(-60,60),math.sin(CurTime())*math.random(-60,60)))

			particle:SetVelocity( Vector(math.Rand(-55,55),math.Rand(-55,50),math.Rand(15,100)) )
			particle:SetDieTime( math.Rand( 5, 7 ) )
			particle:SetStartAlpha( math.Rand( 230, 245 ) )
			particle:SetStartSize( math.Rand( 20, 30 ) )
			particle:SetEndSize( 1 )
			particle:SetRoll( math.Rand( 280, 350 ) )
			particle:SetRollDelta( math.Rand( -1, 1 ) )
			particle:SetColor( 255, 255, 255 )
			--particle:VelocityDecay( true )
			particle:SetAirResistance( 0 )
			
			particle:SetGravity( Vector( math.random(-37,37), math.random(-37,37), 25 ) )
			
		end
		
	emitter:Finish()
	
end

function EFFECT:Think( )
	return false
end

function EFFECT:Render()
end



