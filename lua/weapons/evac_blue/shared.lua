// Variables that are used on both client and server
SWEP.Category			= "Military Accessories"
------------General Swep Info---------------
SWEP.PrintName			= "Signalling Smoke-Grenade (Blue)"
SWEP.Instructions   	= "Left click to deploy a blue smoke signal."
SWEP.Author   			= "Tommo :D"
SWEP.Contact        	= ""
SWEP.Purpose        	= "Requesting Backup"
SWEP.Spawnable      	= true
SWEP.AdminSpawnable 	= true
SWEP.Slot				= 4
SWEP.SlotPos		    = 4	
--------------------------------------------

------------Models---------------------------
SWEP.ViewModel = Model( "models/weapons/v_eq_flashbang.mdl" );
SWEP.WorldModel = Model( "models/weapons/w_eq_flashbang.mdl" );
---------------------------------------------

-------------Primary Fire Attributes----------------------------------------
SWEP.Primary.Round 			= ("evac_indicator_blue")	
SWEP.Primary.RPM				= 20					// This is in Rounds Per Minute
SWEP.Primary.ClipSize			= 1					// Size of a clip
SWEP.Primary.DefaultClip			= 1					// Default number of bullets in a clip
SWEP.Primary.Automatic			= false					// Automatic/Semi Auto
SWEP.Primary.Ammo			= "grenade"
-------------------------------------------------------------------------------------

-------------Secondary Fire Attributes---------------------------------------

SWEP.Secondary.ClipSize			= 0				// Size of a clip
SWEP.Secondary.DefaultClip			= 0				// Default number of bullets in a clip
SWEP.Secondary.Automatic			= false					// Automatic/Semi Auto
SWEP.Secondary.Ammo			= ""
-------------------------------------------------------------------------------------


function SWEP:Initialize()
	//if SERVER then
	self:SetWeaponHoldType("melee")
	//end
end

function SWEP:Deploy()
	self.Weapon:SendWeaponAnim( ACT_VM_DRAW )
end


function SWEP:PrimaryAttack()
	if self:CanPrimaryAttack() then
		self.Weapon:TakePrimaryAmmo(1)
		self.Weapon:SendWeaponAnim(ACT_VM_PULLPIN)
		self.Weapon:SetNextPrimaryFire(CurTime()+1/(self.Primary.RPM/60))
		timer.Simple( 0.6, self.Throw, self )

	end
end

function SWEP:Throw()
	self.Weapon:SendWeaponAnim(ACT_VM_THROW)
	timer.Simple( 0.25, self.SwingArm, self )
	timer.Simple( 0.35, self.Grenada, self )
	timer.Simple( 1, self.Reload, self )
	timer.Simple( 1, self.Deploy, self )
end

function SWEP:SwingArm()
	self.Owner:SetAnimation(PLAYER_ATTACK1)
end

function SWEP:Grenada()
	aim = self.Owner:GetAimVector()
	side = aim:Cross(Vector(0,0,1))
	up = side:Cross(aim)
	pos = self.Owner:GetShootPos() + side * 5 + up * -1
	if SERVER then
	local rocket = ents.Create(self.Primary.Round)
	if !rocket:IsValid() then return false end
	rocket:SetAngles(aim:Angle()+Angle(90,0,0))
	rocket:SetPos(pos)
	rocket:SetOwner(self.Owner)
	rocket:Spawn()
	local phys = rocket:GetPhysicsObject()
	if self.Owner:KeyDown(IN_ATTACK2) then
	phys:ApplyForceCenter(self.Owner:GetAimVector() * 2000)
	else 
	phys:ApplyForceCenter(self.Owner:GetAimVector() * 6000) end
	end
end

function SWEP:SecondaryAttack()
	return false
end

