--[[ BETA Arcade plane script ]]--

local Meta = FindMetaTable("Entity")

function Meta:NeuroJets_ArcadeMovementScript(phys, deltatime)
--//Lost control if destroyed.
	-- if ( self.HealthVal < self.InitialHealth * 0.15 ) and ( self:GetVelocity():Length() > self.MaxVelocity * 0.50 ) then
	-- self:GetPhysicsObject():AddAngleVelocity( Angle( 10, 0, 0 ) )
	-- self:GetPhysicsObject():ApplyForceCenter( self:GetForward() * 10000)
	-- self:GetPhysicsObject():ApplyForceCenter( Vector(0,0,20000) )
	-- end

	if ( self.IsFlying ) then
	
		phys:Wake()
		
		local p = { { Key = IN_FORWARD, Speed = 6 };
					{ Key = IN_BACK, Speed = -1.5 }; }
					
		for k,v in ipairs( p ) do
			
			if ( self.Pilot:KeyDown( v.Key ) ) then
			
				self.Speed = self.Speed + v.Speed
			
			end
			
		end
		
		self.Speed = math.Clamp( self.Speed, self.MinVelocity, self.MaxVelocity )
		local a = self.Pilot:GetPos() + self.Pilot:GetAimVector() * 3000 + self:GetUp() * -self.CrosshairOffset --// This is the point the plane is chasing.
		local ta = ( self:GetPos() - a ):Angle()
		local ma = self:GetAngles()
		local pilotAng = self.Pilot:GetAimVector():Angle()
		local r,pitch,vel,drag
		local mvel = self:GetVelocity():Length()
		
		self.offs = self:VecAngD( ma.y, ta.y )		

		if( self.offs < -160 || self.offs > 160 ) then
			
			r = 0
			
		else
		
			r = ( self.offs / self.BankingFactor ) * -1
			
		end
		
		if ( IsValid( self.LaserGuided ) ) then
		
			pitch = 2.5
			vel = 35
			
		else
		
			pitch = pilotAng.p
			vel = mvel / 40
		
		end
		
		vel = math.Clamp( vel, 10, 120 )
		
		drag = -400 + mvel / 8
		
		if ( mvel < 500 ) then
			
			vel = 135
			
		end
		
		local pr = {}
		pr.secondstoarrive	= 1
		pr.pos 				= self:GetPos() + self:GetForward() * self.Speed + Vector( 0,0,1 ) * drag
		pr.maxangular		= 150 - vel
		pr.maxangulardamp	= 250 - vel
		pr.maxspeed			= 1000000
		pr.maxspeeddamp		= 10000
		pr.dampfactor		= 0.8
		pr.teleportdistance	= 10000
		pr.deltatime		= deltatime
		pr.angle = Angle( pitch, pilotAng.y, pilotAng.r ) + Angle( 0, 0, r )
		
		phys:ComputeShadowControl(pr)
			
		self:WingTrails( ma.r, 25 )
		
	end
end
--[[FUTURE FEATURES
Displaying caracteristics:

- Power (Speed).
- Defense (Health).
- Attack (Armement).
- Mobility (Manoeuvrability).
- Stability (MaxG, Max angle, etc...).
]]--
function Meta:ArcadeThirdPersonView()

	local pos = self:GetPos()
	local ang = self:GetAngles()
	local pang = self.Pilot:EyeAngles()
	local angspd = self:GetPhysicsObject():GetAngleVelocity()
	local eyes = self.Pilot:GetAimVector()
	
	local trace = util.QuickTrace( self:GetPos(), self.Pilot:GetAimVector() * 10000, { self,self.Pilot } )
	
	if  (GetConVarNumber("jet_cockpitview") == 0 ) then
		if not( self.Pilot:GetViewEntity():GetClass() == gmod_cameraprop ) then
		self.ThirdCam:SetNWString("owner", self.Pilot:Nick())
		-- self.Pilot:SetViewEntity( self.ThirdCam )
		end 

		if  ( GetConVarNumber("jet_arcadeview") == 1 ) then
		self.ThirdCam:SetLocalPos( Vector( self.CamDist*math.cos(math.rad(pang.y+90)), self.CamDist*(math.sin(math.rad(pang.y+90))), self.CamDist*math.sin(math.rad(pang.p))) )
		self.ThirdCam:SetAngles( trace.Normal:Angle())		
		else
		self.ThirdCam:SetAngles( ang )		
		end
	else

	if ( self.Pilot:GetViewEntity() == self.ThirdCam ) then
	self.Pilot:SetViewEntity( self.Pilot )
	end
	
	self.ThirdCam:SetNWString("owner", self)
	end	
		
end

print( "[NeuroPlanes] NeuroPlanesArcade.lua loaded!" )