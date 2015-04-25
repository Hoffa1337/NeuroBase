local Meta = FindMetaTable("Entity")
-- no time for table lookups
local pairs = pairs
local ipairs = ipairs 
local table = table 
local math = math 
local Telegraph = Material("VGUI/ui/naval-throttlet-telegraph.png" )
local TelegraphStick = Material("VGUI/ui/telegraph-stick.png" )
local TelegraphPole = Material("VGUI/ui/telegraph-pole.png" )
local ThrottlePos = 0 

function Meta:DefaultMicroShitExhaust( )
	
	self:DrawModel() 
		
	if( self.PropellerPos && self:WaterLevel()>1 && self:GetNWFloat("Throttle") != 0 ) then 
		local count=1
		local scale = self.PropellerSplashScale or 1.0 
		local pos = self.PropellerPos or Vector(-200,0, -25 ) 
		local p = pos  
		if( type(pos) == "table" ) then 
			count = #pos 
			
		end 
		
		for i=1,count do 
			if( count > 1 ) then 
				p = pos[i]
			end 
			
			local particle = self.Emitter:Add( "particle/water/waterdrop_001a", self:LocalToWorld( p )  )
			if ( particle ) then
			-- print("?=?=")
				particle:SetVelocity( self:GetVelocity()*-1 + self:GetRight() * math.random(-16,16)*scale )
				particle:SetDieTime( math.Rand( 1, 3 ) )
				particle:SetStartAlpha( math.Rand( 5, 11 ) )
				particle:SetEndAlpha( 0 )
				particle:SetStartSize( math.Rand( 5, 12 ) * scale )
				particle:SetEndSize( math.Rand( 21, 32 ) ) 
				particle:SetRoll( math.Rand(-11.1, 11.1) * scale )
				particle:SetRollDelta( math.Rand(-1, 1) )
				particle:SetColor( 255,255,255 ) 
				particle:SetAirResistance( 150 ) 
				particle:SetGravity( Vector(math.random(-35,35),math.random(-35,35),15) )
				
			end 
			
		end 
		
	end 
	
	if( self:WaterLevel() == 0 ) then return end 
	
	if(  self:GetNWFloat("Throttle") != 0 && self.ExhaustPosition ) then 
		
		if( type( self.ExhaustPosition ) == "table" ) then 
			
			for i=1,#self.ExhaustPosition do 
					
				local particle = self.Emitter:Add( "particle/smokesprites_000"..math.random(1,9), self:LocalToWorld( self.ExhaustPosition[i] ) )
				
				if ( particle ) then
					particle:SetVelocity( self:GetUp() * -300 + Vector( 0, 0,math.Rand( 55.5,65.5)*4  ) )
					particle:SetDieTime( math.Rand( 1, 4 ) )
					particle:SetStartAlpha( math.Rand( 13, 16 ) )
					particle:SetEndAlpha( 0 )
					particle:SetStartSize( math.Rand( 15, 16 ) )
					particle:SetEndSize( math.Rand( 85, 96 ) )
					particle:SetRoll( math.Rand(0, 360) )
					particle:SetRollDelta( math.Rand(-1, 1) )
					particle:SetColor( math.Rand(35,45), math.Rand(35,45), math.Rand(35,45) ) 
					particle:SetAirResistance( 250 ) 
					particle:SetGravity( self:GetForward() * -5 + VectorRand():GetNormalized()*math.Rand(10, 46)+Vector(0,0,2*math.Rand(155, 165)) ) 	
				end
			
			
			end 
		
		else 
			
			local particle = self.Emitter:Add( "particle/smokesprites_000"..math.random(1,9), self:LocalToWorld( self.ExhaustPosition ) )
			
			if ( particle ) then
				particle:SetVelocity( self:GetForward() * -300 + Vector( math.Rand( -4.5,4.5), -140 - math.Rand( -4.5,4.5),math.Rand( 55.5,65.5)*4  ) )
				particle:SetDieTime( math.Rand( 2, 4 ) )
				particle:SetStartAlpha( math.Rand( 3, 6 ) )
				particle:SetEndAlpha( 0 )
				particle:SetStartSize( math.Rand( 25, 45 ) )
				particle:SetEndSize( math.Rand( 355, 466 ) )
				particle:SetRoll( math.Rand(0, 360) )
				particle:SetRollDelta( math.Rand(-1, 1) )
				particle:SetColor( math.Rand(35,45), math.Rand(35,45), math.Rand(35,45) ) 
				particle:SetAirResistance( 150 ) 
				particle:SetGravity( self:GetForward() * -150 + VectorRand():GetNormalized()*math.Rand(10, 46)+Vector(0,0,math.Rand(155, 165)) ) 	
			end
			
		end 
		
	end 
			
-- if( self:WaterLevel() > 0 ) then 
-- local particle = self.Emitter:Add( "")
	local scale = self:GetNWFloat("BoostPercentage") or 0 
	
	local partText = "particle/snowflake01"

	if( ( scale > .15 || scale < -.15 ) && self:GetVelocity():Length()> 30 && !self.IsMicroSubmarine ) then 
		
		-- print(self:GetVelocity():Length()  )
		local pos = self.WaterBreakPosition or Vector(465,0, -25 ) 
		local particle = self.Emitter:Add( "particle/water/waterdrop_001a", self:LocalToWorld( pos )  )
		if ( particle  && self:WaterLevel() < 3 ) then
		-- print("?=?=")
			particle:SetVelocity( Vector(0,0,125 + scale * 55 ) )
			particle:SetDieTime( math.Rand( 1, 2 ) )
			particle:SetStartAlpha( math.Rand( 25, 45 ) )
			particle:SetEndAlpha( 0 )
			particle:SetStartSize( math.Rand( 4, 10 ) )
			particle:SetEndSize( math.Rand( 30, 81 ) ) 
			particle:SetRoll( math.Rand(-11.1, 11.1) )
			particle:SetRollDelta( math.Rand(-1, 1) )
			particle:SetColor( 255,255,255 ) 
			particle:SetAirResistance( 150 ) 
			particle:SetGravity(Vector(0,0,-225) +  ( self:GetForward()*-200 * scale + self:GetRight()*math.random(-395,395) )  )
			
		end 
		
		
	end 

	
	if( self.PartLength && self.PartStart && self:GetVelocity():Length() > 10 ) then 
		local fxscale1 = self.WaterRippleScale or  1.2
		local pos = self:GetPos()+Vector(0,0,16)
		local fwd = self:GetForward()
		local tr,trace = {},{}
		tr.start = pos + Vector(0,0,50) 
		tr.endpos = tr.start + Vector( 0,0,-250 )
		tr.filter = self 
		tr.mask = MASK_WATER
		trace = util.TraceLine( tr ) 

		-- fwd.z = 0 
		-- pos.z = trace.HitPos.z 
		
		for i=1,10 do
			-- print("allaa")
			local fx = EffectData()
			fx:SetOrigin( (fwd*self.PartStart.x*1.112) + pos + fwd * ( i * -self.PartLength/12  ) )
			fx:SetScale(  math.Clamp(  i * 1.1, 7.5, 15 )*fxscale1 )
			util.Effect("waterripple", fx )
			
		end 
	
	
	end 

end 
function Meta:DefaultNavalClientInit()
		
	self:SetShouldDrawInViewMode( true )
	self.Emitter = ParticleEmitter( self:GetPos() )
	if( self.WeaponGroupIcons ) then 
		self.NewWeaponGroupIcons = {}
		
		for i=1,#self.WeaponGroupIcons do 
			-- print( self.WeaponGroupIcons[i] )
			self.NewWeaponGroupIcons[i] = Material( self.WeaponGroupIcons[i] )
			-- print(i )
		end 
		
	end 
	
	local mins,maxs = self:GetModelBounds()
	-- mins.y, mins.z = 0,0 
	-- maxs.y,maxs.z = 0,0 
	local length = ( mins - maxs ):Length() 
	self.PartLength = length 
	self.PartStart = maxs 
	-- print( self.PartStart )
