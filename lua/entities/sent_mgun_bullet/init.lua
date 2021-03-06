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
	self.Radius = 72
	
	self.PhysObj = self:GetPhysicsObject()
	
	if ( self.PhysObj:IsValid() ) then
	
		self.PhysObj:Wake()
	
	end
	local TrailDelay = math.Rand( 0.15, 0.20 )
	
	if( self.TinyTrail ) then
		
		self.SpriteTrail = util.SpriteTrail( self, 0, Color( math.random(225,235), math.random(245,255), math.random(225,235), math.random(245,255) ), false, 1,0, TrailDelay + 0.85, 1/(0+4)*0.55, "trails/smoke.vmt");  

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
	
	local e = EffectData()
	e:SetStart( self:GetPos() )
	e:SetOrigin( self:GetPos() )
	e:SetNormal( self:GetForward() )
	e:SetAngles( self:GetAngles() )
	e:SetEntity( self )
	e:SetScale( math.random(5,10) )
	util.Effect( "A10_muzzlesmoke", e )

	self:SetAngles( self:GetAngles() + Angle( math.Rand(-.05,.05 ), math.Rand(-.05,.05 ), math.Rand(-.05,.05 ) ) )
	
	self.StartTime = CurTime()
	
end

function ENT:PhysicsCollide( data, physobj )
		
	if( self.StartTime + 0.125 >= CurTime() ) then return end
	
	if ( IsValid( data.HitEntity ) && data.HitEntity:GetOwner() == self:GetOwner() ) then // Plox gief support for SetOwner ( table )
		
		return
		
	end
	
	if ( data.Speed > 1 && data.DeltaTime > 0.1 ) then 

		self:Remove()
		
		
	end
	
end

function ENT:PhysicsUpdate()
	
	if( IsValid( self:GetPhysicsObject() ) ) then
	
		self:GetPhysicsObject():ApplyForceCenter( self:GetForward() * 123456790 - Vector( 0,0,600 ) )
		self:GetPhysicsObject():AddAngleVelocity( Vector( 99, 0, 0 ) )
		
	end
	
	if( self:WaterLevel() > 0 ) then
		
		self:Remove()
		
	end
		
end

function ENT:Think()


end 

function ENT:OnRemove()
	
	if ( !IsValid( self.Owner ) ) then
	
		self.Owner = self
		
	end
	
	self:EmitSound( "IL-2/air_can_03.mp3", 511, math.random( 100, 110 ) )
	local impact = EffectData()
	impact:SetOrigin( self:GetPos() )
	impact:SetStart( self:GetPos() )
	impact:SetScale( 1.0 )
	impact:SetNormal( self:GetForward()*-1 )
	util.Effect("FlareSpark", impact)
	
	local dmg = 400
	local radius = self.Radius or 50
	if( self.MinDamage && self.MaxDamage ) then
		
		dmg = math.random( self.MinDamage, self.MaxDamage )
		
	end
	
	util.BlastDamage( self.Owner, self.Owner, self:GetPos() + Vector( 0,0,2 ), dmg, radius )
	
end
