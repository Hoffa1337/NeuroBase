-- NeuroNaval Global by Robin Hoffa
resource.AddFile("materials/vgui/ui")

local Meta = FindMetaTable("Entity")
-- function GAMEMODE:PlayerFootstep( ply, pos, foot, sound, volume, filter )
	
	-- return !IsValid( ply:GetScriptedVehicle() )
	
-- end
concommand.Add("name_ship", function( ply, cmd, args ) 
	
	if( IsValid( ply ) ) then 
		local veh = ply:GetScriptedVehicle()
		if( IsValid( veh ) && veh.IsMicroCruiser && !veh.ShipName ) then
		 
			veh.ShipName = string.sub( args[1], 1, 32 )
			-- print( ply:Name().." named his "..veh.PrintName.." "..veh.ShipName, ply, veh )
			veh:SetNWString("ShipName", veh.ShipName )
		
		end 
		
	end 

end )
concommand.Add("_neuronaval_zoomvalue", function( ply,cmd,args ) 
	-- print("walla?")
	-- print( args[1] )
	if( tonumber( args[1] ) != nil ) then 
		
		ply.zoomValue = math.Clamp(  tonumber( args[1] ), 5, 90 )
	
	end 

end )



function Meta:NeuroNaval_DefaultPhysicsUpdate()


end


function Meta:NeuroNaval_DefaultPhysSimulate( phys, deltatime )
		-- print("lahme?")
	phys:Wake()
	-- if( !self.LastTickUpdate ) then self.LastTickUpdate = 0 end 
	-- if( self.LastTickUpdate + .1 >= CurTime() ) then return end 
	-- self.LastTickUpdate = CurTime() 
	
	-- phys:AddAngleVelocity(Vector( math.cos(CurTime())*.1, math.sin(CurTime())*.1,  0) )
	if( IsValid( self.Deck ) ) then 
		
		self.Deck:GetPhysicsObject():AddAngleVelocity(Vector( math.cos(CurTime())*.01, math.sin(CurTime())*.01,  0) )
		 
	end 
	
	if( self.ShipAngleForceCurrentValue && self.ShipAngleForceTargetValue ) then 
	
		self.ShipAngleForceCurrentValue = math.Approach( self.ShipAngleForceCurrentValue, self.ShipAngleForceTargetValue, 0.012951 )
		--self.ShipAngleForceCurrentValue*50
		local dir = -1 
		if( self.ActualSpeed < 0 ) then 
			 dir = 1
		end 
		local sforce = math.cos(CurTime()+self:EntIndex())*.01
		local sforce2 =  0 --dir*.00021+math.sin(CurTime()*.1)*(math.Clamp(self:GetVelocity():Length(),0,100 )/100)
		if( !self.IsMicroCruiser ) then 
			sforce = 0
			sforce2 = 0 
			
		end
		if( !self.SAFApproachVal ) then 
			
			self.SAFApproachVal = 0 
			
		end 
		local myang = self:GetAngles() 
		
		self.SAFApproachVal = Lerp( 0.015225, self.SAFApproachVal, self.ShipAngleForceCurrentValue * ( self.TurnAngleValue or 5 ) )
		if( myang.r < 45 && myang.r > -45 && self.PropellerPos && !self.RudderIsFucked  ) then 
			-- print("what")
			self.PhysObj:ApplyForceOffset( self:GetRight() * ( self.ShipAngleForceCurrentValue * ( self.TurnForceValue or 54000 ) ), self:LocalToWorld( self.PropellerPos )  )
			self.PhysObj:AddAngleVelocity( Vector( sforce, -self.ActualSpeed*( self.PitchForce or .001 ) + math.sin(CurTime())/(self.PitchSineValue or 2), 0 ) )
		
		else 
		
		
			self.ShipAngleForce = Vector(sforce, sforce2, self.ShipAngleForceCurrentValue )
			self.PhysObj:AddAngleVelocity( self.ShipAngleForce )  
		
		end 
		
		self.PhysObj:AddAngleVelocity( Vector( self.SAFApproachVal, 0,0 ) )
		self.Speed = math.Clamp( self.Speed, self.MinVelocity, self.MaxVelocity )
		-- print( self.Speed/self.MaxVelocity ) 
		if( self.Speed < 0 ) then 
			
			self:SetNWFloat( "Throttle", self.Speed/self.MinVelocity )
			
		else 
		
			self:SetNWFloat( "Throttle", self.Speed/self.MaxVelocity )
		
		end 
		
		self:SetNWFloat("ActualSpeed", self.Speed ) 
		
		if( self.IsMicroCruiser ) then 
		
			-- self:GetPhysicsObject():ApplyForceCenter( self:GetForward() * ( self.Speed * 500 ) )
			-- self:GetPhysicsObject():AddAngleVelocity( self:GetForward() * math.sin(CurTime()*.001)*2.5 )
			
		end 
		
		
		self.ActualSpeed = math.Approach( self.ActualSpeed, self.Speed, self.ThrottleIncrementSize or 1 )
		-- print( self.ActualSpeed )
		
		if( self.PropellerPos  ) then 
		
			self.PhysObj:ApplyForceOffset( self:GetForward() * ( self.ActualSpeed * 120 ), self:LocalToWorld( self.PropellerPos ) )
		
		else
		
			self:GetPhysicsObject():ApplyForceCenter( self:GetForward() * ( self.ActualSpeed * 120 ) )
		
		end 
		
	end 
	
	-- if( !IsValid( self.Pilot ) ) then return end
	
	self.PhysObj:SetBuoyancyRatio( self.BuoyancyRatio )
	
	
	
	if( self.HasDeck && !IsValid( self.Deck ) ) then return end -- citadel broken, tfw no controls
	
	if ( self.IsBoating && self:WaterLevel() > 0 && !self.Destroyed ) then

		local p = { { Key = IN_FORWARD, Speed = self.ForwardSpeed, Velocity = self.MaxVelocity };
					{ Key = IN_BACK, Speed = self.ReverseSpeed, Velocity = self.MinVelocity }; }
		if( IsValid( self.Pilot ) && !self.Pilot.LastThrottleMovement ) then 
			
			self.Pilot.LastThrottleMovement = CurTime()
			
		end 
		
		for k,v in ipairs( p ) do
			
			if ( IsValid( self.Pilot ) && self.Pilot:KeyDown( v.Key ) && self.Pilot.LastThrottleMovement + 1.0 <= CurTime() ) then
			
				self.Pilot.LastThrottleMovement = CurTime() 
				
				self.Speed = math.Approach( self.Speed, v.Velocity, v.Speed )
				
			
			else
			
				-- self.Speed = math.Approach( self.Speed, 0, 0.25	 ) //Stop the ship after releasing the key.
			
			end
			
		end
		
		self.LastChadburn = self.LastChadburn or 0 
		
		if( self.LastChadburn != self.Speed && !self.Pilot:KeyDown( IN_FORWARD ) && !self.Pilot:KeyDown( IN_BACK ) ) then 
			
			self.LastChadburn = self.Speed 
			-- print( self.Speed )
			if( self.Speed == self.MaxVelocity || self.Speed == self.MinVelocity ) then 
				
				self:EmitSound( ( self.ChadburnSound or "chadburn/cb1.wav" ), 511, 100 ) 
			
			else			
				
				self:EmitSound( ( self.ChadburnSoundFast or "chadburn/cb2.wav" ), 511, 100 ) 
			
			end 
			
		
		end 
			
		local t = { { Key = IN_MOVERIGHT, Speed = 0.0051 }; { Key = IN_MOVELEFT, Speed = -0.0051 } }
		-- local keydown = false
		for k,v in ipairs( t ) do
			
			if(  IsValid( self.Pilot ) && self.Pilot:KeyDown( v.Key ) ) then
				
				local mult = 1
				if( self.WonkyHull ) then
					
					mult = 100
					
				end
				
				if( self.CanTurnStationary ) then
					
					self.ShipAngleForceTargetValue = -v.Speed*25/self.TurnModifierValue * mult
					-- self.PhysObj:AddAngleVelocity( Vector( self.TurnModifierValue/2, 0,  ) )					
					
					-- print( -v.Speed*25/self.TurnModifierValue )
				else
				
					self.ShipAngleForceTargetValue = -v.Speed/self.TurnModifierValue
					-- self.PhysObj:AddAngleVelocity( Vector( self.TurnModifierValue*2, 0, -v.Speed/self.TurnModifierValue ) )
					
				end
				
				self.PhysObj:ApplyForceCenter( self:GetRight() * ( v.Speed * ( self:GetPhysicsObject():GetMass() *  10 ) ) )
				
				break 
			
			else
				
				self.ShipAngleForceTargetValue = 0 
				
			end
		
		end

		
			
	end

end

util.AddNetworkString( "NeuroNavalAmmoCount" )
util.AddNetworkString( "NeuroNavalAmmoCountSingle" )

function SendBoatWeaponsSingle( boat, idx, count ) 
	
	if( !IsValid( boat ) ) then return end 
	
	local pilot = boat.Pilot 
	if( !IsValid( pilot ) ) then return end 
	
	net.Start("NeuroNavalAmmoCountSingle")	
	-- for k,v in pairs( self.Weaponry ) do 
	net.WriteInt( idx, 16 )
	net.WriteInt( count, 16 )
	-- end 
	net.Send( pilot )
	
end 
function SendBoatWeapons( boat ) 
	
	if( !IsValid( boat ) ) then return end 
	if( !boat.Weaponry  ) then return end 
	
	local pilot = boat.Pilot 
	if( !IsValid( pilot ) ) then return end 
	
	net.Start("NeuroNavalAmmoCount")	
	for k,v in pairs(  boat.Weaponry ) do 
		net.WriteInt( k, 16 )
		net.WriteInt( v.AmmoCounter, 16 )
	end 
	net.Send( pilot )
	
end 

util.AddNetworkString( "NeuroNavalCooldown" )

function Meta:NavalSendWeaponCooldown( idx, count )
	
	if( IsValid( self.Pilot ) ) then 
		
		net.Start("NeuroNavalCooldown") 
			net.WriteInt( idx, 16 )
			net.WriteInt( count, 16 )
		net.Send( self.Pilot )
	
	
	end 

