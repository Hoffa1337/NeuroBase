  
-- include( 'HangarPanel.lua' )
        
-- DrawHangar()


local lasttick = CurTime()
local dist = 0
local CrosshairMaterial3 = Material("TankCrosshair2")
local CrosshairMaterial2 = Material("m1a2crosshair")
local CrosshairMaterial4 = Material("RussianCrosshair")
local Scope = Material("TankBin")
local TowerText = Material("IndicatorTower")
local BodyText = Material("IndicatorBody")
local OldBdTxt = Material("IndOldBody")
local OldTwrTxt = Material("IndOldTower")
surface.CreateFont( "ScoreboardText", {
 font = "Impact",
 size = 24,
 weight = 500,
 blursize = 0,
 scanlines = 0,
 antialias = true,
 underline = false,
 italic = false,
 strikeout = false,
 symbol = false,
 rotary = false,
 shadow = false,
 additive = false,
 outline = false
} )

killicon.Add( "sent_basetank_p", "TankKillIcon",Color( 255,255,255, 255 ) )
killicon.Add( "sent_m4sherman_p", "TankKillIcon",Color( 255,255,255, 255 ) )
killicon.Add( "sent_E100_p", "TankKillIcon",Color( 255,255,255, 255 ) )
killicon.Add( "sent_tiger_p", "TankKillIcon",Color( 255,255,255, 255 ) )
killicon.Add( "sent_m1a2_p", "TankKillIcon",Color( 255,255,255, 255 ) )
killicon.Add( "sent_tank_shell", "TankKillIcon",Color( 255,255,255, 255 ) )
killicon.Add( "sent_tank_apshell", "TankKillIcon",Color( 255,255,255, 255 ) )
killicon.Add( "sent_f18batchatillon_p", "TankKillIcon",Color( 255,255,255, 255 ) )
killicon.Add( "sent_arl44_p", "TankKillIcon",Color( 255,255,255, 255 ) )
killicon.Add( "sent_luchs_p", "TankKillIcon",Color( 255,255,255, 255 ) )
killicon.Add( "sent_leichtraktor_p", "TankKillIcon",Color( 255,255,255, 255 ) )
killicon.Add( "sent_is7_p", "TankKillIcon",Color( 255,255,255, 255 ) )
killicon.Add( "sent_pershing_p", "TankKillIcon",Color( 255,255,255, 255 ) )
killicon.Add( "sent_matilda_p", "TankKillIcon",Color( 255,255,255, 255 ) )
killicon.Add( "sent_t72_p", "TankKillIcon",Color( 255,255,255, 255 ) )
killicon.Add( "sent_wolverine_p", "TankKillIcon",Color( 255,255,255, 255 ) )
killicon.Add( "sent_T28_p", "TankKillIcon",Color( 255,255,255, 255 ) )
killicon.Add( "sent_T28_miniturret_p", "TankKillIcon",Color( 255,255,255, 255 ) )
killicon.Add( "sent_FCM36_p", "TankKillIcon",Color( 255,255,255, 255 ) )
killicon.Add( "sent_tiger_p", "TankKillIcon",Color( 255,255,255, 255 ) )
language.Add("sent_flying_bomb", "V-1 Flying Bomb" )
language.Add( "sent_carbomb", "I.E.D" )
language.Add( "sent_cowbomb", "I.E.D" )
language.Add( "sent_improvbomb", "I.E.D" )
language.Add( "sent_tiger_p", "Panzerkampfwagen Tiger I" )
language.Add( "sent_m1a2_p", "Abrams M1A2" )
language.Add( "sent_hellcat_p", "M18 Hellcat" )
language.Add( "sent_hellcat_wheels_p", "M18 Hellcat" )
language.Add( "sent_KV-2", "KV-2" )
language.Add( "sent_KV-1", "KV-1" )
language.Add( "sent_tank_poison_shell", "Poison Gas" )


// Global NeuroTanks stuff
local GroundUnit = {}
GroundUnit.DrawWarning = false
GroundUnit.Crosshair = nil
GroundUnit.Target = NULL
GroundUnit.Tank = NULL
GroundUnit.Pilot = NULL
GroundUnit.Tower = NULL
GroundUnit.Barrel = NULL

CreateClientConVar( "tank_artilleryview", "0", true, false )
CreateClientConVar( "tank_artillery_killcam", "1", true, false )
CreateClientConVar( "tank_IR", "0", true, false )
CreateClientConVar( "tank_WoTstyle", "1", true, false )
CreateClientConVar( "tank_camdistance", "0", true, false )

local function drawIRstuff()

	DrawMaterialOverlay( "effects/combine_binocoverlay.vmt", 0.11 )	
	
	cam.Start3D( EyePos(), EyeAngles() )

	SetMaterialOverride( mat )
	
	for k,v in pairs( player.GetAll() ) do 
		
		if ( v:Alive() ) then
			
			render.SuppressEngineLighting( true )
			render.SetColorModulation( 1, 1, 1 )
			render.SetBlend( 1 )
			v:DrawModel()
			render.SuppressEngineLighting( false )
			
		end
	
	end
	
	for k,v in pairs( ents.GetAll() ) do
	
		if( v:IsNPC()  ) then
			
			render.SuppressEngineLighting(true)
			render.SetColorModulation( .7, .7, .7 )
			render.SetBlend( 1 )
			v:DrawModel()
			render.SuppressEngineLighting(false)

		end
	
		if( v:IsVehicle() && !IsValid( v:GetParent() ) ) then
			
			render.SuppressEngineLighting(true)
			render.SetColorModulation( .15, .15, .15 )
			render.SetBlend( 1 )
			v:DrawModel()
			render.SuppressEngineLighting(false)
			
		end
		
	end
	
	SetMaterialOverride( nil )
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
	DrawSharpen( 0.5 + 2 / ( 1 + math.exp( math.sin( CurTime() * 1000 ) ) ) / 3, 1 )
	
end
function inLOS( a, b )

	if( !a:IsValid() || !b:IsValid() ) then
		
		return false
	
	end
	
	if( a:GetPos():Distance( b:GetPos() ) > 10000 ) then return false end
	
	local trace = util.TraceLine( { start = a:GetPos() + a:GetForward() * 1024, endpos = b:GetPos() + Vector(0,0,32), filter = a, mask = MASK_BLOCKLOS + MASK_WATER } )
	return ( ( trace.Hit && trace.Entity == b ) || !trace.Hit )
	
end


function DrawTankCrosshair()

	// Draw crosshair
	local sizex,sizey = 75, 40
	local x,y = ScrW()/2, ScrH()/2	
	
	surface.SetDrawColor( 255, 255, 255, 220 )
	
	// Square surrounding the reticule
	surface.DrawOutlinedRect( x - sizex / 2, y - sizey / 2, sizex, sizey )
	
	// Crosshair lines
	surface.DrawLine( x - sizex, y, x - sizex/2, y )
	surface.DrawLine( x + sizex, y, x + sizex/2, y )
	surface.DrawLine( x, y - sizey/2, x, y - sizey )
	surface.DrawLine( x, y + sizey/2, x, y + sizey )
	
	surface.SetDrawColor( 125, 125, 125, 140 )

end

function DrawGunHitpointCrosshair( gun )
	
	local lasttick = CurTime()

	local pos = gun:GetPos() 
	local tr, trace = {}, {}
	tr.start = pos + gun:GetForward() * 1024
	tr.endpos = tr.start + gun:GetForward() * 25000
	tr.filter = gun
	-- tr.mask = MASK_WORLD
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
		-- surface.DrawCircle( spos.x, spos.y, 16, Color( 255, 0, 0, 220) )
		surface.DrawLine( spos.x - sizex, spos.y, spos.x - sizex/2, spos.y )
		surface.DrawLine( spos.x + sizex, spos.y, spos.x + sizex/2, spos.y )
		surface.DrawLine( spos.x, spos.y - sizey/2, spos.x, spos.y - sizey )
		surface.DrawLine( spos.x, spos.y + sizey/2, spos.x, spos.y + sizey )
		
	end

end

