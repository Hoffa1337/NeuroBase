/***************************/
/* It is all about physics */
/***************************/

local Meta = FindMetaTable("Entity")


local MFix 		= 0
local ang 		= Angle( 0,0,0 )
local velocity 	= 0
local angvel 	= Angle( 0,0,0 )
local pLimit 	= 0
local Lift 		= 0
local Drag 		= 0
local Throttle 	= 0
local Manu 		= 0
local RPush = 0
local ZForce = 0

-- function Meta:NeuroJets_MovementScript(ply)
function Meta:NA_MovementScript(ply)
	
	self.VolPitch = math.Clamp( math.floor( self:GetVelocity():Length() / 20 + 40 ), 0, 200 )
	
	if( self.IsFlying && self.Pitch && self.EngineMux ) then
	
		for i = 1,#self.EngineMux do
		
			self.EngineMux[i]:ChangePitch( self.VolPitch, 0.01 )
			
		end
		
	end

	-- self:DrawClientsideCockpit()	//I put this here to render any model by default -StarChick

	local MFix 		= MultiplayerCheck()
	local ang 		= self:GetAngles()
	local velocity 	= math.ceil(self:GetVelocity():Length())
	local angvel 	= self:GetPhysicsObject():GetAngleVelocity()
	local pLimit 	= math.cos(  angvel.x / 1000 )
	local Lift 		= 0.045 * velocity * velocity
	local Drag 		= -0.1 * velocity * velocity / 2
	local Throttle 	= self.Speed/self.MaxVelocity
	local Manu 		= 3.75+self.Manoeuvrability/20
	local Steerability = self.NA_SteerabilityMultiplier * ( 1.0 * math.Clamp( velocity, 0, self.NA_PhysicsUpperSpeedLimit ) / self.NA_PhysicsUpperSpeedLimit   ) 
	
	if( self.CopilotSeatPos ) then

		self.CoPilot = self.CopilotSeat:GetDriver()

		if( IsValid( self.CoPilot ) ) then
			
			self:NeuroJets_CoPilotKeybinds( self.CoPilot )
			
		end
	
	end
	
	
	if ( self.IsFlying ) && IsValid(self.Pilot) then

		
		-- self.Pilot:PrintMessage( HUD_PRINTCENTER, 
		-- Steerability.." ("..tostring( math.floor(angvel.x).." "..math.floor(angvel.y).." "..math.floor(angvel.x) )..") - ".. math.floor( self.Speed ).." ( "..self.Pitch.." )" )
		-- self.Pilot:PrintMessage( HUD_PRINTCENTER, "spd="..tostring( math.floor( self.Speed )..", roll="..math.floor(self.Roll)..", p="..math.floor(self.Pitch).."" ) )
		
		--Sound code
		self.SoundPitch = math.Clamp( math.floor( self.Speed*100/self.MaxVelocity + 40 ), 0, 200 )
		
		for i = 1,#self.EngineMux do
		
			self.EngineMux[i]:ChangePitch( self.SoundPitch, 0.01 )
			
		end
		
		self.EngineMux[1]:PlayEx( 1.0, self.SoundPitch )

		local soundspeed = 7000 -- normally 767 * 352/15 --  speed of sound in units = mph * (mph to units) 
		local toggleBarrierSDN
		
		if ( velocity > soundspeed ) &&( velocity < soundspeed + 50) then
		
			toggleBarrierSDN = true	
			
		end	
		
		if ( toggleBarrierSDN ) then
		
			toggleBarrierSDN = false
		-- --	self.SonicBoomMux:Play()	
		-- --	self.SonicBoomMux:Stop()
			self:EmitSound( "LockOn/SonicBoom.mp3", 510, 100 )
			 
		end
		
		if ( velocity > soundspeed ) then
		
			self.SuperSonicMux:Play()	
			
		else
		
			self.SuperSonicMux:Stop()	
			
		end
		
		--Physics
		self:GetPhysicsObject():Wake()
						
		if( !self.LastUseKeyDown ) then
		
			self.LastUseKeyDown = CurTime()	
			
		end

		local TVC_mul
		if( self.HasTVC == true ) then
			TVC_mul	= 2
			else
			TVC_mul = 1
		end

		if ( self.Pilot:KeyDown( IN_FORWARD )  && velocity > 550  ) then
		
			self.Pitch = Lerp( self.NA_LerpPitch, self.Pitch, self.NA_PitchDown * TVC_mul )  * Steerability
		
		elseif ( self.Pilot:KeyDown( IN_BACK )  && velocity > 550 ) then
		
			self.Pitch = Lerp( self.NA_LerpPitch, self.Pitch, -self.NA_PitchUp * TVC_mul )  * Steerability
			
		else
			
			self.Pitch = 0
			
		end
		
		
		if( ang.r > 5 || ang.r < 5 ) then
			
			self.Yaw = -ang.r * self.NA_YawRollMultiplierStraight
			
		end
		
		-- print( math.floor( self.Pitch), math.floor( self.Yaw ) )
		
		if ( self.Pilot:KeyDown( IN_DUCK ) && self.Pilot:KeyDown( IN_MOVELEFT ) ) then
		
			self.Yaw = Lerp( self.NA_LerpYaw, self.Yaw, self.NA_Yaw * TVC_mul)
			
			
		elseif ( self.Pilot:KeyDown( IN_DUCK ) && self.Pilot:KeyDown( IN_MOVERIGHT ) ) then
		
			self.Yaw = Lerp( self.NA_LerpYaw, self.Yaw, -self.NA_Yaw * TVC_mul)
			
		
		else
		
			if( velocity > 1000 ) then
			
				self.Yaw = -ang.r * self.NA_YawRollMultiplierFast
				-- self.Pitch = -ang.p * 2.5
			
			else
			
				self.Yaw = 0
			
			end
			
			
		end
		
		if ( !self.Pilot:KeyDown( IN_DUCK ) && self.Pilot:KeyDown( IN_MOVERIGHT ) ) then --&& velocity > 950 ) then
		
			self.Roll = Lerp( self.NA_LerpRoll, self.Roll, self.NA_Roll * TVC_mul) * Steerability
		
		elseif ( !self.Pilot:KeyDown( IN_DUCK ) && self.Pilot:KeyDown( IN_MOVELEFT ) ) then --&& velocity > 950  ) then
		
			self.Roll = Lerp( self.NA_LerpRoll, self.Roll, -self.NA_Roll * TVC_mul) * Steerability
		
		else
		
			self.Roll = 0
			
		end


		
		local Boost
		
		if ( self.Pilot:KeyDown( IN_SPEED ) ) then
		
			-- self.Speed = 1 + self.Speed * 1.125
			self.Speed = 500 + self.Speed --* 1.125
			
			if( self.HasAfterburner != false ) then
			
				self.EngineMux[3]:PlayEx( 500 , self.SoundPitch )
				Boost = 500
			-- ParticleEffect("afterburner01_once",self:LocalToWorld(self.ReactorPos[1]) ,self:GetAngles(),self)
			-- ParticleEffect("afterburner01_once",self:LocalToWorld(self.ReactorPos[2]) ,self:GetAngles(),self)
			-- ParticleEffectAttach("afterburner01_once",PATTACH_ABSORIGIN_FOLLOW ,self.ThrusterProp[1],0)
			-- ParticleEffectAttach("afterburner01_once",PATTACH_ABSORIGIN_FOLLOW ,self.ThrusterProp[2],0)
			else
			
				self:StopParticles()
				
				Boost = 150//50	
				
			end

		elseif ( self.Pilot:KeyDown( IN_WALK ) ) then
		
			self:StopParticles()			
		
			if( self.HasAirbrakes == true ) then
				
				if (self.Speed > 0.1*self.MaxVelocity) then
				
					self.Speed = self.Speed * 0.90					
					Boost = self.MaxVelocity * 0.10				
					
				else
				
					self.Speed = self.Speed * 0.98
					
				end	
				
				self.Drift = self.Drift + 0.5
				Boost = 0
			else

				self.Speed = self.Speed * 0.95
				Boost = 0
			
			end
			
		else
		
			self:StopParticles()					
			self.Drift = self.Drift - 0.06
			self.EngineMux[3]:FadeOut(0.5)
			-- self.EngineMux[4]:PlayEx( 500 , self.SoundPitch )
			-- self.EngineMux[4]:Stop()
			Boost = 0
			
		end
	
		self.Speed = math.Clamp( self.Speed, self.MinVelocity + Boost, self.MaxVelocity + Boost ) 
		self.Drift = math.Clamp( self.Drift, 1, 2 )
		self:SetNetworkedInt( "Throttle",self.Speed)

		local xG
		
		if ( ang.p < -45 ) then
		
			self.maxG = self.maxG*1.025-- + 1
			xG = self.NA_MaxGForce
			
		elseif ( ang.p > 45 ) then
		
			self.maxG = self.maxG - 1
			xG = self.NA_MinGForce
			
		else
		
			self.maxG = self.maxG - 5
			xG = self.NA_MaxGForce
			
		end
		
		self.maxG = math.Clamp( self.maxG, xG, self.NA_GForceCeiling )
