AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include( 'shared.lua' )

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

	self.Entity:SetModel( "models/military2/bomb/bomb_cbu.mdl" )
	self.Entity:PhysicsInit( SOLID_VPHYSICS )
	self.Entity:SetMoveType( MOVETYPE_VPHYSICS )	
	self.Entity:SetSolid( SOLID_VPHYSICS )

	self.PhysObj = self.Entity:GetPhysicsObject()
	if (self.PhysObj:IsValid()) then
		self.PhysObj:Wake()
		self.PhysObj:EnableGravity(true)
		self.PhysObj:EnableDrag(true)
		self.PhysObj:SetMass(1000)
	end
	
	self.Speed = math.random( 500, 1000 )
	
	self.Owner = self.Owner or self
	
	//util.SpriteTrail(self, 0, Color(255,255,255,math.random(130,170)), false, 3, math.random(0.5,1.1), 3, math.random(1,3), "trails/smoke.vmt");  
end

function ENT:LerpAim( pos)

	if ( pos == nil ) then

		return

	end

	local a = self:GetPos() 
	local b = pos
	local c = Vector( a.x - b.x, a.y - b.y, a.z - b.z )
	local e = math.sqrt( ( c.x ^ 2 ) + ( c.y ^ 2 ) + (c.z ^ 2 ) ) 
	local target = Vector( -( c.x / e ), -( c.y / e ), -( c.z / e ) )

	
	self:SetAngles( LerpAngle( 0.00015, target:Angle(), self:GetAngles() ) )

	
end



function ENT:Detonate( data ) // traceResult

	for i = 1, 5 do

		self:ExplosionImproved()

		util.BlastDamage( self.Owner or self, self.Owner or self, self:GetPos() + self:GetForward() * 128 * i , 1048, 23)
		
	end
	
	util.Decal("Scorch", data.HitPos + data.HitNormal, data.HitPos - data.HitNormal )
	
	self:Remove()
	
end


function ENT:Think()
	
	local tr, trace = {}, {}
	tr.start = self:GetPos()
	tr.endpos = tr.start + self:GetForward() * 256 + self:GetUp() * math.sin(CurTime()) * 40 + self:GetRight() * math.sin(CurTime()) * 40
	tr.filter = { self, self:GetOwner() }
	tr.mask = MASK_SOLID
	
	trace = util.TraceEntity( tr, self )
	
	if ( trace.Hit && trace.Entity != self:GetOwner() ) then
		
		self:Detonate( trace )
		
	end

end

function ENT:OnRemove()
end