function DrawCenteredcrossair(barrel)
	 
	 -- print( barrel:GetModel() )
	local ply = LocalPlayer()
	local tank = ply:GetScriptedVehicle()
	-- print( tank:GetClass() )
	local MaxRange = tank.MaxRange or 25000
	-- local startpos,color = Vector( ScrW()/2, ScrH()/2, 0), Color( 200,200,200,255)
	-- local tr, trace = {},{} -- = self.Pilot:GetEyeTrace()
	local tr, trace = {},{}
	trace.start = barrel:GetPos() + barrel:GetForward() * tank.BarrelLength
	trace.endpos = ply:GetAimVector() * 2500000
	trace.filter = { ply, tank, barrel }
	trace.mask = MASK_WORLD
	tr = util.TraceLine( trace )
	

	-- local outofbounds = ( tpos.x > w || tpos.x < w|| tpos.y > h || tpos.y < h )
	
	-- local p1,p2 = trace.start:ToScreen(), tr.HitPos:ToScreen()
	-- surface.SetDrawColor( 255, 255, 255, 220 )
	-- surface.DrawLine( p1.x, p1.y , p2.x, p2.y )
		
	local hpos = tr.HitPos + tr.HitNormal * 1
	
	if( GetConVarNumber("jet_cockpitview", 0 ) >= 1 && tank.ArtyView && ply.ImpactPosition ) then
		
		hpos = ply.ImpactPosition
		
		local tpos = tank:GetPos():ToScreen()
		local w,h = math.Clamp( tpos.x, 0, ScrW()-55 ), math.Clamp( tpos.y, 0, ScrH()-15 )
		surface.SetFont( "ChatFont" )
		surface.SetTextColor( Color( 0, 255, 0, 255 ) )
		surface.SetTextPos( w, h ) 
		surface.DrawText( tank.PrintName )
		surface.SetDrawColor( Color( 0,255,0,255 ) )
		surface.DrawLine( tpos.x, tpos.y , hpos:ToScreen().x, hpos:ToScreen().y )
		
	end
	
	local pos = hpos:ToScreen()
	ply.TargetPosition = pos
	local x,y = pos.x,pos.y
	local plyang = ( hpos -barrel:GetPos() ):Angle() --ply:GetAimVector():Angle()
	local bang = barrel:GetAngles()
	local theta = barrel:GetNetworkedInt("BarrelTheta", 0 )
	local thetadiff = math.AngleDifference( bang.p, theta )
	local MaxRange = tank.MaxRange or 17000
	local dist = math.floor(( tank:GetPos() - hpos ):Length())
	local text = tostring(dist)
	local Col2 = Color( 0, 255, 0, 255 ) 

	if( dist >= MaxRange && !tank.IsScudLauncher ) then
		
		text = "ERR"
		Col2 = Color( 255, 0, 0, 255 )
		
	end
	
	if( !ply.Adiff || !ply.Bdiff ) then 
		ply.Adiff = 1 
		ply.Bdiff = 1 
	end
	ply.Adiff = math.Clamp( Lerp( 0.1, ply.Adiff, math.abs(math.AngleDifference( plyang.y, bang.y ) ) ), 0, 100 )
	ply.Bdiff = math.Clamp( Lerp( 0.1, ply.Bdiff, thetadiff ), 0, 100 )
	-- print( thetadiff )
	local Col = Color( 255, 25,25, 255 ) 
	
	if( ply.Adiff < .51 && thetadiff < .01 ) then 
		
		Col = Color( 0, 255, 0, 255 ) 
		
		if( IsValid( tr.Entity ) ) then
			
			text = "FIRE"
			Col2 = Color( 200+(math.sin(CurTime())*50), 22, 22, 255 )
		
		end
		
	end

	
		
	surface.SetFont( "ChatFont" )
	surface.SetTextColor( Col2 )
	surface.SetTextPos( x+15, y ) 
	surface.DrawText( text )
	
	surface.DrawCircle( x, y, ply.Adiff+ply.Bdiff, Col )
	surface.DrawCircle( x, y, 8, Col )
	surface.DrawCircle( x, y, 16, Col )
	

end

local function VecAngD(a,b)

	local r = a - b

	if ( r < -180 ) then
	
		r = r + 360
		
	end
	
	if ( r > 180 ) then
	
		r = r - 360
		
	end
	
	return r

end

local function DrawOldTowerIndicator()

	local barrel = LocalPlayer():GetNetworkedEntity("Barrel", NULL)
	local body = LocalPlayer():GetScriptedVehicle()
	local diff = VecAngD(barrel:GetAngles().y, body:GetAngles().y)
	local Size = ScreenScale(65)

	surface.SetDrawColor( 255, 255, 255, 50 )

	
	surface.SetMaterial( OldBdTxt )
	surface.DrawTexturedRectRotated( ScrW()/20 + Size/2, ScrH() / 1.35 + Size/2, Size, Size, -diff  )
	surface.SetMaterial( OldTwrTxt )
	surface.DrawTexturedRect( ScrW()/20, ScrH() / 1.35, Size, Size )
	
end

local function DrawBodyTowerIndicator( Russian )
	
	local barrel = LocalPlayer():GetNetworkedEntity("Barrel", NULL)
	local body = LocalPlayer():GetScriptedVehicle()
	local diff = VecAngD( body:GetAngles().y, barrel:GetAngles().y )
	local Size = ScreenScale(65)
	-- if gmod 13 then
	-- surface.SetDrawColor( col.r, col.g, col.b, 150 + math.Rand( -20,20 ) + math.tan(FrameTime()) )
	if( Russian ) then
	
		surface.SetDrawColor( 255, 0, 0, 200 + math.Rand( -20,20 ) + math.tan(FrameTime()) )
	
	else
	
		surface.SetDrawColor( 255, 255, 255, 170 + math.Rand( -20,20 ) + math.tan(FrameTime()) )
	
	end
	
	surface.SetMaterial( BodyText )
	-- if( Russian ) then
	
		-- surface.DrawTexturedRect( ScrW()/9, ScrH() / 1.05, Size, Size )
	
	-- else
	
		surface.DrawTexturedRect( ScrW()/9, ScrH() / 1.35, Size, Size )
		
	-- end
	surface.SetMaterial( TowerText )
	surface.DrawTexturedRectRotated( ScrW()/9 + Size/2, ScrH() / 1.35 + Size/2, Size, Size, -diff  )

end

function DrawRussianCrosshair( gun )

	local pos = gun:GetPos() 
	local tr, trace = {}, {}
	tr.start = pos + gun:GetForward() * 200
	tr.endpos = tr.start + gun:GetForward() * 49000 + gun:GetUp() * -300
	tr.filter = {gun, LocalPlayer() }
	trace = util.TraceLine( tr )

	if( trace.Hit ) then
					
	
		local spos = trace.HitPos:ToScreen()
		local size = ScrH() / 5.5
	
		if( GetConVarNumber( "jet_cockpitview" ) > 0 ) then
		
			DrawMaterialOverlay( "effects/combine_binocoverlay.vmt", 0.11 )	
			DrawBodyTowerIndicator( true )
			
			if( LocalPlayer():KeyDown( IN_WALK ) ) then
			
				size = ScrH() / 1.85
			
			else
				
				size = ScrH() / 3
			
			end

		end
		
		
		local ofs = size/2
		
	
		surface.SetDrawColor( 255, 50, 50, 120 + math.Rand( -20,20 ) + math.tan(FrameTime()) )
		surface.SetMaterial( CrosshairMaterial4 )
		surface.DrawTexturedRect( spos.x - ofs, spos.y -ofs + 34, size, size )

	
	end
		
end

function DrawAbramsCrosshair( gun )

	local pos = gun:GetPos() + gun:GetForward() * 200
	local tr, trace = {}, {}
	tr.start = pos
	tr.endpos = tr.start + gun:GetForward() * 49000
	tr.filter = {gun, LocalPlayer() }
	trace = util.TraceLine( tr )

	if( trace.Hit ) then
					
	
		local spos = trace.HitPos:ToScreen()
		local size = ScrH() / 5.5
	
		if( GetConVarNumber( "jet_cockpitview" ) > 0 ) then
			
			-- if( GetConVarNumber("tank_wotstyle",0) == 0 && LocalPlayer():GetScriptedVehicle().ArtyView == nil ) then
			
				DrawMaterialOverlay( "effects/combine_binocoverlay.vmt", 0.11 )	
				
			-- end
			
			DrawBodyTowerIndicator( false )
			
			if( LocalPlayer():KeyDown( IN_WALK ) ) then
			
				size = ScrH() / 1.85
			
			else
				
				size = ScrH() / 3
			
			end

		end
		
		
		local ofs = size/2
		
	
		surface.SetDrawColor( 255, 255, 255, 120 + math.Rand( -20,20 ) + math.tan(FrameTime()) )
		surface.SetMaterial( CrosshairMaterial2 )
		surface.DrawTexturedRect( spos.x - ofs, spos.y -ofs, size, size )

	
	end
		
end


local crosshairlerpvalue = 0

function DrawTankHitpointCrosshair( gun )

	local pos = gun:GetPos() + gun:GetForward() * 200
	local tr, trace = {}, {}
	tr.start = pos
	tr.endpos = tr.start + gun:GetForward() * 49000
	tr.mask = MASK_WORLD
	tr.filter = { gun, LocalPlayer(), LocalPlayer():GetScriptedVehicle() }
	trace = util.TraceLine( tr )
	
	if( lasttick + 0.25 <= CurTime() ) then
		
		dist = math.floor( gun:GetPos():Distance( trace.HitPos ) )
		lasttick = CurTime()
		
	end
		
	if( trace.Hit ) then
					
		if( GetConVarNumber( "jet_cockpitview" ) > 0 && !LocalPlayer():GetScriptedVehicle().ArtyView ) then

			surface.SetDrawColor( 255, 255, 255, 255 )
			surface.SetMaterial( Scope )
			surface.DrawTexturedRect( 0, -ScrW() / 4.5, ScrW(), ScrW() )
						
			DrawOldTowerIndicator()
			
			-- surface.DrawTexturedRectRotated( 0 + ScrW(), 0 + ScrH()/4, ScrH()/2, ScrH()/2, -90 )
			-- surface.DrawTexturedRectRotated( 0 + ScrW(), 0 + ScrH()/4, ScrH()/2, ScrH()/2, 90 )
			-- surface.DrawTexturedRectRotated( 0 + ScrW()/4, 0 + ScrH()/4, ScrH()/2, ScrH()/2, 0 )
			-- surface.DrawTexturedRectRotated( 0 + ScrH()/8, 0 + ScrH()/4, ScrH()/2, ScrH()/2, 90 )
			
			local spos = trace.HitPos:ToScreen()
			local size = ScrH() / 3.5
			if( LocalPlayer():KeyDown( IN_WALK ) ) then
				
				size = ScrH() / 1.5
			
			end
			
			local ofs = size/2
			
			surface.SetDrawColor( 0, 0, 0, 175 )	
			surface.SetMaterial( CrosshairMaterial3 )
			surface.DrawTexturedRect( spos.x - ofs, spos.y -ofs, size, size )

			
		else

			-- local sizex,sizey = 55, 30
			local spos = trace.HitPos:ToScreen()
			surface.SetDrawColor( 0, 0, 0, 105 )	
			-- crosshairlerpvalue = Lerp(  0.1, crosshairlerpvalue, math.Clamp( math.floor( gun:GetVelocity():Length() ), 0, 50 ) )
			local scale = 0.5
			
			draw.SimpleText( math.floor(dist*0.01905).."m", "TargetID", spos.x+40, spos.y-20, Color(0,255,0,255), TEXT_ALIGN_LEFT )
			 
			surface.DrawCircle( spos.x, spos.y, 2*scale, Color( 0, 175, 0, 145 ) ) -- big circle
			surface.DrawCircle( spos.x, spos.y+32, 2*scale, Color( 0, 175, 0, 45 ) ) -- big circle
			surface.DrawCircle( spos.x, spos.y+48, 2*scale, Color( 0, 175, 0, 45 ) ) -- big circle
			surface.DrawCircle( spos.x, spos.y+64, 2*scale, Color( 0, 175, 0, 45 ) ) -- big circle
			surface.DrawCircle( spos.x, spos.y+80, 2*scale, Color( 0, 175, 0, 45 ) ) -- big circle
			surface.DrawCircle( spos.x, spos.y+96, 2*scale, Color( 0, 175, 0, 45 ) ) -- big circle
			surface.DrawCircle( spos.x, spos.y, 16*scale, Color( 0, 175, 0, 30 ) ) -- small circle
			surface.DrawCircle( spos.x, spos.y, 32*scale, Color( 0, 175, 0, 75 ) ) --horizon circle
			surface.SetDrawColor( 0, 175, 0, 120 )
			surface.DrawLine( spos.x + 32, spos.y, spos.x + 64, spos.y )
			surface.DrawLine( spos.x - 32, spos.y, spos.x - 64, spos.y )
			surface.DrawLine( spos.x, spos.y - 32, spos.x, spos.y - 64 )

		end
		
	end
		
