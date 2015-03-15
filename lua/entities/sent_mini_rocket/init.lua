AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include( 'shared.lua' )

ENT.Sauce = 50
ENT.Delay = 0
ENT.Speed = 1250
function ENT:OnTakeDamage(dmginfo)
 self:NA_RPG_damagehook(dmginfo)
 end

function ENT:Initialize()
	
	self.seed = math.random( 0, 1000 )
	
//	self:SetModel( "models/weapons/w_missile_closed.mdl" )
	self:PhysicsInit( SOLID_VPHYSICS )
	self:SetMoveType( MOVETYPE_VPHYSICS )	
	self:SetSolid( SOLID_VPHYSICS )
	
	self.Owner = self:GetOwner().Owner or self // lolol
	
	self.PhysObj = self:GetPhysicsObject()
	
	if ( self.PhysObj:IsValid() ) then
	
		self.PhysObj:Wake()
	
	end
	
	util.PrecacheSound("Missile.Accelerate")
	local Glow = ents.Create("env_sprite")				
	Glow:SetKeyValue("model","orangecore2.vmt")
	Glow:SetKeyValue("rendercolor","255 150 100")
	Glow:SetKeyValue("scale",tostring(0.11))
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
	Shine:SetKeyValue("scale", tostring( 0.1 ) )
	Shine:SetKeyValue("GlowProxySize", tostring( 0.1 ))
	Shine:SetParent(self)
	Shine:Spawn()
	Shine:Activate()
	self.SpriteTrail = util.SpriteTrail( self, 0, Color( math.random(5,15), math.random(5,15), math.random(5,15), math.random(200,255) ), false, 0, 32, math.Rand( 0.3, 0.5 ), 1/(0+128)*0.5, "trails/smoke.vmt");  
	
end

function ENT:PhysicsCollide( data, physobj )
	
	if ( IsValid( data.HitEntity ) && data.HitEntity:GetOwner() == self:GetOwner() ) then // Plox gief support for SetOwner ( table )
		
		return
		
	end

	self:Remove()

	
end

function ENT:PhysicsUpdate()
	
	
	if( self:WaterLevel() > 0 ) then
		
		self:Remove()
		
	end
	
	local tr, trace = {},{}
	tr.start = self:GetPos()
	tr.endpos = tr.start + self:GetForward() * 250
	tr.filter = self
	trace = util.TraceLine( tr )
	
	if ( trace.Hit && trace.HitSky ) then
		
		self:Remove()
		
	end
	
	if ( !IsValid( self.Owner ) ) then
		self.Owner = self
	end
	
	if self.Flying == true then
		
		if self.Sauce > 1 then
			
			if( IsValid( self.Target ) ) then
		
				if( ( self:GetPos() - self.Target:GetPos() ):Length() < 50 ) then
					
					self:Remove()
					
					return
					
				end 
				self:SetAngles( LerpAngle( 0.1, self:GetAngles(), (self.Target:GetPos() - self:GetPos() ):Angle() ) )
		
			end 
			self.Speed = self.Speed + 200
			self.PhysObj:SetVelocity( self:GetForward() * self.Speed )
			self.Sauce = self.Sauce - 1
			self.Lastvelocity = self:GetVelocity():Length()
			
			local a = self.PhysObj:GetAngles()
			// Alcohol Induced Rockets aka Drunk Fire
			self.PhysObj:SetAngles( ( AngleRand() * .00246 )+ Angle( a.p + math.sin( CurTime() - self.seed ) * .00515, 
										  a.y + math.cos( CurTime() - self.seed ) * .00515,
										  a.r + .1 ) )
										  
		else
		
			self.PhysObj:Wake()
			self.PhysObj:EnableGravity( true )
			self.PhysObj:EnableDrag( true )
			self.PhysObj:SetMass( 1000 )
			
		end
		
	
		
	end
	

	
end

function ENT:Think()
	
	if self.Delay > 0 then
		self.Delay = self.Delay - 1
		self.Flying = false
	else
		self.Flying = true
		self.Delay = 0
	end
	

	self:EmitSound("Missile.Accelerate")
	
end 

function ENT:OnRemove()
	
	self.SpriteTrail:Remove()
	self:EmitSound("BF2/Weapons/Type85_fire.mp3",511,30)
	
	self:StopSound( "Missile.Accelerate" )
	
	local explo1 = EffectData()
	explo1:SetOrigin( self:GetPos() + Vector( 0,0,8 ) )
	explo1:SetNormal( self:GetUp() )
	explo1:SetEntity( self )
	explo1:SetScale( 3.25 )
	util.Effect( "micro_he_impact_plane", explo1 )
	-- util.Effect( "Explosion", explo1 )
	ParticleEffect( "Explosion", self:GetPos()+Vector(0,0,8), self:GetAngles()*-1, nil )
	ParticleEffect( "microplane_midair_explosion", self:GetPos()+Vector(0,0,8), Angle(0,0,0), nil )
		
	if( IsValid( self.Owner ) && IsValid( self.Owner.Pilot ) ) then -- how the fuck is this happening?
		
		self.Owner = self.Owner.Pilot
	
	end
	
	util.BlastDamage( self, self.Owner, self:GetPos(), 128, math.random(250,500) )

end
