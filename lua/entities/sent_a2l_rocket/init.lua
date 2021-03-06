AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include( 'shared.lua' )

ENT.Radius = 256
ENT.Damage = 1000
ENT.Speed = 2000
function ENT:OnTakeDamage(dmginfo)
 self:NA_RPG_damagehook(dmginfo)
 end
function ENT:Initialize()
	
	self:PhysicsInit( SOLID_VPHYSICS )
	self:SetMoveType( MOVETYPE_VPHYSICS )	
	self:SetSolid( SOLID_VPHYSICS )
	self.Boosting = false
	self.ControlDelay = CurTime()
	
	self.PhysObj = self:GetPhysicsObject()
	self.Sound = CreateSound(self, "Missile.Accelerate")
	
	if ( self.PhysObj:IsValid() ) then
		
		self.PhysObj:EnableGravity(false)
		self.PhysObj:EnableDrag(true)
		self.PhysObj:Wake()
		
	end
	
	util.PrecacheSound("Missile.Accelerate")

	if ( self:GetModel() ) then
		
		self:SetModel( self:GetModel() )
		
	else
	
		self:SetModel( "models/military2/missile/missile_agm88.mdl" )
		
	end
	
	-- util.SpriteTrail( self, 0, Color( 120,120,120, math.random(110,120)), false, 0, 48, 0.75, math.sin(CurTime()) / math.pi * 48, "trails/smoke.vmt");  

end

function ENT:PhysicsCollide( data, physobj )
	
	if( data.DeltaTime < 0.2 ) then return end

	self:NeuroPlanes_BlowWelds( self:GetPos(), 256 )
	self:EmitSound( "explosion" .. math.random( 3, 5 ) .. ".wav", 511, math.random( 70, 100 ) )
	self:NeuroTec_Explosion( self:GetPos(), 512, 1500, 2500, "HE_impact_dirt" )
	self:Remove()
		
end

local function apr( a, b, c )
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
	
	if ( !IsValid( self.Pointer ) ) then
		
		return
	
	end
	
	
	
	if ( IsValid( self.Pointer ) && self.Pointer:IsPlayer() && self.ControlDelay + 0.6 <=CurTime() ) then 

		self:SetAngles( LerpAngle( 0.18, self:GetAngles(), self.Pointer:EyeAngles() ) )
		
		if( self.Pointer:KeyDown( IN_SPEED ) && !self.Boosting ) then
			
			self.Boosting = true
			
			self.Pointer:PrintMessage( HUD_PRINTCENTER, "Booster Rocket Ignited" )
			
			self:EmitSound( "LockOn/SonicBoom.mp3", 511, 100 )
		
		elseif( self.Boosting ) then
			
			self.Speed = math.Approach( self.Speed, 20000, 200 )
			
		end
		
		if( self.Pointer:KeyDown( IN_ATTACK ) ) then
		
			for i=1,10 do
		
				local fx=EffectData()
				fx:SetOrigin(self:GetPos()+Vector(math.random(-256,256),math.random(-256,256),math.random(-256,256)))
				fx:SetScale(20*i)
				util.Effect("Firecloud",fx)
			
			end
			
			-- util.BlastDamage( self.Pointer, self.Pointer, self:GetPos(), self.Radius, self.Damage )
			self:NeuroPlanes_BlowWelds( self:GetPos(), self.Radius )
			self:EmitSound( "explosion" .. math.random( 3, 5 ) .. ".wav", 511, math.random( 70, 100 ) )
			self:NeuroTec_Explosion( self:GetPos(), 512, 1500, 2500, "HE_impact_dirt" )
			self:Remove()
			
			return
	
			
		end
	
	end

	self.PhysObj:SetVelocity( self:GetForward() * self.Speed )
	
end

function ENT:Think()
	
	self.Sound:PlayEx( 100, 1 )
	
end 

function ENT:OnRemove()

	self.Sound:Stop()
	
end
