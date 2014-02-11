AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include( 'shared.lua' )

ENT.Sauce = 2500
ENT.Delay = 0.1
ENT.Speed = 200
local deleteTrail = false
function ENT:OnTakeDamage(dmginfo)
 self:NA_RPG_damagehook(dmginfo)
 end
function ENT:Initialize()

	self.Entity:SetModel( "models/military2/missile/missile_tomahawk2.mdl" )
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
		self.smoketrail[i]:SetPos(self:GetPos() + self:GetForward() * - 130 + self:GetUp()*math.random(0,5)+self:GetRight()*math.random(-5,5))
		self.smoketrail[i]:SetParent(self.Entity)
		self.smoketrail[i]:SetLocalAngles(Angle(0,0,0))
		self.smoketrail[i]:Spawn()
	end
//	util.SpriteTrail(self, 0, Color(255,255,255,math.random(130,170)), false, 17, math.random(1,2), 4, math.random(1,3), "trails/smoke.vmt");  
	self.LastFramePos = self.Entity:GetPos()

end
function ENT:Poff()

	if(!self.Target) then
		self.Target = self //lol
	end
	
		local explo = EffectData()
		explo:SetOrigin(self.Entity:GetPos())
		explo:SetScale(1.5)
		explo:SetNormal(self:GetPos() - self.Target:GetPos())
		util.Effect("nn_explosion", explo)
		util.BlastDamage( self.Entity, self.Entity, (self:GetPos() - self.Target:GetPos()), 250, 30)
		self:ExplosionImproved()
		self.Entity:Remove()
end

function ENT:PhysicsCollide( data, physobj )
	if (data.Speed > 50 && data.DeltaTime > 0.2 ) then 
		local explo = EffectData()
		explo:SetOrigin(self.Entity:GetPos())
		explo:SetScale(1.5)
		explo:SetNormal(data.HitNormal)
		util.Effect("nn_explosion", explo)
		util.BlastDamage( self.Entity, self.Entity, data.HitPos, 250, 30)
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
				self.PhysObj:EnableGravity(true)
				self.PhysObj:EnableDrag(true)
				self.PhysObj:SetMass(2000)
			return false
			end
		local NewAng
			if(self.Flared) then
				NewAng = ( self:GetPos()+Vector(128,128,-128) - self.LastPos ):Angle()
			else
				NewAng =  ( self.Target:GetPos() - self.LastPos ):Angle()
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
				self:Poff()
		end
	end 
end 

function ENT:OnRemove()
	self.Entity:StopSound("Missile.Accelerate")
	self:Poff()
end