end

function DrawArtilleryCrosshair( barrel )
	
	if GroundUnit.Pilot:IsValid() then
		local viewent = GroundUnit.Tank
		local gun = GroundUnit.Pilot:GetNetworkedEntity("Barrel", NULL )
		local pos = viewent:GetPos()
		local tr, trace = {}, {}
		-- tr.start = pos
		tr.start = GroundUnit.Pilot:EyePos()
		-- tr.endpos = tr.start + viewent:GetForward() * 49000
		tr.endpos = GroundUnit.Pilot:GetShootPos()
		-- tr.mask = MASK_NPCWORLDSTATIC
		tr.mask = MASK_SOLID_BRUSHONLY 
		tr.filter = { GroundUnit.Tank,viewent,gun, LocalPlayer(), LocalPlayer():GetScriptedVehicle() }
		trace = util.TraceLine( tr )
		if( lasttick + 0.25 <= CurTime() ) then			
			dist = math.floor( viewent:GetPos():Distance( trace.HitPos ) )
			lasttick = CurTime()			
		end
		
		
		local spos = trace.HitPos:ToScreen()
		surface.SetDrawColor( 255, 255, 255, 105 )	
		draw.SimpleText( math.floor(-gun:GetAngles().p).."°", "ScoreboardText", spos.x-30, spos.y-10, Color(0,0,0,255), TEXT_ALIGN_RIGHT )
			surface.DrawLine( spos.x + 32, spos.y, spos.x + 64, spos.y )
			surface.DrawLine( spos.x - 32, spos.y, spos.x - 64, spos.y )
			surface.DrawLine( spos.x, spos.y + 32, spos.x, spos.y + 64 )
			surface.DrawLine( spos.x, spos.y - 32, spos.x, spos.y - 64 )
		
		if( trace.Hit ) then
			GroundUnit.Pilot:SetNetworkedVector( "TargetPos", trace.HitPos )
			draw.SimpleText( math.floor(dist*0.01905).."m", "ScoreboardText", spos.x+30, spos.y-10, Color(0,0,0,255), TEXT_ALIGN_LEFT )
		else
			GroundUnit.Pilot:SetNetworkedVector( "TargetPos", nil )
			draw.SimpleText( "><", "ScoreboardText", spos.x+30, spos.y-10, Color(0,0,0,255), TEXT_ALIGN_LEFT )
		end

		
	end
end

function DrawLarsCrosshair( barrel )

if !GroundUnit.Pilot:IsValid() then
	return
end
	
	if( !GroundUnit.Tower || !IsValid( GroundUnit.Tower ) ) then return end
	if( !GroundUnit.Barrel || !IsValid( GroundUnit.Barrel ) ) then return end 
	local tr, trace = {}, {}
	tr.start = GroundUnit.Tower:GetPos()
	tr.endpos = GroundUnit.Tower:GetPos() + GroundUnit.Tower:GetForward() * range
	// tr.mask = MASK_NPCWORLDSTATIC
	-- tr.mask = MASK_SOLID_BRUSHONLY 
	tr.mask = MASK_ALL
	tr.filter = { GroundUnit.Tank,GroundUnit.Tower,barrel, LocalPlayer(), LocalPlayer():GetScriptedVehicle() }
	trace = util.TraceLine( tr )

	if GroundUnit.Pilot:IsValid() then
		local minrange = GroundUnit.Tank:GetNetworkedInt("MinRange", 2500)
		local maxrange = GroundUnit.Tank:GetNetworkedInt("MaxRange", 12000)
		local accuracy = GroundUnit.Tank:GetNetworkedInt("ArtilleryAccuracy", 5)
		local range = GroundUnit.Tank:GetNetworkedInt("Range", minrange)
		local pitch = GroundUnit.Barrel:GetAngles().p 
		local towerpitch = GroundUnit.Tower:GetAngles().p
		local tpos = GroundUnit.Tower:GetPos()
		local p = math.rad(pitch-towerpitch)
		local rangerate = math.floor(range)/maxrange
		
		local tr,tr2,tr3, trace,trace2,trace3 = {}, {}, {}, {}, {}, {}
		tr.start = tpos
		tr2.start = tpos
		tr3.start = tpos
		tr.endpos = tpos + GroundUnit.Tower:GetForward() * range
		tr2.endpos = tpos + GroundUnit.Tower:GetForward() * minrange
		tr3.endpos = tpos + GroundUnit.Tower:GetForward() * maxrange
		// tr.mask = MASK_NPCWORLDSTATIC
		-- tr.mask = MASK_SOLID_BRUSHONLY 
		tr.mask = MASK_ALL
		tr2.mask = MASK_ALL
		tr3.mask = MASK_ALL
		tr.filter = { GroundUnit.Tank,GroundUnit.Tower,barrel, LocalPlayer(), LocalPlayer():GetScriptedVehicle() }
		trace = util.TraceLine( tr )
		trace2 = util.TraceLine( tr2 )
		trace3 = util.TraceLine( tr3 )
		
		local downtr,downtr2,downtr3, downtrace,downtrace2,downtrace3 = {}, {}, {}, {}, {}, {}
		downtr.start = tr.endpos + Vector(0,0,64)
		downtr2.start = tr2.endpos + Vector(0,0,64)
		downtr3.start = tr3.endpos + Vector(0,0,64)
		downtr.endpos = tr.endpos + Vector(0,0,-10240)
		downtr2.endpos = tr2.endpos + Vector(0,0,-10240)
		downtr3.endpos = tr3.endpos + Vector(0,0,-10240)
		downtrace = util.TraceLine( downtr )
		downtrace2 = util.TraceLine( downtr2 )
		downtrace3 = util.TraceLine( downtr3 )

		local spos = downtrace.HitPos:ToScreen()
		local spos2 = downtrace2.HitPos:ToScreen()
		local spos3 = downtrace3.HitPos:ToScreen()
	//Crosshair
		surface.SetDrawColor( 255, 255, 255, 105 )	
		draw.SimpleText( math.floor(-pitch).."deg", "ScoreboardText", spos.x-30, spos.y-10, Color(0,0,0,255), TEXT_ALIGN_RIGHT )		
		draw.SimpleText( math.floor(range/16).."ft", "ScoreboardText", spos.x+30, spos.y-10, Color(0,0,0,255), TEXT_ALIGN_LEFT )
		surface.SetDrawColor( 255, 0, 0, 105 )	
		surface.DrawCircle( spos.x, spos.y, 16*(1-rangerate)+10/accuracy, Color( 255, 0, 0, 200) )
		surface.DrawLine( spos.x-16*(1-rangerate)-10/accuracy, spos.y, spos.x+16*(1-rangerate)+10/accuracy, spos.y )
		surface.DrawLine( spos.x, spos.y-4*(1-rangerate)-10/accuracy, spos.x, spos.y+4*(1-rangerate)+10/accuracy)
	
		surface.SetDrawColor( 0, 255, 0, 105 )	
		surface.DrawLine( spos2.x-8, spos2.y, spos3.x, spos3.y )
		surface.DrawLine( spos2.x+8, spos2.y, spos3.x, spos3.y )
		surface.DrawLine( spos2.x-7, spos2.y, spos3.x, spos3.y )
		surface.DrawLine( spos2.x+7, spos2.y, spos3.x, spos3.y )		
		surface.DrawLine( spos2.x-8, spos2.y, spos2.x+8, spos2.y )
/*
		if( trace.Hit ) then
			GroundUnit.Pilot:SetNetworkedVector( "TargetPos", trace.HitPos )
			-- draw.SimpleText( math.floor(dist*0.01905).."m", "ScoreboardText", spos.x+30, spos.y-10, Color(0,0,0,255), TEXT_ALIGN_LEFT )
		else
			GroundUnit.Pilot:SetNetworkedVector( "TargetPos", nil )
			draw.SimpleText( "Out of Range", "ScoreboardText", spos.x+30, spos.y-10, Color(0,0,0,255), TEXT_ALIGN_LEFT )
		end
*/
	//Corner info:
		surface.SetDrawColor( 150, 150, 150, 105 )	
		surface.DrawOutlinedRect(50, 100, 102, 5 )
		surface.SetDrawColor( 255, 255, 255, 105 )	
		draw.SimpleText( math.floor(range*0.01905 ).."m", "ScoreboardText", 51, 112, Color(255,255,255,255), TEXT_ALIGN_RIGHT )
		draw.SimpleText( math.floor(-pitch ).." degrees", "ScoreboardText", 150, 112, Color(255,255,255,255), TEXT_ALIGN_RIGHT )
		for i=0,2 do
		surface.DrawLine( 51, 101+i, 51+100*math.cos(p), 101+i+100*math.sin(p) )
		end
	end
	
