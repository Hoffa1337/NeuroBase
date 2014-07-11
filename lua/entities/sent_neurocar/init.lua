AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include('shared.lua')


ENT.Model = "models/buggy.mdl"
ENT.VehicleScript= "scripts/vehicles/jeep_test.txt"
ENT.SupportWeapons = false -- to enable / disable the use of mounted weapons
ENT.MountedWeapon = "sent_mounted_RL"
ENT.MountedWeaponOffsetX = 16
ENT.MountedWeaponOffsetY = 16
ENT.MountedWeaponOffsetZ = 50
ENT.CurrentTarget = ""
ENT.MountedWeaponTarget = ""
-- ENT.EntityType = "NeuroCar"

function ENT:SpawnFunction( ply, tr, class )
	if ( !tr.Hit ) then return end
	self.Ply = ply
	local trhp = tr.HitPos + tr.HitNormal * 120
	local ent = ents.Create( class )
	ent:SetPos( trhp)
	ent:Spawn()
	ent:Activate()
	ent:SetOwner(self.Ply)
	return ent

end
function ENT:NCUpdateTarget()
	local TSX = self:GetVar('UpdateE',0)
	if (TSX + 1) > CurTime() then return end
	self:SetVar('UpdateE',CurTime())
	self.entitiesInFront = ents.FindInSphere(self:GetPos(),8000)
end
function ENT:Initialize()

	self.entitiesInFront = ents.FindInSphere(self:GetPos(),8000)
	self:SetModel("models/roller.mdl")
	self:PhysicsInit( SOLID_NONE )
	self:SetMoveType( MOVETYPE_VPHYSICS )
	self:SetSolid( SOLID_NONE )
	
	self:SetRenderMode( RENDERMODE_TRANSALPHA )
	self:SetColor( Color( 0,0,0,0 ) )
	self:Activate()
	self.vBody = ents.Create( "prop_vehicle_jeep" )
	self.vBody:SetPos( self:GetPos() )
	self.vBody:SetModel(self.Model)
	self.vBody:SetKeyValue("vehiclescript",self.VehicleScript)
	self.vBody:Spawn()
	self.vBody:Activate()
	self.vBody:Fire("turnon",0,0)
	self.vBody:Fire("handbrakeoff",0,0)
	
	self:SetParent(self.vBody)
	
	
	if ( self.SupportWeapons ) then
	
		self.MountedGun = ents.Create(self.MountedWeapon)
		self.MountedGun:SetPos(self.vBody:GetPos()+Vector(0,0,self.MountedWeaponOffsetZ)+self.vBody:GetForward()*self.MountedWeaponOffsetX + self.vBody:GetRight()*self.MountedWeaponOffsetY)
		self.MountedGun:SetAngles(Vector(0,90,0))
		self.MountedGun:Spawn()
		self.MountedGun:SetParent(self.vBody)
		self.MountedGun.Owner = self:GetOwner()
		self.MountedGun:SetOwner(self:GetOwner())
		self.MountedGun:SetSolid(6)
		
	end
	
	local phys = self:GetPhysicsObject()
	if ( IsValid( phys ) ) then
	
		phys:Wake()
		phys:SetMass(self.PhysicsMass)
		
	end
		-- print("ENT INI ran!")
end

function ENT:Use(ply,caller)

end

function ENT:OnTakeDamage(dmg)
end

function ENT:OnRemove()

	self:Remove()
	self.vBody:Remove()
	
end

