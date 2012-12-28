AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include( 'shared.lua' )

function ENT:Initialize()

	self.Entity:SetModel( "models/hawx/weapons/gbu-32 jdam_big.mdl" )
	self.Entity:PhysicsInit( SOLID_VPHYSICS )
	self.Entity:SetMoveType( MOVETYPE_VPHYSICS )	
	self.Entity:SetSolid( SOLID_VPHYSICS )

	self.PhysObj = self.Entity:GetPhysicsObject()
	if (self.PhysObj:IsValid()) then
		self.PhysObj:Wake()
		self.PhysObj:EnableGravity(true)
		self.PhysObj:EnableDrag(true)
		self.PhysObj:SetMass(1500)
	end
	util.SpriteTrail(self, 0, Color(255,255,255,math.random(30,70)), false, 3, math.random(0.5,1.1), 3, math.random(1,3), "trails/smoke.vmt");  
end

function ENT:PhysicsUpdate()

	local tr, trace = {},{}
	tr.start = self:GetPos()
	tr.endpos = tr.start + self:GetForward() * 250
	tr.filter = self
	trace = util.TraceLine( tr )
	
	if ( trace.Hit && trace.HitSky ) then
		
		self:Remove()
		
	end

end

function ENT:PhysicsCollide( data, physobj )
		
	if ( IsValid( self:GetOwner().Owner ) ) then
		
		self.Owner = self:GetOwner().Owner
	
	else
		
		self.Owner = self
	
	end

	
	if (data.Speed > 150 && data.DeltaTime > 0.8 ) then 
		
		local explo = EffectData()
		explo:SetOrigin(self.Entity:GetPos())
		explo:SetScale( 1.3 )
		util.Effect("nn_explosion", explo)
		util.BlastDamage( self.Owner, self.Owner, data.HitPos, 2000, 1000 )
		util.Decal("Scorch", data.HitPos + data.HitNormal * 768, data.HitPos - data.HitNormal * 768 )
	
		self.Entity:Remove()
	
	end
	
end

function ENT:OnRemove()
end