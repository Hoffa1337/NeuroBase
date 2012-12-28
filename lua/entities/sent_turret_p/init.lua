
AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include('shared.lua')

ENT.PrintName	= "Turret"
ENT.Model = "models/FSX/Warbirds/b-17 flying fortress_turret_top.mdl"

// Speed Limits
ENT.MaxVelocity = 0
ENT.MinVelocity = 0

ENT.InitialHealth = 1000
ENT.HealthVal = nil

ENT.Destroyed = false
ENT.Burning = false
ENT.Speed = 0
ENT.DeathTimer = 0

// Weapons
ENT.MaxDamage = 500
ENT.MinDamage = 100
ENT.BlastRadius = 256

// Timers
ENT.LastPrimaryAttack = nil
ENT.LastSecondaryAttack = nil
ENT.LastFireModeChange = nil
ENT.CrosshairOffset = 0
ENT.PrimaryCooldown = 200
ENT.BulletDelay = CurTime()
ENT.ShellDelay = CurTime()

function ENT:SpawnFunction( ply, tr)

	local SpawnPos = tr.HitPos + tr.HitNormal * 75
	local vec = ply:GetAimVector():Angle()
	local newAng = Angle(0,vec.y + 180,0)
	local ent = ents.Create( "sent_turret_p" )
	ent:SetPos( SpawnPos )
	ent:SetAngles( newAng )
	ent:Spawn()
	ent:Activate()
	
	return ent
	
end

function ENT:Initialize()
	
	self.HealthVal = self.InitialHealth
	self:SetNetworkedInt("health",self.HealthVal)
	
	// Misc
	if ( self:GetModel() ) then		
		self:SetModel( self:GetModel() )		
	else	
		self:SetModel( self.Model )		
	end

	self:PhysicsInit( SOLID_VPHYSICS )
	self:SetMoveType( MOVETYPE_VPHYSICS )
	self:SetSolid( SOLID_VPHYSICS )

	// Sound
	local esound = {}
	self.EngineMux = {}
	esound[1] = "LockOn/TurretRotation.mp3"
--	esound[2] = "physics/cardboard/cardboard_box_scrape_smooth_loop1.wav"
--	esound[3] = "ambient/levels/canals/dam_water_loop2.wav"
	
	for i=1, #esound do
	
		self.EngineMux[i] = CreateSound( self, esound[i] )
		
	end
	
	self.Pitch = 80
	self.EngineMux[1]:PlayEx( 500 , self.Pitch )
--	self.EngineMux[2]:PlayEx( 500 , self.Pitch )
--	self.EngineMux[3]:PlayEx( 500 , self.Pitch )
	
	self:SetUseType( SIMPLE_USE )
	self.IsDriving = false
	self.Pilot = nil
	
	self.Cannon = ents.Create("prop_physics_override")
	local CannonMdl = self:GetNetworkedString( "CannonMdl" )	//Get the gun model from the entity

