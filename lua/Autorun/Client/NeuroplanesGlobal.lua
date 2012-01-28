-- Global client stuff

function DefaultPropPlaneCView( ply, Origin, Angles, Fov )

	local plane = ply:GetScriptedVehicle()
	local view = {
		origin = Origin,
		angles = Angles
		}

	if( ValidEntity( plane ) && ply:GetNetworkedBool( "InFlight", false )  ) then

		local pos	
		local isGuidingRocket = plane:GetNetworkedBool( "DrawTracker", false )
		local fov = GetConVarNumber("fov_desired")
		local ang,pAng = ply:EyeAngles(), plane:GetAngles()
	
		-- if( ang.p < -90 ) then
			
			-- ang.y = -ang.y
			
		-- end
		
		if( GetConVarNumber("jet_cockpitview") > 0 ) then
				
			pos = plane:LocalToWorld( plane.CockpitPosition ) //Origin//
			
		else
			
			local p = plane:GetPos() + plane:GetUp() * plane.CamUp + ply:GetAimVector() * -plane.CamDist
			local tr, trace = {},{}
			tr.start = plane:GetPos() + plane:GetUp() * 100
			tr.endpos = p
			tr.filter = { plane, ply }
			tr.mask = MASK_WORLD
			trace = util.TraceLine( tr )
			
			pos = trace.HitPos
		
		end
	
		
		if( GetConVarNumber( "jet_bomberview" ) > 0 ) then
			
			
			local a = plane:GetAngles()
			pos = plane:GetPos() + plane:GetUp() * -75 + plane:GetForward() * -200
			ang = pAng + Angle( 45, 0, 0 )
		
		end

		if ( isGuidingRocket ) then

			pos = plane:GetPos() + plane:GetUp() * -150
			fov = 60
			
		end
		
		if ( ply:KeyDown( IN_ATTACK ) && GetConVarNumber( "jet_bomberview" ) < 1 ) then
				
				ang.p = ang.p + math.Rand(-.2,.2)
				ang.y = ang.y + math.Rand(-.2,.2)
					
		end
		
		view = {
			origin = pos,
			angles = ang,-- / 2.2 ),
			fov = fov
			}
	end
	
	return view
	
end