end 

net.Receive("NeuroNavalAmmoCountSingle", function( len, pl ) 
	
	local ply = LocalPlayer()
	local boat = ply:GetScriptedVehicle()
	if( IsValid( boat ) && boat.Weaponry ) then 
		
		local idx = net.ReadInt(16)
		boat.Weaponry[idx].Cooldown = net.ReadInt(16)
	
	end 
	
end ) 
net.Receive("NeuroNavalAmmoCount", function( len, pl ) 
	
	local ply = LocalPlayer()
	local boat = ply:GetScriptedVehicle()
	if( IsValid( boat ) && boat.Weaponry ) then 
		
		for i=1,#boat.Weaponry do
			
			local idx = net.ReadInt(16)
			boat.Weaponry[idx].AmmoCounter = net.ReadInt(16)
			boat.Weaponry[idx].MaxAmmo = boat.Weaponry[idx].AmmoCounter
		end
		
	end 
	
end ) 

net.Receive("NeuroNavalCooldown", function( len, pl ) 
	
	local ply = LocalPlayer()
	local boat = ply:GetScriptedVehicle()
	if( IsValid( boat ) && boat.Weaponry ) then 
		
		local idx = net.ReadInt(16)
		-- local TimeStamp = net.ReadInt(32)
		-- print("received index:", idx, boat.WeaponSystems[boat.Weaponry[idx].wepDataIndex].Name )
		
		if( #boat.WeaponSystems >= idx ) then 
			
			-- print("Set Lastattack:" , idx )
			boat.Weaponry[idx].LastAttack = CurTime()
			boat.Weaponry[idx].Cooldown = boat.WeaponSystems[boat.Weaponry[idx].wepDataIndex].Cooldown 
			boat.Weaponry[idx].AmmoCounter = net.ReadInt(16)
			if( !boat.Weaponry[idx].MaxAmmo ) then 
				
				boat.Weaponry[idx].MaxAmmo = boat.Weaponry[idx].AmmoCounter
				
			end 
			
			
		end 
	
	
	end 
	
end ) 

net.Receive( "NeuroNavalWeapons", function( len, pl )
	
	local ply = LocalPlayer()
	local boat = ply:GetScriptedVehicle()
	-- print("Received Network Data")
	if( IsValid( ply ) && IsValid( boat ) ) then 
		
		boat.Weaponry = {}
		
		local count = net.ReadInt(32)
		for i=1, count do 
			local wep = net.ReadEntity()
			table.insert( boat.Weaponry, wep )
		
		end 
	
		
		if( boat.WeaponSystems ) then 
			
			for k,v in pairs( boat.WeaponSystems ) do 
			
				for i=1,#boat.Weaponry do 
					local wep = boat.Weaponry[i]
					
					if( IsValid( wep ) ) then 
					
					
						local weaponIndex = wep:GetNWInt("WeaponTableIndex")
						
						if( weaponIndex == k ) then 
							-- print( weaponIndex )
							boat.Weaponry[i].MaxYaw = v.MaxYaw 
							boat.Weaponry[i].WeaponGroup = v.WeaponGroup
							boat.Weaponry[i].wepDataIndex = weaponIndex 
							-- assign more data here if we need it.
						
						end 
 						
					end 
					
				
				end 
				
			end 
		
		
		end 
		-- PrintTable( boat.Weaponry )
		
	end 
	
end )

local compass = surface.GetTextureID("hud/ntec_compass") 
local compass_letters = surface.GetTextureID("hud/ntec_compass_letters") 
local plyHUDcolor = Color(25,200,50)
local Pi = math.pi
-- local radar_dot =  surface.GetTextureID("sprites/greenglow1")
local radar_dot =  surface.GetTextureID("hud/radar_dot")
local navalCrosshair = Material("VGUI/ui/crosshair.png" )
local navalGunhair = Material("VGUI/ui/gunhair.png" )
local navalViewArea = Material("VGUI/ui/viewconemarker.png" )
local navalViewArea2 = Material("VGUI/ui/viewconemarker2.png" )
local navalScope = Material("VGUI/ui/scope.png" )
local navalImpact = Material("VGUI/ui/impact.png" )
local shellIconDefault =  surface.GetTextureID("vgui/shells/HIGH_EXPLOSIVE_PREMIUM")  --Material("VGUI/shells/HIGH_EXPLOSIVE_PREMIUM" )
local overlayingpanel = nil 

surface.CreateFont("Base02",
				{	font = "Base 02",
					size = 40,
					weight 	= 700,
					antialias = true,
					additive =	false
				}
)
surface.CreateFont("Base03",
				{	font = "Base 02",
					size = 42,
					weight 	= 700,
					antialias = true,
					additive =	false
				}
)
surface.CreateFont("Electrolize",
				{	font = "Electrolize",
					size = 20,
					weight 	= 10000,
					antialias = true,
					additive =	false
				}
)
surface.CreateFont("Electrolize2",
				{	font = "Electrolize",
					size = 25,
					weight 	= 10000,
					antialias = true,
					additive =	false
				}
)
surface.CreateFont("CamouflageW",
				{	font = "Camouflage Woodland",
					size = 20,
					weight 	= 1,
					antialias = true,
					additive =	false
				}
)
surface.CreateFont("CamouflageW2",
				{	font = "Camouflage Woodland",
					size = 20,
					weight 	= 500,
					antialias = true,
					additive =	false
				}
)surface.CreateFont("CamouflageW3",
				{	font = "Camouflage Woodland",
					size = 12,
					weight 	= 500,
					antialias = true,
					additive =	false
				}
)
surface.CreateFont("Bulletto Killa",
				{	font = "Bulletto Killa à",
					size = 25,
					weight 	= 500,
					antialias = true,
					additive =	false
				}
)

concommand.Add("shipname", function( ply,cmd,args ) 
	
	NameBoatPopup()
	
end )

function NameBoatPopup()
	local Frame = vgui.Create( "DFrame" )
	Frame:SetPos( ScrW()/2-150, ScrH()/2-75 )  
	Frame:SetSize( 300, 65 ) 
	Frame:SetTitle( "Custom Ship Name" ) 
	Frame:SetVisible( true ) 
	Frame:SetDraggable( false ) 
	Frame:SetDeleteOnClose( true )
	Frame:ShowCloseButton( true ) 
	Frame:MakePopup() 
	local TextEntry = vgui.Create( "DTextEntry", Frame )	-- create the form as a child of frame
	TextEntry:SetPos( 10, 35 )
	TextEntry:SetSize( 280, 25 )
	TextEntry.OnEnter = function( self )
		if( string.len( self:GetValue() ) > 0 ) then 
		
			RunConsoleCommand("name_ship", tostring( self:GetValue() ) )
			Frame:Close()
		
		end 
	
	end
end 


local function CreateScrollCaptureFrame()
	if( overlayingpanel == nil ) then

		overlayingpanel = vgui.Create('DFrame')
		overlayingpanel.Tank = tank
		overlayingpanel:SetSize(ScrW()+100,ScrH()+100)
		overlayingpanel:SetPos(-50,-50)
		overlayingpanel:SetAlpha(0)
		overlayingpanel.OnMouseWheeled = function(panel, delta )
			LocalPlayer()._wheeldirection = delta
			-- print("Delta:", delta )
		end

	end 
end 

local function RemoveScrollCaptureFrame()
	
	if( overlayingpanel != nil ) then 
		
		overlayingpanel:Remove()
	
	end 
	
end 
local MAX_ZOOM = 5
local DEFAULT_ZOOM = 90 
local sensitivityFraction = 1.0
hook.Add("AdjustMouseSensitivity","AdjustNavalZoomSensitvity", function( sens ) 
	local ply = LocalPlayer()
	
	if( ply.zoomValue && IsValid( ply:GetScriptedVehicle() ) && ply:GetScriptedVehicle().IsMicroCruiser ) then 
		
		ply.sensitivityFraction = ply.zoomValue / DEFAULT_ZOOM 
		
		return math.Clamp( ply.sensitivityFraction, 0, 1 )
		
	end 
	
	return -1 
end )

function NeuroNaval_DefaultBoatCView( ply, Origin, Angles, Fov, self )
				
			
	local plane = ply:GetScriptedVehicle()

	local view = {
		origin = Origin,
		angles = Angles,
		nearz = 1.6
		}

	if( IsValid( plane ) && ply:GetNetworkedBool( "ToSea", false )  ) then

		local pos
		local farDist = plane.CamDist
		local upDist =  plane.CamUp
		
		if( ply.sensitivityFraction && plane.IsMicroCruiser ) then 
			
			farDist = farDist * ply.sensitivityFraction
			
		end 
		if( !ply.zoomValue && plane.IsMicroCruiser ) then ply.zoomValue = DEFAULT_ZOOM end 
	
		if( GetConVarNumber("jet_cockpitview") > 0 ) then
				
			pos = plane:LocalToWorld( self.CockpitviewPosition )
			
		else
			
			local tr,trace = {},{}
			tr.start = plane:GetPos()
			tr.endpos = tr.start+ plane:GetUp() * upDist + ply:GetAimVector() * -farDist
			tr.filter = { plane, ply }
			tr.mask = MASK_SOLID_BRUSHONLY
			trace = util.TraceLine ( tr )
			
			pos = trace.HitPos + trace.HitNormal * 16
			local minz = plane.CameraMinZ or 350 
			if( pos.z < self:GetPos().z+minz ) then pos.z = self:GetPos().z + minz end 
			
		end
		
		if( plane.IsMicroCruiser ) then 
		
			if( input.IsShiftDown() && !vgui.CursorVisible() ) then 
			
				ply.zoomValue = Lerp( FrameTime()*4, ply.zoomValue, MAX_ZOOM )
				ply:ConCommand("_neuronaval_zoomvalue "..ply.zoomValue )
				
			elseif( input.IsControlDown() && !vgui.CursorVisible()  ) then 
				
				ply.zoomValue = Lerp( FrameTime()*4, ply.zoomValue, DEFAULT_ZOOM )
				ply:ConCommand("_neuronaval_zoomvalue "..ply.zoomValue )
				
			end 
		else
			
			ply.zoomValue = DEFAULT_ZOOM
			
		end 
		
		local ang,pAng = ply:GetAimVector():Angle(), plane:GetAngles()
		if( ply.sensitivityFraction && ply.sensitivityFraction < 1 && self.PeriscopePosition ) then 
			
			pos = LerpVector( 0.999-ply.sensitivityFraction, pos, plane:LocalToWorld( self.PeriscopePosition ) )
			pos.z = pos.z + ( DEFAULT_ZOOM / ply.zoomValue )*16
			
		end 
		
		local shell = ply:GetNWEntity("_CINEMATIC_SHELL")

		if( IsValid( shell ) && input.IsKeyDown( KEY_V ) ) then 
				
			pos = LerpVector( 0.97, pos, shell:GetPos() + shell:GetUp() * 15 + shell:GetForward() * 10 )
			-- ang = LerpAngle( .4, ang, ( pos - shell:GetPos() ):Angle() )
		end 
		
		view = {
			origin = pos,
			angles = Angle( ang.p, ang.y, pAng.r / 1.55 ),
			fov = ply.zoomValue
			}
	
		-- CreateScrollCaptureFrame()
		
	else
		
		-- RemoveScrollCaptureFrame()
		
	end
	
	-- print( "Im running too")
	return view
	
end

local Naval = {}
Naval.Ship = NULL
Naval.Captain = NULL
Naval.Target = NULL
local W,H= ScrW(),ScrH()

hook.Add("PostDrawOpaqueRenderables", "example", function()
	local ply = LocalPlayer()
	local boat = ply:GetScriptedVehicle()
	
	if( IsValid( boat ) && boat.IsMicroCruiser ) then 
		---- DEBUG

	 -- */
		--- DEBUG 
		local weapons = boat.Weaponry
		local SelectedWeapon = ply:GetNWInt("Selected_Weapon")
			
		if( weapons && !vgui.CursorVisible() && input.IsKeyDown( KEY_H )  ) then 
			
			local tr,trace = {},{}
			tr.start = boat:GetPos() + Vector( 0,0,55 )
			tr.endpos = tr.start + Vector(0,0,-155 )
			tr.mask = MASK_WATER 
			tr.filter = { v, boat}
			trace = util.TraceLine( tr )
			local campos = boat:GetPos()
				
			campos.z = trace.HitPos.z + trace.HitNormal.z 
					
			cam.Start3D2D( campos,  Angle( 0, boat:GetAngles().y, 0 ) , 4 )


				surface.SetDrawColor( Color( 255,255,255,25 ))
				surface.SetMaterial( navalViewArea )
				surface.DrawTexturedRectRotated( 0,0, 512, 512, 0 )
		
		
			cam.End3D2D()
			for k,v in ipairs( weapons ) do 
				
				if( v.WeaponGroup == SelectedWeapon ) then 
					
					local Baseobj = v:GetParent()				
					local tr,trace = {},{}
					tr.start = Baseobj:GetPos() + Vector( 0,0,50 )
					tr.endpos = tr.start + Vector(0,0,-150 )
					tr.mask = MASK_WATER 
					tr.filter = { v, boat, Baseobj }
					trace = util.TraceLine( tr )
					local wepIndex = v:GetNWInt("WeaponTableIndex") or 1
				
					local boatpos = boat:GetPos()
				
					local turretstart = v:GetPos()
					local turretEnd = v:GetPos() + v:GetForward() * 6650 
					local angLeft = Baseobj:GetAngles()
					local angRight =  Baseobj:GetAngles()
					-- local angWave =  Baseobj:GetAngles()
					local maxYaw = v.Weap
					angLeft:RotateAroundAxis( Baseobj:GetUp(), v.MaxYaw )
					angRight:RotateAroundAxis( Baseobj:GetUp(), -v.MaxYaw )
					-- local adiff = math.AngleDifference( angRight.y, angLeft.y )
					-- print( adiff )
					-- for i=1,3*math.abs(adiff) do
					
						-- angWave:RotateAroundAxis( Baseobj:GetUp(), math.sin(CurTime()*1) * -v.MaxYaw+1 )
					-- angWave:RotateAroundAxis( Baseobj:GetUp(), math.sin( CurTime() ) * ( -v.MaxYaw+1) )
					-- local endpos3 = (v:GetPos() + ( angWave:Forward() * 25 ))
					-- endpos3.z = trace.HitPos.z + trace.HitNormal.z  
				
					-- render.DrawLine( turretstart, endpos3, Color( 255,25,0,255 ),false )
					
					-- end 
	
					local campos = Baseobj:GetPos()

					campos.z = trace.HitPos.z + trace.HitNormal.z 
					
					local endpos1 = (v:GetPos() + ( angLeft:Forward() * 26000 ))
					local endpos2 = (v:GetPos() + ( angRight:Forward() * 26000))
			
					endpos1.z = campos.z 
					endpos2.z = endpos1.z
					boatpos.z = endpos2.z 
					turretstart.z = endpos2.z 
					turretEnd.z = endpos2.z 
			
					render.DrawLine( turretstart, endpos1, Color( 0,255,0,55 ),true )
					render.DrawLine( turretstart, endpos2, Color( 0,255,0,55 ),true )
					
					render.DrawLine( turretstart, turretEnd, Color( 255,5,0,255 ),true )


				end 
				
			end 
		
		end 
		
			
	end 
	
end )
	
local GunIndicator = Material(  "vgui/ui/ships/gun_ind.png" )		
function DrawNavalHUD()

	local ply = LocalPlayer()
	local boat = ply:GetScriptedVehicle() 
	Naval.Captain = LocalPlayer()
	if( !IsValid( Naval.Captain ) ) then return end
	
	Naval.Ship = Naval.Captain:GetNetworkedEntity( "Ship", NULL )
	
	if( !IsValid( Naval.Ship) ) then return end 
	

	

	
	
	if(  boat.Weaponry && Naval.Ship.WeaponSystems && Naval.Ship.NumberOfWeaponGroups  ) then 
	
	
		-- print("??")
		local weapons = boat.Weaponry
		local SelectedWeapon = ply:GetNWInt("Selected_Weapon")

		if( boat.HUDData ) then
			surface.SetMaterial( boat.HUDData.Background )
			surface.SetDrawColor( Color( 255,255,255,255) ) 
			surface.DrawTexturedRectRotated(boat.HUDData.X, boat.HUDData.Y, boat.HUDData.W,boat.HUDData.H, boat.HUDData.Rotation  )
			-- local count = 0 
			
			for k,v in ipairs( weapons ) do 
				
				local maxrot = -math.AngleDifference( boat:GetAngles().y, v:GetAngles().y ) 
				-- if( v.WeaponGroup == SelectedWeapon ) then 
					-- count = count + 1 
					-- maxrot = 
					local wepdata = boat.WeaponSystems[v.wepDataIndex]
					-- if( wepdata.TAng ) then 
						
						-- print( wepdata.TAng.y )
						-- maxrot = maxrot + wepdata.TAng.y
						-- print(maxrot )
				
					-- end 
					local ex,ey = 0,0 
					-- local size =32
					local ind = GunIndicator
					local indSize = 32
					
					
					if( wepdata && wepdata._2Dpos ) then 
						
						ex = wepdata._2Dpos.x 
						ey = wepdata._2Dpos.y 
						-- size =  wepdata._2Dpos.size 
						if( wepdata._2Dpos.icon ) then 
						
							 ind = wepdata._2Dpos.icon 
							 indSize = wepdata._2Dpos.iconSize
						end 
							
						-- print(wepdata)
						if( v.WeaponGroup == SelectedWeapon ) then 
						
							local targetYaw =  v:GetNWFloat("TowerYaw") or maxrot
							local tdiff = math.abs( math.AngleDifference ( targetYaw - boat:GetAngles().y  , maxrot) )
							local tcol =  Color( 255,25,25,75 )
							
							-- print( tdiff)
							if( tdiff < 2 ) then 
							
								tcol = Color( 25,255,25,25,255 )
								
							end 
								-- targetYaw = math.AngleDifference( )
							surface.SetDrawColor( tcol ) 
							surface.SetMaterial( GunIndicator  )	
							surface.DrawTexturedRectRotated( boat.HUDData.X+ex, boat.HUDData.Y+ey, indSize*1,indSize*3, targetYaw - boat:GetAngles().y )
										
						
						end 
						local scol = Color (255,255,255,255 )
						surface.SetDrawColor( scol ) 
						surface.SetMaterial( ind )
						surface.DrawTexturedRectRotated( boat.HUDData.X+ex, boat.HUDData.Y+ey, indSize,indSize,   maxrot )
			
						if( v.LastAttack && v.Cooldown && v.LastAttack + v.Cooldown >= CurTime() ) then
						local x,y = boat.HUDData.X+ex, boat.HUDData.Y+ey
							-- draw.RoundedBox( 4, x-12, y-12,  24, 24, Color(55,55,55,255) )
							surface.SetFont( "Electrolize2" )
							surface.SetTextColor( 255, 255, 255, 255 )
							surface.SetTextPos( x-8,y-10  ) 
							surface.DrawText( math.floor( v.Cooldown + v.LastAttack - CurTime() ) )

						end 
						if( v.AmmoCounter ) then 
							if( ex < 0 ) then 
								ex = -90 
							elseif( ex > 0 ) then 	
								ex = 50 
							end 
							local x,y = boat.HUDData.X+ex, boat.HUDData.Y+ey
							surface.SetFont( "Electrolize" )
							surface.SetTextColor( 25, 255, 45, 255 )
							surface.SetTextPos( x-8,y+5  ) 
							-- surface.DrawRect( x-81,y-35, 20, 20 )
						
							surface.DrawText(  v.AmmoCounter.."/"..v.MaxAmmo )

						
						end 
						
						
					end 
		
				-- end 
				
			
			end 
			
		end 
		

			
		for k=1, Naval.Ship.NumberOfWeaponGroups  do
			
			local v = Naval.Ship.WeaponSystems[k]
			local iconsize = 64
			local x,y = -(iconsize*.8) + ( (1.15*iconsize)*k ),10
			
			surface.SetDrawColor( Color( 45,155,45,255 ) )
			-- surface.DrawRect( x-2, y-2, iconsize, iconsize )
			surface.SetTextColor( 255,25,25, 255 )
			if( SelectedWeapon == k ) then 
				surface.SetDrawColor( Color( 45,255,45,255 ) )
					surface.SetTextColor( 25,255,25, 255 )
				surface.DrawOutlinedRect( x-3,y-3, iconsize+6,iconsize+6 )
			end 
			
				-- 	print( surface.GetTextureID( Naval.Ship.WeaponGroupIcons[k] ) ) 
				
			if( Naval.Ship.NewWeaponGroupIcons && #Naval.Ship.NewWeaponGroupIcons == Naval.Ship.NumberOfWeaponGroups	) then 
			
				surface.SetMaterial( Naval.Ship.NewWeaponGroupIcons[k] )
			
			else
			
				surface.SetTexture( shellIconDefault )
			
			end 
			
			surface.SetDrawColor(255,255,255,255)
			surface.DrawTexturedRect( x,y, iconsize,iconsize  )
		
			surface.SetTextPos( x , y+iconsize*1.1 )
			surface.SetFont( "CamouflageW" )
			surface.DrawText( "["..k.."]")
	
			
		end 
		
	end 
	
	for k,v in pairs( ents.GetAll() ) do 
	
		if( v.IsMicroCruiser && v != Naval.Ship ) then  --r 
			local distance = ( v:GetPos() - Naval.Ship:GetPos() ):Length() 
			local ShipName = v:GetNWString("ShipName") or "" 
			if( distance < 6000  && v:WaterLevel() < 3 ) then 
				
				local textAlpha = 255 
				if( distance > 6000-255 ) then 
					
					textAlpha = 6000-distance
				
				end 
				-- cam.Start3D2D(  ( v:GetPos() + Vector( 0,0,55 ) ), ( v:GetPos() - Naval.Ship:GetPos()):Angle()*-1, 1 )
					local pos = ( v:GetPos() + Vector( 0,0,155 ) ):ToScreen()
					local x,y =  pos.x,pos.y
					local vhp = v:GetNWInt("health")
					local maxhp = math.Clamp( v:GetNWInt( "MaxHealth" ), 0, 9999999999 )
			
					local ncol = Color( 222, 25, 25, textAlpha )
					if ( v:GetClass() == Naval.Ship:GetClass() ) then	
						
						ncol = Color( 25,222,25,textAlpha )
						
					end 
					local col = Color( plyHUDcolor.r, plyHUDcolor.g, plyHUDcolor.b, textAlpha )
					draw.SimpleText(ShipName.." ["..v.PrintName.."]", "Electrolize2", x, y-1, col, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
					-- draw.SimpleText(ShipName.." ["..v.PrintName.."]", "Electrolize2", x, y, ncol, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
				
					if( vhp && maxhp ) then 
						
						local hpcolor = 255 * vhp/maxhp 
					
						draw.SimpleText(math.floor(vhp).."/"..math.floor(maxhp).."HP", "Electrolize", x, y+20, Color( 255-hpcolor,25+hpcolor,25,textAlpha ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
						-- if( ) then 
						draw.SimpleText(math.floor((Naval.Ship:GetPos()-v:GetPos()):Length()).." dist", "Electrolize", x, y+40, Color( 255,25,25,textAlpha ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
						
						-- end 
						
					end 
				-- cam.End3D2D()
				-- draw.SimpleText(ShipName.." ["..v.PrintName.."]", "TargetID", x, y, Color( 25,255,25,255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
				
			end 
		
		end 
		
	end 
	
	Naval.Target = Naval.Captain:GetNetworkedEntity( "Target", NULL )

	if ( IsValid( Naval.Target ) && Naval.Target == Naval.Ship ) then		
		Naval.Target = NULL
	end

	local hp = math.floor( Naval.Ship:GetNWInt( "Health", 0 ) )
	local SystemsError = ( hp < 10 )	
	if ( Naval.Captain:GetNetworkedBool( "InFlight", false ) && Naval.Ship != Naval.Captain && not SystemsError ) then
	
		Naval.DrawArmor()
		Naval.DrawCrosshair()
		if( !Naval.Ship.IsMicroCruiser ) then 
			Naval.DrawArmamentStatus()
			Naval.DrawSubsystemsInfo()
		end 
		Naval.DrawCompass()
		Naval.DrawRadar()
		Naval.DrawTarget()
		if( Naval.Ship.IsMicroCruiser ) then 
		
			Naval.DrawWW2SubInstruments()
		
		end 
			
	end
	
end

local gauge = Material("vgui/ui/submarine-depth-gauge-dial.png" )
local gneedle = Material( "vgui/ui/submarine-depth-gauge-needle.png" )
local bfront = Material( "vgui/ui/ballast-front.png" )
local bback = Material( "vgui/ui/ballast-back.png" )
local depthGaugeLerpVal = 0 
/*
ENT.HUDConfig = {
	-- Depth Gauge and Ballast Meter
	GaugeSize = 128,
	GaugeNeedleStartAngle = 145,
	GaugeNeedleStopAngle = 190,
	GaugeFont = "DebugFixed",
	GaugeFontSmall = "DebugFixedSmall",
	GaugeDial = Material("vgui/ui/submarine-depth-gauge-dial.png" ),
	GaugeNeedle = Material( "vgui/ui/submarine-depth-gauge-needle.png" ),
	BallastGaugeSize = 192,
	BallastFrontPanel = Material( "vgui/ui/ballast-front.png" ),
	BallastBackPanel = Material( "vgui/ui/ballast-back.png" )
}
*/
function Naval.DrawWW2SubInstruments()
	
	
	local gaugeSize = 128+64
	local gaugeSize2 = 128
	local gaugeStartAngle = 145.0
	local gaugeStopAngle = 190
	local gaugeFont =  "DebugFixed"
	local gaugeFontSmall =  "DebugFixedSmall"
		
	local rotationalValue = Naval.Ship:GetNWFloat("CurrentDepth")
	local depthGaugeValue = Naval.Ship:GetNWFloat("CurrentBallastSize")
	local throttle = Naval.Ship:GetNWFloat("Throttle")
	local speed = Naval.Ship:GetNWFloat("ActualSpeed")
	
	if( Naval.Ship.IsMicroSubmarine ) then 
	
		if( Naval.Ship.HUDConfig ) then 
			
			local cfg = Naval.Ship.HUDConfig 
			
			gauge = cfg.GaugeDial
			gneedle = cfg.GaugeNeedle
			gaugeSize = cfg.BallastGaugeSize
			gaugeSize2 = cfg.GaugeSize
			gaugeStartAngle = cfg.GaugeNeedleStartAngle 
			gaugeStopAngle = cfg.GaugeNeedleStopAngle 
			gaugeFont = cfg.GaugeFont 
			gaugeFontSmall = cfg.GaugeFontSmall 
				
			bfront = cfg.BallastFrontPanel
			bback = cfg.BallastBackPanel
			
		end 
	
		depthGaugeLerpVal = Lerp( 0.5, depthGaugeLerpVal, (gaugeSize*.8)* (depthGaugeValue ) )
		-- print( depthGaugeValue )
		surface.SetDrawColor( 255, 255,255, 255 )
		surface.SetMaterial( bback )
		surface.DrawTexturedRect( ScrW() - gaugeSize*.85, ScrH() /2.7  , gaugeSize,gaugeSize )
		surface.SetDrawColor( Color( 255,45,25,255 ) )
		surface.DrawRect( ScrW() - gaugeSize/2.15, ScrH()/2.55+depthGaugeLerpVal, gaugeSize*.25,  6 )
		surface.SetDrawColor( Color( 255,255,255,255 ) )
		surface.SetMaterial( bfront )
		surface.DrawTexturedRect( ScrW() - gaugeSize*.85, ScrH() /2.7, gaugeSize,gaugeSize )
		surface.SetFont( gaugeFontSmall )
		surface.SetTextColor( 25, 255, 25, 255  )
		surface.SetTextPos( ScrW() - gaugeSize/2.1, ScrH() /2.62 ) 
		surface.DrawText( "BALLAST" )

		local gaugeY = 340
		gaugeSize2 = 128 

		surface.SetDrawColor( 255, 255,255, 255 )
		surface.SetMaterial( gauge )
		surface.DrawTexturedRect( ScrW() - gaugeSize2, ScrH() - gaugeY , gaugeSize2,gaugeSize2 )
		
			-- draw.RoundedBox( 4, x-12, y-12,  24, 24, Color(55,55,55,255) )
		surface.SetFont( gaugeFont )
		surface.SetTextColor( 45, 25, 25, 255  )
		surface.SetTextPos( ScrW() - gaugeSize2/1.55, ScrH() - gaugeY+gaugeSize2/1.4 ) 
		surface.DrawText( "DEPTH" )

		surface.SetMaterial( gneedle )
		surface.DrawTexturedRectRotated( ScrW() - gaugeSize2/2, ScrH() - gaugeY+gaugeSize2/2, gaugeSize2 ,gaugeSize2, gaugeStartAngle - ( gaugeStopAngle * rotationalValue ) )
		
	end 
	
	if( speed > 0 ) then 
	
		ThrottlePos = Lerp( .125, ThrottlePos, throttle ) 
	
	else
		
		ThrottlePos = Lerp( .125, ThrottlePos, -throttle ) 
	
	
	end 
	
	-- print( throttle, ThrottlePos  )
	local telY = 70
	surface.SetDrawColor( Color( 255,255,255,255 ))
	surface.SetMaterial( TelegraphPole )
	surface.DrawTexturedRectRotated( ScrW() - telY, ScrH()-55, 128, 128, 0 )
	surface.SetMaterial( Telegraph )
	surface.DrawTexturedRectRotated( ScrW() - telY, ScrH()-128, 128, 128, 0 )
	surface.SetMaterial( TelegraphStick )
	
	surface.DrawTexturedRectRotated( ScrW() - telY, ScrH()-128, 266, 266, 180 + (120  * ThrottlePos ) )

end 

function Naval.DrawCrosshair()

	local ply = LocalPlayer()
	if( IsValid( Naval.Ship ) && Naval.Ship.IsMicroCruiser ) then 
		
		-- local tr,trace = {},{}
		-- tr.start = Naval.Captain:GetShootPos()
		-- tr.endpos = tr.start + ply:GetAimVector() * 16500 
		-- tr.filter = { Naval.Captain, Naval.Ship }
		-- tr.mask = MASK_SOLID_BRUSHONLY + MASK_WATER
		-- trace = util.TraceLine( tr )
		-- local hpos = trace.HitPos:ToScreen()
		
		ply.serverVector = ply:GetNWVector("_NNHPOS" )
		if( !ply.lastVector ) then ply.lastVector = ply.serverVector end 
			
		if( ply.serverVector && ply.zoomValue ) then 
			
			ply.lastVector = LerpVector( FrameTime()*5, ply.lastVector, ply.serverVector )
			local Mult = math.Clamp( 1.1 - ply.zoomValue / DEFAULT_ZOOM, 0, 1 ) 
			local hpos = ply.lastVector:ToScreen()
			local x,y = hpos.x, hpos.y
			local h,w = ScrH(), ScrW()
			local size = 1024/16
			-- if( GetConVarNumber("jet_cockpitview")>0) then	
				-- size = 512
			-- end 
			
			local halfsize = size/2 
			surface.SetDrawColor( 25, 255,25, 155 )
			surface.SetMaterial( navalGunhair )
			surface.DrawTexturedRect(x-halfsize, y-halfsize, size,size )
			
			local shell = ply:GetNWEntity("_CINEMATIC_SHELL")
			if( IsValid( shell ) && input.IsKeyDown( KEY_V ) ) then 
				ply.zoomValue = Lerp( .35, ply.zoomValue, DEFAULT_ZOOM )
				
			end 
			-- print( Mult > .5 )
			if( Mult > .15 && !( IsValid( shell ) && input.IsKeyDown( KEY_V  ) ) ) then 

				surface.SetDrawColor( 255, 255, 255, Mult * 255 )
				surface.SetMaterial( navalScope )
				surface.DrawTexturedRect(0,0,ScrW(),ScrH() )
					
				surface.SetDrawColor( 255, 255, 255, Mult * 255 )
				surface.SetMaterial( navalCrosshair )
				surface.DrawTexturedRect(ScrW()/2-(ScrW()*.25), ScrH()/2-(ScrW()*.25), ScrW()*.5,ScrW()*.5 )
			
			else	
				
			
				
			end 
			
		-- end 
		
			
		
		end 
	
	end 
	local color,red,grey = plyHUDcolor,Color(255,0,0),Color(150,150,150)
	local blue = Color(0,50,200)
	local accuracy = 1 //decreases while firing continuously.

	local wep = Naval.Ship:GetNetworkedString("NeuroPlanes_ActiveWeapon",tostring("NONE_AVAILABLE"))
	local wepType = Naval.Ship:GetNetworkedString("NeuroPlanes_ActiveWeaponType",tostring("NONE_AVAILABLE"))
	local offs = Naval.Ship:GetNWInt( "HudOffset", 0 )
	local shipPos =  ( Naval.Ship:GetPos() + Naval.Ship:GetUp()*offs ):ToScreen()
	local pos =  ( Naval.Ship:GetPos( ) + Naval.Ship:GetUp( ) * offs + Naval.Ship:GetForward( ) * 100000 ):ToScreen()
	local bpos =  ( Naval.Ship:GetPos( ) + Naval.Ship:GetForward( ) * (500+Naval.Ship:GetVelocity():Length()/20) + Naval.Ship:GetUp( ) * offs ):ToScreen()
	local x,y = pos.x, pos.y
	local bx,by = bpos.x, bpos.y
	local r = math.rad(Naval.Ship:GetAngles().r)
	local cosr = math.cos(r)
	local sinr = math.sin(r)
	local tpos
	local tx,ty = 0,0
	if IsValid( Naval.Target ) then
		tpos = ( Naval.Target:GetPos()):ToScreen()
		tx,ty = tpos.x, tpos.y
	end
	
	//artillery
	if ( wepType == "Cannon" ) then
		DrawHUDLine( Vector(W/2-H/12,H/2,0), Vector(W/2-H/64,H/2,0), plyHUDcolor )
		DrawHUDLine( Vector(W/2+H/12,H/2,0), Vector(W/2+H/64,H/2,0), plyHUDcolor )
		DrawHUDLine( Vector(W/2,H/2+H/16,0), Vector(W/2,H/2+H/64,0), plyHUDcolor )
	end

	//torpedo
	if ( wepType == "Torpedo" ) then
		DrawHUDEllipse(Vector(W/2,H/2,0) ,Vector(H/24,H/13,0), plyHUDcolor)	
		DrawHUDLine( Vector(W/2-H/10,H/2,0), Vector(W/2-H/32,H/2,0), plyHUDcolor )
		DrawHUDLine( Vector(W/2+H/10,H/2,0), Vector(W/2+H/32,H/2,0), plyHUDcolor )
		DrawHUDLine( Vector(W/2,H/2-H/10,0), Vector(W/2,H/2-H/16,0), plyHUDcolor )
		DrawHUDLine( Vector(W/2,H/2+H/10,0), Vector(W/2,H/2+H/16,0), plyHUDcolor )

		-- DrawHUDLine( shipPos, pos, plyHUDcolor ) //Cheat! :P
		-- DrawHUDLine( shipPos, Vector(W/2,H/2+H/64,0), plyHUDcolor )

	end
	//anti air
	if ( wepType == "AA" ) then
	DrawHUDEllipse(Vector(W/2,H/2,0) ,Vector(H/16,H/16,0), grey)	
	DrawHUDRect(Vector(W/2-H/16*(1-accuracy/2+1/6),H/2-1,0),H/16/6,3,red)	//left
		DrawHUDLine( Vector(W/2-H/16,H/2,0), Vector(W/2-H/32,H/2,0), grey )		
	DrawHUDRect(Vector(W/2+H/16*(1-accuracy/2),H/2-1,0),H/16/6,3,red)		//right
		DrawHUDLine( Vector(W/2+H/16,H/2,0), Vector(W/2+H/32,H/2,0), grey )		
	DrawHUDRect(Vector(W/2-1,H/2-H/16*(1-accuracy/2+1/6),0),3,H/16/6,red)	//up
		DrawHUDLine( Vector(W/2,H/2-H/16,0), Vector(W/2,H/2-H/32,H/2,0), grey )	
	DrawHUDRect(Vector(W/2-1,H/2+H/16*(1-accuracy/2),0),3,H/16/6,red)		//down
		DrawHUDLine( Vector(W/2,H/2+H/16,0), Vector(W/2,H/2+H/32,H/2,0), grey ) 
	end
	
	//submarine grenade
	if ( wepType == "Seamine" ) then
		DrawHUDEllipse(Vector(W/2,H/2,0) ,Vector(H/32-2,H/32-2,0), blue)	
		DrawHUDEllipse(Vector(W/2,H/2,0) ,Vector(H/32,H/32,0), plyHUDcolor)	
		DrawHUDLine( Vector(W/2-H/12,H/2,0), Vector(W/2-H/32,H/2,0), plyHUDcolor )
		DrawHUDLine( Vector(W/2+H/12,H/2,0), Vector(W/2+H/32,H/2,0), plyHUDcolor )
	end
		
	//surface-to-ground
	if ( wepType == "Singlelock" ) then
		local r = H/64
		for i=1, 2 do 
		DrawHUDLine( Vector(W/2+r,H/2-r,0), Vector(W/2+r*(1+math.cos(i*Pi/6)),H/2-r*(1+math.sin(i*Pi/6)),0), red )	//top right	
		DrawHUDLine( Vector(W/2-r,H/2+r,0), Vector(W/2-r*(1+math.cos(i*Pi/6)),H/2+r*(1+math.sin(i*Pi/6)),0), red )	//bottom left	
		end
		for i=4, 5 do 
		DrawHUDLine( Vector(W/2-r,H/2-r,0), Vector(W/2-r*(1-math.cos(i*Pi/6)),H/2-r*(1+math.sin(i*Pi/6)),0), red )	//top left		
		DrawHUDLine( Vector(W/2+r,H/2+r,0), Vector(W/2+r*(1-math.cos(i*Pi/6)),H/2+r*(1+math.sin(i*Pi/6)),0), red )	//bottom right
		end
	end
	
end

function Naval.DrawSubsystemsInfo()

	
	local color,white,red,grey = plyHUDcolor, Color(255,255,255),Color(255,0,0),Color(150,150,150)
	local x,y = W-H/4,H-H/4
	local rmax,rmin = H/8,H/8/4
	local spd = Naval.Ship:GetVelocity():Length()
	local maxspeed = Naval.Ship.MaxVelocity 
 	local minspeed = Naval.Ship.MinVelocity
	local spdsign = 1
	local throttle = Naval.Ship:GetNWInt( "Throttle", 0)
	throttle = math.Clamp( throttle, minspeed, maxspeed )

	//static elements
	DrawHUDEllipse(Vector(x,y,0) ,Vector(rmax,rmax,0),plyHUDcolor)
	DrawHUDEllipse(Vector(x,y,0) ,Vector(rmin,rmin,0),plyHUDcolor)
	DrawHUDLine( Vector(x-rmin*math.cos(-Pi/3),y-rmin*math.sin(-Pi/3),0), Vector(x-rmax*math.cos(-Pi/3),y-rmax*math.sin(-Pi/3),0), plyHUDcolor )		
	DrawHUDLine( Vector(x-rmin*math.cos(Pi/3),y-rmin*math.sin(Pi/3),0), Vector(x-rmax*math.cos(Pi/3),y-rmax*math.sin(Pi/3),0), plyHUDcolor )		
	DrawHUDLine( Vector(x-rmin*math.cos(Pi/3-Pi/12),y-rmin*math.sin(Pi/3-Pi/12),0), Vector(x-rmax*math.cos(Pi/3-Pi/12),y-rmax*math.sin(Pi/3-Pi/12),0), plyHUDcolor )		
	
	DrawHUDLine( Vector(x-rmin*math.cos(-Pi/12+Pi),y-rmin*math.sin(-Pi/12+Pi),0), Vector(x-rmax*math.cos(-Pi/12+Pi),y-rmax*math.sin(-Pi/12+Pi),0), plyHUDcolor )		
	draw.SimpleText("STOP", "TargetID", x+rmax*0.9, y, plyHUDcolor, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER )
	DrawHUDLine( Vector(x-rmin*math.cos(Pi/12+Pi),y-rmin*math.sin(Pi/12+Pi),0), Vector(x-rmax*math.cos(Pi/12+Pi),y-rmax*math.sin(Pi/12+Pi),0), plyHUDcolor )		
	draw.SimpleText("Full", "TargetID", x-rmax*math.cos(Pi/3)*0.6, y-rmax*math.sin(Pi/3)*0.8, plyHUDcolor, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER )
	draw.SimpleText("Rev", "TargetID", x-rmax*math.cos(Pi/3)*0.6, y+rmax*math.sin(Pi/3)*0.8, plyHUDcolor, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER )
	DrawHUDLine( Vector(x-rmax*math.cos(Pi/2-Pi/6),y-rmax*math.sin(Pi/2-Pi/6),0), Vector(x-1.2*rmax*math.cos(Pi/2-Pi/6),y-1.2*rmax*math.sin(Pi/2-Pi/6),0), grey )		
	DrawHUDLine( Vector(x-rmax*math.cos(Pi/2),y-rmax*math.sin(Pi/2),0), Vector(x-1.2*rmax*math.cos(Pi/2),y-1.2*rmax*math.sin(Pi/2),0), grey )		
	DrawHUDLine( Vector(x-rmax*math.cos(Pi/2+Pi/6),y-rmax*math.sin(Pi/2+Pi/6),0), Vector(x-1.2*rmax*math.cos(Pi/2+Pi/6),y-1.2*rmax*math.sin(Pi/2+Pi/6),0), grey )		
	//speed indicator
	local displayspeed = spd 
	if( Naval.Ship.IsMicroCruiser ) then 
		displayspeed = spd * 10 
		
	end 
	
	draw.SimpleText(math.floor(displayspeed*0.3048/16/1,852).." kts", "TargetID", x+rmin*0.8, y, white, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER )
	local cosr = math.cos((4*spd/maxspeed-1)*Pi/3)
	local sinr = math.sin((4*spd/maxspeed-1)*Pi/3)
	DrawHUDLine( Vector(x-rmin*cosr,y-rmin*sinr,0), Vector(x-rmax*cosr,y-rmax*sinr,0), red )		
	//Throttle
	if throttle < 0 then spdsign = Naval.Ship.MaxVelocity/Naval.Ship.MinVelocity else spdsign = 1 end
	local coss1 = math.cos(-throttle*spdsign/maxspeed*2*Pi-Pi-Pi/12)
	local sins1 = math.sin(-throttle*spdsign/maxspeed*2*Pi-Pi-Pi/12)
	local coss2 = math.cos(-throttle*spdsign/maxspeed*2*Pi-Pi+Pi/12)
	local sins2 = math.sin(-throttle*spdsign/maxspeed*2*Pi-Pi+Pi/12)
	DrawHUDLine( Vector(x-rmin*coss1,y-rmin*sins1,0), Vector(x-rmax*coss1,y-rmax*sins1,0), white )		
	DrawHUDLine( Vector(x-rmin*coss2,y-rmin*sins2,0), Vector(x-rmax*coss2,y-rmax*sins2,0), white )		
	//direction
	local lateralspd = funcDerivate(-Naval.Ship:GetAngles().y)/18*Naval.Ship.TurnModifierValue
	local cosl = math.cos( lateralspd*Pi/6+Pi/2)
	local sinl = math.sin( lateralspd*Pi/6+Pi/2)
	DrawHUDLine( Vector(x-rmax*cosl,y-rmax*sinl,0), Vector(x-1.2*rmax*cosl,y-1.2*rmax*sinl,0), white )		
	
end

function Naval.DrawArmamentStatus()
-- //This function checks the status of all weapons/turrets on the ship.
	local wep = Naval.Ship:GetNetworkedString("NeuroPlanes_ActiveWeapon",tostring("NONE_AVAILABLE"))
	local wepType = Naval.Ship:GetNetworkedString("NeuroPlanes_ActiveWeaponType",tostring("NONE_AVAILABLE"))

	local x,y = W-H/4,H-H/4
	local rmax,rmin = H/8,H/8/4
	
	-- draw.SimpleText(wep, "TargetID", x, y+rmax+rmin, plyHUDcolor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
	draw.SimpleText(wep, "TargetID", x-W/2+H/4, y+H/8, plyHUDcolor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )

	-- BarFiller()
	
end

function Naval.DrawArmor()
	local hp = Naval.Ship:GetNWInt("Health",0)
	local maxhp = Naval.Ship:GetNWInt( "MaxHealth",0)
	local h = hp/maxhp

	local color,white,red,grey = plyHUDcolor, Color(255,255,255),Color(255,0,0),Color(150,150,150)
	local width,height = H/3,15
	local x,y,o = 64,H-5*height,4
	local rmax,rmin = H/8,H/8/4
	DrawHUDRect(Vector(x-o/2,y-o/2,0),width+o,height+o,grey)	
	DrawHUDRect(Vector(x,y,0),width*h,height,Color(255*(1-h),255*h,0,255))
	local extra = ""
	if( Naval.Ship:GetNWString("ShipName") ) then 
		extra = Naval.Ship:GetNWString("ShipName").. " - "
	end 
	

	draw.SimpleText(extra..Naval.Ship.PrintName, "Electrolize", x, y-height, plyHUDcolor, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER )
	draw.SimpleText(math.floor(100*h).." %", "TargetID", x+width/2.5, y+height/2.35, white, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER )

	-- BarFiller()
	
end

local function BarFiller()
//Used with DrawArmamentStatus
end

function Naval.DrawTarget()

	local color = Color(0,150,200)
	local Pi = math.pi

	
	if IsValid(Naval.Target) then
		local tpos = Naval.Target:GetPos():ToScreen()
		local tx,ty = tpos.x,tpos.y
		local dist = (Naval.Target:GetPos()- Naval.Ship:GetPos()):Length()

		local size = Naval.Target:BoundingRadius()
		local ScaleVect = (Naval.Target:OBBMaxs()/size):ToScreen()

		local r = H/128 * (1+2*math.exp(-dist) )* 20*size/dist
		local s = 4
		for i=1, 2 do 
		DrawHUDLine( Vector(tx+r*s,ty-r,0), Vector(tx+r*(s+math.cos(i*Pi/6)),ty-r*(1+math.sin(i*Pi/6)),0), color )	//top right	
		DrawHUDLine( Vector(tx-r*s,ty+r,0), Vector(tx-r*(s+math.cos(i*Pi/6)),ty+r*(1+math.sin(i*Pi/6)),0), color )	//bottom left	
		end
		for i=4, 5 do 
		DrawHUDLine( Vector(tx-r*s,ty-r,0), Vector(tx-r*(s-math.cos(i*Pi/6)),ty-r*(1+math.sin(i*Pi/6)),0), color )	//top left		
		DrawHUDLine( Vector(tx+r*s,ty+r,0), Vector(tx+r*(s-math.cos(i*Pi/6)),ty+r*(1+math.sin(i*Pi/6)),0), color )	//bottom right
		end
	end

end

function Naval.DrawCompass()
//Draw the compass on HUD.
	local yaw =(-Naval.Ship:GetAngles().y/360)
	local width,height = 256, 16
	local x,y = W/2-width/2, 5
	surface.SetTexture(compass) //Top bars
	surface.SetDrawColor( plyHUDcolor ,255 )
	surface.DrawTexturedRectUV( x, y, width, height, yaw , 0, yaw+0.4, 1 )
	surface.SetTexture(compass_letters) ////top letters
	surface.SetDrawColor( plyHUDcolor ,200 )
	surface.DrawTexturedRectUV( x, y+height, width, height, yaw, 0, yaw+0.4,1 );
	DrawHUDOutlineRect(Vector(x,y,0),width,2*height,plyHUDcolor)
end

local RadarScreen = Material("VGUI/ui/radar-monitor.png")
local RadarScreen2 = Material("VGUI/ui/radar-broken.png")
local RadarGrid = Material("VGUI/ui/radar-grid.png")

function Naval.DrawRadar()
//Draw the radar on HUD.


	
	local grey,green = Color(150,150,150), Color(0,150,50)
	local width,height,radius = H/16, H/16,H/16
	local x,y = W-H/9,height*1.52
	if( Naval.Ship.IsMicroCruiser ) then 
		
		surface.SetDrawColor( Color( 255,255,255,255 ) )
		if( Naval.Ship:GetNWBool("RadarFucked") ) then
		
			surface.SetMaterial( RadarScreen2 )
			
		else
		
			surface.SetMaterial( RadarScreen )
		
		end 
		
		local sz,sy = width*5, height*5 
		
		surface.DrawTexturedRectRotated( x-sz/10,y-sy/25, sz, sy, 0 )
		
		if( Naval.Ship:GetNWBool("RadarFucked") ) then return end 
		
		surface.SetDrawColor( Color( 250 + math.random(-5,5) ,250 + math.random(-5,5) ,250 + math.random(-5,5) ,240+math.tan(CurTime())*5) )
		surface.SetMaterial( RadarGrid )
		surface.DrawTexturedRectRotated( x-sz/10+math.cos(CurTime()/2)*.1, (y-sy/25)+math.tan(CurTime()*2)*.05, sz, sy, 0 )
		
		
	end 
	local scalex = 0.3 
	local scaley = 0.6 
	DrawHUDEllipse(Vector(x,y,0) ,Vector(width,height,0),green)
	DrawHUDEllipse(Vector(x,y,0) ,Vector(width*scalex,height*scalex,0),green)
	DrawHUDEllipse(Vector(x,y,0) ,Vector(width*scaley,height*scaley,0),green)
	DrawHUDLine( Vector(x,y,0), Vector(x-radius*math.cos(Pi/2+Pi/6),y-radius*math.sin(Pi/2+Pi/6),0), green )	
	DrawHUDLine( Vector(x,y,0), Vector(x-radius*math.cos(Pi/2-Pi/6),y-radius*math.sin(Pi/2-Pi/6),0), green )	
	
	local time = CurTime()
	-- DrawHUDLine( Vector(x,y,0), Vector(x+radius*math.cos(time/2),y+radius*math.sin(time/2),0), Color(0,255,50) )	
	for i=0,20 do
	DrawHUDLine( Vector(x,y,0), Vector(x+radius*math.cos(time/2-i*0.01),y+radius*math.sin(time/2-i*0.01),0), Color(0,255-i*150/20,50) )	
	end
	
	Naval.FindEnnemies()

end

function Naval.FindEnnemies()

	local ang = Naval.Ship:GetAngles()
	local minrange,maxrange =500,100
	local time = CurTime()
	local cost, sint = math.cos(time/2), math.sin(time/2)
	local ox,oy = W-H/9,H/16*1.2

	
	for k,v in pairs( ents.FindByClass( "sent*" ) ) do
		if ( IsValid( v ) && v.PrintName && v != LocalPlayer():GetScriptedVehicle() && v != Naval.Ship && ( v.Type == "vehicle" || ( v.PrintName == "Missile" ) ) ) then
			
			-- local pos = v:GetPos():ToScreen()
			local pos = (v:GetPos()-Naval.Ship:GetPos()):GetNormalized()
			local d = (v:GetPos()-Naval.Ship:GetPos()):Length2D()
			local fw = v:GetForward():Angle()
			-- local tang = v:GetAngles()
			local tang = (v:GetPos()-Naval.Ship:GetPos()):Angle()
			-- local x,y = pos.x, pos.y
			local x = d/maxrange*math.cos(-math.rad(tang.y-ang.y)-Pi/2)
			local y = d/maxrange*math.sin(-math.rad(tang.y-ang.y)-Pi/2)
			local dx = 10*math.cos(-math.rad(tang.y-ang.y)-Pi/2)
			local dy = 10*math.sin(-math.rad(tang.y-ang.y)-Pi/2)
			local size = v:BoundingRadius()
			local sizemin,sizemax = v:WorldSpaceAABB()			
			local delay = math.exp( 0.5/math.mod(time-math.rad(tang.y-ang.y),4*Pi) )-1
			-- local delay = (x*maxrange/d - cost)*(y*maxrange/d - sint)
			
			if (d>minrange) && (d/maxrange<H/8) then
				DrawHUDEllipse(Vector(ox+x,oy+y,0) ,Vector(2,2,0),Color(0,255,50,255*math.exp( math.exp(10) )) )
				-- DrawHUDLine( Vector(ox+x,oy+y,0), Vector(ox+x+dx,oy+y+dy,0), Color(0,255,50) )	

				-- surface.SetAlphaMultiplier( 0.1 )
				surface.SetDrawColor( 0, 255 , 0, 255*delay )
				surface.SetTexture( radar_dot )
				surface.DrawTexturedRectRotated( ox+x, oy+y, 0.05*sizemin.y/size, 0.05*sizemax.y/size, tang.y-ang.y )
			end

		end
	end
end

hook.Add( "HUDPaint", "NeuroNaval__HeadsUpDisplay", DrawNavalHUD )

print( "[NeuroNaval] c_neuronavalglobal.lua loaded!" )