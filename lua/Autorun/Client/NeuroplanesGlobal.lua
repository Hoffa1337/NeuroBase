local Meta = FindMetaTable("Entity")

function Meta:SetShouldDrawInViewMode( a ) 
return
end

local matHeatWave		= Material( "sprites/heatwave" )
local matFire			= Material( "effects/fire_cloud1" )
local matPlasma			= Material( "effects/strider_muzzle" )
local matSprite 		= Material( "sprites/gmdm_pickups/light"  )


function Meta:JetAir_DrawJetFlames( pos )

	local vOffset = pos + self:GetForward() * -1
	local vNormal = ( vOffset - pos ):GetNormalized()
	local Throttle = math.Clamp( self:GetVelocity():Length() / (1.8 * 965) + 0.01,0, 10 )
	local scroll = CurTime() * -20
	local Scale = 1.5 * Throttle
	
	render.SetMaterial( matHeatWave )
	
	scroll = scroll * 0.9
	render.StartBeam( 3 )
		render.AddBeam( vOffset, 16, scroll, Color( 0, 255, 255, 205 ) )
		render.AddBeam( vOffset + vNormal * 16 * Scale, 32, scroll + 0.01, Color( 255, 255, 255, 205 ) )
		render.AddBeam( vOffset + vNormal * 128 * Scale, 32, scroll + 0.02, Color( 0, 255, 255, 15 ) )
	render.EndBeam()

	scroll = scroll * 0.9
	
	render.StartBeam( 3 )
		render.AddBeam( vOffset, 32, scroll, Color( 0, 255, 255, 255) )
		render.AddBeam( vOffset + vNormal * 16 * Scale, 32, scroll + 0.01, Color( 255, 255, 255, 255 ) )
		render.AddBeam( vOffset + vNormal * 128 * Scale, 32, scroll + 0.02, Color( 0, 255, 255, 0 ) )
	render.EndBeam()
	
	scroll = scroll * 0.6
	
	render.StartBeam( 3 )
		render.AddBeam( vOffset, 32, scroll, Color( 0, 255, 255, 255) )
		render.AddBeam( vOffset + vNormal * 16 * Scale, 32, scroll + 0.01, Color( 255, 255, 255, 255 ) )
		render.AddBeam( vOffset + vNormal * 128 * Scale, 32, scroll + 0.02, Color( 0, 255, 255, 0 ) )
	render.EndBeam()

	scroll = scroll * 0.5
	render.UpdateRefractTexture()
	
	render.StartBeam( 3 )
		render.AddBeam( vOffset, 16 * Scale, scroll, Color( 0, 0, 255, 128) )
		render.AddBeam( vOffset + vNormal * 32 * Scale, 32 * Scale, scroll + 2, Color( 255, 255, 255, 255 ) )
		render.AddBeam( vOffset + vNormal * 128 * Scale, 48 * Scale, scroll + 5, Color( 0, 0, 0, 0 ) )
	render.EndBeam()
	
	local extra = math.Clamp( self:GetVelocity():Length() / (1.8 * 965),0, 25 )
	render.SetMaterial( matSprite )
	render.DrawSprite( pos, 32 + extra, 32 + extra, Color( 25,25,255,165 ) )
	
end

function Meta:JetAir_Draw()
	local p = LocalPlayer()
	self:DrawModel()
	
	if( self.ExhaustPositions ) then
		
		for i = 1, #self.ExhaustPositions do
			
			self:JetAir_DrawJetFlames( self.ExhaustPositions[i] )

		end
		
	end
	
end

function Meta:JetAir_CView( ply, Origin, Angles, Fov )

	local plane = ply:GetScriptedVehicle()

	local view = {
		origin = Origin,
		angles = Angles
		}

	if( IsValid( plane ) && ply:GetNetworkedBool( "InFlight", false )  ) then

		local pos
		
		if( GetConVarNumber("jet_cockpitview") > 0 ) then
				
			pos = plane:LocalToWorld( self.CockpitCameraPos ) //Origin//
			
		else
			
			pos = plane:GetPos() + plane:GetUp() * plane.CamUp + ply:GetAimVector() * -plane.CamDist
		
		end
		
		local isGuidingRocket = plane:GetNetworkedBool( "DrawTracker", false )
		local fov = GetConVarNumber("fov_desired")
		local ang,pAng = ply:EyeAngles(), plane:GetAngles()

		if ( isGuidingRocket ) then

			pos = plane:GetPos() + plane:GetUp() * -150
			fov = 60
			
		end
		
		if ( ply:KeyDown( IN_ATTACK ) ) then
				
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

