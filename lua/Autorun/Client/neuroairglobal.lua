local Meta = FindMetaTable( "Entity" )
local matHeatWave		= Material( "sprites/heatwave" )
local matFire			= Material( "effects/fire_cloud1" )
local matPlasma			= Material( "effects/strider_muzzle" )
local matSprite 		= Material( "sprites/gmdm_pickups/light"  )
local CDTimer = {}

hook.Add("SpawnMenuOpen", "NeuroPlanes_DisableQMenu", function()
	
	
	
	return !IsValid( LocalPlayer():GetScriptedVehicle() )

end ) 

-- hook.Add("CreateMove", "MyCreateMove", function( cmd )

	-- local p = LocalPlayer()
	-- local v = p:GetScriptedVehicle()
	
	-- if( IsValid( v ) && v.ClimbPunishmentMultiplier ) then
	
		
		-- local an = cmd:GetViewAngles()
		-- local newAng = LocalPlayer():GetScriptedVehicle():GetAngles()
		-- local a = Angle( an.p, an.y, p:GetAngles().r ) 
		-- cmd:SetViewAngles(a)
	
	-- end
	
	
-- end )

hook.Add( "Think", "NeuroTec_SendKeyBinds", function()
	
	local ply = LocalPlayer()
	ply.LastNetTick = ply.LastNetTick or 0
	ply.LastRudderVal = ply.LastRudderVal or 0
	ply.NewRudderVal = ply.NewRudderVal or 0
	
	if( ply.LastNetTick + 0.25 <= CurTime() && IsValid( ply:GetScriptedVehicle() ) ) then
		
		ply.LastNetTick = CurTime()
		
		if ( input.IsKeyDown( KEY_Q ) ) then	
			
			ply.NewRudderVal = -1
		
		elseif( input.IsKeyDown( KEY_E ) ) then
			
			ply.NewRudderVal = 1
		
		else
			
			ply.NewRudderVal = 0
		
		end
		
		-- print( newrudderval )
		if( ply.LastRudderVal != ply.NewRudderVal ) then
		
			ply.LastRudderVal = ply.NewRudderVal
			ply:ConCommand( "neurotec_rudder ".. ply.LastRudderVal  )
		
		end
		
	end
	
end ) 


-- local Sent = false


function Meta:CivAir_CInit()
	
	-- self:SetShouldDrawInViewMode( true )
	self.CamDist = self.CameraDistance or 400
	self.CamUp = self.CameraUp or 100
	-- self.CockpitPosition = Vector( 0, 9, 23 )
	self.Emitter = ParticleEmitter( self:GetPos(), false )
end

