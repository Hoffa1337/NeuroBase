AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
resource.AddFile("materials/VGUI/entities/laserPointer.vmt")
resource.AddFile("materials/VGUI/entities/laserPointer.vtf")
include('shared.lua')

SWEP.Weight = 8
SWEP.AutoSwitchTo = false
SWEP.AutoSwitchFrom = false

-- SWEP.Receiver = nil
SWEP.Pointing = false
SWEP.CanCallStrike = false

function SWEP:Initialize()
	self.Pointing = false
	self.CanCallStrike = false
end

function SWEP:Reload()
	
end

function SWEP:Equip( newCommander )
	if ValidEntity(self.RedDot) then
	self.RedDot:Remove()
	newCommander:PrintMessage( HUD_PRINTTALK, "Reset target coordinates..." )
	end
end
function SWEP:Holster( wep )

	return true
end
function SWEP:PrimaryAttack()
	self.Pointing = !self.Pointing
	self.Weapon:SetNWBool("Active", self.Pointing)
	trace = self.Owner:GetEyeTrace()
	if(self.Pointing)then
	
	if ValidEntity(self.RedDot) then
	self.RedDot:Remove()
	end
	self.RedDot = ents.Create( "env_sprite" )
	-- self.RedDot:SetParent( self )	
	self.RedDot:SetPos( trace.HitPos  )
	-- self.RedDot:SetAngles( self:GetAngles() )
	self.RedDot:SetKeyValue( "spawnflags", 1 )
	self.RedDot:SetKeyValue( "renderfx", 0 )
	self.RedDot:SetKeyValue( "scale", 0.2 )
	self.RedDot:SetKeyValue( "rendermode", 9 )
	self.RedDot:SetKeyValue( "HDRColorScale", .75 )
	self.RedDot:SetKeyValue( "GlowProxySize", 2 )
	self.RedDot:SetKeyValue( "model", "sprites/redglow3.vmt" )
	self.RedDot:SetKeyValue( "framerate", "10.0" )
	self.RedDot:SetKeyValue( "rendercolor", " 255 0 0" )
	self.RedDot:SetKeyValue( "renderamt", 255 )
	self.RedDot:Spawn()
	self.Owner:SetNetworkedEntity( "Target",self.RedDot )
	self.Owner:PrintMessage( HUD_PRINTTALK, "Target acquired" )
	else
	if ValidEntity(self.RedDot) then
	self.RedDot:Remove()
	end

	end
end

function SWEP:SecondaryAttack()
	self.CanCallStrike = !self.CanCallStrike
	if ValidEntity(self.RedDot) then
		if self.CanCallStrike then
		self.Owner:SetNetworkedBool( "DestroyTarget", true )
		self.Owner:PrintMessage( HUD_PRINTTALK, "[WIP] Calling a strike..." )
		self.Owner:EmitSound("LockOn/Voices/EngagingBandit.mp3")
		else
		self.Owner:PrintMessage( HUD_PRINTTALK, "Stop the strike!" )	
		self.Owner:SetNetworkedBool( "DestroyTarget", false )
		end
	else
		self.Owner:SetNetworkedBool( "DestroyTarget", false )
		self.CanCallStrike = false
	end
end

function SWEP:Think()
	if(self.Pointing)then
		local trace = self.Owner:GetEyeTrace()
		local point = trace.HitPos
		if (COLOSSAL_SANDBOX) then point = point * 6.25 end
		self.RedDot:SetPos( point )
	end
end
