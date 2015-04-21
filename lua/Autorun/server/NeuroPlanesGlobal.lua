--[[ BETA Global plane script ]]--

	
AddCSLuaFile("autorun/client/c_neurochopperbase.lua")
AddCSLuaFile("autorun/client/neuroairglobal.lua")
AddCSLuaFile("autorun/NeuroPlanesMisc.lua")
AddCSLuaFile("autorun/precache.lua")
AddCSLuaFile("autorun/hawxnpc_init.lua")
AddCSLuaFile("autorun/npcinit.lua")

local Meta = FindMetaTable("Entity")

function Meta:NeuroPlanes_DefaultUse( ply )

	if( ply == self.Pilot ) then return end
	
	if ( !self.IsFlying && !IsValid( self.Pilot ) ) then 

		self:GetPhysicsObject():Wake()
		self:GetPhysicsObject():EnableMotion(true)
		self.IsFlying = true
		self.Pilot = ply
		self.Owner = ply
		
		self:SetNetworkedEntity("Pilot", ply )
		
		-- ply:Spectate( OBS_MODE_CHASE  )
		ply:DrawViewModel( false )
		ply:DrawWorldModel( false )
		ply:StripWeapons()
		ply:SetScriptedVehicle( self )
		ply:SetNetworkedBool("InFlight",true)
		ply:SetNetworkedEntity( "Plane", self ) 
		ply:SetNetworkedBool( "isGunner", false )
		ply:SetNetworkedEntity( "ChopperGunnerEnt", self.ChopperGun )
		
		self.Entered = CurTime()
		
	end

end

function MultiplayerCheck()
--[[ MULTIPLAYER PHYSICS TRICK by StarChick
This function checks if you play in multiplayer
then fixes the physics ratio for the entity to
match the one you use in singleplayer.

Need to multiply all forces used by the "MultiplayerPhysicsFix" value.
 ]]--
	if game.SinglePlayer() then
	
		MultiplayerPhysicsFix = 1
		
	else
	
		MultiplayerPhysicsFix = 0.25
		
	end
	
	return MultiplayerPhysicsFix
	
end

function Meta:NeuroJets_CreateCoPilotEquipment()
	print("NeuroJets_CreateCoPilotEquipment")
	
	if( type(self.CoArmament) != "table" ) then
		
		error( "You forgot to specify the CoArmament table in Shared.lua!" )
	
		return
		
	end
	
	--Armament
	local i = 0
	local c = 0
	self.CoFireMode = 1
	self.CoEquipmentNames = {}
	self.CoRocketVisuals = {}
	
	for k,v in pairs( self.CoArmament ) do
		print( "co equipment "..i)
		
		i = i + 1
		self.CoRocketVisuals[i] = ents.Create("prop_physics_override")
		self.CoRocketVisuals[i]:SetModel( v.Mdl )
		self.CoRocketVisuals[i]:SetPos( self:LocalToWorld( v.Pos ) )
		self.CoRocketVisuals[i]:SetAngles( self:GetAngles() + v.Ang )
		self.CoRocketVisuals[i]:SetParent( self )
		self.CoRocketVisuals[i]:SetSolid( SOLID_NONE )
		self.CoRocketVisuals[i].Type = v.Type
		self.CoRocketVisuals[i].PrintName = v.PrintName
		self.CoRocketVisuals[i].Cooldown = v.Cooldown
		self.CoRocketVisuals[i].isFirst = v.isFirst
		self.CoRocketVisuals[i].Identity = i
		self.CoRocketVisuals[i].Class = v.Class
		self.CoRocketVisuals[i]:Spawn()
		self.CoRocketVisuals[i].LastAttack = CurTime()
		
		if ( v.Color != nil ) then
			
			local c = v.Color
			self.CoRocketVisuals[i]:SetColor( Color(  c.r, c.b, c.g, c.a ) )
			if( c.a <= 0 ) then
				
				self.CoRocketVisuals[i]:SetRenderMode( RENDERMODE_TRANSALPHA )
			
			end
		
		end
		
		if ( v.Damage && v.Radius ) then
			
			self.CoRocketVisuals[i].Damage = v.Damage
			self.CoRocketVisuals[i].Radius = v.Radius
		
		end
		
		-- Usuable Equipment
		if ( v.isFirst == true || v.isFirst == nil /* Single Missile*/ ) then
		
			if ( v.Type != "Effect" && v.Type != "Flarepod" ) then
				
				c = c + 1
				self.CoEquipmentNames[c] = {}
				self.CoEquipmentNames[c].Identity = i
				self.CoEquipmentNames[c].Name = v.PrintName
				
			end
			
		end
		
	end
	
	self.CoNumRockets = #self.CoEquipmentNames

end


-- Usage: Specify ENT.CopilotSeatPos as a local vector in Shared.lua
-- Call self:NeuroJets_CreateCoPilotSeat() in Init.lua inside ENT:Initialize()
function Meta:NeuroJets_CreateCoPilotSeat()
	print( "NeuroJets_CreateCoPilotSeat")
	
	if( !self.CopilotSeatPos ) then 
			
		error("You forgot to specify the ENT.CopilotSeatPos variable in Shared.lua!")
		
		return 
		
	end
	
	self.CopilotSeat = ents.Create( "prop_vehicle_prisoner_pod" )
	self.CopilotSeat:SetPos( self:LocalToWorld( self.CopilotSeatPos ) )
	self.CopilotSeat:SetModel( "models/nova/jeep_seat.mdl" )
	self.CopilotSeat:SetKeyValue( "LimitView", "0" )
	self.CopilotSeat:SetKeyValue( "vehiclescript", "scripts/vehicles/prisoner_pod.txt" )
	self.CopilotSeat.HandleAnimation = function( v, p ) return p:SelectWeightedSequence( ACT_GMOD_SIT_ROLLERCOASTER ) end
	self.CopilotSeat:SetAngles( self:GetAngles() + Angle( 0, -90, 0 ) )
	self.CopilotSeat:SetParent( self )
	self.CopilotSeat:SetColor( Color ( 0,0,0,0 ) )
	self.CopilotSeat:SetRenderMode( RENDERMODE_TRANSALPHA )
	self.CopilotSeat:Spawn()
	--self.CopilotSeat.IsChopperGunnerSeat = true
	self.CopilotSeat.IsHelicopterCoPilotSeat = true
	
	-- Add weapons
	self:NeuroJets_CreateCoPilotEquipment()
	
