AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include( 'shared.lua' )

ENT.Sauce = 100
ENT.Delay = 0
ENT.Speed = 8000

function ENT:Initialize()
	
	self.seed = math.random( 0, 1000 )

--//Need a better bullet model! Using the hl2 AR2 grenade until the new model...	
--	self:SetModel( "models/Shells/shell_large.mdl" )

	self:SetModel( "models/Items/AR2_Grenade.mdl" )
	self:PhysicsInit( SOLID_VPHYSICS )
	self:SetMoveType( MOVETYPE_VPHYSICS )	
	self:SetSolid( SOLID_VPHYSICS )
	self.Radius = self.Radius or 32
	
	self.PhysObj = self:GetPhysicsObject()
	
	if ( self.PhysObj:IsValid() ) then
		self.PhysObj:Wake()
		self.PhysObj:SetMass( 50 )
		
	end
	local TrailDelay = math.Rand( .25, .5 ) / 11
	local TraceScale1 = .5
	local TraceScale2 = .5
	local GlowProxy = 1
	-- print( "GlowProxy: ", GlowProxy, self.TracerGlowProxy )
	-- if( self.TinyTrail ) then
		
		-- self.SpriteTrail = util.SpriteTrail( self, 0, Color( math.random(245,255), math.random(245,255), math.random(245,255), math.random(25,45) ), false, 4,0, TrailDelay + 0.85, 1/(1)*0.55, "trails/smoke.vmt");  
		-- self.SpriteTrail2 = util.SpriteTrail( self, 0, Color( 255, 255, 100, 255 ), false, 4, 4, TrailDelay + 0.05, 1/(0+4)*0.55, "sprites/smokez");  
		
		self.SpriteTrail = util.SpriteTrail( 
							self, 
							0, 
							Color( 255, 
							205, 
							100, 
							225 ), 
							false,
							8, 
							8, 
							TrailDelay, 
							 1 / ( 0 + 6) * 0.5, 
							"trails/smoke.vmt" );
							
		self.SpriteTrail2 = util.SpriteTrail( 
							self, 
							0, 
							Color( 255, 
							255, 
							255, 
							15 ), 
							true,
							12, 
							0, 
							TrailDelay*60, 
							 1 / ( 0 + 48 ) * 0.5, 
							"trails/smoke.vmt" );
							
		local Glow = ents.Create("env_sprite")				
		Glow:SetKeyValue("model","sprites/orangeflare1.vmt")
		Glow:SetKeyValue("rendercolor","255 150 100")
		Glow:SetKeyValue("scale",tostring(TraceScale1))
		Glow:SetPos(self:GetPos())
		Glow:SetParent(self)
		Glow:Spawn()
		Glow:Activate()
	
		local Shine = ents.Create("env_sprite")
		Shine:SetPos(self:GetPos())
		Shine:SetKeyValue("renderfx", "0")
		Shine:SetKeyValue("rendermode", "5")
		Shine:SetKeyValue("renderamt", "255")
		Shine:SetKeyValue("rendercolor", "255 130 100")
		Shine:SetKeyValue("framerate12", "20")
		Shine:SetKeyValue("model", "light_glow01.spr")
		Shine:SetKeyValue("scale", tostring( TraceScale2 ) )
		Shine:SetKeyValue("GlowProxySize", tostring( GlowProxy ))
		Shine:SetParent(self)
		Shine:Spawn()
		Shine:Activate()
		
		-- local Shell = EffectData()
		-- Shell:SetStart( self:GetPos() + self:GetForward() * -1)
		-- Shell:SetOrigin( self:GetPos() + self:GetForward() * -1)
		-- Shell:SetNormal( self:GetRight() * -1 )
		-- Shell:SetEntity( self )
		-- util.Effect( "SMOKE", Shell )  
		
	-- else
	
		-- //Flyby sound	util.PrecacheSound("")
		
		-- self.SmokeTrail = ents.Create( "env_spritetrail" )
		-- self.SmokeTrail:SetParent( self )	
		-- self.SmokeTrail:SetPos( self:GetPos() + self:GetForward() * -3 + self:GetRight() * 4 )
		-- self.SmokeTrail:SetAngles( self:GetAngles() )
		-- self.SmokeTrail:SetKeyValue( "lifetime", TrailDelay )
		-- self.SmokeTrail:SetKeyValue( "startwidth", 4 )
		-- self.SmokeTrail:SetKeyValue( "endwidth", math.random(2,3) )
		-- self.SmokeTrail:SetKeyValue( "spritename", "trails/smoke.vmt" )
		-- self.SmokeTrail:SetKeyValue( "renderamt", 235 )
		-- self.SmokeTrail:SetKeyValue( "rendercolor", "255 255 255" )
		-- self.SmokeTrail:SetKeyValue( "rendermode", 5 )
		-- self.SmokeTrail:SetKeyValue( "HDRColorScale", .75 )
		-- self.SmokeTrail:Spawn()
		
		
		-- self.SpriteTrail = util.SpriteTrail( self, 0, Color( math.random(245,255), math.random(245,255), math.random(244,255), math.random(21,22) ), false, math.random(3,5), math.random(2,3), TrailDelay + 0.85, 1/(0+4)*0.5, "trails/smoke.vmt");  

		-- local Shell = EffectData()
		-- Shell:SetStart( self:GetPos() + self:GetForward() * -100)
		-- Shell:SetOrigin( self:GetPos() + self:GetForward() * -100)
		-- Shell:SetNormal( self:GetRight() * -1 )
		-- util.Effect( "RifleShellEject", Shell )  

		
	-- end
	
	self:DeleteOnRemove( self.SpriteTrail )
		
	-- local e = EffectData()
	-- e:SetStart( self:GetPos() )
	-- e:SetOrigin( self:GetPos() )
	-- e:SetNormal( self:GetForward() )
	-- e:SetAngles( self:GetAngles() )
	-- e:SetEntity( self )
	-- e:SetAttachment( 0 )
	-- e:SetScale( 1.35 )
	-- util.Effect( "MuzzleEffect", e )
	
	-- )
	
	-- self:SetAngles( self:GetAngles() + Angle( math.Rand(-.05,.05 ), math.Rand(-.05,.05 ), math.Rand(-.05,.05 ) ) )
	-- self:GetPhysicsObject():SetVelocity( self:GetForward() * 2000 )
	-- self.StartTime = CurTime()