function Meta:CivAir_Draw()
		if( self.DamagePositions ) then
		local emitter = ParticleEmitter(Vector(0, 0, 0))
			
		for k,v in ipairs( self.DamagePositions ) do
			
			if( v[1]    ) then 
				
				if(  v[2] < 133700 ) then 
				
					local smoke = emitter:Add("effects/smoke_b", self:LocalToWorld( v[1] ) )
					smoke:SetVelocity(self:GetForward()*-80)
					smoke:SetDieTime(math.Rand(.9,.2))
					smoke:SetStartAlpha(math.Rand(55,87))
					smoke:SetEndAlpha(0)
					smoke:SetStartSize(math.random(4,7))
					smoke:SetEndSize(math.random(26,32))
					smoke:SetRoll(math.Rand(-15,15))
					smoke:SetRollDelta(math.Rand(-2,2))
					smoke:SetGravity( Vector( 0, math.random(1,90), math.random(51,155) ) )
					smoke:SetColor(50, 50, 50)
					smoke:SetAirResistance(60)
					
				end
				
				if( v[2] > 20 && v[2] < 133700 ) then
					
					local smoke = emitter:Add("effects/smoke_a", self:LocalToWorld( v[1] ) )
					smoke:SetVelocity(self:GetForward()*-80)
					smoke:SetDieTime(math.Rand(.6,.2))
					smoke:SetStartAlpha(math.Rand(12,24))
					smoke:SetEndAlpha(0)
					smoke:SetStartSize(math.random(16,20))
					smoke:SetEndSize(math.random(22,26))
					smoke:SetRoll(math.Rand(-15,15))
					smoke:SetRollDelta(math.Rand(-2,2))
					smoke:SetGravity( Vector( 0, math.random(1,90), math.random(51,155) ) )
					smoke:SetColor(50, 50, 50)
					smoke:SetAirResistance(60)
					
				end
				if( v[2] == 133701 ) then
					
					local smoke = emitter:Add("particle/water/watersplash_001a_refract", self:LocalToWorld( v[1] ) + self:GetRight() * math.random(-8,8) )
					smoke:SetVelocity(self:GetForward()*-80)
					smoke:SetDieTime(math.Rand(.6,.2))
					smoke:SetStartAlpha(math.Rand(255,255))
					smoke:SetEndAlpha(0)
					smoke:SetStartSize(math.random(2,4))
					smoke:SetEndSize(math.random(12,16))
					smoke:SetRoll(math.Rand(-15,15))
					smoke:SetRollDelta(math.Rand(-2,2))
					smoke:SetGravity( Vector( 0, math.random(1,90), math.random(51,155) ) )
					smoke:SetColor(255, 255, 255 )
					smoke:SetAirResistance(60)
					-- 
				
				end
				
				if( v[2] == 133700  ) then
					
			
					local bonepos = self:LocalToWorld( v[1] ) 
					local tr,trace={},{}
					tr.start = bonepos + self:GetUp() * 72
					tr.endpos = bonepos 
					tr.mask = MASK_SHOT_HULL
					trace = util.TraceLine( tr ) 
					
					bonepos = trace.HitPos + trace.HitNormal * -2
					local dlight = DynamicLight( self:EntIndex().."_"..k )
					if ( dlight ) then

						local c = Color( 191+math.random(-5,5), 64+math.random(-5,5), 0, 100 )

						dlight.Pos = bonepos
						dlight.r = c.r
						dlight.g = c.g
						dlight.b = c.b
						dlight.Brightness = 1 + math.Rand( 0, 1 )
						dlight.Decay = 0.1 + math.Rand( 0.01, 0.1 )
						dlight.Size = 128
						dlight.DieTime = CurTime() + 0.025

					end
					local fire = emitter:Add("particles/Fire1", bonepos+VectorRand() )
					fire:SetVelocity(self:GetForward()*-1)
					fire:SetDieTime(math.Rand(0.2,.53))
					fire:SetStartAlpha(math.Rand(155,255))
					fire:SetEndAlpha(0)
					fire:SetStartSize(math.random(11,13))
					fire:SetEndSize(math.random(0,0))
					fire:SetAirResistance(5)
					fire:SetRoll(math.Rand(180,480))
					fire:SetRollDelta(math.Rand(-10,10))
					fire:SetColor(255,110,0)
					fire:SetGravity( self:GetForward() * -150 )	
					
					local fire = emitter:Add("effects/smoke_a", bonepos  )
					fire:SetVelocity(self:GetForward()*1)
					fire:SetDieTime(math.Rand(.16,0.4))
					fire:SetStartAlpha(math.Rand(110,155))
					fire:SetEndAlpha(0)
					fire:SetStartSize(math.random(9,12))
					fire:SetEndSize(math.random(0,0))
					fire:SetAirResistance(5)
					fire:SetRoll(math.Rand(180,480))
					fire:SetRollDelta(math.Rand(-3,3))
					fire:SetColor(255,110,0)
					fire:SetGravity( self:GetForward() * -150 )	
					
					local fire = emitter:Add("effects/fas_glow_debris", bonepos )
					fire:SetVelocity(self:GetForward()*-1)
					fire:SetDieTime(math.Rand(.1,.2))
					fire:SetStartAlpha(math.Rand(115,215))
					fire:SetEndAlpha(255)
					fire:SetStartSize(math.random(7,math.random(11,19) ) )
					fire:SetEndSize(math.random(0,0))
					fire:SetAirResistance(15)
					fire:SetRoll(math.Rand(180,480))
					fire:SetRollDelta(math.Rand(-3,3))
					fire:SetColor(255,120,0)
					fire:SetGravity( self:GetForward() * -150 )	
					
					local smoke = emitter:Add("effects/smoke_a", bonepos )
					smoke:SetDieTime(math.Rand(3.6,4.2))
					smoke:SetStartAlpha(math.Rand(45,76))
					smoke:SetEndAlpha(0)
					smoke:SetStartSize(math.random(5,8))
					smoke:SetEndSize(math.random(85,125))
					smoke:SetRoll(math.Rand(-15,15))
					smoke:SetRollDelta(math.Rand(-2,2))
					smoke:SetGravity( self:GetForward() * -150 + VectorRand() * 16)
					smoke:SetColor(50, 50, 50)
					smoke:SetAirResistance(60)
					
					
				end
				
			end
				
		end
		
	end
				

	local ExhaustSmoke = self.ExhaustTexture or "particle/smokesprites_000"..math.random(1,9) 
	local pilot = self:GetNetworkedEntity( "Pilot", NULL )
	local hp = math.floor( self:GetNetworkedInt( "Health", 0 ) )
	local maxhp = math.floor( self:GetNetworkedInt( "MaxHealth", 0 ) )
	local percentage =  math.ceil( hp * 100 / maxhp )
	
	self:DefaultDrawInfo()
	
	if( !IsValid( pilot ) || self:GetNetworkedBool("Destroyed",false)  ) then return end
	
	local div = 1
	if( self.TinySmoke ) then
		
		div = self.ParticleSize or 4
		
	end
	
	if( percentage < 20 ) then	
		
		ExhaustSmoke = "particle/smokesprites_000"..math.random(1,9) 
		
	end
	if( type(self.ExhaustPos ) == "table" ) then
	
		for i=1,#self.ExhaustPos do
		
			local particle = self.Emitter:Add( ExhaustSmoke, self:LocalToWorld( self.ExhaustPos[i] ) )

			if ( particle ) then
				
				if( self.JetExhaust ) then
					-- local vOffset = self:LocalToWorld( self.ExhaustPos[i] )
					-- local vNormal = (vOffset - self:LocalToWorld( self.ExhaustPos[i] ) + self:GetForward()*-32):GetNormalized()

					-- local scroll = 0.000001 + (CurTime() * -10)
					
					-- local Scale = 0.2-- math.Clamp( (CurTime() - self.OnStart) * 5, 0, 1 )
						
					-- render.SetMaterial( matFire )
					
					-- render.StartBeam( 3 )
						-- render.AddBeam( vOffset, 32 * Scale, scroll, Color( 0, 0, 255, 32) )
						-- render.AddBeam( vOffset + vNormal * 60 * Scale, 16 * Scale, scroll + 1, Color( 255, 255, 255, 32) )
						-- render.AddBeam( vOffset + vNormal * 148 * Scale, 16 * Scale, scroll + 3, Color( 255, 255, 255, 0) )
					-- render.EndBeam()
					
					-- scroll = scroll * 0.5
					
					-- render.UpdateRefractTexture()
					-- render.SetMaterial( matHeatWave )
					-- render.StartBeam( 3 )
						-- render.AddBeam( vOffset, 45 * Scale, scroll, Color( 0, 0, 255, 32) )
						-- render.AddBeam( vOffset + vNormal * 16 * Scale, 16 * Scale, scroll + 2, Color( 255, 255, 255, 32) )
						-- render.AddBeam( vOffset + vNormal * 64 * Scale, 24 * Scale, scroll + 5, Color( 0, 0, 0, 0) )
					-- render.EndBeam()
					
					
					-- scroll = scroll * 1.3
					-- render.SetMaterial( matFire )
					-- render.StartBeam( 3 )
						-- render.AddBeam( vOffset, 8 * Scale, scroll, Color( 0, 0, 255, 32) )
						-- render.AddBeam( vOffset + vNormal * 32 * Scale, 8 * Scale, scroll + 1, Color( 255, 255, 255, 32) )
						-- render.AddBeam( vOffset + vNormal * 108 * Scale, 8 * Scale, scroll + 3, Color( 255, 255, 255, 0) )
					-- render.EndBeam()
					local dir = self:GetForward()
					local VectorThrust = self:GetNWEntity("VectorThrustObject")
					if( IsValid( VectorThrust ) ) then 
					
						dir = VectorThrust:GetForward()
						-- print("VECTOR THRUST")
					end 
					
					particle:SetVelocity( dir* -300 + Vector( math.Rand( -1.5,1.5),math.Rand( -1.5,1.5),math.Rand( -1.5,1.5)  ) / div )
					-- print("lahme")
					render.SetMaterial( matSprite )
					if( !pilot._SpriteSize ) then pilot._SpriteSize = 12 end 
					
					
					if( IsValid( pilot ) && pilot:KeyDown( IN_JUMP ) ) then	
						-- local size = 
						pilot._SpriteSize = Lerp( 0.1,  pilot._SpriteSize, 16 )
									
						local dlight = DynamicLight( self:EntIndex().."_"..i )
						if ( dlight ) then

							local c = Color( 210+math.random(0,30), 102, 15, 255 )
							if( self.HasAfterBurner ) then
									
								c = Color( 34, 0, 255, 240 )
									
							end
							
							dlight.Pos = self:LocalToWorld( self.ExhaustPos[i] + self:GetForward() *-5 )
							dlight.r = c.r
							dlight.g = c.g
							dlight.b = c.b
							dlight.Brightness = .01
							dlight.Decay = 0.01 
							dlight.Size = pilot._SpriteSize+math.Rand(-.25,.25)
							dlight.DieTime = CurTime() + 0.15

						end
						
					else
					
						pilot._SpriteSize = Lerp( 0.101,  pilot._SpriteSize, 9 )
						
					end
					
					render.DrawSprite( self:LocalToWorld( self.ExhaustPos[i]  ), pilot._SpriteSize+math.Rand(-.2,.2), pilot._SpriteSize+math.Rand(-.2,.2), Color( 222, 102, 15, 255 ) )
			
					
				else
				
					particle:SetVelocity( Vector( math.Rand( -1.5,1.5),math.Rand( -1.5,1.5),math.Rand( 2.5,15.5)  ) / div )
					
				end
				
				if( self.ExhaustDieTime ) then
				
					particle:SetDieTime( self.ExhaustDieTime ) 
				
				else
				
					particle:SetDieTime( math.Rand( 3, 5 ) / div )
					
				end
				
				particle:SetStartAlpha( math.Rand( 20, 30 ) )
				particle:SetEndAlpha( 0 )
				particle:SetStartSize( math.Rand( 3, 5 )/div )
				if( self.JetExhaust ) then
				
					particle:SetEndSize( 0 )
				
					
				else
					
					particle:SetEndSize( math.Rand( 8, 16 )/div )
					
				end
				
				particle:SetRoll( math.Rand(0, 360) )
				particle:SetRollDelta( math.Rand(-1, 1) )
				particle:SetColor( math.Rand(35,45), math.Rand(35,45), math.Rand(35,45) ) 
				particle:SetAirResistance( 100 ) 
				if( !self.JetExhaust ) then
				
					particle:SetGravity( VectorRand():GetNormalized()*math.Rand(7, 16)+Vector(0,0,math.Rand(70, 110)) / div ) 	

				end
				
			end
			
		end
		
	else
	
		local particle = self.Emitter:Add( ExhaustSmoke, self:LocalToWorld( self.ExhaustPos ) )

		if ( particle ) then
			
			particle:SetVelocity( Vector( math.Rand( -1.5,1.5),math.Rand( -1.5,1.5),math.Rand( 2.5,15.5)  ) )
			particle:SetDieTime( math.Rand( 4, 6 ) )
			particle:SetStartAlpha( math.Rand( 20, 30 ) )
			particle:SetEndAlpha( 0 )
			particle:SetStartSize( math.Rand( 3, 5 ) )
			particle:SetEndSize( math.Rand( 8, 16 ) )
			particle:SetRoll( math.Rand(0, 360) )
			particle:SetRollDelta( math.Rand(-1, 1) )
			particle:SetColor( math.Rand(35,45), math.Rand(35,45), math.Rand(35,45) ) 
			particle:SetAirResistance( 100 ) 
			particle:SetGravity( VectorRand():GetNormalized()*math.Rand(7, 16)+Vector(0,0,math.Rand(70, 110)) ) 	

		end
		
	end
	
