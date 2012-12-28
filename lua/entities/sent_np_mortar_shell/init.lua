
AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include('shared.lua')

ENT.explodeDel = NULL
ENT.explodeTime = 10

function ENT:Initialize()

	self:SetModel("models/bf2/weapons/eryx/eryx_rocket.mdl")
	self:SetOwner(self.Owner)
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)

    local phys = self:GetPhysicsObject()
	if(phys:IsValid()) then 
	phys:Wake()
	phys:SetMass( 10 )
	end

end

function ENT:Think()

	self:NextThink( CurTime() )

	local fx = EffectData()
	fx:SetOrigin(self:GetPos())
	fx:SetScale( 0.25 )
	util.Effect("Launch2",fx)

end

function ENT:PhysicsCollide( data, physobj )
	
	if ( IsValid( data.HitEntity ) && data.HitEntity:GetOwner() == self:GetOwner() ) then // Plox gief support for SetOwner ( table )
		
		return
		
	end
	
	if (data.Speed > 100 && data.DeltaTime > 0.2 ) then 
	
		util.BlastDamage( self.Owner, self.Owner, data.HitPos, 512, 600 )
		self:Explode()
		
	end
	
end

function ENT:Explode()

	self.ExplodeOnce = 1
	local expl = ents.Create("env_explosion")
	expl:SetKeyValue("spawnflags",128)
	expl:SetPos(self:GetPos())
	expl:Spawn()
	expl:Fire("explode","",0)
	
	local FireExp = ents.Create("env_physexplosion")
	FireExp:SetPos(self:GetPos())
	FireExp:SetParent(self)
	FireExp:SetKeyValue("magnitude", 1000)
	FireExp:SetKeyValue("radius", 512)
	FireExp:SetKeyValue("spawnflags", "1")
	FireExp:Spawn()
	FireExp:Fire("Explode", "", 0)
	FireExp:Fire("kill", "", 5)
	
	self:Remove()
end