end


function Meta:NeuroJets_DefaultUseStuff( ply, caller )
	
	if( ply == self.Pilot ) then return end

	if ( !self.IsFlying && !IsValid( self.Pilot ) ) then 
	
		self:GetPhysicsObject():Wake()
		self:GetPhysicsObject():EnableMotion( true )
		self.IsFlying = true
		self.Pilot = ply
		self.Owner = ply

		ply:EnterVehicle( self.PilotSeat )
		self.ThirdCam:SetNWString("owner", ply:Nick())
		-- ply:SetDrivingEntity( self )
		ply.OriginalFOV = ply:GetFOV()
		ply:SetHealth( self.HealthVal )
		--ply:SetEyeAngles( self:GetAngles() + Angle( 0, -90, 0 ) )
		ply:SetNetworkedBool( "InFlight",true )
		ply:SetNetworkedEntity( "Plane", self ) 
		self:SetNetworkedEntity("Pilot", ply )
		self.LastUseKeyDown = CurTime()
	
	else
	
		if( IsValid( self.CopilotSeat ) ) then
			
			self.CoPilot = ply
			self.CoPilot:EnterVehicle( self.CopilotSeat )
			self.CoPilot:SetNetworkedBool( "InFlight",true )
			self.CoPilot:SetNetworkedEntity( "Plane", self )
		
		end
		
		-- if ( self.Pilot:KeyDown( IN_USE ) && self.LastUseKeyDown + 0.5 <= CurTime() ) then
		
			-- self:NeuroJets_Eject()
			-- self.LastUseKeyDown = CurTime()	
			
		-- end	

    end

	if ( self.ThrusterPos ) or ( self.ReactorPos ) then
	
		if !(self.ThrusterPos) then
		
			self.ThrusterPos = self.ReactorPos
			
		end
		
		if !( self.FlameTrailR ) then
		
			self.FlameTrailR = ents.Create( "env_spritetrail" )
			self.FlameTrailR:SetParent( self )	
			self.FlameTrailR:SetPos( self:GetPos() + self:GetForward() * self.ThrusterPos[1].x + self:GetRight() * self.ThrusterPos[1].y + self:GetUp() * self.ThrusterPos[1].z  )
			self.FlameTrailR:SetAngles( self:GetAngles() )
			self.FlameTrailR:SetKeyValue( "lifetime", 0.05 )
			self.FlameTrailR:SetKeyValue( "startwidth", 128 )
			self.FlameTrailR:SetKeyValue( "endwidth", 0 )
			self.FlameTrailR:SetKeyValue( "spritename", "sprites/afterburner.vmt" )
			self.FlameTrailR:SetKeyValue( "renderamt", 255 )
			self.FlameTrailR:SetKeyValue( "rendercolor", "255 175 0" )
			self.FlameTrailR:SetKeyValue( "rendermode", 5 )
			self.FlameTrailR:SetKeyValue( "HDRColorScale", .75 )
			self.FlameTrailR:Spawn()
			
		end
	
		if !( self.FlameTrailL ) && (self.ThrusterPos[2]) then
		
			self.FlameTrailL = ents.Create( "env_spritetrail" )
			self.FlameTrailL:SetParent( self )	
			self.FlameTrailL:SetPos( self:GetPos() + self:GetForward() * self.ThrusterPos[2].x + self:GetRight() * self.ThrusterPos[2].y + self:GetUp() * self.ThrusterPos[2].z  )
			self.FlameTrailL:SetAngles( self:GetAngles() )
			self.FlameTrailL:SetKeyValue( "lifetime", 0.05 )
			self.FlameTrailL:SetKeyValue( "startwidth", 128 )
			self.FlameTrailL:SetKeyValue( "endwidth", 0 )
			self.FlameTrailL:SetKeyValue( "spritename", "sprites/afterburner.vmt" )
			self.FlameTrailL:SetKeyValue( "renderamt", 255 )
			self.FlameTrailL:SetKeyValue( "rendercolor", "255 175 0" )
			self.FlameTrailL:SetKeyValue( "rendermode", 5 )
			self.FlameTrailL:SetKeyValue( "HDRColorScale", .75 )
			self.FlameTrailL:Spawn()

		end
	
	end
	
end

function Meta:NeuroJets_Eject( ply )

	if ( !IsValid( self.Pilot ) ) then
	
		return		
		
	end
	
	self:RemoveRotorwash()
	
	if( self.EngineMux ) then
		
		for i=1,#self.EngineMux do
			
			self.EngineMux[i]:FadeOut(5)
		
		end

	end
	
	self.Pilot:SetNetworkedBool( "InFlight", false )
	self.Pilot:SetNetworkedBool( "DrawDesignator", false )
	self.Pilot:SetNetworkedEntity( "Plane", NULL ) 
	self.Pilot:SetScriptedVehicle( NULL )
	self:SetNetworkedEntity("Pilot", self )
	self.Pilot:SetNetworkedBool( "isGunner", false )
	self.Pilot:SetHealth( 100 )
	
	local r = self:GetAngles().r
	
	if ( r < 90 ) and ( r >- 90 ) then
	
		self.Pilot:SetPos(  self:LocalToWorld( Vector( 223, 0, 115+100 )  ))
		
	else
	
		self.Pilot:SetPos(  self:GetPos() + Vector(0,0,150)  )
		
	end

	self.Pilot:SetAngles( Angle( 0, self:GetAngles().y,0 ) )
	self.Owner = NULL
	-- self.Pilot:SetDrivingEntity( NULL )
	
	-- self.Speed = 0
	self.IsFlying = false
	-- self:SetLocalVelocity(Vector(0,0,0))
	
	self:EjectPilot()
	self:NeuroJets_EjectPilot()
	
	self.Pilot = NULL
	
	
	
end

function Meta:NeuroJets_EjectPilot( ply )

	if ( IsValid( self.Pilot ) ) then
	
		-- self.Pilot:SetViewEntity( self.Pilot )
		self.Pilot:ExitVehicle()
		-- self.Pilot:Spawn()
		-- self:EjectPilot()
		
		for i=1,#self.EngineMux do
			
			self.EngineMux[i]:Stop()
			
		end

		self:SetNetworkedBool("NA_Started", false )
		
	else
	
		self:NeuroJets_Eject()
		
		return	
	
	end
	
end

