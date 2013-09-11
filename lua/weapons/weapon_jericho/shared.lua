
if (SERVER) then

	AddCSLuaFile( "shared.lua" )
	SWEP.Weight				= 5
	SWEP.AutoSwitchTo		= false
	SWEP.AutoSwitchFrom		= false

end

if ( CLIENT ) then

	SWEP.DrawAmmo			= true
	SWEP.DrawCrosshair		= false
	SWEP.ViewModelFOV		= 62
	SWEP.ViewModelFlip		= false
	SWEP.CSMuzzleFlashes	= false

	SWEP.PrintName			= "Jericho Launcher"			
	SWEP.Author				= "Hoffa"
	SWEP.Slot				= 4
	SWEP.SlotPos			= 1
	SWEP.IconLetter			= "b"
	
end

SWEP.Author			= "Hoffa"
SWEP.Contact		= "Hoffa1337 @ Facepunch\nSluggomc @ Steam"
SWEP.Purpose		= ""
SWEP.Instructions	= "Aim away from face"
SWEP.HoldType = "rpg"

SWEP.Spawnable			= true
SWEP.AdminSpawnable		= true

SWEP.Primary.Sound			= Sound( "sounds/lockon/missilelaunch.mp3" )
SWEP.Primary.Recoil			= 1.5
SWEP.Primary.Delay			= 30

SWEP.Primary.ClipSize		= 1
SWEP.Primary.DefaultClip	= 1
SWEP.Primary.Automatic		= false
SWEP.Primary.Ammo			= "none"

SWEP.Secondary.ClipSize		= -1
SWEP.Secondary.DefaultClip	= -1
SWEP.Secondary.Automatic	= false
SWEP.Secondary.Ammo			= "none"

SWEP.ViewModel			= "models/weapons/v_RPG.mdl"
SWEP.WorldModel			= "models/weapons/w_rocket_launcher.mdl"

SWEP.Weight				= 25
SWEP.AutoSwitchTo		= false
SWEP.AutoSwitchFrom		= false

SWEP.Primary.Sound			= Sound( "LockOn/Shoot.mp3" )
SWEP.Primary.Automatic		= true
SWEP.Primary.Ammo			= "RPG_Round"



