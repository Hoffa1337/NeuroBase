AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include( 'shared.lua' )

function ENT:Initialize()

//    self:SetModel( "models/hawx/weapons/mk-82.mdl" )
	self:PhysicsInit( SOLID_VPHYSICS )
	self:SetMoveType( MOVETYPE_VPHYSICS )	
	self:SetSolid( SOLID_VPHYSICS )
	self.TraceLength = 700
	
	self.PhysObj = self:GetPhysicsObject()
	
	-- local junk = ents.Create("prop_physics")
	-- junk:SetPos( self:GetPos() + self:GetForward()*90 )
	-- junk:SetAngles( self:GetAngles() )
	-- junk:SetModel( "models/Gibs/HGIBS.mdl" )
	-- junk:Spawn()
	-- junk:GetPhysicsObject():SetMass( self:GetPhysicsObject():GetMass()  )
	
	-- self.JunkWeld = constraint.Weld( junk, self, 0, 0, 9999999999, true, true )
	
	if (self.PhysObj:IsValid()) then
		
		self.PhysObj:EnableGravity( true )
		self.PhysObj:EnableDrag( true )
		self.PhysObj:SetMass( 15500 )
		self.PhysObj:Wake()
		
	end
	
	util.SpriteTrail(self, 0, Color(255,255,255,math.random(22,25)), false, 16, math.Rand(0.5,1.1), 3, math.random(1,3), "trails/smoke.vmt");  
	
	if( IsValid( self.Owner ) ) then
	
		self:SetVelocity( self.Owner:GetVelocity() )
	
	end
	
end

function ENT:PhysicsUpdate()
	
	if( self.Detonated ) then return end
	
	local tr, trace = {},{}
	tr.start = self:GetPos()
	tr.endpos = tr.start + self:GetForward() * 250
	tr.filter = self
	trace = util.TraceLine( tr )
	
	if ( trace.Hit && trace.HitSky ) then
		
		self:Remove()
		
	end

end

function ENT:Think()
	
	if( self.Detonated ) then return end
	
	local tr, trace = {},{}
	tr.start = self:GetPos() + Vector( 0, 0, -20 )
	tr.endpos = tr.start + Vector( 0, 0, -self.TraceLength )
	tr.filter = { self, self:GetOwner() }
	tr.mask = MASK_SOLID
	trace = util.TraceLine ( tr )
	
	-- self:DrawLaserTracer( tr.start, trace.HitPos )
	
	if ( trace.Hit ) then
		
		local a = self:GetAngles()
		self:SetAngles( Angle( math.random(15,25), a.y, 0 ) )
		self:DispatchCluster()
		
	end

end

function ENT:DispatchCluster()

	-- time before shockwave is initiated and damage is dealt.
	local delay = 1.5
	
	-- freeze the bomb in place and make it invisible so we can delay the shockwave.
	self:SetMoveType( MOVETYPE_NONE )
	self:SetSolid( SOLID_NONE )
	self.Detonated = true
	self:SetRenderMode( RENDERMODE_TRANSALPHA )
	self:SetColor( Color( 0,0,0,0 ) )
	
	if( !IsValid( self.Owner ) ) then self.Owner = self end
	
	-- Play initial blast effect
	ParticleEffect( "FAB_Explosion", self:GetPos(), self:GetAngles(), self )
	util.BlastDamage( self, self.Owner, self:GetPos(), 350, math.random( 125, 175) )
	-- Find somewhere to place the shockwave
	local tr, trace = {},{}
	tr.start = self:GetPos()
	tr.endpos = tr.start + Vector( 0,0,-self.TraceLength )
	tr.filter = self
	tr.mask = MASK_SOLID
	trace = util.TraceLine( tr )
	
	-- delay the shockwave a little
	timer.Simple( delay * trace.Fraction, 
					function() 
						
						if( !IsValid( self ) ) then return end
						
						-- Deal the big damage when the fuel is ignited
						util.BlastDamage( self, self.Owner, self:GetPos() + Vector( 0,0,-128 ), self.TraceLength*3.5, math.random( 1125, 3175) )
						
						local physExplo = ents.Create( "env_physexplosion" )
						physExplo:SetOwner( self.Owner )
						physExplo:SetPos( self:GetPos() )
						physExplo:SetKeyValue( "Magnitude", "500" )	-- Power of the Physicsexplosion
						physExplo:SetKeyValue( "radius", tostring( 5 * self.TraceLength ) )	-- Radius of the explosion
						physExplo:SetKeyValue( "spawnflags", "19" )
						physExplo:Spawn()
						physExplo:Fire( "Explode", "", 0.01 )
						
						if( trace.Hit ) then
						
							-- If we are close enough to the ground when we were set off play a shockwave effect.
							ParticleEffect( "FAB_groundwave", trace.HitPos, ( trace.HitPos - trace.HitNormal ):Angle(), NULL )
							
							-- Shockwave
							util.BlastDamage( self, self.Owner, trace.HitPos, self.TraceLength*5, math.random( 45, 85 ) )
						
							-- delay our removal by 2 seconds so the whole effect gets played.
							self:Fire("kill","",2)
							
						end
						
					end )
				
	
end

function ENT:PhysicsCollide( data, physobj )
	
	if( self.Detonated ) then return end
	
	if (  self:GetOwner().Owner && IsValid( self:GetOwner().Owner ) ) then
		
		self.Owner = self:GetOwner().Owner
	
	else
		
		self.Owner = self
	
	end

	if (data.Speed > 150 && data.DeltaTime > 0.8 ) then
			
		util.Decal("Scorch", data.HitPos + data.HitNormal, data.HitPos - data.HitNormal )
		self:DispatchCluster()
        util.BlastDamage( self.Owner, self.Owner, data.HitPos, 512, 2500 )

	end
	
end
