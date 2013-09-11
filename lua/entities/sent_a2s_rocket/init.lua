AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include( 'shared.lua' )

ENT.Sauce = 900
ENT.Delay = 0
ENT.Speed = 5000

function ENT:Initialize()
	
	self.seed = math.random( 0, 1000 )
	
	self:SetModel( "models/hawx/weapons/zuni mk16.mdl" )
	self:PhysicsInit( SOLID_VPHYSICS )
	self:SetMoveType( MOVETYPE_VPHYSICS )	
	self:SetSolid( SOLID_VPHYSICS )
	self.flip = false
	
	-- self.Owner = self:GetOwner().Owner or self // lolol
	
	self.PhysObj = self:GetPhysicsObject() 
	if ( self.PhysObj:IsValid() ) then
	
		self.PhysObj:Wake()
	
	end
	
	util.PrecacheSound("Missile.Accelerate")
		
	local smoketrail = ents.Create("env_rockettrail")
	smoketrail:SetPos( self:GetPos() + self:GetForward() * -5 )
	smoketrail:SetParent( self )
	smoketrail:SetLocalAngles( Angle( 0, 0, 0 ) )
	smoketrail:Spawn()
	
	util.SpriteTrail(self, 0, Color(255,255,255,math.random(200,240)), false, 8, math.random(1,2), 2, math.random(1,3), "trails/smoke.vmt");  
	
	-- self.MissileSound = CreateSound( self, "Missile.Accelerate")
	self.MissileSound = CreateSound( self, "weapons/rpg/rocket1.wav")
		
	self.PhysObj = self:GetPhysicsObject()
	
end

function ENT:PhysicsCollide( data, physobj )
	
	if ( IsValid( data.HitEntity ) && data.HitEntity:GetOwner() == self:GetOwner() ) then // Plox gief support for SetOwner ( table )
		
		return
		
	end
	
	if (data.Speed > 100 && data.DeltaTime > 0.2 ) then 
	
		util.BlastDamage( self.Owner, self.Owner, data.HitPos, 512, 350)
		-- self:ExplosionImproved()
		
		ParticleEffect( "HE_impact_dirt", self:GetPos(), Angle(0,0,0), nil )
        self:EmitSound( "explosion5.wav", 511, math.random( 70, 100 ) )
		self:Remove()
		
	end
	
end

function ENT:PhysicsUpdate()
	self.PhysObj = self:GetPhysicsObject()
	
	local tr, trace = {},{}
	tr.start = self:GetPos()
	tr.endpos = tr.start + self:GetForward() * 250
	tr.filter = self
	trace = util.TraceLine( tr )
	
	if ( trace.Hit && trace.HitSky ) then
		
		self:Remove()
		
	end
	
	if ( !IsValid( self.Owner ) ) then
		self.Owner = self
	end
	
	if self.Flying == true then
		
		if self.Sauce > 1 then

			self.PhysObj:SetVelocity( self:GetForward() * 5000 )
			self.Sauce = self.Sauce - 1
		
		else
			
			self.PhysObj:EnableGravity(true)
			self.PhysObj:EnableDrag(true)
			self.PhysObj:SetMass( 100 )
			
		end
		
	end
	
	// Alcohol Induced Rockets aka Drunk Fire
	self.flip = !self.flip
	local i = ( self.flip ) && 1 || -1
	local a = self.PhysObj:GetAngles()
	local a1 = math.Clamp( math.exp( math.sin( self.seed + CurTime() - ( self:EntIndex() * 10 ) ) * .01 + ( math.random( 1, 10) / 100 ) ) / math.tan( self.seed + CurTime() ) / 4, -2.5, 2.5 )
	local a2 = math.Clamp( math.exp( math.cos( self.seed + CurTime() - ( self:EntIndex() * 10 ) ) * .01 + ( math.random( 1, 10) / 100 ) ) / math.tan( self.seed + CurTime() ) / 4, -2.5, 2.5 )
	//print( a1, a2 )
	self.PhysObj:SetAngles( Angle( a.p + ( 0.35 * ( a2 + math.Rand( -0.1, 0.1 ) ) ) * i, a.y + ( 0.45 * ( a1 + math.Rand( -0.1, 0.1 ) ) ) * i, a.r ) )
	
end

function ENT:Think()
	
	if( self.Delay > 0 ) then
		self.Delay = self.Delay - 1
		self.Flying = false
	
	else
	
		self.Flying = true
	
	end
	
	-- self.MissileSound:PlayEx( 1.0, 100 )
	
end 

function ENT:OnRemove()

	
end