end

function ENT:PhysicsCollide( data, physobj )
	
	if( data.HitEntity.Owner == self.Owner ) then return end 
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
	self:NextThink(CurTime())
	if( IsValid( self ) ) then 
		self:GetPhysicsObject():Wake()
	end 
			
	return true 
	
end 

function ENT:PhysicsUpdate()

	if(  self:WaterLevel() > 0 ) then
		
		self:Remove()
		
		return
		
	end

end

-- function ENT:PhysicsUpdate()
	
	-- local tr,trace ={},{}
	-- tr.start = self:GetPos()
	-- tr.endpos = tr.start + self:GetForward() * 20
	-- tr.filter = { self, self.Owner }
	-- tr.mask = MASK_SHOT_HULL
	-- trace = util.TraceLine( tr )
	-- self:DrawLaserTracer( tr.start, tr.endpos )
	-- if( trace.Hit ) then
		
		-- self:GetPhysicsObject():Sleep()
		-- self:Remove()
		
		-- return
		
	-- end
	
-- end

function ENT:OnRemove()
	
	-- print( self.Owner )
	if ( !IsValid( self.Owner ) ) then
	
		self.Owner = self
		
	end
	
	local dmg = 400
	local radius = self.Radius or 50
	if( self.MinDamage && self.MaxDamage ) then
		
		dmg = math.random( self.MinDamage, self.MaxDamage )
		
	end
	
	local fx_air = "microplane_midair_explosion"
	local fx_water = "WaterSurfaceExplosion"
	local ImpactSound = "WT/Sounds/shell_explosion_"..math.random(1,2)..".wav"
	if( dmg > 3000 ) then 
		
		fx_air = "rt_impact_tank"
		fx_water = "water_impact_big"
	
	end
	-- print( dmg )
	if( self:WaterLevel() == 0 ) then
	
		ParticleEffect( fx_air, self:GetPos(), Angle( 0,0,0 ), nil )

		if( self.HitSquishy ) then
			
			util.Effect("micro_he_blood", impact)
			self:EmitSound( "Bullet.Flesh", 511, 80 )
					
		end 
		
	else

		if( dmg > 3000 ) then 
			
			ParticleEffect( fx_water, self:GetPos(), Angle( 0,0,0 ), nil )

		else 
			
			local impact = EffectData()
			impact:SetOrigin( self:GetPos() + Vector( 0,0,2))
			impact:SetStart( self:GetPos()  + Vector( 0,0,2))
			impact:SetScale( 2 )
			impact:SetNormal( self.HitNormal or self:GetForward()*-1 )
			util.Effect( fx_water, impact)
			
		end 
		
		ImpactSound = "misc/shel_hit_water_"..math.random(1,3)..".wav"
		
	end
		self:PlayWorldSound( ImpactSound )

	-- local impact = EffectData()
	-- impact:SetOrigin( self:GetPos() )
	-- impact:SetStart( self:GetPos() )
	-- impact:SetScale( 1.0 )
	-- impact:SetNormal( self:GetForward()*-1 )
	-- util.Effect("Explosion", impact)
	-- ParticleEffect( "30cal_impact", self:GetPos(), Angle( 0,0,0 ), nil )

	if( IsValid( self.Owner ) && IsValid( self.Owner.Pilot ) ) then -- how the fuck is this happening?
		
		self.Owner = self.Owner.Pilot
		
	end
	-- print(radius, dmg)
	util.BlastDamage( self, self.Owner, self.HitPos or self:GetPos(), radius, dmg )
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
