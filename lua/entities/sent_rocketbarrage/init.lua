AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include( 'shared.lua' )
function ENT:Initialize()

	self.Entity:SetModel( "models/Weapons/W_missile_closed.mdl" )
	self.Entity:PhysicsInit( SOLID_VPHYSICS )
	self.Entity:SetMoveType( MOVETYPE_VPHYSICS )	
	self.Entity:SetSolid( SOLID_VPHYSICS )

	self.PhysObj = self.Entity:GetPhysicsObject()
	if (self.PhysObj:IsValid()) then
		self.PhysObj:Wake()
	end
	util.PrecacheSound("Missile.Accelerate")
	util.SpriteTrail(self, 0, Color(255,255,255,math.random(130,170)), false, 17, math.random(1,2), 4, math.random(1,3), "trails/smoke.vmt");  
	-- self.smoketrail = ents.Create("env_rockettrail")
	-- self.smoketrail:SetPos(self.Entity:GetPos() - 16*self.Entity:GetForward())
	-- self.smoketrail:SetParent(self.Entity)
	-- self.smoketrail:SetLocalAngles(Angle(0,0,0))
	-- self.smoketrail:Spawn()

end

function ENT:PhysicsCollide( data, physobj )
	if (data.Speed > 50 && data.DeltaTime > 0.2 ) then 
		local explo = EffectData()
		explo:SetOrigin(self.Entity:GetPos())
		util.Effect("Explosion", explo)
		self:ExplosionImproved()
		util.BlastDamage( self.Entity, self.Entity, data.HitPos, 256, 90)
		self.Entity:Remove()
	end
end
function ENT:PhysicsUpdate()

end
function ENT:Use( activator, caller )
end

function ENT:Think()
self.PhysObj:SetVelocity(self.Entity:GetForward()*14000)
self.Entity:GunAim(self.Entity:GetOwner().Target)
self.Entity:EmitSound("Missile.Accelerate")
for k,v in pairs(ents.FindInSphere(self.Entity:GetPos(),256)) do
	if (v:IsNPC() || v:IsPlayer()) then
		if (string.find(v:GetClass(), "npc_leakheli")) then return end
			for i=0,3 do
		local explo1 = EffectData()
		explo1:SetOrigin(self.Entity:GetPos()+i*self.Entity:GetForward()*64)
		explo1:SetScale(0.25)
		
		util.Effect("HelicopterMegaBomb", explo1)
		end
	util.BlastDamage( self.Entity, self.Entity, self.Entity:GetPos() , 300, 90)
	self.Entity:Remove()
	end
	end
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
