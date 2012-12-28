AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include( 'shared.lua' )

ENT.Detonated = false

function ENT:Initialize()

	self:SetModel( "models/props_c17/oildrum001_explosive.mdl" )
	self:PhysicsInit( SOLID_VPHYSICS )
	self:SetMoveType( MOVETYPE_VPHYSICS )	
	self:SetSolid( SOLID_VPHYSICS )

	self.PhysObj = self:GetPhysicsObject()
	
	if ( self.PhysObj:IsValid() ) then
	
		self.PhysObj:EnableGravity( true )
		self.PhysObj:SetMass( 2000 )
		self.PhysObj:SetBuoyancyRatio( 5.0 )
		self.PhysObj:EnableDrag( true )
		self.PhysObj:Wake()
		
	end
	
	self.LastBeep = CurTime()
	
end

function ENT:Boooom()
	
	if( !self.Detonated ) then
		
		self.Detonated = true
		self:EmitSound( "sound/npc/turret_floor/retract.wav", 511, 100 )
		
	end
	
	if( self:WaterLevel() > 0 ) then
		
		for i = 0, 15 do	
				
			local effect2 = EffectData()
			effect2:SetScale( 15 )
			effect2:SetOrigin(self:GetPos() + Vector( math.random(-128,128), math.random(-128,128), 0 ) )
			util.Effect("WaterSurfaceExplosion", effect2 )
			
		end	
		
	end
	
	for i = 0, 15 do
	
		local explo1 = EffectData()
		explo1:SetOrigin( self:GetPos() + Vector( math.random(-128,128), math.random(-128,128), math.random(-128,128) ) )
		explo1:SetScale(6.15)
		util.Effect("HelicopterMegaBomb", explo1 )
		
	end
	
	util.BlastDamage( self.Owner, self.Owner, self:GetPos(), 1500, 1500 )
	
	self:EmitSound("Torpedo_Impact.wav",300,100)

	self:Remove()
	
end

function ENT:PhysicsCollide( data, physobj )

	if ( data.Speed > 50 && data.DeltaTime > 0.2 ) then 
	
		self:Boooom()
	
	end
	
end

function ENT:Think()
	
	if( self.LastBeep + 5.0 <= CurTime() ) then
		
		self.LastBeep = CurTime()
		
		self:EmitSound( "sound/npc/turret_floor/ping.wav", 512, 100 )
	
	end

end
function ENT:PhysicsUpdate()

	for k,v in pairs( ents.FindInSphere( self:GetPos(), 1024 ) ) do
		
		if( type(v) == "CSENT_Vehicle" || string.find( v:GetClass(), "prop_vehicle*") || v:IsVehicle() && v != self.Owner ) then
		
			
			self.PhysObj:ApplyForceCenter( ( self:GetPos() - v:GetPos() ):GetNormalized() * 500 )
			
			if( self:GetPos():Distance( v:GetPos() ) < 200 ) then
				
				self:Boooom()
			
			end
		
		end
	
	end
	
end

function ENT:OnRemove()

	
end
