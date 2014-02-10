AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include( 'shared.lua' )

ENT.Speed = 3000
ENT.Damage = 2500
ENT.Radius = 1236
ENT.Cluster = 12
function ENT:OnTakeDamage(dmginfo)
	
	if( !self.HealthVal ) then self.HealthVal = 100 end 
  	if( self.HealthVal < 0 ) then return end
	self:TakePhysicsDamage( dmginfo )
	
	self.HealthVal = self.HealthVal - dmginfo:GetDamage()
	
	self:SetNetworkedInt( "health" , self.HealthVal )
	
	if ( self.HealthVal < 0 ) then

		ParticleEffect( "ap_impact_wall", self:GetPos(), self:GetAngles(), nil )
		util.BlastDamage( self, self, self:GetPos(), 256, 256 )
		self:Remove()
		return
		
		
	end
	
end
function ENT:Initialize()
	
	self:PhysicsInit( SOLID_VPHYSICS )
	self:SetMoveType( MOVETYPE_VPHYSICS )	
	self:SetSolid( SOLID_VPHYSICS )
	self.Ticker = 0
	
	math.randomseed( self:EntIndex() * 1000 + CurTime() )
	local r = math.random( 0, 1 ) 
	self.rand = ( r > 0  ) and 1 or -1
	
	self.PhysObj = self:GetPhysicsObject()
	self.Sound = CreateSound(self, "Missile.Accelerate")
	
	if ( self.PhysObj:IsValid() ) then
		
		self.PhysObj:EnableGravity(false)
		self.PhysObj:EnableDrag(true)
		self.PhysObj:Wake()
		
	end
	
	util.PrecacheSound("Missile.Accelerate")

	self.smoketrail = ents.Create("env_rockettrail")
	self.smoketrail:SetPos(self:GetPos() + self:GetForward() * -83)
	self.smoketrail:SetParent(self)
	self.smoketrail:SetLocalAngles(Angle(0,0,0))
	self.smoketrail:Spawn()

	if ( self:GetModel() ) then
		
		self:SetModel( self:GetModel() )
		
	else
	
		self:SetModel( "models/military2/missile/missile_agm88.mdl" )
		
	end
	
	util.SpriteTrail(self, 0, Color(255,225,180,math.random(150,170)), false, 24, math.random(1,2), 0.5, math.sin(CurTime()) / math.pi * 0.5, "trails/smoke.vmt");  

end

function ENT:PhysicsCollide( data, physobj )
	
	if( data.DeltaTime < 0.2 ) then return end
	
	if ( !self.Owner || !IsValid( self.Owner ) ) then
		
		self.Owner = self
		
	end
	
	local explo = EffectData()
	explo:SetOrigin( self:GetPos() )
	explo:SetStart( Vector( 0, 0, 100 ) )
	explo:SetScale( 1.45 )
	explo:SetNormal( data.HitNormal )
	util.Effect("v1_impact", explo)
	
	if( !self.Radius ) then self.Radius = 512 end
	if( !self.Damage ) then self.Damage = 2048 end
	
	util.BlastDamage( self, self.Owner, data.HitPos, self.Radius, self.Damage )

	-- self:NeuroPlanes_BlowWelds( self:GetPos(), self.Radius )
	-- self:ExplosionImproved()
	self:Remove()
		
end

local function apr( a, b, c )
	local z = math.AngleDifference( b, a )
	return math.Approach( a, a + z, c )
end

function ENT:DispatchCluster()
	
	for i = 1, self.Cluster do
	
		local p = self:GetPos()
		p.x = p.x + math.sin( CurTime() ) * 64
		p.y = p.y + math.cos( CurTime() ) * 64
		
		local r = ents.Create("sent_C100_cluster")
		r:SetPos( p ) 
		r:SetAngles( Angle( 70 + math.random( -5, 5 ), i * ( 360 / self.Cluster ), 0 ) )
		r:SetOwner( self )
		r:Spawn()
		r.Owner = self.Owner
		r:GetPhysicsObject():ApplyForceCenter( r:GetForward() * 900000 )
		
	end
	
	local explo = EffectData()
	explo:SetOrigin( self:GetPos() )
	explo:SetScale( 0.5 )
	util.Effect( "Flaksmoke", explo )
	
	self:Remove()
	
end

function ENT:PhysicsUpdate()
		
	self.PhysObj:SetVelocity( self:GetForward() * self.Speed )
	
	if( self:WaterLevel() > 1 ) then
		
		self:NeuroPlanes_SurfaceExplosion()
		
		self:Remove()
		
		return
		
	end
	
	if( self.Ticker < 30 ) then
			
		self.Ticker = self.Ticker + 1
		
		return
		
	end
	
	if( !self.ImpactPoint ) then
		
		return
		
	end
	
	local tr, trace = {},{}
	tr.start = self:GetPos()
	tr.endpos = tr.start + self:GetForward() * 250
	tr.filter = self
	trace = util.TraceLine( tr )
	
	if ( trace.Hit && trace.HitSky ) then
		
		self:Remove()
		
	end
	
	local pos = self.ImpactPoint
	local mp = self:GetPos()
	local _2Ddistance = ( Vector( pos.x, pos.y, 0 ) - Vector( mp.x, mp.y, 0 ) ):Length()
	
	if ( _2Ddistance > 3150 ) then
		
		pos = self.ImpactPoint + Vector( math.sin( CurTime() * ( self:EntIndex() * 55 ) * self.rand ) * 2048, math.tan( CurTime() * ( self:EntIndex() * 55 ) * self.rand ) * 2048,( 2648 + ( ( math.cos( CurTime() + self:EntIndex() * 100 * self.rand ) * 128 ) ) ) + ( ( self:GetPos() - self.ImpactPoint ):Length() / 3.5 )  )
		
	else
	
		if( self.ShouldCluster ) then
		
			local tr, trace = {},{}
			tr.start = self:GetPos()
			tr.endpos = tr.start + self:GetForward() * 3400
			tr.filter = self
			trace = util.TraceLine( tr )
			
			if( trace.Hit ) then
				
				self:DispatchCluster()
			
			end
		
		end
		
		self.Speed = self.Speed + 25
	
	end
	
	local dir = ( pos - mp ):Angle()
	local a =  LerpAngle( 0.0318, self:GetAngles(), dir )
	//a.p, a.r, a.y = apr( a.p, dir.p, 4.5 ),apr( a.r, dir.r, 4.5 ),apr( a.y, dir.y, 4.5 )
	
	self:SetAngles( a )

end

function ENT:Think()

	self.Sound:PlayEx( 100, 1 )
	
end 

function ENT:OnRemove()

	self.Sound:Stop()
	
end
