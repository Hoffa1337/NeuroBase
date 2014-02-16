AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include( 'shared.lua' )
ENT.Sauce = 500
function ENT:OnTakeDamage(dmginfo)
 self:NA_RPG_damagehook(dmginfo)
 end
function ENT:Initialize()

	self:SetModel( "models/torpedo_float.mdl" )
	self:PhysicsInit( SOLID_VPHYSICS )
	self:SetMoveType( MOVETYPE_VPHYSICS )	
	self:SetSolid( SOLID_VPHYSICS )

	self.PhysObj = self:GetPhysicsObject()
	
	if (self.PhysObj:IsValid()) then

		self.PhysObj:EnableGravity( true )
		self.PhysObj:SetMass( 2000 )
		self.PhysObj:SetBuoyancyRatio( 0.0025 ) --Don't mess with this value or I will find you and stab you with a spork.
		self.PhysObj:EnableDrag( true )
		self.PhysObj:Wake()
		
	end

end

function ENT:PhysicsCollide( data, physobj )

	if ( data.Speed > 50 && data.DeltaTime > 0.2 ) then 
	
		self:Remove()
	
	end
	
end

function ENT:PhysicsUpdate()

	
	if ( IsValid( self.Target ) ) then 
		
		self:GunAim( self.Target )
		
		--Target escaped to the surface. Destroy torpedo
		if( self.Target:WaterLevel() == 0 ) then

			self:Remove()
			
			return
			
		end
	
	else

		
		
	end
	
	if( self:WaterLevel() > 0	) then
	
		if( self.Sauce > 0 ) then
			
			self.PhysObj:SetVelocity( self:GetForward() * 2000 )
			self.Sauce = self.Sauce - 1
	
		end
			
	end
	
	self.LastAngle = self:GetAngles()
	
end


function ENT:OnRemove()
	
	if( self:WaterLevel() > 0 ) then
			
		ParticleEffect( "water_impact_big", self:GetPos(),self:GetAngles(), nil )

	end
	
	local e = EffectData()
	e:SetOrigin( self:GetPos() )
	util.Effect( "Explosion", e )
	
	util.BlastDamage( self, self, self:GetPos(), 750, math.random(750,2500) )

	self:EmitSound("LockOn/ExplodeWater.mp3",300,100)
	
end