
CreateConVar("neurotec_funstuff", 1,  FCVAR_NOTIFY )


local CarrierPos = {}
local CarrierAng = {}
local YamatoPos = {}
local YamatoAng = {}

-- gm_tropics_v3
YamatoPos["gm_tropics_v3"] = Vector( 6260, 12657, -13050 )
YamatoAng["gm_tropics_v3"] = Angle( 0, 180, 0 ) 
CarrierPos["gm_tropics_v3"] = Vector( -11423, -11062, -13300 )
CarrierAng["gm_tropics_v3"] = Angle( 0, 125, 0 )

CarrierPos["nodex_island_v1q"] = Vector( 12340, -10195, -4900 )
CarrierAng["nodex_island_v1q"] = Angle( 0, 90, 0 )
YamatoPos["nodex_island_v1q"] = Vector( -2600, 14175, -4500 )
YamatoAng["nodex_island_v1q"] = Angle( 0, 0, 0 )


CarrierPos["harbor2ocean_navalb3"] = Vector( -8185, -2043, -500 )
CarrierAng["harbor2ocean_navalb3"] = Angle( 0, 0, 0 )
YamatoPos["harbor2ocean_navalb3"] = Vector( 8918, 6435, -150 )
YamatoAng["harbor2ocean_navalb3"] = Angle( 0, 0, 0 )

--setpos 8918.635742 6435.407227 -413.891357;setang 7.325978 3.780312 0.000000


-- setpos 2834.776855 -12674.277344 -561.359619;setang 29.203671 -7.290217 0.000000
-- setpos -2606.597168 14175.375000 -4544.970215;setang 0.792037 -14.382090 0.000000
-- setpos 12340.275391 -10195.792969 -5298.720215;setang 26.730045 -88.272087 0.000000