end

function Meta:NA_DefaultInit()
	
	self.FlameSpriteSize = 0
	self.CameraLerpValue = 0
	self.MyLerpAngle = self:GetAngles()
	self.MyLerpPos = self:GetPos()
	
	self.Emitter = ParticleEmitter( self:GetPos(), false )
	self.Seed = math.random( 1,10000)
	
	if( self.Cockpit3DModel ) then
	
		self.CP = ClientsideModel( self.Cockpit3DModel, RENDERGROUP_OPAQUE)
		self.CP:SetParent( self )
		self.CP:SetRenderMode( RENDERMODE_TRANSALPHA )
		self:SetRenderMode( RENDERMODE_TRANSALPHA )
		self.CP:SetPos( self:GetPos() + self:GetUp() * 99 )
		self.CP:SetAngles( self:GetAngles() )
		
	end
	
	for i=1,# self.Armament do
	CDTimer[i]=0
	end
	
end
function Meta:NA_DefaultCview( ply, Origin, Angles, Fov )

	local plane = ply:GetScriptedVehicle()
	local vel = self:GetVelocity():Length()
	self.CameraLerpValue = Lerp( 0.01, self.CameraLerpValue, vel/4 )
	
	local view = {
		origin = Origin,
		angles = Angles
		}
	
	-- print( plane )
	
	if( IsValid( plane ) && ply:GetNetworkedBool( "InFlight", false )  ) then
		
		local pos
				
		local fov = GetConVarNumber("fov_desired")
		local ang,pAng = ply:GetAimVector():Angle(), plane:GetAngles()
		local myAng = Angle( ang.p, ang.y, pAng.r )
		
		self.MyLerpPos = LerpVector( 0.1, self.MyLerpPos, self:GetPos() + self:GetForward() * -self.CamPos3rd.x + self:GetUp() * self.CamPos3rd.z ) 
		self.MyLerpAngle = LerpAngle( 0.1, self.MyLerpAngle, pAng )
			
		if( GetConVarNumber("jet_cockpitview") > 0 ) then
			
			local p = self.CamPosFirst
			pos = plane:LocalToWorld( Vector( p.x, p.y, p.z ) ) --//Origin//
			
		else
			
			if( GetConVarNumber("jet_freelook", 0 ) < 1 ) then
				
				pos = self.MyLerpPos
				myAng = self.MyLerpAngle
				
			else
			
				pos =  self:GetPos() + ply:GetAimVector() * -self.CamPos3rd.x + self:GetUp() * self.CamPos3rd.z
				
			end
			
			
		end
		
		if(  ply:KeyDown( IN_ATTACK ) && self:GetNetworkedBool( "NA_Started", false ) ) then
			
			-- pos = pos
			myAng = myAng  + Angle( math.Rand(-.35,.35), math.Rand(-.35,.35), math.Rand(-.4,.4))
		
		end

	
		
		view = {
			origin = pos,
			angles = myAng,
			fov = fov
			}

	end

	return view

