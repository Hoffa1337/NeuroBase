SWEP.PrintName = "Target Designator"
SWEP.Author = ""
SWEP.Contact = ""
SWEP.Purpose = "Works with AI-Flak88"
SWEP.Instructions = "Left Click to designate targets. Right click to call a strike. Reload to start tracking."
SWEP.Category = "Military Accessories"
SWEP.Slot = 0
SWEP.SlotPos = 4
SWEP.DrawAmmo = false
SWEP.DrawCrosshair = true

SWEP.Spawnable = true;
SWEP.AdminSpawnable = true;

SWEP.ViewModel = "models/weapons/v_binoculars.mdl";
SWEP.WorldModel = "models/weapons/w_binoculars.mdl";
SWEP.HoldType = "camera"

SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Automatic = false
SWEP.Primary.Ammo = "none"

SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo = "none"

if (SERVER) then
AddCSLuaFile( "shared.lua" )
SWEP.Weight = 5
SWEP.AutoSwitchTo = false
SWEP.AutoSwitchFrom = false
end

-- SWEP.Receiver = nil
SWEP.Pointing = false
SWEP.CanCallStrike = false
SWEP.Tracking = false

function SWEP:Precache()
    util.PrecacheSound("binoculars/binoculars_zoomin.wav")
	util.PrecacheSound("binoculars/binoculars_zoommax.wav")
	util.PrecacheSound("binoculars/binoculars_zoomout.wav")
end

function SWEP:Initialize()
	
	self:SetWeaponHoldType( self.HoldType )

	self.Pointing = false
	self.CanCallStrike = false
	self.Tracking = false
	
	self.LastAction = CurTime()
	self.Zoom = 90
	
end

