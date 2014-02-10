AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include( 'shared.lua' )

ENT.Sauce = 900
ENT.Delay = 0
ENT.Speed = 3000

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

	self.Entity:SetModel( "models/weapons/w_missile_closed.mdl" )
	self.Entity:PhysicsInit( SOLID_VPHYSICS )
	self.Entity:SetMoveType( MOVETYPE_VPHYSICS )	
	self.Entity:SetSolid( SOLID_VPHYSICS )
	
	self.Owner = self:GetOwner() or self
	
	self.PhysObj = self.Entity:GetPhysicsObject()
	
	if ( self.PhysObj:IsValid() ) then
	
		self.PhysObj:Wake()
	
	end
	
	util.PrecacheSound("Missile.Accelerate")
	
	util.SpriteTrail(self, 0, Color(255,255,255,math.random(50,90)), false, 17, math.random(1,2), 4, math.random(1,3), "trails/smoke.vmt");  
	
end

function ENT:PhysicsCollide( data, physobj )
	
	if (data.Speed > 50 && data.DeltaTime > 0.2 ) then 
		
		util.BlastDamage( self.Owner, self.Owner, data.HitPos, 350, 100)
		self:ExplosionImproved()
		self.Entity:Remove()
	
	end
	
end
function ENT:PhysicsUpdate()
	if ( !IsValid( self.Owner ) ) then
		self.Owner = self
	end
	if self.Flying == true then
		if self.Sauce > 1 then
			self.Speed = self.Speed + 1000
			self.PhysObj:ApplyForceCenter(self:GetForward() * self.Speed )
			self.Sauce = self.Sauce - 1
		else
			self.PhysObj:EnableGravity(true)
			self.PhysObj:EnableDrag(true)
			self.PhysObj:SetMass(100)
		end
	end
	self.LastPos = self.Entity:GetPos()
end


function ENT:Use( activator, caller )
end

function ENT:Think()
	
	if self.Delay > 0 then
		self.Delay = self.Delay - 1
		self.Flying = false
	else
		self.Flying = true
		self.Delay = 0
	end
	
	self.Entity:EmitSound("Missile.Accelerate")
	
end 

function ENT:OnRemove()

	self.Entity:StopSound("Missile.Accelerate")
	
	local explo1 = EffectData()
	explo1:SetOrigin(self.Entity:GetPos())
	explo1:SetScale(0.25)
	util.Effect("Explosion", explo1)
	
	for i=0,5 do
	
		local explo1 = EffectData()
		explo1:SetOrigin(self.Entity:GetPos()+i*Vector(math.Rand(-15,15),math.Rand(-15,15),-2))
		explo1:SetScale(0.25)
		util.Effect("HelicopterMegaBomb", explo1)
		
	end
	
end