/*---------------------------------------------------------
---------------------------------------------------------*/
function SWEP:Initialize()

	if ( SERVER ) then
		self:SetNPCMinBurst( 1 )
		self:SetNPCMaxBurst( 1 )
		self:SetNPCFireRate( 6.0 )
	end
	
	
	
	/*if( CLIENT ) then
		self.RocketProps = {}
		local s = self.Owner:GetViewModel()
		
		for i = 1, 4 do 
		
			self.RocketProps[i] = ClientsideModel( "models/hawx/weapons/agm-65 maverick.mdl", RENDERGROUP_OPAQUE )
			self.RocketProps[i]:SetPos( s:GetPos() + s:GetRight() * ( i * -3 ) )
			self.RocketProps[i]:SetParent( s )
			self.RocketProps[i]:SetAttachment( 1 )
			self.RocketProps[i]:SetAngles( s:GetAngles() + Angle( -90, 0, 0 ) )
			self.RocketProps[i]:SetModelScale( Vector( .05, .05, .05 ) )
			
		end
		
	end */
	
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

	if ( CLIENT ) then return end
	
	if( !self.Target ) then 
	
		local tr, trace = {},{}
		tr.start =  self.Owner:GetShootPos() + self.Owner:GetForward() * 100 + self.Owner:GetUp() * 16
		tr.endpos = self.Owner:GetAimVector() * 999999
		tr.filter = { self, self.Owner }
		tr.mask = MASK_SOLID
		trace = util.TraceEntity( tr, self.Owner )
		
		if ( trace.Hit && IsValid( trace.Entity ) ) then
			
			local te = trace.Entity
			
			if( te:IsVehicle() || te:IsNPC() || te:IsPlayer() || te.HealthVal ) then
				
				self.Owner:PrintMessage( HUD_PRINTCENTER, "LOCKED ON" )
				self.Target = te
				self:SetNetworkedEntity( "Target", te )
				//self:EmitSound( "LockOn/Lock.mp3", 511, 100 )
				
				return
				
			end
		
		end
	
	end
	

	
	if( self.Owner:KeyPressed( IN_USE ) && self.LastRelease + 0.5 <= CurTime() ) then
		
		if( IsValid( self.Target ) ) then
		
			self.Target = NULL
			self:SetNetworkedEntity("Target", NULL )
			self.LastRelease = CurTime()
			self.Owner:PrintMessage( HUD_PRINTCENTER, "TARGET CLEARED" )
		
		end
		
	end
	
	if( NEUROPLANES_CINEMATIC_ROCKET && !IsValid( self.Missile ) && self.Launched == true ) then

		self.Owner:UnSpectate()
		self.Owner:DrawViewModel( true )
		self.Owner:DrawWorldModel( true )
		self.Launched = false
		local a = self.Owner:EyeAngles()
		self.Owner:SetEyeAngles( Angle( a.p,a.y,0 ) )
		self.Owner:SetNetworkedBool("DrawTracker", false ) 
	
	elseif( NEUROPLANES_CINEMATIC_ROCKET && IsValid( self.Missile ) ) then
		
		if ( self.Owner:KeyDown( IN_SPEED ) ) then 

			self.Missile = NULL
			
		end
		
		//self.Owner:SetEyeAngles( LerpAngle( 0.1, ( self.Owner:GetPos() - self.Missile:GetPos()):Normalize():Angle() ), self.Owner:EyeAngles() )
		//self.Owner:SetEyeAngles( LerpAngle( 0.01, self.Missile:GetAngles(), self.Owner:EyeAngles() ) )
	
	end
	
end


function SWEP:LaunchRocket()
	
	if( !self.Target ) then
		
		self.Owner:PrintMessage( HUD_PRINTCENTER, "NO TARGET - BLIND FIRE" )
		
	end

	self.Missile = ents.Create("sent_a2a_jericho")
	self.Missile:SetPos( self.Owner:GetShootPos() )
	self.Missile:SetAngles( self.Owner:GetAimVector():Angle() )
	self.Missile:SetModel( "models/BF2/weapons/Predator/predator_rocket.mdl" )
	self.Missile.Target = self.Target
	self.Missile:SetOwner( self.Owner )
	self.Missile.Owner = self.Owner
	self.Missile:SetPhysicsAttacker( self.Owner )
	self.Missile:Spawn()
	self.Missile:EmitSound("LockOn/MissileLaunchEngine.mp3",511,100)
			
	local sm = EffectData()
	sm:SetStart( self.Owner:GetShootPos() )
	sm:SetOrigin( self.Owner:GetShootPos() )
	sm:SetScale( 6.5 )
	util.Effect( "A10_muzzlesmoke", sm )
	
	if( NEUROPLANES_CINEMATIC_ROCKET ) then
		
		self.Owner:Spectate( OBS_MODE_IN_EYE )
		self.Owner:SpectateEntity( self.Missile )	
		self.Owner:DrawViewModel( false )
		self.Launched = true
		self.Owner:PrintMessage( HUD_PRINTCENTER, "Press Shift to exit" )
		self.Owner:SetNetworkedBool("DrawTracker", true ) 
		//self.Owner:SendLua("EnableCinematicRocketShit()")

	end
	
end

