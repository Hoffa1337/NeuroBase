AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include( 'shared.lua' )

ENT.Sauce = 900
ENT.Delay = 1
ENT.Speed = 400

function ENT:OnTakeDamage(dmginfo)
 self:NA_RPG_damagehook()
 end
function ENT:Initialize()

	self.Entity:SetModel( "models/props_phx/amraam.mdl" )
	self.Entity:PhysicsInit( SOLID_VPHYSICS )
	self.Entity:SetMoveType( MOVETYPE_VPHYSICS )	
	self.Entity:SetSolid( SOLID_VPHYSICS )

	self.PhysObj = self.Entity:GetPhysicsObject()
	if (self.PhysObj:IsValid()) then
		self.PhysObj:Wake() 
	end
	util.PrecacheSound("Missile.Accelerate")
	//util.SpriteTrail(self, 0, Color(255,255,255,math.random(130,170)), false, 17, math.random(1,2), 4, math.random(1,3), "trails/smoke.vmt");  
		
	local wFire1 = ents.Create("env_fire_trail")
	wFire1:SetPos(self.PhysObj:GetPos() + self:GetForward() * -30)
	wFire1:SetParent(self.Entity)
	wFire1:Spawn()
	
	self.LastFramePos = self.Entity:GetPos()

end

function ENT:LerpAim(Target)
if (Target == nil) then return end
if (!Target:IsValid()) then return end
	local a = self:GetPos() -- the gun pos
	local b = Target:GetPos(	) -- targets pos
	local c = Vector( a.x - b.x, a.y - b.y, a.z - b.z ) -- c = gun.x y z - target.x y z ^^
	local e = math.sqrt( ( c.x ^ 2 ) + ( c.y ^ 2 ) + (c.z ^ 2 ) ) -- Square root of c.x y z ^ 2
	local target = Vector( -( c.x / e ), -( c.y / e ), -( c.z / e ) ) -- the angle we'll apply, -C.x y z / e =)
	
	self:SetAngles( LerpAngle( 0.05, target:Angle(), self:GetAngles() ) )
	
end

function ENT:PhysicsCollide( data, physobj )
	if (data.Speed > 50 && data.DeltaTime > 0.2 ) then 
		local explo = EffectData()
		explo:SetOrigin(self.Entity:GetPos())
		explo:SetScale(math.Rand(0.5,0.9))
		explo:SetNormal(data.HitNormal)
		util.Effect("nn_explosion", explo)
		util.BlastDamage( self.Entity, self.Entity, data.HitPos, 250, 30)
		self:ExplosionImproved()
		self.Entity:Remove()
	end
end
function ENT:PhysicsUpdate()
	if self.Flying == true then
		if self.Sauce > 1 then
		self.Speed = self.Speed + 100
		self.PhysObj:SetVelocity(self:GetForward()*self.Speed)
		self.Sauce = self.Sauce - 1
		if (self.Target == nil || self.Target == NULL || !self.Target:IsValid()) then 
			self.Sauce = 0
			self.PhysObj:EnableGravity(true)
			self.PhysObj:EnableDrag(true)
			self.PhysObj:SetMass(2000)
		return false
		end
		
			self.Entity:LerpAim( self.Target )
		else
			
			self.PhysObj:EnableGravity(true)
			self.PhysObj:EnableDrag(true)
			self.PhysObj:SetMass(100)
			
		end
	end
	self.LastPos = self.Entity:GetPos()
end


function ENT:Use( activator, caller )
end

function ENT:Think()
		if self.Delay > 0 then
			self.Delay = self.Delay - 1
			self.Flying = false
		else
			self.Flying = true
			self.Delay = 0
		end
			self.Entity:EmitSound("Missile.Accelerate")
		for k,v in pairs(ents.FindInSphere(self.Entity:GetPos(),270)) do
			if v == self.Target then
				goBoomSmall(self.Entity)
		end
	end 
end 

function ENT:OnRemove()
	self.Entity:StopSound("Missile.Accelerate")
		local explo1 = EffectData()
		explo1:SetOrigin(self.Entity:GetPos())
		explo1:SetScale(0.5)
		explo1:SetNormal(Vector(0,0,0))
		util.Effect("nn_explosion", explo1)
		for i=0,5 do
		local explo1 = EffectData()
		explo1:SetOrigin(self.Entity:GetPos()+i*Vector(math.Rand(-15,15),math.Rand(-15,15),-2))
		explo1:SetScale(0.25)
		util.Effect("HelicopterMegaBomb", explo1)
		end
end
