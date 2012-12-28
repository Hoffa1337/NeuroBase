AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include('shared.lua')


ENT.PrintName = "M134 Minigun"
ENT.Model = "models/bf2/weapons/M134/M134.mdl"
ENT.InitialHealth = 3200
ENT.HealthVal = nil
ENT.Destroyed = false
ENT.Burning = false

function ENT:SpawnFunction( ply, tr)

	local SpawnPos = tr.HitPos + tr.HitNormal * 100
	local ent = ents.Create( "sent_m134_g" )
	ent:SetPos( SpawnPos )
	ent:Spawn()
	ent:Activate()
	ent.Pilot = ply
	
	return ent
	
end

function ENT:Initialize()
	
	self:SetModel( self.Model )	
	self:PhysicsInit( SOLID_VPHYSICS )
	self:SetMoveType( MOVETYPE_VPHYSICS )
	self:SetSolid( SOLID_VPHYSICS )
	self.HealthVal = self.InitialHealth
	
	self.LastShot = 0
	self.SpinVal = 0
	
	self.LoopSound = CreateSound( self, "sounds/A10_fart.mp3" )
	
	self.Barrel = ents.Create("prop_physics")
	self.Barrel:SetModel( "models/bf2/weapons/m134/m134_cannon.mdl" )
	self.Barrel:SetPos( self:LocalToWorld( Vector( 1.75, -6.2, 0 ) ) ) 
	self.Barrel:SetAngles( self:GetAngles() )
	self.Barrel:SetOwner( self )
	self.Barrel:Spawn()
	self.barrelaxis = constraint.Axis( self.Barrel, self, 0, 0, Vector( 0, 0, 0 ) , self.Barrel:GetPos(), 0, 0, 1, 0, Vector( 1, 0, 0 ) )
	
	self.BarrelPhys = self.Barrel:GetPhysicsObject()
	self.BarrelPhys:SetMass( 200 )
	
	self.MuzzlePoint = ents.Create("prop_physics")
	self.MuzzlePoint:SetPos( self:LocalToWorld( Vector( -1, -6.2, 1.4 ) ) )
	self.MuzzlePoint:SetAngles( self:GetAngles() )
	self.MuzzlePoint:SetParent( self )
	self.MuzzlePoint:SetModel("models/Airboatgun.mdl")
	self.MuzzlePoint:Spawn()
	self.MuzzlePoint:SetNoDraw( true )
	
	self.PhysObj = self:GetPhysicsObject()
	
	if ( self.PhysObj:IsValid() ) then
	
		self.PhysObj:Wake()
		self.PhysObj:SetMass( 250 )
		self.PhysObj:EnableGravity( true )
		
	end

	
end


function ENT:OnTakeDamage(dmginfo)

	if ( self.Destroyed ) then
		
		return

	end
	
	self:TakePhysicsDamage(dmginfo)
	
	self.HealthVal = self.HealthVal - dmginfo:GetDamage()
	self:SetNetworkedInt("health",self.HealthVal)

	if ( self.HealthVal < 1 ) then
	
		self.Destroyed = true

	end
	
end

function ENT:OnRemove()
	
	self.Barrel:Remove()
	
end

function ENT:PhysicsCollide( data, physobj )
	
end

function ENT:DefaultAttack()

	if ( !IsValid( self.Pilot ) ) then
		
		return
		
	end
	
	local bullet = {} 
 	bullet.Num 		= 1
 	bullet.Src 		= self.Barrel:GetPos() + self.Barrel:GetForward() * 45 + self:GetUp() * 4 + self:GetRight() * 8
 	bullet.Dir 		= self.Barrel:GetForward()
 	bullet.Spread 	= Vector( .02, .023, .014 )
 	bullet.Tracer	= 1															// Show a tracer on every x bullets  
 	bullet.Force	= 50					 									// Amount of force to give to phys objects 
 	bullet.Damage	= 0
 	bullet.AmmoType = "Ar2" 
 	bullet.TracerName 	= "AirboatGunHeavyTracer"
	bullet.Attacker = self.Pilot
 	bullet.Callback    = function ( a, b, c )
								
							self:ExplosiveCallback( a, b, c )
							
						end 
	
	self:FireBullets( bullet )
	
	self:DefaultEffects()
	
end

function ENT:ExplosiveCallback( a, b, c )

	local e = EffectData()
	e:SetOrigin(b.HitPos)
	e:SetNormal(b.HitNormal)
	e:SetScale( 4.5 )
	util.Effect("ManhackSparks", e)

	util.BlastDamage( self.Pilot, self.Pilot, b.HitPos, 100, math.random( 4, 64 ) )

	return { damage = true, effects = DoDefaultEffect } 	
	
end

function ENT:Think()
	
	if( IsValid( self.Pilot ) && self.Pilot:IsPlayer() ) then
		
		local pd = self.Pilot:GetPos():Distance( self:GetPos() )
			
		self.Pilot:DrawViewModel( pd > 90 )
		
		if( self.Pilot:KeyDown( IN_ATTACK ) && pd < 90 ) then
			
			self.SpinVal = math.Approach( self.SpinVal, 30, 1 )
			
			self:SetAngles( LerpAngle( 0.1, self:GetAngles(), self.Pilot:EyeAngles() ) )
			
			if( self.SpinVal >= 30 ) then
				
				self.SpinVal = 30
				
				if( self.LastShot + 0.105 <= CurTime() ) then

					self.LastShot = CurTime()
					self:DefaultAttack()
					
				end
				
			
			end
		
		else
		
			self.SpinVal = math.Approach( self.SpinVal, 0, 1 )
		
		end
		
		if( self.SpinVal > 0 && self.SpinVal < 50 ) then
			
			self:EmitSound("LockOn/TurretRotation.mp3",511, self.SpinVal*4 )
			self.BarrelPhys:AddAngleVelocity( Vector( -self.SpinVal, 0, 0 ) )
	
		end
		
	else
	
		self.Pilot = self
		
	end
	
	if( DEBUG ) then
		-- Debug
		if( self.LastShot + 0.105 <= CurTime() ) then
		
			self:DefaultEffects()
			self.LastShot = CurTime()

		end
		
	end
	
	if ( self.Destroyed ) then 
		
		return
		
	end
	
	self:NextThink( CurTime() )
		
	return true
	
end

function ENT:DefaultEffects()

	local fx = EffectData()
	fx:SetOrigin( self.MuzzlePoint:GetPos() )
	fx:SetEntity( self.MuzzlePoint )
	fx:SetAttachment( 1 )
	fx:SetScale( 2.1 )
	util.Effect("AirboatMuzzleFlash", fx ) 
	
	fx = EffectData()
	fx:SetOrigin( self.MuzzlePoint:GetPos() )
	fx:SetEntity( self.MuzzlePoint )
	fx:SetAttachment( 1 )
	fx:SetScale( 2.1 )
	util.Effect("A10_muzzlesmoke", fx )
	
	fx = EffectData()
	fx:SetOrigin( self:LocalToWorld( Vector( -1, -16, -6.2 ) ) )
	fx:SetNormal( self:GetRight() + self:GetUp() * -1 )
	fx:SetAngles( self:GetRight():GetNormalized():Angle() + Angle( 23, 0, 0 ) )
	util.Effect("RifleShellEject", fx )

	
	self:EmitSound("minigun_shoot.wav", 511, 100 )
	
end