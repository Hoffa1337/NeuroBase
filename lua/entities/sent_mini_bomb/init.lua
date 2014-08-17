AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include( 'shared.lua' )
-- function ENT:OnTakeDamage(dmginfo)
 -- self:NA_RPG_damagehook(dmginfo)
 -- end

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
		self.PhysObj:EnableGravity(true)
		self.PhysObj:EnableDrag(true)
		self.PhysObj:SetMass(1500)
		
	end
	
	self.SpawnTime = CurTime()
	
	-- util.SpriteTrail(self, 0, Color(255,255,255,math.random(20,40)), false, 3, math.random(0.5,1.1), 0, math.random(1,3), "trails/smoke.vmt");  
end

function ENT:PhysicsUpdate()

	local tr, trace = {},{}
	tr.start = self:GetPos()
	tr.endpos = tr.start + self:GetForward() * 55
	tr.filter = self
	trace = util.TraceLine( tr )
	
	if ( trace.Hit && trace.HitSky ) then
		
		self:Remove()
		
	end

end

function ENT:PhysicsCollide( data, physobj )
	
	if( self.SpawnTime + 0.7 > CurTime() ) then return end
	
	if (  !IsValid( self.Owner ) ) then
	
		self.Owner = self
	
	end

	
	if (data.Speed > 150 && data.DeltaTime > 0.8 ) then 
		
		-- local fx = 
	
		
		ParticleEffect( "rocket_impact_dirt", self:GetPos(), Angle( 0,0,0 ), nil )
		-- ParticleEffect( "30cal_impact", self:GetPos(), Angle( 0,0,0 ), nil )
		
		self:EmitSound(  "ambient/explosions/exp"..math.random(1,4)..".wav", 511, 100 )
		
		util.BlastDamage( self, self.Owner, data.HitPos, 256, math.random( 500,1500 ) )
		
		util.Decal("Scorch", data.HitPos + data.HitNormal * 32, data.HitPos - data.HitNormal * 32 )
	
		self.Entity:Remove()
	
	end
	
end

function ENT:OnRemove()
end