function Meta:NeuroJets_Init( ply )

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
	
	self.HealthVal = self.InitialHealth
	
	self:SetNetworkedInt( "health",self.HealthVal)
	self:SetNetworkedInt( "HudOffset", self.CrosshairOffset )
	self:SetNetworkedInt( "MaxHealth",self.InitialHealth)
	self:SetNetworkedInt( "MaxSpeed",self.MaxVelocity)

	self.LastPrimaryAttack = CurTime()
	self.LastSecondaryAttack = CurTime()
	self.LastFireModeChange = CurTime()
	self.LastRadarScan = CurTime()
	self.LastFlare = CurTime()
	self.LastLaserUpdate = CurTime()
	self.LastUseKeyDown = CurTime()

	-- Misc
	self:SetModel( self.Model )	
	self:PhysicsInit( SOLID_VPHYSICS )
	self:SetMoveType( MOVETYPE_VPHYSICS )
	self:SetSolid( SOLID_VPHYSICS )

	self.PhysObj = self:GetPhysicsObject()
	
	if ( self.PhysObj:IsValid() ) then
	
		self.PhysObj:Wake()
		self.PhysObj:SetMass(10000)
		
	end
	if !IsValid(self.SeatPos) then
		self.SeatPos = self:GetPos()+self:GetUp()*100
	end
	self.PilotSeat = ents.Create( "prop_vehicle_prisoner_pod" )
	self.PilotSeat:SetPos( self:LocalToWorld( self.SeatPos ) )
	self.PilotSeat:SetModel( "models/nova/jeep_seat.mdl" )
	self.PilotSeat:SetKeyValue( "vehiclescript", "scripts/vehicles/prisoner_pod.txt" )
	self.PilotSeat.HandleAnimation = function( v, p ) return p:SelectWeightedSequence( ACT_DRIVE_AIRBOAT ) end
	self.PilotSeat:SetAngles( self:GetAngles() + Angle( 0, -90, 0 ) )
	self.PilotSeat:SetParent( self )
	self.PilotSeat:SetKeyValue( "LimitView", "0" )
	self.PilotSeat:SetColor( Color ( 0,0,0,0 ) )
	self.PilotSeat:SetRenderMode( RENDERMODE_TRANSALPHA )
	self.PilotSeat:Spawn()

	if !IsValid(self.GunPos) then
		self.GunPos = self:GetPos()+self:GetForward()*500+self:GetUp()*100
	end
	self.Weapon = ents.Create("prop_physics_override")
	self.Weapon:SetModel(  self.MachineGunModel )
	self.Weapon:SetPos( self:GetPos() + self:GetForward() * self.GunPos.x + self:GetRight() * self.GunPos.y + self:GetUp() * self.GunPos.z  )
	self.Weapon:SetAngles( self:GetAngles() )
	self.Weapon:SetSolid( SOLID_NONE )
	self.Weapon:SetParent( self )
	self.Weapon:SetColor( Color( 0,0,0,0) )
	self.Weapon:SetRenderMode( RENDERMODE_TRANSALPHA )
	self.Weapon:Spawn()

	
	self.EngineMux = {}
	if !IsValid( self.esound) then
	self.esound = {}
	self.esound[1] = "vehicles/Airboat/fan_blade_fullthrottle_loop1.wav"
	self.esound[2] = "vehicles/fast_windloop1.wav"
	self.esound[3] = "vehicles/Airboat/fan_motor_fullthrottle_loop1.wav"
	end
	
	for i=1, #self.esound do
	
		self.EngineMux[i] = CreateSound( self, self.esound[i] )		
		self.EngineMux[i]:SetSoundLevel(135)	
		self.EngineMux[i]:Stop()
		
	end
	
	self.SoundPitch = 80
	self.SonicBoomMux = CreateSound( self, "LockOn/SonicBoom.mp3" )
	self.SonicBoomMux:SetSoundLevel(150)	
	self.SonicBoomMux:Stop()	
	self.SuperSonicMux = CreateSound( self, "LockOn/Supersonic.mp3" )
	self.SuperSonicMux:SetSoundLevel(140)	
	self.SuperSonicMux:Stop()	

	--Armament
	local i = 0
	local c = 0
	self.FireMode = 1
	self.EquipmentNames = {}
	self.RocketVisuals = {}
	if !IsValid(self.Armament) then self.Armament={} end
	
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
		
		if ( v.Color != nil ) then
			
			local c = v.Color
			self.RocketVisuals[i]:SetColor( Color ( c.r, c.b, c.g, c.a ) )
			
			if( c.a <= 0 ) then
				
				self.RocketVisuals[i]:SetRenderMode( RENDERMODE_TRANSALPHA )
				
			end
		
		end
		
		if ( v.Damage && v.Radius ) then
			
			self.RocketVisuals[i].Damage = v.Damage
			self.RocketVisuals[i].Radius = v.Radius
		
		end
		
		-- Usuable Equipment
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

	self.Trails = {}
	
	-- Proper copilot, controls as many weapons as you care to specify in the CoArmament table.
	
	-- print( self.CopilotSeatPos )
	if( self.CopilotSeatPos ) then
		
		self:NeuroJets_CreateCoPilotSeat()
	
	end
	
	--Third view camera
	self.ThirdCam = ents.Create("prop_physics")	 
	self.ThirdCam:SetModel("models/dav0r/camera.mdl")
	self.ThirdCam:SetColor( Color( 255,255,255,0 ) )
	self.ThirdCam:SetRenderMode( RENDERMODE_TRANSALPHA )
	self.ThirdCam:SetPos( self:GetPos() + self:GetForward() * -self.CamDist + self:GetUp() * self.CamUp )
	self.ThirdCam:SetAngles( self:GetAngles() )
	self.ThirdCam:SetParent( self )
	self.ThirdCam:Spawn()
	self.ThirdCam:SetSolid(SOLID_NONE)
	
	if self.HasCockpit then	
		self.Cockpit = ents.Create("sent_cockpit")
		self.Cockpit:SetModel( self.CockpitModel )
		self.Cockpit:SetPos( self:LocalToWorld(self.CockpitPos) )
		self.Cockpit:SetParent( self )
		self.Cockpit:SetSkin( self:GetSkin())
		self.Cockpit:SetAngles( self:GetAngles() )
		self.Cockpit:Spawn()
	end
	
end

