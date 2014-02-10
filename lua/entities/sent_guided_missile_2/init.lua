AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include( 'shared.lua' )

ENT.Sauce = 1000
ENT.Delay = 2.5
ENT.Speed = 120
local deleteTrail = false

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

	self.Entity:SetModel( "models/military2/missile/missile_sm2.mdl" )
	self.Entity:PhysicsInit( SOLID_VPHYSICS )
	self.Entity:SetMoveType( MOVETYPE_VPHYSICS )	
	self.Entity:SetSolid( SOLID_VPHYSICS )

	self.PhysObj = self.Entity:GetPhysicsObject()
	if (self.PhysObj:IsValid()) then
		self.PhysObj:Wake()
	end
	util.PrecacheSound("Missile.Accelerate")
	self.smoketrail = {}
	for i=1,4 do
		self.smoketrail[i] = ents.Create("env_rockettrail")
		self.smoketrail[i]:SetPos(self:GetPos() + self:GetForward() * - 160 + self:GetUp()*math.random(5,16)+self:GetRight()*math.random(-5,5))
		self.smoketrail[i]:SetParent(self.Entity)
		self.smoketrail[i]:SetLocalAngles(Angle(0,0,0))
		self.smoketrail[i]:Spawn()
	end
//	util.SpriteTrail(self, 0, Color(255,255,255,math.random(130,170)), false, 17, math.random(1,2), 4, math.random(1,3), "trails/smoke.vmt");  
	self.LastFramePos = self.Entity:GetPos()

end

function ENT:PhysicsCollide( data, physobj )
	if (data.Speed > 50 && data.DeltaTime > 0.2 ) then 
		local explo = EffectData()
		explo:SetOrigin(self.Entity:GetPos())
		explo:SetScale(math.Rand(0.5,0.9))
		explo:SetNormal(data.HitNormal)
		util.Effect("nn_explosion", explo)
		util.BlastDamage( self.Entity, self.Entity, data.HitPos, 1024, 300)
		self:ExplosionImproved()
		self.Entity:Remove()
	end
end
function ENT:PhysicsUpdate()
	if self.Flying == true then
		if self.Sauce > 1 then
			self.Speed = self.Speed + 100
			self.PhysObj:SetVelocity(self:GetForward()*self.Speed)
			self.Sauce = self.Sauce - 1
			if (self.Target == nil || self.Target == NULL || !self.Target:IsValid()) then 
				self.Sauce = 0
				self.PhysObj:EnableGravity(true)
				self.PhysObj:EnableDrag(true)
				self.PhysObj:SetMass(2000)
			return false
			end
		local NewAng
			if(self.Flared) then
				NewAng = ( self:GetPos()+Vector(128,128,-128) - self.LastPos ):Angle()
			else
				NewAng = ( (self.Target:GetPos()+Vector(math.sin(CurTime())*256,math.sin(CurTime())*256,math.cos(CurTime())*256)) - self.LastPos ):Angle()
			end
			self.Entity:SetAngles(NewAng)
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
		for k,v in pairs(ents.FindInSphere(self.Entity:GetPos(),512)) do
			if v == self.Target then
				goBoomSmall(self.Entity)
		end
	end 
end 

function ENT:OnRemove()
	self.Entity:StopSound("Missile.Accelerate")
	local explo1 = EffectData()
	explo1:SetOrigin(self.Entity:GetPos())
	explo1:SetScale(0.5)
	explo1:SetNormal(Vector(0,0,0))
	util.Effect("nn_explosion", explo1)
	for i=0,5 do
		local explo1 = EffectData()
		explo1:SetOrigin(self.Entity:GetPos()+i*Vector(math.Rand(-15,15),math.Rand(-15,15),-2))
		explo1:SetScale(0.25)
		util.Effect("HelicopterMegaBomb", explo1)
	end
end
