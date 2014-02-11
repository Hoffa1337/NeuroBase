AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include( 'shared.lua' )

ENT.Sauce = 3500
ENT.Delay = 2
ENT.Speed = 5000

function ENT:OnTakeDamage(dmginfo)
 self:NA_RPG_damagehook()
 end

function ENT:Initialize()
	

	
	self:SetModel( "models/weapons/w_missile_closed.mdl" )
	local rand = math.random( 0,1 )
	self.dir = rand == 1 && 1 or -1
	self.seed = self.dir * math.random( 0, 1000 )
	self:PhysicsInit( SOLID_VPHYSICS )
	self:SetMoveType( MOVETYPE_VPHYSICS )	
	self:SetSolid( SOLID_VPHYSICS )
	self.Owner = self:GetOwner()
	
	
	self.PhysObj = self:GetPhysicsObject()
	
	if ( self.PhysObj:IsValid() ) then
		
		self.PhysObj:EnableGravity(false)
		self.PhysObj:EnableDrag(true)
		self.PhysObj:Wake()
		
	end
	
	util.PrecacheSound("Missile.Accelerate")


	local smoketrail = ents.Create("env_rockettrail")
	smoketrail:SetPos(self:GetPos() + self:GetForward() * -5)
	smoketrail:SetParent(self)
	smoketrail:SetLocalAngles(Angle(0,0,0))
	smoketrail:Spawn()

	
	util.SpriteTrail( self, 1, Color(255,255,255,50), false, 16, 0, 0.2, math.sin(CurTime()) / math.pi * 0.5, "trails/smoke.vmt");  

end

function ENT:PhysicsCollide( data, physobj )
	
	if ( !IsValid( self.Owner ) ) then
		
		self.Owner = self
		
	end
	
	if ( data.Speed > 50 && data.DeltaTime > 0.2 ) then 
	
		local explo = EffectData()
		explo:SetOrigin(self:GetPos())
		explo:SetStart( data.HitNormal * 100 )
		explo:SetScale( 1.20 )
		explo:SetNormal(data.HitNormal)
		util.Effect("super_explosion", explo)
		util.BlastDamage( self.Owner, self.Owner, data.HitPos, 1024, 380 )
		self:NeuroPlanes_BlowWelds( self:GetPos(), 1500 )
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
	
	if ( trace.Hit && trace.HitSky ) then
		
		self:Remove()
		
	end
	
	if ( IsValid( self.Target ) ) then 
		
		--[[local swirl = Vector( 
								math.sin( CurTime() + ( self:EntIndex() * 10000 ) ) * 512, 
								math.cos( CurTime() + ( self:EntIndex() * math.random(1000,9001) ) ) * 512, 
								math.sin( CurTime() + ( self:EntIndex() * 10000 ) ) * 512 
							)]]--
		
		local dir = ( self.Target:GetPos()   - self:GetPos() ):Angle()
		local d = self:GetPos():Distance( self.Target:GetPos() )
		local a = self:GetAngles()
		a.p, a.r, a.y = apr( a.p, dir.p, 2.5 ),0,apr( a.y, dir.y, 4.0 )

		self:SetAngles( a )
	
	end

	self.PhysObj:SetVelocity( self:GetForward() * self.Speed )
	
end

function ENT:Think()
	
	if ( !IsValid( self.Target ) ) then
	
		local a = self.PhysObj:GetAngle()
		// Alcohol Induced Rockets aka Drunk Fire
		self.PhysObj:SetAngles( Angle( a.p + math.sin( CurTime() * self.seed ) * .54, 
									  a.y + math.cos( CurTime() * self.seed ) * .54,
									  0 ) )
		
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
			self.Target = nil
		
		end
	
	end
	
	self:EmitSound("Missile.Accelerate")
	
	for k,v in pairs( ents.FindInSphere( self:GetPos(), 64 ) ) do
	
		if ( v && IsValid( v ) && v == self.Target ) then
		
			local explo = EffectData()
			explo:SetOrigin( self:GetPos() )
			explo:SetStart( Vector(0,0,90) )
			explo:SetScale( 0.50 )
			explo:SetNormal( Vector( 0, 0, 1 ) )
			util.Effect("super_explosion", explo)
			util.BlastDamage( self.Owner, self.Owner, self:GetPos(), 612, 300 )
			self:NeuroPlanes_BlowWelds( self:GetPos(), 1024 )
			
			self:Remove()
			
		end
		
	end 
	
end 

function ENT:OnRemove()

	self:StopSound("Missile.Accelerate")
	
end