function Meta:DrawClientsideCockpit() //Toggle between cockpit/plane models. -- Need to move this to clientside
	 if self.HasCockpit && IsValid(self.Cockpit) then
		self.Cockpit:SetSkin( self:GetSkin())
			if  (GetConVarNumber("jet_cockpitview") == 1 ) && IsValid(self.Pilot) && (self.Pilot:GetViewEntity()==self.Pilot) then
			self.Cockpit:SetNWBool( "Hide", false )
			self.Pilot:SetNWBool( "ShowCockpit", true )
			else
			self.Cockpit:SetNWBool( "Hide", true )
				if IsValid(self.Pilot) then
				self.Pilot:SetNWBool( "ShowCockpit", false )
				end
			end			
	
	 end
end

function Meta:NeuroJets_Remove()

	if ( IsValid( self.Pilot ) ) then

		for i=1,#self.esound do
		
			self.EngineMux[i]:Stop()	
		
		end	

		self:NeuroJets_Eject()
	
	end
	
	self:Remove()

end

function Meta:NeuroJets_DamageScript(dmginfo)

	if ( self.Destroyed ) then
		
		return

	end

	self:TakePhysicsDamage(dmginfo)
	
	self.HealthVal = self.HealthVal - dmginfo:GetDamage()
	self:SetNetworkedInt("health",self.HealthVal)
	
	if ( self.HealthVal < self.InitialHealth * 0.15 )  && !self.Burning  then
	
		self.Burning = true
		for i=1,#self.ReactorPos do
		
			local f = ents.Create("env_fire_trail")
			f:SetPos( self:LocalToWorld(self.ReactorPos[i]) )
			f:SetParent( self )
			f:Spawn()
			
		end
		
	end
	
	if ( self.HealthVal <= 0 ) then
	
		self.Destroyed = true
		self.PhysObj:EnableGravity(true)
		self.PhysObj:EnableDrag(true)
		self.PhysObj:SetMass(2000)
		
        util.BlastDamage( self.Pilot, dmginfo:GetInflictor(), self:GetPos(), 1628, 1000 ) 
		
		if( IsValid( self.Wingman ) ) then
		
			self.Wingman:DeathFX()
		
		end
		
		self:Remove()
		
	end
	
end

function Meta:NeuroJets_Collision( data, physobj )

	if ( data.Speed > self.MaxVelocity * 0.2 && data.DeltaTime > 0.2 ) then 
		
		self:NeuroJets_Eject()
		
		self:DeathFX()
		
	end
	
end

function Meta:CreateWingmanNPC()

	self.Pilot:PrintMessage( HUD_PRINTCENTER, "Friendly Wingman Inbound to your assistance" )
	self:EmitSound("LockOn/Voices/CopyRejoin.mp3",511,100)
							
	self.Wingman = ents.Create("npc_wingman")
	self.Wingman:SetModel( self:GetModel() )
	self.Wingman.Armament = self.Armament
	self.Wingman:SetPos( self:GetPos() + self:GetForward() * -3000 + self:GetRight()*2300 )
	self.Wingman:SetAngles( self:GetAngles() )
	self.Wingman:SetSkin( self:GetSkin() )
	self.Wingman.Armament = self.Armament
	self.Wingman:Spawn()
	self.Wingman.Owner = self
	self.Wingman.CycleTarget = self
	self.Wingman.Target = self
	self.Wingman:SetSkin( self:GetSkin() ) 
	self.Wingman:SetNetworkedEntity( "Guardian_Object", self.Pilot )
	
end

function Meta:CycleThroughCopilotWeaponsList()
	
	self.CoLastFireModeChange = CurTime()
	self.CoFireMode = self:IncrementFireVar( self.CoFireMode, self.CoNumRockets, 1 )
	
	local wep = self.CoEquipmentNames[ self.CoFireMode ]
	local wepData = self.CoRocketVisuals[ wep.Identity ]
	 
	local pilot = self.CoPilot
	if( !IsValid( pilot ) ) then return end
	
	if( wepData.Type == "Singlelock" && !self:GetNetworkedBool("DrawDesignator", false ) ) then
		
		pilot:SetNetworkedBool( "DrawDesignator", true )
		//self:SetNetworkedInt( "NeuroPlanes_AutolockonRadius", wepData.Radius or 4096 )
		
	elseif( wepData.Type != "Singlelock" && self:GetNetworkedBool("DrawDesignator", true ) ) then
		
		pilot:SetNetworkedBool( "DrawDesignator", false )
	
	end

	if ( wep.Name != nil ) then
	
		pilot:PrintMessage( HUD_PRINTCENTER, ""..wep.Name )
		--self:SetNetworkedString("NeuroPlanes_ActiveWeapon", wep.Name)
		
	end
	
end

function Meta:NeuroJets_CoPilotKeybinds( ply )
	
	if ( !IsValid( ply ) ) then
	
		return
		
	end

	if ( self.CoLastAttackKeyDown == nil ) then self.CoLastAttackKeyDown = CurTime() end
	if ( self.CoLastFireModeChange  == nil ) then self.CoLastFireModeChange  = CurTime() end
	if ( self.CoLastPrimaryAttack  == nil ) then self.CoLastPrimaryAttack  = CurTime() end
	
	if( ply:KeyDown( IN_SPEED ) && ply:KeyDown( IN_USE ) ) then
			
		self:NeuroPlanes_EjectPlayer( ply )
			
		return
		
	end
	
	// Clear Target 
	if ( ply:KeyDown( IN_WALK ) && IsValid( self.Target ) ) then
		
		self:ClearTarget( )
		ply:PrintMessage( HUD_PRINTCENTER, "Target Released" )
		
	end
	
	// Attack
	if (ply:KeyDown( IN_ATTACK ) ) then
	
		if ( self.LastPrimaryAttack + self.PrimaryCooldown <= CurTime() ) then
			
			self:PrimaryAttack()
			
		end
		
	end

	if ( ply:KeyDown( IN_ATTACK2 ) && self.CoLastAttackKeyDown + 0.5 < CurTime() ) then
		
		self.CoLastAttackKeyDown = CurTime()

		local id = self.EquipmentNames[ self.CoFireMode ].Identity
		local wep = self.RocketVisuals[ id ]
		
		if ( wep.LastAttack + wep.Cooldown <= CurTime() ) then
		
			self:NeuroJets_FireRobot( wep, id, ply )
			
		else
		

			local cd = math.ceil( ( wep.LastAttack + wep.Cooldown ) - CurTime() ) 
			
			if ( cd > 2 ) then
			
				self.CoPilot:PrintMessage( HUD_PRINTTALK, self.PrintName..": "..wep.PrintName.." ready in "..tostring( cd ).. " seconds." )	
			
			end
			
		end

	end
	
	// Firemode 
	if ( self.CoPilot:KeyDown( IN_RELOAD ) && self.CoLastFireModeChange + 0.5 <= CurTime() ) then
			
		self:CycleThroughCopilotWeaponsList()
		
	end

