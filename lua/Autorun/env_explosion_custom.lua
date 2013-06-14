function Splode()

	local explode = ents.FindByClass("env_explosion")
	local physboom = ents.FindByClass("env_physexplosion")
	
	for k,v in pairs( explode or physboom ) do
	
		if( v:IsValid() ) then
			
			
			local Pos = v:LocalToWorld( v:OBBCenter( ) )
			if( v.DoCustomExplosion ) then
				
				ParticleEffect(v.CustomParticleEffect, Pos, Angle(0,0,0), nil )
			
			else
			
				ParticleEffect("dusty_explosion_rockets", Pos, Angle(0,0,0), nil )
				
			end
			
			v:Remove()
		
		end
		
	end
	
end

hook.Add("Think", "Splode", Splode)