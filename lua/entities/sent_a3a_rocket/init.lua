AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include( 'shared.lua' )

ENT.Sauce = 3500
ENT.Delay = 2
ENT.Speed = 4000
ENT.Damage = 2500

function ENT:Initialize()
	
	if ( !self:GetModel() ) then

		self:SetModel( "models/military2/missile/missile_agm88.mdl" )
		
	end
	
	self.seed = math.random( 0, 1000 )
	
	self:PhysicsInit( SOLID_VPHYSICS )
	self:SetMoveType( MOVETYPE_VPHYSICS )	
	self:SetSolid( SOLID_VPHYSICS )
	self.Owner = self:GetOwner().Owner or self
	
	
	self.PhysObj = self:GetPhysicsObject()
	
	if ( self.PhysObj:IsValid() ) then
		
		self.PhysObj:EnableGravity(false)
		self.PhysObj:EnableDrag(true)
		self.PhysObj:Wake()
		
	end
	
	util.PrecacheSound("Missile.Accelerate")

	self.smoketrail = {}
	
	for i=1,2 do
	
		self.smoketrail[i] = ents.Create("env_rockettrail")
		self.smoketrail[i]:SetPos(self:GetPos() + self:GetForward() * -83)
		self.smoketrail[i]:SetParent(self)
		self.smoketrail[i]:SetLocalAngles(Angle(0,0,0))
		self.smoketrail[i]:Spawn()
		
	end
	
	util.SpriteTrail(self, 0, Color(255,255,255,math.random(130,170)), false, 8, math.random(1,2), 2, math.sin(CurTime()) / math.pi * 0.5, "trails/smoke.vmt");  

end

function ENT:PhysicsCollide( data, physobj )
	
	if ( !IsValid( self.Owner ) ) then
		
		self.Owner = self
		
	end
	
	if ( data.Speed > 50 && data.DeltaTime > 0.2 ) then 
		
		for i=0,3 do
		
			local explo1 = EffectData()
			explo1:SetOrigin(self.Entity:GetPos())
			explo1:SetScale(7.25)
			util.Effect("Launch2", explo1)
			
		end
			
		for i=1,10 do
		
			local fx=EffectData()
			fx:SetOrigin(self.Entity:GetPos()+Vector(math.random(-256,256),math.random(-256,256),math.random(-256,256)))
			fx:SetScale(20*i)
			util.Effect("Firecloud",fx)

		end
			
		util.BlastDamage( self.Owner, self.Owner, data.HitPos, 800, self.Damage )
	
		self:Remove()
				
	end
	
end

local function apr(a,b,c)
	local z = math.AngleDifference( b, a )
	return math.Approach( a, a + z, c )
end

function ENT:PhysicsUpdate()

	if( self:WaterLevel() > 1 ) then

		self:Remove()
		
		return
		
	end
	
	local tr, trace = {},{}
	tr.start = self:GetPos()
	tr.endpos = tr.start + self:GetForward() * 250
	tr.filter = self
	trace = util.TraceLine( tr )
	
	if ( trace.Hit && trace.HitSky ) then
		
		self:Remove()
		
	end
	
	if ( IsValid( self.Target ) ) then 
		
		local dir = ( (self.Target:LocalToWorld(self.Target:OBBCenter()) - self.Entity:GetPos()):Angle())
		local d = self:GetPos():Distance( self.Target:GetPos() )
		local a = self:GetAngles()
		a.p, a.r, a.y = apr( a.p, dir.p, 2.4 ),apr( a.r, dir.r, 4 ),apr( a.y, dir.y, 4.0 )

		self:SetAngles( a )
	
	end

	self.PhysObj:SetVelocity( self:GetForward() * self.Speed )
	
end

function ENT:Think()
	
	if ( !IsValid( self.Target ) ) then
	
		local a = self.PhysObj:GetAngles()
		// Alcohol Induced Rockets aka Drunk Fire
		self.PhysObj:SetAngles( Angle( a.p + math.sin( CurTime() - self.seed ) * .09, 
									  a.y + math.cos( CurTime() - self.seed ) * .09,
									  a.r + 2.58123 ) )
		
		return false
		
	else
	
		local a = self:GetPos()
		local ta = ( self.Target:GetPos() - a ):Angle()
		local ma = self:GetAngles()
		local offs = self:VecAngD( ma.y, ta.y )	
		
		if ( offs > -85 && offs < 85 ) then
			
			// Nothing, we can still hit.
			
		else
			
			// Can't locate enemy so we clear the target and the rocket sails away.
			self.Target = NULL
		
		end
	
	end
	
	self:EmitSound("Missile.Accelerate")
	
	local tr, trace = {}, {}
	tr.start = self:GetPos() + self:GetForward() * 72
	tr.endpos = self:GetPos() + self:GetForward() * 300
	tr.filter = self
	tr.mask = MASK_SOLID
	
	trace = util.TraceLine( tr )
	
	if( trace.Hit ) then
	
		for i=0,3 do
		
			local explo1 = EffectData()
			explo1:SetOrigin(self.Entity:GetPos())
			explo1:SetScale(7.25)
			util.Effect("HelicopterMegaBomb", explo1)
			
		end
	
		for i=1,10 do
			
			local fx=EffectData()
			fx:SetOrigin(self.Entity:GetPos()+Vector(math.random(-256,256),math.random(-256,256),math.random(-256,256)))
			fx:SetScale(20*i)
			util.Effect("Firecloud",fx)
		
		end
		
		util.BlastDamage( self.Owner, self.Owner, self.Entity:GetPos(), 900, self.Damage )
		
		self:EmitSound( "explosion3.wav", 511, 100 )
		self:Remove()
		
	end
	
end 

function ENT:OnRemove()

	self:StopSound("Missile.Accelerate")
	
end
