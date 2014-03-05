
if (SERVER) then

	AddCSLuaFile( "shared.lua" )
	SWEP.Weight				= 1
	SWEP.AutoSwitchTo		= false
	SWEP.AutoSwitchFrom		= false

end

if ( CLIENT ) then

	SWEP.DrawAmmo			= false
	SWEP.DrawCrosshair		= true
	SWEP.ViewModelFOV		= 62
	SWEP.ViewModelFlip		= false
	SWEP.CSMuzzleFlashes	= false

	SWEP.PrintName			= "Repair Tool"			
	SWEP.Author				= "Hoffa"
	SWEP.Category			= "NeuroTec Weapons"
	SWEP.Slot				= 1
	SWEP.SlotPos			= 1
	SWEP.IconLetter			= "b"
	
end

SWEP.Author			= "Hoffa/StarChick"
SWEP.Contact		= "Hoffa1337 @ Facepunch\nSluggomc @ Steam"
SWEP.Purpose		= ""
SWEP.Instructions	= "Aim at broken stuff"
SWEP.HoldType = "melee"

SWEP.Spawnable			= true
SWEP.AdminSpawnable		= true

SWEP.Primary.Sound			= Sound( "sounds/lockon/missilelaunch.mp3" )
SWEP.Primary.Recoil			= 1.5
SWEP.Primary.Delay			= 0.5

SWEP.Primary.ClipSize		= 1
SWEP.Primary.DefaultClip	= 1
SWEP.Primary.Automatic		= true
SWEP.Primary.Ammo			= "none"

SWEP.Secondary.ClipSize		= -1
SWEP.Secondary.DefaultClip	= -1
SWEP.Secondary.Automatic	= false
SWEP.Secondary.Ammo			= "none"

SWEP.ViewModel			= "models/wrepons/v_crowbar.mdl"
SWEP.WorldModel			= "models/wrepons/w_crowbar.mdl"

SWEP.Weight				= 1
SWEP.AutoSwitchTo		= true
SWEP.AutoSwitchFrom		= false

SWEP.Primary.Sound			= Sound( "LockOn/Shoot.mp3" )
SWEP.Primary.Automatic		= true
SWEP.Primary.Ammo			= "none"



/*---------------------------------------------------------
---------------------------------------------------------*/
function SWEP:Initialize()
	
	self.TimeIdx = 1
	self.LastTime = CurTime()
	self.Phrases = { "Transponding Hydroflux", "Adjusting Gyrospander", "Corelating QPUs", "Boosting Turbo", "Changing Oil", "Replacing spark plugs"}

	self:SetWeaponHoldType( self.HoldType )
	self.LastRelease = CurTime()
	-- if( SERVER ) then
		
		-- self.Hydrant = ents.Create("prop_physics") 
		-- self.Hydrant:SetModel( "models/props/cs_office/Fire_Extinguisher.mdl" )
		-- self.Hydrant:SetAngles( self:GetAngles() + Angle( 0,0,0 ) )
		-- self.Hydrant:Spawn()
		-- self.Hydrant:SetParent( self )
		
	
	-- end
	
	if( SERVER ) then
	
		self.ChargeSound = CreateSound( self, "weapons/gauss/chargeloop.wav" )
		self.LastUpdate = 0
		
	end
	
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

	-- if( self.Owner:KeyDown( IN_ATTACK ) ) then
	
		-- self.ChargeSound:PlayEx( 100, 100 )
		
	-- else
		
		-- self.ChargeSound:Stop()
	
	-- end
	
end