end

function Meta:NeuroJets_Systems()

	if( !self.LastRadarScan ) then
	
		 self.LastRadarScan = 0
		 
	end
	
	self:NeuroPlanes_LaserTrackerUpdate()
	
	if( self.LastRadarScan != nil ) then
	
		if ( self.LastRadarScan + 1 <= CurTime() ) then

			self.LastRadarScan = CurTime()
			
			for k,v in pairs( ents.GetAll() ) do
				
				if ( ( IsValid( v ) && IsValid( v.Target ) && v.Target == self ) || ( v.Target == self.Pilot && string.find(string.lower(v:GetClass()),"neuro") == nil ) ) then
				
					v:SetNetworkedEntity("Target", v.Target )
				
				end
			
			end
			
		end
	
	else
		
		self.LastRadarScan = CurTime()
	
	end


	-- Ejection Situations.
	if ( self:WaterLevel() > 1 ) then
	
		self:NeuroJets_Eject()
		
	end
				
	if( IsValid( self.Wingman ) ) then
		
		if( self.Wingman.Target == self ) then
			
			if( IsValid( self.LastAttacker ) ) then
				
				self.Wingman.Target = self.LastAttacker
				
			end
			
			self.Wingman.Speed = self.Speed - 100
		
		end
		
		if( IsValid( self.LastAttacker ) && self.LastAttacked + 2.5 <= CurTime() ) then	
			
			if( self.LastAttacked + 15 <= CurTime() ) then
					
				self.LastAttacker = NULL
				
			end
			
			if( IsValid( self.Wingman.Target ) && self:GetPos():Distance( self.Wingman.Target:GetPos() ) > 10000 ) then	
				
				self.Wingman.Target = self
				
			end
		
		elseif( !IsValid( self.LastAttacker ) ) then
			
			self.Wingman.Target = self
		
		end
		
	end
	--Targeting systems
	
	local trace,tr = {},{}
	tr.start = self:GetPos() + self:GetUp() * self.CrosshairOffset + self:GetForward() * 512
	tr.endpos = tr.start + self:GetUp() * self.CrosshairOffset + self:GetForward() * 20000
    tr.filter = { self.CoPilot, self.Pilot, self, self.Weapon, self.PilotSeat, self.CopilotSeat }
	tr.mask = MASK_SOLID
	trace = util.TraceEntity( tr, self )
	
	local e = trace.Entity
	
	local logic = ( IsValid( e ) && ( e:IsNPC() || e:IsPlayer() || e:IsVehicle() || type(e) == "CSENT_vehicle" || string.find( e:GetClass(), "prop_vehicle" ) ) )
	
	if ( logic && !IsValid( self.Target ) && e:GetOwner() != self && e:GetOwner() != self.Pilot && e:GetClass() != self:GetClass() ) then
		
		self:SetTarget( e )
		
	end
	
	--Key binding
	self:NeuroPlanes_CycleThroughJetKeyBinds()
	
	if( !IsValid( self.Pilot ) ) then return end
	
	if( self.Pilot:KeyDown( IN_DUCK ) && self.Speed > self.MaxVelocity * 0.6 && !IsValid( self.Wingman ) ) then
		
		self:CreateWingmanNPC()
		
		return 
		
	end
	
	if ( self.LastLaserUpdate + 0.4 <= CurTime() ) then
		
		self.LastLaserUpdate = CurTime()
		
		if ( IsValid( self.LaserGuided ) ) then
			
			self:SetNetworkedBool( "DrawTracker",true )
			
		else
			
			self:SetNetworkedBool( "DrawTracker",false )
			
		end
		
	end

-- local function ToggleLights( ply ) // This is a test for bind "F" key to toggle planes' lights.
 
    -- local cmd = ply:GetCurrentCommand()
 
    -- if cmd:KeyDown( 88 ) then
        -- ply:ChatPrint( "Lights On!" )
    -- end
 
-- end
-- hook.Add( "Move", "IsForwardKeyDownExample", IsForwardKeyDown )

--Toggling 3rd person view

	if  ( GetConVarNumber("jet_arcademode") == 0 ) then
	self:ThirdPersonView()
	else
	self:ArcadeThirdPersonView()
	end
end

function Meta:NeuroJets_FireRobot( wep, id, ply )
	
	if ( !wep || !id || !IsValid( ply ) ) then
		
		return
		
	end
	
	local pos = wep:GetPos()
	local pilot = ply
	
	if ( wep.isFirst == true ) then
		
		pos = self.RocketVisuals[ id + math.random( 0, 1 ) ]:GetPos()
		
	end
	
	if ( wep.Type == "Homing" && !self.Target ) then
		
		pilot:PrintMessage( HUD_PRINTCENTER, "No Target - Launching Dumbfire" )
		
		
		//return
		
	end
	
	if ( wep.Type == "Laser" && IsValid( self.LaserGuided ) ) then
		
		pilot:PrintMessage( HUD_PRINTCENTER, "You're already controlling a Laser Guided rocket." )
		
		return
	
	end
	
	if ( wep.Type == "Pod" ) then
		
	
		wep.LastAttack = CurTime()
		
		local v = 8
		
		if( wep.BurstSize ) then
			
			v = wep.BurstSize
			
		end
		
		for i = 1,v do
		
			if ( wep.isFirst == true ) then
				
				timer.Simple( i / 4.8, 
				function(a,b,c)
				
					if( type(self.RocketVisuals) == "table" && IsValid( self.RocketVisuals[id + 1 ] ) ) then
						
						self:RocketBarrage( self.RocketVisuals[id + 1 ] ) 
				
					end
				
				end )
				
			end
			
			timer.Simple( i / 5, 
			function(a,b,c)

				self:RocketBarrage( wep ) 
			
			end )
			
		end

		return
		
	end
	
	local r = ents.Create( wep.Class )
	r:SetPos( pos )
	r:SetOwner( self )
	r:SetPhysicsAttacker( pilot )
	r.Target = self.Target
	r.Pointer = pilot
	r:SetModel( wep:GetModel() )
	r:Spawn()
	r:Fire( "Kill", "", 40 )
	r:SetAngles( wep:GetAngles() )
	r.Owner = pilot
	
	if( wep.SubType && wep.SubType == "Cluster" ) then
		
		r.ShouldCluster = true	
	
	end
		
	if( wep.Type == "Torpedo" ) then
		
		r:SetModel( "models/torpedo_float.mdl" )

	end

	if ( r:GetPhysicsObject() != nil ) then
		
		r:GetPhysicsObject():SetVelocity( self:GetVelocity() )
		
	end
	
	
	if( wep.LaunchSound ) then
		
		r:EmitSound( wep.LaunchSound, 511, math.random( 90, 110 ) )
	
	else
		
		r:EmitSound( "weapons/rpg/rocketfire1.wav", 511, 80 )
	
	end
	
	
	if ( wep.Type == "Laser" ) then
		
		self.LaserGuided = r
		r.Damage = wep.Damage
		r.Radius = wep.Radius
		
		self:SetNetworkedEntity("NeuroPlanes_LaserGuided", r )
		pilot:PrintMessage( HUD_PRINTCENTER,  "Press Attack To Detonate" )
		
	end
	
	if( wep.Type == "Singlelock" ) then

		r.Damage = wep.Damage
		r.Radius = wep.Radius
		r.ImpactPoint = self:NeuroJets_LockOnGuided( pilot )

		pilot:PrintMessage( HUD_PRINTCENTER,  "Target Locked - Launching" )

	end
	
	if ( wep.Type == "Homing" || wep.Type == "Swarm" ) then
		
		self:ClearTarget()
	
	end
		
	wep.LastAttack = CurTime()
	
