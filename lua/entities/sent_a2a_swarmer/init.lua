AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include( 'shared.lua' )

ENT.Sauce = 150
ENT.Delay = 1.75
ENT.Speed = 1500

function ENT:OnTakeDamage(dmginfo)
 self:NA_RPG_damagehook(dmginfo)
 end
function ENT:Initialize()
	
	self.Sauce = math.random( 75, 150 )
	self.seed = math.random( 0, 1000 )
	self.Speed = math.random( 2100, 2800 )
	self.Damage = math.random( 25,100 )
	self.Radius = math.random( 350, 450 )
	self.DrunkFactor = math.random( 10, 25 )
	
	self.LastUpdate = CurTime()
	
	self:SetModel( "models/weapons/w_missile_closed.mdl" )
	self:PhysicsInit( SOLID_VPHYSICS )
	self:SetMoveType( MOVETYPE_VPHYSICS )	
	self:SetSolid( SOLID_VPHYSICS )
	self:SetColor( 0, 0, 0, 0 )
	
	//self.Owner = self:GetOwner().Owner or self // lolol
	
	self.PhysObj = self:GetPhysicsObject()
	
	if ( self.PhysObj:IsValid() ) then
	
		self.PhysObj:Wake()
	
	end

	
	self.SpawnTime = CurTime()
	
	util.PrecacheSound("Missile.Accelerate")
	self.smoketrail = ents.Create("env_rockettrail")
	self.smoketrail:SetPos( self:GetPos() + self:GetForward() * -7)
	self.smoketrail:SetParent(self)
	self.smoketrail:SetLocalAngles(Angle(0,0,0))
	self.smoketrail:Spawn()
	
	util.SpriteTrail(self, 0, Color(255,255,255,math.random(120,160)), false, 8, math.random(1,2), 1, math.random(1,3), "trails/smoke.vmt");  
	
	self:SetVelocity( self:GetForward() * 128 )
	
end

function ENT:PhysicsCollide( data, physobj )
	
	//if( self.SpawnTime + 0.01 <= CurTime() ) then return end
	
	if( data.HitEntity == self.Owner ) then self:SetPos( self:GetPos() + self:GetForward() * 128 ) return end
	
	if ( IsValid( data.HitEntity ) && data.HitEntity:GetOwner() == self:GetOwner() ) then // Plox gief support for SetOwner ( table )
		
		return
		
	end
	
	if (data.Speed > 1 && data.DeltaTime > 0.1 ) then 
	
		self:Remove()
		
	end
	
end

function ENT:OnTakeDamage( dmginfo )
	
	if( math.random( 1, 10 ) == 7 ) then
	
		self:Remove()
	
	end
	
end

function ENT:PhysicsUpdate()

	if( self.Flying ) then

	end
	
	local tr, trace = {},{}
	tr.start = self:GetPos()
	tr.endpos = tr.start + self:GetForward() * 250
	tr.filter = self
	trace = util.TraceLine( tr )
	
	if ( trace.Hit && trace.HitSky ) then
		
		self:Remove()
		
	end
	
	if( IsValid( trace.Entity ) && trace.Entity == self.Owner || trace.Entity.Owner == self.Owner ) then
		
		self:SetAngles( self:GetAngles() + Angle( 0, math.random( -50, 50 ), 0 ) )
	
	end

	if self.Flying then
		
		if self.Sauce > 0 then
			
			self.PhysObj:SetVelocity( self:GetForward() * self.Speed )
			self.Sauce = self.Sauce - 1
							  
		else
		
			self.PhysObj:EnableGravity(true)
			self.PhysObj:EnableDrag(true)
			self.PhysObj:SetMass( 100000 )
			self.Flying = false
			self:Remove()
			
		end
		
	end

	
end

local function apr(a,b,c)
	local z = math.AngleDifference( b, a )
	return math.Approach( a, a + z, c )
end

function ENT:Think()
	
	if( self:WaterLevel() > 0 ) then
	
		self:Remove()
		
	end
	
	if( self.Flying ) then
		
		local s,c = math.sin(CurTime() * self:EntIndex() * 1000 ) * self.DrunkFactor, math.cos( self:EntIndex() * 1000 ) * self.DrunkFactor
		if( !IsValid( self.Target ) ) then
		
			self:SetAngles( self:GetAngles() + Angle( s,c, 0 ) )
			
		else

			self:PointAtEntity( self.Target ) 
			
		end
			
		if( IsValid( self.Owner ) && !IsValid( self.Target ) ) then
			
			for k,v in pairs( ents.FindInSphere( self:GetPos(), 3000 ) ) do
				
				local logic = ( 
									
									(v:IsNPC() || v.HealthVal ) && 
									v:GetVelocity():Length() > 50 && 
									v != self.Owner && 
									v != self.Owner.Pilot && 
									v:GetClass() != self.Owner:GetClass() && 
									v:GetOwner() != self:GetOwner() &&
									v != self:GetOwner() &&
									string.find( v:GetClass(), "bullseye" ) == nil 
								
								) // heyooo
				
				//print( v:GetClass(), self.Owner:GetClass(), self:GetOwner():GetClass() )
				
				if( v == self.Owner.Target || logic == true ) then
	
					self.Target = v
					
					//print( v:GetClass(), v:GetModel() )
					//print( "Found Target!" )
					break
					
				end
				
			end
			
		end

	end
	
	
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

	if( !IsValid( self.Owner ) ) then
		
		if( IsValid( self:GetOwner() ) && IsValid( self:GetOwner().Pilot ) ) then
			
			self.Owner  = self:GetOwner().Pilot
			
		end
	
	end
	
	if( !IsValid( self.Owner ) ) then
		
		self.Owner = self:GetOwner()
		
	end
	
	if( !IsValid( self.Owner ) ) then
		
		self.Owner = self
		
	end
	
	self:StopSound("Missile.Accelerate")
	
	
	local ent = ents.Create( "env_explosion" )
	ent:SetPos( self:GetPos() )
	ent:Spawn()
	ent:Activate()
	
	util.BlastDamage( self.Owner, self.Owner, self:GetPos(), self.Radius, self.Damage )
	
	for i=0,5 do
	
		local explo1 = EffectData()
		explo1:SetOrigin(self:GetPos()+i*Vector(math.Rand(-15,15),math.Rand(-15,15),-2))
		explo1:SetScale(0.25)
		util.Effect("HelicopterMegaBomb", explo1)
		
	end
	
end