end

if( table.HasValue( hook.GetTable(), "NeuroTanks_DrawHP" ) ) then
	
	hook.Remove( "HUDPaint", "NeuroTanks_DrawHP" )
	
end



function DrawShells()

	local plr = LocalPlayer()
	local Tank = plr:GetScriptedVehicle("Tank", NULL )
    local ActiveShell = Tank:GetNetworkedString("NeuroTanks_ActiveWeaponShell", "" )
	-- print( ActiveShell )
    local texture
    local BoxSize = 64
	local Offset = BoxSize / 2
    local Shells = { 
					 { "sent_tank_apshell"			 , surface.GetTextureID("vgui/shells/ARMOR_PIERCING_CR") };
					 { "sent_tank_kinetic_shell"		 , surface.GetTextureID("vgui/shells/ARMOR_PIERCING_CR") };
					 {"sent_tank_shell"				 , surface.GetTextureID("vgui/shells/HIGH_EXPLOSIVE") };
					 {"sent_tank_autocannon_shell"	 , surface.GetTextureID("vgui/shells/HIGH_EXPLOSIVE") };
					 {"sent_tank_flak"				 , surface.GetTextureID("vgui/shells/HIGH_EXPLOSIVE_PREMIUM") };
					 {"sent_tank_incendiary"		 , surface.GetTextureID("vgui/shells/HIGH_EXPLOSIVE_PREMIUM") };
					 {"sent_tank_missile"			 , surface.GetTextureID("vgui/shells/HIGH_EXPLOSIVE_PREMIUM") };
					 {"sent_a2s_nuclear_bomb"		 , surface.GetTextureID("vgui/shells/HIGH_EXPLOSIVE_PREMIUM") };
					 {"sent_tank_poison_shell"		 , surface.GetTextureID("vgui/shells/HIGH_EXPLOSIVE_PREMIUM") };
					 {"sent_artillery_shell"		 , surface.GetTextureID("vgui/shells/HIGH_EXPLOSIVE_PREMIUM") };
					 {"sent_tank_clustershell" 		 , surface.GetTextureID("vgui/shells/HOLLOW_CHARGE") };
					 {"sent_tank_38cm_rocket" 		 , surface.GetTextureID("vgui/shells/HIGH_EXPLOSIVE_PREMIUM") };
					 {"sent_tank_300mm_rocket" 		 , surface.GetTextureID("vgui/shells/HIGH_EXPLOSIVE_PREMIUM") };
					 {"sent_tank_armorpiercing"		 ,  surface.GetTextureID("vgui/shells/ARMOR_PIERCING_HE") };
					 {"sent_tank_mgbullet"		 ,  surface.GetTextureID("vgui/shells/HIGH_EXPLOSIVE_PREMIUM") };
					}

	for k,v in pairs( Shells ) do
		
		if( ActiveShell == v[1] ) then
			
			-- print("true")
			texture = v[2] 
			
			break 
			
		end
		
	end
	
	local ATGMAmmo = Tank:GetNetworkedInt("ATGMAmmoCount", 0 )
	
	if( ATGMAmmo > 0 ) then
		
		draw.SimpleTextOutlined( "ATGMs Remaining: "..ATGMAmmo, "NeuroTankATGM", ScrW()/1.5, 15, Color( 0, 0, 0, 255 ), TEXT_ALIGN_LEFT, TEXT_ALIGN_LEFT, 1, Color(255,255,255,55) )
	
	end
	
	local OilIcon = surface.GetTextureID( "TankHUD/dash_lowoil")
	local WaterIcon = surface.GetTextureID( "TankHUD/dash_tempwarn")
	local CE = surface.GetTextureID( "TankHUD/dash_powertrain")
	local Oil = Tank:GetNWFloat( "EngineOilLevel", 0 )
	local Gearbox = Tank:GetNetworkedInt( "EngineGearBoxHealth", 0 )
	local Temp = Tank:GetNetworkedInt("EngineHeat", 0 )
	-- local OilIcon = Material( "TankHUD/dash_lowoil")
	-- local WaterIcon = Material( "TankHUD/dash_tempwarn")
	-- local CE = Material( "TankHUD/dash_engine")

	local sh = 1.07
	local sw = 14
	local bs2 = 32
	

	if( Oil >= 25 ) then
		
		surface.SetDrawColor( 0,255,0,255)
	
	-- elseif( Oil <= 50 ) then
	
		-- surface.SetDrawColor( 224, 152, 27, 199 + (math.sin(CurTime())*55) )
	
	elseif( Oil <= 25 ) then
	
		surface.SetDrawColor( 255, 0, 0, 255 )
		
	end

	surface.SetTexture(OilIcon)
	surface.DrawTexturedRect( ( ScrW() / sw ) - Offset, ( ScrH() / sh ) - Offset, bs2, bs2 );
	
	if( Temp >= 105 ) then
		
		surface.SetDrawColor(255,0,0,255)
	
	else
		
		surface.SetDrawColor( 0, 255, 0, 255 )
		
	end
	surface.SetTexture(WaterIcon)
	surface.DrawTexturedRect( ( ScrW() / sw ) - Offset+32, ( ScrH() / sh ) - Offset, bs2, bs2 );
	
	if( Gearbox >= 100 ) then
		
		surface.SetDrawColor( 0,255,0,255 )
	
	-- elseif( Gearbox <= 50 ) then
		
		-- surface.SetDrawColor( 224, 152, 27, 255 )
	
	elseif( Gearbox <= 50 ) then
		
		surface.SetDrawColor( 255, 0, 0, 255 )
		
	end
	surface.SetTexture(CE)
	surface.DrawTexturedRect( ( ScrW() / sw ) - Offset+64, ( ScrH() / sh ) - Offset, bs2, bs2 );
	
	-- draw.RoundedBox( 4, ( ScrW() / sw ) - Offset, ( ScrH() / sh ) - Offset, bs2, bs2, Color( 45, 45, 45, 255 )  )
	-- draw.RoundedBox( 4, ( ScrW() / sw ) + Offset+15, ( ScrH() / sh ) - Offset, bs2, bs2, Color( 45, 45, 45, 255 )  )
	-- draw.RoundedBox( 4, ( ScrW() / sw ) + 2*(Offset+30), ( ScrH() / sh ) - Offset, bs2, bs2, Color( 45, 45, 45, 255 )  )
	
    if( texture ) then
		
		local MaxAmmo = Tank:GetNetworkedInt("NeuroTanks_AmmoCount", 0 )
		-- print( string.len( MaxAmmo ) )

		draw.SimpleTextOutlined( "x "..MaxAmmo, "NeuroTankHealth", ScrW()/2 + BoxSize/1.15, ScrH()/1.122, Color( 0, 0, 0, 255 ), TEXT_ALIGN_LEFT, TEXT_ALIGN_LEFT, 1, Color(255,255,255,55) )
		draw.RoundedBox( 4, ( ScrW() / 2.011 ) - Offset, ( ScrH() / 1.085 ) - Offset, BoxSize + 8, BoxSize + 8, Color( 45, 45, 45, 185 )  )
		draw.RoundedBox( 4, ( ScrW() / 2 ) - Offset, ( ScrH() / 1.08 ) - Offset, BoxSize, BoxSize, Color(0,80,0,125)  )
		

		surface.SetTexture(texture)
		surface.SetDrawColor(255,255,255,255)
		surface.DrawTexturedRect( ( ScrW() / 2 ) - Offset, ( ScrH() / 1.075 ) - Offset, BoxSize, BoxSize );
		
	
	end
	
end


-- surface.CreateFont( "coolvetica", ScreenScale(16), 500, true, false, "NeuroTankName" )
-- surface.CreateFont( "coolvetica", ScreenScale(28), 500, true, false, "NeuroTankHealth" )
-- surface.CreateFont( "coolvetica", ScreenScale(12), 400, true, false, "NeuroTankSauce" )
-- surface.CreateFont( "coolvetica", ScreenScale(14), 400, true, false, "NeuroTankATGM" )

surface.CreateFont( "NeuroTankATGM", {
 font = "coolvetica",
 size = 32,
 weight = 400,
 blursize = 0,
 scanlines = 0,
 antialias = true,
 underline = false,
 italic = false,
 strikeout = false,
 symbol = false,
 rotary = false,
 shadow = false,
 additive = false,
 outline = false
} )

surface.CreateFont( "NeuroTankSauce", {
 font = "Impact",
 size = 16,
 weight = 400,
 blursize = 0,
 scanlines = 0,
 antialias = true,
 underline = false,
 italic = false,
 strikeout = false,
 symbol = false,
 rotary = false,
 shadow = false,
 additive = false,
 outline = true
} )

surface.CreateFont( "NeuroTankHealth", {
 font = "Impact",
 size = 32,
 weight = 500,
 blursize = 0,
 scanlines = 0,
 antialias = true,
 underline = false,
 italic = false,
 strikeout = false,
 symbol = false,
 rotary = false,
 shadow = false,
 additive = false,
 outline = false
} )

