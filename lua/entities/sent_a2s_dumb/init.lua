AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include( 'shared.lua' )

ENT.Sauce = 900
ENT.Delay = 0
ENT.Speed = 5000


function ENT:Initialize()
	
	self.seed = math.random( 0, 1000 )
	
	self:SetModel( "models/weapons/w_missile_closed.mdl" )
	self:PhysicsInit( SOLID_VPHYSICS )
	self:SetMoveType( MOVETYPE_VPHYSICS )	
	self:SetSolid( SOLID_VPHYSICS )
	-- self:SetColor( Color( 0, 0, 0, 0 ) )
	
	-- self.Owner = self:GetOwner().Owner or self // lolol
	

	self.PhysObj = self:GetPhysicsObject()
	
	if ( self.PhysObj:IsValid() ) then
	
		self.PhysObj:Wake()
	
	end
	
	-- /*
	-- local ent = ents.Create( "rpg_missile" )
	-- ent:SetPos( self:GetPos() )
	-- ent:SetParent( Self )
	-- ent:SetAngles( self:GetAngles() )
	-- ent:Spawn()
	-- ent:Activate() */
	self.SpawnTime = CurTime()
	
	util.PrecacheSound("Missile.Accelerate")
	
	util.SpriteTrail(self, 0, Color(255,255,255,math.random(120,160)), false, 8, math.random(1,2), 1, math.random(1,3), "trails/smoke.vmt");  
	
end

function ENT:PhysicsCollide( data, physobj )
	
	//if( self.SpawnTime + 0.01 <= CurTime() ) then return end
	
	if ( IsValid( data.HitEntity ) && data.HitEntity:GetOwner() == self:GetOwner() ) then // Plox gief support for SetOwner ( table )
		
		return
		
	end
	
	if (data.Speed > 1 && data.DeltaTime > 0.1 ) then 
	
		util.BlastDamage( self.Owner, self.Owner, data.HitPos, 500, 200 )
		//self:EmitSound( "Explosion2.mp3", 511, math.random( 70, 100 ) )
		//self:ExplosionImproved()
		self:Remove()
		
		
	end
	
end

function ENT:PhysicsUpdate()
	self.PhysObj = self:GetPhysicsObject()
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
					
			local a = self.PhysObj:GetAngles()
			// Alcohol Induced Rockets aka Drunk Fire
			self.PhysObj:SetAngles( Angle( a.p + math.sin( CurTime() - self.seed ) * .1, 
										  a.y + math.cos( CurTime() - self.seed ) * .1,
										  a.r + .1 ) )
										  
		else
		
			self.PhysObj:EnableGravity(true)
			self.PhysObj:EnableDrag(true)
			self.PhysObj:SetMass(100)
			
		end
		
	end

	
end

function ENT:Think()
	
	if( self:WaterLevel() > 0 ) then
	
		self:Remove()
		
	end
	
	if self.Delay > 0 then
		self.Delay = self.Delay - 1
		self.Flying = false
	else
		self.Flying = true
		self.Delay = 0
	end
	
	self:EmitSound("Missile.Accelerate")
	
end 

function ENT:OnRemove()

	self:StopSound("Missile.Accelerate")
	
	
	local ent = ents.Create( "env_explosion" )
	ent:SetPos( self:GetPos() )
	ent:Spawn()
	ent:Activate()
	
	for i=0,5 do
	
		local explo1 = EffectData()
		explo1:SetOrigin(self:GetPos()+i*Vector(math.Rand(-15,15),math.Rand(-15,15),-2))
		explo1:SetScale(0.25)
		util.Effect("HelicopterMegaBomb", explo1)
		
	end
	
end