/*	if ( CannonMdl ) then		
		self.Cannon:SetModel( CannonMdl )		
	else	
		self.Cannon:SetModel( "models/fsx/warbirds/b-17 flying fortress_turret_top.mdl" )		
	end
*/
//	self.Cannon:SetModel( CannonMdl )		
	self.Cannon:SetModel( "models/fsx/warbirds/b-17 flying fortress_turret_top_gun.mdl" )		
	self.Cannon:SetPos( self:GetPos() + self:GetForward() * 1 + self:GetUp() * 6 )
	self.Cannon:SetParent( self )
	self.Cannon:SetSkin( self:GetSkin() )
	self.Cannon:SetAngles( self:GetAngles() )
	self.Cannon:Spawn()
	self.CannonPhys = self.Cannon:GetPhysicsObject()	
	if ( self.CannonPhys:IsValid() ) then
	
		self.CannonPhys:Wake()
		self.CannonPhys:EnableGravity( true )
		//self.CannonPhys:EnableDrag( true )
		
	end
	
	-- Hackfix until garry implements GetPhysicsObjectNum/Count on the client.	
	local CannonPropPos = Vector( 40, 7, 5 )
	self.CannonProp = ents.Create("prop_physics_override")
	self.CannonProp:SetPos( self:LocalToWorld( CannonPropPos ) )
	self.CannonProp:SetAngles( self:GetAngles()  ) --+ Angle( 0, -90, 0 )
	self.CannonProp:SetModel( "models/items/ar2_grenade.mdl" )
	self.CannonProp:SetParent( self.Cannon )
	self.CannonProp:Spawn()

	local CannonProp2Pos = Vector( 40, -7, 5)
	self.CannonProp2 = ents.Create("prop_physics_override")
	self.CannonProp2:SetPos( self:LocalToWorld( CannonProp2Pos ) )
	self.CannonProp2:SetAngles( self:GetAngles()  )
	self.CannonProp2:SetModel( "models/items/ar2_grenade.mdl" )
	self.CannonProp2:SetParent( self.Cannon )
	self.CannonProp2:Spawn()
	
	constraint.NoCollide( self.Cannon, self, 0, 0 )
	
	self.PhysObj = self:GetPhysicsObject()
	
	if ( self.PhysObj:IsValid() ) then
	
		self.PhysObj:Wake()
		self.PhysObj:SetMass( 10000 )
		
	end

	self:StartMotionController()

end

function ENT:OnTakeDamage(dmginfo)

	if ( self.Destroyed ) then
		
		return

	end
	
	if( IsValid( self.Pilot ) ) then
	
		self.Pilot:ViewPunch( Angle( math.random(-2,2),math.random(-2,2),math.random(-2,2) ) )
	
	end
	
	self:TakePhysicsDamage(dmginfo)
	
	self.HealthVal = self.HealthVal - dmginfo:GetDamage()
	self:SetNetworkedInt("health",self.HealthVal)
		
	if ( self.HealthVal < 5 ) then
	
		self.Destroyed = true
		self.PhysObj:EnableGravity(true)
		self.PhysObj:EnableDrag(true)
		self.PhysObj:SetMass(2000)
		self:Ignite(60,100)
		
	end
	
end

function ENT:OnRemove()

/*	for i=1,3 do
	
		self.EngineMux[i]:Stop()
		
	end
*/		self.EngineMux[1]:Stop()
	
	if ( IsValid( self.Pilot ) ) then
	
		self:EjectPilotSpecialSpecial()
	
	end
	self.CannonProp:Remove()
	
end

function ENT:PhysicsCollide( data, physobj )

	if ( data.Speed > self.MaxVelocity * 0.8 && data.DeltaTime > 0.2 ) then 
		
		--self:SetNetworkedInt("health",self.HealthVal)
		
	end
	
end

function ENT:Use(ply,caller)

	if ( !self.IsDriving && !IsValid( self.Pilot ) ) then 

		self:GetPhysicsObject():Wake()
		self:GetPhysicsObject():EnableMotion(true)
		self.IsDriving = true
		self.Pilot = ply
		self.Owner = ply
		
		ply:Spectate( OBS_MODE_CHASE  )
		ply:DrawViewModel( false )
		ply:DrawWorldModel( false )
		ply:StripWeapons()
		ply:SetScriptedVehicle( self )
		
		ply:SetNetworkedBool("InFlight",true)
		ply:SetNetworkedEntity( "Turret", self )
		ply:SetNetworkedEntity( "Cannon", self.CannonProp )
		self:SetNetworkedEntity("Pilot", ply )
		self.LastUse = CurTime() + 1
		self:NextThink(CurTime() + 1 )
		
	end
	
end

