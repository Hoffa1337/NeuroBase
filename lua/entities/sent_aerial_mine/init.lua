AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_init.lua")
include("shared.lua")

function ENT:SpawnFunction( ply, tr)
	
	local SpawnPos = tr.HitPos + tr.HitNormal * math.random( 5000, 8000 ) + Vector( math.random( -3024, 3024 ), math.random( -3024, 3024 ) )
	local ent = ents.Create( "sent_aerial_mine" )
	ent:SetPos( SpawnPos )
	ent:Spawn()
	ent:Activate()
	ent.Spawner = ply
	return ent
	
end

function ENT:Initialize()

	self:SetModel( "models/Combine_Helicopter/helicopter_bomb01.mdl" )
	self:PhysicsInit( SOLID_VPHYSICS )
	self:SetMoveType( MOVETYPE_NONE)	
	self:SetSolid( SOLID_VPHYSICS )
	self:SetMaterial("debug/env_cubemap_model")

	self.PhysObj = self:GetPhysicsObject()
	if (self.PhysObj:IsValid()) then
		self.PhysObj:Wake()
		self.PhysObj:EnableGravity(false)
	end
	
	self:Fire( "kill", "", 300 )
	
end

function ENT:Think()
	
	if( self.Destroyed ) then return end
	
	for k,v in pairs( ents.FindInSphere( self:GetPos(), 700 ) ) do
		
		if ( !v:IsPlayer() && ( v:IsNPC() || v.HealthVal != nil || v:GetNetworkedEntity("Pilot") ) && v != self && v:GetClass() != self:GetClass() && v:GetVelocity():Length() > 150 ) then
		   
			self.Target = v
			
			if ( IsValid( self.Target ) ) then
				
				self:EmitSound( "ambient/machines/catapult_throw.wav", 511, math.random(97,104) )
				
				local spawner = self.Spawner
				
				for i=1,math.random(5,7) do
				
					local rnd = Vector( math.random( -512,512), math.random( -512,512), math.random( -512,512) )
					local p = self:GetPos() + rnd
					
					timer.Simple( i / 4, 
					function()
						
						if( !spawner ) then return end
						
						local expl = ents.Create("env_explosion")
						expl:SetKeyValue("spawnflags",128)
						expl:SetPos( p )
						expl:Spawn()
						expl:Fire("explode","",0)
						
						if( IsValid(  spawner ) ) then
						
							util.BlastDamage( spawner, spawner, p, 1800, math.random(250,700) )
						
						end
						
					end )
											
				end
				
				self:Remove()
				
				self.Destroyed = true
				
				return
				
			end
		
		end
		
	end
	
end