end


function Meta:NA_DefaultRemove()
	
	if( IsValid( self.CP ) ) then
	
		self.CP:Remove()

	end
	
end
function Meta:NA_DefaultThink()
	
	self.Pilot = self:GetNetworkedEntity("Pilot",NULL)
	
	if( self.Cockpit3DModel && IsValid( self.CP ) ) then
	
		local jetview = GetConVarNumber("jet_cockpitview" ) > 0
		local pilot = self:GetNetworkedEntity("Pilot", NULL )
		self.CP:SetSkin( self:GetSkin() )
	
		
		if( IsValid( pilot ) && pilot == LocalPlayer() && jetview ) then

			self.CP:SetColor( Color( 255,255,255,255 ) )
			self:SetColor( Color( 0,0,0,0 ) )
			
		else

			self.CP:SetColor( Color( 0,0,0,0 ) )
			self:SetColor( Color( 255,255,255,255 ) )
			
		end
		
		
	end
	
end

function Meta:NA_DefaultDraw()

	self:DrawModel()
	
	if ( self:GetNetworkedBool("NA_Started", false ) ) then	
	
		self:NA_DrawJetFlames( )
		
	end
	
end

function Meta:NA_DrawJetFlames( )
	
	if( !self.NA_ExhaustPorts ) then return end
	
	for i=1,#self.NA_ExhaustPorts do
	
		local particle = self.Emitter:Add( "sprites/heatwave", self:LocalToWorld( self.NA_ExhaustPorts[i] ) )

		if ( particle ) then
			
			particle:SetVelocity( (self:GetVelocity()/10) *-1 + Vector( math.Rand( -2.5,2.5),math.Rand( -2.5,2.5),math.Rand( 2.5,15.5)  ) + self:GetForward()*-280 )
			particle:SetDieTime( math.Rand( 0.15, 0.25 ) )
			particle:SetStartAlpha( math.Rand( 35, 65 ) )	
			particle:SetEndAlpha( 0 )
			-- particle:EnableCollisions( true )
			particle:SetStartSize( math.Rand( 15, 17 ) )
			particle:SetEndSize( math.Rand( 125, 255 ) )
			particle:SetRoll( math.Rand( 0, 360 ) )
			particle:SetRollDelta( math.Rand( -1, 1 ) )
			particle:SetColor( math.Rand( 225, 255 ), math.Rand( 225, 255 ), math.Rand( 225, 255 ) ) 
			particle:SetAirResistance( 100 ) 
			particle:SetGravity( self:GetForward() * -500 + VectorRand():GetNormalized()*math.Rand(-140, 140)+Vector(0,0,math.random(-15, 15)) ) 	

		end
	
		local vOffset = self:LocalToWorld( self.NA_ExhaustPorts[i] )
		local vNorm = self:LocalToWorld( self.NA_ExhaustNormals[i] )
		local vNormal = (vOffset - vNorm ):GetNormalized()

		local scroll = self.Seed + (CurTime() * -10)
		
		local Scale = 2 -- math.Clamp( (CurTime() - self.OnStart) * 5, 0, 1 )
		
		-- print( self.Pilot )
		if( IsValid( self.Pilot ) ) then
			
			
			local Speed = math.floor( math.Clamp( self:GetVelocity():Length()/500, 0, 30 ) )
			
			if( self.Pilot:KeyDown( IN_SPEED ) ) then
				
				self.FlameSpriteSize = math.Approach( self.FlameSpriteSize, 200, 1 )
				-- print( Speed ) 
			else
			
				self.FlameSpriteSize = math.Approach( self.FlameSpriteSize, 0, 1 )
				
			end	
			
			render.SetMaterial( matSprite )
			
			render.DrawSprite( self:LocalToWorld( self.NA_ExhaustPorts[i] ), 25 + self.FlameSpriteSize, 25 + self.FlameSpriteSize, Color( 222, 102, 15, 255 ) )
			
		
		end
		render.SetMaterial( matFire )
		
		render.StartBeam( 3 )
			render.AddBeam( vOffset, 32 * Scale, scroll, Color( 0, 0, 255, 128) )
			render.AddBeam( vOffset + vNormal * 33 * Scale, 16 * Scale, scroll + 1, Color( 255, 255, 255, 128) )
			render.AddBeam( vOffset + vNormal * 55 * Scale, 16 * Scale, scroll + 3, Color( 255, 255, 255, 0) )
		render.EndBeam()
		
		scroll = scroll * 0.5
		
		render.UpdateRefractTexture()
		render.SetMaterial( matHeatWave )
		render.StartBeam( 3 )
			render.AddBeam( vOffset, 45 * Scale, scroll, Color( 0, 0, 255, 128) )
			render.AddBeam( vOffset + vNormal * 16 * Scale, 16 * Scale, scroll + 2, Color( 255, 255, 255, 255) )
			render.AddBeam( vOffset + vNormal * 64 * Scale, 55 * Scale, scroll + 5, Color( 0, 0, 0, 0) )
		render.EndBeam()
		
		
		scroll = scroll * 1.3
		render.SetMaterial( matFire )
		render.StartBeam( 3 )
			render.AddBeam( vOffset, 8 * Scale, scroll, Color( 0, 0, 255, 128) )
			render.AddBeam( vOffset + vNormal * 11 * Scale, 8 * Scale, scroll + 1, Color( 255, 255, 255, 128) )
			render.AddBeam( vOffset + vNormal * 33 * Scale, 8 * Scale, scroll + 3, Color( 255, 255, 255, 0) )
		render.EndBeam()
	
	end
	
