AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include( 'shared.lua' )

ENT.Sauce = 800
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

	self.Entity:SetModel( "models/weapons/w_missile_closed.mdl" )
	self.Entity:PhysicsInit( SOLID_VPHYSICS )
	self.Entity:SetMoveType( MOVETYPE_VPHYSICS )	
	self.Entity:SetSolid( SOLID_VPHYSICS )

	self.PhysObj = self.Entity:GetPhysicsObject()
	
	if (self.PhysObj:IsValid()) then
		self.PhysObj:Wake()
	end

	util.PrecacheSound("Missile.Accelerate")

	util.SpriteTrail(self, 0, Color(195,195,195,math.random(80,100)), false, 17, math.random(1,2), 4, math.random(1,3), "trails/smoke.vmt");  
	

end

function ENT:PhysicsCollide( data, physobj )
	if (data.Speed > 50 && data.DeltaTime > 0.2 ) then 
		local explo = EffectData()
		explo:SetOrigin(self:GetPos())
		explo:SetScale(0.50)
		explo:SetNormal(data.HitNormal)
		util.Effect("nn_explosion", explo)
		util.BlastDamage( self, self, data.HitPos, 1024, 80)
		self:ExplosionImproved()
		self.Entity:Remove()
	end
end
function ENT:PhysicsUpdate()
	if self.Flying == true then
		if self.Sauce > 1 then
			self.Speed = self.Speed + 100
			self.Sauce = self.Sauce - 1
			
			if ( !IsValid( self.Target ) ) then 
				self.Sauce = 0
				self.PhysObj:EnableGravity(true)
				self.PhysObj:EnableDrag(true)
				self.PhysObj:SetMass(2000)
				return false
			end

			self:GunAim( self.Target )
			self.PhysObj:ApplyForceCenter(self:GetForward()*self.Speed)
		else
			self.PhysObj:EnableGravity(true)
			self.PhysObj:EnableDrag(true)
			self.PhysObj:SetMass(1000)
		end
	end

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
	for k,v in pairs(ents.FindInSphere(self.Entity:GetPos(),512)) do
		if v == self.Target then
			local explo = EffectData()
			explo:SetOrigin(self.Entity:GetPos())
			explo:SetScale(0.50)
			explo:SetNormal(Vector(math.random(-1,1),math.random(-1,1),math.random(-1,1)))
			util.Effect("nn_explosion", explo)
			util.BlastDamage( self, self, self:GetPos(), 1024, 80)
			self:ExplosionImproved()
			self.Entity:Remove()
		end
	end 
end 

function ENT:OnRemove()
	self.Entity:StopSound("Missile.Accelerate")
end
