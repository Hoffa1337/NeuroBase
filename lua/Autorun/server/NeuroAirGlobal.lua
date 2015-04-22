-- NeuroAir framework by Hoffa
-- Handles air plane physics and global functions shared across all entities.
resource.AddFile("models/Killstr3aKs")
resource.AddFile("models/aftokinito")
resource.AddFile("materials/models/Killstr3aKs")
resource.AddFile("materials/models/aftokinito")
GLOBAL_FORCE_MULTIPLIER = 14260
local Meta = FindMetaTable("Entity")
local pairs = pairs
local ipairs = ipairs 

sound.Add( {
	name = "airspeed_warning", 
	channel = CHAN_STATIC, 
	volume = 1.0, 
	level = 80, 
	pitch = { 100, 100 }, 
	sound = "Air/airspeed_warning.mp3"
} )

-- Listen for the Q / E keybinds.
concommand.Add( "neurotec_rudder", function( ply, cmd, args )
	if( tonumber( args[1] ) != nil ) then
		
		ply.NeuroRudderValue = math.Clamp( tonumber(args[1]), -1, 1 ) 
		
		
	end

end )

function Meta:GetPlaneParts()
	if( !self.Wings || !self.Ailerons || !self.Flaps ) then 
		
		print("Wings:", self.Wings )
		print("Flaps:", self.Flaps )
		print("Ailerons:", self.Ailerons )
		error("Missing Plane Parts - Fix your plane")
		
		
		return
	
	end
	
	return { 
			self.Tail, 
			self.Wings[1], 
			self.Wings[2], 
			self.Ailerons[1], 
			self.Ailerons[2], 
			self.Flaps[1], 
			self.Flaps[2], 
			self.Elevator, 
			self.Rudder 
			}

end

function Meta:DebugDamageModel()

	local parts = self:GetPlaneParts()
	print("Found Following Parts:")
	PrintTable( parts )
	
	for k,v in pairs( parts ) do
		
		for i=1,100 do 
			
			timer.Simple(i/4, function()
				
				if( IsValid( self ) && IsValid( v ) ) then
					-- print("Damage Dealth to ", v, i/10 )
					util.BlastDamage( game.GetWorld(), game.GetWorld(), v:GetPos(), v.InitialHealth/100, 1 )
				
				end 
				
			end )
		
		end
	
	end

end 
concommand.Add("debug_damage_model", function( ply,cmd,args ) 
	
	local ride = ply:GetScriptedVehicle()
	
	if( IsValid( ride ) ) then
		
		ride:DebugDamageModel() 
		ply:PrintMessage( HUD_PRINTTALK, "[NeuroTec] Testing Damage Model")
		
	end
	
end )
util.AddNetworkString( "NeuroPlaneParts"  )
function SendPlaneParts( ply, plane )
	if( !plane.Wings || !plane.Ailerons ) then
		print("missing control surfaces or wings")
		return 
	end
	local parts = { 
					plane, 
					plane.Tail, 
					plane.Wings[1], 
					plane.Wings[2], 
					plane.Ailerons[1], 
					plane.Ailerons[2], 
					plane.Flaps[1], 
					plane.Flaps[2],
					plane.Elevator, 
					plane.Rudder 
				}
	for k,v in pairs( parts ) do 
		
		if( IsValid( v ) ) then 
		
			v:SetNetworkedInt("Health", v.InitialHealth or 0 )
			v:SetNetworkedInt("MaxHealth", v.InitialHealth or 0 )
		
		end 
		
	end
	 net.Start( "NeuroPlaneParts" )
		net.WriteInt( #parts, 32 )
		for i=1,#parts do 
			net.WriteEntity( parts[i] )	
		end
	 net.Send( ply )
	-- PrintTable( parts )
end

 util.AddNetworkString( "DamageVector" )
 function SendDamageVector( pos, ent, damage )
 
	 net.Start( "DamageVector" )
		net.WriteInt( math.floor(damage), 32 )
		net.WriteVector( pos )
		net.WriteEntity( ent )
	 net.Broadcast()
	 
 end
concommand.Add("jet_toggle_landing_gear", function(ply,cmd,arg )
	
	if( IsValid( ply ) && ply:Alive() && IsValid( ply:GetScriptedVehicle() ) && ply:GetScriptedVehicle():GetVelocity():Length() > 50 ) then
		
		local ride = ply:GetScriptedVehicle()
		
		if( IsValid( ride ) && ride.Wings ) then
			
			if( IsValid( ride.Wings[1] ) ) then
			
				ride.Wings[1]:ToggleLandingGear()
			
			end
			
			if( IsValid( ride.Wings[2] ) ) then
			
				ride.Wings[2]:ToggleLandingGear()
			
			end
			
			if( IsValid( ride.Tail ) && ride.TailModel ) then
			
				ride.Tail:ToggleLandingGear()
			
			end
			
			ply.LastLandingGearToggle = CurTime()
			
		end
	
	end
	
end )



function Meta:JetAir_OnRemove()

	if( self.EngineMux ) then
		
		for i=1,#self.EngineMux do
		
			self.EngineMux[i]:Stop()
			
		end
		
	end
	
	if( self.ContigiousFiringLoop && self.PrimarySound ) then
		
		self.PrimarySound:Stop()
		
	end
	
	if ( IsValid( self.Pilot ) ) then
	
		self:EjectPilot()
	
	end
	
end


function Meta:JetAir_TakeDamage( dmginfo )

	if ( self.Destroyed ) then
		
		return

	end
	
	self:TakePhysicsDamage(dmginfo)
	
	self.HealthVal = self.HealthVal - dmginfo:GetDamage()
	self:SetNetworkedInt( "health", self.HealthVal )
	
	if( self.HealthVal <= self.InitialHealth * .2 ) then 
		
		self.FireWarning:PlayEx( 511, 100 )
	
	end 
	
	if ( self.HealthVal < self.InitialHealth * 0.1 && !self.Burning ) then
		
		self.Burning = true
		self:Ignite( 60, 60 )
		
		-- for i=1,#self.FireTrailPos do
			
			-- for j=1,2 do

				-- local f = ents.Create("env_fire_trail")
				-- f:SetPos( self:LocalToWorld( pos[i] ) + Vector( math.random(-16,16), math.random(-16,16), 0 ) )
				-- f:SetParent( self )
				-- f:Spawn()
				
			-- end
			
		-- end
		
	end
	
	if ( self.HealthVal <= 0 ) then
	
		self:EjectPilot()
			
		return
		
	end
	
end

function Meta:Micro_GunnerThink()
	
	if( self.LastTargetCheck && self.LastTargetCheck + 5.0 <= CurTime() && !IsValid( self.Target ) && self:GetClass() != "plane_apart" ) then 
		self.LastTargetCheck = CurTime()
		
		for k,v in ipairs( player.GetAll() ) do 
			
			if( v != self.Pilot && ( v:GetPos() - self:GetPos() ):Length() < 3000 ) then 
				
				local ride = v:GetScriptedVehicle()
				if( IsValid( ride ) && ride:GetClass() == self:GetClass() ) then 
					
					continue
					
				end 
				
				self.Target = v
				
				break 
			
			end 
			
		end 
		
	end 
	
	if( IsValid( self.Target ) && self.Target:GetPos():Distance( self:GetPos() ) >= 3000 ) then self.Target = NULL end 
	
	
	if( self.TurretBones && !self.Destroyed && !self.IsBurning && ( IsValid( self.Pilot ) || ( IsValid( self.Owner ) && IsValid( self.Owner.Pilot ) ) ) ) then
		
		-- print("true?")
		local pilot =  self.Pilot
		local plane = self
		local v2 = self.Target
		if( self:GetClass() == "plane_part" ) then 
			
			plane = self.Owner
			pilot = self.Owner.Pilot 
			v2 = self.Owner.Target 
			
		end
		-- self.Target = self.Owner.Target 
		
			-- print( self:GetClass() )
		for k,v in ipairs( self.TurretBones ) do
			
			if( !v.Destroyed ) then 
			
				local bpos = self:LocalToWorld( v.Pos )
				local bang = self:GetAngles() + v.Ang
				-- if( !IsValid( self.Target ) ) then 
				
				-- for _,v2 in ipairs( player.GetAll() ) do
				if( IsValid( v2 ) ) then 
				
					local dist = (bpos-v2:GetPos()):Length()
					
					if( dist < 3000 ) then -- && ( IsValid( v2:GetVehicle() ) || IsValid( v2:GetVehicle() ) )
						
						local veh = v2:GetScriptedVehicle()
						local tpos = v2:GetShootPos()
						if( IsValid( veh ) ) then	
							
							tpos = veh:GetPos()
							
						else
							
							veh = v2
							
						end

						local targetpos = ( tpos - bpos ):Angle()
						local ydiff,pdiff = math.floor(math.AngleDifference( bang.y-90, targetpos.y  )), math.floor(math.AngleDifference( bang.p, targetpos.p ))
						v.GunEntity:SetAngles(  targetpos ) 
					
						if( v2:Alive() && ( ydiff > -45 || ydiff < 45 ) && pdiff > -45 && pdiff < 45  ) then
									
							local tr,trace={},{}
							tr.start = bpos+targetpos:Forward()*20
							tr.endpos = bpos+targetpos:Forward()*(.87*dist)
							tr.mask = MASK_SHOT_HULL
							tr.filter = { v2, tpos, veh.Owner, v.GunEntity }
							trace = util.TraceLine( tr )
							
						
							-- print( v2:Name())
							if( v.LastShot + v.CoolDown <= CurTime() && !trace.Hit ) then	
							
								v.LastShot = CurTime()
				
								local bullet = {} 
								bullet.Num 		= 1
								bullet.Src 		= tr.start
								bullet.Dir 		= v.GunEntity:GetAngles():Forward()
								bullet.Spread 	= VectorRand() * math.Rand( -.175, .175 ) --Vector( .1, .1, .1 )*math.Rand(-1,1)
								bullet.Tracer	= 1
								bullet.Force	= 45
								bullet.filter = { self, plane, pilot }
								bullet.Attacker = pilot
								bullet.Inflictor = plane
								bullet.Damage	= math.random( 2, 4 )
								bullet.AmmoType = "Ar2" 
								bullet.TracerName 	= "Tracer"
								bullet.Callback    = function ( a, b, c )
														
														local effectdata = EffectData()
															effectdata:SetOrigin( b.HitPos )
															effectdata:SetStart( b.HitNormal )
															effectdata:SetNormal( b.HitNormal )
															effectdata:SetMagnitude( 1 )
															effectdata:SetScale( 0.75 )
															effectdata:SetRadius( 1 )
														util.Effect( "micro_he_impact_plane", effectdata )
														
														return { damage = true, effects = DoDefaultEffect } 
														
												end 
					
								local sm = EffectData()
								sm:SetStart( bpos + targetpos:Forward()*4 )
								sm:SetOrigin( bpos + targetpos:Forward()*4  )
								sm:SetEntity( v.GunEntity )		
								sm:SetAttachment( 1 )
								sm:SetNormal( targetpos:Forward()*-1 )
								sm:SetScale( 0.5 )
								util.Effect( self.MicroTurretMuzzle or "MuzzleEffect", sm )
					
								self:EmitSound( v.ShootSound, 511, 100 )
								pilot:FireBullets( bullet )
										
										
									-- end )
									
								end
								
							
						
							end

					end				
				
				end 
				
				-- end
	
			end
			
		end

	end
end

function Meta:JetAir_Think()


	-- local tr,trace={},{}
	-- tr.start = self:GetPos() + self:GetForward() * 256 
	-- tr.endpos = tr.start + self:GetForward() * 2500
	-- tr.filter = { self }
	-- tr.mask = MASK_SOLID_BRUSHONLY 
	-- trace = util.TraceLine( tr )
	-- if( trace.HitSky ) then 
		
		-- local pos = trace.HitPos 
		-- local newpos = pos 
		-- newpos.x = -newpos.x 
		-- newpos.y = -newpos.y 
		-- if( util.IsInWorld( newpos ) ) then 
		
			-- self:SetPos( newpos + self:GetForward() * 256 )
			-- local objs = ents.FindInSphere( self:GetPos(), 1024 )
			-- local movables = {}
			-- for k,v in pairs( objs ) do 
				-- print("moved object")
				-- if( v.Owner == self ) then 
					-- table.insert( movables, { ent = v, pos = self:WorldToLocal( v:GetPos() ) } )
					
				-- end 
			
			-- end 
			
			-- for k,v in pairs( movables ) do 
				
				-- v.ent:SetPos( self:LocalToWorld( v.pos ) )
				
			-- end 
			
		-- else 
				 
			-- local dir = self:GetForward()
			-- dir.z = 0 
			-- local tr,trace = {},{}
			-- tr.start = self:GetPos() + dir * -5000
			-- tr.endpos = tr.start + dir * -500000
			-- tr.mask = MASK_SOLID_BRUSHONLY
			-- tr.filter = self 
			-- trace = util.TraceLine( tr ) 
			
			-- local newpos = trace.HitPos + trace.HitNormal * 500 
			-- if( util.IsInWorld( newpos ) ) then 
				
				-- self:SetPos( newpos )
				-- local objs = ents.FindInSphere( self:GetPos(), 512 )
			
			-- local movables = {}
			-- for k,v in pairs( objs ) do 
				
				-- if( v.Owner == self || v:GetOwner() == self || v:GetParent() == self ) then 
					
					-- print( "inserted", v) 
					-- table.insert( movables, { ent = v, pos = self:WorldToLocal( v:GetPos() ) } )
					
				-- end 
			
			-- end 
			
			-- for k,v in pairs( movables ) do 
				
				-- v.ent:SetPos( self:LocalToWorld( v.pos ) )
				
			-- end
			
		-- end 
			
 
		-- end 
		
		-- return 
		
	-- end 
	
	if( self.TurretBones ) then
	
		self:Micro_GunnerThink()
		
	end
	
	-- if( !seqlf.Burning && IsValid( self.Tail ) && !IsValid( self.TailWeld ) ) then
		
		-- self.Burning = true
		
		-- local f = ents.Create("env_fire_trail")
		-- f:SetPos( self:GetPos() )
		-- f:SetParent( self )
		-- f:Spawn()
		
		-- if( IsValid( self.Pilot ) ) then
			
			-- self:EjectPilot()
			
		-- end
	
	-- end
	
	-- if( !self.EngineFire && self.PropellerPos && !IsValid( self.PropellerAxis ) ) then
		
		-- if( type( self.PropellerPos ) == "table" ) then return end
		
		-- self.EngineFire = true
		
		-- local f = ents.Create("env_fire_trail")
		-- f:SetPos( self:LocalToWorld( self.PropellerPos + self:GetForward() * self.PropellerFireOffset ) )
		-- f:SetParent( self )
		-- f:Spawn()
	
	
	-- end
	

	if ( self.Destroyed ) then 
		self:SetNetworkedBool("Destroyed",true)
		-- local effectdata = EffectData()
		-- effectdata:SetOrigin( self:GetPos() + Vector( math.random(-50,50), math.random(-50,50), 0 ) )
		-- util.Effect( "immolate", effectdata )
		if( !self.DeathTimer ) then self.DeathTimer = 0 end
		
		self.DeathTimer = self.DeathTimer + 1
		
		-- self:GetPhysicsObject():AddAngleVelocity( Vector( 0, math.Rand( -0.1, 0.1 ), 0 ) )
		
		-- if( self.TinySmoke && !self.PropellerAttachedToWings && !self.CrashedAndLeaking ) then
			
			-- self.CrashedAndLeaking = true
			
			-- SendDamageVector( self:GetPos(), self, 133701  ) -- Fuel Leak
			
		-- end
		-- if( !self.FireAlarm ) then 
			
			-- self.FireAlarm = true 
		-- self:EmitSound("Tiger/fire_alarm_tank.wav")
			
		if ( self.DeathTimer > self.ImpactTime ) then
			
			-- self.LastAttacker = dmginfo:GetAttaccker()
			-- self.LastAttacked = CurTime()
			
			
			if( self.TinySmoke ) then
			
				self:EmitSound( "WT/Misc/bomb_explosion_"..math.random( 1, 6 )..".wav", 511, math.random( 98,102 ) )
				-- ParticleEffect( "neuro_gascan_explo", self:GetPos(), Angle( 0,0,0 ), nil )
				local a = self:GetAngles()
				a:RotateAroundAxis( self:GetRight(), -90 )
				
				if( self.PropellerAttachedToWings ) then -- big plane
				
					ParticleEffect( "microplane_bomber_explosion", self:GetPos(), Angle( 0,0,0 ), nil )
			
				else
				
					ParticleEffect( "microplane_midair_explosion", self:GetPos(), a, nil )
				
				end
				
				ParticleEffectAttach( "microplane_damage", PATTACH_ABSORIGIN_FOLLOW, self, 0 )
				-- for i=1,5 do
				
					-- local effectdata = EffectData()
					-- effectdata:SetOrigin( self:GetPos()  )
					-- util.Effect( "microplane_damage", effectdata )
					
				-- end
				self:EjectPilot()
				if( self.Wings ) then
					
					for k,v in pairs( self.Wings ) do
					
						if( IsValid( v ) ) then
						
							v.HealthVal = 0
							
						end
						
					end
				
				end
				
				if( self.Tail && IsValid( self.Tail ) ) then	
					
					self.Tail.HealthVal = 0
					
				end
				
				
				-- print("boom from ImpactTimer")
				self:Remove()
				
				return
				
			else
			
				self:DeathFX()
				
			end
		
		end
		
	end
		
	if( !self.IsFlying ) then return end
	local SoundPitch = math.Clamp( math.floor( self:GetVelocity():Length() / 20 + 40 ), 0, 200 )
	
	if( self.Wings && self.Tail ) then
		
		-- SoundPitch = math.Clamp( math.floor( self:GetVelocity():Length() / 10 + 40 ), 0, 180 )
		SoundPitch = math.Clamp( 70 + 500.0 * self.BoostValue /  ( self.MaxVelocity * GLOBAL_FORCE_MULTIPLIER ), 80, 160 )
		-- print( 500.0 * self.BoostValue /  ( self.MaxVelocity * GLOBAL_FORCE_MULTIPLIER ) )
	end
	
	-- rev up engine if we're stalling out
	-- if( self.LastStall && self.LastStall + 3.0 > CurTime() ) then
		
		-- SoundPitch = 120
		
	-- end
	
	self.Pitch = SoundPitch
	
	if( self.EngineMux ) then

		for i = 1,#self.EngineMux do
		
			self.EngineMux[i]:ChangePitch( self.Pitch, 0.01 )
			
		end
		
	else
	
		if( self.Propellers ) then
			
			for k,v in pairs( self.Propellers ) do
				
				if( v.EngineMux ) then
					
					for i=1,#v.EngineMux do 
					
						v.EngineMux[i]:ChangePitch( self.Pitch, 0.01 )
					
					end
					
				end
			
			end
		
		end
		
	end
	if ( self.IsFlying && IsValid( self.Pilot ) ) then
		
		-- local ImpactPos = self:BombingImpact(self:GetVelocity():Length()*1.8, self:GetAngles().p )
		
		-- self:SetNWVector("ImpactPos", ImpactPos )
		
		-- print( self.ShootSound)
		self.Pilot:SetPos( self:GetPos() + Vector(0,0,250) )
		self:UpdateRadar()
		-- self:SonicBoomTicker()
		if( !self.NoLockon ) then
		
			self:Jet_LockOnMethod()
			
		end
		
		self:NeuroPlanes_CycleThroughJetKeyBinds()

	end

	self:NextThink( CurTime() - FrameTime() )

	
	-- return true