end 
util.AddNetworkString( "NeuroNavalWeapons" )
-- Print Glorified SendTable lol
function Meta:NavalSendWeaponEntities( ply )
	
	if( IsValid( ply ) && self.Weaponry ) then 
		
		local Weps = {}
		for k,v in pairs( self.Weaponry ) do 
			
			if( IsValid( v.Turret ) ) then 
				
				table.insert( Weps, v.Turret )
				
			end 
			
		end 
		-- print("begin network")
		-- PrintTable( Weps )
		net.Start("NeuroNavalWeapons")
			net.WriteInt( #Weps, 32 ) -- write size of table so we know how big the loop on the client must be 
			for i=1,#Weps do 
				net.WriteEntity( Weps[i] )
				
			end 
		
		net.Send( ply )
	
	
	end 

end 

function Meta:NeuroNaval_DefaultCruiserThink()
	-- print(self:GetClass(), self:WaterLevel() )
	if( self:WaterLevel() < 3 ) then
	
		if( self.DamagedPoints && #self.DamagedPoints > 0 ) then
			
			for i=1,#self.DamagedPoints do
			
				local effectdata = EffectData()
				effectdata:SetOrigin( self:LocalToWorld( self.DamagedPoints[i] ) )
				if( self.IsMicroCruiser ) then 
					
					effectdata:SetScale( .5 )
					
				end
				
				self.HealthVal = self.HealthVal - math.random(1,4) 
				
				util.Effect( "immolate", effectdata )

			end
		
		end
		
	end
	
	if( self.Deck && IsValid( self.Deck ) ) then 
		
		if( self.HealthVal > self.Deck.HealthVal ) then 
		
			self.HealthVal = self.HealthVal 
			self:SetNWInt("health", math.floor(self.HealthVal) ) 
			
		elseif( self.HealthVal < self.Deck.HealthVal ) then 
		
			self.Deck.HealthVal = self.HealthVal 
			
		end 
	
	end 
	
	local myang = self:GetAngles() 
	
	if( myang.r > 45 || myang.r < -45 ) then 
		
		self.BuoyancyRatio = self.BuoyancyRatio * .999
	
	end 
	
	-- wallaaa 
	if( self.HasNPCAntiAir ) then 
		
		if( !IsValid( self.Target ) ) then 
	
			local closest = NULL
			local dist = 5555
			
			for k,v in ipairs( player.GetAll() ) do 
				
				-- if( !v.HealthVal ) then continue end 
				
				local distdiff = ( self:GetPos() - v:GetPos() ):Length() 
				local cl = v:GetClass()
				if( distdiff < dist  && v:GetVelocity():Length() > 700 && v != self.Owner.Pilot ) then
					local target = v 
					if( IsValid( v:GetScriptedVehicle() ) ) then
						
						target = v:GetScriptedVehicle()
						
					end 
					
					if( v:GetPos().z > self:GetPos().z + 250 && neuro_inLOS( self, target  ) ) then 					
						
						dist = distdiff  
						closest = v 
						
					end 
					
					
				end 
			
			
			end
			
			if( IsValid( closest ) ) then 
			
				self.Target = closest

				return 
				
			end 
		
		end 
	
	end 
	
	
	if( self.PropellerPosition && self:WaterLevel() > 0 && self.Speed > 15 ) then 
		
		local fx = EffectData()
		fx:SetOrigin( self:LocalToWorld( self.PropellerPosition) )
		fx:SetScale(  self.PropellerSplashSize  )
		util.Effect("waterripple", fx )
		
	end 

	if ( self.Destroyed ) then 
		
		-- print("what in the b")
		if( IsValid( self.Pilot ) ) then
		
			self:EjectCaptain()
			
		end
		
		if( !self.IsBurning ) then 
		
			self.IsBurning = true 
			ParticleEffectAttach( "fire_b", PATTACH_ABSORIGIN_FOLLOW, self, 0 )
			
		end 

		self.DeathTimer = self.DeathTimer + 1
		self.BuoyancyRatio = self.BuoyancyRatio * ( self.SinkRate or .99 )
		self:GetPhysicsObject():SetBuoyancyRatio( self.BuoyancyRatio )
		-- self:SetAngles( LerpAngle( .1, self:GetAngles(), self.FuckedUpAngle ) ) 
		
		
		if( !self.IsMicroCruiser && self:WaterLevel() < 2 ) then
			if( math.random( 1, 15 ) == 2 ) then
				
				ParticleEffect( "HE_impact_wall", self:GetPos(), Angle(0,0,0), nil )
				util.BlastDamage( self, self, self:GetPos(), 1628, 15 ) 
				
			end
			local effectdata = EffectData()
			effectdata:SetOrigin( self:GetPos() + self:GetRight() * math.random(-62,62) + self:GetForward() * math.random(-62,62)  )
			util.Effect( "immolate", effectdata )
			-- self:GetPhysicsObject():SetDamping( 5000.0, 5000.0 )
		end
		-- if(  !self.MassiveFire && !self.IsMicroCruiser ) then 
			
			-- self.MassiveFire = true 
			-- ParticleEffectAttach( "fireplume", PATTACH_ABSORIGIN, self, 0 ) -- big fire 
	
				
		-- end 
		if( !self.MicroFire && self.IsMicroCruiser ) then 
			
			self.MicroFire = true 
			ParticleEffectAttach( "fireplume_small", PATTACH_ABSORIGIN, self, 0 ) -- big fire 
			local LastDamagePos = self.LastDamagePosition or self:GetPos() + self:GetRight() * math.random(-125,125) + self:GetForward() * math.random(-252,252 ) 
			local imbalance = ents.Create("prop_physics") 
			imbalance:SetPos( LastDamagePos )
			imbalance:SetAngles( self:GetAngles() )
			imbalance:SetModel("models/props_c17/concrete_barrier001a.mdl")
			imbalance:Spawn()
			imbalance:SetNoDraw( true )
			imbalance:GetPhysicsObject():SetMass( self:GetPhysicsObject():GetMass() * .1 )
			self:GetPhysicsObject():SetDamping( 10, 15 )
			timer.Create( "ship_imbalance_"..imbalance:EntIndex(), .1, 500, function() 
				
				if( IsValid( imbalance ) ) then 
				
					imbalance:GetPhysicsObject():SetMass( imbalance:GetPhysicsObject():GetMass() * 1.0215 ) 
					
				end 

			end )			
			constraint.Weld( imbalance, self, 0,0,0, true, false )
			self:DeleteOnRemove( imbalance )
			
			if( IsValid( self.KeepUp ) ) then self.KeepUp:Remove() end
			-- self.BuoyancyRatio = self.BuoyancyRatio * 1.5
			-- self:GetPhysicsObject():SetBuoyancyRatio( self.BuoyancyRatio )
	
		end 
		
		if( self.MicroSpectactularDeath && self.DeathTimer > 75  && !self.Fucked ) then 
		
			ParticleEffect("water_impact_big", self:GetPos() + self:GetUp() * 1, Angle(0,0,0), nil )
			self.Shake = ents.Create( "env_shake" )
			self.Shake:SetOwner( self )
			self.Shake:SetPos( self:GetPos() )
			self.Shake:SetKeyValue( "amplitude", "500" )	-- Power of the shake
			self.Shake:SetKeyValue( "radius", "9500" )	-- Radius of the shake
			self.Shake:SetKeyValue( "duration", "5" )	-- Time of shake
			self.Shake:SetKeyValue( "frequency", "255" )	-- How har should the screenshake be
			self.Shake:SetKeyValue( "spawnflags", "4" )	-- Spawnflags( In Air )
			self.Shake:Spawn()
			self.Shake:Activate()
			self.Shake:Fire( "StartShake", "", 0 )
			util.BlastDamage( self, self, self:GetPos()+Vector(0,0,2504), 1024, 25000 )
			self:PlayWorldSound( "ambient/athmosphere/thunder2.wav")
			self:PlayWorldSound( "ambient/explosions/explode_7.wav")
			self:GetPhysicsObject():SetBuoyancyRatio( 0 )
			self:SetColor( Color( 155,155,155,255 ) )
			self:Fire("kill","",10 )
							-- self.BuoyancyRatio = self.BuoyancyRatio * 1.5
			-- self:GetPhysicsObject():SetBuoyancyRatio( self.BuoyancyRatio )
			self.Fucked = true 
			
			return
			
		end 
		
		if( self.SpectactularDeath ) then 
			
		
			
			if( self.DeathTimer > 50  && !self.Fucked ) then 
			
			
				ParticleEffect("fireball_explosion", self:GetPos() + self:GetUp() * 1, Angle(0,0,0), nil )
			
				-- ParticleEffect("V1_impact", self:GetPos() + self:GetUp() * 700, Angle(0,0,0), nil )
				self.Shake = ents.Create( "env_shake" )
				self.Shake:SetOwner( self )
				self.Shake:SetPos( self:GetPos() )
				-- self.Shake:SetParent( self )
				self.Shake:SetKeyValue( "amplitude", "500" )	-- Power of the shake
				self.Shake:SetKeyValue( "radius", "9500" )	-- Radius of the shake
				self.Shake:SetKeyValue( "duration", "5" )	-- Time of shake
				self.Shake:SetKeyValue( "frequency", "255" )	-- How har should the screenshake be
				self.Shake:SetKeyValue( "spawnflags", "4" )	-- Spawnflags( In Air )
				self.Shake:Spawn()
				self.Shake:Activate()
				self.Shake:Fire( "StartShake", "", 0 )
				util.BlastDamage( self, self, self:GetPos()+Vector(0,0,2504), 1024, 25000 )
				self:PlayWorldSound( "ambient/athmosphere/thunder2.wav")
				self:PlayWorldSound( "ambient/explosions/explode_7.wav")
				self:GetPhysicsObject():SetBuoyancyRatio( 0 )
				self:SetColor( Color( 55,55,55,255 ) )
				self:Fire("kill","",5 )
				
				self.Fucked = true 
				
				return
				
			end 
			
		end 
		
		if self.DeathTimer > 100 then
		
			
			self.BuoyancyRatio = 0.0
			self:Remove()
			
		end
		
		self:NextThink( CurTime() + 0.2 )
		
		return
		
	end
	
	-- if ( self.NeuroNaval_HasMissileJammer ) then
	
		-- self:NeurNaval_MissileJammer()
	
	-- end
	if ( self.Cannons != nil ) then
		
		for k,v in pairs( self.Cannons ) do
			
			if( IsValid( v )  ) then 
			
				v:GetPhysicsObject():Wake()
			
			end
			
		end
	
	
	end
	if ( self.IsBoating && IsValid( self.Pilot ) ) then
		
		local vel = self:GetVelocity():Length()
		
		-- self.EngineSound:ChangePitch( math.Clamp( 90 + ( vel / 30 ), 90, 155 ), 0.1 )
		self:SetNWFloat("BoostPercentage",  self.ActualSpeed / self.MaxVelocity )
		self.EngineSound:ChangeVolume( math.abs( 1.0 * self.ActualSpeed / self.MaxVelocity )) 
		self.WaterSound:ChangeVolume( math.abs(1.0 * self.ActualSpeed / self.MaxVelocity )) 
		
		if( self.Pilot == NULL ) then return end
		
		-- self.Pilot:SetPos( self:GetPos() + self:GetUp() * 120 )
		
		if( self.Pilot:KeyDown( IN_USE ) && self.LastUse + 0.95  <= CurTime() ) then
			
			self:EjectCaptain()
			
			return
			
		end
		
		if( self.Pilot:KeyDown( IN_JUMP ) && self.LastUse + 1 <= CurTime() ) then
			
			local ply = self.Pilot
			self.LastUse = CurTime()

			if( type( self.Cannons ) == "table" ) then
			
				local found = false
				local itr = 0
				
					
				while !found do
					itr = itr + 1
					
					if( itr > 25 ) then break end 
					
					local r = math.random(1,#self.Cannons)
					local d = self.Cannons[r].Pilot
					if( !IsValid( d ) && self.Cannons[r].VehicleType == STATIC_GUN ) then
						
						self:EjectCaptain()
			
						self.Cannons[r]:Use( ply, ply, 0, 0 )
						found = true
						
						break
						
					end
						
				end
				
			end
			
			return
		
		end
		
		if (  self.Pilot:KeyDown( IN_ATTACK2 ) && ( !self.WeaponSystems ) && self.LastAttackKeyDown + 0.5 < CurTime() ) then
		
			local id = self.EquipmentNames[ self.FireMode ].Identity
			local wep = self.RocketVisuals[ id ]
			
			if ( wep.LastAttack + wep.Cooldown <= CurTime() ) then
			
				self:NeuroPlanes_FireRobot( wep, id )
				
			else
			

				local cd = math.ceil( ( wep.LastAttack + wep.Cooldown ) - CurTime() ) 
				
				if ( cd == 1 ) then 
				
					self.Pilot:PrintMessage( HUD_PRINTTALK, self.PrintName..": "..wep.PrintName.." ready in "..tostring( cd ).. " second." )
				
				else
				
					self.Pilot:PrintMessage( HUD_PRINTTALK, self.PrintName..": "..wep.PrintName.." ready in "..tostring( cd ).. " seconds." )	
				
				end
				
			end
			
			self.LastAttackKeyDown = CurTime()

		end
		
		// Firemode 
		if ( self.EquipmentNames && self.Pilot:KeyDown( IN_RELOAD ) && self.LastFireModeChange + 0.5 <= CurTime() ) then

			self:CycleThroughWeaponsList()
			
		end
		
		if( self.HasAdvancedSAMSystem ) then
				
			
			
			
			
		
		end
		

	end
	
		self:NextThink( CurTime() )

	if( IsValid( self.PhysObj ) ) then 
	
		self.PhysObj:SetBuoyancyRatio( self.BuoyancyRatio )	
		self.PhysObj:Wake()
		
	end 
			
	return true 
	
end

-- function Meta:FindWaterSurface( ply )
	
	

-- end 

function Meta:CaptainHasGunsThink()
	-- self:NextThink(CurTime())
	
	if( self.Weaponry && IsValid( self.Pilot )  && self.Pilot.SelectedWeapon ) then 
		local sameType = -1
		
		for k,v in pairs( self.Weaponry ) do 
					
			-- local k = self.Pilot.SelectedWeapon
			-- local v = self.Weaponry[k]
			-- print( self.Pilot.SelectedWeapon )
			-- print( v.WeaponGroup )
			if ( v.WeaponGroup == self.Pilot.SelectedWeapon && IsValid( v.Turret ) && !v.Destroyed ) then 
				-- print("eh?")
				local tr1,trace1 = {},{}
				tr1.start = self:GetPos()
				tr1.endpos = tr1.start+ self:GetUp() * self.CamUp + self.Pilot:GetAimVector() * -self.CamDist
				tr1.filter = { self, self.Pilot }
				tr1.mask = MASK_SOLID_BRUSHONLY
				trace1 = util.TraceLine ( tr1 )
				
				local pos = trace1.HitPos + trace1.HitNormal * 8
				if( pos.z < self:GetPos().z+350 ) then pos.z = self:GetPos().z + self.CameraMinZ or 350 end 
				
				if( self.Pilot.zoomValue ) then 
				
					pos.z = pos.z + ( 90 / self.Pilot.zoomValue )*11.5
				
				end 
				
				self.Pilot:SetPos( pos )	
				
				local tr, trace = {},{}
				trace.start =  self.Pilot:GetShootPos()
				trace.endpos = trace.start + self.Pilot:GetAimVector() * 44000
				trace.filter = { self, v.Turret, v.Barrel, self.Deck }
				trace.mask = MASK_SOLID + MASK_WATER
				tr = util.TraceLine( trace )
				if( trace.Hit && IsValid( trace.Entity ) ) then 
					
					self.TraceTarget = trace.Entity
					self.LastTraceTargetHit = CurTime() 
					
				
				end 
				-- self:DrawLaserTracer( trace.start, tr.HitPos )
				-- debugoverlay.Line( tr.HitPos, tr.HitPos + Vector(0,0,500), 2.1, Color( 255,0,0,255 ), true  )
				if( !self.Pilot:KeyDown( IN_ATTACK2 ) ) then 
				
					self.Pilot.ClientVector = tr.HitPos
					
				end 
				
				local hpos = self.Pilot.ClientVector 
				if( !self.Pilot.LastSync ) then self.Pilot.LastSync = CurTime() end 
				
				if( self.Pilot.LastSync && self.Pilot.LastSync + 0.05 <= CurTime() ) then 
					
					self.Pilot.LastSync = CurTime()
					self.Pilot:SetNWVector("_NNHPOS", hpos )
					
				end 
				-- if( self.IPPCorrectionalZVector ) then 
			
					-- hpos.z = hpos.z + ( self:GetPos().z - v.Base:GetPos().z)*2
					
				-- end 
				-- debugoverlay.Sphere( hpos, 28, 0.1,Color(0,255,0,255 ), true )
				
				local dist = ( trace.start - hpos ):Length()

				-- if( tr.Fraction > 0.000021 ) then  
				
				local TargetPos = hpos
				local ta = ( v.Turret:GetPos() - TargetPos ):Angle()
				local ma = self:GetAngles()
				local offs = self:VecAngD( ma.y, ta.y )
				local TargetAngle = -offs + 180
				local towerang = v.Turret:GetAngles()
				local diff = self:VecAngD( towerang.y, ta.y )
				local angg = self:GetAngles()
				local maxpitch = self.MaxBarrelPitch or 55
				local minpitch = self.MinBarrelPitch or 25
				local turretAng = v.Turret:GetAngles()
				
				-- v.Turret.MaxRange = self.MaxRange
				-- v.Turret.MinRange = self.MinRange
				self.Barrel = v.Barrel
				self.BarrelLength = v.BarrelLength 
				
				local theta =  math.Clamp( self:BallisticCalculation( hpos ), turretAng.p-maxpitch, turretAng.p+17.5 )
				if( v.DisableIPP ) then 
					
					theta = math.Clamp( self.Pilot:EyeAngles().p-2, -65, -7 )
				
				end 
				-- local ctr,ctrace ={},{}
				
				-- if( v.UseHitScan ) then 
					
					-- theta = -ta.p
					
				-- end 
				
				-- print ( theta, self:BallisticCalculation( hpos ) )
				angg:RotateAroundAxis( self:GetUp(), TargetAngle )
				local extra = 0 
				local extrap = 0 
				if( v.TAng ) then
					extra = v.TAng.y 
					extrap = v.TAng.p 
					
				end 
				
					-- print( v.TAng )
				local newDiff = math.AngleDifference( ma.y+extra, angg.y ) 
				-- print( newDiff )
				v.AngDiff = newDiff 
				
				if( v.AngDiff > -v.MaxYaw && v.AngDiff < v.MaxYaw ) then 
					
					local lerpvalue = v.TowerTurnSpeed
					v.Barrel:SetNWInt("BarrelTheta",theta )
					v.Turret:SetNWFloat("TowerYaw", angg.y )
					-- if( !v.DontPitchBarrel ) then 
					
					v.Turret:SetAngles( LerpAngle( FrameTime()*lerpvalue, towerang, angg ) )
						
					-- end 
					
					local ba = v.Turret:GetAngles()
					if( !v.DontAnimateBarrel ) then 
					
						v.Barrel:SetAngles( Angle( Lerp(  FrameTime()*lerpvalue, v.Barrel:GetAngles().p, theta), ba.y, ba.r  ) )
					
					end 
					
				end 
				
			end 
			
		end 
		
		if( self.LastAttackKeyDown && self.LastAttackKeyDown + .25 <= CurTime() ) then  
			
			self.LastAttackKeyDown 	= CurTime()
			
			local hpos = self.Pilot.ClientVector 
			for k,v in pairs( self.Weaponry ) do 
				
				if ( v.WeaponGroup == self.Pilot.SelectedWeapon && IsValid( v.Turret ) && !v.Destroyed && v.AmmoCounter > 0 ) then 
					-- print( k, v.LastAttack, v.LastAttack + v.Cooldown <= CurTime() )
					-- print(k)
					if( v.LastAttack + v.Cooldown >= CurTime() ) then continue end 
					
					if ( v.AngDiff && v.AngDiff > -v.MaxYaw && v.AngDiff < v.MaxYaw &&  self.Pilot:KeyDown( IN_ATTACK ) ) then 
							
							local numshots = v.NumShots or #v.BarrelPorts
							if( numshots == 1 ) then 
								
								v.AmmoCounter = v.AmmoCounter - 1
								self:NavalSendWeaponCooldown( k, v.AmmoCounter )
								
								self:YamatoFire( v, 1, k, hpos   ) 
								v.LastAttack = CurTime()
								-- self.LastAttackKeyDown = CurTime()
								
								if( v.Cooldown >= 2.5 ) then 
										
									timer.Simple( v.Cooldown, function() 
										
										if( IsValid( self ) && IsValid( self.Pilot ) ) then 
											
											self.Pilot:SendLua("HitMarker([["..v.Name.." is ready!]])")
										
										
										end 
									
									end )
								
								end 
								if( v.Cooldown > .25 ) then 
								
									break 
								
								end 
								
							else 

								if( self.GroupShotCounter < numshots ) then 
		
									if( self.GroupShotCooldown && self.GroupShotCooldown + .15 >= CurTime() ) then continue end 
									
									self.GroupShotCounter = self.GroupShotCounter + 1 
									self.GroupShotCooldown = CurTime() 
										
									if( IsValid( self )  ) then 
									
										v.AmmoCounter = v.AmmoCounter - 1
									
										self:YamatoFire( v, self.GroupShotCounter, k, hpos   ) 
										
									end 
									
									break
									
								else
									
									v.LastAttack = CurTime()
									v.AmmoCounter = v.AmmoCounter - 1
									self:NavalSendWeaponCooldown( k, v.AmmoCounter )
									
									self.LastAttackKeyDown = CurTime()
									self.GroupShotCounter = 0 
									-- print("walla?")		
									if( v.Cooldown >= 2.5 ) then 
											
										timer.Simple( v.Cooldown, function() 
											
											if( IsValid( self ) && IsValid( self.Pilot ) ) then 
												
												self.Pilot:SendLua("HitMarker([["..v.Name.." is ready!]])")
											
											
											end 
										
										end )
									
									end 
						
									break  
								
								end 
								
							end 

						-- end 
						
						-- break 
						
					
					end 
				
				end 
			
			
			end 
		
		end 
		
	end 
	
end 

function Meta:MicroShipGunFire( wep, idx, lastidx, targetpos  )
	-- self.Pilot:PrintMessage( HUD_PRINTCENTER, lastidx )
	local pos = wep.Barrel:GetPos() + wep.Barrel:GetForward() * ( wep.BarrelLength * 3)
	local numshots = wep.NumShots or #wep.BarrelPorts
	
	if( wep.BarrelPorts ) then 	
		pos = wep.Barrel:LocalToWorld( wep.BarrelPorts[idx] )
	end
	
	local bullet = {} 
	bullet.Num 		= 1 
	bullet.Src 		= pos
	bullet.Dir 		= wep.Barrel:GetAngles():Forward()
	bullet.Spread 	= math.Rand(-1,1) * Vector( .01531, .01531, .015  )
	bullet.Tracer	= 1
	bullet.Force	= 5
	bullet.Damage	= math.random(wep.Damage*.7,wep.Damage)
	bullet.AmmoType = "Ar2" 
	bullet.TracerName 	= "AR2Tracer"
	bullet.Attacker = self.Pilot
	-- bullet.Callback    = function (a,b,c) SplodeOnImpact(self,a,b,c) end 
	bullet.Callback    = function ( a, b, c )
							
							local effectdata = EffectData()
								effectdata:SetOrigin( b.HitPos )
								effectdata:SetStart( b.HitNormal )
								effectdata:SetNormal( b.HitNormal )
								effectdata:SetMagnitude( 1 )
								effectdata:SetScale( 0.75 )
								effectdata:SetRadius( 1 )
							util.Effect( "micro_he_impact_plane", effectdata )
							
							return { damage = true, effects = DoDefaultEffect } 
							
					end 
			
 	wep.Barrel:FireBullets( bullet )
	
	if( wep.Muzzle && wep.Muzzle != "" ) then 
		
		ParticleEffectAttach( wep.Muzzle, PATTACH_ABSORIGIN_FOLLOW, wep.Barrel, 0 )
	
	end 

	if( wep.ShootSound ) then 
		local soundEnt = wep.Barrel 
		if( idx == 2 ) then 
			soundEnt = wep.Turret
		elseif( idx == 3 ) then 
			soundEnt = wep.Base
		end 
		
		soundEnt:PlayWorldSound( wep.ShootSound )
		soundEnt:EmitSound( wep.ShootSound, 511, 100 )
		
		-- print("LJUD PLIS")
	end 

end 

function Meta:YamatoFire( wep, idx, lastidx, targetpos  )
	
	if( wep.UseHitScan ) then 
	
		self:MicroShipGunFire( wep, idx, lastidx, targetpos )
	
		return
		
	end 
	
	local pos = wep.Barrel:GetPos()
	local numshots = wep.NumShots or #wep.BarrelPorts
	
	if( wep.BarrelPorts ) then 	
		pos = wep.Barrel:LocalToWorld( wep.BarrelPorts[idx] )
	end 
	
	-- print( wep.BarrelLength )
	local shell = ents.Create( wep.AmmoType )
	shell:SetPos( pos + wep.Barrel:GetForward() * wep.BarrelLength )

	debugoverlay.Sphere( pos + wep.Barrel:GetForward() * wep.BarrelLength, 28, 1.1,Color(0,255,0,255 ), true )
	
	shell:SetModel( wep.AmmoModel )
	shell:SetAngles( wep.Barrel:GetAngles()  )
	shell.Owner = self.Pilot
	shell.DeployAngle = wep.Turret:GetAngles()
	shell.ShipFired = true 
	shell:Spawn()
	shell.MinDamage = wep.Damage*.7
	shell.MaxDamage = wep.Damage
	shell.PenetrationDepth = wep.PenetrationDepth
	shell.Radius = wep.Radius 
	shell:SetOwner( self )
	shell:GetPhysicsObject():Wake()
	shell:GetPhysicsObject():SetMass( 50 )
	shell:GetPhysicsObject():EnableDrag( true )
	shell:GetPhysicsObject():EnableGravity( true )
	shell:GetPhysicsObject():SetDamping( 0,0 )
	shell:GetPhysicsObject():SetDragCoefficient( 1.0 )
	shell.ImpactPos = targetpos 
	if( wep.AmmoType != "sent_mini_torpedo" && wep.AmmoType != "sent_mini_naval_mine" && self.IPPShellVelocity || wep.ShellVelocity && wep.ShellVelocity > 500 ) then 
	
		self:GetPhysicsObject():ApplyForceOffset( shell:GetForward() * -( self:GetPhysicsObject():GetMass() * ( wep.Recoil or .001  ) ), shell:GetPos() )
	
	end 
	
	if( IsValid( self.TraceTarget ) && self.LastTraceTargetHit + 5 >= CurTime() ) then
		
		shell.Target = self.TraceTarget 
	
	end 
	
			
	if( wep.ShellVelocity ) then 
			
		shell:GetPhysicsObject():SetVelocity(  shell:GetForward() * wep.ShellVelocity )	
		
	else 
	
		shell:GetPhysicsObject():SetVelocity(  self:GetVelocity() +  shell:GetForward() * self.IPPShellVelocity )
	
	end 
	
	shell:Fire("kill","",60 )
	if( IsValid( self.Pilot ) && !IsValid( self.Pilot:GetNWEntity("_CINEMATIC_SHELL") ) ) then 
		
		self.Pilot:SetNWEntity("_CINEMATIC_SHELL", shell )
		
	end 
	-- timer.Simple( 0, function() 
	-- print( shell:GetVelocity():Length() )
	-- end )
	-- shell:SetVelocity( shell:GetForward() * 700500 )
	
	-- shell:GetPhysicsObject():SetVelocity( shell:GetForward() * 500000 )
	
	
	-- print( shell:GetVelocity():Length() )
	if( wep.ShootSound ) then 
		local soundEnt = wep.Barrel 
		if( idx == 2 ) then 
			soundEnt = wep.Turret
		elseif( idx == 3 ) then 
			soundEnt = wep.Base
		end 
		
		soundEnt:PlayWorldSound( wep.ShootSound )
		soundEnt:EmitSound( wep.ShootSound, 511, 100 )
		-- print("LJUD PLIS")
	end 

		-- v.Barrel:PlayWorldSound( v.ShootSound )
		-- v.Barrel:EmitSound( v.ShootSound, 511, 100 )

	-- end  
							
	if( wep.Muzzle && wep.Muzzle != "" ) then 
		
		ParticleEffectAttach( wep.Muzzle, PATTACH_ABSORIGIN_FOLLOW, shell, 0 )
	
	end 
	
	-- local shell = 

end 

function Meta:NeuroNaval_DefaultDamage( dmginfo )

	if( self.Destroyed ) then return end

	local dt = dmginfo:GetDamageType()
	local atk = dmginfo:GetAttacker()
	local dampos = dmginfo:GetDamagePosition()
	self.LastDamagePosition = dampos
	--[[/*^
	if( dt && DMG_BLAST_SURFACE == DMG_BLAST_SURFACE || dt && DMG_BLAST == DMG_BLAST || dt && DMG_BURN == DMG_BURN   ) then 
		-- // Nothing, these can hurt us
	else
	
		local infomessage = "This vehicle can only be damaged by armor piercing rounds and explosives!"
		
		if( self.LastReminder + 3 <= CurTime() && atk:IsPlayer() ) then
			
			self.LastReminder = CurTime()
			atk:PrintMessage( HUD_PRINTCENTER, infomessage )

		end
		
		return
		
	end
	^*/ ]]--
	
	
	local dmg = dmginfo:GetDamage()
	-- self:TakePhysicsDamage( dmginfo )
	self.HealthVal = self.HealthVal - dmg
	self:SetNWInt( "health" , self.HealthVal )
	local dpos = dmginfo:GetDamagePosition()
	local inflictor = dmginfo:GetInflictor()
	-- print( inflictor,"INFLICTOR")
	if( IsValid( self.Pilot ) && IsValid( inflictor ) && inflictor:GetClass() == "sent_mini_torpedo" ) then 
		
		local pos = self:GetPos()
		local side = "port"
		local _amt
		if( dmg <= 500 ) then
			_amt = "Minor"
		elseif( dmg > 500 ) then 
			_amt = "Medium" 
		elseif( dmg > 2500 ) then 
			_amt = "Major" 
		elseif( dmg > 5000 ) then
			_amt = "Critical"
		end 
		
		if( self:WorldToLocal( dpos ).y < 0 ) then 
			side = "starboard"
		end 
		
		self.Pilot:PrintMessage(HUD_PRINTTALK, "WARNING! ".._amt.." torpedo damage on "..side.." side")
				
	end 
	
	if( self.AmmoRacks && #self.AmmoRacks > 0 ) then 
		
		for k,v in pairs( self.AmmoRacks ) do 
			
			if( v.Destroyed ) then continue end 
			local vpos =  self:LocalToWorld( v.Pos )
			
			local dist = ( dpos - vpos ):Length() 
			
			if( dist < 79 ) then 
				
				v.Health = v.Health - dmg 
				-- print("ouch")
			end
			
			if( v.Health <= 0 ) then 
				
				v.Destroyed = true 
				local prop = ents.Create("prop_physics_override")
				prop:SetPos( vpos )
				prop:SetParent( self )
				prop:SetNoDraw( true )
				prop:Spawn()
				ParticleEffectAttach( "tank_cookoff", PATTACH_ABSORIGIN_FOLLOW, prop, 0 )
				-- tank_cookoff
			
			end 
			-- print( dist, k )
		
		end 
	
	end 
	
	if( self.HealthVal < .35 * self.InitialHealth ) then 	
		
		self:SetNWBool("RadarFucked",true)
		
	end 
	
	if( atk:IsPlayer() && dmg > 25 ) then
	
		-- atk:PrintMessage( HUD_PRINTTALK, "You dealt "..math.floor( dmg ).." damage to "..self.PrintName )
		atk:SendLua("HitMarker("..math.floor(dmg)..")")
	
	end
	local damagepos = dmginfo:GetDamagePosition() 
	if( self.CitadelPos ) then 
		-- print( ( damagepos - self:LocalToWorld( self.CitadelPos ) ):Length() )
		if( ( damagepos - self:LocalToWorld( self.CitadelPos ) ):Length() < 25 ) then
			
			self.CitadelHealth = self.CitadelHealth - dmg 
			-- print( self.CitadelHealth )
			if( self.CitadelHealth <= 0 ) then 
			
				self.Destroyed = true 
				
				util.BlastDamage( self, dmginfo:GetAttacker(), self:LocalToWorld( self.CitaDelPos ), 500, math.random(750,1500) )
				ParticleEffect( "water_impact_big", pos, Angle(0,0,0), nil )
				ParticleEffect( "rt_impact", pos, Angle(0,0,0), nil )
				
			end 
		
		end 
	
	end 
	
	if( self.RudderPos ) then 
		
		if( ( damagepos - self:LocalToWorld( self.RudderPos ) ):Length() < 25 ) then
			
			self.RudderHealth = self.RudderHealth - dmg 
			
			if( self.RudderHealth <= 0 ) then 
			
				self.RudderIsFucked = true 
				
				if( IsValid( self.Pilot ) ) then 
				
					self.Pilot:SendLua("HitMarker([[Your rudder was destroyed!]])")
					
				end 
				
				return 
				
			end 
			
		end 
	
	end 
	
	if( self.Weaponry ) then 
		
		
		for k,v in ipairs( self.Weaponry ) do 
		
			if( IsValid( v.Base ) && !v.Destroyed ) then 
			
				local dist = dampos:DistToSqr( v.Base:GetPos() )
				if( dist < 8500 ) then 
				
					v.HealthVal = v.HealthVal - dmg 
					-- print( math.floor( v.HealthVal ))
					if( v.HealthVal <= 0 ) then 
					
						v.Destroyed = true 
						if( IsValid( v.Barrel ) ) then 
						
							v.Barrel:SetColor( Color( 45,45,45,255 ) )
							
						end 
						
						if( IsValid( v.Turret )&& IsValid( v.Turret.Barrel ) ) then 
						
							v.Turret:SetColor( Color( 45,45,45,255 ) )
							v.Turret.Barrel:SetColor( Color( 45,45,45,255 ) )
							v.Turret:Ignite( 500, 16 )
							
						end 
						
						
						self:EmitSound("Misc/fire.wav")
						ParticleEffect("neuro_gascan_explo", v.Base:GetPos(), Angle(0,0,0), v.Base )
						ParticleEffectAttach( "fire_b", PATTACH_ABSORIGIN_FOLLOW, v.Base, 0 )
						timer.Simple( math.random(10,15), function() 
							-- ToDo: Fire Fighting QTE
							if( IsValid( v.Base ) ) then 
							
								v.Base:StopParticles()
								
							end 
							
						end ) 
						
						if( IsValid( atk ) && atk:IsPlayer() && v.HealthVal <= 0 ) then 
							
							atk:SendLua("HitMarker([["..v.Name.." destroyed!]])")
						
						end 
						
					
						break 
						
					end 
				
				end 
			
			
			end 
			
		end 
		
	
	end 
	
	-- if( self.WeaponSystems ) then
		
		-- for k,v in pairs( self.WeaponSystems ) do 
			
			-- if ( IsValid( v.Barrel ) ) then 
				
				
			-- end 
		
		-- end 
	
	-- end 
	
	--DamagedPoints
	if( dmg > 350 ) then
		
		-- print( "ouch" )
		local tr,trace = {},{}
		tr.start = dmginfo:GetDamagePosition()
		tr.endpos = self:GetPos()
		tr.filter = {}
		tr.mask = MASK_SOLID
		trace = util.TraceLine( tr )
		
		local a,b = trace.HitPos + trace.HitNormal, trace.HitPos - trace.HitNormal
		util.Decal("Scorch", a, b )
			
		self.BuoyancyRatio = self.BuoyancyRatio * 0.9999
		
		-- if( self:WaterLevel() == 2 ) then self.Destroyed = true return end
		
		local normdist = -20 
		if( self.IsMicroCruiser ) then 
		
			normdist = -2 
			
		end 
		if( trace.Hit && IsValid( trace.Entity ) && trace.Entity == self  && self.HealthVal < .85 * self.InitialHealth ) then
			
			if( self.DamagedPoints == nil ) then self.DamagedPoints = {} end
			
			if( self.DamagePoints == {} ) then
			
				self.DamagedPoints[1] = self:WorldToLocal( trace.HitPos + trace.HitNormal * normdist )
			
			else
			
				self.DamagedPoints[#self.DamagedPoints+1] = self:WorldToLocal( trace.HitPos + trace.HitNormal * normdist )
				
				local waterballast = ents.Create("prop_physics_override")
				waterballast:SetPos(  trace.HitPos + trace.HitNormal * normdist )
				waterballast:SetAngles( self:GetAngles() )
				waterballast:SetModel( "models/props_junk/popcan01a.mdl" )
				waterballast:Spawn()
				self:DeleteOnRemove( waterballast )
				waterballast:SetNoDraw( true )
				waterballast:GetPhysicsObject():SetMass( self:GetPhysicsObject():GetMass() * .015 )
				constraint.Weld( self, waterballast, 0,0,0, true, false )
				
				
			end
			
		end
	
	
	end

	if ( self.HealthVal < 0 ) then
		
		-- if( IsValid( self.KeepUp ) ) then
			
			-- self.KeepUp:Remove()
		
		-- end
		
		if( self:WaterLevel() > 0 && !self.IsMicroCruiser ) then
		
			ParticleEffect( "water_impact_big", self:GetPos(), Angle(0,0,0), nil )
			ParticleEffect( "HE_impact_wall", self:GetPos()+self:GetUp() * 100, Angle(0,0,0), nil )
		
		end
		
	
		self:EmitSound( "ambient/explosions/explode_2.wav", 511, 100 )
		

	
		self.Destroyed = true
		self.BuoyancyRatio = self.BuoyancyRatio * .65
		self:GetPhysicsObject():SetBuoyancyRatio( self.BuoyancyRatio )
		
	end
	
end

function Meta:EjectCaptain()
	
	if ( !IsValid( self.Pilot ) ) then 
	
		return
		
	end
	
	self.LastUse = CurTime()
	self.Owner = NULL 
	self.Pilot:UnSpectate()
	self.Pilot:DrawViewModel( true )
	self.Pilot:DrawWorldModel( true )
	self.Pilot:SetMoveType( MOVETYPE_WALK )
	self.Pilot:Spawn()
	
	self.Pilot:SetNetworkedBool( "ToSea", false )
	self:SetNetworkedEntity( "Pilot", NULL )
	self.Pilot:SetNetworkedEntity( "Ship", NULL )
	-- self.Pilot:SetNetworkedEntity( "Plane", NULL )
	self.Pilot:SetNetworkedBool( "InFlight", false )
	self.Pilot:SetNetworkedBool( "DrawDesignator", false )
	
	self.Pilot:SetPos( self:LocalToWorld( self.ExitPos ) )
	self.Pilot:SetAngles( Angle( 0, self:GetAngles().y,0 ) )
	self.Owner = NULL
	self.Pilot:SetScriptedVehicle( NULL )
	if( !self.IsMicroCruiser ) then 
	
		self.Speed = 0
		self:NextThink( CurTime() + 2 )
		self.EngineSound:Stop()
	
	end 

	self.IsBoating = false
	self.Pilot = NULL

	return
	
end

function Meta:NeuroNaval_DefaultUse( ply, caller )


	if( ply == self.Pilot ) then return end
	
	if ( !self.IsBoating && !IsValid( self.Pilot ) && self.LastUse + 1 <= CurTime() ) then 
		
		self.LastUse = CurTime()
		ply.SelectedWeapon = 1 
		ply:SetNWInt("Selected_Weapon", 1 )
		self:GetPhysicsObject():Wake()
		self:GetPhysicsObject():EnableMotion(true)
		self.IsBoating = true
		self.Pilot = ply
		self.Owner = ply

		ply:Spectate( OBS_MODE_CHASE  )
		ply:DrawViewModel( false )
		ply:DrawWorldModel( false )
		ply:StripWeapons()
		ply:SetMoveType(MOVETYPE_NONE )
		ply:SetScriptedVehicle( self )
		ply:SetNetworkedEntity( "Ship", self )
		-- ply:SetNetworkedEntity( "Plane", self )
		ply:SetNetworkedBool("ToSea", true)
		ply:SetNetworkedBool("InFlight", true)
		self:SetNetworkedEntity("Pilot", ply )
		self.EngineSound:PlayEx(512,100)
		self.WaterSound:PlayEx(512,100)
		timer.Simple( 0.5, function()
				
			if( IsValid( ply ) && IsValid( self ) ) then 
			
				self:NavalSendWeaponEntities(ply)
				SendBoatWeapons( self ) 
			
			end 
			
		end)

			
		if( self.IsMicroCruiser && !self.ShipName ) then 
			
			ply:ConCommand("shipname")
			
		end 
		
	else
		
		if( type( self.Cannons ) == "table" ) then
		
			local found = false
			local itr = 0
			
				
			while !found do
				itr = itr + 1
				
				if( itr > 10 ) then break end 
				
				local r = math.random(1,#self.Cannons)
				local d = self.Cannons[r].Pilot
				if( !IsValid( d ) && self.Cannons[r].VehicleType != nil ) then
					
					self.Cannons[r]:Use( ply, ply, 0, 0 )
					found = true
					
					break
					
				end
					
			end
			
		end
		
	end
	
end

function Meta:NeuroNaval_DefaultRemove()

	if ( IsValid( self.Pilot ) ) then
	
		self:EjectCaptain()
	
	end
	
	if( IsValid( self.KeepUp ) ) then
	
		self.KeepUp:Remove()
	
	end
	
	self.EngineSound:Stop()
	self.WaterSound:Stop()

	if (self.Radars) then
		for i=1,#self.Radars do	
			if( IsValid( self.Radars[i] ) ) then self.Radars[i]:Remove() end	
		end
	end	
end

function Meta:NeuroNaval_DefaultCollisionCallback( data, physobj )
	
	-- Do shit here
	if( data.HitEntity && ( data.HitEntity.IsMicroCruiser || data.HitEntity == game.GetWorld() ) ) then 
		
		-- print( self, "Speed: "..math.floor(data.Speed), data.DeltaTime, data.HitForce )
		if( data.DeltaTime > 0.1 && data.Speed > 0 ) then 
			
			local fx = EffectData()
			fx:SetOrigin( data.HitPos )
			fx:SetStart( data.HitPos )
			fx:SetNormal( data.HitNormal *-1)
			fx:SetEntity( data.HitEntity )
			fx:SetScale( 1 )
			fx:SetMagnitude( 10 )
			util.Effect( "cball_explode", fx )			
			local fx = EffectData()
			fx:SetOrigin( data.HitPos )
			fx:SetStart( data.HitPos )
			fx:SetNormal( data.HitNormal *-1)
			fx:SetEntity( data.HitEntity )
			fx:SetScale( 1 )
			fx:SetMagnitude( 10 )
			util.Effect( "ManhackSparks", fx )
			
			self.HealthVal = self.HealthVal - math.random(5,10)*data.Speed 
			self:SetNWInt("health",math.floor(self.HealthVal))
			
			
		end
		
		if( data.Speed > 5 && data.DeltaTime > .5 ) then 
			
			if( math.random( 1,2) == 2 ) then 
			
				self:EmitSound( "ambient/materials/metal_stress"..math.random(1,5)..".wav", 511, 100 )
			
			else
					
				self:EmitSound( "doors/heavy_metal_move1.wav", 511, math.random(80,120) )
			
			end 
			
		end 
		
	end 
	
end

function Meta:NeuroNaval_DefaultCruiserInit()
	
	
	self.FuckedUpAngle = AngleRand() * 180 
	self.DamagedPoints = {}
	self.ActualSpeed = 0
	self.HealthVal = self.InitialHealth
	self.EngineSound = CreateSound( self, self.EngineSoundPath )
	self.WaterSound = CreateSound( self, "Misc/water_movement.wav" )
	self.GroupShotCounter = 0 
	self.GroupShotCooldown = 0 
	
	self.ShipAngleForce = Angle(0,0,0)
	self.ShipAngleForceTargetValue = 0 
	self.ShipAngleForceCurrentValue = 0 
	
	self.LastAttackKeyDown = 0
	self.LastReminder = 0
	self.LastUse = CurTime()
	self.LastAttack = CurTime()
	
	self.Destroyed = false
	self.Burning = false
	self.Speed = 0
	self.DeathTimer = 0

	-- // Timers
	self.LastPrimaryAttack = 0
	self.LastSecondaryAttack = 0
	self.LastFireModeChange = 0

	if( type(self.Armament) == "table" ) then
		
		// Armamanet
		local i = 0
		local c = 0
		self.FireMode = 1
		self.EquipmentNames = {}
		self.RocketVisuals = {}
		
		for k,v in pairs( self.Armament ) do
			
			i = i + 1
			self.RocketVisuals[i] = ents.Create("prop_physics_override")
			self.RocketVisuals[i]:SetModel( v.Mdl )
			self.RocketVisuals[i]:SetPos( self:GetPos() + self:GetForward() * v.Pos.x + self:GetRight() * v.Pos.y + self:GetUp() * v.Pos.z )
			self.RocketVisuals[i]:SetAngles( self:GetAngles() + v.Ang )
			self.RocketVisuals[i]:SetParent( self )
			self.RocketVisuals[i]:SetSolid( SOLID_NONE )
			self.RocketVisuals[i].Type = v.Type
			self.RocketVisuals[i].PrintName = v.PrintName
			self.RocketVisuals[i].Cooldown = v.Cooldown
			self.RocketVisuals[i].isFirst = v.isFirst
			self.RocketVisuals[i].Identity = i
			self.RocketVisuals[i].Owner = self
			self.RocketVisuals[i].Class = v.Class
			self.RocketVisuals[i]:Spawn()
			self.RocketVisuals[i].LastAttack = CurTime()
			
			if ( v.Damage && v.Radius ) then
				
				self.RocketVisuals[i].Damage = v.Damage
				self.RocketVisuals[i].Radius = v.Radius
			
			end
			
			if( v.SubType ) then
				
				self.RocketVisuals[i].SubType = v.SubType
				
			end
			
			// Usuable Equipment
			if ( v.isFirst == true || v.isFirst == nil /* Single Missile*/ ) then
			
				if ( v.Type != "Effect" && v.Type != "Flarepod" ) then
					
					c = c + 1
					self.EquipmentNames[c] = {}
					self.EquipmentNames[c].Identity = i
					self.EquipmentNames[c].Name = v.PrintName
					
				end
				
			end
			
		end
		
		self.NumRockets = #self.EquipmentNames
		
	end
	
	self:SetUseType( SIMPLE_USE )
	self.IsBoating = false
	self.Pilot = NULL
	
	
	if( self.CannonType == 1 ) then

		self.Cannons = {}
		for i=1,#self.CannonPos do
			
			local pos = self.CannonPos[i]
			if( self.WorldScale ) then	
				pos = pos * self.WorldScale
				
			end 
			self.Cannons[i] = ents.Create( self.CannonTypes[i] )
			self.Cannons[i]:SetPos( self:LocalToWorld( pos ) )
			self.Cannons[i]:SetAngles( self:GetAngles() + self.CannonAngles[i] )
			self.Cannons[i]:SetParent( self )
			self.Cannons[i]:Spawn()
			self.Cannons[i].Owner = self 
			self.Cannons[i].Ship = self
			if( self.Cannons[i].Tower ) then 
			
				self.Cannons[i].Tower:SetSolid( SOLID_NONE )
				self.Cannons[i].Barrel:SetSolid( SOLID_NONE )
			
			end 
			
			
			-- local weld = constraint.Weld( self.Cannons[i], self, 0, 0, 0, true )
		
		end
	
	end
	
	if( self.HasAdvancedSAMSystem ) then
		
		
		
	
	end
	
	// Misc
	self:SetModel( self.Model )	
	self:PhysicsInit( SOLID_VPHYSICS )
	self:SetMoveType( MOVETYPE_VPHYSICS )
	self:SetSolid( SOLID_VPHYSICS )

	self.PhysObj = self:GetPhysicsObject()

	
	if ( IsValid( self.PhysObj ) ) then
	
		self.PhysObj:Wake()
		self.PhysObj:EnableDrag( true )
		self.PhysObj:SetBuoyancyRatio( self.BuoyancyRatio )
		if( self.Mass ) then 
			
			self.PhysObj:SetMass( self.Mass )
			
		end 
		
		if( self.DampFactor ) then
		
			self.PhysObj:SetDamping( self.DampFactor, self.DampFactor ) -- assume linear because lazy
		
		else
		
			self.PhysObj:SetDamping( 0.25, 0.5 ) -- magic
			
		end
		
	end

	self:StartMotionController()
	 
	self.KeepUp = ents.Create("prop_physics")
	if( self.IsMicroCruiser ) then 
	
		self.KeepUp:SetModel("models/Combine_Helicopter/helicopter_bomb01.mdl")
	
	else
		
		self.KeepUp:SetModel( "models/props_wasteland/cargo_container01.mdl" )
	
	end 
	
	self.KeepUp:SetPos( self:LocalToWorld(  Vector( -10, 0, 0 ) ) )
    self.KeepUp:SetAngles( self:GetAngles() + Angle( 0, 90, 0 ) )
	self.KeepUp:Spawn()
	self.KeepUp.Owner = self 
	self.KeepUp:Activate()
	self.KeepUp:SetColor( Color( 255, 255, 255, 0) )
	self.KeepUp:SetNoDraw( true )
	self.KeepUp:SetRenderMode( RENDERMODE_TRANSALPHA )
    -- self.KeepUp:SetOwner( self )
	
	self.KeepUpPhysObj = self.KeepUp:GetPhysicsObject()
	self:DeleteOnRemove( self.KeepUp )
	if ( self.KeepUpPhysObj:IsValid() ) then
		
		self.KeepUpPhysObj:SetMass( self.KeepUpWeight or 1000 )
		self.KeepUpPhysObj:EnableDrag( true )
		
	end
		
	local weld = constraint.Weld( self.KeepUp, self, 0, 0, 0, true )
	local keepup = constraint.Keepupright( self.KeepUp, Angle( 0,0,0 ), 0, 100 )

	if ( self.RadarPositions ) then
		-- print( "walla" )
		self.Radars = {}
		self.RadarAxis = {}
		self.RadarsPhysObj = {}
		
		for i=1,#self.RadarPositions do
			
			self.Radars[i] = ents.Create("prop_physics")
			self.Radars[i]:SetPos( self:LocalToWorld( self.RadarPositions[i] ) )
			self.Radars[i]:SetAngles( self.RadarAngles[i] )
			self.Radars[i]:SetModel( self.RadarModels[i] )
			self.Radars[i]:Spawn()
			
			self.RadarsPhysObj[i] = self.Radars[i]:GetPhysicsObject()		
			if ( self.RadarsPhysObj[i]:IsValid() ) then			
				self.RadarsPhysObj[i]:SetMass( 55 )
				self.RadarsPhysObj[i]:EnableDrag( true )				
				self.RadarsPhysObj[i]:Wake()		
			end
			
			self.RadarAxis[i] = constraint.Axis( self.Radars[i], self, 0, 0, Vector(0,0,1),self.RadarPositions[i], 0, 0, 1, 0 )
			-- print( self.RadarAxis[i] )
		end
		
	
	end
		 
	 if( self.WeaponSystems ) then

		-- Base = "models/magnet/submine/submine.mdl",
		-- BPos =Vector( 1121, -0, 569 ),
		-- Turret = "models/Battleships/Yamato/yamato_mainturret.mdl",
		-- TPos = Vector( 1121, -0, 569 ),
		-- Barrel = "models/Battleships/Yamato/yamato_mainturret_cannon.mdl",
		-- BaPos = Vector( 1221, -0, 580 ),
		-- AmmoType = "",
		-- Cooldown = 15,
		-- Damage = 5000,
		-- MaxYaw = 90
		self.Weaponry = {}
		
		-- PrintTable( self.WeaponSystems )
		for k,v in pairs( self.WeaponSystems ) do 
			-- print( k, v, self.Weaponry )
			
			self.Weaponry[k] = {}
			self.Weaponry[k].LastAttack = 0
			self.Weaponry[k].AmmoCounter = v.AmmoCounter or 500
			self.Weaponry[k].Cooldown = v.Cooldown or 0.3
			self.Weaponry[k].Damage = v.Damage
			self.Weaponry[k].Radius = v.Radius or 128
			self.Weaponry[k].AmmoType = v.AmmoType
			self.Weaponry[k].AmmoModel = v.AmmoModel -- display model for ammo 
			self.Weaponry[k].BarrelLength = v.BarrelLength -- shell offset from barrel
			self.Weaponry[k].MaxYaw = v.MaxYaw -- 2*maxyaw = field of view for the cannon
			self.Weaponry[k].ShootSound = v.ShootSound -- guess
			self.Weaponry[k].NumShots = v.NumShots -- Burst Size
			self.Weaponry[k].BarrelPorts = v.BarrelPorts -- Table of vectors to emit shells from 
			self.Weaponry[k].Muzzle = v.Muzzle -- muzzleflash
			self.Weaponry[k].WeaponGroup = v.WeaponGroup -- used for hud and weapon switching
			self.Weaponry[k].GroupedShotDelay = v.GroupedShotDelay or 20
			self.Weaponry[k].DontAnimateBarrel = v.DontAnimateBarrel
			self.Weaponry[k].DontPitchBarrel = v.DontPitchBarrel
			self.Weaponry[k].ShellVelocity = v.ShellVelocity
			self.Weaponry[k].NoShellBoost = v.NoShellBoost
			self.Weaponry[k].Recoil = v.Recoil
			self.Weaponry[k].TAng = v.TAng -- Tower offset angle 
			self.Weaponry[k].UseHitScan = v.UseHitScan
			self.Weaponry[k].PenetrationDepth = v.PenetrationDepth -- Tower offset angle 
			self.Weaponry[k].Name = v.Name or "Weapon "
			self.Weaponry[k].DisableIPP = v.DisableIPP -- Disable impact point prediction ( use for flak etc, stuff that shoots straight )
			self.Weaponry[k].TowerTurnSpeed = v.TowerTurnSpeed or 1.35
			local BaseAng = v.TAng != nil and v.TAng or Angle( 0,0,0 ) 
			self.Weaponry[k].Base = ents.Create("prop_physics")
			self.Weaponry[k].Base:SetModel( v.Base )
			self.Weaponry[k].Base:SetPos( self:LocalToWorld( v.BPos ) )
			self.Weaponry[k].Base:SetAngles( self:GetAngles() + BaseAng )
			self.Weaponry[k].Base:SetMoveType( MOVETYPE_NONE )
			self.Weaponry[k].Base:SetParent( self )
			self.Weaponry[k].Base:Spawn()
			self.Weaponry[k].Base:PhysicsDestroy()
			self.Weaponry[k].Base:SetNoDraw( true )
			self.Weaponry[k].InitialHealth = self.InitialHealth*.15 
			self.Weaponry[k].HealthVal = self.InitialHealth*.15
			
			-- self.Weaponry[k].Base:GetPhysicsObject():SetMass( 50 )
			
			self.Weaponry[k].Turret = ents.Create("prop_physics")
			self.Weaponry[k].Turret:SetModel( v.Turret )
			self.Weaponry[k].Turret:SetPos( self:LocalToWorld( v.TPos ) )
			if( v.TAng ) then 
				
				local ang = self:GetAngles()
				ang:RotateAroundAxis( self:GetRight(), v.TAng.p )
				ang:RotateAroundAxis( self:GetUp(), v.TAng.y )
				ang:RotateAroundAxis( self:GetForward(), v.TAng.r )
			
				self.Weaponry[k].Turret:SetAngles( ang )
			
			else
			
				self.Weaponry[k].Turret:SetAngles( self:GetAngles() )
			
			end 
			self.Weaponry[k].Turret:SetMoveType( MOVETYPE_NONE )
			self.Weaponry[k].Turret:SetParent( self.Weaponry[k].Base )
			local tur = self.Weaponry[k].Turret
			timer.Simple( 0, function() 
				if ( IsValid( tur ) ) then 
					
					tur:SetNWInt("WeaponTableIndex", k ) -- so we can read the data on the client.
					
				end 
				
			end )
			
			self.Weaponry[k].Turret:Spawn()
			self.Weaponry[k].Turret:PhysicsDestroy()
			
			-- self.Weaponry[k].Turret:GetPhysicsObject():SetMass( 50 )
			-- local _barrelang = 
			self.Weaponry[k].Barrel = ents.Create("prop_physics")
			self.Weaponry[k].Barrel:SetModel( v.Barrel )
			self.Weaponry[k].Barrel:SetPos( self:LocalToWorld( v.BaPos ) )
			self.Weaponry[k].Barrel:SetAngles( self.Weaponry[k].Turret:GetAngles() )
			self.Weaponry[k].Barrel:SetMoveType( MOVETYPE_NONE )
			self.Weaponry[k].Barrel:SetParent( self.Weaponry[k].Turret )
			self.Weaponry[k].Barrel:Spawn()
			self.Weaponry[k].Barrel:PhysicsDestroy()
			-- self.Weaponry[k].Barrel:GetPhysicsObject():SetMass( 50 )
			
			
		end 
		
	end 
	 
	 if( self.CaptainsChairPosition ) then
		 
		self.CaptainsSeat = ents.Create( "prop_vehicle_prisoner_pod" )
		self.CaptainsSeat:SetPos( self:LocalToWorld( pos ) )
		self.CaptainsSeat:SetModel( "models/nova/jeep_seat.mdl" )
		self.CaptainsSeat:SetKeyValue( "LimitView", "0" )
		self.CaptainsSeat:SetKeyValue( "vehiclescript", "scripts/vehicles/prisoner_pod.txt" )
		self.CaptainsSeat.HandleAnimation = function( v, p ) return p:SelectWeightedSequence( ACT_DRIVE_AIRBOAT ) end
		self.CaptainsSeat:SetAngles( self:GetAngles() + ang )
		self.CaptainsSeat:SetParent( self )
		self.CaptainsSeat:SetColor( Color( 0,0,0,0 ) )
		self.CaptainsSeat:SetRenderMode( RENDERMODE_TRANSALPHA )
		self.CaptainsSeat:Spawn()

		
	end 
		
	if( self.DeckModel ) then 

		self.Deck = ents.Create("boat_part")
		
		self.Deck:SetPos( self:LocalToWorld( self.DeckPosition or Vector() ) )
		self.Deck:SetAngles( self:GetAngles() )
		self.Deck:SetColor( Color( 255,255,255,255 ) ) 
		self.Deck:Spawn()
		self.Deck:SetModel( self.DeckModel )
		self.Deck:SetMoveType( MOVETYPE_VPHYSICS )
		self.Deck:PhysicsInit( MOVETYPE_VPHYSICS )
		self.Deck:SetSolid( SOLID_VPHYSICS )	
		self.Deck:Activate()
		
		self.Deck.InitialHealth = self.InitialHealth
		self.Deck.HealthVal = self.InitialHealth
		self.Deck.IsShipDeck = true 
		self:DeleteOnRemove( self.Deck )
		-- print( self.Deck.InitialHealth )
		self.Deck.Weld = constraint.Weld( self.Deck, self, 0, 0, 0, true, false  )
		
		self.HasDeck = true 
		-- self.Deck:PhysicsDestroy()
		-- self.Deck:GetPhysicsObject():SetMass( 50 )
		 
	end 
					-- for i=0,self:GetBoneCount() do 
					-- local rpos,rang = self:GetBonePosition( i )
					-- print( rpos, rang  )
					
				-- end 
	timer.Simple( .0, function() 
		if( IsValid( self ) ) then 
		
			self:SetNWInt( "health",self.HealthVal)
			self:SetNWInt( "MaxHealth",self.InitialHealth)
			self:SetNWInt( "MaxSpeed",self.MaxVelocity)
			

	
			if( self:GetBoneCount() > 1 ) then 
				
				-- for i=1,self:GetBoneCount() do 
				
					-- print( self:GetBonePosition( i ) )
				
				-- end 
				local Citadel = self:LookupBone("Citadel")
				local Rudder = self:LookupBone("Rudder")
				if( Citadel ) then 
					
					local p,a = self:GetBonePosition( Citadel )
					self.CitadelPos = self:WorldToLocal( p ) 
					self.CitadelHealth = self.InitialHealth * .15 
			
				end 
				
				if( Rudder ) then 
				
					local rpos,a2 = self:GetBonePosition( Rudder )				
					self.RudderPos = self:WorldToLocal( rpos )
					self.RudderHealth = self.InitialHealth * .1 
					
				end 
				
				self.AmmoRacks = {}
				for i=1,self:GetBoneCount() do 
					
					local bone = self:GetBoneName( i ) 
					if( string.find( bone,"Ammo") != nil ) then 
						local bp,ba = self:GetBonePosition( i ) 
						table.insert( self.AmmoRacks, 
							{ 
								Health = self.InitialHealth*.05, 
								Pos = self:WorldToLocal( bp ),
								Destroyed = false 
							}  )
					
					end 
					
				end 
				-- print(rudder,"kebab?")
			/*
				
				-- print(  self.RudderPos )
				self.RudderAng = rang 
				self.Rudder = ents.Create("boat_part")
				-- self.Rudder:SetPos( rpos )
				self.Rudder:SetAngles( self:GetAngles()  )
				self.Rudder:SetModel( "models/Gibs/HGIBS.mdl" )
				self.Rudder:SetOwner( self )
				self.Rudder.Owner = self 
				-- self.Rudder:SetMoveType( MOVETYPE_VPHYSICS )
				-- self.Rudder:PhysicsInit( MOVETYPE_VPHYSICS )
				-- self.Rudder:SetSolid( SOLID_VPHYSICS )	
				self.Rudder:Spawn()
				self.Rudder:Activate()
				self.Rudder.HealthVal = self.InitialHealth * .1 
				self.Rudder.InitialHealth = self.InitialHealth * .1 
				-- self.RudderWeld = constraint.Weld( self, self.Rudder, 0, 0, 0, true, false )
				self:DeleteOnRemove( self.Rudder )
				-- print( rpos, rang )
			 */
			end 
			
		end 
		
	end )

end

function Meta:NeurNaval_MissileJammer()
	
	local tr,trace = {},{}
	local Missile = NULL
	-- look for stuff
	for k,v in pairs( ents.FindInSphere( self:GetPos(), 5555 ) ) do
		
		-- print( v, v:GetVelocity():Length() )
		-- look for fast stuff that's not also not what we want it to be :v
		if ( v:GetVelocity():Length() > 5000 && !v:IsPlayer() && !v:IsNPC() && !v:IsVehicle() && v.HealthVal == nil ) then
			
			if( v:GetPos().z > self:GetPos().z ) then
			
				-- look for stuff again
				tr.start = v:GetPos()
				tr.endpos = tr.start + v:GetForward() * 5555
				tr.filter = v
				tr.mask = MASK_SOLID
				trace = util.TraceLine( tr ) 
				
					
				-- oh fuck is it coming at us?
				if( trace.Hit && IsValid( trace.Entity ) ) then
					
					debugoverlay.Line( tr.start, trace.HitPos, 1, Color( 255,0,0,255 ), true  )
					debugoverlay.Line( self:GetPos(), v:GetPos(), 1, Color( 0,255,0,255 ), true  )
					
					if( trace.Entity == self || ( IsValid( trace.Entity.Owner ) && trace.Entity.Owner == self ) ) then
						
						if( !v.JamDir || !v.JamDir2 ) then
							
							local r = ( math.random( 0,1) > 0 )
							local r2 = ( math.random( 0,1) > 0 )
							v.JamDir = -1
							v.JamDir2 = -1
							if( r ) then v.JamDir = 1 end
							if( r2 ) then v.JamDir2 = 1 end
							
						end
						
						-- Alter its course slightly
						v:SetAngles( v:GetAngles() +  Angle( 6.5*v.JamDir, 7.5*v.JamDir2, 0 ) )
					
					end
				
				end
			
			end
			
		end
	
	end

end

function Meta:BoatSAMPhysics()

	if ( self.IsBoating && IsValid( self.Pilot ) ) then

		-- print( "boating" )
		
		self:GetPhysicsObject():Wake()
		
		local plr = self.Pilot
		local hasSAMPilot = false
		
		if( IsValid( self.SAMSeat ) ) then
		
			if( IsValid( self.SAMSeat:GetDriver() ) ) then
				
				plr = self.SAMSeat:GetDriver()
				hasSAMPilot = true
				
			end
			
		end
		
		local a = plr:GetPos() + plr:GetAimVector() * 3000 // This is the point the plane is chasing.
		
		if( self.Aimbot && IsValid( self.AimTarget ) ) then
			
			a = self.AimTarget:GetPos()
			
		end
		
		local ta = ( self:GetPos() - a ):Angle()
		local ma = self:GetAngles()
		
		
		local pilotAng = plr:EyeAngles()
		
		if( self.Aimbot && IsValid( self.AimTarget ) ) then
			
			pilotAng = ( self:GetPos() - self.AimTarget:GetPos() ):Angle()
			
		end
		
		local _t = self.Tower:GetAngles()
		local barrelpitch = math.Clamp( pilotAng.p, -65, 10 )

		self.offs = self:VecAngD( ma.y, ta.y )	
		local angg = self:GetAngles()

		angg:RotateAroundAxis( self:GetUp(), -self.offs + 180 )
		
		if( hasSAMPilot ) then
			
			local diff = self:VecAngD( plr:EyeAngles().y, self:GetAngles().y )
			
			if( diff > 10 || diff < -10 ) then
			
				
				self.Tower:SetAngles( LerpAngle( 0.02, _t, angg ) )
			
			end
			
		else
		
		
			self.Tower:SetAngles( LerpAngle( 0.1, _t, angg ) )
		
		end
		
		_t = self.Tower:GetAngles()
		self.Barrel:SetAngles( Angle( barrelpitch, _t.y, _t.r ) )

	end
	
end

function Meta:BoatSAMLogic()
	
	local SD = self.SAMSeat:GetDriver()
	local plr = self.Pilot
	
	if( IsValid( SD ) ) then
		
		plr = SD
	
	end
	
	
	if( plr:KeyDown( IN_ATTACK ) ) then
		
		local tr,trace = {},{}
		tr.start = self.Barrel:GetPos() + self.Barrel:GetForward() * 140
		tr.endpos = tr.start + self.Barrel:GetForward() * 7000
		tr.filter = { self, self.Barrel, self.Tower, plr }
		tr.mask = MASK_SOLID
		
		trace = util.TraceEntity( tr, self.Barrel )
		
		-- local t1 = Vector( 10, 24, 34 )
		-- local t2 = Vector( 10, 24, 34 )
		
		-- self:DrawLaserTracer( self.Barrel:LocalToWorld( t1 ), trace.HitPos )
		-- self:DrawLaserTracer( self.Barrel:LocalToWorld( t2 ), trace.HitPos )
		
		if( !trace.HitWorld && trace.Hit && IsValid( trace.Entity ) && self.LastAttack + 0.75 <= CurTime() ) then
			
			-- self.Aimbot = true
			-- self.AimTarget = trace.Entity

			self.LastAttack = CurTime()
			self.Missile = ents.Create("sent_a3a_rocket")
			self.Missile:SetPos( self.Barrel:GetPos() + self.Barrel:GetForward() * 150 )
			self.Missile:SetAngles( self.Barrel:GetAngles() )
			self.Missile.Target = trace.Entity
			self.Missile:SetModel( "models/BF2/weapons/Predator/predator_rocket.mdl" ) 
			self.Missile.Owner = plr
			self.Missile.Damage = math.random( 400, 800 )
			self.Missile:SetOwner( self.Barrel )
			self.Missile:Spawn()
			self.Missile.Delay = 0
			
			local fx = EffectData()
			fx:SetOrigin( self.Missile:GetPos() )
			fx:SetScale( 3.0 )
			util.Effect( "launch2", fx )
			
			local fx = EffectData()
			fx:SetOrigin( self.Missile:GetPos() )
			fx:SetNormal( self.Missile:GetForward() * -1 )
			fx:SetScale( 0.5 )
			util.Effect( "tank_muzzle", fx )
			
			plr:PrintMessage( HUD_PRINTCENTER, "Taret Locked - Launching Missile")
			
			return
			
		end
		
	else
	
		-- self.Aimbot = false
		-- self.AimTarget = NULL

	end
	
end

function Meta:BoatRadarAnim()

	local plr = self.Pilot
	if( IsValid( self.SAMSeat ) ) then
		if( IsValid( self.SAMSeat:GetDriver() ) ) then			
			plr = self.SAMSeat:GetDriver()			
		end
	end
	local ma = self:GetAngles()				
	local pilotAng = plr:EyeAngles()		
	local a = plr:GetPos() + plr:GetAimVector() * 3000		
	local ta = ( self:GetPos() - a ):Angle()

/*
self.RadarAnimation=
0: static
1: simply rotate on z axis all the time.
2: follow player aim.
3: track the current target.
*/
	if (self.Radars) then
		for i=1,#self.Radars do	
			if( IsValid( self.Radars[i] ) ) then
			local _t = self.Radars[i]:GetAngles()
				if self.RadarAnimation[i]==0 then
					-- self.Radars[i]:SetAngles( self:GetAngles())
				elseif self.RadarAnimation[i]==1 then
					-- self:RadarsPhysObj[i]:AddAngleVelocity( Vector(1000,1000,100) )
					
				elseif self.RadarAnimation[i]==2 then
					
					-- self.Radars[i]:SetAngles( LerpAngle( 0.1, _t, Angle(ma.p,plr.y,ma.r) ) )
				
				elseif self.RadarAnimation[i]==3 then


					if( self.Aimbot && IsValid( self.AimTarget ) ) then			
						a = self.AimTarget:GetPos()			
					end		
					if( self.Aimbot && IsValid( self.AimTarget ) ) then			
						pilotAng = ( self:GetPos() - self.AimTarget:GetPos() ):Angle()			
					end		
					self.offs = self:VecAngD( ma.y, ta.y )	
					local angg = self:GetAngles()
					angg:RotateAroundAxis( self:GetUp(), -self.offs + 180 )
				
					self.Radars[i]:SetAngles( LerpAngle( 0.1, _t, angg ) )

				
				end
			
			end
		end	
	end
end

print( "[NeuroNaval] NeuroNavalGlobal.lua loaded!" )