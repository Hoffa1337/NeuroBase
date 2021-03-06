
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
	SWEP.CSMuzzleFlashes	= false

	SWEP.PrintName			= "Jericho Launcher"			
	SWEP.Author				= "Hoffa"
	SWEP.Slot				= 4
	SWEP.SlotPos			= 1
	SWEP.IconLetter			= "b"
	
end

SWEP.Author			= "Hoffa"
SWEP.Contact		= "Hoffa"
SWEP.Purpose		= "fuck shit up"
SWEP.Instructions	= "Aim away from face"
SWEP.HoldType = "rpg"
SWEP.Category = "NeuroTec Weapons"
SWEP.Spawnable			= true
SWEP.AdminSpawnable		= true
SWEP.AdminOnly = true 

SWEP.Primary.Sound			= Sound( "sounds/lockon/missilelaunch.mp3" )
SWEP.Primary.Recoil			= 1.5
SWEP.Primary.Delay			= 5

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
	
	self:SetWeaponHoldType( self.HoldType )
	self.LastRelease = CurTime()
	self.LastAttack = CurTime()
	
end


/*---------------------------------------------------------
	Reload does nothing
---------------------------------------------------------*/
function SWEP:Reload()

	self.Weapon:DefaultReload( ACT_VM_RELOAD );
	if( IsValid( self.Target ) ) then self.Target = NULL self:SetNetworkedEntity("Target",NULL) end
	
end


/*---------------------------------------------------------
   Think does nothing
---------------------------------------------------------*/
function SWEP:Think()

	if ( CLIENT ) then return end
	
	if( !IsValid( self.Target ) ) then 
	-- print("Walla")
		local tr, trace = {},{}
		tr.start =  self.Owner:GetShootPos() + self.Owner:GetAimVector() * 100
		tr.endpos = tr.start + self.Owner:GetAimVector() * 14000
		tr.filter = { self, self.Owner }
		tr.mask = MASK_SOLID
		trace = util.TraceEntity( tr, self.Owner )
		-- self:DrawLaserTracer( tr.start, trace.HitPos )
		
		if ( trace.Hit && IsValid( trace.Entity ) ) then
			
			local te = trace.Entity
			
			if( te:IsVehicle() || te:IsNPC() || te:IsPlayer() || te.HealthVal ) then
				
				-- self.Owner:PrintMessage( HUD_PRINTCENTER, "LOCKED ON" )
				self.Target = te
				self:SetNetworkedEntity( "Target", te )
				self.Owner:EmitSound( "LockOn/Lock.mp3", 511, 100 )
				
				return
				
			end
		
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
		
	end
	
end


function SWEP:LaunchRocket()
	
	self.Missile = ents.Create("sent_a2a_jericho")
	self.Missile:SetPos( self.Owner:GetShootPos() + self.Owner:GetRight()*18 + self.Owner:GetAimVector()*-16 + self.Owner:GetUp()*-2)
	self.Missile:SetAngles( self.Owner:GetAimVector():Angle() )
	self.Missile:SetModel( "models/BF2/weapons/Predator/predator_rocket.mdl" )
	self.Missile.Target = self.Target
	self.Missile:SetOwner( self.Owner )
	self.Missile.Owner = self.Owner
	self.Missile:SetPhysicsAttacker( self.Owner )
	self.Missile:Spawn()
	self.Missile:EmitSound("LockOn/MissileLaunchEngine.mp3",511,100)

	self.Owner:EmitSound( "LockOn/MissileLaunchEngine.mp3", 510, 100 )
	
	ParticleEffect("tank_muzzleflash",self.Owner:GetShootPos() + self.Owner:GetRight()*18 + self.Owner:GetAimVector()*-16 + self.Owner:GetUp()*-2 ,self.Owner:GetAngles()*-1,self)
	
	if( NEUROPLANES_CINEMATIC_ROCKET ) then
		
		self.Owner:Spectate( OBS_MODE_IN_EYE )
		self.Owner:SpectateEntity( self.Missile )	
		self.Owner:DrawViewModel( false )
		self.Launched = true
		self.Owner:PrintMessage( HUD_PRINTCENTER, "Press Shift to exit" )
		self.Owner:SetNetworkedBool("DrawTracker", true ) 

	end
	
	self:Reload()
	
