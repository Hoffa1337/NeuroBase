AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include( 'shared.lua' )

ENT.Sauce = 3500
ENT.Delay = 2
ENT.Speed = 5000
ENT.BlastRadius = 256

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
	self.Owner = self:GetOwner().Owner or self
	
	
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
		
		local explo = EffectData()
		explo:SetOrigin(self:GetPos())
		explo:SetStart( data.HitNormal * 100 )
		explo:SetScale( 1.20 )
		explo:SetNormal(data.HitNormal)
		util.Effect("Airstrike_explosion", explo)
		util.BlastDamage( self.Owner, self.Owner, data.HitPos, self.BlastRadius, 950)
		self:NeuroPlanes_BlowWelds( self:GetPos(), 600 )
		
		self:Remove()
		 
	end
	
end

local function apr(a,b,c)
	local z = math.AngleDifference( b, a )
	return math.Approach( a, a + z, c )
end

function ENT:PhysicsUpdate()

	if( self:WaterLevel() > 1 ) then
		
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
		a.p, a.r, a.y = apr( a.p, dir.p, 2.4 ),apr( a.r, dir.r, 4 ),apr( a.y, dir.y, 4.0 )

		self:SetAngles( a )
	
	end

	self.PhysObj:SetVelocity( self:GetForward() * self.Speed )
	
end

function ENT:Think()
	
	if ( !IsValid( self.Target ) ) then
	
		local a = self.PhysObj:GetAngles()
		// Alcohol Induced Rockets aka Drunk Fire
		self.PhysObj:SetAngles( Angle( a.p + math.sin( CurTime() - self.seed ) * .09, 
									  a.y + math.cos( CurTime() - self.seed ) * .09,
									  a.r + 2.58123 ) )
		
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
	tr.endpos = self:GetPos() + self:GetForward() * 2800
	tr.filter = self
	tr.mask = MASK_SOLID
	
	trace = util.TraceLine( tr )
	
	local fx = { "Flaksmoke", "ac130_napalm" }
	if( trace.Hit ) then
		
		for i=1,10 do 

			local effectdata = EffectData()
			effectdata:SetStart( self:GetPos() + self:GetForward() * i * 25 )
			effectdata:SetOrigin( self:GetPos() + self:GetForward() * i * 25 )
			effectdata:SetScale( 5 )
	
			util.Effect( fx[math.random(1,2)], effectdata )
		
		
		end
					
		local bullet = {} 
		bullet.Num 		= math.random(15,22) 
		bullet.Src 		= self:GetPos()+self:GetForward() * 150
		bullet.Dir 		= self:GetAngles():Forward()
		bullet.Spread 	= Vector( .03,.03,.03 )
		bullet.Tracer	= 1	
		bullet.Force	= 1
		bullet.Damage	= math.random( 155, 375 )
		bullet.AmmoType = "Ar2" 
		bullet.TracerName = "GunshipTracer" 
		bullet.Callback = function (a,b,c)
								
								if( IsValid( b.Entity ) ) then
								
									local e = EffectData()
									e:SetOrigin( b.HitPos )
									e:SetNormal( b.HitNormal )
									e:SetScale(0.5)
									
									util.Effect("HelicopterMegaBomb", e)
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
