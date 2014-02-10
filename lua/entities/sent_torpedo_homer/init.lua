AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include( 'shared.lua' )
ENT.Sauce = 500
function ENT:OnTakeDamage(dmginfo)
	
	if( !self.HealthVal ) then self.HealthVal = 100 end 
  	if( self.HealthVal < 0 ) then return end
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
	
		for i = 0, 6 do	
		
			local effect2 = EffectData()
			effect2:SetOrigin(self:GetPos() + i * Vector(math.Rand(-50,50),math.Rand(-50,50),0))
			util.Effect("WaterSurfaceExplosion", effect2)
			
		end	
		
		for i = 0, 4 do
		
			local explo1 = EffectData()
			explo1:SetOrigin(self:GetPos()+i*self:GetForward()*64)
			explo1:SetScale(6.15)
			util.Effect("HelicopterMegaBomb", explo1)
			
		end
		
		util.BlastDamage( self, self, data.HitPos, 512, 400 )
		
		self:Remove()
	
	end
	
end

function ENT:PhysicsUpdate()

	
	if ( IsValid( self.Target ) ) then 
		
		self:GunAim( self.Target )
		
		--Target escaped to the surface. Destroy torpedo
		if( self.Target:WaterLevel() == 0 ) then
		
			self:ExplosionImproved()
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

	self:EmitSound("Torpedo_Impact.wav",300,100)
	
end
