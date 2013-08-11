include('shared.lua')

local LASER = Material('cable/redlaser')
local Scope = Material("TankBin")
local InMeters = 0.3048/16 //This is constant to convert map grid unit to meters.
local InFeet = 1/16 //Constant to get distances from map unit in feet.

function SWEP:Initialize()
    local ply = LocalPlayer()
    self.VM = ply:GetViewModel()
    local attachmentIndex = self.VM:LookupAttachment("muzzle")
    if attachmentIndex == 0 then attachmentIndex = self.VM:LookupAttachment("1") end
	self.Attach = attachmentIndex
end

function SWEP:ViewModelDrawn()
	local hitpos = self.Owner:GetEyeTrace().HitPos
	local startpos = self.Owner:GetEyeTrace().StartPos
	local vec = (hitpos - startpos):GetNormalized()
	if(self.Weapon:GetNWBool("Active")) then
        //Draw the laser beam.
        render.SetMaterial( LASER )
		-- render.DrawBeam(self.VM:GetAttachment(self.Attach).Pos, self.Owner:GetEyeTrace().HitPos, 2, 0, 12.5, Color(255, 0, 0, 255)) //Use HL2 pistol as reference.
		render.DrawBeam(self.Owner:GetEyeTrace().StartPos+vec*20+self.Owner:GetRight()*20+self.Owner:GetUp()*0, self.Owner:GetEyeTrace().HitPos, 2, 0, 12.5, Color(255, 0, 0, 255))
    end
end

if ( CLIENT ) then
function SWEP:DrawHUD()

	local	w = ScrW()
	local	h = ScrH()
	local center = Vector( w/2, h/2, 0 )
	local zoom = self.Owner:GetFOV()
	-- local scale = Vector( 108-zoom, 108-zoom, 0 )
	-- local scale = Vector( 100-zoom, 100-zoom, 0 )
	local scale = Vector( w/12*(1-zoom/90), w/12*(1-zoom/90), 0 )
	local hitpos = self.Owner:GetEyeTrace().HitPos
	local startpos = self.Owner:GetEyeTrace().StartPos
	local length = math.Round( ( hitpos - startpos):Length()*InMeters )

	if self.Weapon:GetNWBool("Active", false) then
	
		surface.SetDrawColor( 255, 255, 255, 255 )
		surface.SetMaterial( Scope )
		surface.DrawTexturedRect( 0, -ScrW() / 4.5, ScrW(), ScrW() )
		local grey = Color(100, 100, 100, 255)
		local green = Color(0, 100, 0, 255)
		local yellow = Color(255, 225, 0, 255)
		DrawHUDEllipse(center,Vector(w/12,w/12,0), grey )
		DrawHUDEllipse(center,scale*3,green )
		-- DrawHUDEllipse(center,Vector(w/4,w/4,0),Color(0,255,0,255) )
		
		DrawHUDLine( Vector(w/2,h/2-w/4,0), Vector(w/2,h/2+w/4,0), grey )
		DrawHUDLine( Vector(w/4,h/2,0), Vector(3*w/4,h/2,0), grey )	
		for i=2,3 do
			DrawHUDLine( Vector(w/2-i*w/12,h/2-16,0), Vector(w/2-i*w/12,h/2+16,0), grey )
			DrawHUDLine( Vector(w/2+i*w/12,h/2-16,0), Vector(w/2+i*w/12,h/2+16,0), grey )
		end
		for j=2,3 do
			DrawHUDLine( Vector(w/2-16,h/2-j*w/12,0), Vector(w/2+16,h/2-j*w/12,0), grey )
			DrawHUDLine( Vector(w/2-16,h/2+j*w/12,0), Vector(w/2+16,h/2+j*w/12,0), grey )	
		end
		for k=1,2 do
		draw.SimpleText("10", "ScoreboardText", w/2+16, h/2+(3-2*k)*w/12, grey, TEXT_ALIGN_CENTER, TEXT_ALIGN_LEFT)
		draw.SimpleText("20", "ScoreboardText", w/2+16, h/2+(3-2*k)*2*w/12, grey, TEXT_ALIGN_CENTER, TEXT_ALIGN_LEFT)
		draw.SimpleText("30", "ScoreboardText", w/2+16, h/2+(3-2*k)*3*w/12, grey, TEXT_ALIGN_CENTER, TEXT_ALIGN_LEFT)
		
		draw.SimpleText("10", "ScoreboardText", w/2+(3-2*k)*w/12, h/2+16, grey, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
		draw.SimpleText("20", "ScoreboardText", w/2+(3-2*k)*2*w/12, h/2+16, grey, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
		draw.SimpleText("30", "ScoreboardText", w/2+(3-2*k)*3*w/12, h/2+16, grey, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
		end
		draw.SimpleText(length.." m", "ScoreboardText", w/2-w/48, h/2+w/48, green, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)

		draw.SimpleText("Status", "ScoreboardText", h/16, h/16, grey, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
		draw.SimpleText("Order", "ScoreboardText", w-h/16, h/16, grey, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
		
		if	self.Owner:GetNetworkedBool( "DestroyTarget", false ) then
		draw.SimpleText("Fire", "ScoreboardText", w-h/16, h/8, green, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
		else
		draw.SimpleText("Hold Fire", "ScoreboardText", w-h/16, h/8, yellow, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
		end
		
		if	self.Owner:GetNetworkedBool( "TrackTarget", false ) then
		draw.SimpleText("Tracking", "ScoreboardText", h/16, h/8, green, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
		else
		draw.SimpleText("Standby", "ScoreboardText", h/16, h/8, yellow, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
		end
		
		
		if	(self.Owner:GetNetworkedEntity( "AI_cannon", NULL ) !=NULL) or (self.Owner:GetNetworkedEntity( "AI_pac3", NULL ) !=NULL) or (self.Owner:GetNetworkedEntity( "AI_flak18", NULL )  then
		draw.SimpleText("Ready", "ScoreboardText", w-h/16, h-h/8, green, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
		else
		draw.SimpleText("Waiting for controls", "ScoreboardText", w-h/16, h-h/8, yellow, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)		
		end
	end

end
end

function SWEP:HUDShouldDraw( name )

	if	self:GetNWBool("Active", true) then
		for k, v in pairs({"CHudHealth", "CHudBattery", "CHudAmmo", "CHudSecondaryAmmo","CHudZoom","CHudSuitPower"}) do
			if name == v then return false end
		end
		else
			if name == "CHudZoom" then return false end
		
	end
		
    -- if ( name == "CHudHealth" or name == "CHudBattery" ) then
        -- return false
    -- end
    return true
end

/*

function SWEP:HideHL2HUD( name )

	if(self.Pointing)then
		for k, v in pairs({"CHudHealth", "CHudBattery", "CHudAmmo", "CHudSecondaryAmmo","CHudZoom","CHudSuitPower","CHudWeaponSelection"}) do
			if name == v then return false end
		end
	end
end	
hook.Add("HUDShouldDraw", "NeuroTech_HideHL2HUD", HideHL2HUD )