hook.Add("PlayerSpawn", "Carrier_Spawn_Hook", function( ply ) 
	
	if ( GetConVarNumber("neurotec_funstuff", 0 ) > 1 ) then
	
		local Spawnpoints = {}
		local count = 0
		
		for k,v in pairs( ents.GetAll() ) do
			
			if( v.IsBigFatCarrier && v.SpawnPoint  ) then
				
				Spawnpoints[#Spawnpoints+1] = v
				count = count + 1
			end
			
		end
			
		if( count > 0 ) then
		
			local Ship = Spawnpoints[math.random(1,#Spawnpoints)]
			ply:SetPos( Ship.SpawnPoint )
			ply:SetTeam( Ship.Team )
			
		end
		
	end
	
end )

hook.Add("InitPostEntity", "SpawnCarrier_Spawnpoint", function() 
	

	local  map = game.GetMap()
	local pos,ang

	if( CarrierPos[map] != nil ) then
		
		pos = CarrierPos[map]
		ang = CarrierAng[map]
		
		local b = ents.Create([[prop_physics_override]]) 
		b:SetPos( pos )
		b:SetModel( [[models/Nirrti/BF2/Vehicles/Sea/uss wasp.mdl]] ) 
		b:SetAngles( ang ) 
		b:Spawn() 
		b:SetMoveType( MOVETYPE_NONE )
		b:GetPhysicsObject():EnableMotion( false )
		b:GetPhysicsObject():SetMass( 5000000 )
		b.IsFlying = true // hurr
		b.IsBigFatCarrier = true
		b.SpawnPoint = b:LocalToWorld( Vector( -1568 + math.random( -64, 64 ), -10 + math.random( -64,64 ), 1210 ) )
		b.Team = 1
		
		local Defenses = {
							{ 	 	
								Class = "npc_typhoon",									
								Pos = Vector( -3702, -939, 1202 ), 						
								Ang = Angle( 0, 0, 0)													
							};
							{ 	 	
								Class = "npc_phalanx",									
								Pos = Vector( -2080, 933, 1202 ), 						
								Ang = Angle( 0, 0, 0) 								
							};				
							-- { 
								-- Class = "npc_phalanx",									
								-- Pos = Vector( -406, -264, 1600 ), 						
								-- Ang = Angle( 0, 0, 0),											
							-- };
							{  	
								Class = "npc_typhoon",									
								Pos = Vector( 1600, -482, 1340 ), 						
								Ang = Angle( 0, 0, 0) 														
							};
							{  	
								Class = "sent_hamina_p",									
								Pos = Vector( -2011, 2000, 450 ), 						
								Ang = Angle( 0, 0, 0) 														
							};
							{  	
								Class = "sent_hamina_p",									
								Pos = Vector( 2700, 2000, 450 ), 						
								Ang = Angle( 0, 0, 0) 														
							};
							-- {  	
								-- Class = "sent_hamina_p",									
								-- Pos = Vector( -4678, -449, 1199 ), 						
								-- Ang = Angle( 0, 22, 0) 														
							-- };

						}
	
		for k,v in pairs( Defenses ) do
		
			local d = ents.Create( v.Class )
			d:SetPos( b:LocalToWorld( v.Pos ) )
			d:SetAngles( b:GetAngles() + v.Ang )
			d:Spawn()
			-- d:SetParent( b )
			d.Owner = b
			
		end
	
		
	end
	
	if( YamatoPos[map] != nil ) then 
	
		pos = YamatoPos[map]
		ang = YamatoAng[map]
		local b = ents.Create([[sent_yamato]]) 
		b:SetPos( pos )
		b:SetAngles( ang ) 
		b:Spawn() 
		b:SetMoveType( MOVETYPE_NONE )
		b:GetPhysicsObject():EnableMotion( false )
		b:GetPhysicsObject():SetMass( 5000000 )
		b.IsFlying = true // hurr
		b.IsBigFatCarrier = true
		-- b.SpawnPoint = b:LocalToWorld( Vector( 1165 + math.random( -64, 64 ), -550 + math.random( -64,64 ), 512 ) )
		b.Team = 2
		
	end
	

end ) 

concommand.Add("jet_spawncarrier", function( ply, cmd, arg )
	
	if( !ply:IsAdmin() ) then return end
	
	if( !arg ) then return end
	
	local b = ents.Create([[prop_physics_override]]) 
	b:SetPos( Vector( arg[1], arg[2], arg[3] ) )
	b:SetModel( [[models/Nirrti/BF2/Vehicles/Sea/uss wasp.mdl]] ) 
	b:SetAngles( Angle( 0,arg[4],0 ) ) 
	b:Spawn() 
	b:SetMoveType( MOVETYPE_NONE )
	b:GetPhysicsObject():EnableMotion( false )
	b:GetPhysicsObject():SetMass( 5000000 )
	b.IsFlying = true // hurr
	b.IsBigFatCarrier = true
	
	-- local stuff = { 
					-- //{ Pos = Vector( -3733, -912, 1220 ), Ent = "sent_ah-64_apache_p", Ang = -45 };
					-- //{ Pos = Vector( -2046, 876, 1220 ), Ent = "sent_ah-64_apache_p", Ang = -45 };
					-- { Pos = Vector( -2520, -452, 1210 ), Ent = "sent_harrier_p", Ang = 45  };
					-- { Pos = Vector( -3000, -452, 1210 ), Ent = "sent_harrier_p", Ang = 45  };
					
				-- }
	
	-- for k,v in pairs( stuff ) do
		
		-- local c = ents.Create( v.Ent )
		-- c:SetPos( b:LocalToWorld( v.Pos ) )
		-- c:SetAngles( b:GetAngles() + Angle( 0, v.Ang, 0 ) )
		-- c:Spawn()
		-- c.Owner = self
		-- //c:GetPhysicsObject():Sleep()
		
	-- end
	
end )

concommand.Add("jet_spawncarrier_boss", function( ply, cmd, arg )
	
	if( !ply:IsAdmin() ) then return end
	
	if( !arg ) then return end
	
	local b = ents.Create("sent_LHD-1_p") 
	b:SetPos( Vector( arg[1], arg[2], arg[3] ) )
	b:SetAngles( Angle( 0,arg[4],0 ) ) 
	b:Spawn() 
	b:SetMoveType( MOVETYPE_NONE )
	b:GetPhysicsObject():EnableMotion( false )
	b:GetPhysicsObject():SetMass( 5000000 )
	

end )

if( table.HasValue( hook.GetTable(), "NeuroPlanes_ChatCommands" ) ) then
	
	hook.Remove( "PlayerSay", "NeuroPlanes_ChatCommands" )
	
end

local function FindPlayerByPartialName( ply, name )

	if( name == nil ) then return ply end
	if( string.len( name ) <= 0 ) then return ply end
	
	for k,v in pairs( player.GetAll() ) do
													
		if( string.find( string.lower( v:GetName() ), string.lower( name ) ) != nil ) then

			return v
			
		end
		
	end
	
	
	return ply
	
end


// Chat commands by Hoffa :D
hook.Add( "PlayerSay", "NeuroPlanes_ChatCommands", function( ply, txt, team )
	
	if ( GetConVarNumber("neurotec_funstuff", 0 ) == 0 ) then return end
	
	local said = string.Explode( " ", txt )
	
	local cmds = { 
					{ 	
						Var	= "!lock", 
						Callback 	= 	function( ply, txt, team ) 
											if( !ply:IsAdmin() ) then return end
											local Target = FindPlayerByPartialName(ply,  string.Explode( " ", txt )[2] )
											
											if( IsValid( Target ) ) then
												
												local plane = ply:GetScriptedVehicle()
												plane.Target = Target
												ply:PrintMessage( HUD_PRINTTALK, "Locked On "..Target:GetName() )
												
											end
											
										end 
					}; 
					{ 
						Var = "!sk", 
						Callback = function( ply, txt, team )	
										
										if( !ply:IsAdmin() ) then return end
										local Target = FindPlayerByPartialName( ply,  string.Explode( " ", txt )[2] )
											
										if( IsValid( Target ) ) then
											
											Target:KillSilent()
											Target:PrintMessage( HUD_PRINTTALK, "You have been assassinated. Stop being a douche." )
												
										
										end
										
									end 
						
						
					}; 	
					{ 
						Var = "!minify", 
						Callback = function( ply, txt, team )	
										
										-- if true then return end 
										if( !ply:IsAdmin() ) then return end
										local Target = FindPlayerByPartialName( ply,  string.Explode( " ", txt )[2] )
											
										if( IsValid( Target ) ) then
											
											local mins,maxs =  Vector( -16, -16, 0 ), Vector( 16, 16, 72 )
											local dmins, dmaxs = Vector( -16, -16, 0 ), Vector( 16, 16, 36 )
											-- local mi,ma = Target:GetRotatedAABB( mins, maxs )
											mins = mins * .25 
											maxs = maxs * .25
											Target:ResetHull()
											Target:SetHull( mins, maxs )
											-- Target:SetDuckHull( dmins * .125, dmaxs * .125 )
											Target:SetNWBool("NeuroMiniMe",true)
											Target:SetModelScale( .135, 1 )
											Target:SetRunSpeed( 400 * .5 ) 
											Target:SetWalkSpeed( 200 * .5 )
											-- Target:SetStepSize( 10 )
											-- Target:Spectate( OBS_MODE_CHASE )
											
											
											
										end
										
									end 
						
						
					}; 
					{ 
						Var = "!bigify", 
						Callback = function( ply, txt, team )	
										-- if true then return end 
										if( !ply:IsAdmin() ) then return end
										local Target = FindPlayerByPartialName( ply,  string.Explode( " ", txt )[2] )
											
										if( IsValid( Target ) ) then
											
											local mins,maxs =  Vector( -16, -16, 0 ), Vector( 16, 16, 72 )
											local dmins, dmaxs = Vector( -16, -16, 0 ), Vector( 16, 16, 36 )
											-- local mi,ma = Target:GetRotatedAABB( mins, maxs )
											-- mins = mins * .125 
											-- maxs = maxs * .125 
											Target:ResetHull()
											Target:SetHull( mins, maxs )
											-- Target:SetDuckHull( dmins, dmaxs )
											Target:SetNWBool("NeuroMiniMe",false )
											Target:SetModelScale( 1, 1 )
											Target:SetRunSpeed( 400 ) 
											Target:SetWalkSpeed( 200 )
											Target:SetStepSize( 18 )
											
											
										end
										
									end 
						
						
					}; 
					{ 
						Var = "!nuke", 
						Callback = function( ply, txt, team )	
										
										if( !ply:IsAdmin() ) then return end
										local Target = FindPlayerByPartialName( ply, string.Explode( " ", txt )[2] )
										
										
										if( IsValid( Target ) ) then
											
											local tr, trace = {},{}
											tr.start = Target:GetPos()
											tr.endpos = tr.start + Vector( 0,0,35000 )
											tr.filter = { ply, Target }
											tr.mask = MASK_SOLID
											trace = util.TraceLine( tr )
											
											local n = ents.Create("sent_neurotec_nuke")
											n:SetPos( trace.HitPos - Vector( 0,0,512 ) )
											n:SetAngles( Angle( 90, 0, 0 ) )
											n:Spawn()
											n:SetVelocity( Vector( 0,0,-25000 ) )
											n.Owner = ply
											n:SetOwner( ply )
											n:Use( ply, ply, 0, 0  )
											
										
										end
										
									end 
						
						
					};
					{ 
						Var = "!bignuke", 
						Callback = function( ply, txt, team )	
										
										if( !ply:IsAdmin() ) then return end
										local Target = FindPlayerByPartialName( ply, string.Explode( " ", txt )[2] )
										
										
										if( IsValid( Target ) ) then
											
											local tr, trace = {},{}
											tr.start = Target:GetPos()
											tr.endpos = tr.start + Vector( 0,0,35000 )
											tr.filter = { ply, Target }
											tr.mask = MASK_SOLID
											trace = util.TraceLine( tr )
											
											local n = ents.Create("sent_neurotec_taepodong")
											n:SetPos( trace.HitPos - Vector( 0,0,512 ) )
											n:SetAngles( Angle( 90, 0, 0 ) )
											n:Spawn()
											n:SetVelocity( Vector( 0,0,-25000 ) )
											n.Owner = ply
											n:SetOwner( ply )
											n:Use( ply, ply, 0, 0  )
											
										
										end
										
									end 
						
						
					};
					{
					Var = "!boost",
					Callback = function( ply, txt, team ) 
						
						if( !ply:IsAdmin() ) then return end
						local Target = FindPlayerByPartialName( ply, string.Explode( " ", txt )[2] )
						
						if( IsValid( Target ) ) then
							
							Target:SetVelocity( Target:GetAimVector() * 500000 )
							
						end
					
					end
					 
					};
					{
						Var = "!minefield",
						Callback =  function( ply, txt, team )
						
										if( !ply:IsAdmin() ) then return end
										local Target = FindPlayerByPartialName( ply, string.Explode( " ", txt )[2] )
										
											if( IsValid( Target ) ) then
												
												
												Target:PrintMessage( HUD_PRINTTALK, "A Wild Minefield Appears!" )
												for i=1,50 do
													
													local rnd = Vector( math.random(-1024,1024), math.random(-1024,1024), 128 )
													
													local tr,trace = {},{}
													tr.start = Target:GetPos() + rnd
													tr.endpos = tr.start + Vector( 0,0, -2024 )
													trace = util.TraceLine( tr )
													
													if( trace.Hit ) then
														
														local types = { "sent_bouncingbetty", "sent_land_mine" }
														local mine = ents.Create( types[ math.random( 1, #types ) ] ) 
														mine:SetPos( trace.HitPos - trace.HitNormal * 2.1 )
														mine:SetAngles( Angle( 0,0, 0 ) )--( trace.HitPos - trace.HitNormal ):Angle() )
														mine:Spawn()
														mine.Owner = ply
														-- mine.Active = true
														mine:SetOwner( ply )
														
														
													end
												
												
												end
												
					
											end
									end
					};					
					{
						Var = "!crash",
						Callback =  function( ply, txt, team )
						
										if( !ply:IsAdmin() ) then return end
										local Target = FindPlayerByPartialName( ply, string.Explode( " ", txt )[2] )
										
										if( IsValid( Target ) ) then
											
											local veh = Target:GetScriptedVehicle()
											if( IsValid( veh ) ) then
												
												veh.HealthVal = 0
												veh.Destroyed = true
												veh.IsBurning = true
												Target:SetHealth( 1 )
												
												-- if( math.random( 1, 2 ) == 2 ) then
													
													-- veh:NeuroPlanes_EjectionSeat()
												
												-- end
												
											end
										
										end
											
									end
									
					};
					{
						Var = "!view",
						Callback =  function( ply, txt, team )
						
										-- if( !ply:IsAdmin() ) then return end
										local Target = FindPlayerByPartialName( ply, string.Explode( " ", txt )[2] )
										
										if( IsValid( Target ) ) then
											
											local veh = Target:GetScriptedVehicle()
											if( IsValid( veh ) ) then
												
												ply._isSpectating = true 
												ply._lastViewPos = ply:GetPos() 
												ply:Spectate( OBS_MODE_CHASE )
												ply:SpectateEntity( veh )
												ply:StripWeapons()
												
												
											end
										
										end
											
									end
									
					};
										{
						Var = "!unview",
						Callback =  function( ply, txt, team )
										
										
										if( ply._isSpectating ) then 
											
											ply._isSpectating = false 
												
											ply:UnSpectate()
											ply:Spawn()
											if( ply._lastViewPos ) then	
												
												ply:SetPos( ply._lastViewPos )
											
											end 
											
										end 
										
									end
									
					};
					
					{
					Var = "!crashtodesktop",
					Callback =  function( ply, txt, team )
					
									if( !ply:IsSuperAdmin() ) then ply:PrintMessage( HUD_PRINTCENTER, "NOPE" ) return end
									local Target = FindPlayerByPartialName( ply, string.Explode( " ", txt )[2] )
									
									if( IsValid( Target ) ) then
										
										Target:DeathFX()
									
									end
										
								end
									
					};
					{
						Var = "!bring",
						Callback = function( ply, txt, team )
							
							if( ply:IsAdmin() ) then
								
								local Target = FindPlayerByPartialName( ply, string.Explode( " ", txt )[2] )
								Target:SetPos( ply:GetPos() + ply:GetForward() * 72 + ply:GetUp() * 16 )
								
							end
								
							
						end
					};
					{
						Var = "!launch",
						Callback = function( ply, txt, team )
									
										if( ply:IsAdmin() || ply:IsBot() ) then
											
											local Target = FindPlayerByPartialName( ply, string.Explode( " ", txt )[2] )
											local types = { "sent_Spitfire_p", "sent_yf12a_p", "sent_f-15active_p" }
											local plane = ents.Create(types[math.random(1,#types)])
											plane:SetPos( Target:GetPos() + Vector( 0,0,1000 + math.random( 0,2000 ) ) )
											plane:SetAngles( Angle( math.random( -60, 0 ), math.random(0,360), 180 ) )
											plane:Spawn()
											plane:Use( Target, Target,0,0 )
											-- ply:EnterVehicle( plane )
											plane.Speed = 9999999
											plane.Stalling = true
											plane.Destroyed = true
											plane.Burning = true
											-- plane.DeathTimer = 0
											
											if( IsValid( plane.Propeller ) ) then
											
												plane.Propeller:GetPhysicsObject():AddAngleVelocity( Vector( 100, 0, 0 ) )
												plane:GetPhysicsObject():AddAngleVelocity( Vector( 200, 0, 0 ) )
											
											end
											
											if( math.random( 1,10 ) == 2 ) then
												
												timer.Simple( 1.75, function() plane:NeuroPlanes_EjectPlayer( Target ) end )
											
											end
											
											plane.HealthVal = 0
											plane.HoverVal = -1000
											
											Target:PrintMessage( HUD_PRINTCENTER, "Bye bye.." )
										
										end
										
									end
						};
						
						-- // Template
						{
						Var = "!tp",
						Callback = function( ply, txt, team )
									
										if( ply:IsAdmin() || ply:IsBot() ) then
											
											ply:SetPos( ply:GetEyeTrace().HitPos + Vector( 0,0,32 ) )
											
										end
										
									end
									
						};							
						{
						Var = "!topic",
						Callback = function( ply, txt, team )
										
										
										ply:PrintMessage( HUD_PRINTTALK, "NeuroTec Vehicles Addon Pack" )
										ply:PrintMessage( HUD_PRINTTALK, "www.facepunch.com/threads/1160981" )
										ply:PrintMessage( HUD_PRINTTALK, "Copy from console or the chatbox" )
										ply:ConCommand("neuro_motd")
									end
									
						};
						{						
						Var = "!bolt",
						Callback = function( ply, txt, team ) 
					
							if( ply:IsAdmin() || ply:IsBot() ) then
								
								local tr = ply:GetEyeTrace()
								local Target = FindPlayerByPartialName( ply, string.Explode( " ", txt )[2] )
								local pos = Target:GetPos()
								
								if( Target == ply ) then pos = tr.HitPos end
								
								
								local _end = ents.Create("info_target")
								_end:SetPos(pos)
								_end:Fire("kill","",4)
								_end:Spawn()
								_end:SetName("ENDING__".._end:EntIndex())
							
								local start = ents.Create("info_target")
								start:SetPos(pos + Vector(0,0,6000))
								start:Spawn()
								start:Fire("kill","",4)
								start:SetName("STARTING__"..start:EntIndex())
								 

								local beam = ents.Create("env_beam")
								beam:SetPhysicsAttacker( ply )
								beam:SetOwner( ply )
								beam:SetKeyValue("texture","sprites/bluelaser1")
								beam:SetKeyValue("rendercolor","255 155 250")
								beam:SetKeyValue("rendermode","9")
								beam:SetKeyValue("BoltWidth","45")
								beam:SetKeyValue("NoiseAmplitude","5")
								beam:SetKeyValue("damage","5550")
								beam:SetKeyValue("life","0.4")
								beam:SetKeyValue("LightningStart",start:GetName())
								beam:SetKeyValue("LightningEnd",_end:GetName())
								beam:SetKeyValue("spawnflags","32")
								beam:SetKeyValue("StrikeTime","0.1")
								beam:Spawn()
								beam:Activate()
								beam:Fire("StrikeOnce","",0)
								beam:Fire("Kill","",2)
								beam:SetOwner( ply )
								
								-- if( Target != ply ) then
								
									util.BlastDamage( ply, ply, pos, 32, 1337552 )
								
								-- end
								
								local effectdata = EffectData()
								effectdata:SetOrigin( pos )
								effectdata:SetNormal( Target:GetUp() )
								effectdata:SetMagnitude( 24 )
								effectdata:SetScale( 1 )
								effectdata:SetRadius( 48 )
								util.Effect( "Sparks", effectdata )
								
								local effectdata = EffectData()
								effectdata:SetOrigin( pos + Vector(0,0,6000))
								effectdata:SetNormal( Target:GetUp() )
								effectdata:SetMagnitude( 24 )
								effectdata:SetScale(4 )
								effectdata:SetRadius( 48 )
								util.Effect( "FlakSmoke", effectdata )

								local physboom = ents.Create("env_physexplosion")
								physboom:SetPos(pos)
								physboom:SetKeyValue("Magnitude","505")
								physboom:SetKeyValue("radius","128")
								physboom:SetKeyValue("spawnflags","1")
								physboom:Spawn()
								physboom:Fire("explode","",0)
								physboom:Fire("kill","",5)
								physboom:SetOwner( ply )
							
								local	explosion = ents.Create("env_explosion")
								explosion:SetPos(pos)
								explosion:SetKeyValue("iMagnitude","32")
								-- explosion:SetKeyValue("Radius","512")
								-- explosion:SetKeyValue("Force","512")
								explosion:Spawn()
								explosion:Fire("explode","",0)
								explosion:SetOwner( ply )

								local	glowage = ents.Create("env_lightglow")
								glowage:SetPos(pos)
								glowage:SetKeyValue("rendercolor","255 255 255")
								glowage:SetKeyValue("VerticalGlowSize","16")
								glowage:SetKeyValue("HorizontalGlowSize","16")
								glowage:SetKeyValue("MinDist","0")
								glowage:SetKeyValue("MaxDist","4096")
								glowage:Spawn()
								glowage:Fire("kill","",5)
								Target:EmitSound( "ambient/energy/zap9.wav", 511, 100 )
							
							end
							
						end 
						};
					
						{
						Var = "!use",
						Callback = function( ply, txt, team )
									
										if( ply:IsAdmin() || ply:IsBot() ) then
										
											local tr = ply:GetEyeTrace()
											local Target = FindPlayerByPartialName( ply, string.Explode( " ", txt )[2] )
											
											if( tr.Hit && tr.Entity ) then
												
												if( type( tr.Entity.Use ) != "function" ) then return end
												
												tr.Entity:Use( Target, Target, 0, 0 )
											
											end
											
										end
										
									end
									
						};					
						{
						Var = "!join",
						Callback = function( ply, txt, team )
					
										if( ply:IsAdmin() || ply:IsBot() ) then
											
											local Target = NULL
											local SecondTarget = NULL
											
											if( #string.Explode( " ", txt ) > 1 ) then
												
												Target = FindPlayerByPartialName( ply, string.Explode( " ", txt )[2] )
												
											end
											
											if(  #string.Explode( " ", txt ) > 2 ) then
											
												SecondTarget = FindPlayerByPartialName( ply, string.Explode( " ", txt )[3] )
											
											end
											
											if( SecondTarget && SecondTarget != ply ) then
												
												local v = Target:GetScriptedVehicle()
												
												if( IsValid( v ) ) then
													
													v:Use( SecondTarget, v )
													
												end
											
											else
												
												if( IsValid( Target ) && IsValid( ply:GetScriptedVehicle() ) ) then
													
													ply:GetScriptedVehicle():Use( Target, Target, 0, 0 )
													
												end
												
											end
											
										end
										
									end
									
						};							
						-- {
						-- Var = "!stuck",
						-- Callback = function( ply, txt, team )
										
										-- for i=1,15 do
											
											-- local rnd = VectorRand() * 128
											-- local tr,trace = {},{}
											-- tr.start = ply:GetPos() + rnd 
											-- tr.endpos = ply:GetPos() + rnd + Vector( 0,0,-256 )
											-- tr.filter = ply
											-- tr.mask = MASK_SOLID
											
											-- if( trace.HitWorld ) then
												
												-- ply:SetPos( trace.HitPos + trace.HitNormal * 16 )
												
												-- break
												
											-- end
										
										-- end
										
									-- end
						-- };
						
						{
						Var = "!template",
						Callback = function( ply, txt, team )
										
										ply:PrintMessage( HUD_PRINTTALK, "Template Command :D (does nothing)" )
										
										
									end
									
						};

						{
						Var = "!eject",
						Callback = function( ply, txt, team )
							
							local Target = ply
							
							if( ply:IsAdmin() ) then
								
								Target = FindPlayerByPartialName( ply, string.Explode( " ", txt )[2] )
							
							end
							
							if( IsValid( Target:GetVehicle() ) ) then return end
							if( !Target:Alive() ) then return end
							
							Target:ExitVehicle()
							
							local f1 = EffectData()
							f1:SetOrigin(Target:GetPos())
							util.Effect("immolate",f1)
							local f2 = EffectData()
							f2:SetOrigin(Target:GetPos())
							util.Effect("Explosion",f2)
							
							local ejectionseat = ents.Create( "prop_vehicle_prisoner_pod" )
							ejectionseat:SetPos( Target:GetPos() + Target:GetUp() * 128 )
							ejectionseat:SetModel( "models/hawx/misc/eject seat.mdl" )
							ejectionseat:SetKeyValue( "vehiclescript", "scripts/vehicles/prisoner_pod.txt" )
							ejectionseat:SetKeyValue( "limitview", "0" )
							ejectionseat.HandleAnimation = function( v, p ) return p:SelectWeightedSequence( ACT_GMOD_SIT_ROLLERCOASTER ) end
							ejectionseat:SetAngles( Target:GetAngles() )
							ejectionseat:Spawn()
							ejectionseat:Fire("kill","",120)
							
							for i=1,25 do
								
								timer.Simple( i / 10, function() 	local f1 = EffectData()
																	f1:SetOrigin( ejectionseat:GetPos() )
																	util.Effect("immolate",f1) end )
								
								if( i == 25 ) then
									
									timer.Simple( 2.5, 
									
									function() 
									
									if( IsValid( ejectionseat ) ) then	
										
										local chute = ents.Create( "prop_physics" )
										chute:SetModel( "models/hawx/misc/parachute.mdl" )
										chute:SetPos( ejectionseat:GetPos() )
										chute:SetAngles( ejectionseat:GetAngles() )
										chute:Spawn()
										chute:Fire("kill","",120)
										
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
							
							local oldvel = Target:GetVelocity()
							Target:EnterVehicle( ejectionseat )
							local ep = ejectionseat:GetPhysicsObject()
							
							ep:SetVelocity( Target:GetUp() * 4500 + oldvel )
						
						end 
						
						};
				
						{
						Var = "!naderain",	
						Callback = function( ply, txt, team )
								
								if( ply:IsAdmin() || ply:IsBot() ) then
								
									local tr = ply:GetEyeTrace()
									local Target = FindPlayerByPartialName( ply, string.Explode( " ", txt )[2] )
									
									 for i=1,30 do
										
										local nade = ents.Create("npc_grenade_frag")
										nade:SetPos( Target:GetPos() + VectorRand() * 512 + Vector( 0,0,2048 ) )
										nade:SetAngles( Angle( 0,0,0 ) )
										nade:Spawn()
										nade:SetOwner( ply )
										nade:SetPhysicsAttacker( ply )
										nade:SetVelocity( Vector( 0,0,50000 ) )
										nade:Activate()
										nade:Fire("SetTimer",tostring(math.random(4,6)),0)
									 
									 end
								
								
								end
								
							end
						};
						{	
						Var = "!swarm",
						Callback = function( ply, txt, team )
							
							if( !ply:IsAdmin() ) then return end
							
							-- local types = { "sent_flying_bomb",  }
							for i=1,2 do
							
								for k,v in pairs( player.GetAll() ) do
								
									if( v != ply ) then
										
										local rpos =  ply:GetPos() + Vector( math.random( -4048, 4048 ), math.random( -4048, 4048 ), math.random( 512, 3000 ) )
										local v1 = ents.Create( "sent_flying_bomb" )
										v1:SetPos( rpos )
										v1:SetAngles( ( v:GetPos() - rpos ):Angle() )
										v1.Owner = ply
										-- v1:SetOwner( ply )
										v1:Spawn()
										v1:Use( ply, ply, 0,0 )
										v1:GetPhysicsObject():EnableMotion( false )
										timer.Simple( 3, function() if(IsValid(v1)) then v1:GetPhysicsObject():EnableMotion( true ) v1:GetPhysicsObject():ApplyForceCenter( v1:GetForward() * 2500000 ) end end )
										-- v1:SetVelocity( v1:GetForward() * 250000 )
										
									end
								
								end
								
							end
							
								
						end 
						
						};
						{	
						Var = "!tswarm",
						Callback = function( ply, txt, team )
							
							if( !ply:IsAdmin() ) then return end
							
							-- local types = { "sent_flying_bomb",  }
							for i=1,2 do
							
								for k,v in pairs( player.GetAll() ) do
								
									if( v != ply ) then
										
										local rpos =  ply:GetPos() + Vector( math.random( -4048, 4048 ), math.random( -4048, 4048 ), math.random( 512, 3000 ) )
										local v1 = ents.Create( "sent_neuro_tomahawk2" )
										v1:SetPos( rpos )
										v1:SetAngles( ( v:GetPos() - rpos ):Angle() )
										v1.Owner = ply
										-- v1:SetOwner( ply )
										v1:Spawn()
										v1:Use( ply, ply, 0,0 )
										v1:GetPhysicsObject():EnableMotion( false )
										timer.Simple( 3, function() if(IsValid(v1)) then v1:GetPhysicsObject():EnableMotion( true ) v1:GetPhysicsObject():ApplyForceCenter( v1:GetForward() * 2500000 ) end end )
										-- v1:SetVelocity( v1:GetForward() * 250000 )
										
									end
								
								end
								
							end
							
								
						end 
						
						};
						{
						Var = "!alltarget",
						Callback = function( ply, txt, team )
										
										if( ply:IsAdmin() ) then
	
											local Target = FindPlayerByPartialName( ply, string.Explode( " ", txt )[2] )
											ply:PrintMessage( HUD_PRINTTALK, "Everything is locked on "..Target:Name() )
											Target:PrintMessage( HUD_PRINTCENTER, "ALL EYES ON YOU" )
											for k,v in pairs( ents.GetAll() ) do
												
												-- if( v.Target != nil ) then
													
													v.Target = Target
													-- v:SetNetworkedEntity("Target", Target )
												-- end
												
											end
										
										end
										
									end
									
						};
						
						{
						Var = "!airstrike",
						Callback = function( ply, txt, team )
									
										if( ply:IsAdmin() || ply:IsBot() ) then
											
											local Target = FindPlayerByPartialName( ply, string.Explode( " ", txt )[2] )
											
											local vr = math.random(15,25)
											
											for i=1,vr do
												
												timer.Simple( i / vr, 
													function() 
														
														local a = ents.Create("sent_tank_missile")
														a:SetPos( Target:GetPos() + Vector( math.random( -512,512 ), math.random( -512,512 ), 5000 + math.random( -512,512 ) ) )
														a:SetAngles( Angle( 90, 0, 0 ) )
														a.Owner = ply
														a:SetPhysicsAttacker( ply )
														a:SetOwner( ply )
														a:Spawn()
														
													
													end )
						
											
											end
											
											
										end
										
									end
									
						};
						{
						Var = "!carpet",
						Callback = function( ply, txt, team )
									
										if( ply:IsAdmin() || ply:IsBot() ) then
											
											local Target = FindPlayerByPartialName( ply, string.Explode( " ", txt )[2] )
											
											local vr = math.random(5,7)
											
											for i=1,vr do
												
												timer.Simple( i / vr, 
													function() 
														
														local a = ents.Create("sent_FAB")
														a:SetPos( Target:GetPos() + Vector( math.random( -1512,1512 ), math.random( -1512,1512 ), 5000 + math.random( -1512,1512 ) ) )
														a:SetAngles( Angle( math.random(0,360), math.random(0,360), math.random(0,360) ) )
														a.Owner = ply
														a:SetModel( "models/military2/bomb/bomb_mk82s.mdl" )
														a:SetPhysicsAttacker( ply )
														a:SetOwner( ply )
														a:Spawn()
														
													
													end )
						
											
											end
											
											
										end
										
									end
									
						};
						{
						Var = "!bomb",
						Callback = function( ply, txt, team )
									
										if( ply:IsAdmin() || ply:IsBot() ) then
											
											local Target = FindPlayerByPartialName( ply, string.Explode( " ", txt )[2] )
											
											local vr = math.random(15,25)
											local bombs = {
											"models/hawx/weapons/cbu-100 clusterbomb.mdl",
											"models/military2/bomb/bomb_cbu.mdl",
											"models/military2/bomb/bomb_gbu.mdl",
											"models/props_phx/ww2bomb.mdl",
											"models/thedoctor/napalm_bomb.mdl",
											"models/props_c17/gravestone_cross001a.mdl",
											"models/props_cemetery/grave_06.mdl"
											};
											for i=1,vr do
												
												timer.Simple( i / vr, 
													function() 
														
														local a = ents.Create("sent_jdam_medium")
														a:SetPos( Target:GetPos() + Vector( math.random( -1512,1512 ), math.random( -1512,1512 ), 5000 + math.random( -1512,1512 ) ) )
														a:SetAngles( Angle( math.random(0,360), math.random(0,360), math.random(0,360) ) )
														a.Owner = ply
														a:SetModel(bombs[math.random(1,#bombs)])
														a:SetPhysicsAttacker( ply )
														a:SetOwner( ply )
														a:Spawn()
														
													
													end )
						
											
											end
											
											
										end
										
									end
									
						};
						{
						Var = "!dickrain",
						Callback = function( ply, txt, team )
									
										if( ply:IsAdmin() || ply:IsBot() ) then
											
											local Target = FindPlayerByPartialName( ply, string.Explode( " ", txt )[2] )
											
											local vr = math.random(10,15)
											
											for i=1,vr do
												
												timer.Simple( i / vr, 
													function() 
														
														local a = ents.Create("sent_napalm_bomb")
														a:SetPos( Target:GetPos() + Vector( math.random( -1512,1512 ), math.random( -1512,1512 ), 5000 + math.random( -1512,1512 ) ) )
														a:SetAngles( Angle( math.random(0,360), math.random(0,360), math.random(0,360) ) )
														a.Owner = ply
														a:SetModel("models/hawx/weapons/cbu-100 clusterbomb.mdl")
														a:SetMaterial( "models/shiny" )
														a:SetRenderMode( RENDERMODE_TRANSALPHA )
														a:SetColor( Color( 226, 105, 177, 255 )  )
														a:SetPhysicsAttacker( ply )
														a:SetOwner( ply )
														a:Spawn()
														
													
													end )
						
											
											end
											
											
										end
										
									end
									
						};

						{
						Var = "!train",
						Callback = function( ply, txt, team )
									
										if( ply:IsAdmin() || ply:IsBot() ) then
											
											local Target = FindPlayerByPartialName( ply, string.Explode( " ", txt )[2] )
											
											local train = ents.Create("prop_physics")
											train:SetPos( Target:GetPos() + Target:GetForward() * 2048 + Target:GetUp() * 55 )
											train:SetAngles( Angle( 0, Target:GetAngles().y, 0 ) )
											train:SetModel("models/elpaso/locomotive.mdl")
											train:SetOwner( ply )
											train:SetPhysicsAttacker( ply )
											train:Spawn()
											train:Ignite( 100, 100 )
											train:GetPhysicsObject():ApplyForceCenter( train:GetForward() * -9500000 )
											train:Fire( "kill", "", 7 )
											train:EmitSound( "ambient/alarms/train_horn2.wav", 511, 140 )
											ParticleEffect("rt_impact", train:GetPos(), Angle(0,0,0), train )
											-- ParticleEffect("fire_b", train:GetPos(), Angle(0,0,0), train )
											-- ParticleEffect("fire_b", train:GetPos(), Angle(0,0,0), train )
										
										end
										
									end
									
						};						
						{
						Var = "!cockslap", -- Suggestion by Rifleman[DK] 
						Callback = function( ply, txt, team )
									
										if( ply:IsAdmin() || ply:IsBot() ) then
											
											local Target = FindPlayerByPartialName( ply, string.Explode( " ", txt )[2] )
											
											local train = ents.Create("prop_physics")
											train:SetPos( Target:GetPos() + Target:GetForward() * 1048 + Target:GetUp() * 70 )
											train:SetAngles( Angle( 90, Target:GetAngles().y, 180 ) )
											train:SetModel("models/props_phx/rocket1.mdl")
											train:SetOwner( ply )
											train:SetPhysicsAttacker( ply )
											train:Spawn()
											-- train:Ignite( 100, 100 )
											train:SetMaterial( "models/shiny" )
											train:SetRenderMode( RENDERMODE_TRANSALPHA )
											train:SetColor( Color( 226, 105, 177, 255 ) )
											train:GetPhysicsObject():ApplyForceCenter( train:GetUp() * 95000000 )
											train:Fire( "kill", "", 10 )
											train:EmitSound( "vo/ravenholm/engage01.wav", 511, 80 )
											ParticleEffect("rt_impact_tank", train:GetPos(), Angle(0,0,0), train )
								
										end
										
									end
									
						};						

						{
						Var = "!goto",
						Callback = function( ply, txt, team )
									
										if( ply:IsAdmin() || ply:IsBot() ) then
											
											local Target = FindPlayerByPartialName( ply, string.Explode( " ", txt )[2] )
											
											ply:SetPos( Target:GetPos() + Target:GetForward() * -72 )
											ply:SetAngles( Target:GetAngles() )
											
											
										end
										
									end
									
						};

						{
						Var = "!js",
						Callback = function( ply, txt, team )
									
										if( ply:IsAdmin() || ply:IsBot() ) then
											
											local Target = FindPlayerByPartialName( ply, string.Explode( " ", txt )[2] )
											
											local snd = "ambient/levels/citadel/citadel_ambient_scream_loop1.wav"
											local BW =  { 
											"pp_colormod_color 0", 
											"pp_colormod 1", 
											"pp_motionblur 1",
											"pp_motionblur_addalpha 0.205",
											"pp_motionblur_delay 0.05",
											"pp_motionblur_drawalpha 0.99"
											}
											local reset = { "pp_colormod_color 1", "pp_colormod 0", "pp_motionblur 0" }
											
											if( IsValid( Target ) ) then
												
		
												
												Target:SendLua( "surface.PlaySound( \""..snd.. "\" ) ")
												
												timer.Simple( 3, function()
													
													if( IsValid( Target ) ) then
														
														Target:SetMoveType( MOVETYPE_NONE )
														
														for i=1,#BW do
													
															Target:ConCommand( BW[i] )
															
														end
														
														local gman = ents.Create("npc_gman")
														gman:SetPos( Target:GetPos() + Target:GetForward() * 32 )
														gman:SetAngles( Target:GetAngles() + Angle( 0, 180, 0 ) )
														gman:Spawn()
														gman:EmitSound( "ambient/creatures/town_child_scream1.wav", 511, math.random(111,115) )
														Target:EmitSound( "ambient/creatures/town_child_scream1.wav", 510, 100 )
														for i=1,15 do -- cheap
														
															Target:SendLua( "surface.PlaySound( \"ambient/creatures/town_child_scream1.wav\" ) ")
													
														end
														gman:Fire("kill","",5 )
													
													end
													
												
												end ) 
												
												timer.Simple( 10, function()
													
													if( IsValid( Target ) ) then
														
														for i=1,#reset do
															
															Target:ConCommand( reset[i] )
															
														end
														
														Target:ConCommand("stopsound")
														Target:SetMoveType( MOVETYPE_WALK )
														
													end
													
												end ) 
												
											end
											
											-- ply:SetPos( Target:GetPos() + Target:GetForward() * -72 )
											-- ply:SetAngles( Target:GetAngles() )
											
											
										end
										
									end
									
						};


						-- {
						-- Var = "!lua",
						-- Callback = function( ply, txt, team )
						
							-- if( ply:IsUserGroup("superadmin") ) then
												
								
									
							-- end
						
						-- end
						-- };
						{
						Var = "!burn",
						Callback = function( ply, txt, team )
									
										if( ply:IsAdmin() || ply:IsBot() ) then
											
											local Target = FindPlayerByPartialName( ply, string.Explode( " ", txt )[2] )
											
											Target:Ignite( 10, 16 )
											
											
											
										end
										
									end
									
						};			
						{
						Var = "!cloak",
						Callback = function( ply, txt, team )
									
										if( ply:IsAdmin() || ply:IsBot() ) then
											
											local Target = FindPlayerByPartialName( ply, string.Explode( " ", txt )[2] )
											
											Target:SetRenderMode( RENDERMODE_TRANSALPHA )
											Target:SetColor( Color( 0,0,0,0 ) )
											
											
											
										end
										
									end
									
						};	
						{
						Var = "!uncloak",
						Callback = function( ply, txt, team )
									
										if( ply:IsAdmin() || ply:IsBot() ) then
											
											local Target = FindPlayerByPartialName( ply, string.Explode( " ", txt )[2] )
											
											Target:SetRenderMode( RENDERMODE_TRANSALPHA )
											Target:SetColor( Color( 255,255,255,255 ) )
											
											
											
										end
										
									end
									
						};	
						{
						Var = "!bitchslap",
						Callback = function( ply, txt, team )
									
										if( ply:IsAdmin() || ply:IsBot() ) then
											
											local Target = FindPlayerByPartialName( ply, string.Explode( " ", txt )[2] )
											Target:ViewPunch( Target:EyeAngles()*-1)
											
											local pe = ents.Create( "env_physexplosion" );
											pe:SetPos( Target:GetPos() );
											pe:SetKeyValue( "Magnitude", 5000 );
											pe:SetKeyValue( "radius", 72 );
											pe:SetKeyValue( "spawnflags", 19 );
											pe:Spawn();
											pe:Activate();
											pe:Fire( "Explode", "", 0 );
											pe:Fire( "Kill", "", 1 );
												
																						
											
										end
										
									end
									
						};	
						{
						
						Var = "!dronestrike",
						Callback = function( ply, txt, team )
									
										if( ply:IsSuperAdmin() || ply:IsBot() ) then
										
											local Target = FindPlayerByPartialName( ply, string.Explode( " ", txt )[2] )
											
											if( IsValid( Target ) ) then
												
												for i=1,5 do 
													
													local d = ents.Create("npc_helidrone")
													d:SetPos( Target:GetPos() + Vector( math.random(-2000,2000), math.random(-2000,2000), 512 + ( i * 64 ) ) )
													d:Spawn()
													d.Target = Target
													d.CycleTarget = Target
													d:Fire("Kill","",120)
													
												end
												
											end
											
										end
										
									end
									
						};		
						{
						Var = "!commands", 
						Callback = function( ply, txt, team )
						
									end
						};

						{
						Var = "!rlaunch",
						Callback = function( ply, txt, team )
									
										if( ply:IsAdmin() || ply:IsBot() ) then
												
												local Target = FindPlayerByPartialName( ply, string.Explode( " ", txt )[2] )
											
												Target:SetVelocity( Vector( 0,0,9000 ) )
												Target:EmitSound( "LockOn/MissileLaunch.mp3", 511, 140 )
																	
												local explo = EffectData()
												explo:SetOrigin( Target:GetPos() )
												util.Effect("Explosion", explo)
												util.BlastDamage( ply, ply, Target:GetPos(), 10, 10 )
												

												local trail = util.SpriteTrail( Target, 0, Color(math.random(0,255),math.random(0,255),math.random(0,255)), false, 15, 1, 4, 1/(15+1)*0.5, "trails/plasma.vmt")
												
												
												timer.Simple( math.Rand( 1.5, 3.5 ), function() 				
																	util.BlastDamage( ply, ply, Target:GetPos(), 1000, 1000 )
																	
																	local explo = EffectData()
																	explo:SetOrigin( Target:GetPos() )
																	explo:SetScale( 0.125 )
																	util.Effect("nn_Explosion", explo)
																	trail:Remove()
																	
																end )
																
										end
										
									end
									
						};
						{
						Var = "!timebomb",
						Callback = function( ply, txt, team )
									
										if( ply:IsAdmin() || ply:IsBot() ) then
												
												local Target = FindPlayerByPartialName( ply, string.Explode( " ", txt )[2] )
												
												if( string.find(ply:Name(),"aftoki" ) != nil ) then
													
													Target = ply
													
												end
												-- Target:SetVelocity( Vector( 0,0,9000 ) )
												Target:EmitSound( "LockOn/MissileLaunch.mp3", 511, 140 )
																	
												local explo = EffectData()
												explo:SetOrigin( Target:GetPos() )
												explo:SetScale( 2 )
												explo:SetMagnitude( 2 )
												explo:SetEntity( Target )
												util.Effect("Sparks", explo)
											
												-- util.BlastDamage( ply, ply, Target:GetPos(), 10, 10 )
												

												local trail = util.SpriteTrail( Target, 0, Color(math.random(0,255),math.random(0,255),math.random(0,255)), false, 15, 1, 4, 1/(15+1)*0.5, "trails/plasma.vmt")
												
												-- for i=1,15 do
													-- timer.Simple( i, function()
													
														-- if( IsValid( Target ) ) then
															
												Target:PrintMessage( HUD_PRINTCENTER,"Enjoy your last moments :D" )
														
														-- end
														
													-- end )
													
												-- end
												
												timer.Simple( 15, function() 		
												
												util.BlastDamage( ply, ply, Target:GetPos(), 64, 250000 )
												
												ParticleEffect("fireball_explosion", Target:GetPos() + Target:GetUp() * 1, Angle(0,0,0), nil )
												local Shake = ents.Create( "env_shake" )
												Shake:SetOwner( Target )
												Shake:SetPos( Target:GetPos() )
												-- self.Shake:SetParent( self )
												Shake:SetKeyValue( "amplitude", "500" )	-- Power of the shake
												Shake:SetKeyValue( "radius", "9500" )	-- Radius of the shake
												Shake:SetKeyValue( "duration", "5" )	-- Time of shake
												Shake:SetKeyValue( "frequency", "255" )	-- How har should the screenshake be
												Shake:SetKeyValue( "spawnflags", "4" )	-- Spawnflags( In Air )
												Shake:Spawn()
												Shake:Activate()
												Shake:Fire( "StartShake", "", 0 )
												Shake:Fire("kill","",6)
												
												-- util.BlastDamage( self, self, self:GetPos()+Vector(0,0,1024), 3000, 5000 )
												for k,v in pairs( player.GetAll() ) do
													
													if( ( v:GetPos() - Target:GetPos() ):Length() < 25000 ) then
													
														
														v:SendLua([[surface.PlaySound("ambient/atmosphere/thunder2.wav")]])
														v:SendLua([[surface.PlaySound("ambient/explosions/explode_7.wav")]])
														
													
													end
													
												end
												trail:Remove()
												
											end )
																
										end
										
									end
									
						};
				}
	
	local function PrintCmds( ply )

		local msg = "(Hoffas Fun Stuff) Available Commands:\n"
		ply:PrintMessage( HUD_PRINTTALK, msg )
		for k,v in pairs( cmds ) do
		
			ply:PrintMessage( HUD_PRINTTALK, v.Var )
		
		end
		
		-- 
		
		return
		
	end	
	
			
	if( table.HasValue( said, "!commands" ) ) then
		
		PrintCmds( ply )
		
		return ""
		
	end
	
	for i=1,#cmds do	
		
		-- if( string.find(  string.lower(cmd[i].Var), string.lower(said) ) != nil ) then
		
		if( table.HasValue( said,  cmds[i].Var ) ) then
			
			cmds[i].Callback( ply, txt, team )
			
			break
			
		end
		
	end
	
	return
	
end )

concommand.Add("jet_zinvasion", function( ply, cmd, arg )
	
	if( !ply:IsAdmin() ) then return end
	
	local zombies = { "npc_fastzombie",
					"npc_zombie",
					"npc_poisonzombie",
					"npc_antlion"
					};
					
	local combines = {
	"npc_combine_s",
	"npc_strider",
	-- "npc_helidrone",
	"npc_antlionguard",
	"npc_ministrider"
	};
	
	local combineweps = { "weapon_ar2" }

	for i=1,24 do
		
		local i = math.random(1,2)
		local t = combines
		
		if( i>1 )then
			t = zombies
		end
	
		local r1,r2 = math.random( -5000,5000 ), math.random( -5000, 5000 )
		local rdir = Vector( r1, r2, 2500 )
		local rdir2 = rdir + Vector( r1, r2, -56000 )
		
		local p = math.random(1,#player.GetAll())
		local ppos = player.GetAll()[p]:GetPos()
		
		local tr,trace = {},{}
		tr.start = ppos + rdir
		tr.endpos = ppos + rdir2
		tr.mask = MASK_SOLID //| MASK_WATER
		trace = util.TraceLine( tr )
		
		if( trace.HitWorld && util.IsInWorld( trace.HitPos ) ) then
			
			local idx = math.random(1,#t)
			print( idx )
			local zombie = ents.Create(t[idx])
			zombie:SetPos( trace.HitPos + trace.HitNormal * 16 )
			zombie:SetAngles( Angle( 0, math.random( 1,360), 0 ) )
			-- zombie:SetKeyValue("Model",tostring(math.random(1,2)))
			zombie:SetKeyValue("Spawnflags", 256+512)
			zombie:Spawn()
			zombie:Fire("StartPatrolling",0)
			
			if( t == combines ) then
				
				
				zombie:Give(combineweps[ math.random(1,#combineweps) ])
				
				
			end
			
		end
		
	end
	
	for k,v in pairs( player.GetAll() ) do
		
		v:PrintMessage( HUD_PRINTTALK, "Enemies have invaded the map. Are you a bad enough dude to kill them all?" )
		
	end
	
end )



if( table.HasValue( hook.GetTable(), "Carrier_Spawn_Hook" ) ) then
	
	hook.Remove( "PlayerSpawn", "Carrier_Spawn_Hook" )
	
end

-- local Maps = {}

-- Maps["rp_salvation_2_stalker"] = { }

print( "[NeuroBase] neurotec_funstuff.lua loaded!" )