local pairs = pairs
local ipairs = ipairs
local table = table
local string = string
local type = type
local surface = surface
local draw = draw
local math = math
local ScrW = ScrW
local ScrH = ScrH
local Color = Color

local AverageHeight = 0
function FixCalcView( ply, Origin, Angles, Fov, NearZ, FarZ ) 
	
	
	local vehicle = ply:GetScriptedVehicle()
	
	if( !IsValid( vehicle ) ) then
		
		vehicle = ply:GetNetworkedEntity("Plane", NULL )
		
	end
	
	if ( IsValid( vehicle ) ) then
		
		if( vehicle.AdvancedCommando ) then return end
		
		if ( vehicle.CalcView != nil ) then
		
			local view = vehicle:CalcView(  ply, Origin, Angles, Fov )
			view.znear = 1.2
			return view
		
		end
		
	end
	
	if( ply:GetNWBool("NeuroMiniMe")  && false ) then 
		-- Origin.z = 9
		-- return { origin = LerpVector( 1, Origin, ply:GetPos() + ply:GetUp() * 9 ) }
		local view = {}
		Origin.z = Lerp( 0.99, Origin.z, ply:GetPos().z + 12  )
		view.origin =  Origin 
		view.fov = 90 
		view.angles = Angles
		
		return view 
		
	end 
	
end
hook.Add("CalcViewModelView", "NeuroTecMinify", function( wep, vm, oldPos, oldAng, pos, ang ) 
	
	local ply = LocalPlayer()
	if( ply:GetNWBool("NeuroMiniMe") ) then 
			
			pos.z = Lerp( 0.99, oldPos.z, ply:GetPos().z + 10  )
			 
		return pos, ang   
	
	end 
	
end ) 

hook.Add("CalcView", "HackFixSentView", FixCalcView )
hook.Add("InitPostEntity", "NeuroPlanes_DetectGroundLevelAverage", function()
	
	local AverageZ = 0
	local count = 0
	
	for k,v in pairs( ents.GetAll() ) do
		
		if( IsValid( v ) && v:OnGround() ) then
		
			count = count + 1
			AverageZ = AverageZ + v:GetPos().z
			
		end
		
	end
	
	AverageHeight = AverageZ / count
	
end )

local langObjects = {
					{ ent = "npc_A10thunderbolt", 			name = "A-10 Thunderbolt II" },
					{ ent = "npc_ac47", 					name = "AC-47 Spooky" },
					{ ent = "npc_ac130", 					name = "AC-130 \"Spectre\"" },
					{ ent = "npc_ADF01falken", 				name = "ADF-01 Falken" },
					{ ent = "npc_ah60", 					name = "AH-64 Apache" },
					{ ent = "npc_f15", 						name = "F-15" },
					{ ent = "npc_F-15C", 					name = "F-15C" },
					{ ent = "npc_F-15E", 					name = "F-15E" },
					{ ent = "npc_F22raptor", 				name = "F-22 Raptor" },
					{ ent = "npc_helidrone", 				name = "Helicopter Drone" },
					{ ent = "npc_k60", 						name = "K-60 Helicopter" },
					{ ent = "npc_leakheli", 				name = "Kamov Ka-27 \"Helix A\"" },
					{ ent = "npc_pilotfish", 				name = "Pilotfish UCAV" },
					{ ent = "npc_X45A_ucav", 				name = "X-45A UCAV" },
					{ ent = "npc_T-80U", 					name = "T-80U" },
					{ ent = "npc_zsu-23-4", 				name = "ZSU-23-4 Shilka" },
					{ ent = "sent_a2a_jericho", 			name = "Jericho Missile" },
					{ ent = "sent_a2a_jericho_drone", 		name = "Jericho Drone" },
					{ ent = "sent_a2a_rocket", 				name = "Homing Missile" },
					{ ent = "sent_a2l_rocket", 				name = "Laser Guided Missile" },
					{ ent = "sent_a2s_dumb", 				name = "Rocket" },
					{ ent = "sent_a2s_nuclear_missile", 	name = "Nuclear Missile" },
					{ ent = "sent_a2s_rocket", 				name = "Rocket" },
					{ ent = "sent_a2s_torpedo", 			name = "Torpedo Missile" },
					{ ent = "sent_s2a_seamissile", 			name = "Sea Missile" },
					{ ent = "sent_s2s_torpedo", 			name = "Sea Torpedo" },
					{ ent = "sent_naval_turret", 			name = "Naval Turret" },
					{ ent = "sent_A-6_p", 					name = "A-6 Intruder" },
					{ ent = "sent_A-7_p", 					name = "A-7 Corsair II" },
					{ ent = "sent_AA_vehicle", 				name = "Anti-Air Unit" },
					{ ent = "sent_ac130_20mm_shell", 		name = "20MM Shell" },
					{ ent = "sent_ac130_40mm_shell", 		name = "40MM Shell" },
					{ ent = "sent_ac130_105mm_shell", 		name = "105MM Shell" },
					{ ent = "sent_ac130_bofors", 			name = "Bofors 40MM" },
					{ ent = "sent_ac130_gau2a", 			name = "GAU-2A 20MM" },
					{ ent = "sent_ac130_howitzer", 			name = "105MM Howitzer" },
					{ ent = "sent_AC130_p", 				name = "AC-130 \"Spectre\"" },
					{ ent = "sent_ac130_vulcan", 			name = "Vulcan 20MM" },
					{ ent = "sent_ADF01falken", 			name = "ADF-01 Falken" },
					{ ent = "sent_AH-1Cobra_p", 			name = "AH-1 Cobra" },
					{ ent = "sent_bunker_buster", 			name = "Bunker Buster" },
					{ ent = "sent_C100_cluster", 			name = "Shrapnel" },
					{ ent = "sent_chopper_gun", 			name = "Mounted Minigun" },
					{ ent = "sent_combine_helicopter_p", 	name = "Combine Helicopter" },
					{ ent = "sent_F-4E_p", 					name = "F-4E Phantom" },
					{ ent = "sent_F-14A_p", 				name = "F-14A Tomcat" },
					{ ent = "sent_F14tomcat", 				name = "F-14 Tomcat" },
					{ ent = "sent_F-15Active_p", 			name = "F-15 ACTIVE" },
					{ ent = "sent_F-15C_p", 				name = "F-15C Eagle" },
					{ ent = "sent_F-15E_p", 				name = "F-15E Strike Eagle" },
					{ ent = "sent_f16fightingfalcon", 		name = "F-16 Fighting Falcon" },
					{ ent = "sent_F-18HARV_p", 				name = "F-18 HARV" },
					{ ent = "sent_A-10_p", 					name = "A-10 Thunderbolt II" },
					{ ent = "sent_F35lightning",			name = "F-35 Lightning II" },
					{ ent = "sent_f117_p", 					name = "F-117 Nighthawk" },
					{ ent = "sent_FA-18C_p",			 	name = "F/A-18C Hornet" },
					{ ent = "sent_FA-18E_p", 				name = "F/A-18E Super Hornet" },
					{ ent = "sent_FA-18RC_p", 				name = "F/A-18RC" },
					{ ent = "sent_FA22raptor", 				name = "FA-22 Raptor" },
					{ ent = "sent_gman_bomber", 			name = "Tacticool Gman Bomber" },
					{ ent = "sent_harrier_p", 				name = "AV-8A Harrier" },
					{ ent = "sent_huey_p", 					name = "UH-1 Iroquois" },
					{ ent = "sent_jas39gripen", 			name = "JAS-39 Gripen" },
					{ ent = "sent_JDAM_medium", 			name = "MK-82 JDAM" },
					{ ent = "sent_JDAM_huge", 				name = "MK-82 JDAM" },
					{ ent = "sent_kamov_p", 				name = "Kamov Ka-27 \"Helix\"" },
					{ ent = "sent_kirov_blimp", 			name = "Kirov Airship" },
					{ ent = "sent_Mi-24_p", 				name = "Mil Mi-24 Hind" },
					{ ent = "sent_mi-28_p", 				name = "Mil Mi-28 Havoc" },
					{ ent = "sent_mig29fulcrum", 			name = "Mig-29 Fulcrum" },
					{ ent = "sent_Mir2000N_p", 				name = "Dassault Mirage 2000 N" },
					{ ent = "sent_mk82", 					name = "Cluster Bomb" },
					{ ent = "sent_rafale_p", 				name = "Dassault Rafale" },
					{ ent = "sent_RAH-66Comanche_p", 		name = "RAH-66 Comanche" },
					{ ent = "sent_RF-15_p", 				name = "RF-15" },
					{ ent = "sent_Su-47_p", 				name = "Su-47 Berkut" },
					{ ent = "sent_torpedo_homer", 			name = "Torpedo" },
					{ ent = "sent_uh60blackhawk", 			name = "UH-60 Blackhawk" },
					{ ent = "sent_x02wyvern", 				name = "X-02 Wyvern" },
					{ ent = "sent_XA20_razorback", 			name = "XA-20 Razorback" },
					{ ent = "sent_YF12A_p", 				name = "YF-12 Blackbird" },
					{ ent = "sent_YF-17_p", 				name = "YF-17 Cobra" },
					{ ent = "sent_cobra_rotor", 			name = "Helicopter Rotor" },
					{ ent = "sent_AH-2Rooivalk_p", 			name = "Denel AH-2 Rooivalk" },
					{ ent = "sent_UH-60BlackHawk_p", 		name = "UH-60 Black Hawk" },
					{ ent = "sent_MH-53JPaveLow_p", 		name = "MH-53J Pave Low IIIE" },
					{ ent = "sent_WZ-10_p", 				name = "CAIC WZ-10" },
					{ ent = "sent_Ka-50BlackShark_p", 		name = "Kamov Ka-50 Black Shark" },
					{ ent = "sent_T-80U_p", 				name = "T-80U" },
					{ ent = "sent_zsu-23-4_p", 				name = "ZSU-23-4 Shilka" },
					{ ent = "sent_uboat_p", 				name = "U-Boat Submarine" },
					{ ent = "sent_rattack_p", 				name = "Rattack Boat" },
					{ ent = "sent_neuro_aa",				name = "Super Turret" }
					} --thats alot of code bro
					
for k,v in pairs( langObjects ) do
	language.Add( v.ent, v.name )
end

CreateClientConVar( "jet_cockpitview", "0", true, false )
CreateClientConVar( "jet_freelook", "1", true, false )
CreateClientConVar( "jet_bomberview", "0", true, false )
CreateClientConVar( "jet_markenemies", "1", true, false )
CreateClientConVar( "jet_health", "1", true, false )
CreateClientConVar( "jet_HUD", "1", true, false )
CreateClientConVar( "jet_HQhud", "0", true, false )
CreateClientConVar( "jet_arcadeview", "0", true, false )
CreateClientConVar( "jet_arcademode", "0", true, false )
CreateClientConVar( "jet_radar", "0", true, false )
surface.CreateFont ("Neuroplanes_Warning_Big",
				{	font = "Helvetica",
					size = 24,
					weight 	= 0,
					antialias = true,
					additive =	false
				}
)					
surface.CreateFont ("Neuroplanes_Warning_Big2",
				{	font = "Helvetica",
					size = 26,
					weight 	= 0,
					antialias = true,
					additive =	false
				}
)
surface.CreateFont("LockonAlert",
				{	font = "Helvetica",
					size = 40,
					weight 	= 700,
					antialias = true,
					additive =	false
				}
)

local JetFighter = {}
JetFighter.DrawWarning = false
JetFighter.Crosshair = nil
JetFighter.Target = NULL
JetFighter.Plane = NULL
JetFighter.Pilot = NULL

local ch_red = Material("JetCH/ch_red")
local ch_green = Material("JetCH/crosshairs-dial")
local targetMat = Material("JetCH/aim")
local hpbar = surface.GetTextureID("JetCH/InfoBar")
local hppanel = surface.GetTextureID("JetCH/Info")
local brackets = Material("JetCH/CH_brackets")
local altpanel = surface.GetTextureID("JetCH/Alt")
local altbar = surface.GetTextureID("JetCH/AltBar")
local blackhp = surface.GetTextureID("vgui/black")
local compass = surface.GetTextureID("hud/ntec_compass") 
local compass_letters = surface.GetTextureID("hud/ntec_compass_letters") 
local plyHUDcolor = Color(255,200,50)
local planeicon_1engine = {}
local planeicon_2engine = {}
local planeicon_4engine = {}
local planeicon_materials = {}

planeicon_materials["planeicon_1engine_fuselage"] = Material("hud/planeicons/planeicon_1engine_fuselage.png")
planeicon_materials["planeicon_1engine_tail"] = Material("hud/planeicons/planeicon_1engine_tail.png")
planeicon_materials["planeicon_1engine_engine1"] = Material("hud/planeicons/planeicon_1engine_engine1.png")
planeicon_materials["planeicon_1engine_rightwing"] = Material("hud/planeicons/planeicon_1engine_rightwing.png")
planeicon_materials["planeicon_1engine_leftwing"] = Material("hud/planeicons/planeicon_1engine_leftwing.png")
planeicon_materials["planeicon_1engine_rightaileron"] = Material("hud/planeicons/planeicon_1engine_rightaileron.png")
planeicon_materials["planeicon_1engine_leftaileron"] = Material("hud/planeicons/planeicon_1engine_leftaileron.png")
planeicon_materials["planeicon_1engine_elevator"] = Material("hud/planeicons/planeicon_1engine_elevator.png")
planeicon_materials["planeicon_1engine_rudder"] = Material("hud/planeicons/planeicon_1engine_rudder.png")