-- Global client stuff
local ScrW = ScrW
local ScrH = ScrH

local JetFighter = {}
JetFighter.DrawWarning = false
JetFighter.Crosshair = nil
JetFighter.Target = NULL
JetFighter.Plane = NULL
JetFighter.Pilot = NULL
JetFighter.LaserGuided = NULL

function DefaultPropPlaneCView( ply, Origin, Angles, Fov )

	local plane = ply:GetScriptedVehicle()
	local view = {
		origin = Origin,
		angles = Angles
		}

	if( IsValid( plane ) && ply:GetNetworkedBool( "InFlight", false )  ) then

		local pos	
		local isGuidingRocket = plane:GetNetworkedBool( "DrawTracker", false )
		local fov = GetConVarNumber("fov_desired")
		local ang,pAng = ply:EyeAngles(), plane:GetAngles()
	
		-- if( ang.p < -90 ) then
			
			-- ang.y = -ang.y
			
		-- end
		local pilotmodel = ply:GetNetworkedEntity("NeuroPlanes_Pilotmodel", NULL )
		
		if( GetConVarNumber("jet_cockpitview") > 0 ) then
			

			-- pos = plane:LocalToWorld( plane.CockpitPosition ) //Origin//
			-- ang = pAng
			
			local a = plane:GetAngles()
			if( !plane.rollcount ) then
				
				plane.rollcount = 0
				plane.yawcount = 0
				
			end
			
			plane.yawcount = math.Approach( plane.yawcount, a.p/4, .1333 )
			plane.rollcount = math.Approach( plane.rollcount, a.r/8, .13333 )
			
			pos =  plane:GetPos() + plane:GetForward() * -plane.CameraDistance + plane:GetUp() * ( plane.CamUp + plane.yawcount ) + plane:GetRight() * plane.rollcount
			a.r = a.r / 1.4
			
			ang = LerpAngle( 0.01, plane.LastAng or Angles,  a )
			if( IsValid( pilotmodel ) ) then
				
				pilotmodel:SetColor( Color ( 0,0,0,0 ) )
				pilotmodel:SetRenderMode( RENDERMODE_TRANSALPHA )
				
			end
			
			
		else
			
			local p = plane:GetPos() + plane:GetUp() * plane.CamUp + ply:GetAimVector() * -plane.CamDist
			local tr, trace = {},{}
			tr.start = plane:GetPos() + plane:GetUp() * 100
			tr.endpos = p
			tr.filter = { plane, ply }
			tr.mask = MASK_WORLD
			trace = util.TraceLine( tr )
			
			pos = p-- trace.HitPos
			
			if( IsValid( pilotmodel ) ) then
				
				pilotmodel:SetColor( Color ( 255,255,255,255 ) )
				
			end
			
		end
		
		-- if( GetConVarNumber( "jet_bomberview" ) > 0 ) then
			 

				-- local a = plane:GetAngles()
				-- pos = plane:GetPos() + plane:GetUp() * -75 + plane:GetForward() * -200
				-- ang = pAng + Angle( 45, 0, 0 )
		
			
		-- end

		-- if ( isGuidingRocket ) then

			-- pos = plane:GetPos() + plane:GetUp() * -150
			-- fov = 60
			
		-- end
		
		-- if ( plane.NoMgun == nil && ply:KeyDown( IN_ATTACK ) && GetConVarNumber( "jet_bomberview" ) < 1 ) then
				
					
		-- end
		
		local imptime = ply:GetNetworkedInt("LastImpact",0)
		local impdamage = math.Clamp( ply:GetNetworkedInt("LastDamage",0), 0, 500 )
		local dmgscale = impdamage * 2.55 / 500 
		
		if( imptime + 0.3 >= CurTime() ) then
				
			ang.p = ang.p + math.Rand(-dmgscale,dmgscale)
			ang.y = ang.y + math.Rand(-dmgscale,dmgscale)
		
		end
			

		if( plane.MinClimb && plane.MaxClimb ) then

			-- if( ply:GetNetworkedBool("MouseAim",false) ) then
				if( GetConVarNumber("jet_cockpitview") > 0 ) then
				
					ang = plane:GetAngles()
					
					-- if( plane.PropellerPos ) then
						
						-- pos = plane:GetPos() + plane:GetForward() * 100
						
						if( ply:KeyDown( IN_FORWARD ) || ply:KeyDown( IN_BACK ) || ply:KeyDown( IN_MOVELEFT ) || ply:KeyDown( IN_MOVERIGHT ) ) then
						
							ply:SetEyeAngles( plane:GetAngles() )
						
						end
					
					-- end
				
				else
					
					ang.r = 0
					
				end
				-- pos = plane:GetPos() + plane:GetForward() * -plane.CameraDistance + plane:GetUp() * 15
				-- ang = LerpAngle( 0.125, plane.LastAng or Angles, plane:GetAngles() )
				
			-- else
				
				
				
			
			-- end
			
		end
		
		plane.LastAng = ang
		plane.LastPos = pos
		
		
		view = {
			origin = LerpVector( 0.001, plane.LastPos or Origin, pos),
			angles = ang,-- / 2.2 ),
			fov = fov
			}
	end
	
	
	return view
	
