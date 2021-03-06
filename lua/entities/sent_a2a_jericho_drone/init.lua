AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include( 'shared.lua' )

ENT.Sauce = 9000
ENT.Delay = 1
ENT.Speed = 5000

-- function ENT:OnTakeDamage(dmginfo)
 -- self:NA_RPG_damagehook(dmginfo)
 -- end

function ENT:Initialize()
	
	self.seed = math.random( 0, 1000 )
	
	self:SetModel( "models/weapons/w_missile_closed.mdl" )
	self:PhysicsInit( SOLID_VPHYSICS )
	self:SetMoveType( MOVETYPE_VPHYSICS )	
	self:SetSolid( SOLID_VPHYSICS )
	
	--self.Owner = self:GetOwner():GetOwner().Pilot or self
	
	self.PhysObj = self:GetPhysicsObject()
	
	if ( self.PhysObj:IsValid() ) then
	
		self.PhysObj:Wake()
	
	end
		
	util.PrecacheSound("Missile.Accelerate")
	self.Sound = CreateSound( self, "Missile.Accelerate" )
	
	util.SpriteTrail( self, 0, Color(255,255,255,math.random(230,255)), false, 16, 0, 0.15, math.random(1,3), "trails/smoke.vmt");  
	
end

function ENT:PhysicsCollide( data, physobj )
	
	if( !IsValid( self.Owner ) ) then
		
		self.Owner = self
		
	end
	
	if ( IsValid( data.HitEntity ) && data.HitEntity:GetOwner() == self:GetOwner() ) then // Plox gief support for SetOwner ( table )
		
		return
		
	end
	
	if (data.Speed > 10 && data.DeltaTime > 0.2 ) then 
		
		ParticleEffect( "rocket_impact_wall", self:GetPos(), self:GetAngles(), nil )
		self:Remove()
	
	end
	
end

local function apr(a,b,c)
	local z = math.AngleDifference( b, a )
	return math.Approach( a, a + z, c )
end

function ENT:PhysicsUpdate()
	
	local tr, trace = {},{}
	tr.start = self:GetPos()
	tr.endpos = tr.start + self:GetForward() * 250
	tr.filter = self
	trace = util.TraceLine( tr )
	
	if( self:WaterLevel() > 0 ) then
		
		self:Remove()
		
		return
		
	end
	
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
		
		else
		
			self.PhysObj:EnableGravity(true)
			self.PhysObj:EnableDrag(true)
			self.PhysObj:SetMass(100)
			
		end
		
	end
	
	local amt = 4.5
	
	if ( IsValid( self.Target ) ) then 
		
		local pos = Vector( 0, math.sin(CurTime() + ( self:EntIndex() * 5 ) ) * 1612, math.cos(CurTime() + ( self:EntIndex() * 5 ) ) * 1612 )
		local dist = self:GetPos():Distance( self.Target:GetPos() )
		
		if( dist  < 2500 ) then
			
			pos = Vector(0,0,0)
			amt = 10
			
		end
		
		
		if( dist < 250 ) then
		
			local explo = EffectData()
			explo:SetOrigin(self:GetPos())
			util.Effect("Explosion", explo)
			
			ParticleEffect( "rocket_impact_wall", self:GetPos(), self:GetAngles(), nil )
			
			local own = self.Owner
			if( !IsValid( own ) ) then own = self end
			
			util.BlastDamage( self, own, self:GetPos(), self.Radius or 256, self.Damage or 512 )
			
			-- 
			self:Remove()
			
			return
			
		end
		
		local dir = ( ( self.Target:GetPos() + pos ) - self:GetPos() ):Angle()
		local a = self:GetAngles()
		a.p, a.r, a.y = apr( a.p, dir.p, amt ),apr( a.r, dir.r, amt ),apr( a.y, dir.y,amt )

		self:SetAngles( a )
	
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
	
	self.Sound:PlayEx( 1.0, 100 )
	
end 

function ENT:OnRemove()

	self.Sound:Stop()
	
end
