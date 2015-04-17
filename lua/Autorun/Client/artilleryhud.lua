
local sin = math.sin
local cos = math.cos

function scaleVertices(tblVertices, iScaleX, iScaleY)
	for k, v in pairs(tblVertices) do
		v.x = v.x * iScaleX
		v.y = v.y * iScaleY
	end
end

function offsetVertices(tblVertices, iOffsetX, iOffsetY)
	for k, v in pairs(tblVertices) do
		v.x = v.x + iOffsetX
		v.y = v.y + iOffsetY
	end
end

function rotateVertices(tblVertices, theta)
	for k, v in pairs(tblVertices) do
		local x = v.x*cos(theta) - v.y*sin(theta)
		local y = v.x*sin(theta) + v.y*cos(theta)
		v.x = x
		v.y = y
	end
end

function percent(n, x)
	return (n*x)/100
end

local per = 0
local indicator = 0

function RotateHud( ReloadTime )
	-- print( ReloadTime )
	local now = CurTime()
	local steps = 21
	indicator = 0
	ReloadTime = ReloadTime - 0.1
	for i=1,steps do
		
		timer.Simple( ReloadTime/steps * i, function()
			
			-- print( ReloadTime/i, math.floor( CurTime() - now ) )
			per = math.ceil(percent(indicator, 37))
			
			if(indicator >= 100) then
				
				indicator = 0
			
			else
				
				indicator = indicator + 5
			
			end
			
		end )
		
	end
	
end
-- timer.Simple( 5, RotateHud( 4 ) )
-- timer.Destroy("HudTest")
-- timer.Create( "HudTest", 0.1, 0, function()  
	
	-- per = math.ceil(percent(indicator, 37))
	-- if(indicator >= 100) then
		-- indicator = 0
	-- else	
		-- indicator = indicator + 5
	-- end

-- end )
local SizeDivider = 1.5
local FatMax = 0.0044
local FatMin = 0.001
local rectmat = surface.GetTextureID("Brick/brickfloor001a")
hook.Add("HUDPaint", "neurotec_ArtyCam", function()

    local ply = LocalPlayer()
    local tank = ply:GetScriptedVehicle()
	local barrel = ply:GetNetworkedEntity("Barrel", NULL )
	
    if( IsValid( tank ) && tank.TankType != nil && ply.Adiff ) then
        -- print( (( ply.Adiff + ply.Bdiff)/2))
		-- if(  GetConVarNumber("jet_cockpitview") == 0 ) then
		
			SizeDivider = Lerp( 0.2, SizeDivider, 1.5 + ( 5.0 - math.Clamp( ply.Adiff, 0, 5 ) ) )
			-- print( SizeDivider/10 )
			
			a = ScrW() / 2
			b = ScrH() / 2
			if( ply.TargetPosition ) then
				
				a = ply.TargetPosition.x
				b = ply.TargetPosition.y
				
			end
			m = math.min(a, b)
			r = m/SizeDivider;
			r2 = math.abs(m - r) / 2
			n = 36
			size = 0.85 - math.Clamp( SizeDivider/15, 0, .8 )

			sX = ScrW() * 0.0044
			sY = ScrH() * 0.0190


			for i=0,n do
				t = 2 * math.pi * (i-1) / n
				px = math.ceil(a + r * math.cos(t))
				py = math.ceil(b + r * math.sin(t))

				local rect = {
					{ x = -(sX/2), y = (sY/2) },
					{ x = (sX/2), y = (sY/2) },
					{ x = (sX/2), y = -(sY/2) },
					{ x = -(sX/2), y = -(sY/2) }
				}

				rotateVertices(rect, math.pi/2+t)
				scaleVertices(rect, size, size) -- we scale the vertices based on scale

				offsetVertices(rect, px, py)

				if(i > per) then
					surface.SetDrawColor( Color(255, 0, 0, 155) )
				else
					surface.SetDrawColor( Color(0, 255, 0, 155) )
				end
				-- draw.NoTexture()
				surface.SetTexture(0)
				surface.DrawPoly( rect )



			end
			 
		-- else
		
		if( tank.ArtyView && GetConVarNumber("jet_cockpitview") == 1 ) then 
		
			if( !ply.ImpactPosition ) then return end
			local tpos = ply.ImpactPosition
			local pos = tpos:ToScreen()
			-- surface.SetDrawColor( Color(0, 155, 0, 124) )
			surface.SetDrawColor( Color(0, 0, 0, 200) )
			-- surface.DrawLine(0,ScrH() / 2, ScrW(), ScrH() / 2)
			-- surface.DrawLine(ScrW() / 2,0, ScrW() / 2, ScrH())
			surface.DrawLine(pos.x,0, pos.x, pos.y)
			surface.DrawLine(pos.x,pos.y, pos.x, ScrH())
			surface.DrawLine(0,pos.y, pos.x, pos.y)
			surface.DrawLine(pos.x,pos.y, ScrW(), pos.y)
			surface.SetDrawColor( Color(255, 255, 255, 255) )
			
			draw.SimpleText( -math.Round(barrel:GetAngles().p*10)/10 .." deg", "ChatFont", pos.x+15, pos.y-10, Color( 0, 0, 0, 255 ), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER )
		
			if (tank.VehicleCrosshairType == 25) then
				
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

				///GPS Coord
				surface.DrawOutlinedRect( ScrW()*0.84, 10, ScrW()*0.15, 95 )
				surface.DrawOutlinedRect( ScrW()*0.84+2, 12, ScrW()*0.15-4, 91 )
				surface.DrawLine(ScrW()*0.84+2,32,ScrW()*0.84+ScrW()*0.15-4,32)
				draw.SimpleText( "GPS Coordinates", "ChatFont", ScrW()*0.85, 20, Color( 0, 0, 0, 255 ), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER )
				draw.SimpleText( "Latitude:    "..math.Round(tpos.y*100)/100, "ChatFont", ScrW()*0.85, 45, Color( 0, 0, 0, 255 ), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER )
				draw.SimpleText( "Longitude: "..math.Round(tpos.x*100)/100, "ChatFont", ScrW()*0.85, 60, Color( 0, 0, 0, 255 ), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER )
				draw.SimpleText( "Altitude:    "..math.Round(tpos.z*100)/100, "ChatFont", ScrW()*0.85, 75, Color( 0, 0, 0, 255 ), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER )
				draw.SimpleText( "Height:       "..math.Round((tpos.z-tank:GetPos().z)*100)/100, "ChatFont", ScrW()*0.85, 90, Color( 0, 0, 0, 255 ), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER )
				
			end
			
		end
		
    end

end)

print( "[NeuroTanks] artilleryhud.lua loaded!" )