surface.CreateFont( "NeuroTankSpeedo", {
 font = "Impact",
 size = 22,
 weight = 500,
 blursize = 0,
 scanlines = 0,
 antialias = true,
 underline = false,
 italic = true,
 strikeout = false,
 symbol = false,
 rotary = false,
 shadow = false,
 additive = false,
 outline = false
} )

surface.CreateFont( "NeuroTankName", {
 font = "coolvetica",
 size = 28,
 weight = 500,
 blursize = 0,
 scanlines = 0,
 antialias = true,
 underline = false,
 italic = false,
 strikeout = false,
 symbol = false,
 rotary = false,
 shadow = false,
 additive = false,
 outline = true
} )

local ammo = 0
local fuel
local s
local scope = Material( "gmod/scope.vmt")

local sin,cos,rad = math.sin,math.cos,math.rad; --Only needed when you constantly calculate a new polygon, it slightly increases the speed.
function GeneratePoly(x,y,radius,quality)
    local circle = {};
    local tmp = 0;
    for i=1,quality do
        tmp = rad(i*360)/quality
        circle[i] = {x = x + cos(tmp)*radius,y = y + sin(tmp)*radius};
    end
    return circle;
end

local xs,ys = ScrW() / 16,ScrH()/1.1

local xC, yC = (xs+280), ys

local circleOut = GeneratePoly(xC, yC, 80, 100)
local circle = GeneratePoly(xC, yC, 70, 100)
local circleCenter = GeneratePoly(xC, yC, 10, 100)
local circleCenter2 = GeneratePoly(xC, yC, 6, 100)

function RotateAround(origX, origY, centerX, centerY, degTurn)

	local ang = math.rad(degTurn)
	local x1 = origX
	local y1 = origY
	
	local x2 = x1 * cos(ang) - y1 * sin(ang)
	local y2 = x1 * sin(ang) + y1 * cos(ang)
	
	local x3 = x2 + centerX
	local y3 = y2 + centerY
	
	return x3, y3

end