function ENT:EjectPilotSpecialSpecial()
	
	if ( !IsValid( self.Pilot ) ) then 
	
		return
		
	end
	
	self.Pilot:UnSpectate()
	self.Pilot:DrawViewModel( true )
	self.Pilot:DrawWorldModel( true )
	self.Pilot:Spawn()
	self.Pilot:SetNetworkedBool( "InFlight", false )
	self.Pilot:SetNetworkedEntity( "Turret", NULL ) 
	self.Pilot:SetNetworkedEntity( "Barrel", NULL )
	self:SetNetworkedEntity("Pilot", NULL )
	
	self.Pilot:SetPos( self:GetPos() + self:GetUp() * 100 )
	self.Pilot:SetAngles( Angle( 0, self:GetAngles().y,0 ) )
	self.Owner = NULL
	self.Pilot:SetScriptedVehicle( NULL )
	
	self.Speed = 0
	self.IsDriving = false
	self:SetLocalVelocity(Vector(0,0,0))
	self.Pilot = NULL
	
end

function ENT:Think()

	self.Cannon:SetSkin( self:GetSkin() )
	
/*	self.Pitch = math.Clamp( math.floor( self:GetVelocity():Length() / 20 + 40 ),0,245 )

	for i = 1,3 do
	
		self.EngineMux[i]:ChangePitch( self.Pitch )
		
	end
*/	
	if ( self.Destroyed ) then 
		
		local effectdata = EffectData()
		effectdata:SetOrigin( self:GetPos() + self:GetRight() * math.random(-62,62) + self:GetForward() * math.random(-62,62)  )
		util.Effect( "immolate", effectdata )
		self.DeathTimer = self.DeathTimer + 1
		
		if self.DeathTimer > 35 then
		
			self:EjectPilotSpecialSpecial()
			self:Remove()
		
		end
		
	end
	
	
	
	if ( self.IsDriving && IsValid( self.Pilot ) ) then
		
		self.Pilot:SetPos( self:GetPos() + self:GetUp() * 82 )
			
		if( self.Pilot:KeyDown( IN_USE ) && self.LastUse + 0.5 > CurTime() ) then
				self:EjectPilotSpecialSpecial()			
			return			
		end
		
		// Ejection Situations.
		if ( self:WaterLevel() > 2 ) then		
			self:EjectPilotSpecialSpecial()			
		end

		// Attack
		if ( self.Pilot:KeyDown( IN_ATTACK ) ) then
					self:PrimaryAttack()
		end

		if ( self.Pilot:KeyDown( IN_ATTACK2 ) ) then
					self:SecondaryAttack()			
		end
		
	end
		
	self:NextThink( CurTime() )
	return true
	
end

function ENT:PrimaryAttack()
	if ( !self ) then // silly timer errors.
		
		return
		
	end

	local bullet = {} 
	bullet.Num 		= 1 
	bullet.Src 		= self.Cannon:GetPos() + self.Cannon:GetForward() * 40 + self.Cannon:GetRight() * 7 + self.Cannon:GetUp() * 6
	bullet.Dir 		= self.CannonProp:GetAngles():Forward()
	bullet.Attacker = self
	bullet.Spread 	= Vector( 0.05, 0.05, 0.05 )
	bullet.Tracer	= 1
	bullet.Force	= 5
	bullet.Damage	= math.random( 5, 25 )
	bullet.AmmoType = "smg1"
	bullet.TracerName 	= "Tracer"
	bullet.Callback    = function ( a, b, c ) self:MountedGunCallback( a, b, c ) end 

	if ( self.ShellDelay < CurTime() ) then				
	
		self.ShellDelay = CurTime() + 0.1
		self.CannonProp:FireBullets( bullet )
		self.CannonProp2:FireBullets( bullet )

		self:EmitSound( "BF2/Weapons/Type85_fire.mp3", 511, math.random( 70, 100 ) )
		local shell = {}
		local e = {}

		for i= 1, 2 do
		shell[i] = EffectData()
		shell[i]:SetStart( self.Cannon:GetPos() + self.Cannon:GetForward() * -4 + self.Cannon:GetRight() * 8*( 2*i-3 ) + self.Cannon:GetUp() * 7)
		shell[i]:SetOrigin( self.Cannon:GetPos() + self.Cannon:GetForward() * -4 + self.Cannon:GetRight() * 8*( 2*i-3 )+ self.Cannon:GetUp() * 7)
		util.Effect( "RifleShellEject", shell[i] ) 

		e[i] = EffectData()
		e[i]:SetStart( self.CannonProp:GetPos()  + self.Cannon:GetRight() * 14*( i-1 ) + self.Cannon:GetUp() * 1)
		e[i]:SetOrigin( self.CannonProp:GetPos() + self.Cannon:GetRight() * 14*( i-1 )+ self.Cannon:GetUp() * 1)
		e[i]:SetAngles( self.Cannon:GetAngles() )
		e[i]:SetEntity( self.Cannon )
		e[i]:SetScale( 0.75 )
		util.Effect( "MuzzleEffect", e[i] )

		end
			
	self:StopSound( "BF2/Weapons/Type85_fire.mp3" )
