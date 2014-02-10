AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include( 'shared.lua' )

ENT.Sauce = 3500
ENT.Delay = 2
ENT.Speed = 5000
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
	
		self.Entity:SetModel( "models/military2/missile/missile_agm88.mdl" )
		
	end
	
	self.Entity:PhysicsInit( SOLID_VPHYSICS )
	self.Entity:SetMoveType( MOVETYPE_VPHYSICS )	
	self.Entity:SetSolid( SOLID_VPHYSICS )
	self.Owner = self:GetOwner().Owner or self
	
	
	self.PhysObj = self.Entity:GetPhysicsObject()
	
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
		self.smoketrail[i]:SetParent(self.Entity)
		self.smoketrail[i]:SetLocalAngles(Angle(0,0,0))
		self.smoketrail[i]:Spawn()
		
	end
	
	util.SpriteTrail(self, 0, Color(15,15,255,math.random(150,190)), false, 32, math.random(1,2), 2, math.sin(CurTime()) / math.pi * 0.5, "trails/smoke.vmt");  

end

function ENT:PhysicsCollide( data, physobj )
	
	if ( !IsValid( self.Owner ) ) then
		
		self.Owner = self
		
	end
	
	if ( data.Speed > 50 && data.DeltaTime > 0.2 && !data.HitSky ) then 
	
		for i=1,8 do 
		
			local explo = EffectData()
			explo:SetOrigin(self:GetPos())
			explo:SetStart( data.HitNormal * 100 )
			explo:SetScale( 1.20 )
			explo:SetNormal(data.HitNormal)
			util.Effect("ac130_napalm", explo)
			
			self.Entity:Remove()
			
		end
		self:EmitSound( "explosion3.mp3", 511, math.random( 70, 100 ) )
		util.BlastDamage( self.Owner, self.Owner, data.HitPos, 2048, 1750)
	
	end
	
end

local function apr(a,b,c)
	local z = math.AngleDifference( b, a )
	return math.Approach( a, a + z, c )
end

function ENT:PhysicsUpdate()

	if ( IsValid( self.Target ) ) then 
		
		local dir = ( self.Target:GetPos() - self:GetPos() ):Angle()
		local d = self:GetPos():Distance( self.Target:GetPos() )
		local a = self:GetAngles()
		a.p, a.r, a.y = apr( a.p, dir.p, 4.4 ),apr( a.r, dir.r, 4 ),apr( a.y, dir.y, 4.0 )

		self:SetAngles( a )
	
	end

	self.PhysObj:SetVelocity( self:GetForward() * self.Speed )
	
end

function ENT:Think()
	
	local fx = EffectData()
	fx:SetOrigin( self:GetPos() )
	fx:SetEntity( self )
	fx:SetNormal( self:GetForward()*-1 )
	fx:SetScale( 1.0 )
	util.Effect("part_dis", fx )
	
	if ( !IsValid( self.Target ) ) then
			
		local a = self.PhysObj:GetAngles()
		// Alcohol Induced Rockets aka Drunk Fire
		self.PhysObj:SetAngles( Angle( a.p + math.sin( CurTime() - self.seed ) * .09, 
									  a.y + math.cos( CurTime() - self.seed ) * .09,
									  a.r + .09 ) )

		return false
		
	else
	
		local a = self:GetPos()
		local ta = ( self.Target:GetPos() - a ):Angle()
		local ma = self:GetAngles()
		local offs = self:VecAngD( ma.y, ta.y )	
		
		if ( offs > -85 && offs < 85 ) then
			
			// Nothing, we can still hit.
			
		else
			
			// Can't locate enemy so we clear the target and the rocket sails away.
			self.Target = nil
			
		end
	
	end
	
	self.Entity:EmitSound("Missile.Accelerate")
	
	for k,v in pairs( ents.FindInSphere( self.Entity:GetPos(),300 ) ) do
	
		if ( IsValid( v ) && v == self.Target ) then
			
			for i=1,8 do 
			
				local explo = EffectData()
				explo:SetOrigin(self:GetPos())
				explo:SetStart( data.HitNormal * 100 )
				explo:SetScale( 1.20 )
				explo:SetNormal(data.HitNormal)
				util.Effect("ac130_napalm", explo)
				
				self.Entity:Remove()
				
			end
		
			util.BlastDamage( self.Owner, self.Owner, self:GetPos(), 2048, 1750)
			self:EmitSound( "explosion3.wav", 511, math.random( 70, 100 ) )
			self.Entity:Remove()
			
		end
		
	end 
	
end 

function ENT:OnRemove()

	self.Entity:StopSound("Missile.Accelerate")
	
end