-- /*
		-- self.Pitch = math.Clamp( self.Pitch, -10000, 10000 )
		-- self.Yaw = math.Clamp( self.Yaw, -10000, 10000 )
		-- self.Roll = math.Clamp( self.Roll, -10000, 10000 )
-- */

		self:GetPhysicsObject():ApplyForceCenter( self:GetUp() * Lift * pLimit *MFix)
		self:GetPhysicsObject():ApplyForceCenter( self:GetForward() * Drag *MFix)
		
		if (ang.p > -10) and (ang.p < 10) and (ang.r < 10) and (ang.r > -10) then
		
			self:GetPhysicsObject():ApplyForceOffset( self:GetUp() * math.cos(  ang.p/10 ) * - velocity/10*MFix, self:GetForward()*-10000 )
			
		end

	else
	
		self:GetPhysicsObject():ApplyForceOffset( self:GetUp()*-200*MFix, self:GetForward()*10000 )	
		self.EngineMux[1]:Stop()	
		self.EngineMux[3]:Stop()
		
	end
				
	local ZForce = - math.exp(5*-self.Speed/self.MaxVelocity)*2

	local RPush = 0 //self:GetAngles().r * 2.1
	
	self:GetPhysicsObject():ApplyForceOffset( self:GetUp()*self.Roll*1.25*(0.5+Throttle)*(Manu+0.25)*MFix, self:GetRight()*-13000 )
	self:GetPhysicsObject():ApplyForceOffset( self:GetUp()*-self.Roll*1.25*(0.5+Throttle)*(Manu+0.25)*MFix, self:GetRight()*13000 )
	self:GetPhysicsObject():ApplyForceOffset( self:GetRight()* ( ( self.Yaw * MFix ) - ( RPush ) ), self:GetForward()*-10000 )
	self:GetPhysicsObject():ApplyForceOffset( self:GetRight()*-( ( self.Yaw * MFix ) - ( RPush ) ), self:GetForward()*10000 )
	self:GetPhysicsObject():ApplyForceOffset( self:GetUp()*self.Pitch*self.Drift*Manu*MFix, self:GetForward()*-17000 )
	self:GetPhysicsObject():ApplyForceOffset( self:GetUp()*-self.Pitch*self.Drift/100*Manu*MFix, self:GetForward()*17000 )

	self:GetPhysicsObject():ApplyForceCenter( self:GetForward() * 500*self.Speed * pLimit *( 120 - self.maxG )/100 *MFix)
	