--	self:StopSound( "Weapon_AR2.Single" )
	end

end

function ENT:ExplosiveShellCallback(a,b,c)

	local info = DamageInfo( )  
		info:SetDamageType( DMG_NEVERGIB )  
		info:SetDamagePosition( b.HitPos )  
		info:SetMaxDamage( self.MaxDamage )  
		info:SetDamage( self.MinDamage )  
		info:SetAttacker( self )  
		info:SetInflictor( self )  
	
	local e = EffectData()
		e:SetOrigin( b.HitPos )
		e:SetScale( 0.1 )
		e:SetNormal( b.HitNormal )
	util.Effect("HelicopterMegaBomb", e)
		e:SetScale( 1.2 )
	util.Effect("ImpactGunship", e)
	
	for k, v in ipairs( ents.GetAll( ) ) do  
		
		if ( IsValid( v ) && v:Health( ) > 0 ) then  
			
			local p = v:GetPos( )  
			local t,tr = {},{}
				t.start = b.HitPos
				t.endpos = p
				t.mask = MASK_BLOCKLOS 
				t.filter = self
			tr = util.TraceLine( t )
			
			if ( p:Distance( b.HitPos ) <= self.BlastRadius ) then  
			
				if ( tr.Hit && tr.Entity ) then
				
					info:SetDamage( self.Damage * ( 1 - p:Distance( b.HitPos ) / self.BlastRadius ) )  
					info:SetDamageForce( ( p - b.HitPos ):GetNormalized( ) * 10 )  
					v:TakeDamageInfo( info )  
					
				end
				
			end 
			
		end  

	end  
	
	return { damage = true, effects = DoDefaultEffect } 
	
end