end

/*---------------------------------------------------------
	PrimaryAttack
---------------------------------------------------------*/
function SWEP:PrimaryAttack()
	
	if( self.LastAttack + self.Primary.Delay > CurTime() ) then return false end
	
	if( IsValid( self.Target ) && self:GetPos():Distance( self.Target:GetPos() ) < 4000 ) then
		
		self.Owner:PrintMessage( HUD_PRINTCENTER, "You're too close to your target!" )
		
		return
		
	end
	
	self.LastAttack = CurTime()
	
	if( !IsValid( self.Target ) ) then
	
		local tr, trace = {},{}
		tr.start =  self.Owner:GetShootPos() + self.Owner:GetForward() * 100 + self.Owner:GetUp() * 16
		tr.endpos = tr.start + self.Owner:GetAimVector() * 14000
		tr.filter = { self, self.Owner }
		tr.mask = MASK_SOLID
		trace = util.TraceEntity( tr, self.Owner )
		
		if( !trace.Hit ) then
			
			self.Owner:EmitSound( "LockOn/Track.mp3", 511, 100 )
			
			return false
			
		end
		
		
			
	end
	
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
	
	if ( (game.SinglePlayer() && SERVER) || CLIENT ) then
	
		self.Weapon:SetNetworkedFloat( "LastShootTime", CurTime() )
		
	end
	
end


function SWEP:OnRestore()

	self.NextSecondaryAttack = 0
	
end

function SWEP:DrawHUD()
	
	if( self.Owner:GetNetworkedBool("DrawTracker", false ) ) then return end
	
	local tr, trace = {},{}
	tr.start =  self.Owner:GetShootPos() + self.Owner:GetForward() * 100 + self.Owner:GetUp() * 16
	tr.endpos = tr.start + self.Owner:GetAimVector() * 14000
	tr.filter = { self, self.Owner }
	tr.mask = MASK_SOLID
	trace = util.TraceEntity( tr, self.Owner )

	local target = self:GetNetworkedEntity("Target", NULL )

	local Col = Color( 0, 255, 0, 255 )
	if( IsValid( target ) ) then
				
		Col = Color( 255, 0, 0, 255 )
	
	end
	draw.SimpleText("[    ]", "HudHintTextLarge", ScrW() / 2, ScrH() / 2, Col, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )	


	if( !trace.Hit || trace.HitSky ) then

		draw.SimpleText("X", "HudHintTextLarge", ScrW() / 2, ScrH() / 2, Color( 255, 0, 0, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
	
	else
		
		draw.SimpleText("X", "HudHintTextLarge", ScrW() / 2, ScrH() / 2, Color( 0, 255, 0, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )

	end


	for k,v in pairs( ents.FindByClass( "sent*" ) ) do
			
		if ( IsValid( v ) && v.PrintName && ( v.Type == "vehicle" || ( v.PrintName == "Missile" ) ) ) then
			
			local pos = v:GetPos():ToScreen( )
			local x,y = pos.x, pos.y
		
			if ( target != nil && v == target ) then
				
				draw.SimpleText( "Locked On", "ChatFont", x, y, Color( 255, 0, 0, 240 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
			else
				
				draw.SimpleText( v.PrintName, "ChatFont", x, y - 35, Color( 255, 102, 0, 240 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )

			end
			
		end
	
	end
	
	for k,v in pairs( ents.FindByClass( "npc*" ) ) do
		
		local pos = v:GetPos( ):ToScreen( )
		local x,y = pos.x, pos.y
		
		if ( !v:OnGround() && v:GetPos().z > self:GetPos().z+128) then
			
			if ( target && v == target ) then
				
				draw.SimpleText( "LOCKED", "ChatFont", x, y, Color( 255, 0, 0, 240 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
				
			else
			
				draw.SimpleText( "Valid Target", "ChatFont", x, y, Color( 255, 102, 0, 240 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
			
			end
			
		end
		
	end
		
end

