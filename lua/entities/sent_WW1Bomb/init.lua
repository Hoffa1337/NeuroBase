AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include( 'shared.lua' )
function ENT:OnTakeDamage(dmginfo)
 self:NA_RPG_damagehook(dmginfo)
end
function ENT:Initialize()

	self.Entity:SetModel( "models/props_phx/ww2bomb.mdl" )
	self.Entity:PhysicsInit( SOLID_VPHYSICS )
	self.Entity:SetMoveType( MOVETYPE_VPHYSICS )	
	self.Entity:SetSolid( SOLID_VPHYSICS )

	self.PhysObj = self.Entity:GetPhysicsObject()
	if (self.PhysObj:IsValid()) then
		self.PhysObj:Wake()
		self.PhysObj:EnableDrag(true)
		self.PhysObj:EnableGravity(true)
		self.PhysObj:SetMass(5500)
	end
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
		
	if ( IsValid( self:GetOwner() ) && IsValid( self:GetOwner().Owner ) ) then
		
		self.Owner = self:GetOwner().Owner
	
	else
		
		self.Owner = self
	
	end

	if (data.Speed > 150 && data.DeltaTime > 0.8 ) then 
		
		local fx = "carpet_explosion"
	
		ParticleEffect( fx, self:GetPos(), self:GetAngles(), NULL )
		
		util.BlastDamage( self, self.Owner, data.HitPos, 1500, math.random( 3000, 5000) )
		util.Decal("Scorch", data.HitPos + data.HitNormal * 768, data.HitPos - data.HitNormal * 768 )
	
		self:Remove()
	
	end
	
end