AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include( 'shared.lua' )

ENT.Sound = "NPC_FloorTurret.Shoot"
ENT.Model = "models/Airboatgun.mdl"

function ENT:Initialize()

	self.Entity:SetModel( self.Model )
	self.Entity:SetVar('DoAttack',CurTime())
	self.Entity:PhysicsInit( SOLID_NONE )
	self.Entity:SetMoveType( MOVETYPE_VPHYSICS )	
	self.Entity:SetSolid( SOLID_NONE )
	
	self.PhysObj = self.Entity:GetPhysicsObject()
	if (self.PhysObj:IsValid()) then
		self.PhysObj:Wake()
	end
	if self.Entity:GetOwner() == nil then return end
	self.Owner = self.Entity:GetOwner()
	self.Entity:SetPhysicsAttacker(self.Owner)

end

local function Pew(o)
if (o == nil || o == NULL) then return end
if (!o) then return end
o:TurretMegaFire()
end
function ENT:Think()
if (!SERVER) then return end
	local selfpos = self.Entity:GetPos()
	local forward = self.Entity:GetForward()
	local entities = ents.FindInSphere(selfpos,3700)
	for k,v in pairs(entities) do
		if (v != self.Entity and forward:Dot((v:GetPos() - selfpos):GetNormalized()) >= 0.35) then
			if ( v:GetClass() == "npc_harrier" ) then return end
			if (v:IsNPC() || v:IsPlayer() || (v:IsVehicle() && v:GetPhysicsObject():GetVelocity():Length() > 0) && self.ShouldAttack) then
				if ( self.Entity:GetPos():Distance(v:GetPos()) > 200 && v:GetPos().z < self.Entity:GetPos().z )  then
					self.Entity:GunAim(v)
					local tr = {}
					tr.start=self:GetPos()+self:GetForward()*128
					tr.endpos=self:GetPos()+self:GetForward()*5400
					tr.filter=self
					local Trace = util.TraceLine(tr)
						
					if ( Trace.Hit && Trace.Entity:IsPlayer() || Trace.Entity:IsNPC() || Trace.Entity:IsVehicle() ) then
					local TSR = self.Entity:GetVar('DoAttack',0)
					if ( TSR + math.random(5,6) ) > CurTime() then return end
						self.Entity:SetVar('DoAttack',CurTime())
						for i=1,35 do
							local x=i/25
							timer.Simple( x, function() Pew( self.Entity ) end )
						end
					end
				end
			end
		end
	end
end