end

local JetFighter = {}
JetFighter.DrawWarning = false
JetFighter.Crosshair = nil
JetFighter.Target = NULL
JetFighter.Plane = NULL
JetFighter.Pilot = NULL
JetFighter.Weapons = NULL

local NA_HUD = {}

function NA_DrawHUD()

	JetFighter.Pilot = LocalPlayer()
	JetFighter.Plane = JetFighter.Pilot:GetNetworkedEntity( "Plane", NULL )
	JetFighter.Turret = JetFighter.Pilot:GetNetworkedEntity( "Turret", NULL )
	JetFighter.Weapons = JetFighter.Plane.Armament

	NA_HUD.DeadPilotHandler()
		
	if ( IsValid( JetFighter.Plane ) ) && !IsValid(JetFighter.Pilot.PlaneParts )  && !JetFighter.Plane.Category == "NeuroTec Micro" then	
		if( JetFighter.Weapons ) then
		
			NA_HUD.WeaponManager()
		
		end
		
	end

end

local DeathScreenFadeCounter = 0
local ypwk = "YOUR PILOT WAS KILLED"
		
function NA_HUD.DeadPilotHandler()
	
	local ply = LocalPlayer()
	
	local pilotDead = ply:GetNetworkedBool("PilotKilled", false )
	if( pilotDead ) then
		
		if( DeathScreenFadeCounter < 240 ) then
		
			DeathScreenFadeCounter = DeathScreenFadeCounter + 1.5
		
		end
		
		surface.SetDrawColor( Color( 199, 0, 0, DeathScreenFadeCounter ) )
		surface.DrawRect( 0,0, ScrW(), ScrH() )
		surface.SetFont( "DermaLarge" )

		surface.SetTextPos( ScrW()/2-surface.GetTextSize( ypwk )/2, ScrH() / 2 )
		surface.SetTextColor( Color( 255,255,255, DeathScreenFadeCounter ) )
		surface.DrawText( ypwk )
		
	else
	
		DeathScreenFadeCounter = 0 
		 
	end
	
	
