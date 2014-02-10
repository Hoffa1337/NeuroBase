AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include( 'shared.lua' )

ENT.Sauce = 2500
ENT.Delay = 0
ENT.Speed = 4000
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
	
	self.seed = math.random( 0, 1000 )
	
	self:SetModel( "models/hawx/weapons/agm-131a sram-ii.mdl" )
	self:PhysicsInit( SOLID_VPHYSICS )
	self:SetMoveType( MOVETYPE_VPHYSICS )	
	self:SetSolid( SOLID_VPHYSICS )
	
	self.Owner = self:GetOwner().Owner or self // lolol
	
	self.PhysObj = self:GetPhysicsObject()
	
	if ( self.PhysObj:IsValid() ) then
	
		self.PhysObj:Wake()
	
	end
	
	util.PrecacheSound("Missile.Accelerate")
	
	self.smoketrail = {}
	
	for i = 1, 3 do
	
		self.smoketrail[i] = ents.Create("env_rockettrail")
		self.smoketrail[i]:SetPos(self:GetPos() + self:GetForward() * -59)
		self.smoketrail[i]:SetParent(self)
		self.smoketrail[i]:SetLocalAngles(Angle(0,0,0))
		self.smoketrail[i]:Spawn()
		
	end
	
	util.SpriteTrail(self, 0, Color(255,255,255,math.random(180,210)), false, 32, math.random(1,2), 1, math.random(1,3), "trails/smoke.vmt");  
	
end

function ENT:PhysicsCollide( data, physobj )
	
	if ( IsValid( data.HitEntity ) && data.HitEntity:GetOwner() == self:GetOwner() ) then // Plox gief support for SetOwner ( table )
		
		return
		
	end
	
	if ( data.Speed > 100 && data.DeltaTime > 0.2 ) then 
	
		local fx = EffectData()
		fx:SetOrigin( self:GetPos() )
		fx:SetNormal( self:GetForward() )
		fx:SetScale( 0.13 )
		util.Effect("nuke_effect_air", fx)
		
		for i=1,10 do
		
			timer.Simple( i/3, function() util.BlastDamage( self.Owner, self.Owner, data.HitPos, 5500, 5500) end )
		
		end
		
		
		self:Remove()
		
		
	end
	
end

function ENT:PhysicsUpdate()

	if ( !IsValid( self.Owner ) ) then
		self.Owner = self
	end
	

	
	if self.Flying == true then
	
		if ( IsValid( self.Target ) ) then 
			
			local dir = ( self.Target:GetPos() - self:GetPos() ):Angle()
			local d = self:GetPos():Distance( self.Target:GetPos() )
			local a = self:GetAngles()
			a.p, a.r, a.y = apr( a.p, dir.p, 2.4 ),apr( a.r, dir.r, 4 ),apr( a.y, dir.y, 4.0 )

			self:SetAngles( a )
		
		end
		
		if self.Sauce > 1 then
			
			self.Speed = self.Speed + 100
			self.PhysObj:SetVelocity( self:GetForward() * self.Speed )
			self.Sauce = self.Sauce - 1
			
		end
		
	end
	
end

function ENT:Think()
	
	if( self.Delay > 0 ) then
	
		self.Delay = self.Delay - 1
		self.Flying = false
	
	else
		
		self.Flying = true
		self.Delay = 0
		
	end
	
	self:EmitSound("Missile.Accelerate")
	
end 

function ENT:OnRemove()

	self:StopSound("Missile.Accelerate")
	
end
