AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include( 'shared.lua' )

function ENT:Initialize()

	if ( self:GetModel() ) then		
		self:SetModel( self:GetModel() )		
	else	
		self:SetModel( "models/props_borealis/bluebarrel001.mdl" )	
	end
	self:PhysicsInit( SOLID_VPHYSICS )
	self:SetMoveType( MOVETYPE_VPHYSICS )	
	self:SetSolid( SOLID_VPHYSICS )

	self.PhysObj = self:GetPhysicsObject()
	
	if ( self.PhysObj:IsValid() ) then
	
	-- print("walla")
		self.PhysObj:EnableGravity( true )
		self.PhysObj:SetMass( 5500 )
		self.PhysObj:SetBuoyancyRatio( 6.0 ) --Don't mess with this value or I will find you and stab you with a spork.
		self.PhysObj:EnableDrag( true )
		self.PhysObj:Wake()
		
	end

end

function ENT:PhysicsCollide( data, physobj )

	if ( data.Speed > 50 && data.DeltaTime > 0.2 && self:WaterLevel() > 0 ) then 
	
		for i = 0, 15 do	
		
			local effect2 = EffectData()
			effect2:SetOrigin(self:GetPos() + Vector( math.random(-128,128), math.random(-128,128), math.random(-128,128) ) )
			util.Effect("WaterSurfaceExplosion", effect2 )
			
		end	
		
		for i = 0, 15 do
		
			local explo1 = EffectData()
			explo1:SetOrigin( self:GetPos() + Vector( math.random(-128,128), math.random(-128,128), math.random(-128,128) ) )
			explo1:SetScale(6.15)
			util.Effect("HelicopterMegaBomb", explo1 )
			
		end
		
		util.BlastDamage( self, self, data.HitPos, 2524, math.random( 725, 1250 ) )
		self:EmitSound("Torpedo_Impact.wav",300,100)
	
		self:Remove()
	
	end
	
end

function ENT:PhysicsUpdate()

	for k,v in pairs( ents.FindInSphere( self:GetPos(), 2024 ) ) do
		
		if( v.HealthVal || string.find( v:GetClass(), "prop_vehicle") || v:IsVehicle() ) then
		
			
			self.PhysObj:ApplyForceCenter( ( self:GetPos() - v:GetPos() ):GetNormalized() * 1000 )
		
		
		end
	
	end
	
end

function ENT:OnRemove()

	
end
