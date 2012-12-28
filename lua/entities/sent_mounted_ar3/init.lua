AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include( 'shared.lua' )

ENT.Sound = "NPC_FloorTurret.Shoot"
ENT.Model = "models/weapons/w_mach_m249para.mdl"

function ENT:SpawnFunction( ply, tr)
	if ( !tr.Hit ) then return end
	self.Ply = ply
	local trhp = tr.HitPos + tr.HitNormal * 32
	local ent = ents.Create( "sent_mounted_ar3" )
	ent:SetPos( trhp)
	ent:Spawn()
	ent:Activate()
	return ent
end
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
function Pew(o)
if (o == nil) then return end
o:TurretMegaFire()
end
function ENT:Think()
	if (!SERVER) then return end
		local selfpos = self.Entity:GetPos()
		local forward = self.Entity:GetForward()
	local entities = ents.FindInSphere(self.Entity:GetPos(),3000)
			local rocket = self.Entity 

		local entitiesInFront = {}
		for k,v in ipairs(entities) do
			if v != self.Entity and forward:Dot((v:GetPos() - selfpos):GetNormalized()) >= 0.25 then
			if (v:IsNPC() || v:IsPlayer() ) then
						if self.Entity:GetPos():Distance(v:GetPos()) > 100 then
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
						timer.Simple(0.1,function() Pew(self.Entity) end)
						timer.Simple(0.2,function() Pew(self.Entity) end)
						timer.Simple(0.3,function() Pew(self.Entity) end)
						timer.Simple(0.4,function() Pew(self.Entity) end)

						end
				end
			end
		end
	end
end

function ENT:OnRemove()
end