end

function Meta:NeuroJets_LockOnGuided( pilot )
				
		// Auto lock-on
		local dist = 2048
		local tempd = tempd or 0
		local pos
		local tr, trace = {},{}
			tr.start = self:GetPos() + self:GetForward() * 600 + self:GetUp() * 600
			tr.endpos = tr.start + pilot:GetAimVector() * 36000
			tr.filter = { self, pilot }
			tr.mask = MASK_SOLID
		trace = util.TraceLine( tr )
		
		if( trace.Hit ) then
		
			for k,v in pairs( ents.GetAll() ) do 
				
				if( ( v:IsVehicle() || v:IsNPC() || v:IsPlayer() || v.HealthVal != nil ) && v != self && v != pilot ) then
					
					tempd = trace.HitPos:Distance( v:GetPos() )
					
					if ( tempd < dist ) then
						
						dist = tempd
						pos = v:GetPos()
						
					end
				
				end
			
			end

		end
				
	if( !pos ) then
	
		pos = trace.HitPos

	end
	
	return pos
	
end

local MFix 		= 0
local ang 		= Angle( 0,0,0 )
local velocity 	= 0
local angvel 	= Angle( 0,0,0 )
local pLimit 	= 0
local Lift 		= 0
local Drag 		= 0
local Throttle 	= 0
local Manu 		= 0
local RPush = 0
local ZForce = 0