--	self:GetPhysicsObject():ApplyForceCenter( self:GetUp() * -ZForce*1000 *MFix)
	self:GetPhysicsObject():ApplyForceCenter( self:GetUp() * -ZForce*10000*self.Drift *MFix)

	--Crash animation until plane is removed
	
	self:WingTrails( ang.r, 1 )
	
	if ( self.Destroyed ) then 
		
		local effectdata = EffectData()
		effectdata:SetOrigin( self:GetPos() + self:GetRight() * math.random(-62,62) + self:GetForward() * math.random(-62,62)  )
		util.Effect( "immolate", effectdata )
		self.DeathTimer = self.DeathTimer + 1
		
		local DeathFactor = math.random(0,7)
		local DeathFactorBoolean = math.random(-1,1)

		self:GetPhysicsObject():ApplyForceOffset( self:GetUp()*-DeathFactor*100*MFix, self:GetForward()*-10000*(1-math.abs(DeathFactorBoolean))+ self:GetRight()*10000*DeathFactorBoolean )
		
	end		

	if( self.Destroyed && self.Speed > 500 ) then
		
		self:GetPhysicsObject():ApplyForceCenter( self:GetForward() * ( 2500 * self.Speed ) )
		
	
	end
	
	return true  
	
end

function Meta:NA_Control_Roll()

end

print( "[NeuroPlanes] NeuroAirPhysics.lua loaded!" )