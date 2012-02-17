ENT.Type = "anim"

ENT.Author			= "Tommo :D"
ENT.Contact			= ""
ENT.PrintName			= "Signalling Smoke-Grenade (RED)"
ENT.Purpose			= "Requesting Backup"
ENT.Instructions			= "Left click to deploy a red smoke grenade."

/*---------------------------------------------------------
OnRemove
---------------------------------------------------------*/
function ENT:OnRemove()
end

/*---------------------------------------------------------
PhysicsUpdate
---------------------------------------------------------*/
function ENT:PhysicsUpdate()
end

/*---------------------------------------------------------
PhysicsCollide
---------------------------------------------------------*/
function ENT:PhysicsCollide(data,phys)
	if data.Speed > 50 then
		self.Entity:EmitSound(Sound("HEGrenade.Bounce"))
	end
	
	local impulse = -data.Speed * data.HitNormal * .4 + (data.OurOldVelocity * -.6)
	phys:ApplyForceCenter(impulse)
end