function Meta:NeuroJets_MovementScript(ply)
	
	self.VolPitch = math.Clamp( math.floor( self:GetVelocity():Length() / 20 + 40 ), 0, 200 )
	
	if( self.IsFlying && self.Pitch && self.EngineMux ) then
	
		for i = 1,#self.EngineMux do
		
			self.EngineMux[i]:ChangePitch( self.VolPitch, 0.01 )
			
		end
		
	end

	-- self:DrawClientsideCockpit()	//I put this here to render any model by default -StarChick

	local MFix 		= MultiplayerCheck()
	local ang 		= self:GetAngles()
	local velocity 	= math.ceil(self:GetVelocity():Length())
	local angvel 	= self:GetPhysicsObject():GetAngleVelocity()
	local pLimit 	= math.cos(  angvel.x / 1000 )
	local Lift 		= ( 0.045 * velocity * velocity ) * ( self.NA_LiftMultiplier or 1.2 )
	local Drag 		= -0.1 * velocity * velocity / 2
	local Throttle 	= self.Speed/self.MaxVelocity
	local Manu 		= 3.75+self.Manoeuvrability/20
	local Steerability = self.NA_SteerabilityMultiplier * ( 1.0 * math.Clamp( velocity, 0, self.NA_PhysicsUpperSpeedLimit ) / self.NA_PhysicsUpperSpeedLimit   ) 
	
	if( self.CopilotSeatPos ) then

		self.CoPilot = self.CopilotSeat:GetDriver()

		if( IsValid( self.CoPilot ) ) then
			
			self:NeuroJets_CoPilotKeybinds( self.CoPilot )
			
		end
	
	end
	
	
	if ( self.IsFlying ) && IsValid(self.Pilot) then

		
		-- self.Pilot:PrintMessage( HUD_PRINTCENTER, 
		-- Steerability.." ("..tostring( math.floor(angvel.x).." "..math.floor(angvel.y).." "..math.floor(angvel.x) )..") - ".. math.floor( self.Speed ).." ( "..self.Pitch.." )" )
		
		--Sound code
		self.SoundPitch = math.Clamp( math.floor( self.Speed*100/self.MaxVelocity + 40 ), 0, 200 )
		
		for i = 1,#self.EngineMux do
		
			self.EngineMux[i]:ChangePitch( self.SoundPitch, 0.01 )
			
		end
		
		self.EngineMux[1]:PlayEx( 1.0, self.SoundPitch )

		local soundspeed = 2000 -- normally 767 * 352/15 --  speed of sound in units = mph * (mph to units) 
		local toggleBarrierSDN
		
		if ( velocity > soundspeed ) &&( velocity < soundspeed + 50) then
		
			toggleBarrierSDN = true	
			
		end	
		
		if ( toggleBarrierSDN ) then
		
			toggleBarrierSDN = false
		-- --	self.SonicBoomMux:Play()	
		-- --	self.SonicBoomMux:Stop()
			self:EmitSound( "LockOn/SonicBoom.mp3", 510, 100 )
			 
		end
		
		if ( velocity > soundspeed ) then
		
			self.SuperSonicMux:Play()	
			
		else
		
			self.SuperSonicMux:Stop()	
			
		end
		
		--Physics
		self:GetPhysicsObject():Wake()
						
		if( !self.LastUseKeyDown ) then
		
			self.LastUseKeyDown = CurTime()	
			
		end

		if ( self.Pilot:KeyDown( IN_FORWARD )  && velocity > 550  ) then
		
			self.Pitch = Lerp( self.NA_LerpPitch, self.Pitch, self.NA_PitchDown )  * Steerability
			
		elseif ( self.Pilot:KeyDown( IN_BACK )  && velocity > 550 ) then
		
			self.Pitch = Lerp( self.NA_LerpPitch, self.Pitch, -self.NA_PitchUp )  * Steerability
			
		else
			
			self.Pitch = 0
			
		end
		
		
		if( ang.r > 5 || ang.r < 5 ) then
			
			self.Yaw = -ang.r * self.NA_YawRollMultiplierStraight
			
		end
		
		-- print( math.floor( self.Pitch), math.floor( self.Yaw ) )
		
		if ( self.Pilot:KeyDown( IN_DUCK ) && self.Pilot:KeyDown( IN_MOVELEFT ) ) then
		
			self.Yaw = Lerp( self.NA_LerpYaw, self.Yaw, self.NA_Yaw )
			
			
		elseif ( self.Pilot:KeyDown( IN_DUCK ) && self.Pilot:KeyDown( IN_MOVERIGHT ) ) then
		
			self.Yaw = Lerp( self.NA_LerpYaw, self.Yaw, -self.NA_Yaw )
			
		
		else
		
			if( velocity > 1000 ) then
			
				self.Yaw = -ang.r * self.NA_YawRollMultiplierFast
				-- self.Pitch = -ang.p * 2.5
			
			else
			
				self.Yaw = 0
			
			end
			
			
		end
		
		if ( !self.Pilot:KeyDown( IN_DUCK ) && self.Pilot:KeyDown( IN_MOVERIGHT ) && velocity > 950 ) then
		
			self.Roll = Lerp( self.NA_LerpRoll, self.Roll, self.NA_Roll ) * Steerability
			
		elseif ( !self.Pilot:KeyDown( IN_DUCK ) && self.Pilot:KeyDown( IN_MOVELEFT ) && velocity > 950  ) then
		
			self.Roll = Lerp( self.NA_LerpRoll, self.Roll, -self.NA_Roll ) * Steerability
			
		else
		
			self.Roll = 0
			
		end


		
		local Boost
		
		if ( self.Pilot:KeyDown( IN_SPEED ) ) then
		
			self.Speed = 1 + self.Speed * 1.125
			
			if( self.HasAfterburner != false ) then
			
				self.EngineMux[3]:PlayEx( 500 , self.SoundPitch )
				Boost = 500
			-- ParticleEffect("afterburner01_once",self:LocalToWorld(self.ReactorPos[1]) ,self:GetAngles(),self)
			-- ParticleEffect("afterburner01_once",self:LocalToWorld(self.ReactorPos[2]) ,self:GetAngles(),self)
			-- ParticleEffectAttach("afterburner01_once",PATTACH_ABSORIGIN_FOLLOW ,self.ThrusterProp[1],0)
			-- ParticleEffectAttach("afterburner01_once",PATTACH_ABSORIGIN_FOLLOW ,self.ThrusterProp[2],0)
			else
			
				self:StopParticles()
				
				Boost = 150//50	
				
			end

		elseif ( self.Pilot:KeyDown( IN_WALK ) ) then
		
			self:StopParticles()			
		
			if( self.HasAirbrakes != false ) then
				
				if (self.Speed > 0.3*self.MaxVelocity) then
				
					self.Speed = self.Speed * 0.98
					
				else
				
					self.Speed = math.Approach( self.Speed, 0, 50 )
					
				end	
				
				self.Drift = self.Drift + 0.5
				Boost = 0
				
			end
			
		else
		
			self:StopParticles()					
			self.Drift = self.Drift - 0.06
			self.EngineMux[3]:FadeOut(0.5)
			-- self.EngineMux[4]:PlayEx( 500 , self.SoundPitch )
			-- self.EngineMux[4]:Stop()
			Boost = 0
			
		end
	
		self.Speed = math.Clamp( self.Speed, self.MinVelocity, self.MaxVelocity + Boost ) 
		self.Drift = math.Clamp( self.Drift, 1, 2 )
		self:SetNetworkedInt( "Throttle",self.Speed)

		local xG
		
		if ( ang.p < -45 ) then
		
			self.maxG = self.maxG*1.025-- + 1
			xG = self.NA_MaxGForce
			
		elseif ( ang.p > 45 ) then
		
			self.maxG = self.maxG - 1
			xG = self.NA_MinGForce
			
		else
		
			self.maxG = self.maxG - 5
			xG = self.NA_MaxGForce
			
		end
		
		self.maxG = math.Clamp( self.maxG, xG, self.NA_GForceCeiling )
-- /*
		-- self.Pitch = math.Clamp( self.Pitch, -10000, 10000 )
		-- self.Yaw = math.Clamp( self.Yaw, -10000, 10000 )
		-- self.Roll = math.Clamp( self.Roll, -10000, 10000 )
-- */

		self:GetPhysicsObject():ApplyForceCenter( self:GetUp() * Lift * pLimit *MFix)
		self:GetPhysicsObject():ApplyForceCenter( self:GetForward() * Drag *MFix)
		
		if (ang.p > -10) and (ang.p < 10) and (ang.r < 10) and (ang.r > -10) then
		
			self:GetPhysicsObject():ApplyForceOffset( self:GetUp() * math.cos(  ang.p/10 ) * - velocity/10*MFix, self:GetForward()*-10000 )
			
		end

	else
	
		self:GetPhysicsObject():ApplyForceOffset( self:GetUp()*-200*MFix, self:GetForward()*10000 )	
		self.EngineMux[1]:Stop()	
		self.EngineMux[3]:Stop()
		
	end
				
	local ZForce = - math.exp(5*-self.Speed/self.MaxVelocity)*2

	local RPush = 0 //self:GetAngles().r * 2.1
	
	self:GetPhysicsObject():ApplyForceOffset( self:GetUp()*self.Roll*1.25*(0.5+Throttle)*(Manu+0.25)*MFix, self:GetRight()*-13000 )
	self:GetPhysicsObject():ApplyForceOffset( self:GetUp()*-self.Roll*1.25*(0.5+Throttle)*(Manu+0.25)*MFix, self:GetRight()*13000 )
	self:GetPhysicsObject():ApplyForceOffset( self:GetRight()* ( ( self.Yaw * MFix ) - ( RPush ) ), self:GetForward()*-10000 )
	self:GetPhysicsObject():ApplyForceOffset( self:GetRight()*-( ( self.Yaw * MFix ) - ( RPush ) ), self:GetForward()*10000 )
	self:GetPhysicsObject():ApplyForceOffset( self:GetUp()*self.Pitch*self.Drift*Manu*MFix, self:GetForward()*-17000 )
	self:GetPhysicsObject():ApplyForceOffset( self:GetUp()*-self.Pitch*self.Drift/100*Manu*MFix, self:GetForward()*17000 )

	self:GetPhysicsObject():ApplyForceCenter( self:GetForward() * 500*self.Speed * pLimit *( 120 - self.maxG )/100 *MFix)
	
