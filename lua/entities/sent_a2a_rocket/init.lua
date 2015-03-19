AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include( 'shared.lua' )

ENT.Sauce = 3000
ENT.Delay = 2
ENT.Speed = 5000
ENT.BlastRadius = 256
function ENT:OnTakeDamage(dmginfo)
 self:NA_RPG_damagehook(dmginfo)
 end
function ENT:Initialize()
	
	if ( self:GetModel() ) then
		
		self:SetModel( self:GetModel() )
		
	else
	
		self:SetModel( "models/military2/missile/missile_agm88.mdl" )
		
	end
	
	self.seed = math.random( 0, 1000 )
	
	self:PhysicsInit( SOLID_VPHYSICS )
	self:SetMoveType( MOVETYPE_VPHYSICS )	
	self:SetSolid( SOLID_VPHYSICS )
	-- self.Owner = self:GetOwner().Owner or self
	
	
	self.PhysObj = self:GetPhysicsObject()
	
	if ( self.PhysObj:IsValid() ) then
		
		self.PhysObj:EnableGravity(false)
		self.PhysObj:EnableDrag(true)
		self.PhysObj:Wake()
		
	end
	
	util.PrecacheSound("Missile.Accelerate")

	-- self.smoketrail = {}
	
	-- for i=1,2 do
	
		-- self.smoketrail[i] = ents.Create("env_rockettrail")
		-- self.smoketrail[i]:SetPos(self:GetPos() + self:GetForward() * -83)
		-- self.smoketrail[i]:SetParent(self)
		-- self.smoketrail[i]:SetLocalAngles(Angle(0,0,0))
		-- self.smoketrail[i]:Spawn()
		
	-- end
	
	-- util.SpriteTrail(self, 0, Color(255,255,255,math.random(130,170)), false, 8, math.random(1,2), 2, math.sin(CurTime()) / math.pi * 0.5, "trails/smoke.vmt");  

end

function ENT:PhysicsCollide( data, physobj )
	
	if ( !IsValid( self.Owner ) ) then
		
		self.Owner = self
		
	end
	
	if ( data.Speed > 50 && data.DeltaTime > 0.2 ) then 
		
		self:NeuroTec_Explosion( data.HitPos, 512, 1500, 2500, "HE_impact_dirt" )
	
		self:Remove()
		 
	end
	
end

local function apr(a,b,c)
	local z = math.AngleDifference( b, a )
	return math.Approach( a, a + z, c )
end

function ENT:PhysicsUpdate()

	if( self:WaterLevel() > 0 ) then
		
		self:NeuroPlanes_SurfaceExplosion()
		
		self:Remove()
		
		return
		
	end
	
	local tr, trace = {},{}
	tr.start = self:GetPos()
	tr.endpos = tr.start + self:GetForward() * 250
	tr.filter = self
	trace = util.TraceLine( tr )
	
	if ( trace.Hit && trace.HitSky ) then
		
		self:Remove()
		
	end
	
	if ( IsValid( self.Target ) ) then 
		
		local dir = ( self.Target:GetPos() - self:GetPos() ):Angle()
		local d = self:GetPos():Distance( self.Target:GetPos() )
		local a = self:GetAngles()
		

		self:SetAngles( LerpAngle( 0.125, a, dir ) )
	
	end

	self:GetPhysicsObject():SetVelocity( self:GetForward() * self.Speed )
	
end

function ENT:Think()
	
	if ( !IsValid( self.Target ) ) then
	
		-- local a = self:GetPhysicsObject():GetAngles()
		-- // Alcohol Induced Rockets aka Drunk Fire
		-- self.PhysObj:SetAngles( Angle( a.p + math.sin( CurTime() - self.seed ) * .09, 
									  -- a.y + math.cos( CurTime() - self.seed ) * .09,
									  -- a.r + 2.58123 ) )
		
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
			self.Target = NULL
		
		end
	
	end
	
	self:EmitSound("Missile.Accelerate")
	
	local tr, trace = {}, {}
	tr.start = self:GetPos() + self:GetForward() * 128
	tr.endpos = self:GetPos() + self:GetForward() * 1024
	tr.filter = self
	tr.mask = MASK_SOLID
	
	trace = util.TraceLine( tr )
	
	local fx = {  }
	if( trace.Hit ) then
		

		local effectdata = EffectData()
		effectdata:SetStart( self:GetPos() )
		effectdata:SetOrigin( self:GetPos() )
		effectdata:SetScale( 5 )
		util.Effect( "Explosion", effectdata )
		
		ParticleEffect( "rocket_impact_wall", self:GetPos(), self:GetAngles(), nil )
	
		local bullet = {} 
		bullet.Num 		= math.random(20,25) 
		bullet.Src 		= self:GetPos()+self:GetForward() * 150
		bullet.Dir 		= self:GetAngles():Forward()
		bullet.Spread 	= Vector( .04,.04,.04 )
		bullet.Tracer	= 1	
		bullet.Force	= 1
		bullet.Damage	= math.random( 255, 475 )
		bullet.AmmoType = "Ar2" 
		bullet.TracerName = "GunshipTracer" 
		bullet.Callback = function (a,b,c)
								
								if( IsValid( b.Entity ) ) then
								
									local e = EffectData()
									e:SetOrigin( b.HitPos )
									e:SetNormal( b.HitNormal )
									e:SetScale(0.5)
									
									util.Effect("Explosion", e)
									util.Effect("Launch2", e)
									
									local p = self.Owner.Pilot
									if( !IsValid( p ) ) then
										
										p = self.Owner
										
									end

									
									util.BlastDamage( p, p, b.HitPos, self.BlastRadius, math.random( 15, 105 ) )
									
								end
								
								return { damage = true, effects = DoDefaultEffect }  
							
							end 
								
		self:FireBullets( bullet ) 
		
		self:EmitSound("weapons/ar2/fire1.wav", 511, 30 )
		self:EmitSound( "Explosion2.mp3", 511, math.random( 70, 100 ) )
		
		-- self:NeuroPlanes_BlowWelds( self:GetPos(), 1000 )
		
		self:Remove()
		
	end
	
end 

function ENT:OnRemove()

	self:StopSound("Missile.Accelerate")
	
end