/*---------------------------------------------------------
	PrimaryAttack
---------------------------------------------------------*/
function SWEP:PrimaryAttack()
	
	self.Weapon:SetNextSecondaryFire( CurTime() + self.Primary.Delay )
	self.Weapon:SetNextPrimaryFire( CurTime() + self.Primary.Delay )
	
	if ( !self:CanPrimaryAttack() ) then return end
	
	if (SERVER ) then
	
		self.Weapon:EmitSound( self.Primary.Sound )
		self:TakePrimaryAmmo( 1 )
	
		self:LaunchRocket()
		self:ShootEffects() 

		
		if( IsValid( self.Target ) ) then
		
			self.Target = NULL
			self:SetNetworkedEntity( "Target", NULL )
			self.LastRelease = CurTime()
			self.Owner:PrintMessage( HUD_PRINTCENTER, "TARGET CLEARED" )
		
		end
		
	end
	
	if ( self.Owner:IsNPC() ) then return end
	
	self.Owner:ViewPunch( Angle( math.Rand(-3.2,-1.1), math.Rand(-3.1,-1.1), 0 ) )
	
	if ( (SinglePlayer() && SERVER) || CLIENT ) then
	
		self.Weapon:SetNetworkedFloat( "LastShootTime", CurTime() )
		
	end
	
end


function SWEP:OnRestore()

	self.NextSecondaryAttack = 0
	
end
--local targetMat = Material("JetCH/aim")
function SWEP:DrawHUD()
	
	if( self.Owner:GetNetworkedBool("DrawTracker", false ) ) then return end
	
	local tr, trace = {},{}
	tr.start =  self.Owner:GetShootPos() + self.Owner:GetForward() * 100 + self.Owner:GetUp() * 16
	tr.endpos = self.Owner:GetAimVector() * 8000
	tr.filter = { self, self.Owner }
	tr.mask = MASK_SOLID
	trace = util.TraceEntity( tr, self.Owner )
	local sizex,sizey = 100,70
	local x,y = ScrW()/2, ScrH()/2
	
	surface.SetDrawColor( 255, 255, 255, 220 )
	surface.DrawOutlinedRect( x - sizex / 2, y - sizey / 2, sizex, sizey )
	surface.DrawLine( x - sizex, y, x - sizex/2, y )
	surface.DrawLine( x + sizex, y, x + sizex/2, y )
	surface.DrawLine( x, y - sizey/2, x, y - sizey )
	surface.DrawLine( x, y + sizey/2, x, y + sizey )
	
	if( !trace.Hit ) then
		
		draw.SimpleText("OUT OF RANGE", "HudHintTextLarge", ScrW() / 2, ScrH() / 2, Color( 255, 255, 255, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
	
	else
	
		surface.DrawOutlinedRect( x - 30, y - 20, 60, 40 )
		
	end

	local target = self:GetNetworkedEntity("Target", NULL )
	
	for k,v in pairs( ents.FindByClass( "sent*" ) ) do
			
		if ( IsValid( v ) && v.PrintName && ( v.Type == "vehicle" || ( v.PrintName == "Missile" ) ) ) then
			
			local pos = v:GetPos():ToScreen( )
			local x,y = pos.x, pos.y
		
			if( v.PrintName == "Missile" ) then
	
				--surface.DrawTexturedRect( x - size / 2, y - size / 2, size, size )
				//draw.SimpleText( "Missile", "ChatFont", x, y, Color( 255, 40, 0, 200 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
			
			else
			
				draw.SimpleText( v.PrintName, "ChatFont", x, y - 35, Color( 255, 102, 0, 240 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
			
			end
	
			
			if ( target != NULL && v == target ) then
				
				draw.SimpleText( "Locked On", "ChatFont", x, y, Color( 255, 0, 0, 240 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
				
			end
			
		end
	
	end
	
	for k,v in pairs( ents.FindByClass( "npc*" ) ) do
		
		local pos = v:GetPos( ):ToScreen( )
		local x,y = pos.x, pos.y
		
		if ( !v:OnGround() ) then
		
			draw.SimpleText( "Valid Target", "ChatFont", x, y - 35, Color( 255, 102, 0, 240 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
			
			--surface.SetMaterial( targetMat )
			--surface.DrawTexturedRect( x - size / 2, y - size / 2, size, size )
		
		end
		
		if ( target && v == target ) then
				
			draw.SimpleText( "Locked On", "ChatFont", x, y, Color( 255, 0, 0, 240 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
				
		end
		
	end
		
end

