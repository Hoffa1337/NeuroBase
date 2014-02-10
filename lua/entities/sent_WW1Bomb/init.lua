AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include( 'shared.lua' )
function ENT:OnTakeDamage(dmginfo)
	
	if( !self.HealthVal ) then self.HealthVal = 100 end 
  	if( self.HealthVal < 0 ) then return end
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

	self.Entity:SetModel( "models/props_phx/ww2bomb.mdl" )
	self.Entity:PhysicsInit( SOLID_VPHYSICS )
	self.Entity:SetMoveType( MOVETYPE_VPHYSICS )	
	self.Entity:SetSolid( SOLID_VPHYSICS )

	self.PhysObj = self.Entity:GetPhysicsObject()
	if (self.PhysObj:IsValid()) then
		self.PhysObj:Wake()
		self.PhysObj:EnableDrag(false)
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
		
	if (  self:GetOwner().Owner && IsValid( self:GetOwner().Owner ) ) then
		
		self.Owner = self:GetOwner().Owner
	
	else
		
		self.Owner = self
	
	end

	
	if (data.Speed > 150 && data.DeltaTime > 0.8 ) then 
		
		local explo = EffectData()
		explo:SetOrigin(self.Entity:GetPos())
		explo:SetScale(0.6)
		util.Effect("nn_explosion", explo)
		
		self:ExplosionImproved()
		
		util.BlastDamage( self.Owner, self.Owner, data.HitPos, 3048, 750 )
		self:NeuroPlanes_BlowWelds( self:GetPos(), 666 )
		util.Decal("Scorch", data.HitPos + data.HitNormal * 256, data.HitPos - data.HitNormal * 256 )
	
		self.Entity:Remove()
	
	end
	
end