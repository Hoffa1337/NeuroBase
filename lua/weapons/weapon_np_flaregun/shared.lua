
if (SERVER) then

	AddCSLuaFile( "shared.lua" )
	SWEP.Weight				= 5
	SWEP.AutoSwitchTo		= false
	SWEP.AutoSwitchFrom		= false

end

if ( CLIENT ) then

	SWEP.DrawAmmo			= true
	SWEP.DrawCrosshair		= true
	SWEP.ViewModelFOV		= 62
	SWEP.ViewModelFlip		= false
	SWEP.CSMuzzleFlashes	= true

	SWEP.PrintName			= "Flaregun"			
	SWEP.Author				= "Hoffa"
	SWEP.Slot				= 2
	SWEP.SlotPos			= 1
	SWEP.IconLetter			= "b"
	
end

SWEP.Author			= "Hoffa"
SWEP.Contact		= "Hoffa1337 @ Facepunch\nSluggomc @ Steam"
SWEP.Purpose		= ""
SWEP.Instructions	= "In case of of emergency, fire flare towards sky\nand wait to see if the enemy can beat your team mates to the spot."
SWEP.HoldType = "rpg"
SWEP.Category = "Military Accessories"
SWEP.Spawnable			= true
SWEP.AdminSpawnable		= false

SWEP.Primary.Sound			= Sound( "weapons/flaregun/fire.wav" )
SWEP.Primary.Recoil			= 1.5
SWEP.Primary.Delay			= 5

SWEP.Primary.ClipSize		= -1
SWEP.Primary.DefaultClip	= -1
SWEP.Primary.Automatic		= false
SWEP.Primary.Ammo			= "none"

SWEP.Secondary.ClipSize		= -1
SWEP.Secondary.DefaultClip	= -1
SWEP.Secondary.Automatic	= false
SWEP.Secondary.Ammo			= "none"

SWEP.ViewModel			= "models/weapons/v_357.mdl"
SWEP.WorldModel			= "models/weapons/w_357.mdl"

SWEP.Weight				= 5
SWEP.AutoSwitchTo		= false
SWEP.AutoSwitchFrom		= false


/*---------------------------------------------------------
---------------------------------------------------------*/
function SWEP:Initialize()

	if ( SERVER ) then
		self:SetNPCMinBurst( 1 )
		self:SetNPCMaxBurst( 1 )
		self:SetNPCFireRate( 6.0 )
	end

	self:SetWeaponHoldType( self.HoldType )
	self.LastRelease = CurTime()
	
end


/*---------------------------------------------------------
	Reload does nothing
---------------------------------------------------------*/
function SWEP:Reload()

	self.Weapon:DefaultReload( ACT_VM_RELOAD );
	
end


/*---------------------------------------------------------
   Think does nothing
---------------------------------------------------------*/
function SWEP:Think()
	
	if( IsValid( self.flare ) ) then
	
		for k,v in pairs( ents.FindInSphere( self.flare:GetPos(), 1500 ) ) do
			
			if( IsValid( v.Target ) ) then
				
				v.Target = self.flare
				
			end
			
		end
		
	end

end

/*---------------------------------------------------------
	PrimaryAttack
---------------------------------------------------------*/
function SWEP:PrimaryAttack()
	
	self.Weapon:SetNextSecondaryFire( CurTime() + self.Primary.Delay )
	self.Weapon:SetNextPrimaryFire( CurTime() + self.Primary.Delay )

	if (SERVER ) then
	
		self.Weapon:EmitSound( self.Primary.Sound )

		self.flare = ents.Create("prop_physics")
		self.flare:SetPos( self.Owner:GetShootPos() )
		self.flare:SetAngles( self.Owner:EyeAngles() )
		self.flare:SetModel( "models/Items/AR2_Grenade.mdl" )
		self.flare:Spawn()
		//self.flare:Ignite(50,50)
		self.flare:Fire("kill","",30)
		self.flare:EmitSound("weapons/flaregun/fire.wav", 100, 100 )
		
	
		-- timer.Simple( 1.5, function() self.flare:GetPhysicsObject():SetMass( 1 ) end )
		
		for i=1,5 do
		
			local f2 = ents.Create("env_flare")
			f2:SetPos( self.flare:GetPos() + Vector( math.random(-2,2),math.random(-2,2),math.random(-2,2) ) )
			f2:SetParent( self.flare )
			f2:Spawn()
			
		end
		
		//self.flare:SetVelocity( self.Owner:GetAimVector() * 150000 )
		
		self.flare:GetPhysicsObject():ApplyForceCenter( self:GetForward() * 8000 )
		
		self:ShootEffects() 

		
	end
	
	if ( self.Owner:IsNPC() ) then return end

	if ( (game.SinglePlayer() && SERVER) || CLIENT ) then
	
		self.Weapon:SetNetworkedFloat( "LastShootTime", CurTime() )
		
	end
	
end

function SWEP:OnRestore()

	self.NextSecondaryAttack = 0
	
end
