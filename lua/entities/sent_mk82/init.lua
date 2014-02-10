AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include( 'shared.lua' )

ENT.Cluster = 16
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

//    self:SetModel( "models/hawx/weapons/mk-82.mdl" )
	self:PhysicsInit( SOLID_VPHYSICS )
	self:SetMoveType( MOVETYPE_VPHYSICS )	
	self:SetSolid( SOLID_VPHYSICS )

	self.PhysObj = self:GetPhysicsObject()
	
	if (self.PhysObj:IsValid()) then
		
		self.PhysObj:EnableGravity( true )
		self.PhysObj:EnableDrag( true )
		self.PhysObj:SetMass( 15500 )
		self.PhysObj:Wake()
		
	end
	
	util.SpriteTrail(self, 0, Color(255,255,255,math.random(50,70)), false, 16, math.Rand(0.5,1.1), 3, math.random(1,3), "trails/smoke.vmt");  
	
	if( IsValid( self.Owner ) ) then
	
		self:SetVelocity( self.Owner:GetVelocity() )
	
	end
	
end

function ENT:PhysicsUpdate()

	local tr, trace = {},{}
	tr.start = self:GetPos()
	tr.endpos = tr.start + self:GetForward() * 250
	tr.filter = self
	trace = util.TraceLine( tr )
	
	if ( trace.Hit && trace.HitSky ) then
		
		self:Remove()
		
	end

end

function ENT:Think()
	
	local tr, trace = {},{}
	tr.start = self:GetPos() + Vector( 0, 0, -72 )
	tr.endpos = tr.start + Vector( 0, 0, -1024 ) + self:GetForward() * 512
	tr.filter = { self, self:GetOwner() }
	tr.mask = MASK_SOLID
	
	trace = util.TraceLine ( tr )
	
	if ( trace.Hit ) then
	
		self:DispatchCluster()
		
	end

end

function ENT:DispatchCluster()
	
	for i = 1, self.Cluster do
	
		local p = self:GetPos()
		p.x = p.x + math.sin( CurTime() ) * 64
		p.y = p.y + math.cos( CurTime() ) * 64
		
		local r = ents.Create("sent_C100_cluster")
		r:SetPos( p + VectorRand() * 2 ) 
		r:SetAngles( Angle( 25 + math.random(-15,15), i * ( 360 / self.Cluster ), 0 ) )
		r:SetOwner( self:GetOwner() )
		r:Spawn()
		r.Owner = self.Owner
		r:SetPhysicsAttacker( self.Owner )
		r:GetPhysicsObject():ApplyForceCenter( r:GetForward() * 90000 )
		
		implode( self:GetPos(), 128, 128, -600000000 ) // blow away the clusters
		
	end
	
	local fx = "rocket_impact_wall"
	-- if( math.random( 1,3 ) == 1 ) then
		
		-- fx = "VBIED_b_explosion"
		
	-- end
	
	ParticleEffect( fx, self:GetPos(), self:GetAngles(), nil )
	
	
	self:Remove()
	
end

function ENT:PhysicsCollide( data, physobj )
	
	if (  self:GetOwner().Owner && IsValid( self:GetOwner().Owner ) ) then
		
		self.Owner = self:GetOwner().Owner
	
	else
		
		self.Owner = self
	
	end

	if (data.Speed > 150 && data.DeltaTime > 0.8 ) then
			
		util.Decal("Scorch", data.HitPos + data.HitNormal, data.HitPos - data.HitNormal )
		self:DispatchCluster()
        util.BlastDamage( self.Owner, self.Owner, data.HitPos, 512, 2500 )

	end
	
end
