AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include( 'shared.lua' )

ENT.Delay = 3
ENT.Speed = 400

function ENT:Initialize()
	
	self.seed = math.random( 0, 1000 )

	self:SetModel( "models/torpedo_float.mdl" )
	self:PhysicsInit( SOLID_VPHYSICS )
	self:SetMoveType( MOVETYPE_VPHYSICS )	
	self:SetSolid( SOLID_VPHYSICS )
	self.Radius = self.Radius or 32
	
	self.PhysObj = self:GetPhysicsObject()
	self:SetRenderMode( RENDERMODE_TRANSALPHA )
	self:SetColor( Color( 255,255,255,255) )
	-- self:SetLegacyTransform( true )

	if ( self.PhysObj:IsValid() ) then
		self.PhysObj:Wake()
		self.PhysObj:SetMass( 500 )
		self.PhysObj:SetBuoyancyRatio( .1 )
		
	end
	
	timer.Simple( 0, function() 
		
		if( IsValid( self ) ) then 
		
			self.keepUp = constraint.Keepupright( self, Angle( 0,0,0 ), 0, 999999 )
			self:SetModelScale( .15, .1 )
			self:Activate() 
		end 
	
	end )
	

end

function ENT:PhysicsCollide( data, physobj )
		
	if( data.HitEntity && data.HitEntity:GetClass() == self:GetClass()  ) then return end 
	
	-- print( physobj:GetMass() )
	-- if( self.StartTime + 0.0125 >= CurTime() ) then return end
	self.HitNormal =  data.HitNormal*-1
	self.HitPos = data.HitPos 
	self.CollideObject = data.HitEntity
	if( IsValid( data.HitEntity ) && data.HitEntity.HealthVal != nil ) then
		
		self.HitObject = true
		if( data.HitEntity:IsNPC() || data.HitEntity:IsPlayer() ) then
			
			self.HitSquishy = true
		
		end
		
	end
	
	-- print( data.HitEntity.OnTakeDamage )
	self:Remove()
	
	-- return
	-- end
	
end

function ENT:Think( )
	

	self.Delay = self.Delay - 1 
	if( self.Delay > 0 ) then return end 
	self:NextThink(CurTime())
	
	if( self.DeployAngle ) then 
		
		self:SetAngles( LerpAngle( FrameTime()*5, self:GetAngles(), self.DeployAngle ) )
	
	end 
	
	self:GetPhysicsObject():SetVelocity( self:GetForward() * self.Speed )
	
	
	local fx = EffectData()
	fx:SetOrigin( self:GetPos() + Vector(0,0,32))
	fx:SetScale( 3.0 )
	util.Effect("waterripple", fx )
	if( IsValid( self ) ) then 
		self:GetPhysicsObject():Wake()
	end 
			
	return true 
	
end 

function ENT:PhysicsUpdate()


end

function ENT:OnRemove()
	
	-- print( self.Owner )
	if ( !IsValid( self.Owner ) ) then
	
		self.Owner = self
		
	end

	local ImpactSound = "WT/Sounds/shell_explosion_"..math.random(1,2)..".wav"
	self:PlayWorldSound( ImpactSound )

		if( self:WaterLevel() == 0 ) then
		
			ParticleEffect( "microplane_midair_explosion", self:GetPos(), Angle( 0,0,0 ), nil )
	
			if( self.HitSquishy ) then
				
				util.Effect("micro_he_blood", impact)
				self:EmitSound( "Bullet.Flesh", 511, 80 )
						
			end 
			
		else
			
			local impact = EffectData()
			impact:SetOrigin( self:GetPos() + Vector( 0,0,2))
			impact:SetStart( self:GetPos()  + Vector( 0,0,2))
			impact:SetScale( 2 )
			impact:SetNormal( self.HitNormal or self:GetForward()*-1 )
			util.Effect("WaterSurfaceExplosion", impact)

		end
	
	local impact = EffectData()
	impact:SetOrigin( self:GetPos() )
	impact:SetStart( self:GetPos() )
	impact:SetScale( 1.0 )
	impact:SetNormal( self:GetForward()*-1 )
	util.Effect("Explosion", impact)
	ParticleEffect( "30cal_impact", self:GetPos(), Angle( 0,0,0 ), nil )

	local dmg = 400
	local radius = self.Radius or 50
	if( self.MinDamage && self.MaxDamage ) then
		
		dmg = math.random( self.MinDamage, self.MaxDamage )
		
	end
	
	if( IsValid( self.Owner ) && IsValid( self.Owner.Pilot ) ) then -- how the fuck is this happening?
		
		self.Owner = self.Owner.Pilot
		
	end
	
	local dmgnfo = DamageInfo()
	dmgnfo:SetAttacker( self.Owner )
	dmgnfo:SetInflictor( self )
	dmgnfo:SetDamage( dmg )
	dmgnfo:SetDamageForce( self:GetVelocity() )
	dmgnfo:SetDamagePosition( self.HitPos or self:GetPos() + self:GetForward() * 32 )
	dmgnfo:SetDamageType( DMG_BULLET )
	
	util.BlastDamageInfo( dmgnfo,self:GetPos() + self:GetForward() * ( self.PenetrationDepth or 8 ), radius )
	-- print(radius, dmg)
	-- util.BlastDamage( self, self.Owner, self:GetPos()+Vector(0,0,8), radius, dmg )
	-- print( self.Owner, radius, dmg, self.CollideObject )
	if( self:WaterLevel() == 0 ) then
	
		-- if( self.TracerScale1 && self.TracerScale1 >= 1 ) then
		
			-- util.Decal( "scorch", self:GetPos(), self.HitNormal && self.HitNormal * -32 or self:GetPos() + self:GetForward() *16 )

		-- else
		
		util.Decal( "SmallScorch", self:GetPos(), self.HitNormal && self:GetPos() + self.HitNormal * -32 or self:GetPos() + self:GetForward() * 16 )

		
		-- end
		
	end
	
	-- self:Remove()
	
end