end 

local function WeaponReorganizer(tbl) //This will sort the weapons hardpoint from the left wing to the right
	
	-- PrintTable( tbl )
	
	-- if true then return end
	
	-- if( tbl == nil ) then return end 
	
	local newtbl = tbl
	table.SortByMember( newtbl, "PrintName" )
	-- for k, v in ipairs( newtbl ) do
		-- print( v.PrintName )
	-- end
	
	return newtbl
end

function NA_HUD.WeaponManager() //Show hardpoints and tells you when your last used weapon is ready.
	if( !JetFighter.Weapons ) then return end 
	if( JetFighter.Plane.VehicleType == VEHICLE_HELICOPTER ) then return end
	
	local NbEquip = JetFighter.Plane:GetNetworkedInt( "NumEquipment", 1 )
	local FireMode = JetFighter.Plane:GetNetworkedInt( "FireMode", 1 )
	local CoolDown = JetFighter.Plane:GetNetworkedInt( "CoolDown", 0 )
	local IdCoolingDown = JetFighter.Plane:GetNetworkedInt( "IdCoolingDown", 1 )
	local WepCoolingDown = JetFighter.Plane:GetNetworkedString( "WeaponCoolingDown", NULL )
	local IsCoolingDown = JetFighter.Plane:GetNetworkedInt( "IsCoolingDown", false )
	local WepTable = JetFighter.Weapons
	local WepTable2 = WeaponReorganizer(WepTable)
	local maxHardpoint =  WepTable2[1].Hardpoint
	local nw = #WepTable
	-- local nw = maxHardpoint
	local pi = math.pi

	//Draw hard points
	for i,v in pairs( WepTable2 ) do
		if ( v.Type != "Effect" && v.Type != "Flarepod" ) then
			surface.SetDrawColor( 0, 255, 0, 200)
			surface.DrawOutlinedRect( ScrW()*5/6 + i/nw*128-64, ScrH()*31/32-ScrH()/12*math.sin(pi/4*(1+2*i/nw))^2, 8, ScrH()/12*math.sin(pi/4*(1+2*i/nw))^2)
			-- surface.DrawOutlinedRect( ScrW()*5/6 + v.Hardpoint/nw*128-64, ScrH()*31/32-ScrH()/12*math.sin(pi/4*(1+2*v.Hardpoint/nw)), 8, ScrH()/12*math.sin(pi/4*(1+2*v.Hardpoint/nw)))
		end
	end
	
	//draw weapon status
		surface.SetDrawColor( 0, 255, 0, 200)
		surface.DrawRect(ScrW()*5/6 + FireMode/nw*128-64, ScrH()*31/32-ScrH()/12*math.sin(pi/4*(1+2*FireMode/nw))^2, 8, ScrH()/12*math.sin(pi/4*(1+2*FireMode/nw))^2 )

	for i=1,nw do		
		if IsCoolingDown then
			CDTimer[FireMode]=1
			timer.Simple( JetFighter.Weapons[FireMode].Cooldown, function() if( !IsValid( JetFighter.Plane ) ) then return end CDTimer[FireMode]=0 end )	
		
		end

		if CDTimer[i] ==1 then
			surface.SetDrawColor( 255, 0, 0, 200)
			surface.DrawRect(ScrW()*5/6 + i/nw*128-64, ScrH()*31/32-ScrH()/12*math.sin(pi/4*(1+2*i/nw))^2, 8, ScrH()/12*math.sin(pi/4*(1+2*i/nw))^2 )
			-- surface.DrawRect(ScrW()*5/6 + IdCoolingDown/nw*128-64, ScrH()*31/32-ScrH()/12*math.sin(pi/4*(1+2*IdCoolingDown/nw))^2, 8, ScrH()/12*math.sin(pi/4*(1+2*IdCoolingDown/nw))^2 )
		end
		
		
	end

	-- draw.SimpleText( FireMode, "TargetID", ScrW()*5/6+16, ScrH()*4/5+55*0, Color( 0, 255, 0, 200 ), TEXT_ALIGN_LEFT, TEXT_ALIGN_LEFT )		

	//Draw minigun
	if ( JetFighter.Pilot:KeyDown( IN_ATTACK ) ) then
		surface.SetDrawColor( 255, 150, 0, 200)
		surface.DrawRect(ScrW()*5/6-2, ScrH()*31/32-55, 4, 24 )
	else
		surface.SetDrawColor( 0, 255, 0, 200)
		surface.DrawRect(ScrW()*5/6-2, ScrH()*31/32-55, 4, 24 )

	end
	