end

function DrawWeaponHUD()
	JetFighter.Pilot = LocalPlayer()
	JetFighter.Plane = JetFighter.Pilot:GetNetworkedEntity( "Plane", NULL )
	JetFighter.Target = JetFighter.Plane:GetNetworkedEntity( "Target", NULL )
		JetFighter.Plane:GetNetworkedEntity("NeuroPlanes_LaserGuided", r )
		local hp = math.floor( JetFighter.Plane:GetNetworkedInt( "Health", 0 ) )
		local SystemsError = ( hp < 10 )
	if ( IsValid( JetFighter.Plane ) ) then
		-- Hackfix to clear target lock-on
		if ( JetFighter.Target == JetFighter.Plane ) then		
			JetFighter.Target = NULL		
		end
		
		if ( JetFighter.Pilot:GetNetworkedBool( "InFlight", false ) && JetFighter.Plane != JetFighter.Pilot && not SystemsError ) then
			if( GetConVarNumber("jet_HUD") > 0 ) and ( GetConVarNumber("jet_HQhud") == 0 ) then
				JetFighter.CustomWeaponHUD()
			end
		end
	end
	
end

function JetFighter.CustomWeaponHUD()

	local wep = JetFighter.Plane:GetNetworkedString("NeuroPlanes_ActiveWeapon",tostring("NONE_AVAILABLE"))
	local wepType = JetFighter.Plane:GetNetworkedString("NeuroPlanes_ActiveWeaponType",tostring("NONE_AVAILABLE"))

	local offs = JetFighter.Plane:GetNetworkedInt( "HudOffset", 0 )
	-- local r = math.rad( 100*JetFighter.Plane:GetAngles().r-60)/180
	local pos =  ( JetFighter.Plane:GetPos( ) + JetFighter.Plane:GetUp( ) * offs + JetFighter.Plane:GetForward( ) * 100000 ):ToScreen()
	local bpos =  ( JetFighter.Plane:GetPos( ) + JetFighter.Plane:GetForward( ) * (500+JetFighter.Plane:GetVelocity():Length()/20) + JetFighter.Plane:GetUp( ) * offs ):ToScreen()
	local x,y = pos.x, pos.y
	local bx,by = bpos.x, bpos.y
	local r = math.rad(JetFighter.Plane:GetAngles().r)
	local cosr = math.cos(r)
	local sinr = math.sin(r)
	local Pi = math.pi
	local Sh = ScrH()/4
	local tpos
	local tx,ty = 0,0
	if IsValid( JetFighter.Target ) then
		tpos = ( JetFighter.Target:GetPos()):ToScreen()
		tx,ty = tpos.x, tpos.y
	end
	
	surface.SetDrawColor( 0, 255, 0, 200)
	
	//Homing Missile
	if ( wepType == "Homing" ) then
	surface.DrawCircle( x, y, Sh, Color( 0, 255, 0, 255) )
		if IsValid(JetFighter.Target) then
			if (math.abs(tx-x)<Sh-16) && (math.abs(ty-y)<Sh-16) then
			surface.DrawCircle( tx, ty, 16, Color( 0, 255, 0, 200) )			
			end
		else
		//"No Target - Launching Dumbfire"		
		end
	end
	
	//Bomb
	if ( wepType == "Bomb" ) then
		surface.SetDrawColor( 0, 255, 0, 255)
		surface.DrawLine( bx, by-16, bx, by+5*32 ) --down
		for i=1,5 do
		surface.DrawRect( bx-16-i*4 , by+i*32 , 32+i*8, 1 )
		end
		JetFighter.BombsightHUD()
	end
	
	//Laser guided Missile	
	if ( wepType == "Laser" ) then
		surface.DrawCircle( x, y, Sh, Color( 0, 255, 0, 255) )
		surface.DrawLine( x, y-16, x, y-Sh ) --up
		surface.DrawLine( x, y+16, x, y+Sh ) --down
		surface.DrawLine( x-16, y, x-Sh, y ) --left
		surface.DrawLine( x+16, y, x+Sh, y ) --right
		for i=1,4 do
		surface.DrawRect( x-16 , y+i/5*Sh , 32, 1 )
		end
		if IsValid( JetFighter.LaserGuided ) then
		surface.SetDrawColor( 255, 255, 255, 255)
		surface.DrawOutlinedRect( ScrW()/2-Sh/4, ScrH()/2-Sh/4, Sh/2, Sh/2 ) 
		//"You're already controlling a Laser Guided rocket."
		else
		surface.SetDrawColor( 0, 255, 0, 255)		
		end
	end
	
	//Hellfire
	if( wepType == "Singlelock" ) then
	surface.DrawRect( x-64 , y+32 , 8, 64 )
	surface.DrawRect( x+64 , y+32 , 8, 64 )
	end

	//Rockets
	if ( wepType == "Pod" ) then
		surface.SetDrawColor( 0, 255, 0, 255)
		for i=0,4 do
		surface.DrawRect( x-64 , y-32+i*32 , 32, 4 )
		surface.DrawRect( x+32 , y-32+i*32 , 32, 4 )
		end
	end
	
	//Laser Cannon
	if ( wepType == "Lasercannon" ) then
	surface.SetDrawColor( 0, 255, 0, 255)
	surface.DrawCircle( x, y, Sh, Color( 255, 0, 0, 255) )
	surface.DrawCircle( x, y, Sh*3/4, Color( 255, 0, 0, 255) )
	surface.DrawCircle( x, y, Sh/2, Color( 255, 0, 0, 255) )
	end
	
	//Swarm
	if ( wepType == "Swarm" ) then
		surface.SetDrawColor( 255, 0, 0, 255)
		surface.DrawLine( x, y-16, x, y-64 ) --up
		surface.DrawLine( x, y+16, x, y+64 ) --down
	end
	
	//Air to sea Torpedo
	if( wepType == "HomingTorpedo" ) then
		surface.SetDrawColor( 0, 255, 0, 255)
		for i=1,4 do
		surface.DrawRect( x , y+i*i*8 , 32, 2 )
		end	
		if IsValid(JetFighter.Target) then
			surface.DrawCircle( tx, ty, 16, Color( 0, 100, 255, 200) )			
		end
	end

	//Torpedo
	if( wepType == "Torpedo" ) then
		JetFighter.BombsightHUD()
	end

	//Dumb rocket
	if( wepType == "Dumb" ) then
		surface.DrawCircle( x, y, 16, Color( 0, 255, 0, 200) )				
	end
	
end

function JetFighter.BombsightHUD()

end

if( table.HasValue( hook.GetTable(), "Neuroplanes_Weapons_HeadsUpDisplay" ) ) then
	hook.Remove("HUDPaint", "Neuroplanes_Weapons_HeadsUpDisplay")
	print("Deleting Neuroplanes_Weapons_HeadsUpDisplay")
end
hook.Add( "HUDPaint", "Neuroplanes_Weapons_HeadsUpDisplay", DrawWeaponHUD )
print("NeuroPlanes Client Loaded")