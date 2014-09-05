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
		self.PhysObj:EnableGravity(true)
		self.PhysObj:EnableDrag(false)
		self.PhysObj:SetMass(1500)
		-- self.PhysObj:SetDamping( 0.975,0.975 )
		
	end
	
	self.SpawnTime = CurTime()
	-- self:EmitSound("weapons/mortar/mortar_shell_incomming1.wav",25,110)
	self:EmitSound("BF2/Weapons/Artillery_projectile_"..math.random(1,3)..".mp3")

	util.SpriteTrail(self, 0, Color(255,255,255,math.random(11,12)), false, 3, math.random(0.5,1.1), 0, math.random(1,3), "trails/smoke.vmt");  
end

function ENT:PhysicsUpdate()

	local tr, trace = {},{}
	tr.start = self:GetPos()
	tr.endpos = tr.start + self:GetForward() * 55
	tr.filter = self
	trace = util.TraceLine( tr )
	
	if ( trace.Hit && trace.HitSky || self:WaterLevel() > 0 ) then
		
		if( self:WaterLevel() > 0 ) then
			
			ParticleEffect( "water_impact_big", self:GetPos(), Angle( 0,0,0 ), nil )
			util.BlastDamage( self, self.Owner, self:GetPos() + Vector(0,0,32), 270, math.random( 1500,2500 ) )
			self:EmitSound(  "ambient/explosions/exp"..math.random(1,4)..".wav", 511, 100 )
		
		end
		
		self:Remove()
		
	end

end

function ENT:PhysicsCollide( data, physobj )
	
	if( self.SpawnTime + 0.25 > CurTime() ) then return end
	
	if (  !IsValid( self.Owner ) ) then
	
		self.Owner = self
	
	end

	
	if (data.Speed > 5 && data.DeltaTime > 0.2 ) then 

		ParticleEffect( "rocket_impact_dirt", self:GetPos(), Angle( 0,0,0 ), nil )
		-- 
		self:EmitSound(  "ambient/explosions/exp"..math.random(1,4)..".wav", 511, 100 )
		
		util.BlastDamage( self, self.Owner, data.HitPos, 270, math.random( 1500,2500 ) )
		
		util.Decal("Scorch", data.HitPos + data.HitNormal * 32, data.HitPos - data.HitNormal * 32 )
	
		self:Remove()
	
	end
	
end

function ENT:OnRemove()
end
