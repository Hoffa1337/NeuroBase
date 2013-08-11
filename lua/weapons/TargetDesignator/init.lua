AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
resource.AddFile("materials/VGUI/entities/laserPointer.vmt")
resource.AddFile("materials/VGUI/entities/laserPointer.vtf")
include('shared.lua')

function SWEP:Reload()
	if ( self.LastAction + 1 <= CurTime() ) then
	
	self.Tracking = !self.Tracking
		if IsValid(self.RedDot) then
			if self.Tracking then
				self.Owner:SetNetworkedBool( "TrackTarget", true )
				self.Owner:PrintMessage( HUD_PRINTCENTER, "Searching the new position..." )
				self.Owner:EmitSound( "ambient/machines/thumper_startup1.wav")

			else
				self.Owner:SetNetworkedBool( "TrackTarget", false )
				self.Owner:PrintMessage( HUD_PRINTCENTER, "Stop tracking." )
				self.Owner:EmitSound( "ambient/machines/thumper_shutdown1.wav")
			
			end
		else
				self.Owner:SetNetworkedBool( "TrackTarget", false )
				self.Owner:PrintMessage( HUD_PRINTTALK, "Tracking system stopped." )			
				self.Owner:PrintMessage( HUD_PRINTCENTER, "Waiting for coordinates..." )			
		
		end
		
		self.LastAction = CurTime()
	end
end

function SWEP:Equip( newCommander )
	if IsValid(self.RedDot) then
	self.RedDot:Remove()
	newCommander:PrintMessage( HUD_PRINTTALK, "Reset target coordinates..." )
	end
end
function SWEP:Holster( wep )
	if IsValid(self.RedDot) then
		self.Owner:PrintMessage( HUD_PRINTTALK, "Last coordinates saved..." )	
		self.Owner:PrintMessage( HUD_PRINTTALK, "Blind fire mode activated." )	
	end
		
	return true
end
function SWEP:PrimaryAttack()
	self.Pointing = !self.Pointing
	self.Weapon:SetNWBool("Active", self.Pointing)
	trace = self.Owner:GetEyeTrace()
	if(self.Pointing)then
	
		if IsValid(self.RedDot) then
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
		self.RedDot:SetKeyValue( "model", "sprites/glow1.vmt" )
		self.RedDot:SetKeyValue( "framerate", "10.0" )
		self.RedDot:SetKeyValue( "rendercolor", "255 0 0 " )
		self.RedDot:SetKeyValue( "renderamt", 255 )
		self.RedDot:Spawn()
		self.Owner:SetNetworkedEntity( "Target",self.RedDot )
		self.Owner:PrintMessage( HUD_PRINTCENTER, "Target acquired." )
		self.Owner:EmitSound( "binoculars/binoculars_zoomout.wav" )
	else
		if !IsValid(self.RedDot) then
		-- if IsValid(self.RedDot) then
		-- self.RedDot:Remove() //Can't fire while not using the goggles
		self.Zoom = 90		
		self.Owner:PrintMessage( HUD_PRINTCENTER, "Target aborted." )
		end
		self.Owner:EmitSound( "binoculars/binoculars_zoomin.wav" )
	self.Weapon:SetNextPrimaryFire(CurTime() + 0.1)
	end
end

function SWEP:SecondaryAttack()
	self.CanCallStrike = !self.CanCallStrike
		if IsValid(self.RedDot) then
			if self.CanCallStrike then
			self.Owner:SetNetworkedBool( "DestroyTarget", true )
			self.Owner:PrintMessage( HUD_PRINTTALK, "Calling a strike..." )
			self.Owner:EmitSound("LockOn/Voices/EngagingBandit.mp3")
			else
			self.Owner:PrintMessage( HUD_PRINTTALK, "Stop the strike!" )	
			self.Owner:SetNetworkedBool( "DestroyTarget", false )
			end
		else
			self.Owner:SetNetworkedBool( "DestroyTarget", false )
			self.CanCallStrike = false
		end
		
		self.LastAction = CurTime()
	self.Weapon:SetNextSecondaryFire(CurTime() + 0.5)

end

function SWEP:Think()
	if(self.Pointing)then
		self.Owner:DrawViewModel(false)
		local trace = self.Owner:GetEyeTrace()
		local point = trace.HitPos
		
		if (COLOSSAL_SANDBOX) then point = point * 6.25 end
		
		self.RedDot:SetPos( point )

		if self.Owner:KeyDown( IN_ZOOM ) then
			if ( self.LastAction + 0.5 <= CurTime() ) then	
				self.LastAction = CurTime()			
				self.Owner:EmitSound( "binoculars/binoculars_zoommax.wav" )
				
				if self.Zoom > 0 then
				self.Zoom = self.Zoom - 30		
				else
					self.Zoom = 90		
					-- self.Pointing = false
					-- self.Weapon:SetNWBool("Active", self.Pointing)
				end
			print(self.Zoom)
			
			end
		end
				
	else
		self.Owner:DrawViewModel(true)
		self.Zoom = 90
	end
	self.Owner:SetFOV( self.Zoom, 0.25 )
	
	

end
