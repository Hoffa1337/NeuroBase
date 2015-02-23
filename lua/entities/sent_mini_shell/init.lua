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
	
		self.PhysObj:SetMass( 5000000 )
		self.PhysObj:EnableGravity( true )
		self.PhysObj:EnableDrag( true )
		self.PhysObj:Wake()
	
	end
	local TrailDelay = math.Rand( 0.15, 0.20 )/10
	local TraceScale1 = self.TracerScale1 or 0.1
	local TraceScale2 = self.TracerScale2 or 0.1
	local GlowProxy = self.TracerGlowProxy or 1
	-- print( "GlowProxy: ", GlowProxy, self.TracerGlowProxy )
	if( self.TinyTrail ) then
		
		self.SpriteTrail = util.SpriteTrail( self, 0, Color( math.random(245,255), math.random(245,255), math.random(245,255), math.random(5,15) ), false, 4,0, TrailDelay + 0.85, 1/(0+4)*0.55, "trails/smoke.vmt");  
		-- self.SpriteTrail2 = util.SpriteTrail( self, 0, Color( 255, 255, 100, 255 ), false, 4, 4, TrailDelay + 0.05, 1/(0+4)*0.55, "trails/smoke.vmt");  
		
		local Glow = ents.Create("env_sprite")				
		Glow:SetKeyValue("model","orangecore2.vmt")
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
		
	else
	
		-- //Flyby sound	util.PrecacheSound("")
		
		self.SmokeTrail = ents.Create( "env_spritetrail" )
		self.SmokeTrail:SetParent( self )	
		self.SmokeTrail:SetPos( self:GetPos() + self:GetForward() * -3 + self:GetRight() * 4 )
		self.SmokeTrail:SetAngles( self:GetAngles() )
		self.SmokeTrail:SetKeyValue( "lifetime", TrailDelay )
		self.SmokeTrail:SetKeyValue( "startwidth", 4 )
		self.SmokeTrail:SetKeyValue( "endwidth", math.random(2,3) )
		self.SmokeTrail:SetKeyValue( "spritename", "trails/smoke.vmt" )
		self.SmokeTrail:SetKeyValue( "renderamt", 235 )
		self.SmokeTrail:SetKeyValue( "rendercolor", "255 255 255" )
		self.SmokeTrail:SetKeyValue( "rendermode", 5 )
		self.SmokeTrail:SetKeyValue( "HDRColorScale", .75 )
		self.SmokeTrail:Spawn()
		
		
		self.SpriteTrail = util.SpriteTrail( self, 0, Color( math.random(245,255), math.random(245,255), math.random(244,255), math.random(21,22) ), false, math.random(3,5), math.random(2,3), TrailDelay + 0.85, 1/(0+4)*0.5, "trails/smoke.vmt");  

		local Shell = EffectData()
		Shell:SetStart( self:GetPos() + self:GetForward() * -100)
		Shell:SetOrigin( self:GetPos() + self:GetForward() * -100)
		Shell:SetNormal( self:GetRight() * -1 )
		util.Effect( "RifleShellEject", Shell )  
		
	end
	
	-- local e = EffectData()
	-- e:SetStart( self:GetPos() )
	-- e:SetOrigin( self:GetPos() )
	-- e:SetNormal( self:GetForward() )
	-- e:SetAngles( self:GetAngles() )
	-- e:SetEntity( self )
	-- e:SetAttachment( 0 )
	-- e:SetScale( 1.35 )
	-- util.Effect( "MuzzleEffect", e )
	
	-- ParticleEffect( "mg_muzzleflash", self:GetPos(), self:GetAngles(), nil )
	
	self:SetAngles( self:GetAngles() + Angle( math.Rand(-.05,.05 ), math.Rand(-.05,.05 ), math.Rand(-.05,.05 ) ) )
	
	-- self.StartTime = CurTime()
	
end

