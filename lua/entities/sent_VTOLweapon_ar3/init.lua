AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include( 'shared.lua' )

ENT.Sound = "NPC_FloorTurret.Shoot"
ENT.Model = "models/weapons/w_mach_m249para.mdl"

function ENT:Initialize()

	self.Entity:SetModel( self.Model )

	self.Entity:PhysicsInit( SOLID_VPHYSICS )
	self.Entity:SetMoveType( MOVETYPE_VPHYSICS )	
	self.Entity:SetSolid( SOLID_VPHYSICS )
	
	self.PhysObj = self.Entity:GetPhysicsObject()
	if (self.PhysObj:IsValid()) then
		self.PhysObj:Wake()
	end
	if self.Entity:GetOwner() == nil then return end
	self.Owner = self.Entity:GetOwner()
	self.Entity:SetPhysicsAttacker(self.Owner)

end

function ENT:Use( activator, caller )
--TODO:
-- Make it usable
end
local function Pew(o)
if (o == nil) then return end
o:TurretMegaFire()
end
function ENT:Think()
	if (!SERVER) then return end
		local selfpos = self.Entity:GetPos()
		local forward = self.Entity:GetForward()
		local entities = ents.FindInSphere(self.Entity:GetPos(),3000)
		local rocket = self.Entity 
		for k,v in ipairs(entities) do
			if v != self.Entity and forward:Dot((v:GetPos() - selfpos):GetNormalized()) >= 0.25 then
			if (v:IsNPC() || v:IsPlayer() || (v:IsVehicle() && v:GetVelocity():Length() > 1) && self.Entity.ShouldAttack == true) then
				if ( v:GetClass() == "npc_leakheli" || v:GetClass() == "npc_pelican") then return end
						if self.Entity:GetPos():Distance(v:GetPos()) > 200 && (Vector(0,0,v:GetPos().z) - Vector(0,0,self.Entity:GetPos().z)):Length()*-1 < 0  then
						self.Entity:GunAim(v)
						local tr = {}
						tr.start=rocket:GetPos()+rocket:GetForward()*64
						tr.endpos=rocket:GetPos()+rocket:GetForward()*2000000
						tr.filter=rocket
						local Trace = util.TraceLine(tr)
						
						if (Trace.Hit && Trace.Entity:IsPlayer() || Trace.Entity:IsNPC() || Trace.Entity:IsVehicle()) then
						local TSR = self.Entity:GetVar('DoRocket',0)
						if (TSR + 1) > CurTime() then return end
							self.Entity:SetVar('DoRocket',CurTime())
				for i=1,7 do
					local x=i/10
					timer.Simple(x,function() Pew(self.Entity) end)
				end
					end
				end
			end
		end
	end
end

function ENT:OnRemove()
end
