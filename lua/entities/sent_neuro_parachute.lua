AddCSLuaFile()
ENT.Type = "anim"

ENT.Author			= "Chute"
ENT.Contact			= ""
ENT.PrintName		= ""
ENT.Purpose			= ""
ENT.Instructions			= ""
ENT.Spawnable = false
ENT.AdminSpawnable = false
ENT.Model = "models/bf2/props/bf2_parachute.mdl"
ENT.DeployDelay = 25

function ENT:Initialize()

	self:SetModel( self.Model)
	self:PhysicsInit( SOLID_VPHYSICS )
	self:SetMoveType( MOVETYPE_VPHYSICS )	
	self:SetSolid( SOLID_VPHYSICS )
	if( CLIENT ) then
	
		self:SetLegacyTransform( false )
		self:SetModelScale( 0, 0 )
		self:SetPos( self:GetPos() + self:GetUp() * -128 )
	
	end

	self.DeployTimer = 0
	-- print("WALLA")
end

function ENT:Think()
	
	if( CLIENT ) then return end
	
	self:GetPhysicsObject():Wake()
	
end

function ENT:Draw()

	if( SERVER ) then return end
	self.Owner = self:GetNetworkedEntity("Idiot", NULL )
	local offs = Vector(0,0,0)
	
	if( IsValid( self.Owner ) && !self:GetNetworkedBool("drop",false) ) then 
	
		offs = self.Owner:GetUp() * ( 128 * self.DeployTimer / self.DeployDelay  )
		self:SetAngles( Angle( 0, self.Owner:GetAngles().y, 0 ) )
		-- self:SetPos( self.Owner:GetPos() + offs ) 
		
	end
	
	self:DrawModel()
	if( self.DeployTimer < self.DeployDelay && IsValid( self.Owner ) ) then
	
		-- print( ( 128 * self.DeployTimer / 50  ) )
		self.DeployTimer = self.DeployTimer + 1
		-- self.Deployed = true
		self:SetModelScale( self.DeployTimer/self.DeployDelay, 0 )
		self:SetPos( self.Owner:GetPos() + offs )
		-- self:SetAngles( self.Owner:GetAngles() )
		
		
	end
	

end

function ENT:OnRemove()
end

function ENT:PhysicsUpdate()
	
	if( !self.Destroyed && IsValid( self.Owner ) && self.Owner:GetVelocity():Length() < 400 ) then
		
		-- self.Owner:SetVelocity( self.Owner:GetVelocity() + self.Owner:GetAimVector() * 20 )
	-- print("walla")
	
	end
	
end

function ENT:PhysicsCollide(data,phys)
end