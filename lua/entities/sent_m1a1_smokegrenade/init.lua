AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include( 'shared.lua' )

ENT.Sound = "ambient/fire/gascan_ignite1.wav"
ENT.Model = "models/weapons/w_eq_smokegrenade.mdl"

function ENT:Initialize()

	self.Entity:SetModel( self.Model )

	self.Entity:PhysicsInit( SOLID_VPHYSICS )
	self.Entity:SetMoveType( MOVETYPE_NONE )	
	self.Entity:SetSolid( SOLID_VPHYSICS )
	self.Entity:SetModel(self.Model)
	self.PhysObj = self.Entity:GetPhysicsObject()
	
	-- self.SmokeStack = ents.Create("env_smokestack")
	-- self.SmokeStack:SetPos(self:GetPos())
	-- self.SmokeStack:SetParent(self.Entity)
	-- self.SmokeStack:SetKeyValue("BaseSpread","64")
	-- self.SmokeStack:SetKeyValue("SpreadSpeed","32")
	-- self.SmokeStack:SetKeyValue("Speed","10")
	-- self.SmokeStack:SetKeyValue("StartSize","68")
	-- self.SmokeStack:SetKeyValue("EndSize","84")
	-- self.SmokeStack:SetKeyValue("Rate","6")
	-- self.SmokeStack:SetKeyValue("SmokeMaterial","modulus/particles/Smoke"..math.random(1,6))
	-- self.SmokeStack:SetKeyValue("JetLength","310")
	-- self.SmokeStack:SetKeyValue("WindAngle","10")
	-- self.SmokeStack:SetKeyValue("twist","6")
	-- self.SmokeStack:Spawn()
	-- self.SmokeStack:Fire("turnon","",0)
	if (self.PhysObj:IsValid()) then
		self.PhysObj:Wake()
	end
	if self.Entity:GetOwner() == nil then return end
	self.Owner = self.Entity:GetOwner()
	self.Entity:SetPhysicsAttacker(self.Owner)
	
end
local tankTab = {
{"npc_t72"};
{"npc_t72_turrent"};
{"npc_tank"};
{"npc_tank_turrent"};
}
function ENT:Use( activator, caller )

end

function ENT:Think()
	self:NextThink(CurTime()+0.25)
	local fx = EffectData()
	fx:SetOrigin(self:GetPos())
	util.Effect("Launch2",fx)
	
	for k,v in pairs(ents.GetAll()) do
		if (v:GetPos():Distance(self:GetPos()) < 1024 && v:IsNPC()) then
			v:SetNPCState(4)
		for _,V in pairs(tankTab) do
			if (v:GetClass() == tostring(V[1])) then
				
				V.Enemy = nil
				V:NextThink(CurTime()+15)
			
			end
		end
		
		
		end
	end
	
	return true
end

function ENT:OnRemove()

end