planeicon_materials["planeicon_2engine_fuselage"] = Material("hud/planeicons/planeicon_2engine_fuselage.png")
planeicon_materials["planeicon_2engine_tail"] = Material("hud/planeicons/planeicon_2engine_tail.png")
planeicon_materials["planeicon_2engine_engine1"] = Material("hud/planeicons/planeicon_2engine_engine1.png")
planeicon_materials["planeicon_2engine_engine2"] = Material("hud/planeicons/planeicon_2engine_engine2.png")
planeicon_materials["planeicon_2engine_rightwing"] = Material("hud/planeicons/planeicon_2engine_rightwing.png")
planeicon_materials["planeicon_2engine_leftwing"] = Material("hud/planeicons/planeicon_2engine_leftwing.png")
planeicon_materials["planeicon_2engine_rightaileron"] = Material("hud/planeicons/planeicon_2engine_rightaileron.png")
planeicon_materials["planeicon_2engine_leftaileron"] = Material("hud/planeicons/planeicon_2engine_leftaileron.png")
planeicon_materials["planeicon_2engine_elevator"] = Material("hud/planeicons/planeicon_2engine_elevator.png")
planeicon_materials["planeicon_2engine_rudder"] = Material("hud/planeicons/planeicon_2engine_rudder.png")

planeicon_materials["planeicon_4engine_fuselage"] = Material("hud/planeicons/planeicon_4engine_fuselage.png")
planeicon_materials["planeicon_4engine_tail"] = Material("hud/planeicons/planeicon_4engine_tail.png")
planeicon_materials["planeicon_4engine_engine1"] = Material("hud/planeicons/planeicon_4engine_engine1.png")
planeicon_materials["planeicon_4engine_engine2"] = Material("hud/planeicons/planeicon_4engine_engine2.png")
planeicon_materials["planeicon_4engine_engine3"] = Material("hud/planeicons/planeicon_4engine_engine3.png")
planeicon_materials["planeicon_4engine_engine4"] = Material("hud/planeicons/planeicon_4engine_engine4.png")
planeicon_materials["planeicon_4engine_rightwing"] = Material("hud/planeicons/planeicon_4engine_rightwing.png")
planeicon_materials["planeicon_4engine_leftwing"] = Material("hud/planeicons/planeicon_4engine_leftwing.png")
planeicon_materials["planeicon_4engine_rightaileron"] = Material("hud/planeicons/planeicon_4engine_rightaileron.png")
planeicon_materials["planeicon_4engine_leftaileron"] = Material("hud/planeicons/planeicon_4engine_leftaileron.png")
planeicon_materials["planeicon_4engine_elevator"] = Material("hud/planeicons/planeicon_4engine_elevator.png")
planeicon_materials["planeicon_4engine_rudder"] = Material("hud/planeicons/planeicon_4engine_rudder.png")

local function GetPlaneParts( ply )
local vehicle = ply:GetScriptedVehicle()
local parts = {}
if( IsValid( vehicle ) ) then
parts.Ailerons = {}
parts.Flaps = {}
parts.Wings = {}
parts.Rudder = NULL
parts.Elevator = NULL
parts.Plane = vehicle
for k,v in pairs( ents.FindInSphere( vehicle:GetPos(), 1024 ) ) do
if ( v:GetOwner() == vehicle && v:GetClass() == "plane_part") then
local mdl = string.lower( v:GetModel() )
if( string.find( mdl, "aileron") ) then table.insert( parts.Ailerons, v ) end
if( string.find( mdl, "wing") ) then table.insert( parts.Wings, v ) end
if( string.find( mdl, "flap") ) then table.insert( parts.Flaps, v ) end
if( string.find( mdl, "elevator") ) then parts.Elevator = v end
if( string.find( mdl, "rudder") ) then parts.Rudder = v end
end
end
end
return parts 
end



/*
hook.Add("HUDPaint", "Laserguidance_Minicam", function()
	
	local pl = LocalPlayer()
	--local pos = pl
	
	local CamData = {}
	CamData.angles = Angle( 90,0,0 )
	CamData.origin = pos
	CamData.x = 0
	CamData.y = 0
	CamData.w = ScrW() / 4
	CamData.h = ScrH() / 4
	render.RenderView( CamData )
	
end )
 */

function HideHL2HUD( name )	-- Hide the default HL2 HUD which appears while using the entities.
	
	local ply = LocalPlayer()
	-- print( ply )
	
	-- if true then return end 
	if( !IsValid( ply ) ) then return end 
	
	local tank = ply:GetNetworkedEntity( "Tank", NULL )
	local plane = ply:GetNetworkedEntity( "Plane", NULL )

	if ( ply:GetNetworkedBool("InFlight", false) ) then
		for k, v in pairs({"CHudHealth", "CHudBattery", "CHudAmmo", "CHudSecondaryAmmo","CHudZoom","CHudSuitPower","CHudWeaponSelection"}) do
			if name == v then return false end
		end
	end
end	
hook.Add("HUDShouldDraw", "NeuroTech_HideHL2HUD", HideHL2HUD )
	
local function inLOS( a, b )

	if( !IsValid( a ) || !IsValid( b ) ) then
		
		return false
	
	end
	
	if( ( a:GetPos() - b:GetPos()):Length() > 10000 ) then return false end
	
	local trace = util.TraceLine( { start = a:GetPos() + a:GetForward() * 1024, endpos = b:GetPos() + Vector(0,0,32), filter = a, mask = MASK_BLOCKLOS + MASK_WATER + MASK_SOLID } )
	return ( ( trace.Hit && trace.Entity == b ) || !trace.Hit )
	
end

function JetFighter.CopilotCalcView( ply, Origin, Angles, Fov )

	-- local plane = NULL// plr:GetDrivingEntity()
	-- if( IsValid( plane ) ) then 

		-- return  -- Dont fuck up our cameras plskthx
		
	-- end
	-- 
	
	local copilotplane = ply:GetNetworkedEntity( "Plane", NULL ) 
	
	if( IsValid( copilotplane ) ) then
		
		local lg = copilotplane:GetNetworkedEntity("NeuroPlanes_LaserGuided", NULL )
		if( IsValid( lg ) ) then
		
			local pos = lg:GetPos() + lg:GetForward() * 100
			local myAng = lg:GetAngles()
				
			local view = {
				origin = pos,
				angles = myAng,
				fov = GetConVarNumber("fov_desired")
				}
				
			return view
			
		end
	
	end
	
	local isGunner = ply:GetNetworkedBool( "isGunner", false )
	local plane = ply:GetNetworkedEntity("NeuroPlanes_Helicopter", NULL )
	
	local view = {
			origin = Origin,
			angles = Angles,
			fov = fov
		}
	
	if( isGunner && IsValid( plane ) ) then
	-- print( "AHMED VAD G�R DU???")
		local pos
		local fov = GetConVarNumber("fov_desired")
		local ang = ply:GetAimVector():Angle()
		local pAng = plane:GetAngles()
		local myAng 

		-- hurr hackfix
		if ( ang.p < 4|| ang.p > 300 ) then ang.p = 4 end
		if ( ang.p > 89 && ang.p < 150 ) then ang.p = 89 end
		-- durr
		
		if ( ply:KeyDown( IN_ATTACK ) ) then
			
			local wat = ( plane.MaxZoom / 100 ) - ( plane.ZoomLevel / 100 ) -- more zoom = more feedback from recoil.
			ang.p = ang.p + math.Rand( -.3 - wat, .3 + wat )
			ang.y = ang.y + math.Rand( -.3 - wat, .3 + wat )
	
		end
		
		if( ply:KeyDown( IN_ATTACK2 ) && plane.LastZoom + 0.5 <= CurTime() ) then
			
			plane.LastZoom = CurTime()
			
			if( plane.ZoomLevel == plane.MinZoom ) then
			
				plane.ZoomLevel = plane.MaxZoom
				
			elseif( plane.ZoomLevel == plane.MaxZoom ) then
			
				plane.ZoomLevel = plane.MinZoom
		
			end
			
		end
		
		plane.ZoomVar = math.Approach( plane.ZoomVar, plane.ZoomLevel, 10 )
		pos = plane:GetPos() + plane:GetForward() * 165 + plane:GetUp() * -59
		fov = plane.ZoomVar
		myAng = Angle( ang.p, ang.y, pAng.r / 1.15 )
		
		local lg = plane:GetNetworkedEntity("NeuroPlanes_LaserGuided", NULL )
		if( IsValid( lg ) ) then
		
			local pos = lg:GetPos() + lg:GetForward() * 100
			local myAng = lg:GetAngles()
				
			local view = {
				origin = pos,
				angles = myAng,
				fov = GetConVarNumber("fov_desired")
				}
				
			return view
			
		end
		
		view = {
			origin = pos,
			angles = myAng,
			fov = fov
		}
		
		return view
	
	end

	return
	
end

function JetFighter.Panels()

	local hp = math.floor( JetFighter.Plane:GetNetworkedInt( "Health", 0 ) )
	local maxhp = math.floor( JetFighter.Plane:GetNetworkedInt( "MaxHealth", 0 ) )
	JetFighter.Plane.HealthVal = math.ceil( hp * 100 / maxhp )
	local maxspd = math.floor( JetFighter.Plane:GetNetworkedInt( "MaxSpeed", 0 ) )
	local throttle =  ( JetFighter.Plane:GetVelocity():Length() * 100) / maxspd
	local h = hp / maxhp
	local flares = 	JetFighter.Plane:GetNetworkedInt( "FlareCount", 0 )
	local wep = JetFighter.Plane:GetNetworkedString("NeuroPlanes_ActiveWeapon",tostring("NONE_AVAILABLE")) -- should this really be necessary?

	surface.SetTexture( hppanel )
	surface.SetDrawColor( 255, 255, 255, 255 )
	surface.DrawTexturedRect( 10, ScrH()-10-128 ,512,128 )

	surface.SetTexture( hpbar )
	surface.SetDrawColor( 255, 255*h , 255*h*h, 255 )
	surface.DrawTexturedRect( 40, ScrH()-50, 180*h, 8 )
	draw.SimpleText("Health: "..JetFighter.Plane.HealthVal, "TargetID", 90, ScrH() -57, Color( 255, 255*h , 255*2*h*h, 255 ), TEXT_ALIGN_LEFT, TEXT_ALIGN_LEFT )

	surface.SetTexture( blackhp )
	surface.SetDrawColor( 255, 255, 255, 255 )
	surface.DrawTexturedRect( 35, ScrH()-50+128, 128+128*(1-h), 8 )

	surface.SetTexture( altpanel )
	surface.SetDrawColor( 255, 255, 255, 255 )
	surface.DrawTexturedRect( ScrW()-64-64, ScrH()*0.5-256, 128, 512 )

	surface.SetTexture( altbar )
	surface.SetDrawColor( 255, 255, 255, 255 )
	surface.DrawTexturedRect(ScrW()-54-32,ScrH()*0.5+220 - 430*throttle/138 -8,64,8)

		draw.SimpleText("Throttle: "..math.floor(throttle), "TargetID", 256, ScrH()-75, Color( 255, 255, 255, 245 ), TEXT_ALIGN_LEFT, TEXT_ALIGN_LEFT )

	if ( wep != "NONE_AVAILABLE" ) then

		draw.SimpleText("WEP: "..wep, "TargetID", 256, ScrH() - 54, Color( 255, 255, 255, 245 ), TEXT_ALIGN_LEFT, TEXT_ALIGN_LEFT )
		
	end


end

function JetFighter.HUD() --Real Head-Up Display by StarChick. ;)

	local spd = JetFighter.Plane:GetVelocity():Length()
	local maxspd = math.floor( JetFighter.Plane:GetNetworkedInt( "MaxSpeed", 1000*1.8 ) )
	
	local lockwarning
	if JetFighter.DrawWarning then 
	lockwarning = 255 
--	JetFighter.Pilot:EmitSound( "LockOn/Launch.mp3", 511, 100 ) --Maybe annoying?
	else
	lockwarning = 0
