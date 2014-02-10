AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include( 'shared.lua' )

ENT.Sauce = 3500
ENT.Delay = 2
ENT.Speed = 5000
ENT.DTime = 0

function ENT:OnTakeDamage(dmginfo)
	
	if( !self.HealthVal ) then self.HealthVal = 100 end
	
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
	
	if ( self:GetModel() ) then
		
		self:SetModel( self:GetModel() )
		
	else
	
		self:SetModel( "models/military2/missile/missile_agm88.mdl" )
		
	end
	
	self.seed = math.random( 0, 1000 )
	
	self:PhysicsInit( SOLID_VPHYSICS )
	self:SetMoveType( MOVETYPE_VPHYSICS )	
	self:SetSolid( SOLID_VPHYSICS )
	self.Owner = self:GetOwner().Owner or self
	
	self.PhysObj = self:GetPhysicsObject()
	
	if ( self.PhysObj:IsValid() ) then
		
		self.PhysObj:EnableGravity(false)
		self.PhysObj:EnableDrag(true)
		self.PhysObj:Wake()
		
	end
	
	util.PrecacheSound("Missile.Accelerate")
	
	
	self.smoketrail = {}
	
	for i=1,2 do
	
		self.smoketrail[i] = ents.Create("env_rockettrail")
		self.smoketrail[i]:SetPos(self:GetPos() + self:GetForward() * -83)
		self.smoketrail[i]:SetParent(self)
		self.smoketrail[i]:SetLocalAngles(Angle(0,0,0))
		self.smoketrail[i]:Spawn()
		
	end
	
	util.SpriteTrail(self, 0, Color(255,255,255,math.random(130,170)), false, 8, math.random(1,2), 2, math.sin(CurTime()) / math.pi * 0.5, "trails/smoke.vmt");  

end

function ENT:PhysicsCollide( data, physobj )
	
	if ( self.Inert ) then return end
	
	if ( !IsValid( self.Owner ) ) then
		
		self.Owner = self
		
	end
	
	if ( data.Speed > 50 && data.DeltaTime > 0.2 ) then 
	
		local explo = EffectData()
		explo:SetOrigin(self:GetPos())
		explo:SetStart( data.HitNormal * 100 )
		explo:SetScale( 1.20 )
		explo:SetNormal(data.HitNormal)
		util.Effect("Airstrike_explosion", explo)
		util.BlastDamage( self.Owner, self.Owner, data.HitPos, 512, 950 )
		self:Remove()
		
	end
	
end

local function apr(a,b,c)
	local z = math.AngleDifference( b, a )
	return math.Approach( a, a + z, c )
end

function ENT:PhysicsUpdate()
	
	if( self.DTime > 400 ) then self:Remove() return end
	
	if( self.Inert ) then self.DTime = self.DTime + 1 return end
	
	local tr, trace = {},{}
	tr.start = self:GetPos()
	tr.endpos = tr.start + self:GetForward() * 250
	tr.filter = self
	trace = util.TraceLine( tr )
	
	if ( trace.Hit && trace.HitSky ) then
		
		self:Remove()
		
	end
	
	if ( IsValid( self.Target ) ) then 
		
		local dir = ( self.Target:GetPos() - self:GetPos() ):Angle()
		local d = self:GetPos():Distance( self.Target:GetPos() )
		local a = self:GetAngles()
		a.p, a.r, a.y = apr( a.p, dir.p, 2.4 ),apr( a.r, dir.r, 4 ),apr( a.y, dir.y, 4.0 )

		self:SetAngles( a )
		
		if( self:GetPos():Distance( self.Target:GetPos() ) < 4500 ) then
			
			for i=1,10 do
				
				local drone = ents.Create("sent_a2a_jericho_drone")
				drone:SetPos( self:GetPos() + self:GetRight() * math.sin(CurTime() + ( self:EntIndex() * 5 ) + i ) * 36 + self:GetUp() * math.cos(CurTime() + ( self:EntIndex() * 5 ) + i ) * 36 )
				drone:SetOwner( self )
				drone:SetPhysicsAttacker( self:GetOwner() )
				drone:SetModel( "" )
				drone:SetAngles( self:GetAngles() )
				drone:Spawn()
				drone.Target = self.Target
				drone.Owner = self:GetOwner()
				
				local p = drone:GetPhysicsObject()
				if( p ) then
					
					p:SetVelocity( self:GetVelocity() )
				
				end
			
			end
			
			local trash = ents.Create("prop_physics")
			trash:SetModel( self:GetModel() )
			trash:SetPos( self:GetPos() )
			trash:SetAngles( self:GetAngles() )
			trash:Spawn()
			trash:Ignite(10,10)
			trash:Fire("kill",10)
			trash:GetPhysicsObject():SetVelocity( -self:GetVelocity() )
			
			self:ExplosionImproved()
			self.Inert = true
			
			self:Remove()
			
		end
		
	end

	self.PhysObj:SetVelocity( self:GetForward() * self.Speed )
	
end

function ENT:Think()
		
	if( self.Inert ) then return false end
	
	if ( !IsValid( self.Target ) ) then
	
		local a = self.PhysObj:GetAngles()
		// Alcohol Induced Rockets aka Drunk Fire
		self.PhysObj:SetAngles( Angle( a.p + math.sin( CurTime() - self.seed ) * .29, 
									  a.y + math.cos( CurTime() - self.seed ) * .29,
									  a.r + 2.58123 ) )
		
		return false
		
	else
	
		local a = self:GetPos()
		local ta = ( self.Target:GetPos() - a ):Angle()
		local ma = self:GetAngles()
		local offs = self:VecAngD( ma.y, ta.y )	
		
		if ( offs > -75 && offs < 75 ) then
			
			// Nothing, we can still hit.
			
		else
			
			// Can't locate enemy so we clear the target and the rocket sails away.
			self.Target = NULL
		
		end
	
	end
	
	self:EmitSound("Missile.Accelerate")
	
end 

function ENT:OnRemove()

	self:StopSound("Missile.Accelerate")
	
end
