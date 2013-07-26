include('shared.lua')

local LASER = Material('cable/redlaser')
local Scope = Material("TankBin")

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
	local zoom = 75
	local scale = Vector( 108-zoom, 108-zoom, 0 )
	local segmentdist = 360 / ( 2 * math.pi * math.max( scale.x, scale.y ) / 2 )

	-- if self.Pointing then
	if self.Weapon:GetNWBool("Active", false) then
	
		surface.SetDrawColor( 255, 255, 255, 255 )
		surface.SetMaterial( Scope )
		surface.DrawTexturedRect( 0, -ScrW() / 4.5, ScrW(), ScrW() )

		surface.SetDrawColor( 255, 255, 255, 255 )
		for i = 0, 360 - segmentdist, segmentdist do
		surface.DrawLine( center.x + math.cos( math.rad( i ) ) * scale.x, center.y - math.sin( math.rad( i ) ) * scale.y, center.x + math.cos( math.rad( i + segmentdist ) ) * scale.x, center.y - math.sin( math.rad( i + segmentdist ) ) * scale.y )
		end
	end

end
end