function ENT:PhysicsCollide( data, physobj )
		
	-- if( self.StartTime + 0.0125 >= CurTime() ) then return end
	self.HitNormal =  data.HitNormal*-1
	
	if ( IsValid( data.HitEntity ) && data.HitEntity:GetOwner() == self:GetOwner() ) then --// Plox gief support for SetOwner ( table )
		
		return
		
	end
	
	-- if ( data.Speed > 1 && data.DeltaTime > 0.1 ) then 
		
		if( IsValid( data.HitEntity ) && data.HitEntity.HealthVal != nil ) then
			
			self.HitObject = true
			if( data.HitEntity:IsNPC() || data.HitEntity:IsPlayer() ) then
				
				self.HitSquishy = true
			
			end
			
		end
		
		self:Remove()
		
	-- end
	
end

function ENT:Think()
	
	if( self:WaterLevel() > 0 ) then
		
		self:Remove()
		
		return
		
	end
		
	
end

function ENT:OnRemove()
	
	if ( !IsValid( self.Owner ) ) then
	
		self.Owner = self
		
	end
	
	self:EmitSound( "IL-2/air_can_03.mp3", 511, math.random( 100, 110 ) )
	
	if( self.ImpactScale && self.ImpactScale >= 2 ) then
		
		local impact = EffectData()
		impact:SetOrigin( self:GetPos() + Vector( 0,0,2) )
		impact:SetStart( self:GetPos()  + Vector( 0,0,2))
		impact:SetScale( 1.0 )
		impact:SetNormal( self.HitNormal or self:GetForward()*-1 )
		util.Effect("Explosion", impact)
		
		-- ParticleEffect( "30cal_impact", self:GetPos(),self.HitNormal:Angle() or Angle( 0,0,0 ), nil )
		-- ParticleEffect( "Explosion", self:GetPos() + Vector( 0,0,2), Angle( 0,0,0 ), nil )

		local impact = EffectData()
		impact:SetOrigin( self:GetPos() + Vector( 0,0,2))
		impact:SetStart( self:GetPos()  + Vector( 0,0,2))
		impact:SetScale( self.ImpactScale*1.5 or 2 )
		impact:SetNormal( self.HitNormal or self:GetForward()*-1 )
		util.Effect("micro_he_impact", impact)
		if( self:WaterLevel() > 0 ) then
			
			util.Effect("WaterSurfaceExplosion", impact)
			
		end
		
	else
	
		local impact = EffectData()
		impact:SetOrigin( self:GetPos() )
		impact:SetStart( self:GetPos() )
		impact:SetScale( self.ImpactScale or 1.5 )
		impact:SetNormal( self.HitNormal or self:GetForward()*-1 )
		
		if( self:WaterLevel() == 0 ) then
		
			if( self.HitSquishy ) then
				
				util.Effect("micro_he_blood", impact)
			
			else
			
				if( self.HitObject ) then
				
					util.Effect("micro_he_impact_plane", impact)
				
				else
					
					util.Effect("micro_he_impact", impact)
				
				end
				
			end 
			
		else
			
			if( self.ImpactScale && self.ImpactScale < 1 ) then
				
				util.Effect("watersplash", impact)
			
				
			else
			
				util.Effect("WaterSurfaceExplosion", impact)
			
			end
			
		end
		
	end
	
	-- local impact = EffectData()
	-- impact:SetOrigin( self:GetPos() )
	-- impact:SetStart( self:GetPos() )
	-- impact:SetScale( 1.0 )
	-- impact:SetNormal( self:GetForward()*-1 )
	-- util.Effect("Explosion", impact)
	-- ParticleEffect( "30cal_impact", self:GetPos(), Angle( 0,0,0 ), nil )
	-- ParticleEffect( "Explosion", self:GetPos(), Angle( 0,0,0 ), nil )
	
	local dmg = 400
	local radius = self.Radius or 50
	if( self.MinDamage && self.MaxDamage ) then
		
		dmg = math.random( self.MinDamage, self.MaxDamage )
		
	end
	
	util.BlastDamage( self.Owner, self.Owner, self:GetPos() + Vector( 0,0,2 ), radius, dmg )
	if( self.TracerScale1 && self.TracerScale1 >= 1 ) then
	
		util.Decal( "scorch", self:GetPos(), self.HitNormal && self.HitNormal * -32 or self:GetPos() + self:GetForward() * 32 )

	else
	
		util.Decal( "SmallScorch", self:GetPos(), self.HitNormal && self.HitNormal * -32 or self:GetPos() + self:GetForward() * 32 )

	
	end
	
end
