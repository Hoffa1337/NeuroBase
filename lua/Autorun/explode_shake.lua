function Explode_Shake()
	for _, ply in pairs( player.GetAll() ) do
		found = false
		for k, v in pairs( ents.GetAll() ) do
			if v:GetClass() == "env_explosion" or v:GetClass() == "env_physexplosion" then
				found = true
			end
		end

		if not found then ply.ShakeTime = nil end

		for k, v in pairs( ents.GetAll() ) do
			if ( v:GetClass() == "env_explosion" or v:GetClass() == "env_physexplosion" ) and ply:Alive() then
				if ply.ShakeTime then
					if ply.ShakeTime < ( CurTime() - 1 ) then
						v:Remove()
					end
				else
					ply.ShakeTime = CurTime()
				end

				if ply:GetPos():Distance( v:GetPos() ) <= 250 then
					ply:ViewPunch( Angle( math.random( -10, 10 ), math.random( -10, 10 ), math.random( -10, 10 ) ) )
				elseif ply:GetPos():Distance( v:GetPos() ) <= 500 then
					ply:ViewPunch( Angle( math.random( -5, 5 ), math.random( -5, 5 ), math.random( -5, 5 ) ) )
				elseif ply:GetPos():Distance( v:GetPos() ) <= 750 then
					ply:ViewPunch( Angle( math.random( -1, 1 ), math.random( -1, 1 ), math.random( -1, 1 ) ) )
				end
			end
		end
	end
end
//hook.Add( "Think", "Explode_Shake_Think", Explode_Shake )