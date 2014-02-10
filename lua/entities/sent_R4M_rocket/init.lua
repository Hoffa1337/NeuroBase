AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include( 'shared.lua' )

ENT.Sauce = 100
ENT.Delay = 0
ENT.Speed = 2200
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
	
	self.seed = math.random( 0, 1000 )
	
//	self:SetModel( "models/weapons/w_missile_closed.mdl" )
	self:PhysicsInit( SOLID_VPHYSICS )
	self:SetMoveType( MOVETYPE_VPHYSICS )	
	self:SetSolid( SOLID_VPHYSICS )
	
	self.Owner = self:GetOwner().Owner or self // lolol
	
	self.PhysObj = self:GetPhysicsObject()
	
	if ( self.PhysObj:IsValid() ) then
	
		self.PhysObj:Wake()
	
	end
	
	util.PrecacheSound("Missile.Accelerate")
	
	self.SpriteTrail = util.SpriteTrail( self, 0, Color( math.random(200,235), math.random(200,235), math.random(200,235), math.random(200,255) ), false, 0, 128, math.Rand( 0.15, 0.25 ), 1/(0+128)*0.5, "trails/smoke.vmt");  
	
end

function ENT:PhysicsCollide( data, physobj )
	
	if ( IsValid( data.HitEntity ) && data.HitEntity:GetOwner() == self:GetOwner() ) then // Plox gief support for SetOwner ( table )
		
		return
		
	end
	
	if (data.Speed > 100 && data.DeltaTime > 0.2 ) then 
	
		util.BlastDamage( self.Owner, self.Owner, data.HitPos, 500, 200 )
		self:ExplosionImproved()
		self:Remove()
		
		
	end
	
end

function ENT:PhysicsUpdate()
	
	
	if( self:WaterLevel() > 0 ) then
		
		self:Remove()
		
	end
	
	local tr, trace = {},{}
	tr.start = self:GetPos()
	tr.endpos = tr.start + self:GetForward() * 250
	tr.filter = self
	trace = util.TraceLine( tr )
	
	if ( trace.Hit && trace.HitSky ) then
		
		self:Remove()
		
	end
	
	if ( !IsValid( self.Owner ) ) then
		self.Owner = self
	end
	
	if self.Flying == true then
		
		if self.Sauce > 1 then
			
			self.Speed = self.Speed + 100
			self.PhysObj:SetVelocity( self:GetForward() * self.Speed )
			self.Sauce = self.Sauce - 1
			self.Lastvelocity = self:GetVelocity():Length()
			
			local a = self.PhysObj:GetAngles()
			// Alcohol Induced Rockets aka Drunk Fire
			self.PhysObj:SetAngles( Angle( a.p + math.sin( CurTime() - self.seed ) * .05, 
										  a.y + math.cos( CurTime() - self.seed ) * .05,
										  a.r + .1 ) )
										  
		else
		
			self.PhysObj:Wake()
			self.PhysObj:EnableGravity( true )
			self.PhysObj:EnableDrag( true )
			self.PhysObj:SetMass( 1000 )
			
		end
		
	end
	

	
end

function ENT:Think()
	
	if self.Delay > 0 then
		self.Delay = self.Delay - 1
		self.Flying = false
	else
		self.Flying = true
		self.Delay = 0
	end
	
	local effectdata = EffectData()
	effectdata:SetStart( self:GetPos() )
	effectdata:SetOrigin( self:GetPos() )
	effectdata:SetEntity( self )
	effectdata:SetScale( 10 )
	effectdata:SetNormal( self:GetForward() )
	util.Effect( "A10_muzzlesmoke", effectdata )
	
	self:EmitSound("Missile.Accelerate")
	
end 

function ENT:OnRemove()
	
	self.SpriteTrail:SetParent( )
	self.SpriteTrail:SetMoveType( MOVETYPE_NONE )
	self.SpriteTrail:Fire("kill","",4)
	
	self:StopSound( "Missile.Accelerate" )
	
	local explo1 = EffectData()
	explo1:SetOrigin( self:GetPos() )
	explo1:SetScale( 0.25 )
	util.Effect( "Explosion", explo1 )
	
	for i = 1, 5 do
	
		local explo1 = EffectData()
		explo1:SetOrigin( self:GetPos() + Vector( math.random(-128,128), math.random(-105,105), 0 ) )
		explo1:SetScale( 0.25 )
		util.Effect("HelicopterMegaBomb", explo1)
		
	end
	
end