function ENT:SecondaryAttack()
	
	if ( !self ) then // silly timer errors.
		
		return
		
	end

	local bullet2 = {} 
	bullet2.Num 		= 1 
	bullet2.Src 		= self.Cannon:GetPos() + self.Cannon:GetForward() * 40 + self.Cannon:GetRight() * -7 + self.Cannon:GetUp() * 6
	bullet2.Dir 		= self.Cannon:GetAngles():Forward()
	bullet2.Attacker = self
	bullet2.Spread 	= Vector( 0.05, 0.05, 0.05 )
	bullet2.Tracer	= 1
	bullet2.Force	= 5
	bullet2.Damage	= math.random( 50, 125 )
	bullet2.AmmoType = "Ar2"
	bullet2.TracerName 	= "AR2Tracer"
	bullet2.Callback    = function ( a, b, c ) self:MountedGunCallback( a, b, c ) end 

	if ( self.ShellDelay < CurTime() ) then				
	
		self.ShellDelay = CurTime() + 0.5
		self.CannonProp:FireBullets( bullet2 )
		self.CannonProp2:FireBullets( bullet2 )
		self:EmitSound( "IL-2/gun_17_22.mp3", 511, math.random( 70, 100 ) )

		local shell2 = EffectData()
		shell2:SetStart( self.Cannon:GetPos() + self.Cannon:GetForward() * -4 + self.Cannon:GetRight() * 2 + self.Cannon:GetUp() * 8)
		shell2:SetOrigin( self.Cannon:GetPos() + self.Cannon:GetForward() * -4 + self.Cannon:GetRight() * 2 + self.Cannon:GetUp() * 8)
		shell2:SetOrigin( self.Cannon:GetPos() + self.Cannon:GetForward() * -4 + self.Cannon:GetRight() * 2 + self.Cannon:GetUp() * 8)
		util.Effect( "RifleShellEject", shell2 ) 

		local shell2 = EffectData()
		shell2:SetStart( self.Cannon:GetPos() + self.Cannon:GetForward() * -4 + self.Cannon:GetRight() * -4 + self.Cannon:GetUp() * 8)
		shell2:SetOrigin( self.Cannon:GetPos() + self.Cannon:GetForward() * -4 + self.Cannon:GetRight() * -4+ self.Cannon:GetUp() * 8)
		shell2:SetOrigin( self.Cannon:GetPos() + self.Cannon:GetForward() * -4 + self.Cannon:GetRight() * -4+ self.Cannon:GetUp() * 8)
		util.Effect( "RifleShellEject", shell2 ) 
		
		local e2 = EffectData()
		e2:SetStart( self.CannonProp2:GetPos() )
		e2:SetOrigin( self.CannonProp2:GetPos() )
		e2:SetAngles( self.CannonProp2:GetAngles() )
		e2:SetEntity( self.CannonProp2 )
		e2:SetScale( 1.5 )
		util.Effect( "MuzzleEffect", e2 )

		local e2 = EffectData()
		e2:SetStart( self.CannonProp:GetPos() )
		e2:SetOrigin( self.CannonProp:GetPos() )
		e2:SetAngles( self.CannonProp:GetAngles() )
		e2:SetEntity( self.CannonProp )
		e2:SetScale( 1.5 )
		util.Effect( "MuzzleEffect", e2 )
			
	self:StopSound( "BF2/Weapons/Type85_fire.mp3" )
--	self:StopSound( "Weapon_AR2.Single" )
	end
	
end

function ENT:MountedGunCallback( a, b, c )

	if ( IsValid( self.Weapon ) ) then
	
		local e = EffectData()
		e:SetOrigin(b.HitPos)
		e:SetNormal(b.HitNormal)
		e:SetScale( 2.0 )
		util.Effect("ManhackSparks", e)

		util.BlastDamage( self.Weapon, self.Weapon, b.HitPos, 100, math.random(15,19) )
		
	end
	
	return { damage = true, effects = DoDefaultEffect } 	
	
end

local function apr(a,b,c)
	local z = math.AngleDifference( b, a )
	return math.Approach( a, a + z, c )
end

function ENT:PhysicsUpdate()

	if ( self.IsDriving && self.Pilot ) then

		self:GetPhysicsObject():Wake()
		
		local a = self.Pilot:GetPos() + self.Pilot:GetAimVector() * 3000 // This is the point the plane is chasing.
		
		local ta = ( self:GetPos() - a ):Angle()
		local ma = self:GetAngles()
		local brlang = self.Cannon:GetAngles()

		local pilotAng = self.Pilot:EyeAngles()
--		local _v = pilotAng
--		local _e = self:GetAngles()
--		local _d = self:GetAngles()
		local _t = self:GetAngles()
		local _b = self.Cannon:GetAngles()
		local Cannonpitch = math.Clamp( pilotAng.p, -35, 35 )