end
/*
function NA_HUD.WeaponManager() //Show hardpoints and tells you when your last used weapon is ready.
	
	local eq = JetFighter.Plane:GetNetworkedInt( "NumEquipment", 1 )


	local FireMode = JetFighter.Plane:GetNetworkedInt( "FireMode", -1 )
	local CoolDown = JetFighter.Plane:GetNetworkedInt( "CoolDown", 0 )
	local IdCoolingDown = JetFighter.Plane:GetNetworkedInt( "IdCoolingDown", 0 )

	
	if( !table.HasValue( JetFighter.Weapons, { Index = eq, Cooldown = CoolDown } ) ) then
		
		table.insert( JetFighter.Weapons, { Index = eq, Cooldown = CoolDown } )
		
	end
	
	-- Make sure we update the table with the weapons current cooldown.
	for k,v in pairs( JetFighter.Weapons ) do
		
		if ( eq == v.Index && v.Cooldown != CoolDown ) then
			
			v.Cooldown = CoolDown
			
		end
	
	end
	
	-- local NbEquip = JetFighter.CurrentEquipment --  
		
	draw.SimpleText( FireMode, "TargetID", ScrW()*5/6+16, ScrH()*4/5+55, Color( 0, 255, 0, 200 ), TEXT_ALIGN_LEFT, TEXT_ALIGN_LEFT )		

	if ( JetFighter.Pilot:KeyDown( IN_ATTACK ) ) then
		surface.SetDrawColor( 255, 150, 0, 200)
		surface.DrawRect(ScrW()*5/6-2-16, ScrH()*4/5+55, 4, 24 )
	else
		surface.SetDrawColor( 0, 255, 0, 200)
		surface.DrawRect(ScrW()*5/6-2-16, ScrH()*4/5+55, 4, 24 )

	end

	for k,v in pairs( JetFighter.Weapons ) do
	
		surface.SetDrawColor( 0, 255, 0, 200)
		surface.DrawOutlinedRect( ScrW()*5/6-16 + i/k*128, ScrH()*4/5+55, 8, 64 )
		surface.DrawRect(ScrW()*5/6-16 + FireMode/k*128, ScrH()*4/5+55, 8, 64 )
		
	end
	
	for k,v in pairs( JetFighter.Weapons ) do
		
		if v.Cooldown !=0 then
		
			surface.SetDrawColor( 255, 0, 0, 200)
			surface.DrawRect(ScrW()*5/6-16 + v.Cooldown/k*128, ScrH()*4/5+55, 8, 64 )
		
		end
		
	end
		
	
end
*/
hook.Add( "HUDPaint", "NeuroAir_DrawHUD", NA_DrawHUD )


print( "[NeuroPlanes] neuroairglobal.lua loaded!" )