end
function Meta:JetAir_PhysSim( phys, deltatime )

	local a = self:GetAngles()
	local stallang = ( ( a.p < -24 || a.r > 24 || a.r < -24 ) && self:GetVelocity():Length() < 500 )
	
	if ( self.IsFlying ) then
	
		phys:Wake()
		
		local p = { { Key = IN_FORWARD, Speed = 4.5 };
					{ Key = IN_BACK, Speed = -3.5 }; }
					
		for k,v in ipairs( p ) do
			
			if ( self.Pilot:KeyDown( v.Key ) ) then
			
				self.Speed = self.Speed + v.Speed
			
			end
			
		end
		
		
		local a = self.Pilot:GetPos() + self.Pilot:GetAimVector() * 3000 + self:GetUp() * -self.CrosshairOffset // This is the point the plane is chasing.
		local ta = ( self:GetPos() - a ):Angle()
		local ma = self:GetAngles()
		local pilotAng = self.Pilot:EyeAngles()
		local r,pitch,vel
		self.offs = self:VecAngD( ma.y, ta.y )		
		
		local r_mod = -1
				
		
		if( pilotAng.p < -89 || pilotAng.p > 89) then
			
			r_mod = 1
			
		end
		
		if( self.offs < -150 || self.offs > 150 ) then r = 0 else r = ( self.offs / self.BankingFactor ) * r_mod end
		

		pitch = pilotAng.p
		vel =  math.Clamp( self:GetVelocity():Length() / 15, 10, 120 )
		
		local upvalue = -420
		
		if( self:GetVelocity():Length() < 200 ) then	
			
			pilotAng.y = ma.y
			r = 0
			-- upvalue = 0
			
		end
		
		// Increase speed going down, decrease it going up
		-- if( ma.p < -21 || ma.p > 15 && !self.AfterBurner ) then 	
			
			-- self.Speed = self.Speed + ma.p/5.25 
			
		-- end
	
		self.Speed = math.Clamp( self.Speed, self.MinVelocity, self.MaxVelocity + 150 )
		
		local pr = {}
		pr.secondstoarrive	= 1
		pr.pos 				= self:GetPos() + self:GetForward() * self.Speed + Vector( 0,0, upvalue + ( self:GetVelocity():Length() / 3.5 ) )
		pr.maxangular		= 162 - vel
		pr.maxangulardamp	= 262 - vel
		pr.maxspeed			= 1000000
		pr.maxspeeddamp		= 10000
		pr.dampfactor		= 0.9
		pr.teleportdistance	= 10000
		pr.deltatime		= deltatime
		pr.angle = pilotAng + Angle( 0, 0, r - r_mod )
		
		if( stallang ) then return end
		
		phys:ComputeShadowControl( pr )
			
		self:WingTrails( ma.r, 20 )
		
	end
end
function Meta:JetAir_Init()
	
	self.HealthVal = self.InitialHealth
	
	self:SetNetworkedInt( "health",self.HealthVal)
	self:SetNetworkedInt( "HudOffset", self.CrosshairOffset )
	self:SetNetworkedInt( "MaxHealth",self.InitialHealth)
	self:SetNetworkedInt( "MaxSpeed",self.MaxVelocity)

	self.LastPrimaryAttack = CurTime()
	self.LastFireModeChange = CurTime()
	self.LastRadarScan = CurTime()
	self.LastFlare = CurTime()
	self.LastLaserUpdate = CurTime()

	// Armamanet
	local i = 0
	local c = 0
	self.FireMode = 1
	self.EquipmentNames = {}
	self.RocketVisuals = {}
	self.LastFireModeChange = CurTime()
	
	for k,v in pairs( self.Armament ) do
		
		i = i + 1
		self.RocketVisuals[i] = ents.Create("prop_physics_override")
		self.RocketVisuals[i]:SetModel( v.Mdl )
		self.RocketVisuals[i]:SetPos( self:LocalToWorld( v.Pos ) )
		self.RocketVisuals[i]:SetAngles( self:GetAngles() + v.Ang )
		self.RocketVisuals[i]:SetParent( self )
		self.RocketVisuals[i]:SetSolid( SOLID_NONE )
		self.RocketVisuals[i].Type = v.Type
		self.RocketVisuals[i].PrintName = v.PrintName
		self.RocketVisuals[i].Cooldown = v.Cooldown
		self.RocketVisuals[i].isFirst = v.isFirst
		self.RocketVisuals[i].Identity = i
		self.RocketVisuals[i].Class = v.Class
		self.RocketVisuals[i]:Spawn()
		self.RocketVisuals[i].LastAttack = CurTime()
		
		if( v.LaunchSound ) then
			
			self.RocketVisuals[i].LaunchSound = v.LaunchSound
			
		end
		
		if ( v.Damage && v.Radius ) then
			
			self.RocketVisuals[i].Damage = v.Damage
			self.RocketVisuals[i].Radius = v.Radius
		
		end
		
		if( v.Color ) then
			
			self.RocketVisuals[i]:SetRenderMode( RENDERMODE_TRANSALPHA )
			self.RocketVisuals[i]:SetColor( v.Color )
			self.RocketVisuals[i].Color = v.Color
			if( v.Color == Color( 0,0,0,0 ) ) then
				
				self.RocketVisuals[i]:DrawShadow( false )
				
			end
		
		end
		
		// Usuable Equipment
		if ( v.isFirst == true || v.isFirst == nil /* Single Missile*/ ) then
		
			if ( v.Type != "Effect" ) then
				
				c = c + 1
				self.EquipmentNames[c] = {}
				self.EquipmentNames[c].Identity = i
				self.EquipmentNames[c].Name = v.PrintName
				
			end
			
		end
		
	end
	
	self.NumRockets = #self.EquipmentNames
	
	self.Trails = {}

	// Sound
	
	self.EngineMux = {}
	
	for i=1, #self.EngineSounds do
	
		self.EngineMux[i] = CreateSound( self, self.EngineSounds[i] )
		
	end
	
	// Sonic Boom variables
	local fxsound = { "ambient/levels/canals/dam_water_loop2.wav", "LockOn/SonicBoom.mp3", "LockOn/Supersonic.mp3" }
	self.PCfx = 0
	self.FXMux = {}
	
	for i=1, #fxsound do
	
		self.FXMux[i] = CreateSound( self, fxsound[i] )
		
	end
	
	self.Pitch = 80
	for i=1,#self.EngineMux do
		
		self.EngineMux[i]:PlayEx( 500 , self.Pitch )
		
	end
	
	self:SetUseType( SIMPLE_USE )
	self.IsFlying = false
	self.Pilot = NULL
	
	self.Miniguns = {}
	
	for i=1,#self.MinigunPos do
		
		self.Miniguns[i] = ents.Create("prop_physics_override")
		self.Miniguns[i]:SetPos( self:LocalToWorld( self.MinigunPos[i] ) )
		self.Miniguns[i]:SetModel( self.MachineGunModel )
		self.Miniguns[i]:SetAngles( self:GetAngles() )
		self.Miniguns[i]:SetNoDraw( true )
		self.Miniguns[i]:DrawShadow( false )
		self.Miniguns[i]:SetParent( self )
		self.Miniguns[i]:SetSolid( SOLID_NONE )
		self.Miniguns[i]:Spawn()
		self.Miniguns[i].LastAttack = CurTime()
		
	end
	self.MinigunIndex = 1
	self.MinigunMaxIndex = #self.Miniguns
		
	// Misc
	self:SetModel( self.Model )	
	self:PhysicsInit( SOLID_VPHYSICS )
	self:SetMoveType( MOVETYPE_VPHYSICS )
	self:SetSolid( SOLID_VPHYSICS )

	self.PhysObj = self:GetPhysicsObject()
	
	if ( self.PhysObj:IsValid() ) then
	
		self.PhysObj:Wake()
		self.PhysObj:SetMass(10000)
		
	end

	self:StartMotionController()

end

local function CreateDamageTimer( ent, k  )

	timer.Create( ent:EntIndex().."_timer_"..k, 0.5, 120, 
		function() 
			
			if( IsValid( ent ) ) then
					
				util.BlastDamage( ent, ent, ent:GetPos(),32, math.random(2,3) )
			
			end
			
		end )
								
end

function Meta:CivAir_DefaultDamage(dmginfo)

	if ( self.Destroyed ) then
		
		
		
		-- self:Remove()
		
		return

	end
	local dmg = dmginfo:GetDamage()
	local attacker = dmginfo:GetAttacker()
	
	
	if( self.EngineBones && dmginfo:GetDamageType() != DMG_CRUSH ) then 
		local dist = 999999999
		local enginebone = 0
		local gunners = 0 
		
		for k,v in ipairs( self.EngineBones ) do 
			local bp, ba = self:GetBonePosition( v.Index )
			local tdist = dmginfo:GetDamagePosition():DistToSqr( bp )
			if( GetConVarNumber("developer")>0 ) then
				debugoverlay.Sphere( bp, math.sqrt( self.EngineBoneRadius or 320 ), 155.1, Color( 55,55,255,255 ), true  )
			end
			if( tdist < ( self.EngineBoneRadius or 320 ) && !v.Destroyed ) then
				v.Health = v.Health - dmg
				
				if( v.EngineBone ) then
					
					enginebone = enginebone + 1 
					self:SetNetworkedInt("EngineHealth_"..enginebone, math.floor( v.Health ) )
					
				elseif( v.TurretBone ) then
					
					gunners = gunners + 1 
					self:SetNetworkedInt("TurretHealth_"..gunners, math.floor( v.Health ) )
					
				end
				-- print( v.Health )
				if( v.Health <= 0 ) then
				
				
					if( v.EngineBone ) then
					
					
						v.Destroyed = true
						
						if( IsValid( self.Propeller ) && !self.Propellers ) then
							-- SendDamageVector( v.Pos, self, 133700  ) -- Engine smoke
							
							ParticleEffectAttach( "microplane_jet_flame", PATTACH_POINT_FOLLOW, self, v.Index )
								
							CreateDamageTimer( self, k )
							
							timer.Simple( math.random(3,10), function()
								
								if( IsValid( v ) && IsValid( self ) ) then
								
									self.PropellerAxis = NULL
								
								end
							
							end )
							
						end
						
					else
						
						if( v.TurretBone && !v.Destroyed ) then
							
							v.Destroyed = true
							local fx = EffectData()
							fx:SetOrigin( v.Pos )
							-- self:DrawLaserTracer(self:GetPos() + Vector(0,0,512), pbpos )
							fx:SetNormal( self:GetUp() )
							fx:SetEntity( self )
							fx:SetScale( 1 )
							util.Effect( "micro_he_blood", fx )
							
						else
						
							if( !v.FuelIgnited && !v.Destroyed  ) then
							
								SendDamageVector( v.Pos, self, 133701  ) -- fuel
								-- ParticleEffectAttach( ) -- 
								-- ParticleEffectAttach( "microplane_fuel_leak", PATTACH_POINT, self, v.Index )
								
								v.FuelIgnited = true
								
							else
							
								if( !v.Destroyed ) then

									-- ParticleEffectAttach( "microplane_fuel_leak_fire", PATTACH_POINT, self, v.Index )
								
									SendDamageVector( v.Pos, self, 133700  ) -- fuel
									v.Destroyed = true
									CreateDamageTimer( self, k )
									
								end
				
							end
						
						end
						
					end
					
				end
				if( !self.NoPropeller ) then
				
					local rnd = "WT/Misc/Engine_destroyed"..math.random(1,3)..".wav"
					self:EmitSound( rnd, 511, 100 )
					
				end
				
			end
		end
	end
	if( self.PilotBonePosition && !self.PilotDed ) then
	
		local pbpos = self:LocalToWorld( self.PilotBonePosition )
		local tdist = dmginfo:GetDamagePosition():DistToSqr( pbpos )
		if( tdist < 27 ) then	
			
			-- print( tdist )
			-- print("damn thats close")
			if( dmg > 10 ) then
				-- print("hit pilot bye bye")
				local fx = EffectData()
				fx:SetOrigin( pbpos + Vector(0,0,4) )
				-- self:DrawLaserTracer(self:GetPos() + Vector(0,0,512), pbpos )
				fx:SetNormal( self:GetUp() )
				fx:SetEntity( self )
				fx:SetScale( 1 )
				util.Effect( "micro_he_blood", fx )
				
				self:GetPhysicsObject():AddAngleVelocity( Vector( math.Clamp( self:GetAngles().r, -35, 35 )*10, 0,0  ) )
		
				self.PilotDed = true
				
				if( IsValid( self.Pilot ) ) then
				
					self.Pilot:SetNetworkedBool("PilotKilled", true )
				
				end
				 
				if( attacker:IsPlayer() ) then
					
					attacker:PrintMessage( HUD_PRINTCENTER, "BOOM HEAD SHOT !")
				
				end 
				
				return
				
			end
		
		end


	end
	
	self:TakePhysicsDamage(dmginfo)
	
	self.HealthVal = self.HealthVal - dmginfo:GetDamage()
	self:SetNetworkedInt( "health", self.HealthVal )
	
	self.LastAttacker = dmginfo:GetAttacker()
	self.LastAttacked = CurTime()
	
	if( IsValid( self.Pilot ) ) then
		
		self.Pilot.LastShock = self.Pilot.LastShock or 0
		
		if( self.Pilot.LastShock + 0.5 <= CurTime() ) then
			
			self.Pilot.LastShock = CurTime() 
			self.Pilot:SetNetworkedInt("LastImpact", CurTime() )
			self.Pilot:SetNetworkedInt("LastDamage", math.floor( dmginfo:GetDamage() ) )
			
		
		end
		
	end
	
	if ( self.HealthVal < self.InitialHealth * 0.1 && !self.Burning ) then

		self.Burning = true
		
		if( self.PropellerPos ) then
			
			if( type( self.PropellerPos ) == "table" ) then
				
				-- for i=1,#self.PropellerPos do
					
					-- local f = ents.Create("env_fire_trail")
					-- f:SetPos( self:LocalToWorld( self.PropellerPos[i] ) )
					-- f:SetParent( self )
					-- f:Spawn()
				
				-- end
				
			else
			
				local f = ents.Create("env_fire_trail")
				f:SetPos( self:LocalToWorld( self.PropellerPos ) )
				f:SetParent( self )
				f:Spawn()
		
			end
			
			self:Ignite( 60, 60 )
			
		else
			
			if( !self.TinySmoke ) then
				
				for i=1,#self.FireTrailPos do
					
					for j=1,2 do

						local f = ents.Create("env_fire_trail")
						f:SetPos( self:LocalToWorld( self.FireTrailPos[i] ) + Vector( math.random(-16,16), math.random(-16,16), 0 ) )
						f:SetParent( self )
						f:Spawn()
						
					end
					
				end
				
			end
			
		end
		
		
	end
	
	if ( self.HealthVal <= 0 ) then
		
		self:SetPhysDamping( 1.0,0 )
		self.Destroyed = true
		
		constraint.RemoveAll( self )
		constraint.RemoveAll( self.Tail )
		constraint.RemoveAll( self.Wings[1] )
		constraint.RemoveAll( self.Wings[2] )
		
		if( self.EngineMux ) then
			
			for i=1,#self.EngineMux do
			
				self.EngineMux[i]:Stop()
				
			end
			
		end
	
		self:GetPhysicsObject():AddAngleVelocity( Vector( 0,0, math.random(-1,1)  * 100 ) )
		
		self.IsFlying = false
		self.Speed = 0
		self.CurrentVelocity = 0
		
		-- self.Destroyed = true
		self.PhysObj:EnableGravity(true)
		self.PhysObj:EnableDrag(true)
		-- self:SetPhysDamping( 0,0 )
		-- self.PhysObj:SetMass( 2000 )
		self:Ignite( 60,100 )
		
	end
	
end

