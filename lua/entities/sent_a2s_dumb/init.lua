AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include( 'shared.lua' )

ENT.Sauce = 900
ENT.Delay = 0
ENT.Speed = 5000

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
	
	self.seed = math.random( 0, 1000 )
	
	self:SetModel( "models/hawx/weapons/zuni mk16.mdl" )
	self:PhysicsInit( SOLID_VPHYSICS )
	self:SetMoveType( MOVETYPE_VPHYSICS )	
	self:SetSolid( SOLID_VPHYSICS )
	-- self:SetColor( Color( 0, 0, 0, 0 ) )
	
	-- self.Owner = self:GetOwner().Owner or self // lolol
	

	self.PhysObj = self:GetPhysicsObject()
	
	if ( self.PhysObj:IsValid() ) then
	
		self.PhysObj:Wake()
	
	end
	
	self.SpawnTime = CurTime()
	
	util.PrecacheSound("Missile.Accelerate")
	
	util.SpriteTrail(self, 0, Color(255,255,255,math.random(120,160)), false, 8, math.random(1,2), 1, math.random(1,3), "trails/smoke.vmt");  
	
end

function ENT:PhysicsCollide( data, physobj )
	
	-- //if( self.SpawnTime + 0.01 <= CurTime() ) then return end
	
	if ( IsValid( data.HitEntity ) && data.HitEntity:GetOwner() == self:GetOwner() ) then --// Plox gief support for SetOwner ( table )
		
		return
		
	end
	
	if (data.Speed > 1 && data.DeltaTime > 0.1 ) then 
		
		
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
		
		return
		
	end
	
	if ( !IsValid( self.Owner ) ) then
	
		self.Owner = self
		
	end
	
	if self.Flying == true then
		
		if self.Sauce > 1 then
			
			self.Speed = self.Speed + 100
			self.PhysObj:SetVelocity( self:GetForward() * self.Speed )
			self.Sauce = self.Sauce - 1
					
			local a = self.PhysObj:GetAngles()
			// Alcohol Induced Rockets aka Drunk Fire
			self.PhysObj:SetAngles( Angle( a.p + math.sin( CurTime() - self.seed ) * .01, 
										  a.y + math.cos( CurTime() - self.seed ) * .01,
										  a.r + math.sin( CurTime() - self.seed ) * .01 ) )
										  
		else
		
			self.PhysObj:EnableGravity(true)
			self.PhysObj:EnableDrag(true)
			self.PhysObj:SetMass(100)
			
		end
		
	end

	
end

function ENT:Think()
	
	if( self:WaterLevel() > 0 ) then
	
		self:Remove()
		
	end
	
	if self.Delay > 0 then
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
	
	util.BlastDamage( self, self.Owner, self:GetPos(), 512, math.random(300,600) )
	ParticleEffect("rocket_impact_wall", self:GetPos(), self:GetAngles(), nil )
	
	for i=0,5 do
	
		local explo1 = EffectData()
		explo1:SetOrigin(self:GetPos()+i*Vector(math.Rand(-15,15),math.Rand(-15,15),-2))
		explo1:SetScale(0.25)
		util.Effect("HelicopterMegaBomb", explo1)
		
	end
	
end
