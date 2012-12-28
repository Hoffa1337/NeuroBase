AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include( 'shared.lua' )

function ENT:Initialize()

	if ( self:GetModel() ) then
		
		self:SetModel( self:GetModel() )
		
	else
	
		self.Entity:SetModel( "models/hawx/weapons/gbu-32 jdam.mdl" )
	
	end
	
	self.Entity:PhysicsInit( SOLID_VPHYSICS )
	self.Entity:SetMoveType( MOVETYPE_VPHYSICS )	
	self.Entity:SetSolid( SOLID_VPHYSICS )

	self.PhysObj = self.Entity:GetPhysicsObject()
	
	if (self.PhysObj:IsValid()) then
		
		self.PhysObj:Wake()
		self.PhysObj:EnableDrag( true )
		
	end
	util.SpriteTrail(self, 0, Color(255,255,255,math.random(20,40)), false, 3, math.random(0.5,1.1), 3, math.random(1,3), "trails/smoke.vmt");  
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
		
	if (  self:GetOwner().Owner && IsValid( self:GetOwner().Owner ) ) then
		
		self.Owner = self:GetOwner().Owner
	
	else
		
		self.Owner = self
	
	end

	
	if (data.Speed > 150 && data.DeltaTime > 0.8 ) then 
		
		local explo = EffectData()
		explo:SetOrigin(self.Entity:GetPos())
		explo:SetScale(0.8)
		util.Effect("nn_explosion", explo)
		
		self:ExplosionImproved()
		
		util.BlastDamage( self.Owner, self.Owner, data.HitPos, 750, 1000)
		self:NeuroPlanes_BlowWelds( self:GetPos(), 1000 )
		util.Decal("Scorch", data.HitPos + data.HitNormal * 256, data.HitPos - data.HitNormal * 256 )
	
		self.Entity:Remove()
	
	end
	
end

function ENT:OnRemove()
end