 include('shared.lua')     
   function ENT:Draw()            
      self.Entity:DrawModel()
   end
 
function ENT:Initialize()
	pos = self:GetPos()
	self.emitter = ParticleEmitter( pos )
 end
 
 function ENT:Think()

	pos = self:GetPos()
		for i=1, 1 do
			local particle = self.emitter:Add( "particle/smokesprites_000"..math.random(1,9), pos)
			if (particle) then
				particle:SetVelocity( VectorRand():GetNormalized()*math.Rand(20, 30) )
				particle:SetDieTime( math.Rand( 18, 25 ) )
				particle:SetStartAlpha( math.Rand( 40, 50 ) )
				particle:SetEndAlpha( 0 )
				particle:SetStartSize( math.Rand( 18, 23 ) )
				particle:SetEndSize( math.Rand( 250, 300 ) )
				particle:SetRoll( math.Rand(0, 360) )
				particle:SetRollDelta( math.Rand(-1, 1) )
				particle:SetColor( 30 , 200 , 30 ) 
 				particle:SetAirResistance( 100 ) 
 				particle:SetGravity( VectorRand():GetNormalized()*math.Rand(50, 70)+Vector(0,0,math.Rand(150, 200)) ) 	

		end
	end
end