function Meta:Micro_DefaultPrimaryAttack()
	
	if ( !IsValid( self.Pilot ) ) then return end
	if( self.PhysicalAmmo ) then
		
		self:Micro_FireCannons()
	
	else
		
		if( self.BurstSize ) then
			
			for i=1,self.BurstSize do
				
				
				-- self.PrimaryDelay = 1.0 / self.RoundsPerSecond * self.BurstSize
				
				timer.Simple( ( self.BurstDuration or 1.0 ) / self.RoundsPerSecond * i, function()
					
					if( IsValid( self ) ) then
						
						self:Jet_FireMultiBarrel()
						
					end
					
				end )
				
				
			end
		
		
		else
		
			self:Jet_FireMultiBarrel()
			
		end
	
	end
	
	if( !self.ContigiousFiringLoop ) then
	
		self.Miniguns[math.random(1,#self.Miniguns)]:EmitSound( self.MinigunSound, 510, math.random( 120, 130 ) )
		
	end
	-- print(self.LastPrimaryAttack)
	
	if( self.PrimaryCooldown && self.PrimaryCooldown >= 1 ) then
	
		self:SetNWFloat("LastPrimaryAttack", CurTime() )
	
	end
	
	self.LastPrimaryAttack = CurTime()
	
end


function mod(a, b)
return a - math.floor( a / b ) 
end
function Meta:CivAir_DefaultInit()
	
	self.ValidSeats = { { self, "use" } }
	
	self.ToggleGear = true
	self.FlareCooldown = 15
	self.FlareCount = 8
	self.MaxFlares = 8
	self.CrosshairOffset = 0
		--// Scale health for micros 
	-- if( self.ClimbPunishmentMultiplier && !self.Nerfed ) then
		
		-- self.InitialHealth = self.InitialHealth / 10
		-- self.HealthVal = self.InitialHealth
		-- self.MinDamage = self.MinDamage / 2
		-- self.MaxDamage = self.MaxDamage / 2
		-- if( self.Radius ) then
			
			-- self.Radius = self.Radius / 2
			
		-- end
		
		
		-- self.Nerfed = true
		
	-- end

	self.HealthVal = self.InitialHealth
	
	self:SetNetworkedInt( "health",self.HealthVal)
	self:SetNetworkedInt( "HudOffset", self.CrosshairOffset )
	self:SetNetworkedInt( "MaxHealth",self.InitialHealth)
	self:SetNetworkedInt( "MaxSpeed",self.MaxVelocity)
	
	self.LastAutoPSwap = CurTime()
	
	self.MaxPropellerVal = 1600
	self.PropellerMult = self.MaxPropellerVal / 2000

	
	if( self.ExtraSeats ) then
	
		self:HelicopterCreateGunnerSeats( self.ExtraSeats )
		for i=1,#self.GunnerSeats do
			
			self.GunnerSeats[i]:SetNoDraw( true )
			self.GunnerSeats[i]:DrawShadow( false )
			
			
		end
		
	end
	
	self.EquipmentNames = {}
		
	-- if( self.VisualModels ) then
	
		-- local gun = ents.Create("prop_physics_override")
		-- gun:SetPos(self:LocalToWorld(self.VisualModels.Cannon.Pos))
		-- gun:SetAngles(self:GetAngles()+self.VisualModels.Cannon.Ang)
		-- gun:GetPhysicsObject():SetMass( 1 ) 
		-- gun:SetParent(self)
		-- gun:SetMaterial(self.VisualModels.Cannon.Mat)
		-- gun:SetColor(self.VisualModels.Cannon.Col)
		-- gun:SetModel(self.VisualModels.Cannon.Mdl)
		-- gun:Spawn()
		
	-- end
	
	if( self.LanternPos ) then
		
		self.Lanterns = {}
		
		for i=1,#self.LanternPos do
		
			self.Lanterns[i] = ents.Create( "env_sprite" )
			self.Lanterns[i]:SetParent( self )	
			self.Lanterns[i]:SetPos( self:LocalToWorld( self.LanternPos[i].Pos ) ) -----143.9 -38.4 -82
			self.Lanterns[i]:SetAngles( self:GetAngles() )
			self.Lanterns[i]:SetKeyValue( "spawnflags", 1 )
			self.Lanterns[i]:SetKeyValue( "renderfx", 0 )
			self.Lanterns[i]:SetKeyValue( "scale", 0.38 )
			self.Lanterns[i]:SetKeyValue( "rendermode", 9 )
			self.Lanterns[i]:SetKeyValue( "HDRColorScale", .75 )
			self.Lanterns[i]:SetKeyValue( "GlowProxySize", 2 )
			self.Lanterns[i]:SetKeyValue( "model", self.LanternPos[i].Mat )
			self.Lanterns[i]:SetKeyValue( "framerate", "10.0" )
			self.Lanterns[i]:SetKeyValue( "rendercolor", " 255 0 0" )
			self.Lanterns[i]:SetKeyValue( "renderamt", 255 )
			self.Lanterns[i]:Spawn()
		
		end
		
	end
	
	self.Trails = {}
	
	self.Miniguns = {}
	
	for i=1,#self.MinigunPos do
		
		self.Miniguns[i] = ents.Create("prop_physics_override")
		self.Miniguns[i]:SetPos( self:LocalToWorld( self.MinigunPos[i] ) )
		self.Miniguns[i]:SetModel( self.MachineGunModel )
		self.Miniguns[i]:SetAngles( self:GetAngles() )
		
		if( GetConVarNumber("developer",0)>0 ) then
		
		else
		
			self.Miniguns[i]:SetRenderMode( RENDERMODE_TRANSALPHA )
			self.Miniguns[i]:SetColor( Color( 0,0,0,0 ) )
			self.Miniguns[i]:DrawShadow( false )
			
			-- self.Miniguns[i]:SetNoDraw( true )
			
		end
		
		self.Miniguns[i]:SetParent( self )
		self.Miniguns[i]:SetSolid( SOLID_NONE )
		self.Miniguns[i]:Spawn()
		self.Miniguns[i].LastAttack = CurTime()
		
	end
	
	self.MinigunIndex = 1
	self.MinigunMaxIndex = #self.Miniguns
		
	
	
	--  Sonic Boom variables
	local fxsound = { "ambient/levels/canals/dam_water_loop2.wav", "LockOn/SonicBoom.mp3", "LockOn/Supersonic.mp3" }
	self.PCfx = 0
	self.FXMux = {}
	
	for i=1, #fxsound do
	
		self.FXMux[i] = CreateSound( self, fxsound[i] )
		
	end
	
	self:SetUseType( SIMPLE_USE )
	self.IsFlying = false
	self.Pilot = NULL
	self.BoostValue = 0
	
	local rnd = 1
	if( type( self.PropellerPos ) == "table" ) then
		
		rnd = math.random(1,#self.PropellerPos)
		self.Propellers = {}
		for k,v in pairs( self.PropellerPos ) do
			
			self.Propellers[k] = ents.Create("plane_part")
			self.Propellers[k]:SetPos( self:LocalToWorld( self.PropellerPos[k] ) )
			self.Propellers[k]:SetModel( self.PropellerModels[k] )
			self.Propellers[k]:SetAngles( self:GetAngles() )
			self.Propellers[k]:SetOwner( self )
			self.Propellers[k]:Spawn()

			self.Propellers[k].HealthVal = 50
			self.Propellers[k].InitialHealth = 50
			self.Propellers[k].IsDumbWheel = true
			self.Propellers[k].IsPropeller = true
			self.Propellers[k]:GetPhysicsObject():SetMass( self.PropMass or 10 )
			
			if( self.HideProp ) then
				
				self.Propellers[k]:SetRenderMode( RENDERMODE_TRANSALPHA )
				self.Propellers[k]:SetColor( Color( 0,0,0,0 ) )
				self.Propellers[k]:SetNoDraw( true )
				
			end 
			
			-- timer.Simple(1,function() if( IsValid(  self ) && IsValid(  self.Propellers[k] ) ) then self.Propellers[k]:SetNetworkedBool("IsPropeller",true) end end )
			
			self.Propellers[k].EngineMux = {}
			
			for i=1, #self.EngineSounds do
		
				self.Propellers[k].EngineMux[i] = CreateSound( self, self.EngineSounds[i] )
			
			end
			
			self:DeleteOnRemove( self.Propellers[k] )
			
		end
		
		self.Propeller = self.Propellers[rnd]
		
	else
	
		--  Sound
		self.EngineMux = {}
		
		for i=1, #self.EngineSounds do
		
			self.EngineMux[i] = CreateSound( self, self.EngineSounds[i] )
			
		end
		
		if( self.PropellerPos ) then
		
			self.Propeller = ents.Create("plane_part")
			self.Propeller:SetPos( self:LocalToWorld( self.PropellerPos ) )
			self.Propeller:SetModel( self.PropellerModel )
			self.Propeller:SetAngles( self:GetAngles() )
			self.Propeller.IsDumbWheel = true 
			self.Propeller.InitialHealth = 30
			self.Propeller.HealthVal = 30 
			self.Propeller:Spawn()
			self.Propeller:SetOwner( self ) 
			timer.Simple(1,function() if( IsValid( self.Propeller ) ) then self.Propeller:SetNetworkedBool("IsPropeller",true) end end )
			

		end
		
	end
	
	-- 
	if( self.WheelPos ) then
	
		self.Wheels = {}
		self.WheelWelds = {}

		for i = 1, #self.WheelPos do
			
			self.Wheels[i] = ents.Create("prop_physics")
			self.Wheels[i]:SetPos( self:LocalToWorld( self.WheelPos[i] ) )
			self.Wheels[i]:SetModel( self.WheelModels[i] )
			self.Wheels[i]:SetAngles( self:GetAngles() )-- + Angle(90,0,0) )
			self.Wheels[i]:Spawn()
			self.Wheels[i]:GetPhysicsObject():SetMass( self.WheelMass or 15000 )
			self.Wheels[i]:GetPhysicsObject():SetDamping( self.Damping or 0, self.AngDamping or 0 )
			
			-- self.Wheels[i]:SetParent( self )
			-- 
	
		end

	end
	
	--  Misc
	self:SetModel( self.Model )	
	self:PhysicsInit( SOLID_VPHYSICS )
	self:SetMoveType( MOVETYPE_VPHYSICS )
	self:SetSolid( SOLID_VPHYSICS )
	
	if( self.Damping ) then
	
		self:GetPhysicsObject():SetDamping( self.Damping, self.AngDamping )
	
	end

	
	if( self.TailModel ) then
		
		self.Tail = ents.Create("plane_part")
		self.Tail:SetPos( self:LocalToWorld( self.TailPos ) )
		self.Tail:SetModel( self.TailModel )
		self.Tail:SetAngles( self:GetAngles() )
		self.Tail:SetOwner( self )
		if( self.MicroTurretSound ) then
			
			self.Tail.MicroTurretSound = self.MicroTurretSound
			
		end
		if( self.MicroTurretDelay ) then
			
			self.Tail.MicroTurretDelay = self.MicroTurretDelay
		
		end
		if( self.MicroTurretMuzzle ) then	
		
			self.Tail.MicroTurretMuzzle = self.MicroTurretMuzzle
			
		end
		
		-- print("TailWheel", self.TailWheel) 
		if( self.TailWheel ) then
			
			self.Tail.WheelModel = self.TailWheel
			self.Tail.Wingdex = 3 -- 3 for tail
			
		end
		
		if( self.TailWheelPositionOverride ) then
			
			self.Tail.TailWheelPositionOverride = self.TailWheelPositionOverride
			
		end
		
		self.Tail:Spawn()
		self.Tail.HealthVal = self.InitialHealth
		self.Tail.InitialHealth = self.InitialHealth
		self.TailWeld = constraint.Weld( self.Tail, self, 0,0, self.OverrideWeldStrenght or 185000,true)
		self:DeleteOnRemove( self.Tail )
		self.Tail:GetPhysicsObject():SetDamping( self.Damping, self.AngDamping )
		self.Tail:GetPhysicsObject():SetMass( self:GetPhysicsObject():GetMass() )
	
		-- print( self.Tail:GetSolid() )
		
	end
	
-- ENT.BombdoorModels = { "models/starchick971/neuroplanes/american/fa-22 raptor_missilebaydoor_l.mdl",
						-- "models/starchick971/neuroplanes/american/fa-22 raptor_missilebaydoor_r.mdl",
						-- "models/starchick971/neuroplanes/american/fa-22 raptor_bombbaydoor_l.mdl",
						-- "models/starchick971/neuroplanes/american/fa-22 raptor_bombbaydoor_r.mdl"
						-- }
-- ENT.BombdoorPositions = {Vector(0,0,0),
						 -- Vector(0,0,0),
						 -- Vector(0,0,0),
						 -- Vector(0,0,0)
						-- }
-- ENT.BombdoorAngles = { Angle( 0,0,0 ),
						-- Angle( 0,0,0 ),
						-- Angle( 0,0,0 ),
						-- Angle( 0,0,0 )}
	
	if( self.BombdoorModels ) then 
		
		self.BombDoors = {}
		for i=1,#self.BombdoorModels do 
			
			self.BombDoors[i] = ents.Create("prop_physics_override")
			self.BombDoors[i]:SetPos( self:LocalToWorld( self.BombdoorPositions[i] ) )
			self.BombDoors[i]:SetAngles( self:GetAngles() + self.BombdoorAngles[i] )
			self.BombDoors[i]:SetModel( self.BombdoorModels[i] )
			self.BombDoors[i]:SetSolid( SOLID_NONE )
			self.BombDoors[i]:SetParent( self )
			self.BombDoors[i]:Spawn()
		
		end 
	
	end 
	
	-- used by death check, frames to burn before exploding.
	self.ImpactTime = math.random( 45,80 )
	
	if( self.WingModels ) then
		
		self.Wings = {}
		
		for i=1,#self.WingModels do
			
			self.Wings[i] = ents.Create("plane_part")
			self.Wings[i]:SetPos( self:LocalToWorld( self.WingPositions[i] ) ) 
			self.Wings[i]:SetModel( self.WingModels[i] )
			self.Wings[i]:SetAngles( self:GetAngles() )
			self.Wings[i]:SetOwner( self )
			self.Wings[i].Owner = self
			self.Wings[i].Wingdex = i
			
			if( self.WingWheelModels && i <= #self.WingWheelModels ) then
				
				self.Wings[i].WheelModel = self.WingWheelModels[i]
				
			end
			
			self.Wings[i]:Spawn()
		
			self.Wings[i].HealthVal = self.InitialHealth/3
			self.Wings[i].InitialHealth = self.InitialHealth/3
			self.Wings[i]:GetPhysicsObject():SetMass( self:GetPhysicsObject():GetMass()  )
			self.Wings[i]:GetPhysicsObject():SetDamping( self.Damping, self.AngDamping )
			self:DeleteOnRemove( self.Wings[i] )
			self.Wings[i].Weld = constraint.Weld( self.Wings[i], self, 0,0, self.OverrideWeldStrenght or 65000,true)
			
		end
		
		
		timer.Simple( 0, 
		function()
			if( IsValid( self ) ) then
			
				local weld = constraint.Weld( self.Wings[1], self.Wings[2], 0,0,self.OverrideWeldStrenght or 5000,true)
				self.Wings[1].CrossWeld = weld
				self.Wings[2].CrossWeld = weld
				
				if( self.ForceWeldTailToWings ) then
				
					constraint.Weld( self.Tail, self.Wings[1], 0,0,self.OverrideWeldStrenght or 35000,true)
					constraint.Weld( self.Tail, self.Wings[2], 0,0,self.OverrideWeldStrenght or 35000,true)
				
				end
				
			end
			
		end )
	end
		
	if(  type( self.PropellerPos )  == "table" ) then
		
		for i=1,#self.Propellers do 
		
			constraint.NoCollide( self, self.Propellers[i], 0, 0 )	
			
			if( self.PropellerAttachedToWings ) then
				
				if( i <= #self.Propellers/2 ) then
				
					self.Propellers[i].Axis = constraint.Axis( self.Propellers[i], self.Wings[1], 0, 0, Vector(1,0,0) , self.PropellerPos[i], 10000, 0, 1, 0 )
					
				else
					
					self.Propellers[i].Axis = constraint.Axis( self.Propellers[i], self.Wings[2], 0, 0, Vector(1,0,0) , self.PropellerPos[i], 10000, 0, 1, 0 )
				
				end
			
			else
			
				self.Propellers[i].Axis = constraint.Axis( self.Propellers[i], self, 0, 0, Vector(1,0,0) , self.PropellerPos[i], 10000, 0, 1, 0 )
			
			end
			
		end
		
		self.PropellerAxis = self.Propellers[rnd].Axis
		
	else
	
		constraint.NoCollide( self, self.Propeller, 0, 0 )	
		self.PropellerAxis = constraint.Axis( self.Propeller, self, 0, 0, Vector(1,0,0) , self.PropellerPos, self.OverrideWeldStrenght or 12000, 0, 1, 0 )
	
	end
	
	-- animations
	if( self.ControlSurfaces ) then

		self.Ailerons = {}
		self.Flaps = {}
		
		if( self.ControlSurfaces.Ailerons ) then
		
			for i=1,#self.ControlSurfaces.Ailerons do
				
				self.Ailerons[i] = ents.Create("plane_part")
				self.Ailerons[i]:SetPos( self:LocalToWorld( self.ControlSurfaces.Ailerons[i].Pos ) )
				self.Ailerons[i]:SetAngles( self:GetAngles() + self.ControlSurfaces.Ailerons[i].Ang )
				self.Ailerons[i]:SetModel( self.ControlSurfaces.Ailerons[i].Mdl )
				self.Ailerons[i]:SetMoveType( MOVETYPE_NONE )
				self.Ailerons[i].HealthVal = 20
				self.Ailerons[i].InitialHealth = 20
				self.Ailerons[i].IsDumbWheel = true
				self.Ailerons[i]:SetOwner( self )
				
				if( i == 2 || i == 4 || i == 6 ) then -- fucking biplanes.
				
					self.Ailerons[i]:SetParent( self.Wings[2] )
					
				else
				
					self.Ailerons[i]:SetParent( self.Wings[1] )
					
				end
				
				self.Ailerons[i]:Spawn()
				
			end
			
		end
		
		if( self.ControlSurfaces.Flaps ) then
		
			for i=1,#self.ControlSurfaces.Flaps do
				
				self.Flaps[i] = ents.Create("plane_part")
				self.Flaps[i]:SetPos( self:LocalToWorld( self.ControlSurfaces.Flaps[i].Pos ) )
				self.Flaps[i]:SetAngles( self:GetAngles() + self.ControlSurfaces.Flaps[i].Ang )
				self.Flaps[i]:SetModel( self.ControlSurfaces.Flaps[i].Mdl )
				self.Flaps[i]:SetMoveType( MOVETYPE_NONE )
				if( i == 1 || i == 3 || i == 5 ) then
				
					self.Flaps[i]:SetParent( self.Wings[1] )
					
				else
				
					self.Flaps[i]:SetParent( self.Wings[2] )
					
				end
				
				self.Flaps[i]:SetOwner( self )
				self.Flaps[i].HealthVal = 20
				self.Flaps[i].InitialHealth = 20
				self.Flaps[i].IsDumbWheel = true 
				self.Flaps[i]:Spawn()
		
			end
			
		end
		-- Tail parts
		self.Elevators = {}
		self.Elevator = NULL 
		if( type( self.ControlSurfaces.Elevator ) == "table" && #self.ControlSurfaces.Elevator > 1 ) then 
			
			for i =1,#self.ControlSurfaces.Elevator do 
				-- print( "Spawning Elevator", i ) 
				local v = self.ControlSurfaces.Elevator[i]
			
				self.Elevators[i] = ents.Create("plane_part")
				self.Elevators[i]:SetPos( self.Tail:LocalToWorld( v.Pos ) )
				self.Elevators[i]:SetAngles( self:GetAngles() + v.Ang )
				self.Elevators[i]:SetModel( v.Mdl )
				self.Elevators[i]:SetMoveType( MOVETYPE_NONE )
				if( i == 1 ) then 
				
					self.Elevators[i]:SetParent( self.Tail )
				
				else 
					
					-- timer.Simple( 0, function() 
					if( IsValid( self.Elevators[i] ) && IsValid( self.Elevators[1] ) ) then 
						
						self.Elevators[i]:SetParent( self.Elevators[1] )
					
					end 
						
					-- end ) 
					
				
				end 
			
				self.Elevators[i]:SetOwner( self )
				self.Elevators[i].HealthVal = 25
				self.Elevators[i].InitialHealth = 25
				self.Elevators[i].IsDumbWheel = true 
				self.Elevators[i]:Spawn()
				
			end
			self.Elevator = self.Elevators[1]
			-- print( self.Elevators[1] ) 
				
			if( self.MoveExhaustWithElevator ) then 
					
				timer.Simple( 0, function() 
				
					if( IsValid ( self.Elevator ) ) then
					
				
						self:SetNWEntity("VectorThrustObject", self.Elevator )
					
					end 
					
				end )
				
			end 
			
		else 
		
			self.Elevator = ents.Create("plane_part")
			self.Elevator:SetPos( self.Tail:LocalToWorld( self.ControlSurfaces.Elevator.Pos ) )
			self.Elevator:SetAngles( self:GetAngles() + self.ControlSurfaces.Elevator.Ang )
			self.Elevator:SetModel( self.ControlSurfaces.Elevator.Mdl )
			self.Elevator:SetMoveType( MOVETYPE_NONE )
			self.Elevator:SetParent( self.Tail )
			self.Elevator:SetOwner( self )
			self.Elevator.HealthVal = 25
			self.Elevator.InitialHealth = 25
			self.Elevator.IsDumbWheel = true 
			self.Elevator:Spawn()
			
		end 
		
		if(   #self.ControlSurfaces.Rudder  > 1 ) then
			
			self.Rudders = {}
				
			for i=1,#self.ControlSurfaces.Rudder do 
				
				self.Rudders[i] = ents.Create("plane_part")
				self.Rudders[i]:SetPos( self.Tail:LocalToWorld( self.ControlSurfaces.Rudder[i].Pos ) )
				self.Rudders[i]:SetAngles( self:GetAngles() + self.ControlSurfaces.Rudder[i].Ang )
				self.Rudders[i]:SetModel( self.ControlSurfaces.Rudder[i].Mdl )
				self.Rudders[i]:SetMoveType( MOVETYPE_NONE )
				self.Rudders[i]:SetParent( self.Tail )
				self.Rudders[i]:SetOwner( self )
				self.Rudders[i].HealthVal = 25
				self.Rudders[i].InitialHealth = 25
				self.Rudders[i].IsDumbWheel = true 
				self.Rudders[i]:Spawn()
				
			end
			
			self.Rudder = self.Rudders[1]
			
			
		else
			
			
			self.Rudder = ents.Create("plane_part")
			self.Rudder:SetPos( self.Tail:LocalToWorld( self.ControlSurfaces.Rudder.Pos ) )
			self.Rudder:SetAngles( self:GetAngles() + self.ControlSurfaces.Rudder.Ang )
			self.Rudder:SetModel( self.ControlSurfaces.Rudder.Mdl )
			self.Rudder:SetMoveType( MOVETYPE_NONE )
			self.Rudder:SetParent( self.Tail )
			self.Rudder:SetOwner( self )
			self.Rudder.HealthVal = 25
			self.Rudder.InitialHealth = 25
			self.Rudder.IsDumbWheel = true 
			self.Rudder:Spawn()
			
		end
		
	end

	if( self.AutoCannons ) then
		
		self.ACannons = {}
		
		for k,v in pairs( self.AutoCannons ) do
				
			self.ACannons[k] = ents.Create( "prop_physics" )
			self.ACannons[k]:SetPos( self:LocalToWorld( v.Pos ) )
			self.ACannons[k]:SetAngles( self:GetAngles() + v.Ang )
			self.ACannons[k]:SetModel( v.Mdl )
			self.ACannons[k]:SetMoveType( MOVETYPE_NONE )
			self.ACannons[k]:SetParent( self )
			self.ACannons[k]:Spawn()
		
		
		end
	
	end
	
	if( self.Wheels ) then
		
		for i= 1, #self.Wheels do
				
			if( self.Wheels[i]:GetPhysicsObject() != nil ) then
				
				self.Wheels[i]:GetPhysicsObject():SetMass( self.WheelMass or 2500 )
			
			end
			
			constraint.NoCollide( self, self.Wheels[i], 0, 0 )	
			
			if( self.AxledWheels ) then
			
				self.WheelWelds[i] = constraint.Axis( self.Wheels[i], self, 0, 0, Vector(0,1,0) , self.WheelPos[i], 45000, 0, 1, 0 )
			
			else
			
				self.WheelWelds[i] = constraint.Weld( self.Wheels[i], self, 0,50,25000,true)
			
			end
			
		end
		
	end
	
	if( type( self.PropellerPos ) == "table" ) then
	
	else
	
		if( IsValid( self.Propeller ) ) then
		
			self.PropellerPhys = self.Propeller:GetPhysicsObject()	
			
			if ( self.PropellerPhys:IsValid() ) then
		
				self.PropellerPhys:Wake()
				self.PropellerPhys:SetMass( 2000 )
				self.PropellerPhys:EnableGravity( true )
				self.PropellerPhys:EnableCollisions( true )
				
			end
			
		end
		
	end
	
	

	
	self.PhysObj = self:GetPhysicsObject()
	
	if ( self.PhysObj:IsValid() ) then
	
		self.PhysObj:Wake()
		self.PhysObj:SetMass( 12000 )
		
	end
	
	if( self.Armament ) then
		-- Armamanet
		local i = 0
		local c = 0
		self.FireMode = 1
		self.EquipmentNames = {}
		self.RocketVisuals = {}
		self.LastFireModeChange	= CurTime()
		
		for k,v in pairs( self.Armament ) do
			
			i = i + 1
			local class = "prop_physics_override"
			if( self.ArmamentDamageSystem ) then 
				
				class = "plane_part" 
				
			end 
			
			self.RocketVisuals[i] = ents.Create( class )
			self.RocketVisuals[i]:SetModel( v.Mdl )
			self.RocketVisuals[i]:SetPos( self:LocalToWorld( v.Pos ) )
			self.RocketVisuals[i]:SetAngles( self:GetAngles() + v.Ang )
			self.RocketVisuals[i].HealthVal = 50 
			
			-- if( #self.Armament > 1 ) then
			if( !self.ArmamentDamageSystem ) then
				
				if( self.ArmamentAttachedToWings ) then
		
					if( v.Pos.y > 0 ) then 

						self.RocketVisuals[i]:SetParent( self.Wings[1] )
					
					else
						
						self.RocketVisuals[i]:SetParent( self.Wings[2] )
				
					end 
				
				else
				
					self.RocketVisuals[i]:SetParent( self )
					
				end
				
			end 
			self.RocketVisuals[i].Type = v.Type
			self.RocketVisuals[i].PrintName = v.PrintName
			self.RocketVisuals[i].Cooldown = v.Cooldown
			self.RocketVisuals[i].isFirst = v.isFirst
			self.RocketVisuals[i].Identity = i
			self.RocketVisuals[i].Class = v.Class
			self.RocketVisuals[i].Owner = self
			self.RocketVisuals[i]:Spawn()
			self.RocketVisuals[i]:Activate()
			-- self.RocketVisuals[i]:GetPhysicsObject():Wake()
			self.RocketVisuals[i].LastAttack = CurTime()


			if( !self.ArmamentDamageSystem ) then 
				
				self.RocketVisuals[i]:SetSolid( SOLID_NONE )
				
			end 
			
			-- end
			
			if ( v.Damage && v.Radius ) then
				
				self.RocketVisuals[i].Damage = v.Damage
				self.RocketVisuals[i].Radius = v.Radius
			
			end
			
			if( v.Color ) then
				
				self.RocketVisuals[i]:SetRenderMode( RENDERMODE_TRANSALPHA )
				self.RocketVisuals[i]:SetColor( v.Color )
				self.RocketVisuals[i].Color = v.Color
				if( v.Color == Color( 0,0,0,0 ) ) then
				
					self.RocketVisuals[i]:DrawShadow( false )
					
				end
			end
		
			if( v.LaunchSound ) then
				
				self.RocketVisuals[i].LaunchSound = v.LaunchSound
				
			end
			
			if ( v.isFirst == true || v.isFirst == nil ) then
			
				if ( v.Type != "Effect" ) then
					
					c = c + 1
					self.EquipmentNames[c] = {}
					self.EquipmentNames[c].Identity = i
					self.EquipmentNames[c].Name = v.PrintName
					
				end
				
			end
			
			if( self.ArmamentDamageSystem ) then
				local pos = v.Pos 
				self.RocketVisuals[i].IsArmedWeapon = true 
					
				-- timer.Simple( 1.0, function() 
					-- print("welding")
					self.RocketVisuals[i]:GetPhysicsObject():Wake()
					self.RocketVisuals[i]:PhysicsInit( SOLID_VPHYSICS )
					self.RocketVisuals[i]:SetSolid( SOLID_VPHYSICS )
					self.RocketVisuals[i]:SetMoveType( MOVETYPE_VPHYSICS )
					
					if( pos.y > 0 ) then 

						self.RocketVisuals[i].Weld = constraint.Weld( self.RocketVisuals[i], self.Wings[1], 0, 0, 11250, true, false )
						self.Wings[1]:DeleteOnRemove( self.RocketVisuals[i] )
						
					else
						
						self.RocketVisuals[i].Weld = constraint.Weld( self.RocketVisuals[i], self.Wings[2] , 0, 0, 11250, true, false )
						self.Wings[2]:DeleteOnRemove( self.RocketVisuals[i] )
						
					end 
				
				-- end )
						
						
			end 
		end

		self.NumRockets = #self.EquipmentNames
		
	end

	
	self:StartMotionController()
	
	if( self.Damping && self.AngDamping ) then
		
		self.Speed = self.MaxVelocity / 2
		
		
	else
		
		self.Speed = 0
	
	end
	
	if( !self.LastPrimaryAttack ) then
	
		self.LastPrimaryAttack = 0
	
	end
	
	if( self.ContigiousFiringLoop ) then
		
		self.PrimarySound = CreateSound( self.Miniguns[1], self.PrimaryShootSound )
		-- self.PrimarySound:SetSoundLevel( 511 ) 
		-- self.PrimarySound:ChangeVolume( 1.0, 0 )
	end
	if( self._2ndContigiousFiringLoop ) then
		
		self.SecondarySound = CreateSound( self.Miniguns[1], self.SecondaryShootSound )
		-- self.PrimarySound:SetSoundLevel( 511 ) 
		-- self.PrimarySound:ChangeVolume( 1.0, 0 )
	end
	
	if( self.HasPilotSeat ) then
		
		self.PilotSeat = ents.Create( "prop_vehicle_prisoner_pod" )
		self.PilotSeat:SetPos( self:GetPos() )
		self.PilotSeat:SetModel( "models/nova/jeep_seat.mdl" )
		self.PilotSeat:SetKeyValue( "LimitView", "0" )
		self.PilotSeat:SetKeyValue( "vehiclescript", "scripts/vehicles/prisoner_pod.txt" )
		self.PilotSeat.HandleAnimation = function( v, p ) return p:SelectWeightedSequence( ACT_DRIVE_AIRBOAT ) end
		self.PilotSeat:SetAngles( self:GetAngles() + Angle(0,-90,0 ))
		self.PilotSeat:SetParent( self )
		self.PilotSeat:SetColor( Color( 0,0,0,0 ) )
		self.PilotSeat:DrawShadow(  false )
		self.PilotSeat:SetRenderMode( RENDERMODE_TRANSALPHA )
		self.PilotSeat:SetSolid( SOLID_NONE )
		self.PilotSeat:Spawn()
	
	end 
	self.StallWarning = CreateSound( self, "air/airspeed_warning.wav")
	self.FireWarning = CreateSound( self, "air/warning2.wav")
	
	-- init is a heavy operation so we move the bone table initialization to the next frame 
	timer.Simple( 0, function() 
		
		if( IsValid( self ) ) then	
			
			self:Micro_SetupBones()
			
		end
	
	end )
	
	
end

function Meta:Micro_SetupBones()

	local bonecount = self:GetBoneCount()
	local engines = 0
	local gunners = 0 
	
	if( bonecount > 1 ) then -- stupid root bone
		
		for i=0,bonecount-1 do
			
			local name = string.lower(self:GetBoneName(i))
			local bp,ba = self:GetBonePosition(i)

			-- print( name, " - ", self:GetModel() )
			if( string.find( name, "engine" ) != nil) then
			
				if( !self.EngineBones ) then self.EngineBones = {} end
				engines = engines + 1
				self:SetNetworkedInt("EngineHealth_"..engines, self.InitialHealth / 4 )
				self:SetNetworkedInt("EngineMaxHealth_"..engines, self.InitialHealth / 4 )
				
				table.insert( self.EngineBones, 
					{ 
							Index = i, 
							Health = self.InitialHealth / 4, 
							Pos = self:WorldToLocal( bp ), 
							Ang = ba, 
							Destroyed = false,
							EngineBone = true
							
						} )
					
			end
				
			if( string.find( name, "fueltank" ) != nil ) then
				
				if( !self.EngineBones ) then self.EngineBones = {} end
		
				table.insert( self.EngineBones, 
					{ 
						Index = i, 
						Health = self.HealthVal / 4, 
						Pos = self:WorldToLocal( bp ), 
						Ang = ba, 
						Destroyed = false, 
						FuelIgnited = false 
						
					} )
		
				
			end
			
			if( string.find( name, "turret" ) != nil ) then
				
				if( !self.EngineBones ) then self.EngineBones = {} end
				gunners = gunners + 1 
				
				bp,ba = self:GetBonePosition(i)
				-- ba:RotateAroundAxis( self:GetUp(), 90 )
				local gunObject = ents.Create("prop_physics")
				gunObject:SetModelScale( 0.1, 0.1 )
				gunObject:SetPos( bp )
				gunObject:SetAngles( ba )
				gunObject:SetParent( self )
				gunObject:SetRenderMode( RENDERMODE_TRANSALPHA )
				-- gunObject:SetColor( Color( 0,0,0,0 ) ) 
				gunObject:SetModel("models/weapons/w_pist_usp_silencer.mdl")
				gunObject:SetSolid( SOLID_NONE )
				gunObject:Spawn()
				gunObject:Activate()
				
			
				self:SetNetworkedInt("TurretHealth_"..gunners, math.floor( self.HealthVal / 8 ) )
				
				table.insert( self.EngineBones, 
					{ Index = i, 
					Health = self.HealthVal / 8, 
					Pos = self:WorldToLocal( bp ),
					Ang = ba, 
					Destroyed = false, 
					FuelIgnited = true,
					LastShot = 0,
					CoolDown = self.MicroTurretDelay or 3,
					ShootSound = self.MicroTurretSound or "WT/Guns/m4_singleshot.wav",
					GunEntity = gunObject,
					TurretBone = true } )
				
			end
			
			if( string.find( name, "pilot" ) != nil ) then
			
				self.PilotBonePosition = self:WorldToLocal( bp )
			
			end
			
		end
		if( self.EngineBones ) then
		
			for k,v in pairs( self.EngineBones ) do
				
				if( v.TurretBone ) then
					
					if( !self.TurretBones ) then self.TurretBones = {} end 
					
					table.insert( self.TurretBones, v )
				
				end
			
			end
			
		end 
		
	end
	
end

function Meta:CivAir_PhysCollide( data, physobj )
		
	
	if ( self.Speed > self.MaxVelocity * 0.1 && data.DeltaTime > 0.2 ) then  
	
		self:EmitSound( "LockOn/PlaneHit.mp3", 510, math.random( 100, 130 ) )
	
		if ( self:GetVelocity():Length() > self.MaxVelocity * 0.50 || (IsValid( self.Tail ) && !IsValid( self.TailWeld ) ) ) then
		
			self:DeathFX()
		
		end
		
	end
	
end
	
local sounds = {
"physics/wood/wood_box_break1.wav",
"ambient/materials/roust_crash1wav",
"ambient/materials/roust_crash2wav",
"physics/metal/metal_box_break1.wav",
"physics/metal/paintcan_impact_hard3.wav"}
	
local function CreateJunk( self )
		
		local junk = ents.Create("prop_physics")
		junk:SetPos( self:GetPos() )
		junk:SetModel( self:GetModel() )
		junk:SetAngles( self:GetAngles() )
		junk:Spawn()
		junk:Fire("kill","", math.random(10,30) )
		junk:SetColor( Color( 175,175,175,255 ) )
		junk:SetVelocity( self:GetVelocity() )
		
		ParticleEffectAttach( "fireplume_small", PATTACH_ABSORIGIN_FOLLOW, junk, 0 )
		
		junk:Ignite( 60,60 )

end 

function Meta:Micro_PhysCollide( data, physobj )
	
	-- if( self.Destroyed && self.BouncedOnce )
	
	if( self.LastStall && self.LastStall + 4 >= CurTime() ) then self.BouncedOnce = true end 
	
	if( self.Destroyed && !self.BouncedOnce ) then -- make sure we hit something before triggering the impact explosion
		
		self.BouncedOnce = true
		
		return
		
	end
	
	
	
	if( IsValid( data.HitEntity ) && data.HitEntity:GetClass() == "sent_mini_shell" ) then return end 
	
	
	if( (  data.Speed > 400 && !data.HitEntity:IsPlayer() )  || ( self.Destroyed && self.BouncedOnce && data.Speed > 50 ) || ( data.Speed > 300 && ( !IsValid( self.Propeller ) || !IsValid( self.Tail ) ) ) ) then 
		
		self:PlayWorldSound( "WT/Misc/bomb_explosion_"..math.random(1,6)..".wav" )
		
		ParticleEffect( "microplane_bomber_explosion", self:GetPos(), Angle( 0,0,0 ), nil )
		
		CreateJunk( self )
		self:EjectPilot()
		
		util.BlastDamage( self, IsValid( self.LastAttacker ) and self.LastAttacker or self, self:GetPos() + Vector( 0,0,50 ) , 256, 1500 )

		
		self:Remove()
	
		return 
	
	end
	

	if( data.DeltaTime > .25 ) then
	
		local crashsound = sounds[math.random(1,#sounds)]
		self:EmitSound( crashsound, 511, math.random(95,105) )
	
	end
		
		
		
	if ( self.CurVelocity > self.MaxVelocity * 0.1 && data.DeltaTime > 0.1 ) then  
		

		if ( self:GetVelocity():Length() > self.MaxVelocity * 0.3 || (IsValid( self.Tail ) && !IsValid( self.TailWeld ) ) ) then
			
			if( self.RippedByPhysForce ) then return end 
			
			self.Destroyed = true
			
			local oldvel = data.OurOldVelocity
			
			self.IsFlying = false
			
			self:SetPhysDamping( 0,0 )
		
			self:GetPhysicsObject():SetVelocity( oldvel )
			
			if( IsValid( self.Tail ) ) then
				
				self.Tail:EmitSound( "LockOn/PlaneHit.mp3", 511, math.random(90,110) ) 
	
			end  
		
			
			self:PlayWorldSound( "npc/combine_gunship/gunship_explode2.wav" )
			
			-- timer.Simple( 0, function()
				-- if(IsValid( self ) ) then
				
			if( math.random(1,2) == 1 && self:WaterLevel() == 0 ) then
			
				self:Ignite(60,60)
			
			end
			
			-- if( self.PropellerAttachedToWings ) then -- big plane
					
				ParticleEffect( "microplane_bomber_explosion", self:GetPos(), Angle( 0,0,0 ), nil )
				
				
			-- else
			
				-- ParticleEffect( "microplane_explosion", self:GetPos(), Angle( 0,0,0 ), nil )
			
			-- end 
		
			local inflictor = self
			if( IsValid( self.LastAttacker ) && self.LastAttacked + 10 >= CurTime() ) then
				
				inflictor = self.LastAttacker
			
			end
			local oldpilot = self.Pilot
			self:EjectPilot()
			-- skip to next frame
			timer.Simple( 0,function() 
				
					util.BlastDamage( self, inflictor or self, self:GetPos()+Vector(0,0,32), 500, 500 )
				
				end )
				-- end
				
			-- end )
	
			util.BlastDamage( self, IsValid( self.LastAttacker ) and self.LastAttacker or self, self:GetPos() + Vector( 0,0,50 ) , 256, 1500 )
			
			CreateJunk( self )
			
			self:Remove()
			
			return 
			-- self:Explode()
			-- self:DeathFX()
		
		end
		
	end
	
end

function Meta:CivAir_Think()
	
	if( !self.IsFlying ) then return end
	
	self:NextThink( CurTime() )
	self.Pitch = math.Clamp( math.floor( self.Speed / 15 + 50 ), 0, 165 )
	
	if( self.EngineMux ) then
	
		for i = 1,#self.EngineMux do
		
			self.EngineMux[i]:ChangePitch( self.Pitch, 1.0 )
			
		end
		
		if( !IsValid( self.Pilot ) ) then
			
			for i =1,#self.EngineMux do
			
				self.EngineMux[i]:FadeOut( 1, 1 )
			
			end
			
		end
	
	end
	
	
	
	
	if ( self.Destroyed ) then 
		
		local effectdata = EffectData()
		effectdata:SetOrigin( self:GetPos() + Vector( math.random(-15,15), math.random(-25,25), 0 ) )
		util.Effect( "immolate", effectdata )
		self.DeathTimer = self.DeathTimer + 1
		
		if ( self.DeathTimer > 32 ) then
		
			self:EjectPilot()
			self:DeathFX()
		
		end
		
		-- return
		
	end
	
	if ( self.IsFlying && IsValid( self.Pilot ) ) then
		
		if( self.Pilot:KeyDown( IN_RELOAD ) && self.LastAutoPSwap + 0.5 <= CurTime() ) then
			
			self.LastAutoPSwap = CurTime()
			self.AutoPilot = !self.AutoPilot
			
		end
		
		self.Pilot:SetPos( self:GetPos() + Vector( 0, 0, 200 ) )
		self:UpdateRadar()
		self:NeuroPlanes_CycleThroughJetKeyBinds()

	end

	return true
end


function Meta:CivAir_DefaultMovement( phys, deltatime )
local a = self:GetAngles()
	local stallang = ( ( a.p < -24 || a.r > 15 || a.r < -15 ) && self:GetVelocity():Length() < 500 )

		
	if( self.AutoPilot ) then
		
		local pr = {}
		pr.secondstoarrive	= 1
		pr.pos 				= self:GetPos() + self:GetForward() * self.Speed
		pr.maxangular		= self.MaxAngular or 15
		pr.maxangulardamp	= self.MaxAngularDamp or 80
		pr.maxspeed			= self.MaxCSCSpeed or 1000000
		pr.maxspeeddamp		= self.MaxCSCSpeedDamp or 10000
		pr.dampfactor		= self.MaxCSCDampFactor or 0.72
		pr.teleportdistance	= self.MaxCSCTeleDistance or 10000
		pr.deltatime		= deltatime
		pr.angle = self:GetAngles()
		
		if( stallang ) then return end
		
		phys:ComputeShadowControl( pr )
			
		self:WingTrails( self:GetAngles().r, 10 )
		
		return
		
	end
	
	if ( self.IsFlying ) then
	
		phys:Wake()
		
		local p = { { Key = IN_FORWARD, Speed = 1.25 };
					{ Key = IN_BACK, Speed = -1.15 }; }
					
		for k,v in ipairs( p ) do
			
			if ( self.Pilot:KeyDown( v.Key ) ) then
			
				self.Speed = self.Speed + v.Speed
			
			end
			
		end

		local a = self.Pilot:GetPos() + self.Pilot:GetAimVector() * 3000 + self:GetUp() * -self.CrosshairOffset --  This is the point the plane is chasing.
		local ta = ( self:GetPos() - a ):Angle()
		local ma = self:GetAngles()
		local pilotAng = self.Pilot:EyeAngles()
		local r,pitch,vel
		self.offs = self:VecAngD( ma.y, ta.y )		
		
		local r_mod = -1
				
		
		if( pilotAng.p < -89 || pilotAng.p > 89) then
			
			r_mod = 1
			
		end
		
		if( self.offs < -160 || self.offs > 160 ) then r = 0 else r = ( self.offs / self.BankingFactor ) * r_mod end
		

		pitch = pilotAng.p
		vel =  math.Clamp( self:GetVelocity():Length() / 15, 10, 90 )

		
		if( self:GetVelocity():Length() < 100 ) then	
			
			pilotAng.y = ma.y
			r = 0
			
		end

		if( ma.p < -25 || ma.p > 23 ) then self.Speed = self.Speed + ma.p/8.55 end
		local up = Vector( 0,0, -150 + ( self:GetVelocity():Length() / 5.8 ) )
		
		local tr,trace = {},{}
		tr.start = self:GetPos() + ( self:GetForward() * 500 ) + Vector( 0,0,50 )
		tr.endpos = self:GetPos() + ( self:GetForward() * 500 ) + Vector( 0,0,-1024 )
		tr.filter = self
		tr.mask = MASK_SOLID
		trace = util.TraceLine( tr )
		
		if( self.Speed < 400 && trace.HitWorld ) then
			
			r = 1
			r_mod = 1
			up = Vector( 0,0,-30 )
			pilotAng.p = -1
			vel = 90
			
		end
		
		if( self.Pilot:KeyDown( IN_WALK ) ) then
			
			r = 0
			r_mod = 0
			pilotAng.p = 0
			pilotAng.y = ma.y
			pilotAng.r = 0
			
		end
		
		self.Speed = math.Clamp( self.Speed, self.MinVelocity, self.MaxVelocity )
		
		local pr = {}
		pr.secondstoarrive	= 1
		pr.pos 				= self:GetPos() + self:GetForward() * self.Speed + up
		pr.maxangular		= 100 - vel
		pr.maxangulardamp	= 100 - vel
		pr.maxspeed			= 1000000
		pr.maxspeeddamp		= 10000
		pr.dampfactor		= 0.72
		pr.teleportdistance	= 10000
		pr.deltatime		= deltatime
		pr.angle = pilotAng + Angle( 0, 0, r - r_mod ) --pr.angle = --[[self:GetAngles() + Angle( self.C_Pitch, self.C_Yaw, self.C_Roll ) -- ]] Angle( pitch, pilotAng.y, pilotAng.r ) + Angle( 0, 0, r )
		
		if( stallang ) then return end
		
		phys:ComputeShadowControl( pr )
			
		self:WingTrails( ma.r, 10 )
			
	end		

	
	if( IsValid( self.Propeller ) ) then
		
		local spinval = self.Speed
		if( self.Speed == 0 ) then
			
			spinval = 100
		
		end
		
		self.Propeller:GetPhysicsObject():AddAngleVelocity( Vector( spinval/50, 0, 0 ) )
		
	end
	
end


function Meta:CivAir_DefaultUse( ply, caller, a, b )
	
	if ( !self.IsFlying && !IsValid( self.Pilot ) ) then 
		
		self.LastStarted = CurTime()
		
		if( self.EngineMux ) then
			
			self.Pitch = 80
			for i =1,#self.EngineMux do
			
				self.EngineMux[i]:PlayEx( 511 , self.Pitch )
			
			end
			
		else
			
			if( type( self.Propellers ) == "table" ) then
				
				for i=1,#self.Propellers do
					
					for y=1,#self.Propellers[i].EngineMux do
					
						self.Propellers[i].EngineMux[y]:Play()
					
					end
					
				end
			
			end
		
		end
		
		if( self.Wings && self.Tail ) then
			
			ply:SendLua( "notification.AddLegacy( [[Hold Jump to increase throttle, Press Duck to decrease throttle.]], 0, 4 )" )
			
			timer.Simple( 1, function() 
				if( IsValid( ply ) ) then
					ply:SendLua( "notification.AddLegacy( [[Hold Sprint to activate Combat Flaps]], 0, 4 )" )
				end
			end )
			timer.Simple( 2, function() 
				if( IsValid( ply ) ) then
					ply:SendLua( "notification.AddLegacy( [[Press V to Zoom]], 0, 4 )" )
				end
			end )
			timer.Simple( 3, function() 
				if( IsValid( ply ) ) then
					ply:SendLua( "notification.AddLegacy( [[jet_cockpitview 1 / 0 toggles between camera modes]], 0, 4 )" )
				end
			end )
			
			
		end
		
		self:Jet_DefaultUseStuff( ply, caller )
			
		timer.Simple( 1, function() 
		
			if( IsValid( ply ) && IsValid( self ) ) then
			
				SendPlaneParts( ply, self )
			
			end 
		
		end )
		
		if( self.HasPilotSeat ) then
			
			self.Pilot:EnterVehicle( self.PilotSeat )
		
		end 
		
		
		self:SetPhysicsAttacker( ply, 999999999 )
		
		self.PilotModel = self:SpawnPilotModel( self.PilotModelPos, Angle( 0,0,0 ) )
		ply:SetNetworkedEntity("NeuroPlanes_Pilotmodel", self.PilotModel )
	
		
	else
		
		if( type(self.GunnerSeats) == "table" ) then
		
			for i=1,#self.GunnerSeats do
				
				if( !IsValid( self.GunnerSeats[i]:GetDriver() ) ) then
					
					ply:EnterVehicle( self.GunnerSeats[i] )
					
					return
					
				end
			
			end
			
		end
		
	end

	
end
function Meta:CivAir_OnRemove()
	
	if( self.ContigiousFiringLoop ) then
			
		self.PrimarySound:Stop()
		-- self.PrimarySound:Remove()
		
	end
	self.StallWarning:Stop()
	self.FireWarning:Stop() 
	-- self:StopSound("")
	if( self.Destroyed ) then
		local atk = self
		
		if( IsValid( self.LastAttacker ) && self.LastAttacked + 5 >= CurTime() ) then
				
			atk = self.LastAttacker
				
		end
		
		util.BlastDamage( self, atk, self:GetPos() + Vector(0,0,32), 500, 500  )
		
	end
	
	if( self.EngineMux ) then
	
		for i=1,#self.EngineMux do
		
			self.EngineMux[i]:Stop()
			
		end
	else
	
		if( self.Propellers ) then
			
			for k,v in pairs( self.Propellers ) do
				
				if( v.EngineMux ) then
					
					for i=1,#v.EngineMux do 
					
						v.EngineMux[i]:Stop()
					
					end
					
				end
			
			end
		
		end
		
	end
	
	-- self:StopSound("Tiger/fire_alarm_tank.wav")
	
	if( self.Propeller && IsValid( self.Propeller ) ) then
		
		self.Propeller:Remove()
		
	end
	
	if( self.Wheels ) then
	
		for i = 1, #self.Wheels do
			
			if ( IsValid( self.Wheels[i] ) ) then
				
				self.Wheels[i]:Remove()
			
			end
			
		end
		
	end
	
	if( self.FXMux ) then
		
		for i=1,#self.FXMux do
			
			self.FXMux[i]:Stop()
			
		end 
	
	end
	
	if ( IsValid( self.Pilot ) ) then
	
		self:EjectPilot()
	
	end
	
end


function Meta:NA_GenericPhysUpdate()
	
	if( IsValid( self.Propeller ) ) then
		
		-- self.Propeller:GetPhysicsObject():AddAngleVelocity( Vector( 1000,0,0 ) )
		self.Propeller:GetPhysicsObject():AddAngleVelocity( Vector( 2000,0,0 ) )
		-- print(" soi" )
	end
	
	if ( self.IsFlying && IsValid( self.Pilot ) ) then
	
		if( IsValid( self.PilotSeat ) ) then
			
			if( !IsValid( self.PilotSeat:GetDriver() ) ) then
				
				self:NeuroJets_Eject()
				
				return
				
			end
			
		end
		
		self:GetPhysicsObject():Wake()
	
	end
	
end

function Meta:NA_DefaultUseStuff( ply )

	if( ply == self.Pilot ) then return end
	if( self.IsBurning ) then return end
	if( self.Destroyed ) then return end
	if( self:WaterLevel() > 0 ) then return end
	
	if ( !self.IsFlying && !IsValid( self.Pilot ) ) then 
	
		self:GetPhysicsObject():Wake()
		self:GetPhysicsObject():EnableMotion( true )

		self.Pilot = ply
		self.Owner = ply

		ply:EnterVehicle( self.PilotSeat )
		-- ply:SetDrivingEntity( self )
		
		ply.OriginalFOV = ply:GetFOV()
		
		ply:SetHealth( self.HealthVal )
		ply:SetNetworkedBool( "InFlight",true )
		
		ply:SetNetworkedEntity( "Plane", self ) 
		ply:SetScriptedVehicle( self )
		self:SetNetworkedEntity("Pilot", ply )
		
		
		self:SetNetworkedInt( "FlareCount", self.FlareCount )
		self:SetNetworkedInt( "FireMode", self.FireMode)
		local wep = self.EquipmentNames[ self.FireMode ]
		if( IsValid( wep ) ) then
			
			local wepData = self.RocketVisuals[ wep.Identity ]
			self:SetNetworkedString("NeuroPlanes_ActiveWeapon", wep.Name)
			self:SetNetworkedString("NeuroPlanes_ActiveWeaponType", wepData.Type)
			
		end
		
		
		self.LastUseKeyDown = CurTime()
		
		self:EmitSound( self.NA_StartupSound, 511, 100 )
		
		timer.Simple( self.NA_StartupDelay, function()
			
			if( IsValid( self ) ) then
				
				self:SetNetworkedBool( "NA_Started",true )
				self:CreateRotorwash()
				if( self.EngineMux ) then
					
					for i=1,#self.EngineMux do
		
						self.EngineMux[i]:PlayEx( 500, self.Pitch )
					
					end
					
				end
				
				self.IsFlying = true
				
			end
			
		end )
		
	else
	
		if( IsValid( self.CopilotSeat ) ) then
			
			self.CoPilot = ply
			self.CoPilot:EnterVehicle( self.CopilotSeat )
			
			if( self.NA_Copilot_HUD ) then
			
				self.CoPilot:SetNetworkedBool( "InFlight",true )
				self.CoPilot:SetNetworkedEntity( "Plane", self )
				
			end
			
		end

    end

end

function Meta:NA_Default_Jet_PhysicsCollide( data, physobj )
	
	if( data.Speed > 1200 && !self.Destroyed ) then
		
		
		self:NeuroJets_Eject()
		self:DeathFX()
		
		
	end

end


function Meta:NA_GenericOnRemove()

	if( self.EngineMux ) then
	
		for i=1,#self.EngineMux do
		
			self.EngineMux[i]:Stop()
			
		end
		
	end
		
	
	if( self.Propeller && IsValid( self.Propeller ) ) then
		
		self.Propeller:Remove()
		
	end
	
	if( self.Wheels ) then
	
		for i = 1, #self.Wheels do
			
			if ( IsValid( self.Wheels[i] ) ) then
				
				self.Wheels[i]:Remove()
			
			end
			
		end
		
	end
	
	if ( IsValid( self.Pilot ) ) then
	
		self:NeuroJets_Eject()
	
	end

end

function Meta:NA_Default_Jet_TakeDamage( dmginfo )

	if ( self.Destroyed ) then
		
		return

	end
	
	self:TakePhysicsDamage(dmginfo)
	
	local dmg = dmginfo:GetDamage()
	local damagepos = dmginfo:GetDamagePosition()
	
	self.HealthVal = self.HealthVal - dmg
	self:SetNetworkedInt( "health",self.HealthVal )


	if( self.NA_NumEngines && self.NA_NumEngines > 0 ) then
		
		-- print( "!!")
		for i=1,self.NA_NumEngines do
			-- print( "!!!")
			if( !self.NA_EngineHealth.Destroyed ) then
				-- print( "!!!!")
				local engpos = self:LocalToWorld( self.NA_ExhaustPorts[i] )
				if( damagepos:Distance( engpos ) < 60 ) then
					-- print( "!!!!!")
					self.NA_EngineHealth[i].Health = self.NA_EngineHealth[i].Health - dmg
					if( self.NA_EngineHealth[i].Health < 0 ) then
						-- print( "!!!!!!")
						self.NA_EngineHealth[i].Destroyed = true
						self.NA_EngineHealth[i].Fire = ents.Create("env_fire_trail")
						self.NA_EngineHealth[i].Fire:SetPos( engpos )
						self.NA_EngineHealth[i].Fire:SetParent( self )
						self.NA_EngineHealth[i]:Spawn()
							
						self.MaxVelocity = self.MaxVelocity * ( ( 1/self.NA_NumEngines ) * 2 )
						
					end
				
				end

			end
		
		end
		
	end
	
	if( self.HealthVal <= 0 && !self.Destroyed ) then
		
		self.Destroyed = true
		self:SetPhysDamping( 0,0 )
		
		self:DeathFX()
		
		return
		
	end
	
end

function Meta:NeuroJets_VisualStuff()
	
	if( self.IsBurning ) then
		
		if( self.NA_ExhaustPorts != nil ) then
			
			for i=1,#self.NA_ExhaustPorts do
				
				local fire = EffectData()
				fire:SetOrigin( self.NA_ExhaustPorts[i] )
				util.Effect("immolate",fire)
			
			end
		
		else
		
		
		end
	
	end
	

end


function Meta:NA_GenericJetThink()
	
	self:NextThink( CurTime() )

	if ( self.IsFlying && IsValid( self.Pilot ) ) then
		
		self:NeuroJets_MovementScript()
		self:NeuroJets_VisualStuff()
		self:UpdateRadar()
		self:SonicBoomTicker()
		self:Jet_LockOnMethod()
		self:NeuroPlanes_CycleThroughJetKeyBinds()
	
	end
	
end

function Meta:NA_25mmPrimaryAttack()
	if ( !IsValid( self.Pilot ) ) then
		
		return
		
	end
	
	for i=1,10 do 
	
		timer.Simple( i / 15, 
		
		function() 
			
			if( !IsValid( self ) ) then return end
			if( !IsValid( self.Pilot ) ) then return end
			
			local bullet = {} 
			bullet.Num 		= 1
			bullet.Src 		= self.Weapon:GetPos() + self.Weapon:GetForward() * ( self.PrimaryGunBarrelLength )
			bullet.Dir 		= self.Weapon:GetAngles():Forward()		-- Dir of bullet 
			bullet.Spread 	= Vector( .019, .019, .019 )				-- Aim Cone 
			bullet.Tracer	= math.random( 1, 2 )					-- Show a tracer on every x bullets  
			bullet.Force	= 450					 					-- Amount of force to give to phys objects 
			bullet.Damage	= math.random( 20, 45 )
			bullet.Attacker = self.Pilot
			bullet.AmmoType = "Ar2" 
			bullet.TracerName 	= self.NA_TracerName
			bullet.Callback    = function ( a, b, c )
									
									local e = EffectData()
									e:SetOrigin(b.HitPos)
									e:SetNormal(b.HitNormal)
									e:SetScale( 16.5 )
									util.Effect("ManhackSparks", e)

									ParticleEffect( self.NA_DefaultMaingunImpactFX, b.HitPos, ( b.HitPos - b.HitNormal ):Angle(), self )
									util.BlastDamage( self, self.Pilot, b.HitPos, 256, math.random( 100, 250 ) )
									
									return { damage = true, effects = DoDefaultEffect } 
									
								end 
			
			self.Weapon:FireBullets( bullet )
			
			self.Pilot:EmitSound( self.NA_PrimaryAttackSound, 511, 98 )

			local LagPrediction = ( self.PrimaryGunBarrelLength + ( self:GetVelocity():Length()/20 ) )
			
			if( self.NA_PrimaryAttackEffect ) then
			
				ParticleEffect( self.NA_PrimaryAttackEffect, self.Weapon:GetPos() + self.Weapon:GetForward() * LagPrediction, self.Weapon:GetAngles(), self.Weapon )
			
			else
			
				ParticleEffect( "MG_muzzleflash", self.Weapon:GetPos() + self.Weapon:GetForward() * LagPrediction, self.Weapon:GetAngles(), self.Weapon )
			
			end
			
			self.LastPrimaryAttack = CurTime()
		
		
		end )
		
	end
	
end

local spintable={-1,1}
function Meta:NA_DefaultPhysSim( phys, deltatime )

	-- if the player ejects mid-air we dont want the plane to stop. Send it away spinning.
	if( !self.IsFlying && self.Speed > 2000 ) then
		
		if( !self.SpinDir ) then self.SpinDir = spintable[math.random(1,2)] end
		
		self:GetPhysicsObject():ApplyForceCenter( self:GetForward() * self.Speed * 2001 )
		self:GetPhysicsObject():AddAngleVelocity( Vector( self.SpinDir * 7.5, 0, 0 ) )
		
	end
	
end

function Meta:NeuroAir_Default_Jet_Init()
 
	self:SetRenderMode( RENDERMODE_TRANSALPHA )
	
	if( !self.NA_YawRollMultiplierFast || !self.NA_PhysicsUpperSpeedLimit ) then
	
		-- physics
		self.RotationalDamping 	= 0.152-- 0.000000015--0.001
		self.LinearDamping		= 0.1--0.000000015-- 0.001
		self.NA_Yaw 				= 800
		self.NA_PitchDown 		= 650
		self.NA_PitchUp 			= 600 
		self.NA_Roll 			= 8000
		self.NA_YawRollMultiplierStraight = 5
		self.NA_YawRollMultiplierFast = 3
		self.NA_Mass = 1000

		self.NA_LerpYaw = 0.45 -- 0.0 to 1.0
		self.NA_LerpRoll = 0.0875 -- 0.0 to 1.0
		self.NA_LerpPitch = 0.45 -- 0.0 to 1.0

		self.NA_GForceCeiling = 100
		self.NA_MaxGForce = 15
		self.NA_MinGForce = -50

		self.NA_PhysicsUpperSpeedLimit = 2200

		self.NA_SteerabilityMultiplier = 1.0
		
	end
	
	if( !self.NA_LiftMultiplier ) then
		
		self.NA_LiftMultiplier = 1
		
	end
	
	if( self.NA_ExhaustPorts ) then
	
		self.NA_EngineHealth = {}
		self.NA_NumEngines = #self.NA_ExhaustPorts
		for i = 1,self.NA_NumEngines do
			
			self.NA_EngineHealth[i] = {}
			
			self.NA_EngineHealth[i].Health = self.InitialHealth / ( 2 * self.NA_NumEngines )
			self.NA_EngineHealth[i].Destroyed = false
			-- print( self.NA_EngineHealth[i] )
			
		end
		
	end
	
	self.Destroyed = false
	self.Burning = false
	self.Speed = 0
	self.DeathTimer = 0
	self.RollIncrement = 0
	self.PitchIncrement = 0
	self.YawIncrement = 0
	
	-- Timers
	self.LastPrimaryAttack = 0
	self.LastSecondaryAttack = 0
	self.LastFireModeChange = 0
	self.LastRadarScan = 0
	self.LastFlare = 0

	self.HealthVal = self.InitialHealth
	
	self:SetNetworkedInt( "health",	self.HealthVal)
	-- self:SetNetworkedInt( "HudOffset", self.CrosshairOffset )
	self:SetNetworkedInt( "MaxHealth",self.InitialHealth )
	self:SetNetworkedInt( "MaxSpeed",self.MaxVelocity)

	self.LastPrimaryAttack = CurTime()
	self.LastSecondaryAttack = CurTime()
	self.LastFireModeChange = CurTime()
	self.LastRadarScan = CurTime()
	self.LastFlare = CurTime()
	self.LastLaserUpdate = CurTime()

	// Armamanet
	local i = 0
	local c = 0
	self.FireMode = 1
	self.EquipmentNames = {}
	self.RocketVisuals = {}
	
	for k,v in pairs( self.Armament ) do
		
		i = i + 1
		self.RocketVisuals[i] = ents.Create("prop_physics_override")
		self.RocketVisuals[i]:SetModel( v.Mdl )
		self.RocketVisuals[i]:SetPos( self:LocalToWorld( v.Pos )  )
		self.RocketVisuals[i]:SetAngles( self:GetAngles() + v.Ang )
		self.RocketVisuals[i]:SetParent( self )
		self.RocketVisuals[i]:SetSolid( SOLID_NONE )
		self.RocketVisuals[i].Type = v.Type
		self.RocketVisuals[i].PrintName = v.PrintName
		self.RocketVisuals[i].Cooldown = v.Cooldown
		self.RocketVisuals[i].isFirst = v.isFirst
		self.RocketVisuals[i].Identity = i
		self.RocketVisuals[i].Class = v.Class
		self.RocketVisuals[i]:Spawn()
		self.RocketVisuals[i].LastAttack = CurTime()
		
		if ( v.Damage && v.Radius ) then
			
			self.RocketVisuals[i].Damage = v.Damage
			self.RocketVisuals[i].Radius = v.Radius
		
		end
		
		// Usuable Equipment
		if ( v.isFirst == true || v.isFirst == nil /* Single Missile*/ ) then
		
			if ( v.Type != "Effect" && v.Type != "Flarepod" ) then
				
				c = c + 1
				self.EquipmentNames[c] = {}
				self.EquipmentNames[c].Identity = i
				self.EquipmentNames[c].Name = v.PrintName
				
			end
			
		end
		
	end
	
	self.NumRockets = #self.EquipmentNames
	self:SetNetworkedInt( "NumEquipment", self.NumRockets)
	self.Trails = {}
	
	-- Create Soundsystems
	
	
	self.EngineMux = {}
	
	for i=1, #self.NA_EngineSounds do
	
		self.EngineMux[i] = CreateSound( self, self.NA_EngineSounds[i] )
		
	end
	
	// Sonic Boom variables
	self.PCfx = 0
	self.FXMux = {}
	
	for i=1, #self.NA_FXSound do
	
		self.FXMux[i] = CreateSound( self, self.NA_FXSound[i] )
		
	end
	
	self.SoundPitch = 80
	self.SonicBoomMux = CreateSound( self, "LockOn/SonicBoom.mp3" )
	self.SonicBoomMux:SetSoundLevel(150)	
	self.SonicBoomMux:Stop()	
	self.SuperSonicMux = CreateSound( self, "LockOn/Supersonic.mp3" )
	self.SuperSonicMux:SetSoundLevel(140)	
	self.SuperSonicMux:Stop()	
	
	self.VolPitch = 80
	
	self:SetUseType( SIMPLE_USE )
	self.IsFlying = false
	self.Pilot = NULL

	self.PilotSeat = ents.Create( "prop_vehicle_prisoner_pod" )
	self.PilotSeat:SetPos( self:LocalToWorld( self.PilotSeatPos ) )
	self.PilotSeat:SetModel( "models/nova/jeep_seat.mdl" )
	self.PilotSeat:SetKeyValue( "vehiclescript", "scripts/vehicles/prisoner_pod.txt" )
	self.PilotSeat.HandleAnimation = function( v, p ) return p:SelectWeightedSequence( ACT_DRIVE_AIRBOAT ) end
	self.PilotSeat:SetAngles( self:GetAngles() + Angle( 0, -90, 0 ) )
	self.PilotSeat:SetParent( self )
	self.PilotSeat:SetKeyValue( "LimitView", "0" )
	self.PilotSeat:SetColor( Color ( 0,0,0,0 ) )
	self.PilotSeat:SetRenderMode( RENDERMODE_TRANSALPHA )
	self.PilotSeat:DrawShadow( false )
	self.PilotSeat:Spawn()


	local o = self.MachineGunOffset
	self.Weapon = ents.Create("prop_physics_override")
	self.Weapon:SetModel( self.MachineGunModel )
	self.Weapon:SetPos( self:LocalToWorld( o ) )
	self.Weapon:SetAngles( self:GetAngles() )
	self.Weapon:SetSolid( SOLID_NONE )
	self.Weapon:SetParent( self )
	self.Weapon:Spawn()
	
	self.ShootingLoop = CreateSound( self.Weapon, self.NA_PrimaryAttackSound )
	
	// Misc
	self:SetModel( self.Model )	
	self:SetSkin( 1 )
	self:PhysicsInit( SOLID_VPHYSICS )
	self:SetMoveType( MOVETYPE_VPHYSICS )
	self:SetSolid( SOLID_VPHYSICS )

	self.PhysObj = self:GetPhysicsObject()
	
	if ( self.PhysObj:IsValid() ) then
	
		self.PhysObj:Wake()
		self.PhysObj:SetMass( self.NA_Mass or 10000 )
		
	end

	self:StartMotionController()
		
		
	if( self.LinearDamping && self.RotationalDamping && self.PhysObj ) then
	
		self.PhysObj:SetDamping( self.LinearDamping, self.RotationalDamping )
	
	end
	
end

function Meta:NA_JetPrimaryAttack()
	
	if ( !IsValid( self.Pilot ) ) then
		
		return
		
	end
	
 	local bullet = {} 
 	bullet.Num 		= 1
 	bullet.Src 		= self.Weapon:GetPos() + self.Weapon:GetForward() * 255
 	bullet.Dir 		= self.Weapon:GetAngles():Forward()		// Dir of bullet 
 	bullet.Spread 	= Vector( .019, .019, .019 )				// Aim Cone 
 	bullet.Tracer	= math.random( 2, 4 )					// Show a tracer on every x bullets  
 	bullet.Force	= 450					 					// Amount of force to give to phys objects 
 	bullet.Damage	= math.random( 40, 45 )
 	bullet.AmmoType = "Ar2" 
 	bullet.TracerName 	= "AirboatGunHeavyTracer" 
 	bullet.Callback    = function ( a, b, c )
							
							local e = EffectData()
							e:SetOrigin(b.HitPos)
							e:SetNormal(b.HitNormal)
							e:SetScale( 6.5 )
							util.Effect("ManhackSparks", e)

							local e = EffectData()
							e:SetOrigin(b.HitPos)
							e:SetNormal(b.HitNormal)
							e:SetScale( 2.5 )
							util.Effect("HelicopterMegaBomb", e)
							
							util.BlastDamage( self.Pilot, self.Pilot, b.HitPos, 300, 8 )
							
							return { damage = true, effects = DoDefaultEffect } 
							
						end 
 	
	self.Weapon:FireBullets( bullet )
	
	self.Weapon:EmitSound( "A10fart.mp3", 511, 98 )
	
	local effectdata = EffectData()
	effectdata:SetStart( self.Weapon:GetPos() + self:GetForward() * 130 )
	effectdata:SetOrigin( self.Weapon:GetPos() + self:GetForward() * 130 )
	effectdata:SetEntity( self.Weapon )
	effectdata:SetNormal( self:GetForward() )
	util.Effect( "A10_muzzlesmoke", effectdata )  

	self.LastPrimaryAttack = CurTime()
	
end

function Meta:NA_BombingPointPrediction()

	if ( self.IsFlying && IsValid( self.Pilot ) ) then
	
		local spd = self:GetVelocity():Length()
		local ang = self:GetAngles()
		local bpos = self:BombingImpact(spd,ang.p)
		self:SetNetworkedVector( "BombingImpactPos", bpos )
		
	end
	
end

function Meta:SetPhysDamping( damp, ang )
	self._Damp = self.Damping 
	self._AngDamp = self.AngDamping
	
	if( IsValid( self ) ) then self:GetPhysicsObject():SetDamping( damp, ang ) end
	for i=1,#self.Wings do if( IsValid( self.Wings[i] ) ) then	self.Wings[i]:GetPhysicsObject():SetDamping( damp, ang )end end
	-- if( IsValid( self.Wings[2] ) ) then	self.Wings[2]:GetPhysicsObject():SetDamping( damp, ang )end
	if( IsValid( self.Tail ) ) then	self.Tail:GetPhysicsObject():SetDamping( damp, ang ) end
	
end

function Meta:GetPhysDamping( )
	
	return self._Damp or 0, self._AngDamp or 0
end


function Meta:IsPlaneOnGround()
	
	local tr,trace = {},{}
	tr.start = self:GetPos() + self:GetForward() * 250 
	tr.endpos = tr.start + Vector( 0,0,-250 )
	tr.filter = { self, self.Owner, self.Wings, self.Ailerns, self.Tail, self.Pilot }
	tr.mask = MASK_SOLID
	trace = util.TraceLine( tr )
	-- print( trace.Hit )
	return trace.Hit 
	
end

function Meta:MicroPhysics( phys, deltatime )

	if( self.Destroyed ) then 
		
		self:GetPhysicsObject():ApplyForceCenter( Vector(0,0,-250000 ) ) 
		-- self:GetPhysicsObject():AddAngleVelocity( Vector( 15*self.Damping, 0,0 ) ) 
		-- self:SetPhysDamping( 1,1 ) 
		
		-- return
		
	end
	
	self.CurVelocity = self:GetPhysicsObject():GetVelocity():Length()
	if( !self.ZMomentum ) then
		
		self.ZMomentum = 0 
		
	end
	

		-- if( !self._Ticker ) then self._Ticker = CurTime() self._Delta = 0 end
		
		-- if( self._Ticker + .25 <= CurTime() ) then
		
			-- if( !self._OldVelocity ) then self._OldVelocity = self:GetVelocity():Length() self._OldVelocityTime = CurTime() return end
		
			-- self._LastDelta = self._Delta
			-- self._Delta = self:GetVelocity():Length() - self._OldVelocity / CurTime() - self._OldVelocityTime
			
			-- self.Pilot:PrintMessage( HUD_PRINTCENTER, self._Delta .. " " .. self._LastDelta  )
			-- self._OldVelocity = self:GetVelocity():Length()
			-- self._OldVelocityTime = CurTime()
			-- self._Ticker = CurTime()
			
			
		-- end
		
	-- end
	
	local MaxVelocity = self.MaxVelocity
	local SteeringPower =  1.2 * ( self.CurVelocity  / MaxVelocity ) - 0.22 * math.sqrt( self.CurVelocity / MaxVelocity )
	local Lift = 0	
	local ma = self:GetAngles()
	local minp = self.MinClimb or 5
	local maxp = self.MaxClimb or -15
	local punish = self.ClimbPunishmentMultiplier or 50
	local FlapsDown = false
	local boostmultiplier = 0
	local liftmultiplier = 1
	local ma = self:GetAngles()
	local pwr = 1.0 * ( self.CurVelocity  / self.MaxVelocity )	
	
	
	-- print( self.CurVelocity )
	
	local Stalling = ( ( ma.p < -30 || ( ma.r < -35 || ma.r > 35 ) ) && self.CurVelocity < 400+math.abs(ma.r) ) || ( self.LastStarted && self.LastStarted + 15 <= CurTime() && self.CurVelocity < 250 && !self:IsPlaneOnGround() )
	-- print( Stalling ) 
	local AnimRudder, AnimAileron, AnimFlaps, AnimElevator = 0,0,0,0
	local throttle = self.ThrottleIncrementSize
	local pitchValue = self.PitchValue
	
	if( self.LastStall && self.LastStall + 5 >= CurTime() ) then	
		
		self.StallWarning:PlayEx(511,100)
		
	else
		
		self.StallWarning:FadeOut( 1 )
	
	end
	
	
	if( ma.p > 45 && self:GetVelocity().z < 0 ) then
	
		self.ZMomentum = math.Approach( self.ZMomentum, self.PitchValue/4, 0.2 )
		
	else
		
		self.ZMomentum = math.Approach( self.ZMomentum, 0, 0.12 )
	
	end
	if( IsValid( self.Pilot ) && self.Pilot:KeyDown( IN_BACK ) ) then
		
		self.ZMomentum = math.Approach( self.ZMomentum, 0, 0.2 )
	
	end
	if( IsValid( self.Tail ) && !IsValid( self.TailWeld )) then
	
		self.Destroyed = true
		self.BouncedOnce = true 
		self:SetPhysDamping( 0, 0 )
		-- print("bye")
		return
		
	end
	-- self.ZMomentum = math.Clamp( self.ZMomentum, )
	-- print( self.ZMomentum )
	pitchValue = pitchValue - self.ZMomentum
	-- print(  )
	local valid = 0
	if( self.Propellers ) then
			
		
		for i=1,#self.Propellers do
			
			local prop = self.Propellers[i]
			local weld = self.Propellers[i].Axis
			if( IsValid( prop ) ) then
			
				if( !IsValid( weld ) && !prop.IsBurning && self.CurVelocity > 150 && self.HealthVal < self.InitialHealth * .5 ) then
					
					prop.IsBurning = true
					
					self.MaxVelocity = self.MaxVelocity * 0.9
					-- print("NEUROTEC DEBUG: Lost propeller #"..i, self.Propeller == prop )
					-- local f = ents.Create("env_fire_trail")
					-- f:SetPos( self:LocalToWorld( self.PropellerPos[i] ) )
					
					-- if( self.PropellerAttachedToWings ) then
						
						-- if( i < #self.Propellers/2 ) then
							
							-- if( IsValid( self.Wings[1] )  ) then
								
								-- f:SetParent( self.Wings[1] )
							
							-- end
							
						-- else
							
							-- if(  IsValid( self.Wings[2] )  ) then
						
								-- f:SetParent( self.Wings[2] )
							
							-- end
							
						-- end
					
					-- else
					
						-- f:SetParent( self )
						
					-- end
					
					-- f:Spawn()
				
				end
				
				if( IsValid( weld ) )then
					
					valid = valid + 1
			
				end
				
			end
		
		end
		
	
	end
	-- if( self.CurVelocity && IsValid( self.Pilot ) && self.LastVelocity ) then
		
		-- local velo = self:GetForward():Dot( self:GetVelocity():GetNormalized() )
		-- print( velo, "cross product")
		-- local avel = self:GetPhysicsObject():GetAngleVelocity()
		-- local mi,ma = self:WorldSpaceAABB()
		-- local radius = ( mi - ma ):Length()/2
		-- local RotationalG = ( ( avel.r^2 ) * radius ) / GetConVarNumber( "sv_gravity" )
		-- local GForce =  ( ( self:GetPhysicsObject():GetMass() * self.CurVelocity ^2 ) / radius )  / GetConVarNumber( "sv_gravity" )
		-- print( "Debug G-force:",  math.sqrt( self.LastVelocity  - self.CurVelocity ), math.sqrt( RotationalG ) )
		
	-- end
	-- if( !self.Destroyed && IsValid( self.Pilot ) && self.CurVelocity < 400 &&  ) then
			
		-- self.Pilot:PrintMessage( HUD_PRINTCENTER, "WARNING LOW AIR SPEED" )
	
	-- end
	
	if( !self.StallingDownForce ) then self.StallingDownForce = 0 end 
		
	if( self.LastStall && self.LastStall + 4 >= CurTime() ) then 
			
	
		-- self:GetPhysicsObject():AddAngleVelocity( AngleRand() )
		self.StallingDownForce = math.Approach( self.StallingDownForce, -380000, 5000 )
	
	else
		
		self.StallingDownForce = math.Approach( self.StallingDownForce, 0, 5000 )
		
	end 
	
	self:GetPhysicsObject():ApplyForceCenter( Vector( 0,0,self.StallingDownForce ) ) 
			
	if( IsValid( self.Wings[1] ) && IsValid( self.Wings[1].Weld ) && IsValid( self.Wings[2] ) && IsValid( self.Wings[2].Weld ) && Stalling ) then 	
		
	
		self.BoostValue = self.BoostValue * .99999
		
		self.LastStall = CurTime()
		self.LastVelo = self:GetVelocity()
		
	
		
		self:SetPhysDamping( 0.1, 0.0 )
		-- return
		-- local stallpattern = self.StallPattern or VectorRand()*4 + Vector( -5,0, 0 )
		-- self:GetPhysicsObject():AddAngleVelocity( Vector( self.BankForce, 0,0 ) )
		
		
		-- self:GetPhysicsObject():ApplyForceCenter( self:GetForward() * -self:GetAngles().p * 5000 )
		
		
	else
	
		local d,a = self:GetPhysDamping()
		
		self:SetPhysDamping( Lerp( 0.0011, d,  self.Damping ), Lerp( 0.0011, a, self.AngDamping ))
	
	end

	
	if( IsValid( self.Pilot ) && self.Pilot:KeyDown( IN_SPEED ) ) then
		
		-- AnimRudder = self.Pilot.NeuroRudderValue or 0
		
		if( self.HealthVal > self.InitialHealth * 0.33  && IsValid( self.Wings[1] ) && IsValid( self.Wings[2] ) ) then
			
			AnimFlaps = 1
			
			-- self.Pilot:PrintMessage( HUD_PRINTCENTER, "Flaps Down" )
			
			if( self.CurVelocity < MaxVelocity  ) then
				local uplift = self:GetUp() * ( self.CurVelocity / self.WingLiftMultiplier * self:GetPhysicsObject():GetMass() ) / 2
				local myang = self:GetAngles()
				-- print( math.floor( self:GetAngles().p))
				-- if( myang.p > 45 || myang.p < -90 ) then	
					
					-- uplift = Vector( 0,0,0 )
					
					
				-- end
				
				if( self.SuperFlaps ) then 
					
					uplift = uplift * 2
					-- if( self.Pilot:KeyDown( IN_BACK ) ) then 
						
						-- uplift = uplift * 2.5 
					
					-- end 
					
				end 
				if( !IsValid( self.Wings[1] ) || !IsValid( self.Wings[2] ) ) then
					
					uplift = 0 
					
				end 
				
				self:GetPhysicsObject():ApplyForceCenter( uplift )
				-- self.Tail:GetPhysicsObject():ApplyForceCenter( self:GetUp() * ( self.CurVelocity / self.WingLiftMultiplier * self:GetPhysicsObject():GetMass() ) / 4 )
				
			end
			
			SteeringPoweer =  4.5 * ( self.CurVelocity  / MaxVelocity ) - 0.22 * math.sqrt( self.CurVelocity / MaxVelocity )
			-- MaxVelocity = MaxVelocity * 0.85
			-- punish = punish * 3.75
			-- self:SetPhysDamping( self.Damping-self.Damping*0.1, self.AngDamping-self.AngDamping*0.1 )
			-- self.BoostValue = self.BoostValue 
			-- throttle = throttle * 0.52
			-- self:GetPhysicsObject():AddAngleVelocity( Vector( 0, -0.51, 0 ) )
			
			FlapsDown = true
			
			 
		else
		
			self:SetPhysDamping( self.Damping, self.AngDamping )
			self.Pilot:PrintMessage( HUD_PRINTCENTER, "Your flaps have jammed!" )
		
		end
		
		if( self.CurVelocity < self.MaxVelocity * 0.33 ) then
			
			SteeringPower = SteeringPower * 0.1
			
		end
	
	else
		
		
		if( IsValid( self.Pilot ) ) then
			
			-- self.Pilot:PrintMessage( HUD_PRINTCENTER, )
			boostmultiplier	= 60
			
			self:SetPhysDamping( self.Damping, self.AngDamping )
		
		else
			
			liftmultiplier = 0.001
			boostmultiplier = 2
			self:SetPhysDamping( 0.5, 0.5 )
		
		end
		
	end

	self.ExtraBoost = self.ExtraBoost or 0

	
	if( ma.p > 5 || ma.p < -5 ) then 
		
		local mult = boostmultiplier*4
		local addval = 500
		-- print( ma.p )
		if( ma.p > 5 ) then
			
			mult = boostmultiplier*2
			addval = 4500 
			
		end
		
		self.ExtraBoost = math.Approach( self.ExtraBoost, ( ma.p * punish )  * mult, addval )
	
	else
		
		self.ExtraBoost = math.Approach( self.ExtraBoost, 0, 7500 )
	
		
	end

	for i=1,#self.Wings do
		
		local wi = self.Wings[i]
		if( IsValid( wi ) && IsValid( wi.Weld ) ) then
			
			local wiphy = wi:GetPhysicsObject() -- pretty fly
			local vvel = wiphy:GetVelocity():Length()
			
			Lift = ( self.CurVelocity / self.WingLiftMultiplier ) * wiphy:GetMass()
			
			local punishment = math.Clamp( self:GetAngles().p * 470, 0, 35000 )
			-- self.Pilot:PrintMessage( HUD_PRINTCENTER, Lift .." - "..punishment.." - "..Lift-punishment )
			
			
			if( self.LastStall && self.LastStall + 5.0 >= CurTime() ) then
				
				Lift = 0
			
			end
			
			if( wi.HealthVal && wi.InitialHealth ) then
			
				Lift = Lift * math.Clamp( 1.5 * ( wi.HealthVal / wi.InitialHealth ), 0, 1 )
			
			end
			
			wiphy:ApplyForceCenter( wi:GetUp()  * (Lift-punishment) + wi:GetForward() * self.ExtraBoost )

		end
		
	end
	
	if( IsValid( self.Propeller ) && IsValid( self.PropellerAxis ) ) then
	
		if( self.Propellers ) then
		
			for i=1,#self.Propellers do 
				
				if( !IsValid( self.Propellers[i] )) then continue end
				
				if( i <= #self.Propellers/2 ) then
				
					self.Propellers[i]:GetPhysicsObject():AddAngleVelocity( Vector( self.PropForce or 100, 0, 0 ) )
				
				else
					
					self.Propellers[i]:GetPhysicsObject():AddAngleVelocity( Vector( -self.PropForce or -100, 0, 0 ) )
		
				end
				
			end
			
		else
		
			self.Propeller:GetPhysicsObject():SetMass( self.PropMass or 10 )
			self.Propeller:GetPhysicsObject():AddAngleVelocity( Vector( self.PropForce or 100, 0, 0 ) )
		
		end
	
	else
				-- print("W???")
		if( !self.NoPropeller ) then
			
			-- print("???")
			if( !self.Propellers ) then
				-- print("what")
				-- local ov = self:GetPhysicsObject():GetVelocity()
			
				if( !self.CorrectedNoPropPhys ) then 
					
					self.CorrectedNoPropPhys = true 
					self.PitchValue = self.PitchValue * .8
					self.WingLiftMultiplier = self.WingLiftMultiplier * 2 
					self.TailLiftMultiplier = self.TailLiftMultiplier * 2 
			
				end 


				-- print( ( self:GetVelocity().z * -1200 ) )
				self:SetPhysDamping( 2, 2 )
				if( self:GetVelocity().z > -800 ) then 
				
					self:GetPhysicsObject():ApplyForceCenter( self:GetForward() * math.abs( self:GetVelocity().z * -2000 ))
					
				end 
				
				if( !IsValid( self.TailWeld ) ) then 
					-- print("muh plane")
					-- print(self:GetAngles().p)
					self:GetPhysicsObject():ApplyForceCenter( Vector( 0,0,-133000) )
					self:GetPhysicsObject():AddAngleVelocity( VectorRand() * 15 ) 
					
					-- if( IsValid( self.Propeller ) && IsValid( self.PropellerAxis ) ) then
						
						-- self.Propeller:GetPhysicsObject():SetMass( self:GetMass() * 1.2) 
						
					-- end 
					-- if( self:GetAngles().p > 0 ) then 
						
						-- self:GetPhysicsObject():AddAngleVelocity( Vector( 0,0,251 ) )
						
					-- end 
					
				end 
				self.LVAl = self.LVAl or 0 
				self.LVAl = math.Approach( self.LVAl, ( self:GetAngles().p * 55500 ), 25 )
				
				self:GetPhysicsObject():ApplyForceCenter( self:GetForward() *self.LVAl )
				-- self:GetPhysicsObject():SetVelocity( ov )
				
			else
				
				local count = 0 
				for i=1,#self.Propellers do
					
					if( IsValid( self.Propellers[i] ) && IsValid( self.Propellers[i].Axis )  ) then
						
						self.Propeller = self.Propellers[i]
						self.PropellerAxis = self.Propellers[i].Axis
						count = count + 1
					
					end
				
				end
		
				if( count == 0 ) then 
				
					-- print("NO PROPS")
					-- if( !self.CorrectedNoPropPhys ) then 
						
						-- self.CorrectedNoPropPhys = true 
						-- self.PitchValue = self.PitchValue * .8
						-- self.WingLiftMultiplier = self.WingLiftMultiplier * 2 
						-- self.TailLiftMultiplier = self.TailLiftMultiplier * 2 
				
					-- end 
					-- self.EngineSounds
					self:SetPhysDamping( 2.25, 4 )
					if( self:GetVelocity().z > -800 ) then 
					
						self:GetPhysicsObject():ApplyForceCenter( self:GetForward() * math.abs( self:GetVelocity().z * -2000 ))
						
					end 
					self.LVAl = self.LVAl or 0 
					-- if( self:GetAngles().p < 0 ) then 
						
						-- self.LVAl = math.Approach( self.LVAl, math.Clamp( ( self:GetAngles().p * 255500 ), -5000, -15999999 ) , 5 )
						
						
					-- else 
					
						self.LVAl = math.Approach( self.LVAl, ( self:GetAngles().p * 255500 ), 15 )
					-- print( self.LVAl )
					-- end 
					
					self:GetPhysicsObject():ApplyForceCenter( self:GetForward() *self.LVAl )
					
				end 
				
			end

		end
		
	end
		

	if( IsValid( self.Tail )  ) then
		
		-- self.Tail:GetPhysicsObject():ApplyForceCenter( self.Tail:GetUp() * lift*4 )
		local Lift = self.CurVelocity/self.TailLiftMultiplier * self.Tail:GetPhysicsObject():GetMass()
		if( self.LastStall && self.LastStall + 5.0 >= CurTime() || ( !IsValid( self.Wings[1] ) || !IsValid( self.Wings[2] ) ) ) then
			
			Lift = 0
			
		end
		
		self.Tail:GetPhysicsObject():ApplyForceCenter( self.Tail:GetUp() * Lift )
	
	
	end

		
	-- if( self.LastStall && self.LastStall + math.Rand( 0.5, 1.5 ) >= CurTime() ) then 
	
			-- self:SetVelocity( self.LastVelo )	
			-- self:SetPhysDamping( 0.755, 0.735 )
			
			-- self:GetPhysicsObject():AddAngleVelocity( Vector( 0.21, 0.0, 0 ) )
			
		-- return


	-- end
			
		
	-- if( ( !self.Propellers && IsValid( self.Propeller ) && !IsValid( self.PropellerAxis ) ) || !IsValid( self.TailWeld ) ) then

		-- if( !self.LostPropellerAdaptedPhysics ) then
			
			-- self.LostPropellerAdaptedPhysics = true
			-- local oldvelocity = self:GetPhysicsObject():GetVelocity()
			
			-- self:SetPhysDamping( 2.0, 2.0 )
			-- self.WingLiftMultiplier = 99999999999999999999999
			-- self.TailLiftMultiplier = 99999999999999999999999 
			-- self.PitchValue  = self.PitchValue / self.Damping
			-- self.RudderMultiplier  = self.RudderMultiplier / self.Damping
			-- self.BankForce  = self.BankForce / self.Damping
			
			-- self:GetPhysicsObject():SetVelocity( oldvelocity )
	
			
		-- end

	-- end
	if( IsValid( self.Pilot ) ) then
		-- print( math.floor( self.BoostValue / self.MaxVelocity ) )
		--  
		if( self.Pilot:KeyDown( IN_JUMP  ) && self.BoostValue <= GLOBAL_FORCE_MULTIPLIER * self.MaxVelocity /*&& self.CurVelocity < MaxVelocity */) then
			
			
			self.BoostValue = self.BoostValue + ( throttle * math.abs( 1.55 - 1.5 * self.CurVelocity / self.MaxVelocity ) )

		elseif( self.Pilot:KeyDown( IN_DUCK ) ) then

			self.BoostValue = math.Approach( self.BoostValue, 0, self.ThrottleDecreaseSize )
			if( ma.p > -5 ) then
				
				self.ExtraBoost = self.ExtraBoost * .999
				
			end
			-- print( self.Pilot:EyeAngles().p )
		end
		
		local oldboost = self.BoostValue
		-- self.BoostValue = self.BoostValue
		
		if( self.CurVelocity > MaxVelocity*1.05 && IsValid( self.Pilot ) ) then
			
			self.Fluttering = true
	
			self:GetPhysicsObject():AddAngleVelocity( VectorRand() * 7 )
			-- self:GetPhysicsObject():ApplyForceCenter( VectorRand() * self:GetPhysicsObject():GetMass() )
				
			local dmg = DamageInfo()
			dmg:SetAttacker( self.Pilot )
			dmg:SetDamage( 0.051 )
			dmg:SetDamageForce( VectorRand() * 500 )
			dmg:SetDamagePosition( self:GetPos()+VectorRand()*8 )
			dmg:SetDamageType( DMG_CRUSH )
			dmg:SetInflictor( self )
			dmg:SetMaxDamage( 0.065 )
			
			util.BlastDamageInfo( dmg, self:GetPos(), 8 )
			
			self.Pilot:SetNetworkedInt("LastImpact", CurTime() )
			self.Pilot:SetNetworkedInt("LastDamage", ( (self.CurVelocity / self.MaxVelocity ) - 1 ) * 350  )
			-- print( ( (self.CurVelocity / self.MaxVelocity ) - 1 ) * 350 )
			
			if( self.CurVelocity > self.MaxVelocity * 1.2 ) then
				
				self.Pilot:PrintMessage( HUD_PRINTCENTER, "WARNING! REACHING CRITICAL STRUCTURAL LOAD")
				SteeringPower = 0.55
				pwr = 0.55
				
				if( math.random(1,25) == 10 ) then
					
					self:EmitSound("ambient/materials/creak5.wav", 511, 100 )
					
				end
				
				if( self.Flaps && self.Pilot:KeyDown( IN_SPEED ) ) then
					
					for i=1,#self.Flaps do 
					
						if( IsValid( self.Flaps[i] ) ) then
							
							local lastpos = self.Flaps[i]:GetPos()
							self.Flaps[i]:SetParent()
							self.Flaps[i].Destroyed = true
							self.Flaps[i]:SetSolid( SOLID_VPHYSICS )
							self.Flaps[i]:SetMoveType( MOVETYPE_VPHYSICS )
							self.Flaps[i]:SetVelocity( self:GetVelocity() )
							self.Flaps[i]:EmitSound( "physics/wood/wood_box_break1.wav", 511, 100 )
							if( IsValid( self.Flaps[i]:GetPhysicsObject() ) ) then 
								
								self.Flaps[i]:GetPhysicsObject():EnableGravity( true )
								self.Flaps[i]:GetPhysicsObject():SetMass( 5000 )
								self.Flaps[i]:GetPhysicsObject():AddAngleVelocity( VectorRand() * 1511 )
								
							end 
							
							self.Flaps[i]:SetPos( lastpos )
							self.Flaps[i] = NULL
						
						
						end
						
					end
					
				end
			
			end
			
			if( self.CurVelocity > self.MaxVelocity*1.5 && self.ControlSurfaces ) then
			
				self:GetPhysicsObject():AddAngleVelocity( VectorRand() * 25 )
			
				
				-- local fx = EffectData()
				-- fx:SetOrigin( self:GetPos() )
				-- fx:SetScale( 0.15 )
				-- util.Effect( "HunterDamage", fx )
				if( self.ControlSurfaces && !IsValid( self.Ailerons[1] ) && !IsValid( self.Ailerons[2] ) ) then
					
					if( math.random( 1, 50 ) == 22 ) then
						
						local idx = math.random(1,2)
						local wing = self.Wings[idx]
						if( IsValid( wing ) && IsValid( wing.Weld ) ) then
							
							-- constraint.RemoveAll( wing )
							
							if( IsValid( wing.CrossWeld ) ) then
								
								wing.CrossWeld:Remove()
								
							end
							
							self.ImpactTime = 1000
							self.BouncedOnce = true
							self.RippedByPhysForce = true 
							
							wing:GetPhysicsObject():EnableGravity( true )
							wing:GetPhysicsObject():EnableDrag( true )
							wing:GetPhysicsObject():SetMass( 50000 )
							wing:SetVelocity( self:GetVelocity() )
							-- local fx = EffectData()
							-- fx:SetOrigin( wing:GetPos() )
							-- fx:SetStart( wing:GetPos() )
							-- fx:SetEntity( wing )
							-- util.Effect("microplane_damage", fx )
							ParticleEffectAttach( "microplane_damage", PATTACH_ABSORIGIN_FOLLOW, wing, 0 )
							self:GetPhysicsObject():AddAngleVelocity( VectorRand() * 50 )
							wing.Weld:Remove()
							
							if( self.EngineMux ) then
								
								for i=1,#self.EngineMux do
								
									self.EngineMux[i]:Stop()
									
								end
								
							end
							
							self.Wings[idx] = NULL
		
						end
					
					end
				
				end
				
				if( math.random( 1, 7 ) == 3 ) then
					
					local idx = math.random(1,2)
					local aileron = self.Ailerons[idx]
					if( IsValid( aileron ) ) then 
						
						aileron:SetParent( nil )
						aileron.Destroyed = true
						aileron:SetSolid( SOLID_VPHYSICS ) 
						aileron:SetMoveType( MOVETYPE_VPHYSICS )
						aileron:SetVelocity( self:GetVelocity() )
						aileron:GetPhysicsObject():SetMass( 5000 )
						aileron:EmitSound("physics/wood/wood_box_break1.wav", 511, 100 )
						aileron:GetPhysicsObject():EnableGravity( true )
						aileron:GetPhysicsObject():EnableDrag( true )
						aileron.NoFieryDeath = true
						-- aileron:Remove()
						-- local fx = EffectData()
						-- fx:SetOrigin( aileron:GetPos() )
						-- fx:SetStart( aileron:GetPos() )
						-- fx:SetEntity( aileron )
						-- util.Effect("microplane_damage", fx )
						ParticleEffectAttach( "microplane_damage", PATTACH_ABSORIGIN_FOLLOW, aileron, 0 )
						
						self.Ailerons[idx] = NULL
					
					else
						
						if( math.random( 1, 25 ) == 7 && IsValid( self.Rudder ) ) then
								
							self.Rudder:SetParent( nil )
							self.Rudder.Destroyed = true
							self.Rudder.NoFieryDeath = true
							self.Rudder:SetSolid( SOLID_VPHYSICS )
							self.Rudder:SetMoveType( MOVETYPE_VPHYSICS )
							self.Rudder:SetVelocity( self:GetVelocity() )
							self.Rudder:GetPhysicsObject():EnableGravity( true )
							self.Rudder:GetPhysicsObject():EnableDrag( true )
							self.Rudder:GetPhysicsObject():SetMass( 5000 )
							self.Rudder:EmitSound("physics/wood/wood_box_break1.wav", 511, 100 )
							self.Rudder = NULL
							-- self.Rudder:Remove()
							
							
						end
						
						if( math.random( 1, 25 ) == 3 && IsValid( self.Elevator) ) then
							
							self.Elevator:SetParent( nil )
							self.Elevator.Destroyed = true
							self.Elevator.NoFieryDeath = true
							-- self.Elevator:Remove()
							
							self.Elevator:SetSolid( SOLID_VPHYSICS )
							self.Elevator:SetMoveType( MOVETYPE_VPHYSICS )
							self.Elevator:GetPhysicsObject():SetMass( 5000 )
							self.Elevator:SetVelocity( self:GetVelocity() )
							self.Elevator:EmitSound("physics/wood/wood_box_break1.wav", 511, 100 )
							self.Elevator:GetPhysicsObject():EnableGravity( true )
							self.Elevator:GetPhysicsObject():EnableDrag( true )
							self.Elevator = NULL
							
						end
						
					end
					
				end
				-- self:GetPhysicsObject():ApplyForceCenter( VectorRand() * ( self:GetPhysicsObject():GetMass() * 500 ))
			end
			-- self.BoostValue = oldboost
		else
		
			self.Fluttering = false
			
		end

	
		if( ( IsValid( self.Propeller ) && IsValid( self.PropellerAxis ) ) || self.NoPropeller ) then

			
			if( !self.Pilot.MouseAim ) then self.Pilot:SetNetworkedBool("MouseAim",false) end
			
			-- self.Pilot:SetAngles( self:GetAngles() )
			self.Pilot.MouseAim = self.Pilot.MouseAim or false
			self.Pilot.LastMouseAimToggle = self.Pilot.LastMouseAimToggle or CurTime()
			
			if( self.Pilot:KeyDown( IN_WALK ) && self.Pilot.LastMouseAimToggle + 0.5 <= CurTime()) then
				
				self.Pilot.LastMouseAimToggle = CurTime()
					
				self.Pilot.MouseAim = !self.Pilot.MouseAim
				self.Pilot:SetNetworkedBool("MouseAim", self.Pilot.MouseAim )
				
			end
			
			if( GetConVarNumber( "warthunder_controls", 0 ) > 0 && self.Pilot.MouseAim ) then
				
				if( !self.Pilot:KeyDown( IN_FORWARD ) && !self.Pilot:KeyDown( IN_BACK ) && !self.Pilot:KeyDown( IN_MOVERIGHT ) && !self.Pilot:KeyDown( IN_MOVELEFT ) && self.CurVelocity > 150  ) then
						--[[
					local ma = self:GetAngles()
					local mp = self:GetPos()
					
					local tpos = self:GetPos() + self.Pilot:EyeAngles():Forward() * 3500 + self:GetUp() * 512
					local ta = ( tpos - mp ):Angle()
					local dP = math.AngleDifference( ma.p, ta.p )
					local dY = math.AngleDifference( ma.y, ta.y )
					local dR = math.AngleDifference( ma.r, ta.r )
					
					self.Pilot:PrintMessage( HUD_PRINTCENTER, math.floor(dP).." - "..math.floor(dY).." - "..math.floor(dR) )
					local r,p,y = dY, dP, dP
					
					local RollAng = ( tpos - ( mp + self:GetForward() * 3500 ) ):Angle()
					-- RollAng:RotateAroundAxis( self:GetUp(), 90 )
					
					local rolldiff = math.AngleDifference( ma.r, RollAng.r ) 
					
					-- ma:RotateAroundAxis( self:GetForward(),  )
					
					print( ma.r, rolldiff )
					
					-- if( ma.r > 145 || ma.r < -145 ) then
						
						r = -rolldiff
						
					-- end
					
					
					p = 0
					y = 0
					
						
					
					self:GetPhysicsObject():AddAngleVelocity( Vector( r*2, p, y ) )
					-- local 
					
					]]--
					
					-- self.Pilot:SetPos( self:GetPos() + Vector(0,0,100) )
					-- debug override
					-- self.MousePichForceMult = 1.2 -- MousePichForceMult * PitchForce, override default max pitch force when using hte mouse.
					-- self.MouseBankForceMult = 1.0 -- MouseBankForceMult * BankForce, override default max bank speed if the plane feels sluggish when turning
					-- self.MousePitchForce = 70 -- How many times to multiply the angle difference between plane pitch and mouse pitch
					-- self.MouseBankForce = 200 -- How many times to multiply the angle difference between plane Yaw and Mouse Yaw.
					-- self.MouseBankTreshold = 2.0 -- How many degrees we can allow the mouse to move before we start banking, set this high if you got a front mounted cannon so you can aim freely a bit.
					-- self.MousePitchTreshold = 1.0 -- use power of two with MouseBankTreshold to create a mousetrap near the front of the plane. 
				
					local ma = self:GetAngles()
					local mp = self:GetPos()
					-- local norm = Angle( math.NormalizeAngle( ma.p ), math.NormalizeAngle( ma.y ), math.NormalizeAngle( ma.r ) )
					local tpos = self:GetPos() + self.Pilot:EyeAngles():Forward() * 3500  -- + self:GetUp() * 150
					local ta = ( tpos - mp ):Angle()
					
					local diffY = self:VecAngD( ma.y, ta.y )
					local diffR = math.Clamp( self:VecAngD( ma.r, ta.r ), -65, 65 )
					local extradiffp = 5 
					local diffP = self:VecAngD( ma.p, ta.p-extradiffp )
					-- if( math.abs(diffY) > 
					
					local p,y,r = math.Clamp( diffY*1, -65, 65 ), math.Clamp( -diffP*1, -self.RudderMultiplier, self.RudderMultiplier ), math.Clamp( -diffY*2, -pitchValue*2, pitchValue*2 )
					local MouseTrapSize = 2

					-- R P Y
					-- P Y R
					-- print( IsValid( self.Tail ), self.Pilot, IsValid( self.TailWeld ) )
					-- print( -y/20 )
					local rudd = y
					-- if( self.Pilot.MouseAim ) then
						-- rudd = -y-15
					-- end
					-- print( -y )
					
					AnimRudder = math.Clamp( -r/10, -1, 1 )
					AnimElevator = math.Clamp( -rudd/20, -1, 1 )
					AnimAileron = math.Clamp( -p/4, -1, 1  )
					-- print( p )
					
					-- Yaw is right
					-- if( diffY < 25*MouseTrapSize && diffY > -25*MouseTrapSize ) then
						if( self.ControlSurfaces &&(  !IsValid( self.Ailerons[1]) || !IsValid( self.Ailerons[2] ) ) ) then
							-- print("wall")
							diffR = 0.001
							pwr = 0--
							
						end
						
						if( diffP < 15*MouseTrapSize && diffP > -15*MouseTrapSize ) then
							
							if( diffR > 1*MouseTrapSize || diffR < -1*MouseTrapSize ) then
								
								local div = 1
								
								
								self:GetPhysicsObject():AddAngleVelocity( Vector( math.Clamp( -diffR/div, -self.BankForce, self.BankForce ), 0, 0 ) * pwr )
								
							
							
							end
						
						
						-- end
						
					end
					
					if( ma.r > 55 || ma.r < -55 ) then
						
						p = p * 0.1
						
					end
					
					if( diffY > 90 || diffY < -90 ) then
							
						diffP = -diffP
						
					end
					
					
					
					-- if( diffY > -3 && diffY < 3 ) then
						
						-- p = diffP*2.25
						
						
					-- end
					-- self.Pilot:PrintMessage( HUD_PRINTCENTER, math.floor( self:GetAngles().r ) )
					-- if( ( diffP > MouseTrapSize || diffP < -MouseTrapSize ) || ( diffY > MouseTrapSize || diffY < -MouseTrapSize ) ) then
					-- local dir = 1
					
					if( self.ControlSurfaces && !IsValid( self.Elevator ) ) then
						
						y = 0
					
					end
					if( self.ControlSurfaces && !IsValid( self.Rudder ) ) then
						
						r = 0
						
					end
					
					if( self.ControlSurfaces && ( !IsValid( self.Ailerons[1] ) || !IsValid( self.Ailerons[2 ] ) ) ) then
						
						p = 0--
						
					end
					
					if( self.PilotDed ) then
						
						r,p,y =45,0,0
					
					end
					
					 
					local cang = self:GetAngles()
					if( cang.r > 60 ) then	 
						
						-- if( cang.r > 90 && cang.r < 179 ) then 
							-- dir = -1
						-- end
						self:GetPhysicsObject():AddAngleVelocity( Vector(  -self.BankForce*.67, 0, 0 ) )
						
					elseif( cang.r < -60 ) then
						-- if( cang.r < -90 && cang.r > -179 ) then 
							-- dir = -1
						-- end
						self:GetPhysicsObject():AddAngleVelocity( Vector( self.BankForce*.67, 0, 0 ) )
						
					else
					
						self:GetPhysicsObject():AddAngleVelocity( Vector( 1*p*( self.BankForceDivider or 2 ),y * ( self.PitchForceDivider or 1),r*2*( self.YawForceDivider or 0.25) * SteeringPower ) )
					
					end
					-- end
					-- ]]--
					
				end

			else
			
				local right = self:GetAngles().r

				if( ( right > 2 && right < 90 ) || ( right > -90 && right < -2  ) && !( self.Pilot:KeyDown( IN_MOVELEFT ) || self.Pilot:KeyDown( IN_MOVERIGHT )  ) ) then
				
					self:GetPhysicsObject():AddAngleVelocity( Vector( 0, 0, -right/( self.AutoRollYawFactor or 10 ) ) )
					-- self:GetPhysicsObject():AddAngleVelocity( Vector( 0, -right/20, 0 ) )
					
				end
						
			
			end
	


			-- if( IsValid( self.TailWeld ) ) then
	
				local force = self.BoostValue
		
				self:GetPhysicsObject():ApplyForceCenter( Vector( 0,0,-600 * self.Damping * 5 ) )
					
					local propforce = 0.5 
					if( IsValid( self.Wings[1] ) ) then 
						propforce = propforce + 0.25 
					end
					if ( IsValid( self.Wings[2] ) ) then 
						propforce = propforce + 0.25 
					end 
					
					if( self.Propellers ) then
				
						for i=1,#self.Propellers do
						
							if( IsValid( self.Propellers[i] ) && IsValid( self.Propellers[i].Axis ) && !self.Propellers[i].IsBurning ) then
								
								self:GetPhysicsObject():ApplyForceCenter( propforce * self.Propellers[i]:GetForward() * ( force + self.ExtraBoost / 40 ) / #self.Propellers )
								
							end
							
						end
			
					else	
						
						if( IsValid( self.PropellerAxis ) || self.NoPropeller ) then
						
							self:GetPhysicsObject():ApplyForceCenter( propforce * self:GetForward() * ( force + self.ExtraBoost / 40 ) )
						end
						
					end
					
				-- end 
				
			end
			
				
			-- else
				
				

			
			-- end
		
		if( self.PilotDed ) then  self:GetPhysicsObject():ApplyForceCenter( Vector( 0,0,-800 ) * self.Damping ) return end 
		
		local _steerforce = 0  
		
		if( IsValid( self.Wings[1].Weld ) ) then
		
			_steerforce = _steerforce + .5
			
		end 
		
		if( IsValid( self.Wings[2].Weld ) ) then 
		
			_sterforce = _steerforce + .5 
			
		end 
		if( self.CanSteerAtLowVelocity ) then	
			
			if( SteeringPower < .35 && self.CurVelocity > 500 ) then 
				SteeringPower = .35 
			end 
			
		end 
			if( self.Pilot:KeyDown( IN_MOVELEFT) ) then
					
				if( ( self.ControlSurfaces && IsValid( self.Ailerons[2] ) ) || !self.ControlSurfaces ) then
				
					self:GetPhysicsObject():AddAngleVelocity( _steerforce * Vector( -self.BankForce or -365, 0, 0 ) * SteeringPower )
					AnimAileron = 1
				
				end
				
			elseif( self.Pilot:KeyDown( IN_MOVERIGHT ) ) then
				
				if( ( self.ControlSurfaces && IsValid( self.Ailerons[1] ) ) || !self.ControlSurfaces ) then
				
				
					self:GetPhysicsObject():AddAngleVelocity( _steerforce * Vector( self.BankForce or 365, 0, 0 ) * SteeringPower )
					AnimAileron = -1
				
				end
				
			end

		
			if( !IsValid( self.TailWeld ) ) then 
				
				if( self.CurVelocity < 950 ) then 
				
					self:GetPhysicsObject():ApplyForceCenter( Vector( 0,0,-230000 ) )
					
				end 
				
				self:GetPhysicsObject():AddAngleVelocity( VectorRand() * 5 )
			
			end 
			
			if( !IsValid( self.Wings[1].Weld ) && IsValid( self.Wings[2].Weld ) ) then
			
				-- self:GetPhysicsObject():AddAngleVelocity( 20 * Vector( -self.BankForce or -365, 0, 0 ) * SteeringPower )
				-- self.BouncedOnce = true 
				-- self.Destroyed = true 
				
				if( self.CurVelocity < 950 ) then 
					
					self:GetPhysicsObject():ApplyForceCenter( Vector( 0,0,-230000 ) )
					-- self.BoostValue = 0
					
				end 

				self:GetPhysicsObject():AddAngleVelocity( Vector( -105, 0, 0 ) )
				
				self.Wings[2]:GetPhysicsObject():SetDamping( 0,3 )
				-- self:SetPhysDamping( 1, 1 )
				-- print("=?")
				-- self.Wings[2]:GetPhysicsObject():SetPhysicsDamping( 1,1 )
				
			elseif( !IsValid( self.Wings[2].Weld ) && IsValid( self.Wings[1].Weld ) ) then
			-- print("=?")
				-- self:GetPhysicsObject():AddAngleVelocity( 20 * Vector( self.BankForce or 365, 0, 0 ) * SteeringPower )
				-- self.BouncedOnce = true 
				-- self.Destroyed = true 
								
				if( self.CurVelocity < 950 ) then 

					self:GetPhysicsObject():ApplyForceCenter( Vector( 0,0,-230000 ) )
					
				end 
				
				-- self.BoostValue = 0
				-- self:SetPhysDamping( 1, 1 ) 
				-- self.Wings[1]:GetPhysicsObject():SetPhysicsDamping( 1,1 )
				self:GetPhysicsObject():AddAngleVelocity( Vector( 105, 0, 0 ) )
				self.Wings[1]:GetPhysicsObject():SetDamping( 0,3 )
			
			elseif( !IsValid( self.Wings[1].Weld ) && !IsValid( self.Wings[2].Weld ) ) then 
			
				self:SetPhysDamping( 3, 2 )
								
				if( self.CurVelocity < 950 ) then 

					self:GetPhysicsObject():ApplyForceCenter( Vector( 0,0,-230000 ) )
					
				end 
				
			end
			
			if( !IsValid( self.Wings[1].Weld) || !IsValid( self.Wings[2].Weld ) ) then
				
				-- self:GetPhysicsObject():ApplyForceCenter( Vector( 0,0, GetConVarNumber( "sv_gravity") * self:GetPhysicsObject():GetMass() ) )
					-- print("NEURO DEBUG:", !IsValid( self.Wings[1].Weld) , !IsValid( self.Wings[2].Weld ) )
				if( IsValid( self.Wings[1] ) && !IsValid( self.Wings[1].Weld) && !self.LostLeftWing ) then
					self.LostLeftWing = true
					-- local effectdata = EffectData()
					-- effectdata:SetOrigin( self.Wings[1]:GetPos()  )
					-- util.Effect( "microplane_damage", effectdata )
					ParticleEffectAttach( "microplane_damage", PATTACH_ABSORIGIN_FOLLOW, self.Wings[1], 0 )
						
				end
				if(  IsValid( self.Wings[2] ) &&!IsValid( self.Wings[2].Weld) && !self.LostRightWing ) then
					self.LostRightWing = true
					-- local effectdata = EffectData()
					-- effectdata:SetOrigin( self.Wings[1]:GetPos()  )
					-- util.Effect( "microplane_damage", effectdata )
					ParticleEffectAttach( "microplane_damage", PATTACH_ABSORIGIN_FOLLOW, self.Wings[2], 0 )
						
				end
					
					if( self.TailAttachedToWings && IsValid( self.TailWeld ) ) then 
						
						self.TailWeld:Remove()
					
					end 
					
					-- self:SetPhysDamping( 0,0 )
					-- self.Destroyed = true
					
				return
				
			end
			
		end
		
		if( IsValid( self.Tail ) && IsValid( self.Wings[1].Weld ) && IsValid( self.Wings[2].Weld ) ) then
			
			if( self.Pilot.NeuroRudderValue ) then
			
				if( self.AngleCompensation ) then
				
					self:GetPhysicsObject():AddAngleVelocity( self.AngleCompensation )
				
				end
				
				AnimRudder = self.Pilot.NeuroRudderValue
				if( self.CurVelocity > 10 ) then
					
					if( IsValid( self.Rudder ) ) then
						
						local Pwr = SteeringPower
						if( Pwr < 0.3 ) then
						
							Pwr = 0.75
						
						end
						
						-- haram
						self:GetPhysicsObject():ApplyForceOffset( self:GetRight() * ( Pwr * ( ( self.RudderMultiplier or 7  ) * -self.Pilot.NeuroRudderValue ) * 6500), self.Rudder:GetPos() ) 
					
					else
						
						if( !self.ControlSurfaces ) then
						
							self:GetPhysicsObject():AddAngleVelocity( Vector( 0,0, ( self.RudderMultiplier or 7  ) * -self.Pilot.NeuroRudderValue ) )
						
						else
							
							if( self.Rudders && IsValid( self.Rudders[2] ) ) then
								
								self.Rudder = self.Rudders[2]
								self.RudderMultiplier =  self.RudderMultiplier * .65 
							
							end 
								
						end
						
					end
					
				end
				
			end
			
		
			-- print( pitchValue )
			if( IsValid( self.Pilot ) && self.Pilot:KeyDown( IN_FORWARD ) ) then
				
			
				if( IsValid( self.Elevator ) ) then
					local pos = self.Elevator:GetPos()
					local pos2 = self:WorldToLocal( pos )
					pos2.y = 0 -- fixes imbalance on twin-elevator planes like the F-22
					pos2 = self:LocalToWorld( pos2 )
					
					self:GetPhysicsObject():ApplyForceOffset( self:GetUp() * ( pitchValue * SteeringPower * 17500), pos2 ) 
				
				else
					
					if( !self.ControlSurfaces ) then
					
						self:GetPhysicsObject():AddAngleVelocity( Vector( 0, pitchValue or 11, 0 ) * SteeringPower )
					
					end
					
				end
				
				-- self.Tail:GetPhysicsObject():ApplyForceCenter( self.Tail:GetUp() * 50000 )
				AnimElevator = -1
				
			elseif( IsValid( self.Pilot ) && self.Pilot:KeyDown( IN_BACK ) ) then
			
				if( IsValid( self.Elevator ) ) then
					
					self:GetPhysicsObject():ApplyForceOffset( self:GetUp() * ( pitchValue * SteeringPower * -17500), self.Elevator:GetPos() ) 
				
				else
					
					if( !self.ControlSurfaces ) then
					
						self:GetPhysicsObject():AddAngleVelocity( Vector( 0, -pitchValue or -11, 0 ) * SteeringPower )
					
					end
					
				end
				
				-- self:GetPhysicsObject():AddAngleVelocity( Vector( 0, -pitchValue or -11, 0 ) * SteeringPower )
				AnimElevator = 1
			
			-- else
				
				-- AnimElevator = 0
			
			-- end
		
		else
	
			
			-- if( !IsValid( self.TailWeld ) ) then
			
			
		
		end
		
		
		
	end
	
	-- if( IsValid( self.Propeller ) && !IsValid( self.PropellerAxis ) && !self.Propellers && !self.NoPropeller ) then
		
		-- if( self.CurVelocity < 1000 ) then	
			
			-- self:SetPhysDamping( 1.75, self.AngDamping/2 )
		
		-- end
		
	-- end
	
	-- /*
	-- local AnimRudder, AnimAileron, AnimFlaps, AnimElevator = 0,0,0,0
	if( self.ControlSurfaces && IsValid( self.Pilot ) && self.IsFlying ) then
		
		if( self.Fluttering ) then
			
			AnimAileron = math.random(-1,1)
			AnimRudder = math.random(-1,1)
			AnimAileron = math.random( -1,1 )
			
		end
		
		local ma = self:GetAngles() 
		
		if( self.Ailerons ) then
			
			for i=1,#self.Ailerons do
				
				if( IsValid( self.Ailerons[i] ) ) then
					
					local ma = self:GetAngles()
					local angs = self.ControlSurfaces.Ailerons[i].Ang
					
					ma:RotateAroundAxis( self:GetRight(), angs.p )
					ma:RotateAroundAxis( self:GetUp(), angs.y )
					ma:RotateAroundAxis( self:GetForward(), angs.r )
					
					local ail = self.Ailerons[i]
					local ra = ail:GetAngles()
					
					
					local dir = -1
					if( i == 2 || i == 4 || i == 6 ) then
						
						dir = 1
						
					end
					
					ma:RotateAroundAxis( ail:GetRight(), 25*AnimAileron*dir )
					
					ail:SetAngles( LerpAngle( 0.0911, ra, ma ) )
					if( self.ThrustVectoring && IsValid( self.Pilot ) && ( self.Pilot:KeyDown( IN_MOVELEFT ) || self.Pilot:KeyDown(IN_MOVERIGHT))) then 
						
						self.Elevators[i]:SetAngles( LerpAngle( 0.0911, ra, ma ) )
					
					end 
					
				end
				
					
			end
			
		
		
		
		end
		
		if( self.Flaps ) then
		
			for i=1,#self.Flaps do
				
				if( IsValid( self.Flaps[i] ) ) then
					
					local ma = self:GetAngles()
					local angs = self.ControlSurfaces.Flaps[i].Ang
					
					ma:RotateAroundAxis( self:GetRight(), angs.p )
					ma:RotateAroundAxis( self:GetUp(), angs.y )
					ma:RotateAroundAxis( self:GetForward(), angs.r )
					
					local ail = self.Flaps[i]
					local ra = ail:GetAngles()

					
					ma:RotateAroundAxis( ail:GetRight(), 45*AnimFlaps )
					
					ail:SetAngles( LerpAngle( 0.0211, ra, ma ) )
					
				end
				
					
			end
			
		end
		
		if( IsValid( self.Elevator ) ) then
			
			local ra = self.Elevator:GetAngles()
			local map = self:GetAngles()
			map:RotateAroundAxis( self:GetRight(), -32*AnimElevator )
			
			self.Elevator:SetAngles( LerpAngle( 0.0615, ra, map ) )
			if( self.Pilot && !self.Pilot:KeyDown(IN_MOVELEFT ) && !self.Pilot:KeyDown( IN_MOVERIGHT ) && self.Elevators && IsValid( self.Elevators[2] ) ) then 
				
				self.Elevators[2]:SetAngles( LerpAngle( 0.0615, ra, map ) )
				
			end 
				
		
		end
		
		if( IsValid( self.Rudder ) ) then
			
			local ma = self:GetAngles()
			local ra = self.Rudder:GetAngles()
			
			ma:RotateAroundAxis( self:GetUp(), 15*AnimRudder )
			
			if( self.Rudders ) then
				
				for i=1,#self.Rudders do
					
					if( IsValid( self.Rudders[i] ) ) then
						
						ra = self.Rudders[i]:GetAngles()
						local defAng = self.ControlSurfaces.Rudder[i].Ang
						local newAng = self:GetAngles()
						newAng:RotateAroundAxis( self:GetUp(), defAng.y + 15*AnimRudder )
						newAng:RotateAroundAxis( self:GetRight(), defAng.p )
						newAng:RotateAroundAxis( self:GetForward(), defAng.r )
						self.Rudders[i]:SetAngles( LerpAngle( 0.15, ra, newAng  ) )
					
					end 
				
				end 
				
			else
			
				self.Rudder:SetAngles( LerpAngle( 0.15, ra, ma ) )
			
			end
			
		end
	
	
	end
	-- */
	self.LastVelocity = self:GetPhysicsObject():GetVelocity():Length()
	
end

print( "[NeuroPlanes] NeuroAirGlobal.lua loaded!" )