function ENT:Think()
	
	self:NCUpdateTarget()
	
 	local maxDistance = 16000
	local selfpos = self.vBody:GetPos()
	local forward = self.vBody:GetForward()
	local right = self.vBody:GetRight()
	local up = self.vBody:GetUp()
	local TSBrake = self.vBody:GetVar('TimeSinceLastBrake', 0)
	local Debug = 0
	local Debug2 = 0
	local throttle = 0
	local steer = 0

	local tracefilter = {
	self.vBody,
	self,
	};

	for tbl,ent in pairs(self.entitiesInFront) do
	
		if ( ent:IsPlayer()) or (ent:IsNPC() ) then
		
			if ent != tracefilter and forward:Dot((ent:GetPos() - selfpos):GetNormalized()) >= 0.75 then
				
				if (self.SupportWeapons) then
				
					self.MountedGun.Target = ent
					
				end
				
				self.vBody:Fire("throttle","1.5",0)
				throttle = 1.5
				
				Debug2 = "Found entity: "..ent:GetClass().." / "..ent:GetName().." throttling to 1.5 steering 0.0"
			
				for i=0,8 do
				
					self.vBody:Fire("steer","0",0)
					steer = 0
					
				end
			
			end
	
			if ent != tracefilter and right:Dot((ent:GetPos() - selfpos):GetNormalized()) >= 0.45 then -- 0.55
				
				self.vBody:Fire("steer","3",0)
				steer = 3
				self.vBody:Fire("throttle","0.8",0)
				throttle = 0.8
			
			end
			
			if ent != tracefilter and right:Dot((ent:GetPos() - selfpos):GetNormalized()) <= 0.45 then -- 0.55 
				self.vBody:Fire("steer","-3",0)
				steer = -3
				self.vBody:Fire("throttle","0.8",0)
				throttle = 0.8
				
			end
			
		end
		
	end
					
	--Messy front tracers.. 
	local FT1 = {}
	FT1.start=selfpos+up*32
	FT1.endpos=selfpos+forward*300 +up*32 + right*170
	FT1.filter=tracefilter
	
	local FT2 = {}
	FT2.start=selfpos+up*32
	FT2.endpos=selfpos+forward*300 +up*32 + right*-170
	FT2.filter=tracefilter
	
	local FTR1=util.TraceLine(FT1)
	local FTR2=util.TraceLine(FT2)

	if ( FTR1.Hit ) then
	
		self.vBody:Fire("steer","-2.5",0)
		steer = -2.5
		
	end
	
	if ( FTR2.Hit ) then
	
		self.vBody:Fire("steer","2.5",0)
		steer = 2.5

	end
	
	AT1 = {}
	AT1.start=selfpos+up*32 + forward*-100
	AT1.endpos=selfpos+up*32 + right*128 + forward*-300
	AT1.filter=tracefilter
	local Atrace1 = util.TraceLine(AT1)

	AT2 = {}
	AT2.start=selfpos+up*32 + forward*-100
	AT2.endpos=selfpos+up*32 + right*-128 + forward*-300
	AT2.filter=tracefilter
	local Atrace2 = util.TraceLine(AT2)

	if ( Atrace1.Hit ) then
	
		self.vBody:Fire("throttle","0.2",0)
		throttle = 0.2
		self.vBody:Fire("steer","-3",0)
		steer = -2
	
	end
	
	if ( Atrace2.Hit ) then
	
		self.vBody:Fire("throttle","0.2",0)
		self.vBody:Fire("steer","3",0)
		throttle = 0.2
		steer = 2

	end
			
	local LeftTrace = {}
	local RightTrace = {}
	local FrontTrace = {}
	-- starting positions
	FrontTrace.start=selfpos+up*32
	LeftTrace.start=selfpos+up*32
	RightTrace.start=selfpos+up*32
	
	-- Endpos
	FrontTrace.endpos=selfpos+up*32 +forward*310 + right*math.Rand(20,-20)
	LeftTrace.endpos=selfpos+up*32 +right*-240
	RightTrace.endpos=selfpos+up*32 +right*240
	-- Blacklist
	FrontTrace.filter=tracefilter
	RightTrace.filter=tracefilter
	LeftTrace.filter=tracefilter
	
	local L_Trace = util.TraceLine(LeftTrace)
	local R_Trace = util.TraceLine(RightTrace)
	local FRONTTrace = util.TraceLine(FrontTrace)

	if ( L_Trace.Hit ) then
	
		for i=0,4 do		
		
			self.vBody:Fire("steer","5.5",0)
			steer = 5.5
			
		end																						
		
	end
																					
	if ( R_Trace.Hit ) then
	
		for i=0,4 do
		
			self.vBody:Fire("steer","-5.5",0)
			steer = -5.5
			
		end

	end
	
	if ( FRONTTrace.Hit ) then

		local o = FRONTTrace.Entity
		
		if o:IsPlayer() then
			if (TSBrake + 2) > CurTime() then return end
																								
			self.vBody:SetVar( 'TimeSinceLastBrake', CurTime() )
			
			self.vBody:Fire("handbrakeon","",0)
			self.vBody:Fire("handbrakeoff","",2)
			self.vBody:Fire("throttle","-3.9",2.1)
			throttle = -3.9
			
			
		end
		
		if o:GetClass() == "prop_physics" and o:GetPhysicsObject():GetMass() < 60 or o:IsNPC() then
			
			self.vBody:Fire("throttle","2.3",0)
			throttle = 2.3
		
		else
		
			self.vBody:Fire("throttle","-0.9",0)
			throttle = -0.9
		end
		
	end

 end


