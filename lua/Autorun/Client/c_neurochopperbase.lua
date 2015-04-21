local Meta = FindMetaTable("Entity")

local matHeatWave		= Material( "sprites/heatwave" )
local matFire			= Material( "effects/fire_cloud1" )
local matPlasma			= Material( "effects/strider_muzzle" )

function Meta:HelicopterDefaultCInit()
	
	self.ZoomLevel = self.MaxZoom
	self.ZoomVar = self.ZoomLevel
	self.LastZoom = 0
	self.Emitter = ParticleEmitter( self:GetPos(), false )
	
	
end

function Meta:HelicopterDefaultDraw()

	self:DrawModel()
	
	local prop = self:GetNetworkedEntity("RotorProp", NULL )
	-- print(prop )
	if( IsValid( prop ) ) then
		
		local a = prop:GetAngles()
		a:RotateAroundAxis( prop:GetUp(), 45 )
		prop:SetAngles( a )
		prop:DrawModel()
		a:RotateAroundAxis( prop:GetUp(), 90 )
		prop:SetAngles( a )
		prop:DrawModel()
		
		
	end
	
	local p = LocalPlayer()
	
	local driver = self:GetNetworkedEntity("Pilot", NULL )
	
	local extra = ""
	
	if( IsValid( driver ) ) then
		
		extra = tostring(driver:Name().."\n")

	end
	
	if ( p:GetEyeTrace().Entity == self && EyePos():Distance( self:GetPos() ) < 1000 ) then
			
			AddWorldTip(self:EntIndex(),self.PrintName.."\n"..extra.."Health: "..tostring( math.floor( self:GetNetworkedInt( "health" , 0 ) ) ), 0.5, self:GetPos() + Vector(0,0,72), self )
			
	end
	

	if( IsValid( driver ) ) then
		
		self:DrawHeloExhaust( self:LocalToWorld( self.ExhaustPosition ) )

	end

end

function Meta:DrawHeloExhaust( pos )

	-- local particle = self.Emitter:Add("sprites/heatwave",pos)
	-- particle:SetDieTime( 0.3 )
	-- particle:SetStartAlpha( 255 )
	-- particle:SetEndAlpha( 255 )
	-- particle:SetStartSize( 50 )
	-- particle:SetEndSize( 25 )
	-- particle:SetColor( 255, 255, 255 )
	-- particle:SetCollide( true )
	-- particle:SetRoll( math.random(-1,1) )
	-- particle:SetGravity( Vector( math.sin(CurTime() - self:EntIndex() * 10 ) * 32,math.cos(CurTime() - self:EntIndex() * 10 ) * 32, math.random(-300,-200) ) )
	-- //particle:SetVelocity( self:GetVelocity() )
	-- //particle:SetAngleVelocity( self:GetAngleVelocity() )
	
	-- self.Emitter:Finish()

end

function Meta:HelicopterDefaultCalcView(  ply, Origin, Angles, Fov )

	local plane = ply:GetScriptedVehicle()
	
	local view = {
		origin = Origin,
		angles = Angles
		}
		
	
	if( IsValid( plane ) && ply:GetNetworkedBool( "InFlight", false )  ) then
		
		local pos
		local pilotmodel = ply:GetNetworkedEntity("NeuroPlanes_Pilotmodel", NULL )
		
		if( GetConVarNumber("jet_cockpitview") > 0 ) then
				
			pos = plane:LocalToWorld( self.CockpitCameraPos ) //Origin//
			
			if( IsValid( pilotmodel ) ) then
				
				pilotmodel:SetColor( Color( 0,0,0,0 ) )
				pilotmodel:SetRenderMode( RENDERMODE_TRANSALPHA )
				
			end
			
		else
			
			pos = plane:GetPos() + plane:GetUp() * plane.CamUp + ply:GetAimVector() * -plane.CamDist
			
			if( IsValid( pilotmodel ) ) then
				
				pilotmodel:SetColor( Color( 255,255,255,255 ) )
				
			end
			
		end
		
		local gun = ply:GetNetworkedEntity( "ChopperGunnerEnt", NULL )
		local GotChopperGunner = ( ply:GetNetworkedBool( "isGunner", false ) && IsValid( gun ) )
		local fov = GetConVarNumber("fov_desired")
		local ang,pAng = ply:GetAimVector():Angle(), plane:GetAngles()
		local myAng 

		if ( GotChopperGunner ) then
			
			// hurr hackfix
			if ( ang.p < 4|| ang.p > 300 ) then ang.p = 4 end // Stupid glitch where the mouse responds faster than the lua engine.
			if ( ang.p > 89 && ang.p < 150 ) then ang.p = 89 end // stupid cl_pitchdown > 89(default) 
			// durr
			
			if ( ply:KeyDown( IN_ATTACK ) ) then
				
				local wat = ( self.MaxZoom / 100 ) - ( self.ZoomLevel / 100 )
				ang.p = ang.p + math.Rand( -.3 - wat, .3 + wat )
				ang.y = ang.y + math.Rand( -.3 - wat, .3 + wat )
		
			end
			
			if( ply:KeyDown( IN_ATTACK2 ) && self.LastZoom + 0.5 <= CurTime() ) then
				
				self.LastZoom = CurTime()
				
				if( self.ZoomLevel == self.MinZoom ) then
				
					self.ZoomLevel = self.MaxZoom
					
				elseif( self.ZoomLevel == self.MaxZoom ) then
				
					self.ZoomLevel = self.MinZoom
			
				end
				
			end
			
			
			self.ZoomVar = math.Approach( self.ZoomVar, self.ZoomLevel, 10 )
			pos = plane:LocalToWorld( self.GunCamPos ) --GetPos() + plane:GetForward() * 165 + plane:GetUp() * -59
			fov = self.ZoomVar
			myAng = Angle( ang.p, ang.y, pAng.r / 1.45 )
		
		else
		
			myAng = Angle( ang.p, ang.y, pAng.r / 1.75 )
		
		end
		
		
		local LaserGuided = plane:GetNetworkedEntity("NeuroPlanes_LaserGuided", NULL )
		local copilot = plane:GetNetworkedEntity( "CoPilot", NULL )
		
		if( IsValid( LaserGuided ) && !IsValid( copilot ) ) then
			
			pos = LaserGuided:GetPos() + LaserGuided:GetForward() * 100
			myAng = LaserGuided:GetAngles()

		end
		
		view = {
			origin = pos,
			angles = myAng,
			fov = fov
			}

	end

	return view

end


print( "[NeuroPlanes] c_neurochopperbase.lua loaded!" )