--	JetFighter.Pilot:StopSound( "LockOn/Launch.mp3" )
	end
	
	local dangerzone
	if( spd > maxspd * 1.2 ) then dangerzone = 255 else dangerzone = 0 end
	
	if ( IsValid( JetFighter.Target ) && JetFighter.Target != JetFighter.Plane && v == JetFighter.Target ) then
		draw.SimpleText( "Locked On", "ChatFont", x, y, Color( 255, 0, 0, 240 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
	end
	
	--local target = JetFighter:GetNetworkedEntity( "Target", NULL )

					
	surface.SetDrawColor( lockwarning, 255-lockwarning, 0, 200)
	if( GetConVarNumber("jet_cockpitview") > 0 ) then
	
		if JetFighter.Plane.Category == "NeuroTec Micro" then
			JetFighter.HUDinstruments(dangerzone)
		else 
			JetFighter.ModernHUD(lockwarning)
		end
		
	else

		if (JetFighter.Plane.VehicleType == VEHICLE_PLANE ) or 	(JetFighter.Plane.VehicleType == VEHICLE_HELICOPTER ) then
			JetFighter.HUDindicators(dangerzone)
			-- JetFighter.Panels()	
		end
	end

	//Alerts
	if ( JetFighter.DrawWarning && JetFighter.Plane && JetFighter.Pilot:GetNetworkedBool("InFlight") ) then
--		draw.SimpleText("LOCK-ON ALERT", "LockonAlert", ScrW() / 2, 150, Color( 255, 35, 35, 200 + (math.sin(CurTime())*50) ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )

	end
	
/*	//Bombing Impact Prediction (this lag so much...)
	local bpos = JetFighter.Plane:GetNetworkedVector("BombingImpactPos", JetFighter.Plane:GetPos() )
	local ang = JetFighter.Plane:GetAngles()
	local eyeang = JetFighter.Pilot:EyeAngles()
	local d = (bpos-JetFighter.Plane:GetPos() ):Length()
	local w,h = 50,50*math.abs(math.sin(ang.p/180*math.pi/2) )
	
	DrawHUDEllipse(bpos:ToScreen(),Vector(w,h,0),Color(255,255,0,255) )
*/
	//

	JetFighter.HUDTargetting()
	JetFighter.HUDhealth()
	JetFighter.HUDradar()

end

function JetFighter.HP() --Display ennemies remaining health, would help to seek the weakest one! ;D
	for k,v in pairs( ents.FindByClass( "sent*" ) ) do
		if ( IsValid( v ) && v.PrintName && v != JetFighter.Plane && ( v.Type == "vehicle" || ( v.PrintName == "Missile" ) ) ) then
			
			local pos = v:GetPos():ToScreen( )
			local x,y = pos.x, pos.y
			if( inLOS( JetFighter.Plane, v ) ) then
				local hp = math.floor( v:GetNetworkedInt( "health" ) )
				local maxhp = math.floor( v:GetNetworkedInt( "MaxHealth", 0 ) )
				local h = hp / maxhp

				if hp && maxhp && x < ScrW()+25 && x > 25 && y < ScrH()-5 && y > 5 then

					if h<=0 then h = 0 end
					draw.RoundedBox(0, x-16, y +16, 32*h, 5, Color(255*(1-h),255*h,0,255))				
				end
			end
		end
	end

	for k,v in pairs( ents.FindByClass( "npc*" ) ) do
		
		local pos = ( v:GetPos() + Vector(0,0,72 ) ):ToScreen( )
		local x,y = pos.x, pos.y
			if( inLOS( JetFighter.Plane, v ) ) then
			local hp = math.floor( v:GetNetworkedInt( "health" ) )
			local maxhp = math.floor( v:GetNetworkedInt( "MaxHealth", 0 ) )
			local h = hp / maxhp
			
				if hp && maxhp && x < ScrW()+25 && x > 25 && y < ScrH()-5 && y > 5 then

					if h<=0 then h = 0 end
					draw.RoundedBox(0, x-25, y - 20, 50*h, 5, Color(255*(1-h),255*h,0,255))				
				end
			end
	end

end 

function JetFighter.MarkEnemies()
	
	if( !IsValid( JetFighter.Plane ) ) then return end 
	
	local count = 0
	local size = 30
	local NTeam = JetFighter.Plane:GetNetworkedInt( "NeuroTeam", 1 )
	
	for k,v in pairs( ents.FindByClass( "sent*" ) ) do

		if ( IsValid( v ) && v.PrintName && v != JetFighter.Plane && ( v.Type == "vehicle" || ( v.PrintName == "Missile" ) ) ) then
			
			local pos = v:GetPos():ToScreen( )
			local x,y = pos.x, pos.y
			local TargetTeam = v:GetNetworkedInt( "NeuroTeam", 0 )
			
			if( inLOS( JetFighter.Plane, v ) ) then
			
				if ( TargetTeam == NTeam ) and ( TargetTeam > 0 ) then
					
					local extra = ""
					if( IsValid( v:GetNetworkedEntity("Pilot",NULL) ) ) then
						
						extra = " - "..tostring(v:GetNetworkedEntity("Pilot",NULL):Name())
						
					end
					
					if ( v:GetModel() == JetFighter.Plane:GetModel() ) then
						draw.SimpleText( v.PrintName..extra, "ChatFont", x, y - 30, Color( 0, 255, 255, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
					else
						draw.SimpleText( v.PrintName..extra, "ChatFont", x, y - 30, Color( 0, 150, 255, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
					end
				else
					
					local target = v:GetNetworkedEntity( "Target", NULL )

					if ( target && IsValid( target ) && ( target == JetFighter.Plane || target == JetFighter.Pilot ) ) then
						
						draw.SimpleText( "Warning", "ChatFont", x, y - 15, Color( 204, 51, 0, 240 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
						count = count + 1
						
					end
				
					if( v.PrintName == "Missile" ) then

						//draw.SimpleText( "Missile", "ChatFont", x, y, Color( 255, 40, 0, 200 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
					
					else
					
						draw.SimpleText( v.PrintName, "ChatFont", x, y - 30, Color( 255, 102, 0, 240 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
						surface.DrawCircle( x, y, 8, Color( 255, 0, 0, 255) ) 
					end
					
				
				end
			
				if ( IsValid( JetFighter.Target ) && JetFighter.Target != JetFighter.Plane && v == JetFighter.Target ) then
					
					draw.SimpleText( "Locked On", "ChatFont", x, y, Color( 255, 0, 0, 240 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
					
				end
			
			end
			
		end
	
	end
	
	for k,v in pairs( ents.FindByClass( "npc*" ) ) do
		
		local pos = ( v:GetPos() + Vector(0,0,72 ) ):ToScreen( )
		local x,y = pos.x, pos.y
		
		if( IsValid( v ) && inLOS( JetFighter.Plane, v ) ) then
			
			if ( v:OnGround() ) then
			
				draw.SimpleText( "Unit", "ConsoleText", x, y - 35, Color( 255, 102, 0, 240 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
			
			else
				
				if( v:GetNetworkedEntity( "Guardian_Object", NULL ) == LocalPlayer() ) then
						
					draw.SimpleText( "Escort", "ChatFont", x, y - 35, Color( 25, 255, 0, 240 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
					
				else
				
					if( v.PrintName ) then
					
						draw.SimpleText( v.PrintName, "ChatFont", x, y - 35, Color( 255, 102, 0, 240 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
						
					else
					
						draw.SimpleText( "Enemy", "ChatFont", x, y - 35, Color( 255, 102, 0, 240 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
					
					end
				//surface.SetMaterial( targetMat )
				//surface.DrawTexturedRect( x - size / 2, y - size / 2, size, size )

				end
				
			end

			if ( IsValid( JetFighter.Target ) && JetFighter.Target != JetFighter.Plane && v == JetFighter.Target ) then
			
				draw.SimpleText( "Locked On", "ChatFont", x, y, Color( 255, 0, 0, 240 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
					
			end
			
			
			local target = v:GetNetworkedEntity( "Target", NULL )
					
			if ( IsValid( target ) && target == JetFighter.Plane && target:GetNetworkedEntity("Guardian_Object", NULL ) != LocalPlayer() ) then
				
				draw.SimpleText( "Warning", "ChatFont", x, y - 15, Color( 204, 51, 0, 240 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
				count = count + 1
			
			end
		
		end
		
	end

-- Need to use a new name base for npc plane ex: ai_AH-64.	
-- /*	for k,v in pairs( ents.FindByClass( "ai*" ) ) do
		--"same as in: ents.FindByClass( "npc*" ) "
	-- end
-- */
	
	if( !JetFighter.Plane || !JetFighter.Pilot || !IsValid( JetFighter.Plane ) || !IsValid( JetFighter.Pilot ) ) then return end
	
	for k,v in pairs( player.GetAll() ) do
		
		if ( v:GetPos():Distance( JetFighter.Plane:GetPos() ) < 15500 && v != JetFighter.Pilot ) then
			
			if ( v:OnGround() && !v.ColdBlooded && inLOS( JetFighter.Plane, v ) ) then
				
				local pos = ( v:GetPos() + Vector( 0, 0, 82 ) ):ToScreen( )
				local x,y = pos.x, pos.y
				draw.SimpleText( v:GetName(), "ChatFont", x + 15, y, Color( 45, 255, 45, 240 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
				
				if ( IsValid( JetFighter.Target ) && JetFighter.Target != JetFighter.Plane && v == JetFighter.Target ) then
				
					draw.SimpleText( "Locked On", "ChatFont", x, y, Color( 255, 0, 0, 240 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
						
				end
				
			end
		
		end
		
	end
	
	if( count > 0 ) then
		
		JetFighter.DrawWarning = true

		
	else
	
		JetFighter.DrawWarning = false
	
	end
	
end
local function BombingImpact( ent, v0,pitch)

	local pos = ent:GetPos()+Vector(0,0,-50)
	local ang = ent:GetAngles()

	local trace,tr = {},{}
	tr.start = pos
	tr.endpos = tr.start + Vector( 0,0, -1000000 )
	tr.filter = { ent.Pilot, ent, ent.Weapon, ent.Wings, ent.Tail }
	tr.mask = MASK_SOLID
	trace = util.TraceEntity( tr, ent )

	local h = pos.z - trace.HitPos.z
	local R = v0*math.abs( math.sin(math.rad(-ang.p))* math.sqrt( 2*h/600 ) )
	

	local ImpactPos = pos + ent:GetForward()*R + Vector(0,0,-h)
	return ImpactPos
	
end

function JetFighter.DrawCrosshair( )
	
	JetFighter.Target = JetFighter.Plane:GetNetworkedEntity( "Target", NULL )
	
	local offs = JetFighter.Plane:GetNetworkedInt( "HudOffset", 0 )
	local pos =  ( JetFighter.Plane:GetPos( ) + JetFighter.Plane:GetUp( ) * offs + JetFighter.Plane:GetForward( ) * 3000 ):ToScreen()
	local x,y = pos.x, pos.y
	local size = 48

	local trace,tr = {},{}
	tr.start = JetFighter.Plane:GetPos() + JetFighter.Plane:GetUp() * offs + JetFighter.Plane:GetForward() * 1000
	tr.endpos = tr.start + JetFighter.Plane:GetUp() * offs + JetFighter.Plane:GetForward() * 9000
	tr.filter = JetFighter.Plane
	tr.mask = MASK_SOLID
	trace = util.TraceLine( tr )
	
	local t = trace.Entity
	
	local logic = ( !trace.HitWorld && !trace.HitSky && IsValid( t ) && 
					( t:IsNPC() 					 ||
					t:IsPlayer() 					 || 
					t:IsVehicle() 					 || 
					( t:GetNetworkedInt("Health", 0 ) != 0 ) && 
					t:GetOwner() != JetFighter.Plane && 
					t:GetOwner() != JetFighter.Pilot ) )
		-- local r = math.rad( 100*JetFighter.Plane:GetAngles().r-60)/180
		local r = math.rad( JetFighter.Plane:GetAngles().r) + math.rad( JetFighter.Pilot:EyeAngles().r)
		local cosr = math.cos(r)
		local sinr = math.sin(r)
	local lockwarning
	if JetFighter.DrawWarning then lockwarning = 255 else lockwarning = 0 end

	if( GetConVarNumber("jet_HUD") == 0 ) then
		if( logic ) then
			
			surface.SetDrawColor( 255, 0, 0, 255 )
			surface.DrawOutlinedRect( pos.x - ( ( size + 5 ) / 2 ), pos.y - ( ( size + 5 ) / 2 ), size + 5, size + 5 ) 
			
		else
		
			surface.SetDrawColor( 0, 255, 0, 255 )
			
		end
		
		surface.SetMaterial(  ch_green )
		surface.DrawTexturedRect( pos.x - size / 2, pos.y - size / 2, size, size )
		
	else
	
		local X,Y = x,y
		if( GetConVarNumber("jet_cockpitview",0) == 0 ) then
			surface.SetDrawColor( 0, 255, 0, 255 )
			surface.DrawCircle( X, Y, 10, Color( 5, 235, 5, 255) ) --grey horizon circle
			surface.DrawCircle( X, Y, 9, Color( 5, 205, 5, 55) ) --grey horizon circle
			surface.DrawCircle( X, Y, 11, Color( 5, 205, 5, 55) ) --grey horizon circle
			surface.DrawCircle( X, Y, 1, Color( 5, 235, 5, 255) ) --aiming dot
		else
			surface.SetDrawColor( 0, 255, 0, 100 )
			surface.DrawCircle( X, Y, 8, Color( 0, 255, 0, 100) ) --horizon circle
					
			surface.DrawLine( X+8*sinr, Y-8*cosr, X+20*sinr, Y-20*cosr ) --up
			surface.DrawLine( X-8*cosr, Y-8*sinr, X-20*cosr, Y-20*sinr ) --left
			surface.DrawLine( X+8*cosr, Y+8*sinr, X+20*cosr, Y+20*sinr ) --right
							
		end
		
		-- if( GetConVarNumber("jet_cockpitview",0) >  0 ) then
		
		if( JetFighter.Plane.WingModels ) then
			
			JetFighter.Pilot.ImpactPos =  BombingImpact( JetFighter.Plane, JetFighter.Plane:GetVelocity():Length()*1.8, JetFighter.Plane:GetAngles().p ) --JetFighter.Plane:GetNWVector("ImpactPos", Vector(0,0,0) )
			
			if( JetFighter.Pilot.ImpactPos != Vector(0,0,0) ) then
				
				local IP = JetFighter.Pilot.ImpactPos:ToScreen()
				surface.DrawCircle( IP.x, IP.y, 32, Color( 167, 167, 255, 180) ) 
			
			end
					
			JetFighter.OldSchoolCrosshair()
			
		end
		
		-- end

	end

end

function JetFighter.OldSchoolCrosshair()

	local tpos = ( JetFighter.Plane:GetPos() + LocalPlayer():EyeAngles():Forward() * 3500 + JetFighter.Plane:GetUp() * 300 ):ToScreen()
	local size,l = 16, 8
	surface.DrawCircle( tpos.x, tpos.y, 16, Color(255,200,50,100) )
	surface.SetDrawColor(255,200,50,255)
	surface.DrawLine( tpos.x-size, tpos.y, tpos.x-l, tpos.y )
	surface.DrawLine( tpos.x+size, tpos.y, tpos.x+l, tpos.y )
	surface.DrawLine( tpos.x, tpos.y-size, tpos.x, tpos.y-l )
	surface.DrawLine( tpos.x, tpos.y+size, tpos.x, tpos.y+l )
	
	//Primary cooldown indicator
	local shots = JetFighter.Plane:GetNetworkedInt("FiringTimer")
	local maxshots = JetFighter.Plane.PrimaryMaxShots or 25
	local ratio = shots/maxshots
	local cd1 = JetFighter.Plane.PrimaryCooldown
	local lpa = JetFighter.Plane:GetNetworkedFloat("LastPrimaryAttack") -CurTime() + cd1	

	surface.DrawOutlinedRect( tpos.x -36, tpos.y-size, 4, size*2)		
	if (lpa != nil) and (shots ==0) then
		if lpa <0 then lpa = 0 end
		surface.SetDrawColor( 255, 50, 0, 200)
		surface.DrawRect( tpos.x -36, tpos.y-size*(2*lpa/cd1-1), 4, size*2*lpa/cd1 )		
	else
		surface.SetDrawColor( 255, 50, 0, 200)
		surface.DrawRect( tpos.x -36, tpos.y-size*(2*ratio-1), 4, size*2*ratio )
	end
	//Secondary cooldown indicator
	if ( !JetFighter.Plane.NoSecondaryWeapons && JetFighter.Plane.Armament && #JetFighter.Plane.Armament > 0 )  then
	
		
		local index = JetFighter.Plane:GetNetworkedInt("FireMode")
		local idx = index+1 
		if( #JetFighter.Plane.Armament < idx ) then idx = index end 
		local cd2 = JetFighter.Plane.Armament[idx].Cooldown

		local lsa = JetFighter.Plane:GetNetworkedFloat("LastSecondaryAttack") -CurTime() + cd2	
		if (lsa != nil) then
			if lsa <0 then lsa = 0 end
			surface.SetDrawColor(255,200,50,255)		
			surface.DrawOutlinedRect( tpos.x +32, tpos.y-size, 4, size*2)		
			surface.SetDrawColor( 255, 50, 0, 200)
			surface.DrawRect( tpos.x +32, tpos.y-size*(2*lsa/cd2-1), 4, size*2*lsa/cd2 ) 
		end
	end	
end

function JetFighter.HUDinstruments(dangerzone)

	local spd = JetFighter.Plane:GetVelocity():Length()
	local maxspd = math.floor( JetFighter.Plane:GetNetworkedInt( "MaxSpeed", 0 ) )
	
	//Compass (From NNaval)
	local yaw =(-JetFighter.Plane:GetAngles().y/360)
	local width,height = 256, 16
	local x,y = ScrW()/2-width/2, 5
	surface.SetTexture(compass) //Top bars
	surface.SetDrawColor( plyHUDcolor ,255 )
	surface.DrawTexturedRectUV( x, y, width, height, yaw , 0, yaw+0.4, 1 )
	surface.SetTexture(compass_letters) ////top letters
	surface.SetDrawColor( plyHUDcolor ,200 )
	surface.DrawTexturedRectUV( x, y+height, width, height, yaw, 0, yaw+0.4,1 )
	DrawHUDOutlineRect(Vector(x,y,0),width,2*height,plyHUDcolor)

	
	//Airspeed
	local size = 100
	local sposX, sposY = size*1.1, ScrH()-size*1.1
	local spdmod = 2*math.pi*spd/maxspd
	DrawHUDEllipse(Vector(sposX,sposY,0) ,Vector(size,size,0),Color(100,100,100,200))
	surface.DrawCircle( sposX, sposY, size*0.2, Color(100,100,100,200) )
	draw.SimpleText( math.floor(spd/1.8), "TargetID", sposX, sposY-8, Color(255, 255-dangerzone, 255-dangerzone, 200), TEXT_ALIGN_CENTER, TEXT_ALIGN_LEFT )		
	DrawHUDLine( Vector(sposX+size*0.2*math.cos(spdmod),sposY+size*0.2*math.sin(spdmod),0), Vector(sposX+size*math.cos(spdmod), sposY+size*math.sin(spdmod)), Color(255,0,0,200) )
	
end

function JetFighter.HUDindicators(dangerzone)

//throttle indicator
	local spd = math.floor( JetFighter.Plane:GetVelocity():Length() / 1.8 )
	local maxspd = math.floor( JetFighter.Plane:GetNetworkedInt( "MaxSpeed", 0 ) )
	local thr = JetFighter.Plane:GetNetworkedInt( "Throttle", nil )
	local ratio = math.Clamp( 100*(JetFighter.Plane:GetNetworkedInt( "Throttle", (( JetFighter.Plane:GetVelocity():Length() )) ) )/maxspd, 0, 100) 
	local size = 32
	
	surface.SetDrawColor( 255, 255, 255, 200)
	surface.DrawOutlinedRect( size, ScrH()-size*4, size, size*3) //box
	surface.DrawOutlinedRect( size-1, ScrH()-size*4-1, size+2, size*3+2)

	surface.DrawOutlinedRect( size-5, ScrH()-size, size+10, 16 ) //speed textbox
	draw.SimpleText( math.floor(spd), "TargetID", size+35, ScrH()-size, Color(255, 255-dangerzone, 255-dangerzone, 200), TEXT_ALIGN_RIGHT, TEXT_ALIGN_LEFT )		

	surface.SetDrawColor( 100, 100, 100, 200)
	surface.DrawRect( size+1 , ScrH()-size*4+1, size-2, size*3-2 ) //lever_background
	surface.SetDrawColor( 55, 55, 55, 255)
	-- surface.DrawRect( size-1 , ScrH()-5-size*(1+3*thr/100)+(6*thr/100), size+2, 4 ) //throttle lever
	surface.DrawRect( size-1 , ScrH()-5-size*(1+3*ratio/100)+(6*ratio/100), size+2, 4 ) //throttle lever




end

function JetFighter.HUDhealth()

	local hp = math.floor( JetFighter.Plane:GetNetworkedInt( "Health", 0 ) )
	local maxhp = math.floor( JetFighter.Plane:GetNetworkedInt( "MaxHealth", 0 ) )
	local h = hp / maxhp
	local posX,posY,size = ScrW()*0.85, ScrH()*0.4, 128

	//Health value indicator
	draw.SimpleText( ""..math.floor(100*h).."%", "TargetID", posX+90,posY+64, Color(255*(1-h),255*h,0,255), TEXT_ALIGN_RIGHT, TEXT_ALIGN_LEFT )		

	if( !JetFighter.FadeValue ) then JetFighter.FadeValue = 0 end 
	
	if IsValid( JetFighter.Pilot ) && IsValid( JetFighter.Plane ) && JetFighter.Pilot && JetFighter.Pilot.PlaneParts && JetFighter.Plane.Category == "NeuroTec Micro" then

		JetFighter.FadeValue = math.Approach(  JetFighter.FadeValue, 55, 0.5 )

		local parts_hp = {}
		local engines_hp = {}
		local parts_color={}
		local engines_color={}
		local normal,damaged,critical,destroyed = Color(255, 255, 255, JetFighter.FadeValue ),Color(255, 150, 0, JetFighter.FadeValue ), Color(255, 0, 0, JetFighter.FadeValue ), Color(0, 0, 0, 255)
/*		
: local parts = { 
plane, 					1
plane.Tail, 			2
plane.Wings[1], 		3
plane.Wings[2], 		4
plane.Ailerons[1], 		5
plane.Ailerons[2], 		6
plane.Flaps[1], 		7
plane.Flaps[2],			8
plane.Elevator, 		9
plane.Rudder 			10
}
*/	
		for i = 1, #JetFighter.Pilot.PlaneParts do
			if( IsValid(JetFighter.Pilot.PlaneParts[i] ) ) then 				
				 if( !JetFighter.Pilot.PlaneParts[i].MaxHealth ) then JetFighter.Pilot.PlaneParts[i].MaxHealth =  JetFighter.Pilot.PlaneParts[i]:GetNetworkedInt("MaxHealth",400) end
				parts_hp[i] = JetFighter.Pilot.PlaneParts[i]:GetNetworkedInt("Health")/JetFighter.Pilot.PlaneParts[i]:GetNetworkedInt("MaxHealth")

				if (parts_hp[i] <= 0.1) then parts_color[i] = destroyed
				elseif (parts_hp[i] > 0.5) and (parts_hp[i] <= 0.9) then parts_color[i] = damaged
				elseif (parts_hp[i] > 0.1) and (parts_hp[i] <= 0.5) then parts_color[i] = critical
				else parts_color[i] = normal		
				end				
				if( IsValid(JetFighter.Pilot.PlaneParts[1] ) ) then 				
					if (JetFighter.Pilot.PlaneParts[i]:GetPos()-JetFighter.Pilot.PlaneParts[1]:GetPos()):Length()>150 then parts_color[i] = destroyed end  //Any better idea?
				end
			end
			
		end
		
		local k = 1
		
		if type( JetFighter.Pilot.PlaneParts[1].PropellerPos ) == "table" then k = #JetFighter.Pilot.PlaneParts[1].PropellerPos end	
		if type( JetFighter.Pilot.PlaneParts[1].ExhaustPos ) == "table" and JetFighter.Pilot.PlaneParts[1].NoPropeller then k = #JetFighter.Pilot.PlaneParts[1].ExhaustPos end	
		if k == 2 then posX,posY,size = ScrW()*0.85-32, ScrH()*0.4-32, size*1.5 end
		if k == 4 then posX,posY,size = ScrW()*0.85-64, ScrH()*0.4-64, size*2 end
		
		if( IsValid( JetFighter.Pilot.PlaneParts[1] ) ) then
			surface.SetDrawColor( parts_color[1] )
			surface.SetMaterial( planeicon_materials["planeicon_"..k.."engine_fuselage"])		surface.DrawTexturedRect( posX, posY, size, size )
		end	
		if( IsValid( JetFighter.Pilot.PlaneParts[2] ) ) then
			surface.SetDrawColor( parts_color[2] )
			surface.SetMaterial( planeicon_materials["planeicon_"..k.."engine_tail"])		surface.DrawTexturedRect( posX, posY, size, size )			
		end	
		if( IsValid( JetFighter.Pilot.PlaneParts[3] ) ) then
			surface.SetDrawColor( parts_color[3] )
			surface.SetMaterial( planeicon_materials["planeicon_"..k.."engine_leftwing"])	surface.DrawTexturedRect( posX, posY, size, size )
		end	
		if( IsValid( JetFighter.Pilot.PlaneParts[4] ) ) then		
			surface.SetDrawColor( parts_color[4] )
			surface.SetMaterial( planeicon_materials["planeicon_"..k.."engine_rightwing"])		surface.DrawTexturedRect( posX, posY, size, size )
		end	
		if( IsValid( JetFighter.Pilot.PlaneParts[5] ) ) then	
			surface.SetDrawColor( parts_color[5] )
			surface.SetMaterial( planeicon_materials["planeicon_"..k.."engine_leftaileron"])		surface.DrawTexturedRect( posX, posY, size, size )
		end	
		if( IsValid( JetFighter.Pilot.PlaneParts[6] ) ) then	
			surface.SetDrawColor( parts_color[6] )
			surface.SetMaterial( planeicon_materials["planeicon_"..k.."engine_rightaileron"])		surface.DrawTexturedRect( posX, posY, size, size )
		end	
		/*
		if( IsValid( JetFighter.Pilot.PlaneParts[7] ) ) then			
			surface.SetDrawColor( parts_color[7] )
			surface.SetMaterial( planeicon_materials["planeicon_"..k.."engine_leftflap"])	surface.DrawTexturedRect( posX, posY, size, size )
		end	
		if( IsValid( JetFighter.Pilot.PlaneParts[8] ) ) then						
			surface.SetDrawColor( parts_color[8] )
			surface.SetMaterial( planeicon_materials["planeicon_"..k.."engine_rightflap"])	surface.DrawTexturedRect( posX, posY, size, size )
		end	
		*/
		if( IsValid( JetFighter.Pilot.PlaneParts[9] ) ) then						
			surface.SetDrawColor( parts_color[9] )
			surface.SetMaterial( planeicon_materials["planeicon_"..k.."engine_elevator"])		surface.DrawTexturedRect( posX, posY, size, size )
		end	
		if( IsValid( JetFighter.Pilot.PlaneParts[10] ) ) then						
			surface.SetDrawColor( parts_color[10] )
			surface.SetMaterial( planeicon_materials["planeicon_"..k.."engine_rudder"])		surface.DrawTexturedRect( posX, posY, size, size )
		end	

			if type(JetFighter.Pilot.PlaneParts[1].PropellerPos)  == "Vector" then			
			engines_hp[1] = JetFighter.Pilot.PlaneParts[1]:GetNetworkedInt("EngineHealth_1")/JetFighter.Pilot.PlaneParts[1]:GetNetworkedInt("EngineMaxHealth_1")
				if engines_hp[1] <= 0.1 then engines_color[1] = destroyed	elseif (engines_hp[1] < 0.5) then engines_color[1] = critical else engines_color[1] = normal end
				surface.SetDrawColor( engines_color[1] )
				surface.SetMaterial( planeicon_materials["planeicon_"..k.."engine_engine1"])		surface.DrawTexturedRect( posX, posY, size, size )
			end
			if JetFighter.Pilot.PlaneParts[1].NoPropeller and type(JetFighter.Pilot.PlaneParts[1].ExhaustPos)  == "Vector" then			
			engines_hp[1] = JetFighter.Pilot.PlaneParts[1]:GetNetworkedInt("EngineHealth_1")/JetFighter.Pilot.PlaneParts[1]:GetNetworkedInt("EngineMaxHealth_1")
				if engines_hp[1] <= 0.1 then engines_color[1] = destroyed	elseif (engines_hp[1] < 0.5) then engines_color[1] = critical else engines_color[1] = normal end
				surface.SetDrawColor( engines_color[1] )
				surface.SetMaterial( planeicon_materials["planeicon_"..k.."engine_engine1"])		surface.DrawTexturedRect( posX, posY, size, size )
			end
			
		if type( JetFighter.Pilot.PlaneParts[1].PropellerPos ) == "table"	then		
			for j=1,#JetFighter.Pilot.PlaneParts[1].PropellerPos do		
				engines_hp[j] = JetFighter.Pilot.PlaneParts[1]:GetNetworkedInt("EngineHealth_"..j)/JetFighter.Pilot.PlaneParts[1]:GetNetworkedInt("EngineMaxHealth_"..j)
				if engines_hp[j] <= 0.1 then engines_color[j] = destroyed	elseif (engines_hp[j] < 0.5) then engines_color[j] = critical else engines_color[j] = normal end
					surface.SetDrawColor( engines_color[j] )
					surface.SetMaterial( planeicon_materials["planeicon_"..k.."engine_engine"..j..""])		surface.DrawTexturedRect( posX, posY, size, size )
			end
		end
		if type( JetFighter.Pilot.PlaneParts[1].ExhaustPos ) == "table" and JetFighter.Pilot.PlaneParts[1].NoPropeller then		
			for j=1,#JetFighter.Pilot.PlaneParts[1].ExhaustPos do		
				engines_hp[j] = JetFighter.Pilot.PlaneParts[1]:GetNetworkedInt("EngineHealth_"..j)/JetFighter.Pilot.PlaneParts[1]:GetNetworkedInt("EngineMaxHealth_"..j)
				if engines_hp[j] <= 0.1 then engines_color[j] = destroyed	elseif (engines_hp[j] < 0.5) then engines_color[j] = critical else engines_color[j] = normal end
					surface.SetDrawColor( engines_color[j] )
					surface.SetMaterial( planeicon_materials["planeicon_"..k.."engine_engine"..j..""])		surface.DrawTexturedRect( posX, posY, size, size )
			end
		end	
	else
	draw.SimpleText( "Armor","TargetID", posX+90,posY+48, Color(255*(1-h),255*h,0,255), TEXT_ALIGN_RIGHT, TEXT_ALIGN_LEFT )			
	end
end

function JetFighter.HUDradar()

	local lockwarning
	if JetFighter.DrawWarning then lockwarning = 255 else lockwarning = 0 end

	//Radar
	if( GetConVarNumber("jet_radar") > 0 ) then				
		local RadarSize = ScrW()/6
		local offsetX,offsetY = ScrW()*0.8,-16*6-RadarSize-10  -ScrH()*0.5
		-- surface.SetDrawColor( lockwarning, 255-lockwarning, 0, 25)
		surface.SetDrawColor( 255, 255-lockwarning, 255-lockwarning, 25)
		surface.DrawRect(offsetX, ScrH()+offsetY, RadarSize, RadarSize )
		-- surface.SetDrawColor( lockwarning, 255-lockwarning, 0, 150)
		surface.SetDrawColor( 255, 255-lockwarning, 255-lockwarning, 150)
		surface.DrawLine( offsetX, ScrH()+offsetY, RadarSize+offsetX, ScrH()+offsetY+RadarSize )
		surface.DrawLine( offsetX, ScrH()+offsetY+RadarSize, RadarSize+offsetX, ScrH()+offsetY )
		surface.DrawLine( offsetX, ScrH()+offsetY, offsetX, ScrH()+offsetY+RadarSize )
		surface.DrawLine( RadarSize+offsetX, ScrH()+offsetY, RadarSize+offsetX, ScrH()+offsetY+RadarSize )
		surface.DrawLine( offsetX, ScrH()+offsetY, RadarSize+offsetX, ScrH()+offsetY )
		surface.DrawLine( offsetX, ScrH()+offsetY+RadarSize, RadarSize+offsetX, ScrH()+offsetY+RadarSize )

		local yaw = math.rad( JetFighter.Plane:GetAngles().y+90)
		local cosy = math.cos(yaw)
		local siny = math.sin(yaw)
		
		surface.DrawCircle( offsetX + RadarSize/2, ScrH()+offsetY+RadarSize/2, RadarSize/2, Color( 255, 255-lockwarning, 255-lockwarning,255 ))
		draw.SimpleText( "S", "BudgetLabel", offsetX + RadarSize/2 + cosy*RadarSize*7/15, ScrH()+offsetY+RadarSize/2 + siny*RadarSize*7/15, Color( 255, 255-lockwarning, 255-lockwarning, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
		draw.SimpleText( "E", "BudgetLabel", offsetX + RadarSize/2 - siny*RadarSize*7/15, ScrH()+offsetY+RadarSize/2 + cosy*RadarSize*7/15, Color( 255, 255-lockwarning, 255-lockwarning, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
		draw.SimpleText( "N", "BudgetLabel", offsetX + RadarSize/2 - cosy*RadarSize*7/15, ScrH()+offsetY+RadarSize/2 - siny*RadarSize*7/15, Color( 255, 255-lockwarning, 255-lockwarning, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
		draw.SimpleText( "W", "BudgetLabel", offsetX + RadarSize/2 + siny*RadarSize*7/15, ScrH()+offsetY+RadarSize/2 - cosy*RadarSize*7/15, Color( 255, 255-lockwarning, 255-lockwarning, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
	end	

end

function JetFighter.ModernHUD(lockwarning)

	local Yaw = math.floor( JetFighter.Plane:GetAngles().y ) + 180
	local maxspd = math.floor( JetFighter.Plane:GetNetworkedInt( "MaxSpeed", 0 ) )
//	local throttle =  ( JetFighter.Plane:GetVelocity():Length() * 100) / maxspd
	local throttle = 100*(JetFighter.Plane:GetNetworkedInt( "Throttle", (( JetFighter.Plane:GetVelocity():Length() )) ) )/maxspd
	local throttle2 = math.floor( JetFighter.Plane:GetNetworkedInt( "Throttle", nil ) )
	local spd = math.floor( JetFighter.Plane:GetVelocity():Length() / 1.8 )
	local hp = math.floor( JetFighter.Plane:GetNetworkedInt( "Health", 0 ) )
	local maxhp = math.floor( JetFighter.Plane:GetNetworkedInt( "MaxHealth", 0 ) )
	local h = hp / maxhp
	local wep = JetFighter.Plane:GetNetworkedString("NeuroPlanes_ActiveWeapon",tostring("NONE_AVAILABLE")) -- should this really be necessary?
	local NTeam = JetFighter.Plane:GetNetworkedInt( "NeuroTeam", 1 )
	local flares = 	JetFighter.Plane:GetNetworkedInt( "FlareCount", 0 )
	local flarestatus
	if flares < 1 then flarestatus = 255 else flarestatus = 0 end
	local locking
	if ( IsValid( JetFighter.Target ) ) then locking = 255 else locking = 0 end

	surface.SetDrawColor( lockwarning, 255-lockwarning, 0, 200)
	//Artificial horizon that must work only for planes
	if (JetFighter.Plane.VehicleType == VEHICLE_PLANE ) then --Only jets can use extra boost		
		JetFighter.Target = JetFighter.Plane:GetNetworkedEntity( "Target", NULL )
		local offs = JetFighter.Plane:GetNetworkedInt( "HudOffset", 0 )
		local pos =  ( JetFighter.Plane:GetPos( ) + JetFighter.Plane:GetUp( ) * offs + JetFighter.Plane:GetForward( ) * 3000 ):ToScreen()
		local x,y = pos.x, pos.y
		local HorizonPoint = (JetFighter.Plane:GetPos() + JetFighter.Plane:GetUp( ) * offs +JetFighter.Plane:GetForward()*10000):ToScreen( )
		local X,Y = HorizonPoint.x, HorizonPoint.y
		-- local r = math.rad( 100*JetFighter.Plane:GetAngles().r-60)/180
		local r = math.rad( JetFighter.Plane:GetAngles().r) + math.rad( JetFighter.Pilot:EyeAngles().r)
		local cosr = math.cos(r)
		local sinr = math.sin(r)
		local p = math.rad(JetFighter.Plane:GetAngles().p)
		local Pi = math.pi
		
		surface.DrawLine( x, y, x-16*math.cos(-r+Pi/3), y+16*math.sin(-r+Pi/3) )
		surface.DrawLine( x-16*math.cos(-r+Pi/3), y+16*math.sin(-r+Pi/3), x-16*cosr, y-16*sinr )
		surface.DrawLine( x-16*cosr, y-16*sinr, x-32*cosr, y-32*sinr )
		
		surface.DrawLine( x, y, x+16*math.cos(r+Pi/3), y+16*math.sin(r+Pi/3) )
		surface.DrawLine( x+16*math.cos(r+Pi/3), y+16*math.sin(r+Pi/3), x+16*cosr, y+16*sinr )
		surface.DrawLine( x+16*cosr, y+16*sinr, x+32*cosr, y+32*sinr )

		local HorizonBar = ScrW()/12
		surface.DrawLine( x-48*cosr, y-48*sinr, x-HorizonBar*cosr, y-HorizonBar*sinr )
		surface.DrawLine( x+48*cosr, y+48*sinr, x+HorizonBar*cosr, y+HorizonBar*sinr )		
	end

	//Brackets
	if (JetFighter.Plane.VehicleType == VEHICLE_PLANE ) or 	(JetFighter.Plane.VehicleType == VEHICLE_HELICOPTER ) then	
		--Left
		surface.DrawOutlinedRect( ScrW()/4-2 , ScrH()/2-250, 5, 500 )
		surface.DrawLine( ScrW()/4-2 , ScrH()/2-250, ScrW()/4+8, ScrH()/2-250 )
		surface.DrawLine( ScrW()/4-2 , ScrH()/2+250, ScrW()/4+8, ScrH()/2+250 )
		local bracketadjust
		if ( JetFighter.Plane:GetNetworkedInt( "Throttle", false) ) then bracketadjust = 97 else bracketadjust = 0 end
		surface.DrawRect( ScrW()/4-2 , ScrH()/2+250 - throttle*(340+bracketadjust)/100, 5, throttle*(340+bracketadjust)/100 )
		--Right
		surface.DrawOutlinedRect( ScrW()*3/4+2, ScrH()/2-250, 5, 500 )
		surface.DrawLine( ScrW()*3/4+2, ScrH()/2-250, ScrW()*3/4-8, ScrH()/2-250 )
		surface.DrawLine( ScrW()*3/4+2, ScrH()/2+250, ScrW()*3/4-8, ScrH()/2+250 )
		surface.DrawRect( ScrW()*3/4+2, ScrH()/2-250 + 500*(1-h), 5, h*500 )
	end
		
	//Equipment
	draw.SimpleText("Countermeasures:"..flares, "TargetID", ScrW()*5/6-48, ScrH()*4/5+25, Color( flarestatus, 255-flarestatus, 0, 200 ), TEXT_ALIGN_LEFT, TEXT_ALIGN_LEFT )
	if ( wep != "NONE_AVAILABLE" ) then
		draw.SimpleText( wep, "TargetID", ScrW()*5/6-48, ScrH()*4/5+40, Color( 0, 255, 0, 200 ), TEXT_ALIGN_LEFT, TEXT_ALIGN_LEFT )		
	end

	//Speed
	surface.DrawOutlinedRect(ScrW()/6, ScrH()/2-25, 50, 17 )
	draw.SimpleText("SPEED", "TargetID", ScrW()/6+2, ScrH()/2-28, Color( lockwarning, 255-lockwarning, 0, 200 ), TEXT_ALIGN_LEFT, TEXT_ALIGN_LEFT )
	draw.SimpleText(math.floor(spd), "TargetID", ScrW()/6+48, ScrH()/2-5, Color( lockwarning, 255-lockwarning, 0, 200 ), TEXT_ALIGN_RIGHT, TEXT_ALIGN_RIGHT )

	draw.SimpleText( "Throttle: "..math.floor(throttle).."%", "TargetID", ScrW()/4-30, ScrH()/2+260, Color(lockwarning, 255-lockwarning, 0, 200), TEXT_ALIGN_LEFT, TEXT_ALIGN_LEFT )		
	//Altitude
	surface.DrawOutlinedRect(ScrW()*5/6-50, ScrH()/2-25, 35, 17 )
	draw.SimpleText("ALT", "TargetID", ScrW()*5/6-48, ScrH()/2-28, Color( lockwarning, 255-lockwarning, 0, 200 ), TEXT_ALIGN_LEFT, TEXT_ALIGN_LEFT )
	draw.SimpleText( math.floor(JetFighter.Plane:GetPos().z - AverageHeight), "TargetID", ScrW()*5/6-48, ScrH()/2-5, Color( lockwarning, 255-lockwarning, 0, 200 ), TEXT_ALIGN_LEFT, TEXT_ALIGN_LEFT )

	//Cap
	surface.DrawOutlinedRect( ScrW()/2- 17 , 100, 35, 17 )
	draw.SimpleText( math.floor(Yaw), "TargetID", ScrW()/2, 108, Color( lockwarning, 255-lockwarning, 0, 200 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )

end

function JetFighter.HUDTargetting()

	for k,v in pairs( ents.FindByClass( "sent*" ) ) do
		if ( IsValid( v ) && inLOS( v ) && v.PrintName && v != JetFighter.Plane && ( v.Type == "vehicle" || ( v.PrintName == "Missile" ) ) ) then
			
			local pos = v:GetPos():ToScreen( )
			local x,y = pos.x, pos.y
			local TargetTeam = v:GetNetworkedInt( "NeuroTeam", 0 )
			if( inLOS( JetFighter.Plane, v ) ) then
				if ( TargetTeam == NTeam ) and ( TargetTeam > 0 ) then	
					if ( v:GetModel() == JetFighter.Plane:GetModel() ) then
						surface.SetDrawColor( 0, 255, 255, 255)
						surface.DrawOutlinedRect( x-16, y-16, 32, 32 )
						surface.DrawLine( x-16, y-16, x+16, y+16 )
						surface.DrawLine( x-16, y+16, x+16, y-16 )
					else
						surface.SetDrawColor( 0, 150, 255, 255)
						surface.DrawOutlinedRect( x-16, y-16, 32, 32 )
						surface.DrawLine( x-16, y-16, x+16, y+16 )
						surface.DrawLine( x-16, y+16, x+16, y-16 )
					end
				else	
				surface.SetDrawColor( 0, 255, 0, 255)
				surface.DrawOutlinedRect( x-16, y-16, 32, 32 )
				end
--				if ( IsValid( JetFighter.Target ) && JetFighter.Target != JetFighter.Plane && v == JetFighter.Target ) then
				if ( IsValid( JetFighter.Target ) ) then
					local targetpos = JetFighter.Target:GetPos():ToScreen( )
					local x,y = targetpos.x, targetpos.y
					draw.SimpleText("Target", "TargetID", 10, 10, Color( lockwarning, 255-lockwarning, 0, 200 ), TEXT_ALIGN_LEFT, TEXT_ALIGN_LEFT )
						if JetFighter.Target.PrintName then
							draw.SimpleText( JetFighter.Target.PrintName, "TargetID", 10, 32, Color( lockwarning, 255-lockwarning, 0, 200 ), TEXT_ALIGN_LEFT, TEXT_ALIGN_LEFT )
						else
							draw.SimpleText( "Unknown", "TargetID", 10, 32, Color( lockwarning, 255-lockwarning, 0, 200 ), TEXT_ALIGN_LEFT, TEXT_ALIGN_LEFT )				
						end
					draw.SimpleText( "Locked On", "TargetID", ScrW() / 2, 175, Color( 255, 0, 0, 200 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
					surface.SetDrawColor( 255, 0, 0, 200)
					surface.DrawOutlinedRect( x-16, y-16, 32, 32 )
					surface.DrawLine( x-16, y, x, y+16 )
					surface.DrawLine( x-16, y, x, y-16 )
					surface.DrawLine( x, y+16, x+16, y )
					surface.DrawLine( x, y-16, x+16, y )
				end
			end
		end
	end

	for k,v in pairs( ents.FindByClass( "npc*" ) ) do
		
		local pos = ( v:GetPos() + Vector(0,0,72 ) ):ToScreen( )
		local x,y = pos.x, pos.y
			if( inLOS( JetFighter.Plane, v ) ) then
			--surface.SetDrawColor( 0, 255, 0, 255)
			surface.DrawOutlinedRect( x-16, y-16, 32, 32 )
			end
	end
	
end

function DrawHelicopterOuterCrosshair()
	
	-- Draw crosshair
	local sizex,sizey = 200, 150
	local x,y = ScrW()/2, ScrH()/2	
	
	surface.SetDrawColor( 255, 255, 255, 220 )
	
	-- Square surrounding the reticule
	surface.DrawOutlinedRect( x - sizex / 2, y - sizey / 2, sizex, sizey )
	
	-- Crosshair lines
	surface.DrawLine( x - sizex, y, x - sizex/2, y )
	surface.DrawLine( x + sizex, y, x + sizex/2, y )
	surface.DrawLine( x, y - sizey/2, x, y - sizey )
	surface.DrawLine( x, y + sizey/2, x, y + sizey )
	
	surface.SetDrawColor( 125, 125, 125, 140 )
	
	surface.DrawOutlinedRect( x - ( ScrW() / 1.45 ) / 2, y - ( ScrH() / 1.45 ) / 2, ( ScrW() / 1.45 ), ( ScrH() / 1.45 ) )
	

end

local mat = Material( "models/debug/debugwhite" )
local function DrawThermal()

	DrawMaterialOverlay( "effects/combine_binocoverlay.vmt", 0.11 )	
	
	cam.Start3D( EyePos(), EyeAngles() )

	render.MaterialOverride( mat )
	
	for k,v in pairs( ents.GetAll() ) do 
		
		if ( v:IsPlayer() && v:Alive() && !IsValid( v:GetDrivingEntity() ) && !v.ColdBlooded ) then
			
			render.SuppressEngineLighting( true )
			render.SetColorModulation( 1, 1, 1 )
			render.SetBlend( 1 )
			v:DrawModel()
			render.SuppressEngineLighting( false )
			
		end
	
		if( v:IsNPC() && type( v ) != "CSENT_Vehicle" ) then
			
			render.SuppressEngineLighting(true)
			render.SetColorModulation( .7, .7, .7 )
			render.SetBlend( 1 )
			v:DrawModel()
			render.SuppressEngineLighting(false)

		end
		
		if( v:IsVehicle() ) then
		
			render.SuppressEngineLighting(true)
			render.SetColorModulation( .15, .15, .15 )
			render.SetBlend( 1 )
			v:DrawModel()
			render.SuppressEngineLighting(false)
			
		end
		
	end
	
	render.MaterialOverride( nil )
	cam.End3D()
			
	local col = {}
	col[ "$pp_colour_addr" ] = 0
	col[ "$pp_colour_addg" ] = 0
	col[ "$pp_colour_addb" ] = 0
	col[ "$pp_colour_brightness" ] = 0
	col[ "$pp_colour_contrast" ] = 0.8
	col[ "$pp_colour_colour" ] = 0
	col[ "$pp_colour_mulr" ] = 0
	col[ "$pp_colour_mulg" ] = 0
	col[ "$pp_colour_mulb" ] = 0

	DrawColorModify( col )
	DrawMotionBlur( 0.59, 1, 0 )
	DrawSharpen( 0.5 + 2 / ( 1 + math.exp( math.sin( CurTime() * 1000 ) ) ) / 3, 1 )

end

function DrawHitpointCrosshair( gun )

	local pos = gun:GetPos() 
	local tr, trace = {}, {}
	tr.start = pos + gun:GetForward() * 1024
	tr.endpos = tr.start + gun:GetForward() * 25000
	tr.filter = gun
	trace = util.TraceLine( tr )
	
	if( trace.Hit ) then
		
		local spos = trace.HitPos:ToScreen()
		surface.SetDrawColor( 255, 255, 255, 220 )
		surface.DrawOutlinedRect( spos.x - 60 / 2, spos.y - 40 / 2, 60, 40 ) 
	
	end
			
end

local function Draw3DWeaponCrosshair( gun )
	
	local pos = ( gun:GetPos() + gun:GetForward() * 25000 ):ToScreen()
	local gap = 15
	local length = gap + 25
	local x,y = pos.x,pos.y//ScrW()/2, ScrH()/2
	
	local tr,trace = {},{}
		tr.start = gun:GetPos()
		tr.endpos = tr.start + gun:GetForward() * 35000
		tr.filter = {gun, LocalPlayer()}
		tr.mask = MASK_SOLID
	trace = util.TraceLine( tr )
	
	if ( !trace.HitSky && trace.Entity && IsValid( trace.Entity ) && trace.Entity:IsNPC() || trace.Entity:IsPlayer() || type(trace.Entity) == "CSENT_vehicle" ) then
	
		surface.SetDrawColor( 255, 50, 50, 255 )
	
	else
	
		surface.SetDrawColor( 50, 255, 50, 255 )
		
	end

	//Bracket crosshair
	if VEHICLE_HELICOPTER then
	--Left
	surface.DrawLine( x-32 , y-32, x-8, y-32 )
	surface.DrawLine( x-32 , y+32, x-8, y+32 )
	surface.DrawRect( x-32 , y-32, 2, 64 )
	--Right
	surface.DrawLine( x+32 , y-32, x+8, y-32 )
	surface.DrawLine( x+32 , y+32, x+8, y+32 )
	surface.DrawRect( x+32 , y-32, 2, 64 )
	else
	//Old crosshair
	surface.DrawLine( x - length, y, x - gap, y )
	surface.DrawLine( x + length, y, x + gap, y )
	surface.DrawLine( x, y - length, x, y - gap )
	surface.DrawLine( x, y + length, x, y + gap )

	end
	
end

local function DrawLaserguidanceCrosshair( sizex, sizey )

	local center = { x = ScrW() / 2, y = ScrH() / 2 }
	local scale = { x = sizex, y = sizey }
	local segmentdist = 360 / ( 2 * math.pi * math.max( scale.x, scale.y ) / 2 )
	surface.SetDrawColor( 175, 175, 175, 255 )
 
	for a = 0, 360 - segmentdist, segmentdist do
	
		surface.DrawLine( center.x + math.cos( math.rad( a ) ) * scale.x, 
						  center.y - math.sin( math.rad( a ) ) * scale.y, 
						  center.x + math.cos( math.rad( a + segmentdist ) ) * scale.x, 
						  center.y - math.sin( math.rad( a + segmentdist ) ) * scale.y )
	
	end
	
	local gap = 15
	local length = gap + 40
	local x,y = ScrW()/2, ScrH()/2
	surface.DrawLine( x - length, y, x - gap, y )
	surface.DrawLine( x + length, y, x + gap, y )
	surface.DrawLine( x, y - length, x, y - gap )
	surface.DrawLine( x, y + length, x, y + gap )
	
	-- local copilotplane = LocalPlayer():GetNetworkedEntity( "Plane", NULL ) 
	
	-- if( IsValid( copilotplane ) ) then
		
		-- local lg = copilotplane:GetNetworkedEntity("NeuroPlanes_LaserGuided", NULL )
		-- if( IsValid( lg ) ) then
		
		
			
		-- end
		
	-- end
	
end

local spos


local function HellfireMarker()
	
	local plr = LocalPlayer()
	local plane = plr:GetNetworkedEntity("Plane", NULL )
	
	local logic = IsValid( plane ) && plr:GetNetworkedBool("DrawDesignator", false ) 
	
	if( logic && IsValid( plr ) ) then
		
		local tr, trace = {},{}
		tr.start = plane:GetPos() + plane:GetForward() * 600 + plane:GetUp() * 600
		tr.endpos = tr.start + plr:GetAimVector() * 36000
		tr.filter = { plane, plr }
		tr.mask = MASK_SOLID
		trace = util.TraceLine( tr )
		
	
		if( trace.Hit ) then
		
			local dist = 2048
			local tempd = 0
			local pos = trace.HitPos
			local found = false
		
			surface.SetDrawColor( 255, 255, 255, 195 )
			
			-- Auto lock-on
			for k,v in ipairs( ents.GetAll() ) do 
				
				if( ( v:IsVehicle() || v:IsNPC() || v:IsPlayer() ) && v != plane && v != plr && v != coplane ) then
					
					tempd = trace.HitPos:Distance( v:GetPos() )
					--print( v:GetClass(), v )
					
					//print( tempd, dist )
					
					if ( tempd < dist ) then
						
						dist = tempd
						pos = v:GetPos()
						found = true
						//print( dist, pos, found )
						
					end
				
				end
			
			end
			
			if( found ) then
			
				surface.SetDrawColor( 255, 0, 0, 255 )
				
			end
			
			spos = pos:ToScreen()
			-- Draw crosshair
			local sizex,sizey = 60, 40
			local x,y = spos.x, spos.y
			
			//surface.SetDrawColor( 255, 255, 255, 220 )
			
			-- Square surrounding the reticule
			surface.DrawOutlinedRect( x - sizex / 2, y - sizey / 2, sizex, sizey )
			
			-- Crosshair lines
			surface.DrawLine( x - sizex, y, x - sizex/2, y )
			surface.DrawLine( x + sizex, y, x + sizex/2, y )
			surface.DrawLine( x, y - sizey/2, x, y - sizey )
			surface.DrawLine( x, y + sizey/2, x, y + sizey )
			
		//	surface.SetDrawColor( 125, 125, 125, 140 )
			
			surface.DrawOutlinedRect( x - ( sizex / 1.45 ) / 2, y - ( sizey / 1.45 ) / 2, ( sizex / 1.45 ), ( sizey / 1.45 ) )
			
			/*
			surface.DrawOutlinedRect( spos.x - 60 / 2, spos.y - 40 / 2, 60, 40 )
			//surface.SetTextPos( spos.x - 60 / 2, spos.y - 40 / 2 ) 
			//surface.DrawText( math.floor( tr.start:Distance( trace.HitPos ) ) )
			*/
			
			
		end
		
	end
		
end
hook.Add("HUDPaint","NeuroPlanes_Hellfiredesignator", HellfireMarker )

function JetFighter.PhalanxCIWS_HUD()
	
	local plr = LocalPlayer()
	local phlx = plr:GetNetworkedEntity( "Turret", NULL )
	local drawoverlay = IsValid( phlx ) && plr:GetNetworkedBool("DrawPhalanxHUD", false )
	
	if( drawoverlay ) then
		
		DrawThermal()
		DrawHelicopterOuterCrosshair()
		DrawLaserguidanceCrosshair( 25, 25 )
		
		local a = plr:EyeAngles()
		local hp = math.floor( phlx:GetNetworkedInt( "Health", 0 ) )
		local maxhp = math.floor( phlx:GetNetworkedInt( "MaxHealth", 0 ) )
		local health = hp * 100 / maxhp
		
		if( phlx.ZoomVar ) then
		
			draw.SimpleText(tostring(math.floor(a.p)).." "..tostring(math.floor(a.y)).." "..tostring(math.floor(a.r)).."  "..phlx.ZoomVar, "HudHintTextLarge", ScrW() / 16, ScrH() / 15, Color( 255, 255, 255, 255 ), TEXT_ALIGN_LEFT, TEXT_ALIGN_LEFT )
		
		end
		
		draw.SimpleText( phlx.PrintName, "HudHintTextLarge", ScrW() / 1.4, ScrH() / 15, Color( 255, 255, 255, 255 ), TEXT_ALIGN_LEFT, TEXT_ALIGN_LEFT )
		draw.SimpleText( "Integrity: "..math.Round(health).."%", "Trebuchet24", ScrW() / 15, ScrH() / 1.15, Color( 255, 255, 255, 255 ), TEXT_ALIGN_LEFT, TEXT_ALIGN_LEFT )
		//draw.SimpleText( , "HudHintTextLarge", ScrW() / 1.15, ScrH() / 1.15, Color( 255, 255, 255, 255 ), TEXT_ALIGN_LEFT, TEXT_ALIGN_LEFT )

	end
	
end
hook.Add("RenderScreenspaceEffects", "Neuroplanes__PhalanxCIWS", JetFighter.PhalanxCIWS_HUD )

function JetFighter.LaserguidanceScreenspace()
	
	local plr = LocalPlayer()
	local plane = plr:GetScriptedVehicle()
	local drawoverlay = ( ( IsValid( plane ) && plane:GetNetworkedBool( "DrawTracker", false ) ) )
	if( !IsValid( plane ) ) then return end 
	local copilot = plane:GetNetworkedEntity("CoPilot", NULL )

	if( IsValid( copilot ) && plane:GetNetworkedBool("DrawTracker", false ) && LocalPlayer() == copilot ) then
		-- dW
		DrawThermal()
		DrawLaserguidanceCrosshair( 250, 250 )
	
	end
	
	if( !IsValid( copilot ) && drawoverlay ) then
	
		DrawThermal()
		DrawLaserguidanceCrosshair( 250, 250 )

	end
	
end
hook.Add("RenderScreenspaceEffects", "Neuroplanes__LaserguidanceScreenspace", JetFighter.LaserguidanceScreenspace )

function JetFighter.HelicopterGuncamScreenspace()
	
	local plr = LocalPlayer()
	local vhe = plr:GetDrivingEntity() ---------------------------------------------------------------------<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
	local isPilot = IsValid( vhe )
	local isChopperGunner = plr:GetNetworkedBool( "isGunner", false )
	local gun = plr:GetNetworkedEntity( "ChopperGunnerEnt", NULL )
	local haveGun = IsValid( gun )
	
	if( haveGun ) then

		if( isChopperGunner ) then
			
			DrawThermal()
			DrawHelicopterOuterCrosshair()
			DrawHitpointCrosshair( gun )

		else
			
			local lasttick = CurTime()

			local pos = gun:GetPos() 
			local tr, trace = {}, {}
			tr.start = pos + gun:GetForward() * 700
			tr.endpos = tr.start + gun:GetForward() * 25000
			tr.filter = gun
			trace = util.TraceLine( tr )
			
			if( lasttick + 0.25 <= CurTime() ) then
				
				dist = math.floor( gun:GetPos():Distance( trace.HitPos ) )
				lasttick = CurTime()
				
			end

			if( trace.Hit ) then
				
				local spos = trace.HitPos:ToScreen()
				local sizex,sizey = 8, 8
				surface.SetDrawColor( 255, 255, 255, 220 )
				surface.DrawCircle( spos.x, spos.y, 8, Color( 255, 255, 255, 220) )
				surface.DrawLine( spos.x - sizex, spos.y, spos.x - sizex/2, spos.y )
				surface.DrawLine( spos.x + sizex, spos.y, spos.x + sizex/2, spos.y )
				surface.DrawLine( spos.x, spos.y - sizey/2, spos.x, spos.y - sizey )
				surface.DrawLine( spos.x, spos.y + sizey/2, spos.x, spos.y + sizey )
				
			end
			--Draw3DWeaponCrosshair( gun )
			
		end
	
	end

end
hook.Add("RenderScreenspaceEffects", "Neuroplanes__HelicopterGuncamScreenspace", JetFighter.HelicopterGuncamScreenspace )

local debugWhite = Material("models/debug/debugwhite")

function JetFighter.Ac130stuff()
local pl = LocalPlayer()
local case_b = ( pl:GetNetworkedBool("NeuroPlanes__DrawAC130Overlay", false ) == true && IsValid( pl:GetVehicle() ) )
	if( case_b ) then
			
		local sizex,sizey = 200, 150
		local x,y = ScrW()/2, ScrH()/2	
		
		surface.SetDrawColor( 255, 255, 255, 220 )
		
		-- Square surrounding crosshair
		//surface.DrawRect( x - sizex / 2, y - sizey / 2, sizex, sizey )
		surface.DrawOutlinedRect( x - sizex / 2, y - sizey / 2, sizex, sizey )
		
		-- Crosshair lines
		surface.DrawLine( x - sizex, y, x - sizex/2, y )
		surface.DrawLine( x + sizex, y, x + sizex/2, y )
		surface.DrawLine( x, y - sizey/2, x, y - sizey )
		surface.DrawLine( x, y + sizey/2, x, y + sizey )
		
		surface.SetDrawColor( 125, 125, 125, 140 )
		
		//surface.DrawRect( x - ( ScrW() / 1.15 ) / 2, y - ( ScrH() / 1.15 ) / 2, ( ScrW() / 1.15 ), ( ScrH() / 1.15 ) )
		surface.DrawOutlinedRect( x - ( ScrW() / 1.45 ) / 2, y - ( ScrH() / 1.45 ) / 2, ( ScrW() / 1.45 ), ( ScrH() / 1.45 ) )
		
		
		local gun = pl:GetNetworkedEntity("NeuroPlanesMountedGun", NULL )
		
		-- Gun reticle
		if( IsValid( gun ) ) then
			
			local pos = gun:GetPos() 
			local tr, trace = {}, {}
			tr.start = pos + gun:GetForward() * 1024
			tr.endpos = tr.start + gun:GetForward() * 25000
			tr.filter = gun
			trace = util.TraceLine( tr )
			
			if( trace.Hit ) then
				
				local spos = trace.HitPos:ToScreen()
				surface.SetDrawColor( 255, 255, 255, 220 )
				surface.DrawOutlinedRect( spos.x - 60 / 2, spos.y - 40 / 2, 60, 40 ) 
			
			end
			
		end

		DrawMaterialOverlay( "effects/combine_binocoverlay.vmt", 0.11 )	
		
	
		cam.Start3D( EyePos(), EyeAngles() )

		render.MaterialOverride( debugWhite )
		
		for k,v in pairs( ents.GetAll() ) do 
			
			if ( v:IsPlayer() && v:Alive() && !IsValid( v:GetDrivingEntity() ) && !v.ColdBlooded && v != LocalPlayer() ) then
				
				render.SuppressEngineLighting(true)
				render.SetColorModulation( 1, 1, 1 )
				render.SetBlend( 1 )
				v:DrawModel()
				render.SuppressEngineLighting(false)
				
			end
			
			if( v:IsNPC() && v:OnGround() ) then
				
				render.SuppressEngineLighting(true)
				render.SetColorModulation( .7, .7, .7 )
				render.SetBlend( 1 )
				v:DrawModel()
				render.SuppressEngineLighting(false)
			/*
			elseif( v:IsNPC() ) then
				
				render.SuppressEngineLighting(true)
				render.SetColorModulation( 1, 1, 1 )
				render.SetBlend( 1 )
				v:DrawModel()
				render.SuppressEngineLighting(false)
			*/
			end
			
			local va = v:GetColor()
			
			if( IsValid( v ) && v:IsVehicle() && va.a > 100 ) then
			
				render.SuppressEngineLighting(true)
				render.SetColorModulation( .15, .15, .15 )
				render.SetBlend( 1 )
				v:DrawModel()
				render.SuppressEngineLighting(false)
				
			end
			
		end
		
		render.MaterialOverride( nil )
		cam.End3D()
				
		local col = {}
		col[ "$pp_colour_addr" ] = 0
		col[ "$pp_colour_addg" ] = 0
		col[ "$pp_colour_addb" ] = 0
		col[ "$pp_colour_brightness" ] = 0
		col[ "$pp_colour_contrast" ] = 0.8
		col[ "$pp_colour_colour" ] = 0
		col[ "$pp_colour_mulr" ] = 0
		col[ "$pp_colour_mulg" ] = 0
		col[ "$pp_colour_mulb" ] = 0

		DrawColorModify( col )
		DrawMotionBlur( 0.59, 1, 0 )
		DrawSharpen( 1 + 1 / ( 1 + math.exp( -CurTime() / 10 ) ) / 80, 1 )
				
	end

end
function JetFighter.RenderScreenspaceEffects()

	JetFighter.Pilot = LocalPlayer()
	JetFighter.Plane = JetFighter.Pilot:GetNetworkedEntity( "Plane", NULL )

	if ( !JetFighter.Plane || !IsValid( JetFighter.Plane ) ) then
		
		return
		
	end
		
	if ( JetFighter.Plane:GetNetworkedBool( "DrawTracker", false ) ) then
		
		DrawMaterialOverlay( "effects/combine_binocoverlay.vmt", 0.1 )
			
	end
	
	local p = LocalPlayer()
	local isGunner = p:GetNetworkedBool( "isGunner", false )
	local plane = p:GetNetworkedEntity("ChopperGunnerEnt", NULL )
	local case_a = ( JetFighter.Plane:GetNetworkedBool( "ChopperGunner", false ) == true && JetFighter.Pilot:GetNetworkedBool("isGunner", false ) == true )
	
	local case_c = ( isGunner == true && IsValid( plane ) )--( p:GetNetworkedEntity( "ChopperGunnerEnt", nil ) != p && p:GetNetworkedBool("isGunner", false ) == true )
	
	if( case_a || case_b || case_c ) then
			
		local sizex,sizey = 200, 150
		local x,y = ScrW()/2, ScrH()/2	
		
		surface.SetDrawColor( 255, 255, 255, 220 )
		
		-- Square surrounding crosshair
		//surface.DrawRect( x - sizex / 2, y - sizey / 2, sizex, sizey )
		surface.DrawOutlinedRect( x - sizex / 2, y - sizey / 2, sizex, sizey )
		
		-- Crosshair lines
		surface.DrawLine( x - sizex, y, x - sizex/2, y )
		surface.DrawLine( x + sizex, y, x + sizex/2, y )
		surface.DrawLine( x, y - sizey/2, x, y - sizey )
		surface.DrawLine( x, y + sizey/2, x, y + sizey )
		
		surface.SetDrawColor( 125, 125, 125, 140 )
		
		//surface.DrawRect( x - ( ScrW() / 1.15 ) / 2, y - ( ScrH() / 1.15 ) / 2, ( ScrW() / 1.15 ), ( ScrH() / 1.15 ) )
		surface.DrawOutlinedRect( x - ( ScrW() / 1.45 ) / 2, y - ( ScrH() / 1.45 ) / 2, ( ScrW() / 1.45 ), ( ScrH() / 1.45 ) )
		
		
		local gun = JetFighter.Pilot:GetNetworkedEntity("NeuroPlanesMountedGun", NULL )
		
		-- Gun reticle
		if( IsValid( gun ) ) then
			
			local pos = gun:GetPos() 
			local tr, trace = {}, {}
			tr.start = pos + gun:GetForward() * 1024
			tr.endpos = tr.start + gun:GetForward() * 25000
			tr.filter = gun
			trace = util.TraceLine( tr )
			
			if( trace.Hit ) then
				
				local spos = trace.HitPos:ToScreen()
				surface.SetDrawColor( 255, 255, 255, 220 )
				surface.DrawOutlinedRect( spos.x - 60 / 2, spos.y - 40 / 2, 60, 40 ) 
			
			end
			
		end

		DrawMaterialOverlay( "effects/combine_binocoverlay.vmt", 0.11 )	
		
	
		cam.Start3D( EyePos(), EyeAngles() )

		render.MaterialOverride( debugWhite )
		
		for k,v in pairs( ents.GetAll() ) do 
			
			if ( v:IsPlayer() && v:Alive() && !IsValid( v:GetDrivingEntity() ) && !v.ColdBlooded ) then
				
				render.SuppressEngineLighting(true)
				render.SetColorModulation( 1, 1, 1 )
				render.SetBlend( 1 )
				v:DrawModel()
				render.SuppressEngineLighting(false)
				
			end
		
			if( v:IsNPC() && type( v ) != "CSENT_Vehicle" ) then
				
				render.SuppressEngineLighting(true)
				render.SetColorModulation( .7, .7, .7 )
				render.SetBlend( 1 )
				v:DrawModel()
				render.SuppressEngineLighting(false)
			/*
			elseif( v:IsNPC() ) then
				
				render.SuppressEngineLighting(true)
				render.SetColorModulation( 1, 1, 1 )
				render.SetBlend( 1 )
				v:DrawModel()
				render.SuppressEngineLighting(false)
			*/
			end
			
			if( v:IsVehicle() ) then
			
				render.SuppressEngineLighting(true)
				render.SetColorModulation( .15, .15, .15 )
				render.SetBlend( 1 )
				v:DrawModel()
				render.SuppressEngineLighting(false)
				
			end
			
		end
		
		render.MaterialOverride( nil )
		cam.End3D()
				
		local col = {}
		col[ "$pp_colour_addr" ] = 0
		col[ "$pp_colour_addg" ] = 0
		col[ "$pp_colour_addb" ] = 0
		col[ "$pp_colour_brightness" ] = 0
		col[ "$pp_colour_contrast" ] = 0.8
		col[ "$pp_colour_colour" ] = 0
		col[ "$pp_colour_mulr" ] = 0
		col[ "$pp_colour_mulg" ] = 0
		col[ "$pp_colour_mulb" ] = 0

		DrawColorModify( col )
		DrawMotionBlur( 0.59, 1, 0 )
		DrawSharpen( 1 + 1 / ( 1 + math.exp( -CurTime() / 10 ) ) / 80, 1 )
				
	end
	
end


-- Missile Alert && Valid Target Markers
function JetFighter.MissileAlert()

	-- 
	if ( JetFighter.DrawWarning ) then
	
		JetFighter.Pilot.LockonSound:PlayEx( 1.0, 100 )
		-- local pos = JetFighter.Plane:GetPos() + JetFighter.Plane:GetForward() * -805
		-- local ang = JetFighter.Plane:GetAngles()
		
		draw.SimpleText("LOCK-ON ALERT", "LockonAlert", ScrW() / 2, ScrH() - 45, Color( 255, 35, 35, 200 + (math.sin(CurTime())*50) ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )

	else
	
		JetFighter.Pilot.LockonSound:FadeOut( 0.15 )
		/*if( JetFighter.Pilot.LastBeep + 3.1 <= CurTime() ) then
			
			JetFighter.Pilot.LastBeep = CurTime()
			surface.PlaySound( "LockOn/Launch.mp3" )
				
		end*/
		
	end
		
end

function JetFighter.DrawHP()
	
	local hp = math.floor( JetFighter.Plane:GetNetworkedInt( "Health", 0 ) )
	local maxhp = math.floor( JetFighter.Plane:GetNetworkedInt( "MaxHealth", 0 ) )
	local health = hp * 100 / maxhp
	
	local hpvar = math.Clamp( hp / 9, 15, 255 )
	JetFighter.Plane.HealthVal = math.ceil( hp * 100 / maxhp )
	local size = 128
	local offs = size / 2

	local maxspd = math.floor( JetFighter.Plane:GetNetworkedInt( "MaxSpeed", 0 ) )
	local throttle = math.floor( ( JetFighter.Plane:GetVelocity():Length() * 100 ) / maxspd )
	local speed = math.floor(JetFighter.Plane:GetVelocity():Length() / 1.8 )
	local wep = JetFighter.Plane:GetNetworkedString("NeuroPlanes_ActiveWeapon",tostring("NONE_AVAILABLE")) -- should this really be necessary?

	
	draw.RoundedBox(0, ScrW() / 70, ScrH() / 1.1 + 100, 100 * health, 15, Color(255,0,0,255))
	draw.RoundedBox( 3, ScrW() / 70, ScrH() / 1.1, 280, 80, Color( 45, 45, 45, 150 ) )
	draw.SimpleText("Health: "..JetFighter.Plane.HealthVal, "TargetID", ScrW() / 40, ScrH() / 1.08, Color( 255, 255, 255, 245 ), TEXT_ALIGN_LEFT, TEXT_ALIGN_LEFT )
	draw.SimpleText("Throttle: "..throttle, "TargetID", ScrW() / 40, ScrH() / 1.06, Color( 255, 255, 255, 245 ), TEXT_ALIGN_LEFT, TEXT_ALIGN_LEFT )
	draw.SimpleText("Speed: "..speed, "TargetID", 5 * ScrW() / 40, ScrH() / 1.06, Color( 255, 255, 255, 245 ), TEXT_ALIGN_LEFT, TEXT_ALIGN_LEFT )
		
	if ( wep != "NONE_AVAILABLE" ) then

		draw.SimpleText("WEP: "..wep, "TargetID", ScrW() / 40, ScrH() / 1.04, Color( 255, 255, 255, 245 ), TEXT_ALIGN_LEFT, TEXT_ALIGN_LEFT )
		
	end
	
end

function DrawPlaneHUD()
	
	JetFighter.Pilot = LocalPlayer()
	JetFighter.Plane = JetFighter.Pilot:GetNetworkedEntity( "Plane", NULL )
	JetFighter.Turret = JetFighter.Pilot:GetNetworkedEntity( "Turret", NULL )
	
	if( JetFighter.Pilot && !JetFighter.Pilot.LockonSound ) then
		
		JetFighter.Pilot.LockonSound = CreateSound( JetFighter.Pilot, "LockOn/Launch.mp3" )
	
	end
		
	local ply = LocalPlayer()
	local roofturret = ply:GetNetworkedEntity( "Neuroplanes_B17_roofturret", NULL )
	
	if( IsValid( roofturret ) ) then
		
		local pos = ( roofturret:GetPos() + roofturret:GetForward() * 2500 ):ToScreen()
		local x,y = pos.x, pos.y
		local size = 48
			
		surface.SetMaterial(  ch_green )
		surface.DrawTexturedRect( pos.x - size / 2, pos.y - size / 2, size, size )

	end
	if ( IsValid( JetFighter.Turret ) ) then
		if ( JetFighter.Target == JetFighter.Turret ) then
		
			JetFighter.Target = NULL
		
		end

		if ( JetFighter.Pilot:GetNetworkedBool( "InFlight", false ) && JetFighter.Turret != JetFighter.Pilot ) then
				
			if( GetConVarNumber("jet_markenemies") > 0 ) then				
				JetFighter.MarkEnemies()				
			end
			if( GetConVarNumber("jet_health") > 0 ) then				
				JetFighter.HP()				
			end

		end
	end
	if ( IsValid( JetFighter.Plane ) ) then
		
		if ( JetFighter.Pilot.LastBeep == nil ) then
		
			JetFighter.Pilot.LastBeep = CurTime()
			
		end
			
		-- Hackfix to clear target lock-on
		if ( JetFighter.Target == JetFighter.Plane ) then
		
			JetFighter.Target = NULL
		
		end
		
		local hp = math.floor( JetFighter.Plane:GetNetworkedInt( "Health", 0 ) )
		local SystemsError = ( hp < 10 )
		if ( JetFighter.Pilot:GetNetworkedBool( "InFlight", false ) && JetFighter.Plane != JetFighter.Pilot && not SystemsError ) then
			

			if( GetConVarNumber("jet_markenemies") > 0 ) then
				
				JetFighter.MarkEnemies()
				
			end

			if( GetConVarNumber("jet_health") > 0 ) then
				
				JetFighter.HP()
				
			end

			
			JetFighter.MissileAlert()
			JetFighter.DrawCrosshair()

			if( GetConVarNumber("jet_HUD") > 0 ) and ( GetConVarNumber("jet_HQhud") == 0 ) then
				
				JetFighter.HUD()
			else
				
				if( GetConVarNumber("jet_HQhud") == 0 ) then
					JetFighter.DrawHP()			
				end

			end
			
			if( GetConVarNumber("jet_HQhud") > 0 ) and ( GetConVarNumber("jet_HUD") == 0 ) then
				
				JetFighter.Panels()

			else
				
				if( GetConVarNumber("jet_HUD") == 0 ) then
				JetFighter.DrawHP()			
				end

			end

			if( GetConVarNumber("jet_HQhud") > 0 ) and ( GetConVarNumber("jet_HUD") > 0 ) then
				JetFighter.DrawHP()			
			end
			
		end
		
	end

	
end

//Debug
//lua_run_cl LocalPlayer():SetNetworkedBool("NeuroPlanes__DrawAC130Overlay",true)
//lua_run_cl LocalPlayer():SetNetworkedEntity("NeuroPlanesMountedGun",  LocalPlayer():GetActiveWeapon() )

if( table.HasValue( hook.GetTable(), "NeuroPlanes_ScreenspaceEffects" ) ) then
	hook.Remove("RenderScreenspaceEffects", "NeuroPlanes_ScreenspaceEffects")
	print("Deleting NeuroPlanes_ScreenspaceEffects")
end
if( table.HasValue( hook.GetTable(), "NeuroPlanes__CopilotGuncam" ) ) then
	hook.Remove("CalcView", "NeuroPlanes__CopilotGuncam")
	print("Deleting NeuroPlanes__CopilotGuncam")
end
if( table.HasValue( hook.GetTable(), "Neuroplanes__HeadsUpDisplay" ) ) then
	hook.Remove("HUDPaint", "Neuroplanes__HeadsUpDisplay")
	print("Deleting Neuroplanes__HeadsUpDisplay")
end
if( table.HasValue( hook.GetTable(), "Neuroplanes_EnnemiesHP" ) ) then
	hook.Remove("HUDPaint", "Neuroplanes_EnnemiesHP")
	print("Deleting Neuroplanes_EnnemiesHP")
end

hook.Add( "CalcView", "NeuroPlanes__CopilotGuncam", JetFighter.CopilotCalcView )
//hook.Add( "RenderScreenspaceEffects", "NeuroPlanes_ScreenspaceEffects", JetFighter.RenderScreenspaceEffects )
hook.Add( "RenderScreenspaceEffects", "NeuroPlanes_ScreenspaceEffects",  JetFighter.Ac130stuff )
hook.Add( "HUDPaint", "Neuroplanes__HeadsUpDisplay", DrawPlaneHUD )
//hook.Add("HUDPaint", "Neuroplanes_EnnemiesHP", JetFighter.HP ) 
//hook.Add("HUDPaint", "Neuroplanes_Panels", JetFighter.Panels ) 

print( "[NeuroBase] JetHUD.lua loaded!" )