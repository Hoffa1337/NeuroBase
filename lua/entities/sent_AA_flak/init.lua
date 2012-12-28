AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include( 'shared.lua' )

ENT.AutoDetonateTimer = 0

function ENT:Initialize()

	self.Entity:SetModel( "models/hawx/weapons/cbu-94 blackoutbomb.mdl" )
	self.Entity:PhysicsInit( SOLID_VPHYSICS )
	self.Entity:SetMoveType( MOVETYPE_VPHYSICS )	
	self.Entity:SetSolid( SOLID_BSP )
	self.MaxTime = math.random(8,16)
	self.PhysObj = self.Entity:GetPhysicsObject()
	
	if (self.PhysObj:IsValid()) then
	
		self.PhysObj:Wake()
		self.PhysObj:EnableGravity( true ) 
		
	end

	util.SpriteTrail(self, 0, Color(255,255,255,80), false, math.random(2,5), math.random(1,2), 2, math.random(1,3), "trails/smoke.vmt");  
	
end

function ENT:PhysicsCollide( data, physobj )
	
	if ( !IsValid( self.Owner ) ) then
		
		self.Owner = self
		
	end
	
	if ( data.Speed > 150 && data.DeltaTime > 0.1 ) then 

		util.BlastDamage( self.Owner, self.Owner, data.HitPos, 768, math.random( 25,35 ))
		
		local fx = EffectData()
		fx:SetOrigin(data.HitPos)
		util.Effect("Flaksmoke",fx)

		self:EmitSound( "ambient/fire/gascan_ignite1.wav",211,100 )

		self.Entity:Remove()
		
	end
	
end

function ENT:Think()
	
	if( !IsValid( self.Owner ) ) then
		
		self.Owner = self
	
	end
	
	local tr, trace = {},{}
	tr.start = self:GetPos()
	tr.endpos = tr.start + self:GetForward() * 250
	tr.filter = self
	tr.mask = MASK_SOLID
	trace = util.TraceLine( tr )
	
	if( trace.HitSky ) then
	
		self.AutoDetonateTimer = self.MaxTime // poff
	
	end
	
	
	self.AutoDetonateTimer = self.AutoDetonateTimer + 1
	
	//print( self.AutoDetonateTimer )
	
	if( self.AutoDetonateTimer >= self.MaxTime ) then
		
		local p = Vector( math.random( -128,128), math.random( -128,128), math.random( -128,128) ) 
		util.BlastDamage( self.Owner, self.Owner, self:GetPos() + p, 1200, math.random( 50,100 ))

		fx = EffectData()
		fx:SetOrigin( self:GetPos() + p )
		util.Effect( "Flaksmoke",fx )
		
		self:EmitSound( "ambient/fire/gascan_ignite1.wav",211,100 )
		
		self:Remove()
		
		return
		
	end
	
	
	if( self:WaterLevel() > 0 ) then
	
		self:Remove()
	
	end
	
	if ( !IsValid( self.Owner ) ) then
		
		self.Owner = self
		
	end
	
	for k,v in pairs( ents.FindInSphere(self:GetPos(), 1000 ) ) do
	
		if ( ( v:IsNPC() || v.HealthVal ) && v != self.Owner && v:GetParent() != self.Owner && self.AutoDetonateTimer > ( self.MaxTime * 0.5 ) ) then
			
			local p = Vector( math.random( -128,128), math.random( -128,128), math.random( -128,128) ) 
			util.BlastDamage( self.Owner, self.Owner, self:GetPos() + p, 1200, math.random( 50,100 ))

			fx = EffectData()
			fx:SetOrigin( self:GetPos() + p )
			util.Effect("Flaksmoke",fx)
			
			self:EmitSound( "ambient/fire/gascan_ignite1.wav",211,100 )
			
			self:Remove()
		
		end
	
	end

end