local frac = 0
--[[
hook.Add("HUDPaint", "NeuroTanks_DrawSpeed", function() 
	
	local tank = LocalPlayer():GetScriptedVehicle( )
	
	if( LocalPlayer():GetNetworkedEntity("Plane", NULL ) == tank  )  then return end
	
	if( tank && tank.NoSpeedo ) then return end
	
	if( tank:IsValid() ) then
	
		local speedMPH = tank:GetNetworkedInt( "SpeedMPH", 0 )
		local maxVelocity = tank:GetNetworkedInt( "MaxSpeed", 0 )
		local speedKPH = math.ceil(speedMPH * 1.609344)
		
		local maxSpeedKPH = maxVelocity
		local maxSpeedMPH = maxSpeedKPH / 1.609344
		
		local x,y = ScrW() / 16,ScrH()/1.1
		
		-- local frac = speedMPH / maxSpeedMPH
		frac = Lerp( 0.075, frac, math.Clamp( speedMPH, 0, maxSpeedMPH ) / maxSpeedMPH )
		
		if( frac < 0.05 ) then frac = 0.05 end
		
		-- draw.RoundedBox( 4, x+201, y - 21, 72*frac, 70, Color(255*(1-frac),255*frac,0,250))
		-- draw.RoundedBox( 4, x+197, y - 26, 80, 80, Color( 45, 45, 45, 225 ) )
		-- draw.SimpleTextOutlined( speedKPH .." KPH", "NeuroTankHealth", x+202.5, y + 10 , Color( 0, 0, 0, 255 ), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER, 1, Color(255,255,255,255) )
		
		-- surface.DrawPoly(GeneratePoly( x+197, y - 26, 80, 200 ))

		trianglevertex = {{ },{ },{ }} --create the two dimensional table
 
		 --Left vertex
		trianglevertex[1]["x"] = xC + 3
		trianglevertex[1]["y"] = yC + 5
		 
		 --Right vertex
		trianglevertex[2]["x"] = xC - 3
		trianglevertex[2]["y"] = yC + 5
		 
		 --Top vertex
		trianglevertex[3]["x"] = xC
		trianglevertex[3]["y"] = yC - 70
		
		local fracAngle = math.rad( ( ( ( frac - 0 ) * 300 ) / 1 ) + 210 )
		-- print(math.deg(fracAngle))
		for k,v in pairs( trianglevertex ) do
			
			local x1 = v["x"] - xC
			local y1 = v["y"] - yC
			
			local x2 = x1 * cos(fracAngle) - y1 * sin(fracAngle)
			local y2 = x1 * sin(fracAngle) + y1 * cos(fracAngle)
			
			v["x"] = x2 + xC
			v["y"] = y2 + yC
  
		end
		
		surface.SetDrawColor(Color( 45, 45, 45, 25 ))
		surface.DrawPoly(circleOut)		
		surface.SetDrawColor(Color( 0, 255, 0, 230 ))
		surface.DrawPoly(circle)
		surface.SetDrawColor(Color( 45, 45, 45, 225 ))
		surface.DrawPoly(circleOut)
	
		--
		
		local xPos, yPos = RotateAround(0, 50, xC, yC, 336)
		
		draw.SimpleText( maxSpeedKPH+1, "NeuroTankSpeedo", xPos, yPos , Color( 25, 25, 25, 255 ), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
		
		--

		xPos, yPos = RotateAround(0, 65, xC, yC, 51)
		
		draw.SimpleText( "0", "NeuroTankSpeedo", xPos, yPos , Color( 25, 25, 25, 255 ), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)

		--
		
		draw.SimpleText( math.ceil((maxSpeedKPH+1)/2), "NeuroTankSpeedo", xC-10, yC - 60 , Color( 25, 25, 25, 255 ), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
		
		--
		
		surface.SetDrawColor(Color( 255, 0, 0,225 ))
		surface.DrawPoly(trianglevertex)
		surface.SetDrawColor(Color( 0, 0, 0, 255 ))
		surface.DrawPoly(circleCenter)				
		-- surface.SetDrawColor(Color( 255, 0, 0, 255 ))
		-- surface.DrawPoly(circleCenter2)		
		
	end

end )
]]


local Crew = { }
local TankCrewData = {}

net.Receive( "NeuroTanksCrewMembers", function( len, pl )
	-- Clear crew table when we receive new one.
	Crew = {}
	TankCrewData = net.ReadTable()
	for k,v in pairs( TankCrewData["Faces"] ) do
		-- Precache materials and insert into crew table.
		table.insert( Crew, { Material( v[1] ), Material( v[2] ) } )
	
	end

end )

hook.Add("HUDPaint", "NeuroTanks_DrawHP", function() 
	
	local sveh = LocalPlayer():GetScriptedVehicle()
	local tank = LocalPlayer():GetNetworkedEntity("Tank", NULL )
	local barrel = LocalPlayer():GetNetworkedEntity("Barrel", NULL)
	local tower = LocalPlayer():GetNetworkedEntity("Tower", NULL)
	local gun = LocalPlayer():GetNetworkedEntity("Weapon", NULL)
	
	if( IsValid( tank ) && IsValid( sveh ) && sveh.TankType && sveh.CrewPositions ) then
		
		local CrewSize = 2
		-- print( sveh.CrewPositions )
		if( type( sveh.CrewPositions ) == "table" ) then
			
			CrewSize = math.Clamp( #sveh.CrewPositions, 0, 4 )
			
		end
		
		-- Generate our crew if we doesnt have one. One crew per session.

		if( GetConVarNumber( "jet_cockpitview", 0 ) == 0 ) then
		
			if( TankCrewData && #TankCrewData > 0 && CrewSize > 0 ) then
				
				
				local ply = LocalPlayer()
				local movex = 0

				local size = 40
				for i=1,CrewSize do
					if( !TankCrewData[i] ) then return end
					
					local hp = TankCrewData[i].Health or 100
					local Dead = TankCrewData[i].Dead
					
					local x,y = math.Clamp( ScrW()/2.9 + (-130+movex), 250, 800 ), ScrH()/1.141
					-- print( x, "225" )
					movex = movex + size*1.3
					surface.SetDrawColor( Color( 45, 45, 45, 155 ) )
					surface.DrawRect( x, y, size*1.25, size )
					
					surface.SetDrawColor( Color( 255,255,255,255 ) )
					surface.SetMaterial( Crew[i][2] )
					surface.DrawTexturedRect( x-10, y, size, size )
					
					if( !Dead ) then
					
						surface.SetDrawColor( Color( 255,255,255,255 ) )
					
					else
						
						surface.SetDrawColor( Color( 255,0,0,255 ) )
					
					end
					
					surface.SetMaterial( Crew[i][1] )
					surface.DrawTexturedRect( x, y, size*1.5, size )
					
					surface.SetDrawColor( Color( 0, 0, 0, 255 ) )
					surface.DrawRect( x-1, y+size-1, size+12, 10+1 )
					-- Crew Healthbar
			
					surface.SetDrawColor( Color( 0, 105+TankCrewData[i].Health, 0, 85 ) )
					surface.DrawRect( x, y+size, TankCrewData[i].Health/2, 10 )
					surface.SetTextColor( 245, 245, 245, 255 )
					surface.SetTextPos( x, y+size-3 )
					surface.SetFont( "ChatFont")
					surface.DrawText( math.floor(TankCrewData[i].Health) )
				end
				
			end
			
		end
		
	end
	local sveh = LocalPlayer():GetScriptedVehicle()
	if( barrel:IsValid() ) then
		
		-- drawIRstuff()
		if( GetConVarNumber("tank_WoTstyle") > 0 ) then
			DrawCenteredcrossair(barrel)	
			-- DrawImpactZone()
			-- DrawAccuracyCircle()
	
		else
			
			
		end
			if( gun:IsValid() ) then
				DrawGunHitpointCrosshair( gun )
			end
			
			if( sveh.VehicleCrosshairType && sveh.VehicleCrosshairType == 1 ) then
			
				DrawGunHitpointCrosshair( barrel )
			
			elseif( sveh.VehicleCrosshairType && sveh.VehicleCrosshairType == 2 ) then
				
				DrawAbramsCrosshair( barrel )
			
			
			elseif( sveh.VehicleCrosshairType && sveh.VehicleCrosshairType == 3 ) then
				
				DrawRussianCrosshair( barrel )
				
			elseif( sveh.VehicleCrosshairType && sveh.VehicleCrosshairType == 4 ) then
				
				DrawArtilleryCrosshair( barrel )
			
			elseif( sveh.VehicleCrosshairType && sveh.VehicleCrosshairType == 5 ) then
				
				-- do nothing
				
			elseif( sveh.VehicleCrosshairType && sveh.VehicleCrosshairType == 21 ) then
				
				DrawLarsCrosshair( barrel )
				
			else
			
				DrawTankHitpointCrosshair( barrel )
			
			end
		
		
	end
	
	local plr = LocalPlayer()
	local Tank = plr:GetScriptedVehicle("Tank", NULL )
	local Barrel = plr:GetNetworkedEntity("Barrel", NULL )
	local Weapon = plr:GetNetworkedEntity( "Weapon", NULL )
	local Cannon = plr:GetNetworkedEntity( "Cannon", NULL )

	if( Weapon:IsValid() && Cannon:IsValid() ) then
		
		local Tank = Weapon
		local Barrel = Cannon
		
	end
	
	if ( ( Tank:IsValid() && Barrel:IsValid() ) or ( Weapon:IsValid() && Cannon:IsValid() ) ) then
		
		
		
		
		if( GetConVarNumber("jet_cockpitview", 0 ) > 0 ) then
			-- \gui\sniper_corner.vmt
			-- DrawMaterialOverlay( "gmod/scope.vmt", 1.0 )	
			-- surface.SetTexture( scope )
			-- surface.SetDrawColor( 0,0,0, 255 )
			-- surface.SetMaterial(scope )
			-- surface.DrawTexturedRect( 0, 0, ScrW(), ScrH())
			--Effects\combine_binocoverlay.vmt \filmscan256.vmt \steadycamfrustum.vmt Engine\filmdust.vmt Glass\glasswindowbreak070b_mask.vtf
		end
		
		
		-- if( GetConVarNumber( "jet_cockpitview" ) > 0 ) then return end
		
		local x,y = ScrW() / 16,ScrH()/1.1
		local hp = math.floor( Tank:GetNetworkedInt( "health", 0 ) )
		local maxhp = math.floor( Tank:GetNetworkedInt( "MaxHealth", 0 ) )
		local h = hp / maxhp

		if( hp > 0 ) then

			if( h <= 0 )then 
				
				h = 0 
				
			end

			local ActiveWeapon = Tank:GetNetworkedString("NeuroTanks_ActiveWeapon", "" )
			local Shots = Tank:GetNetworkedInt("AutoLoaderShots", 0 )
            local MaxShots = Tank:GetNetworkedInt("AutoLoaderMax", 0 )

			if( Tank.IsAutoLoader ) then
				

				AutoLoader = "Shells loaded: "..Shots.."/"..MaxShots
                
				AutoLoaderColor = Shots < 1 && Color(80,0,0,195) or Color(0,80,0,195)
                
				if( !s ) then
					
					s = Shots/MaxShots
					
				end
				
                s = math.Approach( s, Shots/MaxShots, 0.02 )
                
                if (s <= 0) then
                
                    s = 0
                    
                end
				
                -- if Shots == 0 then
                    -- AutoLoaderColor = Color(102,0,0,195)
                -- else
                    -- AutoLoaderColor = Color(0,51,0,195)
                -- end
				
			end

			draw.RoundedBox( 4, x-25, y - 20, 215*h, 45, Color(255*(1-h),255*h,0,195))
			draw.RoundedBox( 4, x-30, y - 26, 225, 55, Color( 45, 45, 45, 225 ) )
            --draw.RoundedBox( 4, ScrW()/1.54, ScrH()/1.136, 140, 30, Color(0,51,0,195))
            if( Tank.IsAutoLoader ) then 
                
				draw.RoundedBox( 4, ScrW()/1.30, y - 21, 200*s, 45, Color(255*(1-s),255*s,0,245))
                draw.RoundedBox( 4, ScrW()/1.305, y - 26, 210, 55, Color( 45, 45, 45, 220 ))
                --draw.SimpleText( AutoLoader,   "ScoreboardText", ScrW()/1.52, ScrH()/1.11,  Color( 255, 255, 255,255 ), TEXT_ALIGN_LEFT, TEXT_ALIGN_LEFT ) 
                -- draw.SimpleTextOutlined( AutoLoader, "ScoreboardText", ScrW()/1.26, ScrH()/1.11, Color( 0, 0, 0, 255 ), TEXT_ALIGN_LEFT, TEXT_ALIGN_LEFT, 2, Color(255,255,255,255) )
                draw.SimpleText( "Shells loaded", "NeuroTankName", ScrW()/1.299, ScrH()/1.155, Color( 255, 255, 255, 255 ), TEXT_ALIGN_LEFT )
                draw.SimpleTextOutlined( Shots.."/"..MaxShots, "NeuroTankHealth", ScrW()/1.23, ScrH()/1.13, Color( 0, 0, 0, 255 ), TEXT_ALIGN_LEFT, TEXT_ALIGN_LEFT, 1, Color(255,255,255,255) )
       
			end
						
			
			
			--draw.SimpleText( ActiveWeapon,   "ScoreboardText", ScrW()/1.52, ScrH()/1.130,  Color( 255, 255, 255,255 ), TEXT_ALIGN_LEFT, TEXT_ALIGN_LEFT )
            DrawShells()
			local name = Tank.PrintName
			if( string.len( name ) > 17 ) then
				
				name = string.sub( name, 0, 17 )
				
			end
			
			draw.SimpleText( name, "NeuroTankName", ScrW()/26, ScrH()/1.155, Color( 255, 255, 255, 255 ), TEXT_ALIGN_LEFT )
			draw.SimpleTextOutlined( math.ceil( hp * 100 / maxhp ).."%", "NeuroTankHealth", ScrW()/6.9, ScrH()/1.12, Color(0,0,0,255), TEXT_ALIGN_LEFT, TEXT_ALIGN_LEFT, 1, Color(255,255,255,255))
					
		
		
			
			local maxfuel = Tank:GetNetworkedInt("TankMaxFuel", 0 )
			fuel = fuel && Tank:GetNetworkedInt( "TankFuel", 0 ) or maxfuel
			local fuelpct = fuel / maxfuel
			draw.RoundedBox( 4, x-25, y + 35, 215*fuelpct, 15, Color(255*(1-fuelpct),255*fuelpct,0,195))
			draw.RoundedBox( 4, x-30, y + 30, 225, 24, Color( 45, 45, 45, 225 ) )
			draw.SimpleText( "Fuel", "NeuroTankSauce", x-25, y + 32.5, Color( 255, 255, 255, 255 ), TEXT_ALIGN_LEFT )
			
			
		end
		
	end

end )


local Meta = FindMetaTable("Entity")


function Meta:DefaultDrawInfo()
	
	self:DrawModel()
	
	local p = LocalPlayer()
	
	local driver = self:GetNetworkedEntity("Pilot", NULL )
	local extra = ""
	local ammo = self:GetNetworkedInt("NeuroTanks_AmmoCount", 0 )
	local fuel = self:GetNetworkedInt("TankMaxFuel", 0 )
	local cfuel = self:GetNetworkedInt( "TankFuel", 0 )
	
	if( self.Description ) then
		
		extra = self.Description.."\n"
		
	end
		
	if( driver:IsValid() ) then
		
		extra = tostring(driver:Name().."\n")

	end
	
	if( self.IsAutoLoader ) then
		
		extra = extra.."(Auto Loader)\n"
		
	end
	
	if( self.BurstFire ) then
		
		extra = extra.."(Burst Fire)\n"
		
	end
	
	if( ammo > 0 ) then
		
		local maxammo = ( TANK_TYPE_MAX - self.TankType ) * 10
		extra = extra.."Ammo: "..ammo.."/"..maxammo.."\n"
		
	end
	
	if( fuel > 0 ) then
		
		extra = extra.."Fuel: "..math.floor( cfuel * 100 / fuel ).."%\n"
		
	end
	
	local hp = math.floor( self:GetNetworkedInt( "health" ) )
	local maxhp = math.floor( self:GetNetworkedInt( "MaxHealth", 0 ) )
	local h = hp / maxhp
	 
	extra = extra.."Health: "..math.floor(h * 100).."%"

	if ( AddWorldTip != nil && p:GetEyeTrace().Entity == self && EyePos():Distance( self:GetPos() ) < 1000 && p != driver ) then
			
		AddWorldTip(self:EntIndex(),self.PrintName.."\n"..extra, 0.5, self:GetPos() + Vector(0,0,172), self )
			
	end
	
	local Oil = self:GetNWFloat( "EngineOilLevel", 0 )
	
	if( Oil && Oil <= 0 && self.Emitter != nil ) then
		
		-- local particle = self.Emitter:Add( "sprites/smoke", self:LocalToWorld( self:GetPos() ) + self:GetRight() * math.random( -16,16 ) )
		-- self.Emitter = ParticleEmitter( self:GetPos() )
		
		if( particle && self:GetNetworkedBool("IsStarted", false ) ) then
			
			particle:SetDieTime( 0.3 )
			particle:SetStartAlpha( 255 )
			particle:SetEndAlpha( 255 )
			particle:SetStartSize( 50 )
			particle:SetEndSize( 0 )
			particle:SetColor( 255, 255, 255 )
			particle:SetCollide( false )
			particle:SetRoll( math.random(-1,1) )
			particle:SetGravity( Vector( math.sin(CurTime() - self:EntIndex() * 10 ) * 32, math.cos( CurTime() - self:EntIndex() * 10 ) * 32, math.random(70,130) ) )
			particle:SetCollide( true )
			
		end
		
		-- self.Emitter:Finish()

			
	end
	
end

function DrawTankHUD()

	GroundUnit.Pilot = LocalPlayer()
	GroundUnit.Tank = GroundUnit.Pilot:GetNetworkedEntity( "Tank", NULL )
	GroundUnit.Tower = GroundUnit.Pilot:GetNetworkedEntity( "Tower", NULL )
	GroundUnit.Barrel = GroundUnit.Pilot:GetNetworkedEntity( "Barrel", NULL )

	if ( GroundUnit.Tank:IsValid() ) then

		if ( GroundUnit.Pilot:GetNetworkedBool( "InFlight", false ) && GroundUnit.Tank != GroundUnit.Pilot ) then

			if( GetConVarNumber("jet_cockpitview") > 0 ) then
			
				-- if( GetConVarNumber("jet_health") > 0 ) then				
					-- GroundUnit.EnnemiesHP()				
				-- end
				if( GetConVarNumber("jet_markenemies") > 0 ) then				
					GroundUnit.MarkEnemies()				
				end
				-- GroundUnit.Binocular()
-- /*			else
				-- if  (GetConVarNumber("tank_artilleryview") == 1 ) then
					-- GroundUnit.Satellite
				-- end*/
			end
		
			GroundUnit.MissileAlert()
			GroundUnit.HUD()			
			if  (GetConVarNumber("tank_artilleryview") == 1 ) then
				GroundUnit.ArtilleryDisplay()			
			end
	end

	end
	
end
hook.Add( "HUDPaint", "NeuroTanks__HeadsUpDisplay", DrawTankHUD )

function GroundUnit.MissileAlert() -- Missile Alert && Valid Target Markers

	//GroundUnit.Pilot.LockonSound:PlayEx( 1.0, 100 )
	if ( GroundUnit.DrawWarning && GroundUnit.Tank && GroundUnit.Pilot:GetNetworkedBool("InFlight") ) then
		
		local pos = GroundUnit.Tank:GetPos() + GroundUnit.Tank:GetForward() * -805
		local ang = GroundUnit.Tank:GetAngles()
		
		draw.SimpleText("LOCK-ON ALERT", "LockonAlert", ScrW() / 2, ScrH() - 45, Color( 255, 35, 35, 200 + (math.sin(CurTime())*50) ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )

	else
	
		//GroundUnit.Pilot.LockonSound:FadeOut( 0.15 )
		/*if( GroundUnit.Pilot.LastBeep + 3.1 <= CurTime() ) then
			
			GroundUnit.Pilot.LastBeep = CurTime()
			surface.PlaySound( "LockOn/Launch.mp3" )
				
		end*/
		
	end
		
end

function GroundUnit.EnnemiesHP() --Display ennemies remaining health, would help to seek the weakest one! ;D

	for k,v in pairs( ents.FindByClass( "sent*" ) ) do
	
		if ( v:IsValid() && v.PrintName && v != GroundUnit.Tank && ( v.Type == "vehicle" || ( v.PrintName == "Missile" ) ) ) then
			
			local pos = ( v:GetPos() + Vector( 0,0,150 ) ):ToScreen( )
			local x,y = pos.x, pos.y
			
			if( inLOS( GroundUnit.Tank, v ) ) then
			
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
		
		if( inLOS( GroundUnit.Tank, v ) ) then
			
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

-- local binoculars = Material("Tank_Binoculars")
function GroundUnit.Binocular()

	local Tank = GroundUnit.Pilot:GetScriptedVehicle("Tank", NULL )
	if !( Tank:IsValid() ) then
	Tank = GroundUnit.Pilot:GetNetworkedEntity("Tank", NULL )
	end
	local Barrel = GroundUnit.Pilot:GetNetworkedEntity("Barrel", NULL )
	local speed = math.floor(Tank:GetVelocity():Length() / 1.8 )
	local Yaw
	
	
	if ( Barrel:IsValid() ) then
	Yaw = math.floor( Barrel:GetAngles().y ) + 180
	end

	if( Tank.HasBinoculars ) then
		
		-- surface.SetMaterial( binoculars )
		-- surface.DrawTexturedRect( 0,0, ScrW(), ScrH() )
		
		local color = {}
			color[ "$pp_colour_addr" ] = 0
			color[ "$pp_colour_addg" ] = 3 * 0.02
			color[ "$pp_colour_addb" ] = 0
			color[ "$pp_colour_brightness" ] = 0
			color[ "$pp_colour_contrast" ] = 1
			color[ "$pp_colour_colour" ] = 1
			color[ "$pp_colour_mulr" ] = 0
			color[ "$pp_colour_mulg" ] = 0
			color[ "$pp_colour_mulb" ] = 0 
		DrawColorModify( color )

	local lockwarning
	if GroundUnit.DrawWarning then 	lockwarning = 255 	else	lockwarning = 0	end
	surface.SetDrawColor( 150+lockwarning*105/255, 255-lockwarning, 150-lockwarning*150/255, 200)

	//Speed
	surface.DrawOutlinedRect(ScrW()/6, ScrH()/2-25, 50, 17 )
	draw.SimpleText("SPEED", "TargetID", ScrW()/6+2, ScrH()/2-28, Color( 150+lockwarning*105/255, 255-lockwarning, 150-lockwarning*150/255, 200 ), TEXT_ALIGN_LEFT, TEXT_ALIGN_LEFT )
	draw.SimpleText(math.floor(speed), "TargetID", ScrW()/6+48, ScrH()/2-5, Color( 150+lockwarning*105/255, 255-lockwarning, 150-lockwarning*150/255, 200 ), TEXT_ALIGN_RIGHT, TEXT_ALIGN_RIGHT )

	//Cap
	surface.DrawOutlinedRect( ScrW()/2- 17 , 100, 35, 17 )
	draw.SimpleText( math.floor(Yaw), "TargetID", ScrW()/2, 108, Color( 150+lockwarning*105/255, 255-lockwarning, 150-lockwarning*150/255, 200), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )

	end
end

--local satellite = Material("Tank_Binoculars")
function GroundUnit.Satellite() //Called when use artillery strikes, it draws a Satellite remote screen.

	local Yaw
	if ( GroundUnit.Pilot:IsValid() ) then
	Yaw = math.floor( GroundUnit.Pilot:EyeAngles().y ) + 180
	end
	if( Tank.IsArtillery ) then
		
		--surface.SetMaterial( binoculars )
		-- surface.DrawTexturedRect( 0,0, ScrW(), ScrH() )
		
		local color = {}
			color[ "$pp_colour_addr" ] = 0
			color[ "$pp_colour_addg" ] = 0
			color[ "$pp_colour_addb" ] = 0
			color[ "$pp_colour_brightness" ] = -0.1
			color[ "$pp_colour_contrast" ] = 1
			color[ "$pp_colour_colour" ] = 0.20
			color[ "$pp_colour_mulr" ] = 0
			color[ "$pp_colour_mulg" ] = 0
			color[ "$pp_colour_mulb" ] = 0 
		DrawColorModify( color )

	local lockwarning
	if GroundUnit.DrawWarning then 	lockwarning = 255 	else	lockwarning = 0	end
	surface.SetDrawColor( 150+lockwarning*105/255, 255-lockwarning, 150-lockwarning*150/255, 200)

	draw.SimpleText( "Satellite Cam", "TargetID", ScrW()/2, 5, Color( 150+lockwarning*105/255, 255-lockwarning, 150-lockwarning*150/255, 200), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
	//Cap
	surface.DrawOutlinedRect( ScrW()/2- 17 , 100, 35, 17 )
	draw.SimpleText( math.floor(Yaw), "TargetID", ScrW()/2, 108, Color( 150+lockwarning*105/255, 255-lockwarning, 150-lockwarning*150/255, 200), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )

	end

end

local LastT = CurTime()
local LastA = 0
function GroundUnit.ArtilleryDisplay()
	
	local lockwarning
	if( GroundUnit.Tank.IsArtillery ) then
		local color = {}
		color[ "$pp_colour_addr" ] = 0
		color[ "$pp_colour_addg" ] = 3 * 0.02
		color[ "$pp_colour_addb" ] = 0
		color[ "$pp_colour_brightness" ] = 0
		color[ "$pp_colour_contrast" ] = 0.75
		color[ "$pp_colour_colour" ] = 0.3
		color[ "$pp_colour_mulr" ] = 0
		color[ "$pp_colour_mulg" ] = 0
		color[ "$pp_colour_mulb" ] = 0 
	DrawColorModify( color )
			if GroundUnit.DrawWarning then 	lockwarning = 255 	else	lockwarning = 0	end

			local x,y = ScrW()/2, ScrH()/2
			surface.SetDrawColor( 150+lockwarning*105/255, 255-lockwarning, 150-lockwarning*150/255, 200)

			surface.DrawOutlinedRect( ScrW()/8 , ScrH()/8, x*3/2, y*3/2 )
			draw.SimpleText( "Test derivative", "TargetID", ScrW() / 2, 175, Color( 255, 0, 0, 200 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
				surface.DrawLine( x, y+16, x, y+64 )
				surface.DrawLine( x, y-16, x, y-64 )
				surface.DrawLine( x+16, y, x+64, y )
				surface.DrawLine( x-16, y, x-64, y )
			surface.DrawCircle( x, y, ScrW()/6, Color( lockwarning, 255-lockwarning, 0, 200) )
			surface.DrawCircle( x, y, ScrW()/5, Color( lockwarning, 0, 255-lockwarning, 200) )

			local A = GroundUnit.Tank:GetPos().x
			local D
				local t = CurTime()
				local dT = t - LastT
				LastT = t
				local dA = A - LastA
				LastA = A
				if (dT != 0) then
					D= math.Round(dA/dT)
				else
					D= 0;
				end
			draw.SimpleText( D, "TargetID", ScrW() / 2, 200, Color( 255, 0, 0, 200 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )

	end
end

function GroundUnit.HUD()

	local Barrel = GroundUnit.Pilot:GetNetworkedEntity("Barrel", NULL )
	local Weapon = GroundUnit.Pilot:GetNetworkedEntity( "Weapon", NULL )
	local Cannon = GroundUnit.Pilot:GetNetworkedEntity( "Cannon", NULL )
	local Pitch
	local hp = math.floor( GroundUnit.Tank:GetNetworkedInt( "Health", 0 ) )
	local maxhp = math.floor( GroundUnit.Tank:GetNetworkedInt( "MaxHealth", 0 ) )
	local h = hp * 100 / maxhp

	if ( GroundUnit.Target:IsValid() && GroundUnit.Target != GroundUnit.Plane && v == GroundUnit.Target ) then
		draw.SimpleText( "ALERT", "ChatFont", ScrW()*7/8, 120, Color( 255, 0, 0, 240 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
	end
	if ( h <= 20 ) then
		draw.SimpleText( "WARNING", "ChatFont", ScrW()*7/8, 108, Color( 255, 0, 0, 240 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
	end
	
	if ( GroundUnit.Tank.IsArtillery ) then

		if ( Barrel:IsValid() ) then
		Pitch = math.floor( Barrel:GetAngles().p )
		else
			if ( Cannon:IsValid() ) then
			Pitch = math.floor( Barrel:GetAngles().p )
			else
			Pitch = 0
			end
		end

		//Display angle of the main cannon.
		surface.SetDrawColor( 255, 255, 255, 200 )
		draw.SimpleText( -math.floor(Pitch).." degrees", "TargetID", ScrW()/8, 108, Color( 255, 255, 255, 200 ), TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER )

	end
	
end

function GroundUnit.MarkEnemies()
	
	local Tank = GroundUnit.Pilot:GetScriptedVehicle()
	local Barrel = GroundUnit.Pilot:GetNetworkedEntity("Barrel", NULL )
	local Weapon = GroundUnit.Pilot:GetNetworkedEntity( "Weapon", NULL )
	local Cannon = GroundUnit.Pilot:GetNetworkedEntity( "Cannon", NULL )
	local count = 0
	local size = 30
	local NTeam = Tank:GetNetworkedInt( "NeuroTeam", 1 )
	
	for k,v in pairs( ents.FindByClass( "sent*" ) ) do

		if ( v:IsValid() && v.PrintName && v != Tank && ( v.Type == "vehicle" || ( v.PrintName == "Missile" ) ) ) then
			
			local pos = ( v:GetPos() + Vector( 0,0,50 ) ):ToScreen( )
			local x,y = pos.x, pos.y
			local TargetTeam = v:GetNetworkedInt( "NeuroTeam", 0 )
			
			if( inLOS( Tank, v ) ) then
			
				if ( TargetTeam == NTeam ) and ( TargetTeam > 0 ) then
					if ( v:GetClass() == Tank:GetClass() ) then
						draw.SimpleText( v.PrintName, "ChatFont", x, y - 30, Color( 0, 255, 255, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
					else
						draw.SimpleText( v.PrintName, "ChatFont", x, y - 30, Color( 0, 150, 255, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
					end
				else
					
					local target = v:GetNetworkedEntity( "Target", NULL )

					if ( target:IsValid() && ( target == Tank || target == Barrel || target == Weapon || target == Cannon || target == GroundUnit.Pilot ) ) then
						
						draw.SimpleText( "Warning", "ChatFont", x, y - 15, Color( 204, 51, 0, 240 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
						count = count + 1
						
					end
				
					if( v.PrintName == "Missile" ) then

						//draw.SimpleText( "Missile", "ChatFont", x, y, Color( 255, 40, 0, 200 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
					
					else
						
						if ( v:GetClass() == Tank:GetClass() ) then
							
							draw.SimpleText( v.PrintName, "ChatFont", x, y - 30, Color( 0, 255, 55, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
						
						else
						
							draw.SimpleText( v.PrintName, "ChatFont", x, y - 30, Color( 255, 102, 0, 240 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
						
						end

					end
					
				
				end
			
				if (  GroundUnit.Target:IsValid() && GroundUnit.Target != Tank && v == GroundUnit.Target ) then
					
					draw.SimpleText( "Locked On", "ChatFont", x, y, Color( 255, 0, 0, 240 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
					
				end
			
			end
			
		end
	
	end
	
	for k,v in pairs( ents.FindByClass( "npc*" ) ) do
		
		local pos = ( v:GetPos() + Vector(0,0,150 ) ):ToScreen( )
		local x,y = pos.x, pos.y
		
		if( inLOS( Tank, v ) ) then
			
			if ( v:OnGround() ) then
			
				draw.SimpleText( "Unit", "ChatFont", x, y - 35, Color( 255, 102, 0, 240 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
			
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

			if ( GroundUnit.Target:IsValid() && GroundUnit.Target != Tank && v == GroundUnit.Target ) then
			
				draw.SimpleText( "Locked On", "ChatFont", x, y, Color( 255, 0, 0, 240 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
					
			end
			
			
			local target = v:GetNetworkedEntity( "Target", NULL )
					
			if ( target:IsValid() && target == Tank && target:GetNetworkedEntity("Guardian_Object", NULL ) != LocalPlayer() ) then
				
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
	
	if( !Tank || !GroundUnit.Pilot || !Tank:IsValid() || !GroundUnit.Pilot:IsValid() ) then return end
	
	for k,v in pairs( player.GetAll() ) do
		
		if ( v:GetPos():Distance( Tank:GetPos() ) < 6500 && v != GroundUnit.Pilot ) then
			
			if ( v:OnGround() && !v.ColdBlooded && inLOS( Tank, v ) ) then
				
				local pos = ( v:GetPos() + Vector( 0, 0, 82 ) ):ToScreen( )
				local x,y = pos.x, pos.y
				draw.SimpleText( v:GetName(), "ChatFont", x + 15, y, Color( 45, 255, 45, 240 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
				
				if ( GroundUnit.Target:IsValid() && GroundUnit.Target != Tank && v == GroundUnit.Target ) then
				
					draw.SimpleText( "Locked On", "ChatFont", x, y, Color( 255, 0, 0, 240 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
						
				end
				
			end
		
		end
		
	end
	
	if( count > 0 ) then
		
		if( GroundUnit.Pilot:GetScriptedVehicle() == Tank ) then
			
			GroundUnit.DrawWarning = true
		
		else
			
			GroundUnit.DrawWarning = false
		
		end
		
	else
	
		GroundUnit.DrawWarning = false
	
	end
	
end


function DrawAccuracyCircle()
	
	-- if true then return end
	local et = LocalPlayer():GetEyeTrace()
	local norm = et.Normal:Angle()
	-- local plyang = norm
	-- print( norm.p )
	-- PrintTable( plyang )
	-- local plyang = LocalPlayer():GetEyeTrace().Normal:Angle():Normalize()
	-- print( plyang )
	
	local tank = LocalPlayer():GetScriptedVehicle( )
	
	if !( tank:IsValid() ) then
	
		tank = LocalPlayer():GetNetworkedEntity("Tank", NULL )
	end
	
	local ent = LocalPlayer():GetNetworkedEntity( "Barrel", NULL )
	local entang = ent:GetAngles()
	
	norm.p = math.Clamp( norm.p,-45, 6)

	local ang = entang-norm
	
	local dZ =funcDerivate( math.Round(ang.p,2) )
	local dY =funcDerivate( math.Round(ang.y,2) )
	dZ = math.Clamp( dZ, -ScrH(), ScrH())
	dY = math.Clamp( dY, -ScrH(), ScrH())

	local Spd = LocalPlayer():GetVelocity():Length()
	local dSpd = math.Round(Spd/200,2)
	dSpd = math.Clamp( dSpd, -ScrH()/3, ScrH()/3)

	local accoffset = math.Round( dSpd*100 + math.abs(dZ+dY)/16 )
	
	-- print( dZ,dY,dSpd )
	-- print( accoffset )
	surface.DrawCircle( ScrW()/2, ScrH()/2, ScrH()/32+accoffset, Color( 255, 255, 255, 220) )

end

function DrawImpactZone()

	local R = LocalPlayer():GetNetworkedFloat( "Range", 1000 )
	local LaunchAngle = LocalPlayer():GetNetworkedFloat( "LaunchAngle", 45 )
	local LaunchVelocity = LocalPlayer():GetNetworkedFloat( "LaunchVelocity", 3000 )

	local ent = LocalPlayer():GetNetworkedEntity("Barrel", NULL)
		
	local tr, trace = {}, {}
	tr.start =  Vector(0,0,0)
	tr.endpos = tr.start + Vector(0,0,-10)
	tr.filter = tank,barrel
	trace = util.TraceLine( tr )
	
	local radius = 100
	radius = math.Clamp( radius, 0,ScrW()*2)
	local center = trace.HitPos:ToScreen()	
	local normalA = trace.Normal:Angle()
	
	local scale = Vector(radius, radius ,0 )
	local color = Color( 255,0,0,255)
	
	if( trace.Hit ) then	
		DrawHUDEllipse(center,scale,color) 
	end
	
	
end
	
print( "[NeuroTanks] C_NeuroTanksGlobal.lua loaded!" )