--	self:GetPhysicsObject():ApplyForceCenter( self:GetUp() * -ZForce*1000 *MFix)
	self:GetPhysicsObject():ApplyForceCenter( self:GetUp() * -ZForce*10000*self.Drift *MFix)

	--Crash animation until plane is removed
	
	self:WingTrails( ang.r, 1 )
	
	if ( self.Destroyed ) then 
		
		local effectdata = EffectData()
		effectdata:SetOrigin( self:GetPos() + self:GetRight() * math.random(-62,62) + self:GetForward() * math.random(-62,62)  )
		util.Effect( "immolate", effectdata )
		self.DeathTimer = self.DeathTimer + 1
		
		local DeathFactor = math.random(0,7)
		local DeathFactorBoolean = math.random(-1,1)

		self:GetPhysicsObject():ApplyForceOffset( self:GetUp()*-DeathFactor*100*MFix, self:GetForward()*-10000*(1-math.abs(DeathFactorBoolean))+ self:GetRight()*10000*DeathFactorBoolean )
		
	end		

	if( self.Destroyed && self.Speed > 500 ) then
		
		self:GetPhysicsObject():ApplyForceCenter( self:GetForward() * ( 2500 * self.Speed ) )
		
	
	end
	
	return true  
	
end


function Meta:NeuroJets_PrimaryAttack( nuzzle, tracer, fx )

	if ( !IsValid( self.Pilot ) ) then
		
		return
		
	end
	
 	local bullet = {} 
 	bullet.Num 		= 1
 	bullet.Src 		= self.Weapon:GetPos() + self.Weapon:GetForward() * self.MuzzleOffset
 	bullet.Dir 		= self.Weapon:GetAngles():Forward()			-- Dir of bullet 
 	bullet.Spread 	= Vector( .019, .019, .019 )				-- Aim Cone 
 	bullet.Tracer	= 1											-- Show a tracer on every x bullets  
 	bullet.Force	= 0						 					-- Amount of force to give to phys objects 
 	bullet.Damage	= 0
 	bullet.AmmoType = "Ar2" 
 	bullet.TracerName 	= "AirboatGunHeavyTracer" 
 	bullet.Callback    = function ( a, b, c )
							
							local e = EffectData()
							e:SetOrigin(b.HitPos)
							e:SetNormal(b.HitNormal)
							e:SetScale( 4.5 )
							util.Effect( fx, e)
							
							if( IsValid( b.HitEntity ) ) then
								
								b:Ignite( 5,15 )
							
							end
							
							util.BlastDamage( self.Pilot, self.Pilot, b.HitPos, 250, 10 )
							
							return { damage = true, effects = DoDefaultEffect } 
							
						end 
 	
	self.Weapon:FireBullets( bullet )
	
	self.Weapon:EmitSound( "A10fart.mp3", 510, 98 )
	
	local effectdata = EffectData()
	effectdata:SetStart( self.Weapon:GetPos() + self:GetForward() * 100 )
	effectdata:SetOrigin( self.Weapon:GetPos() + self:GetForward() * 100 )
	effectdata:SetEntity( self.Weapon )
	effectdata:SetNormal( self:GetForward() )
	util.Effect( "A10_muzzlesmoke", effectdata )  

	self.LastPrimaryAttack = CurTime()

end

--[[FUTURE FEATURES
Displaying caracteristics:

- Power (Speed).
- Defense (Health).
- Attack (Armement).
- Mobility (Manoeuvrability).
- Stability (MaxG, Max angle, etc...).

3rd person view (Code below)
]]--


function Meta:ThirdPersonView()

	local pos = self:GetPos()
	local ang = self:GetAngles()
	local pang = self.Pilot:EyeAngles()
	local angspd = self:GetPhysicsObject():GetAngleVelocity()
	
/*	if ( self.Pilot:GetViewEntity():GetClass() == self.Pilot ) then
		self.Pilot:SetNetworkedBool("Using1stPersonView", true)
	else
		self.Pilot:SetNetworkedBool("Using1stPersonView", false)
	end
if  ( self.Pilot:GetNetworkedBool("Using1stPersonView") )	then	
print(self.Pilot:GetViewEntity():GetClass())
end	

*/

	if ( self.Pilot:GetViewEntity():GetClass() == gmod_cameraprop ) then
		self.Pilot:SetNetworkedBool("UsingCamera", true)
	else
		self.Pilot:SetNetworkedBool("UsingCamera", false)
	end
	
	if  (GetConVarNumber("jet_cockpitview") == 0 ) then
		if not( self.Pilot:GetViewEntity():GetClass() == gmod_cameraprop ) then
		self.ThirdCam:SetNWString("owner", self.Pilot:Nick())
		self.ThirdCam:SetLocalPos( Vector( -self.CamDist, 2*angspd.z, self.CamUp-2*angspd.y) )
		-- self.Pilot:SetViewEntity( self.ThirdCam )
		self.Pilot:SetEyeAngles(Angle(0,180,0))
	--	self.Pilot:SetMoveType(MOVETYPE_NOCLIP)	
		end 

		if  ( GetConVarNumber("jet_arcadeview") == 1 ) then
		self.ThirdCam:SetAngles( Angle(ang.p, ang.y, 0) )
		else
		self.ThirdCam:SetAngles( ang )		
		end
	else

	if ( self.Pilot:GetViewEntity() == self.ThirdCam ) then
	-- self.Pilot:SetViewEntity( self.Pilot )
	self.Pilot:SetEyeAngles(Angle(0,90,0))
	end
	
	self.ThirdCam:SetNWString("owner", self)
	end	
		
end


print( "[NeuroPlanes] NeuroPlanesGlobal.lua loaded!" )