/*---------------------------------------------------------
	PrimaryAttack
---------------------------------------------------------*/
function SWEP:PrimaryAttack()
	
	if ( CLIENT ) then return end
	
	self.Weapon:SetNextSecondaryFire( CurTime() + self.Primary.Delay )
	self.Weapon:SetNextPrimaryFire( CurTime() + self.Primary.Delay )
	
	if ( !self:CanPrimaryAttack() ) then return end
	
	local tr,trace = {},{}
	tr.start = self.Owner:GetShootPos()
	tr.endpos = tr.start + self.Owner:GetAimVector() * 100
	-- tr.mask = MASK_SOLID
	tr.filter = { self, self.Owner }
	trace = util.TraceLine( tr )
	
	
	if( trace.Hit && IsValid( trace.Entity ) && trace.Entity.HealthVal != nil ) then
	self.Owner:EmitSound( "weapons/crowbar/crowbar_impact"..math.random(1,2)..".wav" )
	self.Weapon:SendWeaponAnim(ACT_VM_HITCENTER)
		
		local fx = EffectData()
		fx:SetOrigin( trace.HitPos )
		fx:SetStart( trace.HitPos )
		fx:SetScale( 0.4 )
		fx:SetNormal( trace.HitNormal )
		util.Effect( "inflator_magic", fx )		
		
	else
		self.Weapon:EmitSound("weapons/iceaxe/iceaxe_swing1.wav")
		self.Weapon:SendWeaponAnim(ACT_VM_HITCENTER)
	end
	self.Owner:SetAnimation( PLAYER_ATTACK1 )
		if (trace.Entity:IsNPC()) or (trace.Entity:IsPlayer()) then
			bullet = {}
			bullet.Num    = 1
			bullet.Src    = self.Owner:GetShootPos()
			bullet.Dir    = self.Owner:GetAimVector()
			bullet.Spread = Vector(0, 0, 0)
			bullet.Tracer = 0
			bullet.Force  = 5
			bullet.Damage = math.random(20,55)
			self.Owner:FireBullets(bullet)
		end
	
	if ( SERVER ) then
		
		if( trace.Hit && IsValid( trace.Entity ) && trace.Entity.HealthVal != nil ) then
			
			local a,b,c = trace.Entity, trace.Entity.HealthVal, trace.Entity.InitialHealth

			if( b == c ) then
				
				self.Owner:PrintMessage( HUD_PRINTCENTER, "Vehicle Repaired!" )
				
				return
				
			end
			
			if( c && !a.Destroyed || ( c && a:GetClass() == "tank_track_entity" ) ) then
					
				if( self.LastTime + 2 <= CurTime() ) then
					
					self.LastTime = CurTime()
					self.TimeIdx = self.TimeIdx + 1
					
					if( self.TimeIdx > #self.Phrases ) then
						
						self.TimeIdx = 1
						
					end
					
				end
				
				local txt = self.Phrases[self.TimeIdx]
				
				a.Burning = false
				a.HealthVal = math.Approach( b, c, 100 )
				a:SetNetworkedInt("health",a.HealthVal )
				a.OilLevel = 100
				a:SetNWFloat( "EngineOilLevel", 100 )
				a.GearBoxHealth = 500
				a.OilLeaking = false
				a.EngineHeat = 0
				a.OilPumpBroken = false
				
				for k,v in pairs( ents.FindInSphere( trace.HitPos, 128 )  ) do
					
					-- print( v:GetClass() )
						
						
					if( v:GetClass() == "env_fire_trail" ) then
						
						v:Remove()
						-- v:StopSounds()
					end
				
				end
				
				if(  a:GetClass() == "tank_track_entity" ) then
					
					txt = "Repairing Threads"
			
				end
				
				self.Owner:PrintMessage( HUD_PRINTCENTER, txt..": "..math.floor( a.HealthVal * 100 / c ).."%" )
				
				
			else
				
				
				self.Owner:PrintMessage( HUD_PRINTCENTER, "This vehicle is too damaged" )
			
			end
			
			
		else

			self.Owner:PrintMessage( HUD_PRINTCENTER, "Nothing to repair" )		
		
		end
		
	end
	
	-- if ( (SinglePlayer() && SERVER) || CLIENT ) then
	
		self.Weapon:SetNetworkedFloat( "LastShootTime", CurTime() )
		
	-- end
	
end

function SWEP:SecondaryAttack()
//Show a windows displaying all information about the vehicle.

end

function SWEP:Holster( wep )
	-- self.Weapon:SendWeaponAnim(ACT_VM_HOLSTER)		
	return true 
end

function SWEP:OnRestore()

	self.NextSecondaryAttack = 0
	
end