--		_t.p, _t.y, _t.r = apr( _t.p, _e.p, 40.5 ),apr( _t.y, pilotAng.y, 40.5 ),apr( _t.r, _e.r, 40.5 )
--		_d.p, _d.y, _d.r = apr( _d.p, _t.p, 40.5 ),apr( _d.y, _t.y, 40.5 ),apr( _d.r, _t.r, 40.5 )
--		_d.p = 2 * _v.y		
--		self:SetAngles( _d )

		self:SetAngles( LerpAngle( 0.05, _t, Angle( _t.p, pilotAng.y, _t.r ) ) )
		self.Cannon:SetAngles( LerpAngle( 0.8, _b, Angle( Cannonpitch, _t.y, _t.r ) ) ) 

		self.offs = self:VecAngD( ma.y, ta.y )
		self.boffs = self:VecAngD( brlang.p, ta.p )
		local angg = self:GetAngles()

		angg:RotateAroundAxis( self:GetUp(), -self.offs + 180 )
		--print( "Tower: "..self.offs )
		--print( "Cannon: "..self.boffs )
		--print( "Cannon: "..brlang.p )
		
		/*if ( !self.Pilot:KeyDown( IN_JUMP ) ) then
		
			if ( self.offs < 175 && self.offs > 0 ) then
				
				self:AddAngleVelocity( Angle(0,0,5) )
			
			elseif( self.offs > -175 && self.offs < 0 ) then
				
				self:AddAngleVelocity( Angle(0,0,-5) )
				
			elseif( self.offs > 177 || self.offs < -177 ) then
			
				self:SetVelocity( self:GetVelocity() / 1000 )
				
			end
			
		else
		
			self:SetVelocity( self:GetVelocity() / 1.05 )
			
		end*/
		
		local tankAng = self:GetAngles()
		
		
		//self:SetAngles( Angle( tankAng.p, pilotAng.y, tankAng.r ) )
		//self.Cannon:SetAngles( Angle( pilotAng.p / 1.5, pilotAng.y, tankAng.r ) )
	
	end
	
end

function ENT:PhysicsSimulate( phys, deltatime )
	
	if ( self.IsDriving && self.Pilot ) then
		phys:Wake()
	
		local dir = Angle( 0,0,0 )
		local p = { { Key = IN_FORWARD, Speed = 50 };
					{ Key = IN_BACK, Speed = -25 }; }
		local p2 = { { Key = IN_MOVELEFT, AngSpeed = 30 };
					 { Key = IN_MOVERIGHT, AngSpeed = -30 }; }
--[[		local p3 = { { Key = IN_SPEED, Speed = 256 };	//Boost
					 { Key = IN_JUMP, Speed = 0 }; }	//Handbreak
		local p4 = { { Key = IN_RELOAD, Speed = 256 };	//Change Warhead
					 { Key = IN_ZOOM, Speed = 0 }; }	//Change view
]]--		
		for k,v in ipairs( p ) do
			if ( self.Pilot:KeyDown( v.Key ) ) then
			
				self.Speed = self.Speed + v.Speed
	--			self:ApplyForceCenter( self:GetForward() * ( self.Speed * 1000 ) )
			end			
		end
		self.Speed = math.Clamp( self.Speed, self.MinVelocity, self.MaxVelocity )
		
--		self:GetPhysicsObject():SetVelocity( self:GetForward() * self.Speed )		
		
		
		for k,v in ipairs( p2 ) do
			
			if ( self.Pilot:KeyDown( v.Key ) ) then
				
				dir = Angle( 0, v.AngSpeed, 0 )
				
			end
		
		end
		
	
	local pr = {}
	pr.secondstoarrive	= 1
	pr.pos 				= self:GetPos() + self:GetForward() * self.Speed //+ Vector(0,0,-600)
	pr.maxangular		= 25
	pr.maxangulardamp	= 25
	pr.maxspeed			= 1000000
	pr.maxspeeddamp		= 10000
	pr.dampfactor		= 0.8
	pr.teleportdistance	= 10000
	pr.deltatime		= deltatime
	pr.angle = self:GetAngles() + dir
	
	phys:ComputeShadowControl(pr)
 
	end	
end


