include('shared.lua')

local LASER = Material('cable/redlaser')

function SWEP:Initialize()
    local ply = LocalPlayer()
    self.VM = ply:GetViewModel()
    local attachmentIndex = self.VM:LookupAttachment("muzzle")
    if attachmentIndex == 0 then attachmentIndex = self.VM:LookupAttachment("1") end
	self.Attach = attachmentIndex
end

function SWEP:ViewModelDrawn()
	if(self.Weapon:GetNWBool("Active")) then
        //Draw the laser beam.
        render.SetMaterial( LASER )
		render.DrawBeam(self.VM:GetAttachment(self.Attach).Pos, self.Owner:GetEyeTrace().HitPos, 2, 0, 12.5, Color(255, 0, 0, 255))
    end
end
