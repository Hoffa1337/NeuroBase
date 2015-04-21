sound.Add( {
	name = "Global.ChoppaGun",
	sound = {
		"AH64fire.wav",
	},
	channel = CHAN_WEAPON,
	soundlevel = 220,
	pitchstart = 90,
	pitchend = 105,
} )

CreateConVar("neuro_parachute",1,false,false)
-- hook.Add("CreateMove", "NeuroTec_ChuteMove", function( cmd )
	
	

-- end )


local function Falling( ply )
	
	local tr,trace={},{}
	tr.start = ply:GetPos()
	tr.endpos = tr.start + Vector( 0,0,-10 )
	tr.filter = ply
	tr.mask = MASK_SOLID
	trace = util.TraceLine( tr )
	
	-- print( trace.Hit )
	return trace.Hit


end
hook.Add("Think","NeuroTec_parachutethink",function()
	

	for k,v in ipairs( player.GetAll() ) do 
		
		if( v:Alive() ) then
			
			if( !Falling( v ) ) then
				
				if( !v.FreeFallTimer ) then
					
					v.FreeFallTimer = 0
					
				end
				
				v.FreeFallTimer = v.FreeFallTimer + 1
			-- print( v.FreeFallTimer ) 
			else
				
				v.FreeFallTimer = 0
				
			end
			
			
			if( IsValid( v.ChuteObj ) ) then
				
				local tr,trace = {},{}
				tr.start = v.ChuteObj:GetPos()
				tr.endpos = tr.start + Vector( 0,0,-155 )
				tr.filter = { v, v.ChuteObj }
				tr.mask = MASK_SOLID
				trace = util.TraceLine( tr )
				
			
				-- v:GetPhysicsObject():ApplyForceCenter( Vector(0,0,5000 ) )
				local pos = v.ChuteObj:GetPos()
				
				if( !v.ChuteObj.Destroyed && ( trace.Hit || v:WaterLevel() > 0 || IsValid( v:GetVehicle() ) || IsValid( v:GetScriptedVehicle() ) ) ) then
					
					v.ChuteObj.Destroyed = true
					v.ChuteObj:SetParent()
					
					v.ChuteObj:SetSolid( SOLID_VPHYSICS )
					v.ChuteObj:GetPhysicsObject():EnableGravity( false )
					v.ChuteObj:SetGravity( -1 )
					v.HasChute = false
					v.ChuteObj:SetNetworkedBool("drop",true)
					v:SetGravity( 1 )
					timer.Simple(0, function()if(IsValid(v))then v:SetGravity( 1 ) end end )
					v.ChuteObj:GetPhysicsObject():ApplyForceCenter( Vector( 0,0,101500 ) + VectorRand() * 500 )
					v.ChuteObj:SetPos( pos )
					v.ChuteObj:Fire("kill","",5)
					v.ChuteObj:EmitSound( "doors/door_chainlink_close1.wav", 511, 155 ) -- lol
					-- v.ChuteObj = NULL
					
				else
					
					if( v.ChuteObj.Destroyed ) then
						
						v:SetGravity( 0 )
						
					else
						
						-- v.ChuteObj:SetAngles( v:GetAngles() )
						v:GetPhysicsObject():ApplyForceCenter( VectorRand() * 500 )
						v:SetGravity( 0.122 )
						-- v:SetVelocity( v:GetVelocity() + v:GetForward() * 32 )
						-- v:GetPhysicsObject():ApplyForceCenter( v:GetUp() * 2500 )
						if( v:GetVelocity():Length() > 300 ) then
							
							v:SetVelocity( v:GetVelocity() * -0.01 )
						
						else
							
							-- v.ChuteObj:SetVelocity(  v:GetVelocity() + v:GetForward() * 32 )
							-- v:SetVelocity( v:GetVelocity() + v:GetForward() * 32 )
						
						end
						
					end
					
					
				end
				
			
			else
				
				-- print( IsValid( v:GetVehicle() ), IsValid( v:GetScriptedVehicle() ), v:OnGround() )
				if( v:WaterLevel() == 0 && v:GetVelocity():Length() > 200 && !IsValid( v:GetVehicle() ) && !IsValid( v:GetScriptedVehicle() ) && v:GetVelocity().z <= 0 && v.FreeFallTimer > 100 && v:KeyDown( IN_JUMP ) && v:GetMoveType() != MOVETYPE_NOCLIP ) then
					
					if( GetConVarNumber( "neuro_parachute" ) == 0 ) then return end
	
					v.ChuteObj = ents.Create("sent_neuro_parachute")
					-- v.ChuteObj:SetModel()
					-- v.ChuteObj:SetModelScale( 0.01, 0.001 )
					v.ChuteObj:SetAngles( v:GetAngles() )
					v.ChuteObj:SetPos( v:LocalToWorld( Vector( 0,0,120 ) ) )
					v.ChuteObj:SetParent( v, 0 )
					v.ChuteObj:SetMoveType( MOVETYPE_NONE )
					v.ChuteObj:SetOwner( v )
					v.ChuteObj.Owner = v
					v.ChuteObj:Spawn()
					v.ChuteObj:SetNetworkedEntity("Idiot", v )
					v.HasChute = true
					v:SetVelocity( v:GetVelocity() * -0.15 + Vector( 0,0,150 ) )
					v:EmitSound( "ambient/wind/wind_hit1.wav", 511, math.random(100,110))
					v.ChuteObj:EmitSound( "ambient/wind/windgust.wav", 50, math.random(90,100))
					-- timer.Simple( 1, function() if(IsValid(v.ChuteObj))then v.ChuteObj:SetModelScale( 0.0, 2 ) end end )
					-- v:SetVelocity( v:GetVelocity() * 0.1 )
					
				end
				
			end
		
		else
		
			v.FreeFallTimer = 0
		
		end
	
	end
	
end ) 

local Meta = FindMetaTable("Entity")

function Meta:CreateRotorwash()
	
	if( !self.IsRotorwashing ) then
	
		self.Rotorwash = ents.Create("env_rotorwash_emitter")
		self.Rotorwash:SetPos( self:GetPos() )
		self.Rotorwash:SetParent( self )
		self.Rotorwash:SetKeyValue( "altitude", "",1024 )
		self.Rotorwash:Spawn()
		
		self.IsRotorwashing = true
	
	end

end

function Meta:RemoveRotorwash()
	
	if( IsValid( self.Rotorwash ) ) then
		
		self.Rotorwash:Remove()
		self.IsRotorwashing = false
	
	end

end

function Meta:NeuroPlanes_DefaultAttachEquipment()

	-- Armamanet
	local i = 0
	local c = 0
	self.FireMode = 1
	self.EquipmentNames = {}
	self.RocketVisuals = {}
	if( self.NoGuns ) then return end
	
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
		self.RocketVisuals[i].Class = v.Class
		self.RocketVisuals[i]:Spawn()
		self.RocketVisuals[i].LastAttack = CurTime()
		
		if ( v.Damage && v.Radius ) then
			
			self.RocketVisuals[i].Damage = v.Damage
			self.RocketVisuals[i].Radius = v.Radius
		
		end
		
		-- Usuable Equipment
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

function Meta:SetChoppergunner( plr, oldplr )
	
	self.LastChopperGunToggle = CurTime()
	self.GotChopperGunner = !self.GotchopperGunner
	
	plr:SetNetworkedBool("isGunner", self.GotChopperGunner )
	plr:SetNetworkedEntity("NeuroPlanesMountedGun", self.GotChopperGunner )
	
	if( plr != oldplr ) then
		
		oldplr:SetNetworkedBool("isGunner", false )
		oldplr:SetNetworkedEntity("NeuroPlanesMountedGun", oldplr )
	
	end

end

function Meta:NeuroPlanes_DefaultChopperCrash()
	
	for k,v in pairs( self.RocketVisuals ) do
		
		if( v && IsValid( v ) && math.random(1,2) == 1 ) then
			
			local oldpos = v:GetPos()
			
			v:SetParent(nil)
			v:SetSolid( SOLID_VPHYSICS )	
			v:Fire("kill","",25)
			
			if( self.HealthVal < self.InitialHealth * 0.5 ) then
				
				v:Ignite(25,25)
			
			end
			
			local p = v:GetPhysicsObject()
			if( p ) then
				
				p:Wake()
				p:EnableGravity( true )
				p:EnableDrag( true )
				
			end
			
			v:SetPos( oldpos )
			
		end
		
	end
	
	if( self.rotoraxis && IsValid( self.rotoraxis ) ) then
		
		self.rotoraxis:Remove()
		
	end
	
	if( self.tailrotoraxis && IsValid( self.tailrotoraxis ) ) then
		
		if( math.random( 1,4 ) == 1 ) then
			
			self.tailrotoraxis:Remove()
		
		end
	
	end
	
	self.RotorPropeller:GetPhysicsObject():EnableGravity( true )
	self.TailPropeller:GetPhysicsObject():EnableGravity( true )
	self.RotorPropeller:SetOwner(nil)
	self.TailPropeller:SetOwner(nil)
	
	-- bye bye
	self.RotorPhys:ApplyForceCenter( self:GetUp() * ( self.RotorVal * 100 ) + self:GetRight() * ( math.random( -1, 1 ) * ( self.RotorVal * 100 ) ) + self:GetForward() * ( math.random( -1, 1 ) * ( self.RotorVal * 100 ) )  )
	local ra = self.RotorPhys:GetAngles()
	self.RotorPhys:SetAngles( ra + Angle( math.random(-5,5),math.random(-5,5),math.random(-5,5) ) )
	
	self.RotorPropeller:Fire( "kill", "", 25 )
	self.TailPropeller:Fire( "kill", "", 25 )
	
	if( self.HealthVal < self.InitialHealth * 0.5 ) then
			
		self:Ignite( 25, 25 )
		
	end

	self.LoopSound:Stop()
	
	if( self.RotorVal > 200 ) then
		
		self:EmitSound("npc/combine_gunship/gunship_explode2.wav",511,125)
	
	end
	
	self:Fire( "kill", "", 25 )
	self.PhysObj:Wake()
	self.PhysObj:EnableGravity( true )
	self.PhysObj:EnableDrag( true )
	self.Destroyed = true
	
end

function Meta:NeuroPlanes_DefaultChopperTakeDmg( dmginfo )
	if ( self.Destroyed ) then
		
		return

	end
	
	-- if( IsValid( self.Pilot ) ) then
	
		-- self.Pilot:ViewPunch( Angle( math.random(-2,2),math.random(-2,2),math.random(-2,2) ) )
	
	-- end
	
	self:TakePhysicsDamage(dmginfo)
	self.HealthVal = self.HealthVal - dmginfo:GetDamage()
	self:SetNetworkedInt( "health",self.HealthVal )
	
	-- if ( dmginfo:GetDamagePosition():Distance( self.RotorPropeller:GetPos() ) < 50 && dmginfo:GetDamage() > 1500 ) then -- Direct blow to the rotor
		
		-- self:NeuroPlanes_DefaultChopperCrash()
	
	-- end
	
	if ( self.HealthVal < self.InitialHealth * 0.2 && !self.Burning ) then
	
		self.Burning = true
		local p = {}
		p[1] = self:GetPos() + self:GetForward() * -129 + self:GetRight() * -20 + self:GetUp() * 37
		p[2] = self:GetPos() + self:GetForward() * -129 + self:GetRight() * 20 + self:GetUp() * 37
		for _i=1,2 do
		
			local f = ents.Create("env_fire_trail")
			f:SetPos( p[_i] )
			f:SetParent( self )
			f:Spawn()
			
		end
		
	end
	
	if ( self.HealthVal < 0 ) then
		
		if( !self.Destroyed ) then
			
			if( math.random(1,2) == 2 ) then
			
				self:NeuroPlanes_DefaultChopperCrash()
			
			else
				
				self:DeathFX()
			
			end
			
		end
		
	end

end
function Meta:NeuroPlanes_DefaultChopperPhysImpact( data, physobj )
	
	if ( data.Speed > self.MaxVelocity * 0.45 && data.DeltaTime > 0.2 ) then 
	
		if( self.Destroyed ) then
			
			self:EmitSound("physics/metal/metal_large_debris2.wav",511,100)
			
			if( IsValid( self.ChopperGun ) ) then
			
				self.ChopperGun:EmitSound( "ambient/explosions/explode_3.wav", 511, 100 )
			
			end
			
		else
		
			self:EmitSound("physics/metal/metal_box_break1.wav", 250, 60 )
		
		end
			
		if ( self:GetVelocity():Length() < self.MaxVelocity * 0.7 ) then
			
			self.HealthVal = self.HealthVal * ( 0.3 + ( math.random(10,25) / 100 ) )
			self:SetNetworkedInt("health",self.HealthVal)
		
		else
			
			if( !self.Destroyed ) then
				
				self:NeuroPlanes_DefaultChopperCrash()
			
			end
			
		end
		
	
	end

end

function Meta:NeuroPlanes_DefaultChopperOnRemove()
	self.LoopSound:Stop()
	
	if( self.RotorPropeller && IsValid( self.RotorPropeller ) ) then
		
		self.RotorPropeller:Remove()
		
	end
	
	if( self.TailPropeller && IsValid( self.TailPropeller ) ) then
		
		self.TailPropeller:Remove()
	
	end
	
	if( self.Destroyed ) then
		
		for i=1,7 do
			
			local fx = EffectData()
			fx:SetOrigin( self:GetPos()+ Vector(math.random(-100,100),math.random(-100,100),math.random(16,72)) )
			util.Effect("super_explosion", fx)
		
		end

	end
	
	if ( IsValid( self.Pilot ) ) then
	
		self:HeloEjectPilotSpecial()
	
	end
end

function Meta:NeuroPlanes_DefaultChopperWithGunnerThink()

	if( IsValid( self.ChopperGun ) ) then
	
		self.ChopperGun:SetSkin( self:GetSkin() )
		
	end
	
	if( IsValid( self.RotorPropeller ) && IsValid( self.TailPropeller ) ) then
	
		self.RotorPropeller:SetSkin( self:GetSkin() )
		self.TailPropeller:SetSkin( self:GetSkin() )
		
	end
	
	if( IsValid( self.Turret ) ) then
	
		self.Turret:SetSkin( self:GetSkin() )
		
	end
	
	if( IsValid( self.RadarCam ) ) then
	
		self.RadarCam:SetSkin( self:GetSkin() )
		
	end
	
	self.Pitch = math.Clamp( math.floor( self:GetVelocity():Length() / 100 + 100 ),0,205 )
	self.LoopSound:ChangePitch( self.Pitch, 2 )
	

	if ( self.Destroyed && self.HealthVal < self.InitialHealth * 0.5 && self:WaterLevel() < 2 ) then 
		
		local effectdata = EffectData()
		effectdata:SetOrigin( self:GetPos() + self:GetRight() * math.random(-32,32) + self:GetForward() * math.random(-32,32)  )
		util.Effect( "immolate", effectdata )
		
		
		if( !self.DeathTimer ) then self.DeathTimer = 1 end
		
		self.DeathTimer = self.DeathTimer + 1
		if( self.DeathTimer > 30 ) then
			
			self:DeathFX()
			
			return
			
		end
		
		return
		
		
	end
	
	if ( self.IsFlying && IsValid( self.Pilot ) ) then
		
		self.Pilot:SetPos( self:GetPos() + self:GetUp() * 72 )
		
		-- HUD Stuff
		self:UpdateRadar()
		
		-- Lock On method
		if( !self.NoGuns ) then
		
			self:Jet_LockOnMethod()
		
		end
		
		-- Clear Target 
		if ( self.Pilot:KeyDown( IN_SPEED ) && IsValid( self.Target ) ) then
			
			self:ClearTarget()
			self.Pilot:PrintMessage( HUD_PRINTCENTER, "Target Released" )
			
		end
		
		local d = NULL
		if( IsValid( self.PassengerSeat ) ) then
			
			 d = self.PassengerSeat:GetDriver()
			 
		end
		
		
		
		-- Attack
		if ( !self.NoGuns && ( self.Pilot:KeyDown( IN_ATTACK ) && !IsValid( d ) ) || ( IsValid( d ) && d:KeyDown( IN_ATTACK ) ) ) then
			
			
			if ( self.ChopperGunAttack + 0.12 <= CurTime() ) then
				
				self:FuselageAttack()
			
			end
			
		end

		if ( self.LastSecondaryKeyDown + 0.5 <= CurTime() && self.Pilot:KeyDown( IN_ATTACK2 ) && !self.Pilot:GetNetworkedBool( "isGunner", false ) ) then
		
			local id = self.EquipmentNames[ self.FireMode ].Identity
			local wep = self.RocketVisuals[ id ]
			self.LastSecondaryKeyDown = CurTime()
		
			if( !IsValid( wep ) ) then
				
				self.Pilot:PrintMessage( HUD_PRINTCENTER, "NO AMMO" )
					
				return 
				
			end
			
			if ( wep.LastAttack + wep.Cooldown <= CurTime() ) then
			
				self:SecondaryAttack( wep, id )
				
			else
			
	
				local cd = math.ceil( ( wep.LastAttack + wep.Cooldown ) - CurTime() ) 
				
				if ( cd == 1 ) then 
				
					self.Pilot:PrintMessage( HUD_PRINTTALK, self.PrintName..": "..wep.PrintName.." ready in "..tostring( cd ).. " second." )
				
				else
				
					self.Pilot:PrintMessage( HUD_PRINTTALK, self.PrintName..": "..wep.PrintName.." ready in "..tostring( cd ).. " seconds." )	
				
				end
				
			end
	
		end

		local eyeAng
		local myAng = self:GetAngles()

		if( IsValid( d ) && d:IsPlayer() ) then 
			
			eyeAng = d:EyeAngles()
			
			if ( d:KeyDown( IN_ZOOM ) && self.LastChopperGunToggle + 1.0 <= CurTime() && !IsValid( self.LaserGuided ) ) then
								
		
				self.LastChopperGunToggle = CurTime()
				self.GotChopperGunner = !self.GotChopperGunner
				d:SetNetworkedBool( "isGunner", self.GotChopperGunner )
				d:SetNetworkedEntity( "ChopperGunEnt", self.ChopperGun )
				d:SetNetworkedEntity( "NeuroPlanes_Helicopter", self )
				print( "Values: ", self.GotChopperGunner, self.Pilot:GetNetworkedBool("isGunner", false), self.Pilot:GetNetworkedEntity("ChopperGunnerEnt", NULL ) )
				
			end
		
		else
			
			eyeAng = self.Pilot:EyeAngles()
			
			if ( self.Pilot:KeyDown( IN_ZOOM ) && self.LastChopperGunToggle + 1.0 <= CurTime() && !IsValid( self.LaserGuided ) ) then
				
				self.LastChopperGunToggle = CurTime()
				self.GotChopperGunner = !self.GotChopperGunner
				self.Pilot:SetNetworkedBool( "isGunner", self.GotChopperGunner )
				self.Pilot:SetNetworkedEntity( "ChopperGunEnt", self.ChopperGun )
				
				print( "Values: ", self.GotChopperGunner, self.Pilot:GetNetworkedBool("isGunner", false), self.Pilot:GetNetworkedEntity("ChopperGunnerEnt", NULL) )

			end
		
		end
		
		eyeAng.r = myAng.r

		if ( eyeAng.y > myAng.y + 85 ) then
		
			eyeAng.y = myAng.y + 85
			
		elseif( eyeAng.y < myAng.y -85 ) then
		
			eyeAng.y = myAng.y -85
			
		end
		
		if ( eyeAng.p > myAng.p + 70 ) then
		
			eyeAng.p = myAng.p + 70
			
		elseif( eyeAng.p < myAng.p -4 ) then
		
			eyeAng.p = myAng.p -4
			
		end
		
		if( IsValid( self.ChopperGun ) ) then
		
			if( self.LinearMachineGun ) then
				
				eyeAng.y = myAng.y
				eyeAng.r = myAng.r
				
			end
			
			self.ChopperGun:SetAngles( LerpAngle( 0.223, self.ChopperGun:GetAngles(), eyeAng ) )
		
		end
		
		if( IsValid( self.RadarCam ) ) then
		
			self.RadarCam:SetAngles( Angle( myAng.p, eyeAng.y, myAng.r ) )
			
		end
		if( IsValid( self.Turret ) ) then
		
			self.Turret:SetAngles( Angle( myAng.p, eyeAng.y, myAng.r ) )
		
		end
		
		
		-- Firemode 
		if ( self.Pilot:KeyDown( IN_RELOAD ) && self.LastFireModeChange + 0.5 <= CurTime() ) then

			self:CycleThroughWeaponsList()
			
		end
		
		-- Flares
		if ( self.Pilot:KeyDown( IN_SCORE ) && self.Speed > 10 && !self.isHovering && self.FlareCount > 0 && self.LastFlare + self.FlareCooldown <= CurTime() && self.LastFireModeChange + 0.75 <= CurTime() ) then
			
			self.LastFireModeChange = CurTime()
			self.FlareCount = self.FlareCount - 1
			self:SetNetworkedInt( "FlareCount", self.FlareCount )
			self:SpawnFlare()
			
			if ( self.FlareCount == 0 ) then
			
				self.LastFlare = CurTime() 
				self.FlareCount = self.MaxFlares
				
			end
			
		end
	
		if ( self.Pilot:KeyDown( IN_USE ) && self.Entered + 1.0 <= CurTime() ) then

			self:HeloEjectPilotSpecial()
			
		end	
		
		-- Ejection Situations.
		if ( self:WaterLevel() > 2 ) then
		
			self:HeloEjectPilotSpecial()
			
		end

	end

	self:NextThink( CurTime() )
	
end

function Meta:FuselageAttack()

	if ( !IsValid( self.Pilot ) ) then
		
		return
		
	end
	
	local bullet = {} 
 	bullet.Num 		= 1
 	bullet.Src 		= self.ChopperGun:GetPos() + self.ChopperGun:GetForward() * 305
 	bullet.Dir 		= self.ChopperGun:GetAngles():Forward()						-- Dir of bullet 
 	bullet.Spread 	= Vector( .021, .021, .019 )								-- Aim Cone 
 	bullet.Tracer	= 1															-- Show a tracer on every x bullets  
 	bullet.Force	= 50					 									-- Amount of force to give to phys objects 
 	bullet.Damage	= math.random( 25, 75 )
 	bullet.AmmoType = "Ar2" 
 	bullet.TracerName 	= "AirboatGunHeavyTracer" 
 	bullet.Callback    = function ( a, b, c )
								
							self:ChopperGunCallback( a, b, c )
							
						end 
 	/*
 	local e = EffectData()
	e:SetStart( self.ChopperGunProp:GetPos()+self.ChopperGunProp:GetForward() * 72 )
	e:SetOrigin( self.ChopperGunProp:GetPos()+self.ChopperGunProp:GetForward() * 72 )
	e:SetEntity( self.ChopperGunProp )
	e:SetAttachment( 1 )
	util.Effect( "ChopperMuzzleFlash", e )
	*/

	if self.ChopperGunProp and self.ChopperGunProp:IsValid() and !self.ChopperGunProp:GetNoDraw() then
		ParticleEffect( "apc_muzzleflash", self.ChopperGunProp:GetPos()+self.ChopperGunProp:GetForward() * 72, self.ChopperGunProp:GetAngles(), self.ChopperGunProp )
	else
		ParticleEffect( "apc_muzzleflash", self.ChopperGun:GetPos()+self.ChopperGun:GetForward() * 72, self.ChopperGun:GetAngles(), self.ChopperGun )
	end
			
	self.ChopperGun:FireBullets( bullet )
	
	self.ChopperGun:EmitSound( "Global.ChoppaGun", 510, math.random(96,104) )

	self.ChopperGunAttack = CurTime()
	
end

function Meta:ChopperGunCallback( a, b, c )

	if ( IsValid( self.Pilot ) ) then
	
		ParticleEffect( "tank_impact_wall_sparkburst", b.HitPos, b.HitNormal:Angle() )
		ParticleEffect( "ric_dustup", b.HitPos, b.HitNormal:Angle() )
		
		util.BlastDamage( self.Pilot, self.Pilot, b.HitPos, 380, math.random( 25,150 ) )
		
	end
	
	return { damage = true, effects = DoDefaultEffect } 	
	
end

function Meta:NeuroPlanes_DefaultHeloUse(ply)
	
	if( ply == self.Pilot ) then return end
	
	if ( !self.IsFlying && !IsValid( self.Pilot ) ) then 

		self:GetPhysicsObject():Wake()
		self:GetPhysicsObject():EnableMotion(true)
		
		-- timer.Simple( self.SpinUpTime, function()
		
			-- if( IsValid( self ) ) then
				
				self.IsFlying = true
				self.Started = true
				
			-- end
			
		-- end )
		self.Pilot = ply
		self.Owner = ply
		
		self:SetNetworkedEntity("Pilot", ply )
		
		self.Entered = CurTime()
		
		ply:Spectate( OBS_MODE_CHASE  )
		ply:DrawViewModel( false )
		ply:DrawWorldModel( false )
		ply:StripWeapons()
		ply:SetScriptedVehicle( self )
		ply:SetNetworkedBool("InFlight",true)
		ply:SetNetworkedEntity( "Plane", self ) 
		ply:SetNetworkedBool( "isGunner", false )
		ply:SetNetworkedEntity( "ChopperGunnerEnt", self.ChopperGun )
		
		
		if( self.HelicopterPilotSeatPos ) then
		
			self.PilotModel = self:SpawnPilotModel( self.HelicopterPilotSeatPos, self:GetAngles() )
		
		end
		
		self.Entered = CurTime()
		
		if( self.SpinUpSound ) then
		
			self:EmitSound( self.SpinUpSound, 511, 100 )
			timer.Simple( self.SpinUpTime, function() if( IsValid( self ) ) then
				
				self.LoopSound:PlayEx(511,0)
				self.LoopSound:SetSoundLevel(511)
				
				end
			
			 end )
			
		
		else
			
				self.LoopSound:PlayEx(511,10)
				self.LoopSound:SetSoundLevel(511)
				
				
		end
		
	
			
	else 
	
		-- If we have a pilot, send this player to the co-pilot seat.
		local d = self.PassengerSeat:GetDriver()

		if( !IsValid( d ) ) then
			
			-- Give control of weapons to co-pilot.
			ply:EnterVehicle( self.PassengerSeat )
			
			if( IsValid( self.ChopperGun ) ) then
				
				ply:PrintMessage( HUD_PRINTCENTER, "Press ZOOM to toggle guncam" )
				ply:SetNetworkedEntity( "ChopperGunnerEnt", self.ChopperGun )
				ply:SetNetworkedEntity( "NeuroPlanes_Helicopter", self )
				
			end
			
			self.GotChopperGunner = false
			
			if( IsValid( self.Pilot ) ) then
			
				-- And revoke the controls from the pilot
				self.Pilot:PrintMessage( HUD_PRINTCENTER, ply:GetName().." is your new co-pilot." )
				self.Pilot:SetNetworkedBool( "isGunner", false )
				self.Pilot:SetNetworkedEntity( "ChopperGunnerEnt", NULL )
				
			end

		else
	
			for i=1,#self.GunnerSeats do
				
				if( !IsValid( self.GunnerSeats[i]:GetDriver() ) ) then
					
					ply:EnterVehicle( self.GunnerSeats[i] )
					ply:DrawWorldModel( true )
					ply:SetRenderMode( RENDERMODE_TRANSALPHA )
					ply:SetColor( Color( 255,255,255,255 ) )
					
					if( !IsValid( self.GunnerSeats[i].MountedWeapon ) ) then
						
						ply:SetAllowWeaponsInVehicle( true )
						-- ply:SetOwner( self )
						
					end
					
					return
					
				end
			
			end
	
		end

	end
	
end

function Meta:HelicopterGunnerSeatsKeyBinds()

	-- Gunners
	for i=1,#self.GunnerSeats do
		
		local seat = self.GunnerSeats[i]
		local gunner = seat:GetDriver()
		local Minigun = seat.MountedWeapon
		
		if( IsValid( seat ) && IsValid( gunner ) && IsValid( Minigun ) ) then
			
			gunner:SetAllowWeaponsInVehicle( false )
			
			local ang = gunner:EyeAngles()
			
			if( gunner:KeyDown( IN_USE ) ) then
				
				gunner:SetPos( self:LocalToWorld( Vector( 168, 0, 12 ) ) )
				
				return
				
			end
			
			if ( gunner:KeyDown( IN_ATTACK ) && Minigun.LastAttack + 0.1 <= CurTime() ) then
				
				ang = ang + Angle( math.Rand(-.4,.4), math.Rand(-.4,.4), math.Rand(-.4,.4) )
				
				local bullet = {} 
				bullet.Num 		= 1
				bullet.Src 		= Minigun:GetPos() + Minigun:GetForward() * 100
				bullet.Dir 		= Minigun:GetAngles():Forward()					-- Dir of bullet 
				bullet.Spread 	= Vector( .03, .03, .03 )				-- Aim Cone 
				bullet.Tracer	= 2											-- Show a tracer on every x bullets  
				bullet.Force	= 0						 				-- Amount of force to give to phys objects 
				bullet.Damage	= 0
				bullet.AmmoType = "Ar2" 
				bullet.TracerName = "AirboatGunHeavyTracer" 
				bullet.Callback = function ( a, b, c )
				
										local effectdata = EffectData()
											effectdata:SetOrigin( b.HitPos )
											effectdata:SetStart( b.HitNormal )
											effectdata:SetNormal( b.HitNormal )
											effectdata:SetMagnitude( 80 )
											effectdata:SetScale( 10 )
											effectdata:SetRadius( 30 )
										util.Effect( "ImpactGunship", effectdata )
										
										util.BlastDamage( self, gunner, b.HitPos, 64, 35 )
										
										return { damage = true, effects = DoDefaultEffect } 
										
									end 
									
				Minigun:FireBullets( bullet )	
				Minigun:EmitSound( "npc/turret_floor/shoot"..math.random(2,3)..".wav", 511, 60 )

				local effectdata = EffectData()
					effectdata:SetStart( Minigun:GetPos() )
					effectdata:SetOrigin( Minigun:GetPos() )
				util.Effect( "RifleShellEject", effectdata )  

				local e = EffectData()
					e:SetStart( Minigun:GetPos()+Minigun:GetForward() * 62 )
					e:SetOrigin( Minigun:GetPos()+Minigun:GetForward() * 62 )
					e:SetEntity( Minigun )
					e:SetAttachment(1)
					-- e:SetScale( 0.25 )
				util.Effect( "ChopperMuzzleFlash", e )

				Minigun.LastAttack = CurTime()
		
			end

			
			Minigun:SetAngles( ang )
		end
		
	end

end

function Meta:HelicopterCreateGunnerSeats( tbl )
	
	self.GunnerSeats = {}
	
	for i,v in pairs( tbl ) do
		
		if( v.Type == "Gunnerseat" ) then
			
			if( v.Pos ) then
				
				self.GunnerSeats[i] = ents.Create( "prop_vehicle_prisoner_pod" )
				self.GunnerSeats[i]:SetPos( self:LocalToWorld( v.Pos ) )
				self.GunnerSeats[i]:SetModel( v.Mdl )
				self.GunnerSeats[i]:SetKeyValue( "vehiclescript", "scripts/vehicles/prisoner_pod.txt" )
				self.GunnerSeats[i]:SetKeyValue( "LimitView", v.LimitView )
				self.GunnerSeats[i].HandleAnimation = function( v, p ) return p:SelectWeightedSequence( ACT_GMOD_SIT_ROLLERCOASTER ) end
				self.GunnerSeats[i]:SetAngles( self:GetAngles() + v.Ang )
				self.GunnerSeats[i]:SetParent( self )
				self.GunnerSeats[i]:Spawn()
				self.GunnerSeats[i].isChopperGunnerSeat = true
				
				if( self.HideExtraSeats || v.NoDraw == true ) then
					
					self.GunnerSeats[i]:SetRenderMode( RENDERMODE_TRANSALPHA )
					self.GunnerSeats[i]:SetColor( Color( 0,0,0,0 ) )
					
				end
				
				table.insert( self.ValidSeats, { self.GunnerSeats[i], "enter" } )
	
			end
			
			if( v.GunPos ) then
				
				self.GunnerSeats[i].MountedWeapon = ents.Create("prop_physics_override")
				self.GunnerSeats[i].MountedWeapon:SetPos( self:LocalToWorld( v.GunPos ) )
				self.GunnerSeats[i].MountedWeapon:SetAngles( self:GetAngles() + v.GunAng )
				self.GunnerSeats[i].MountedWeapon:SetModel( v.GunMdl )
				self.GunnerSeats[i].MountedWeapon:SetParent( self.GunnerSeats[i] )
				self.GunnerSeats[i].MountedWeapon:SetSolid( SOLID_NONE )
				self.GunnerSeats[i].MountedWeapon.LastAttack = CurTime()
				self.GunnerSeats[i].MountedWeapon:Spawn()
			
			end
			
			if( v.StPos ) then
				
				self.GunnerSeats[i].GunMount = ents.Create("prop_physics_override")
				self.GunnerSeats[i].GunMount:SetPos( self:LocalToWorld( v.StPos ) )
				self.GunnerSeats[i].GunMount:SetAngles( self:GetAngles() + v.StAng )
				self.GunnerSeats[i].GunMount:SetModel( v.StMdl )
				self.GunnerSeats[i].GunMount:SetParent( self.GunnerSeats[i] )
				self.GunnerSeats[i].GunMount:SetSolid( SOLID_NONE )
				self.GunnerSeats[i].GunMount:Spawn()
				
			end
			
			
		end
				
	end

end

function Meta:HelicopterAttachLoadout()

	-- Armamanet
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
		self.RocketVisuals[i]:SetColor( v.Col )
		self.RocketVisuals[i].Type = v.Type
		self.RocketVisuals[i].PrintName = v.PrintName
		self.RocketVisuals[i].Cooldown = v.Cooldown
		self.RocketVisuals[i].isFirst = v.isFirst
		self.RocketVisuals[i].Identity = i
		self.RocketVisuals[i].Class = v.Class
		self.RocketVisuals[i]:SetColor( v.Col )
		self.RocketVisuals[i]:SetRenderMode( RENDERMODE_TRANSALPHA )
		self.RocketVisuals[i]:Spawn()
		self.RocketVisuals[i].LastAttack = CurTime()
		
		if( v.BurstSize ) then
			
			self.RocketVisuals[i].BurstSize = v.BurstSize
		
		end
		
		if ( v.Damage && v.Radius ) then
			
			self.RocketVisuals[i].Damage = v.Damage
			self.RocketVisuals[i].Radius = v.Radius
		
		end
		
		-- Usuable Equipment
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


function Meta:HelicopterFuselageAttack()

	if ( !IsValid( self.Pilot ) ) then
		
		return
		
	end
	
	if( !IsValid( self.ChopperGun ) ) then return end
	
	local bullet = {} 
 	bullet.Num 		= 1
 	bullet.Src 		= self.ChopperGun:GetPos() + self.ChopperGun:GetForward() * 45
 	bullet.Dir 		= self.ChopperGun:GetAngles():Forward()						-- Dir of bullet 
 	bullet.Spread 	= Vector( .021, .021, .019 )								-- Aim Cone 
 	bullet.Tracer	= 1															-- Show a tracer on every x bullets  
 	bullet.Force	= 50					 									-- Amount of force to give to phys objects 
 	bullet.Damage	= math.random( 25, 75 )
 	bullet.AmmoType = "Ar2" 
 	bullet.TracerName 	= "AirboatGunHeavyTracer" 
 	bullet.Callback    = function ( a, b, c )
								
							self:HelicopterGunCallback( a, b, c )
							
						end 
 	local e = EffectData()
	e:SetStart( self.ChopperGunProp:GetPos()+self.ChopperGunProp:GetForward() * 72 )
	e:SetOrigin( self.ChopperGunProp:GetPos()+self.ChopperGunProp:GetForward() * 72 )
	e:SetEntity( self.ChopperGunProp )
	e:SetAttachment( 1 )
	util.Effect( "ChopperMuzzleFlash", e )
	
	self.ChopperGun:FireBullets( bullet )
	
	self.ChopperGun:EmitSound( "AH64fire.wav", 510, math.random(96,104) )

	self.ChopperGunAttack = CurTime()
	
end

function Meta:HelicopterGunCallback( a, b, c )

	if ( IsValid( self.Pilot ) ) then
	
		local e = EffectData()
		e:SetOrigin(b.HitPos)
		e:SetNormal(b.HitNormal)
		e:SetScale( 4.5 )
		util.Effect("ManhackSparks", e)

		local e = EffectData()
		e:SetOrigin(b.HitPos)
		e:SetNormal(b.HitNormal)
		e:SetScale( 1.5 )
		util.Effect("HelicopterMegaBomb", e)
		
		util.BlastDamage( self.Pilot, self.Pilot, b.HitPos, 380, math.random( 25,150 ) )
		
	end
	
	return { damage = true, effects = DoDefaultEffect } 	
	
end

function Meta:HelicopterSpinThatThing()
	
	if( self.Destroyed || !self.IsFlying ) then return end
	
	local topval = ( self.Pilot != nil && ( self.MaxRotorVal / 2 ) ) or 0 -- Should not be > 500
	
	self.RotorVal = math.Approach( self.RotorVal, topval, self.RotorMult )	
	self.Started = ( self.RotorTimer <= 1 ) -- Loving the hard coded values <^.^> 

	if( self.Started ) then
		
		if( IsValid( self.TailPropeller ) ) then
		
			if( self.TiltTailRotor ) then
				
				self.TailPropeller:GetPhysicsObject():AddAngleVelocity( Vector( 0, 0, self.RotorVal * 2 ) )
		
			else
			
				self.TailPropeller:GetPhysicsObject():AddAngleVelocity( Vector( 0, self.RotorVal * 2, 0 ) )
		
			end
			
		end
		
		if( IsValid( self.RotorPropeller ) ) then
		
			self.RotorPropeller:GetPhysicsObject():AddAngleVelocity( Vector( 0, 0, self.RotorVal * 2 ) )
		
		end
		
	else
		
		if ( self.RotorVal > 1 && !self.Destroyed ) then
		
			self.RotorTimer = self.RotorTimer - 0.5 ----math.Round(200/(self.EngineTimeRate))/100
			if( IsValid( self.TailPropeller ) ) then
				
				if( self.TiltTailRotor ) then
					
					self.TailPropeller:GetPhysicsObject():AddAngleVelocity( Vector( 0, 0, -self.RotorVal * 20 / self.RotorTimer ) )

				else
				
					self.TailPropeller:GetPhysicsObject():AddAngleVelocity( Vector( 0, self.RotorVal * 20 / self.RotorTimer, 0 ) )
				
				end
				
			end
			
			if( IsValid( self.RotorPropeller ) ) then

				self.RotorPropeller:GetPhysicsObject():AddAngleVelocity( Vector( 0, 0, self.RotorVal * 20 / self.RotorTimer ) )
			
			end
					
		end
		
		if ( self.RotorTimer <= 1 ) then
		
			self.RotorTimer = 1
		
		end
	
	end
	
end



function Meta:HelicopterSecondaryAttack( wep, id )
	
	if ( IsValid( wep ) ) then
	
		self:NeuroPlanes_FireRobot( wep, id )
		
	end
	
end

function Meta:HelicopterMgunAttack()
	
	if( self.NoGuns ) then return end
	
	if ( !IsValid( self.Pilot ) ) then
		
		return
		
	end
	
	local d = self.PassengerSeat:GetDriver()
	if( !IsValid( d ) ) then
		
		d = self.Pilot
		
	end
	
	for i=1,2 do
			
		local bullet = {} 
		bullet.Num 		= 1
		bullet.Src 		= self.Miniguns[i]:GetPos() + self.Miniguns[i]:GetForward() * 60
		bullet.Dir 		= self.Miniguns[i]:GetAngles():Forward()			-- Dir of bullet 
		bullet.Spread 	= Vector( .041, .041, .041 )				-- Aim Cone 
		bullet.Tracer	= 1											-- Show a tracer on every x bullets  
		bullet.Force	= 25					 					-- Amount of force to give to phys objects 
		bullet.Damage	= math.random( 1, 2 )
		bullet.AmmoType = "Ar2" 
		bullet.TracerName 	= "AirboatGunHeavyTracer" 
		bullet.Callback    = function ( a, b, c )
								/*
								local effectdata = EffectData()
									effectdata:SetOrigin( b.HitPos )
									effectdata:SetStart( b.HitPos )
									effectdata:SetNormal( b.HitNormal )
									effectdata:SetScale( 1 )
								util.Effect( "ManhackSparks", effectdata )
								*/
								ParticleEffect( "tank_impact_wall_sparkburst", b.HitPos, b.HitNormal:Angle() )
								ParticleEffect( "ric_dustup", b.HitPos, b.HitNormal:Angle() )
		
								util.BlastDamage( d, d, b.HitPos, 68, math.random( 20, 32 ) )
								
								return { damage = true, effects = DoDefaultEffect } 
								
							end 
		
		local effectdata = EffectData()
		effectdata:SetStart( self.Miniguns[i]:GetPos() )
		effectdata:SetOrigin( self.Miniguns[i]:GetPos() )
		effectdata:SetEntity( self.Miniguns[i] )
		effectdata:SetNormal( self:GetForward() )
		util.Effect( "A10_muzzlesmoke", effectdata )

		
		local shell = EffectData()
		shell:SetStart( self.Miniguns[i]:GetPos() )
		shell:SetOrigin( self.Miniguns[i]:GetPos() )
		util.Effect( "RifleShellEject", shell ) 
		
		/*
		local e = EffectData()
			e:SetStart( self.Miniguns[i]:GetPos() )
			e:SetOrigin( self.Miniguns[i]:GetPos() )
			e:SetEntity( self.Miniguns[i] )
			e:SetAttachment(1)
			e:SetScale( 0.2 )
		util.Effect( "ChopperMuzzleFlash", e )
		*/
		ParticleEffect( "MG_muzzleflash", self.Miniguns[i]:GetPos() + self.Miniguns[i]:GetForward()*30, self.Miniguns[i]:GetAngles(), self.Miniguns[i] )
		
		self.Miniguns[i]:FireBullets( bullet )
		
		--self.Miniguns[i]:EmitSound("LockOn/TurretRotation.mp3", 511, 100 )
		self.Miniguns[i]:EmitSound("minigun_shoot.wav", 511, 100 )

		
		
	end

	self.ChopperGunAttack = CurTime()
	
end

function Meta:HelicopterDefaultThink2()
	
	
   if( IsValid( self.RotorPropeller ) ) then

        self.RotorPropeller:SetSkin( self:GetSkin() )
		
		
    end

    if( IsValid( self.TailPropeller ) ) then

        self.TailPropeller:SetSkin( self:GetSkin() )

    end

	if( !self.VelPitch ) then self.VelPitch = 0 end
	
    if ( self.IsFlying && IsValid( self.Pilot ) ) then
		
        self.VelPitch = Lerp( 0.1, self:GetVelocity():Length() / 70, self.VelPitch )

    -- else

        -- self.VelPitch = 0

    end

    self.Pitch = math.Clamp( math.floor( self.VelPitch + self.RotorPhys:GetAngleVelocity():Length() / 30  ),0,175 )
    self.LoopSound:ChangePitch( self.Pitch, 2.0 )
	
    if ( self.HealthVal < self.InitialHealth * 0.12 && self:WaterLevel() < 2 ) then

        local effectdata = EffectData()
        effectdata:SetOrigin( self:GetPos() + self:GetRight() * math.random(-32,32) + self:GetForward() * math.random(-32,32)  )
        util.Effect( "immolate", effectdata )

    end

    if ( self.IsFlying && IsValid( self.Pilot ) ) then

        self.Pilot:SetPos( self:GetPos()+Vector(0,0,5) )

        -- HUD Stuff
        self:UpdateRadar()

		if( !self.NoGuns ) then
		
			-- -- Lock On method
			self:Jet_LockOnMethod()

		end
		
        -- Clear Target
        if ( self.Pilot:KeyDown( IN_SPEED ) && IsValid( self.Target ) ) then

            self:ClearTarget()
            self.Pilot:PrintMessage( HUD_PRINTCENTER, "Target Released" )

        end

        local d = self.PassengerSeat:GetDriver()
		self.CoPilot = d
		
        -- Attack
        if ( !self.NoGuns && ( self.Pilot:KeyDown( IN_ATTACK ) && !IsValid( d ) ) || ( IsValid( d ) && d:KeyDown( IN_ATTACK ) ) ) then

            if ( self.ChopperGunAttack + 0.1 <= CurTime() ) then

                self:PrimaryAttack()

            end

        end

        if ( !self.NoGuns && self.LastSecondaryKeyDown + 0.5 <= CurTime() && ( ( self.Pilot:KeyDown( IN_ATTACK2 ) && !IsValid( d ) ) || ( IsValid( d ) && d:KeyDown( IN_ATTACK2 ) ) ) ) then

            local id = self.EquipmentNames[ self.FireMode ].Identity
            local wep = self.RocketVisuals[ id ]
            self.LastSecondaryKeyDown = CurTime()

            if ( wep.LastAttack + wep.Cooldown <= CurTime() ) then

                self:SecondaryAttack( wep, id )

            else


                local cd = math.ceil( ( wep.LastAttack + wep.Cooldown ) - CurTime() )

                local a = self.Pilot

                if( IsValid( d ) ) then -- copilot

                    a = d

                end

                if ( cd == 1 ) then

                    a:PrintMessage( HUD_PRINTTALK, self.PrintName..": "..wep.PrintName.." ready in "..tostring( cd ).. " second." )

                else

                    a:PrintMessage( HUD_PRINTTALK, self.PrintName..": "..wep.PrintName.." ready in "..tostring( cd ).. " seconds." )

                end

            end

        end


        -- Firemode
        if (  (  ( self.Pilot:KeyDown( IN_RELOAD ) && !IsValid( d ) ) || ( IsValid( d ) && d:KeyDown( IN_RELOAD ) ) ) && self.LastFireModeChange + 0.5 <= CurTime() ) then

            self:CycleThroughWeaponsList()

        end

        -- Flares
		local cp = IsValid( self.CoPilot ) && self.CoPilot:KeyDown( IN_JUMP )
		
        if ( ( self.Pilot:KeyDown( IN_SCORE ) || cp ) && !self.isHovering && self.FlareCount > 0 && self.LastFlare + self.FlareCooldown <= CurTime() && self.LastFireModeChange + 0.2 <= CurTime() ) then

            self.LastFireModeChange = CurTime()
            self.FlareCount = self.FlareCount - 1
            self:SetNetworkedInt( "FlareCount", self.FlareCount )
            self:SpawnFlare()

            if ( self.FlareCount == 0 ) then

                self.LastFlare = CurTime() + 30
                self.FlareCount = self.MaxFlares

            end

        end

        if ( self.Pilot:KeyDown( IN_USE ) && self.Entered + 1.0 <= CurTime() ) then

            self:HeloEjectPilotSpecial()

        end

        -- Ejection Situations.
        if ( self:WaterLevel() > 2 ) then

            self:HeloEjectPilotSpecial()

        end
	else
	
		
		self.RotorTimer = math.Approach( self.RotorTimer, self.MaxRotorTimer, 2 )
		
    end
	
	self:NextThink(CurTime())
	
end
function Meta:HelicopterDefaultThink()
		
	if ( self.Burning && self:WaterLevel() < 2 ) then 
		
		local effectdata = EffectData()
		effectdata:SetOrigin( self:GetPos() + self:GetRight() * math.random(-32,32) + self:GetForward() * math.random(-32,32)  )
		util.Effect( "immolate", effectdata )
		self.HealthVal = self.HealthVal - 1
		
	end
		
	if( self.Destroyed ) then
		
		self.DeathTimer = self.DeathTimer + 1
		
		if( self.DeathTimer > 15 ) then
		
			self.Destroyed = true
			
			self:DeathFX()
				
			return
				
		end
		
	end
	
	if( !IsValid( self.rotoraxis ) ) then	
		
		self.Destroyed = true
		
		return
		
	end
			
	if ( self.IsFlying && IsValid( self.Pilot ) ) then
	
		self.VelPitch = self:GetVelocity():Length() / 100
		
	else 
		
		self.VelPitch = 0
	
	end
	
	self.Pitch = math.Clamp( math.floor( self.VelPitch + self.RotorPhys:GetAngleVelocity():Length() / 30  ),0,175 )
	self.LoopSound:ChangePitch( self.Pitch, 2.0 )
		
	if( IsValid( self.ChopperGun ) ) then
	
		self.ChopperGun:SetSkin( self:GetSkin() )
	
	end
	
	if( IsValid( self.RotorPropeller ) ) then
	
		self.RotorPropeller:SetSkin( self:GetSkin() )
	
	end
	
	if( IsValid( self.TailPropeller ) ) then
	
		self.TailPropeller:SetSkin( self:GetSkin() )
		
	end
	
	if ( self.IsFlying && IsValid( self.Pilot ) ) then
		
		self.Pilot:SetPos( self:GetPos() + self:GetUp() * 72 )
		
		-- HUD Stuff
		self:UpdateRadar()
		-- Lock On method
		if( self.CanLockon != false ) then
			
			if( !self.NoGuns ) then
			
				self:Jet_LockOnMethod()
			
			end
			
		end
		
		-- Clear Target 
		if ( self.Pilot:KeyDown( IN_SPEED ) && IsValid( self.Target ) ) then
			
			self:ClearTarget()
			self.Pilot:PrintMessage( HUD_PRINTCENTER, "Target Released" )
			
		end
					
		local d = self.PassengerSeat:GetDriver()
		
		self.CoPilot = d
		
		-- Attack
		if ( self.HasMGun != false && ( self.Pilot:KeyDown( IN_ATTACK ) && !IsValid( d ) ) || ( IsValid( d ) && d:KeyDown( IN_ATTACK ) ) ) then

			if ( self.ChopperGunAttack + 0.12 <= CurTime() ) then
				
				self:HelicopterFuselageAttack()
			
			end
			
		end

		if ( !self.NoGuns && self.LastSecondaryKeyDown + 0.5 <= CurTime() && self.Pilot:KeyDown( IN_ATTACK2 ) && !self.Pilot:GetNetworkedBool( "isGunner", false ) ) then
			
			local id = self.EquipmentNames[ self.FireMode ].Identity
			local wep = self.RocketVisuals[ id ]
			self.LastSecondaryKeyDown = CurTime()
			
			if( !IsValid( wep ) ) then
					
				self.Pilot:PrintMessage( HUD_PRINTCENTER, "NO AMMO" )
				
				return 
				
			end
	
			if ( wep.LastAttack + wep.Cooldown <= CurTime() ) then
			
				self:HelicopterSecondaryAttack( wep, id )
				
			else
			
	
				local cd = math.ceil( ( wep.LastAttack + wep.Cooldown ) - CurTime() ) 
				
				if ( cd == 1 ) then 
				
					self.Pilot:PrintMessage( HUD_PRINTTALK, self.PrintName..": "..wep.PrintName.." ready in "..tostring( cd ).. " second." )
				
				else
				
					self.Pilot:PrintMessage( HUD_PRINTTALK, self.PrintName..": "..wep.PrintName.." ready in "..tostring( cd ).. " seconds." )	
				
				end
				
			end
	
		end
		
		if( self.HasMGun != false ) then
		
			local eyeAng
			local myAng = self:GetAngles()

			if( IsValid( d ) && d:IsPlayer() ) then 
				
				eyeAng = d:EyeAngles()
				
				if ( d:KeyDown( IN_ZOOM ) && self.LastChopperGunToggle + 1.0 <= CurTime() && !IsValid( self.LaserGuided ) ) then
									
			
					self.LastChopperGunToggle = CurTime()
					self.GotChopperGunner = !self.GotChopperGunner
					d:SetNetworkedBool( "isGunner", self.GotChopperGunner )
					d:SetNetworkedEntity( "ChopperGunEnt", self.ChopperGun )
					d:SetNetworkedEntity( "NeuroPlanes_Helicopter", self )
					--print( "Values: ", self.GotChopperGunner, self.Pilot:GetNetworkedBool("isGunner", false), self.Pilot:GetNetworkedEntity("ChopperGunnerEnt", NULL ) )
					
				end
			
			else
				
				eyeAng = self.Pilot:EyeAngles()
				
				if ( self.Pilot:KeyDown( IN_ZOOM ) && self.LastChopperGunToggle + 1.0 <= CurTime() && !IsValid( self.LaserGuided ) ) then
					
					self.LastChopperGunToggle = CurTime()
					self.GotChopperGunner = !self.GotChopperGunner
					self.Pilot:SetNetworkedBool( "isGunner", self.GotChopperGunner )
					self.Pilot:SetNetworkedEntity( "ChopperGunEnt", self.ChopperGun )
					
					--print( "Values: ", self.GotChopperGunner, self.Pilot:GetNetworkedBool("isGunner", false), self.Pilot:GetNetworkedEntity("ChopperGunnerEnt", NULL) )

				end
			
			end
			
			eyeAng.r = myAng.r

			if ( eyeAng.y > myAng.y + 85 ) then
			
				eyeAng.y = myAng.y + 85
				
			elseif( eyeAng.y < myAng.y -85 ) then
			
				eyeAng.y = myAng.y -85
				
			end
			
			if ( eyeAng.p > myAng.p + 70 ) then
			
				eyeAng.p = myAng.p + 70
				
			elseif( eyeAng.p < myAng.p -4 ) then
			
				eyeAng.p = myAng.p -4
				
			end
			
			if( IsValid( self.ChopperGun ) ) then
				
				self.ChopperGun:SetAngles( LerpAngle( 0.223, self.ChopperGun:GetAngles(), eyeAng ) )
			
			end
			if( IsValid( self.ChopperTurret ) ) then
				
				self.ChopperTurret:SetAngles( Angle( myAng.p, eyeAng.y, myAng.r ) )
			
			end
		
		end
		
		-- Firemode 
		if ( self.Pilot:KeyDown( IN_RELOAD ) && self.LastFireModeChange + 0.5 <= CurTime() ) then

			self:CycleThroughWeaponsList()
			
		end
		
		-- Flares
		if ( (  self.Pilot:KeyDown( IN_SCORE ) || ( IsValid( self.CoPilot ) && self.CoPilot:KeyDown( IN_JUMP ) ) ) &&  self.FlareCount > 0 && self.LastFlare + self.FlareCooldown <= CurTime() && self.LastFireModeChange + 0.62 <= CurTime() ) then
			
			self.LastFireModeChange = CurTime()
			self.FlareCount = self.FlareCount - 1
			self:SetNetworkedInt( "FlareCount", self.FlareCount )
			self:SpawnFlare()
			
			if ( self.FlareCount == 0 ) then
			
				self.LastFlare = CurTime() 
				self.FlareCount = self.MaxFlares
				timer.Simple( self.FlareCooldown,
				function()
					if( IsValid( self ) ) then
						
						self:SetNetworkedInt( "FlareCount", self.FlareCount )
						
					end
					
				end )
				
			end
			
		end
	
		if ( self.Pilot:KeyDown( IN_USE ) && self.Entered + 1.0 <= CurTime() ) then

			self:HeloEjectPilotSpecial()
			
		end	
		
		-- Ejection Situations.
		if ( self:WaterLevel() > 2 ) then
		
			self:HeloEjectPilotSpecial()
			
		end

	end
	
end

function Meta:HeloEjectPilotSpecial()
	
	if ( !IsValid( self.Pilot ) ) then 
	
		return
		
	end
	
	self.Pilot:UnSpectate()
	self.Pilot:DrawViewModel( true )
	self.Pilot:DrawWorldModel( true )
	self.Pilot:Spawn()
	self.Pilot:SetNetworkedBool( "InFlight", false )
	self.Pilot:SetNetworkedEntity( "Plane", NULL ) 
	self:SetNetworkedEntity("Pilot", NULL )
	self.Pilot:SetNetworkedBool( "isGunner", false )
	self.Pilot:SetNetworkedBool( "DrawDesignator", false )
	self.Pilot:ExitVehicle()
	
	if( self.LoopSound ) then
		
		self.LoopSound:FadeOut( 10 )
		 
		
	end
	
	if( self.ExitPos ) then
		
		self.Pilot:SetPos( self:LocalToWorld( self.ExitPos ) )
		
	else
	
		self.Pilot:SetPos( self:GetPos() + self:GetRight() * -155 )
		
	end
	
	self.Pilot:SetAngles( Angle( 0, self:GetAngles().y,0 ) )
	self.Owner = NULL
	self.Pilot:SetScriptedVehicle( NULL )
	
	self.Speed = 0
	self.IsFlying = false
	self:SetLocalVelocity(Vector(0,0,0))
	
	if( IsValid( self.PilotModel ) ) then
		
		self.PilotModel:Remove()
	
	end
	
	--local oldpilot = self.Pilot
	
	self.Pilot = NULL
	/*
	-- Give the copilot control over the helicopter when the current pilot exits
	if( IsValid( self.PassengerSeat:GetDriver() ) ) then
		
		
		local ply = self.PassengerSeat:GetDriver()
		ply:ExitVehicle()
		self:SetNetworkedEntity( "CoPilot", NULL )
		
		self:Use( ply, ply )
		
		if( IsValid( oldpilot ) ) then
				
			ply:PrintMessage( HUD_PRINTCENTER, oldpilot:GetName().." bailed on you. You are the new pilot." )
			
		end
		
		return
		
	end
	*/
end

function Meta:HelicopterCreateEngineSound()

	self.LoopSound = CreateSound(self.Entity,Sound( self.HelicopterEngineSound ))
	self.LoopSound:SetSoundLevel(511)
	
end

function Meta:HelicopterCreateFXSound()
	
	if self.HelicopterAlarmSound != nil then
		self.AlarmSound = CreateSound(self.Entity,Sound( self.HelicopterAlarmSound ))
	else
		self.AlarmSound = CreateSound(self.Entity,Sound( "Tiger/fire_alarm.wav" ))
	end

end
	
function Meta:HelicopterCreatePilotSeat()
	
	if( !self.HelicopterPilotSeatPos ) then return end
	
	self.PilotSeat = ents.Create( "prop_vehicle_prisoner_pod" )
	self.PilotSeat:SetPos( self:LocalToWorld( self.HelicopterPilotSeatPos ) )
	self.PilotSeat:SetModel( "models/nova/jeep_seat.mdl" )
	self.PilotSeat:SetKeyValue( "vehiclescript", "scripts/vehicles/prisoner_pod.txt" )
	self.PilotSeat.HandleAnimation = function( v, p ) return p:SelectWeightedSequence( ACT_DRIVE_AIRBOAT ) end
	self.PilotSeat:SetAngles( self:GetAngles() + Angle( 0, -90, 0 ) )
	self.PilotSeat:SetParent( self )
	self.PilotSeat:SetKeyValue( "LimitView", "0" )
	self.PilotSeat:SetRenderMode( RENDERMODE_TRANSALPHA )
	if( GetConVarNumber("developer") == 0 ) then
	
		self.PilotSeat:SetColor( Color( 0,0,0,0 ) )
		
	end
	
	self.PilotSeat:Spawn()
	
end

function Meta:HelicopterCreatePassengerSeat()
	
	if( !self.HelicopterPassengerSeatPos ) then return end
	
	self.PassengerSeat = ents.Create( "prop_vehicle_prisoner_pod" )
	self.PassengerSeat:SetPos( self:LocalToWorld( self.HelicopterPassengerSeatPos ) )
	self.PassengerSeat:SetModel( "models/nova/jeep_seat.mdl" )
	self.PassengerSeat:SetKeyValue( "LimitView", "0" )
	self.PassengerSeat:SetKeyValue( "vehiclescript", "scripts/vehicles/prisoner_pod.txt" )
	self.PassengerSeat.HandleAnimation = function( v, p ) return p:SelectWeightedSequence( ACT_DRIVE_AIRBOAT ) end
	self.PassengerSeat:SetAngles( self:GetAngles() + Angle( 0, -90, 0 ) )
	self.PassengerSeat:SetParent( self )
	if( GetConVarNumber("developer") == 0 ) then
	
		self.PassengerSeat:SetColor( Color ( 0,0,0,0 ) )
		
	end
	
	self.PassengerSeat:SetRenderMode( RENDERMODE_TRANSALPHA )
	self.PassengerSeat:Spawn()
	
	if( IsValid( self.ChopperGun ) ) then
	
		self.PassengerSeat.IsChopperGunnerSeat = true
		
	end
	
	self.PassengerSeat.IsHelicopterCoPilotSeat = true
	
	
	table.insert( self.ValidSeats, { self.PassengerSeat, "enter" } )
		
end


function Meta:HelicopterCreateRotors()

	self.RotorPropeller = ents.Create("sent_cobra_rotor")
	self.RotorPropeller:SetPos( self:LocalToWorld( self.RotorPropellerPos ) )
	self.RotorPropeller:SetAngles( self:GetAngles() )
	self.RotorPropeller:SetSolid( SOLID_VPHYSICS )
	self.RotorPropeller:Spawn()
	self.RotorPropeller.isTouching = false
	self.RotorPropeller:SetOwner( self )
	self.RotorPropeller:SetModel( self.RotorModel )
	self:SetNetworkedEntity("RotorProp", self.RotorPropeller )
	
	self.rotoraxis = constraint.Axis( self.RotorPropeller, self, 0, 0, Vector(0,0,1) , self.RotorPropellerPos, 0, 0, 1, 0 )

	local ea = Vector( 0,1,0 )
	if( self.TailRotorAngleOffset ) then
		
		ea = self.TailRotorAngleOffset
		
	end
	
	self.TailPropeller = ents.Create("prop_physics")
	self.TailPropeller:SetModel( self.RotorModelTail )
	self.TailPropeller:SetPos( self:LocalToWorld( self.TailPropellerPos )  )
	self.TailPropeller:SetAngles( self:GetAngles() )
	self.TailPropeller:Spawn()
	self.TailPropeller:SetOwner( self )
	
	if( self.TiltTailRotor ) then
			
		self.tailrotoraxis = constraint.Axis( self.TailPropeller, self, 0, 0, Vector(0,0,1) , self.TailPropellerPos, 0, 0, 1, 0 )
	
	else
	
		self.tailrotoraxis = constraint.Axis( self.TailPropeller, self, 0, 0, ea , self.TailPropellerPos, 0, 0, 1, 0 )

	end
	
	self.TailPhys = self.TailPropeller:GetPhysicsObject()
	self.RotorPhys = self.RotorPropeller:GetPhysicsObject()	

	if ( self.RotorPhys:IsValid() ) then
	
		self.RotorPhys:Wake()
		self.RotorPhys:SetMass( self.MaxRotorVal )
		self.RotorPhys:EnableGravity( false )
		self.RotorPhys:EnableDrag( true )
		
	end
	
	if ( self.TailPhys:IsValid() ) then
	
		self.TailPhys:Wake()
		self.TailPhys:SetMass( 100 )
		self.TailPhys:EnableGravity( false )
		self.TailPhys:EnableCollisions( false )
		
	end
	
	constraint.NoCollide( self, self.RotorPropeller, 0, 0 )	
	constraint.NoCollide( self, self.TailPropeller, 0, 0 )
	

end

function Meta:HelicopterCreateChopperGun()
	
	self.ChopperGun = ents.Create("prop_physics_override")
	self.ChopperGun:SetModel( self.MachineGunModel )
	self.ChopperGun:SetPos( self:LocalToWorld( self.MachineGunOffset ) )
	self.ChopperGun:SetAngles( self:GetAngles() )
	self.ChopperGun:SetSolid( SOLID_NONE )
	self.ChopperGun:SetParent( self )
	self.ChopperGun:Spawn()
	self.ChopperGun:SetOwner( self )
	
	self.ChopperGunProp = ents.Create("prop_physics_override")
	self.ChopperGunProp:SetModel( "models/Airboatgun.mdl" )
	self.ChopperGunProp:SetPos( self.ChopperGun:GetPos() + self.ChopperGun:GetForward() * 32 )
	self.ChopperGunProp:SetParent( self.ChopperGun )
	self.ChopperGun:SetSolid( SOLID_NONE )
	self.ChopperGunProp:SetAngles( self:GetAngles() )
	self.ChopperGunProp:Spawn()
	self.ChopperGunProp:SetColor( Color( 0, 0, 0, 0 ) )
	self.ChopperGunProp:SetRenderMode( RENDERMODE_TRANSALPHA )
	self.ChopperGunProp:SetOwner( self.ChopperGun )

	if self.MGunHasTurret then
	self.ChopperTurret = ents.Create("prop_physics_override")
	self.ChopperTurret:SetModel( self.ChopperTurretModel )
	self.ChopperTurret:SetPos( self:GetPos() + self.ChopperTurretPos  )
	self.ChopperTurret:SetAngles( self:GetAngles() + self.ChopperTurretAng )
	self.ChopperTurret:SetSolid( SOLID_NONE )
	self.ChopperTurret:SetParent( self )
	self.ChopperTurret:Spawn()
	end
	
end
	
function Meta:HelicopterCreateWheels()
	
	for i = 1,#self.WheelPos do
		
		self.Wheels[i] = ents.Create("prop_physics")
		self.Wheels[i]:SetPos( self:LocalToWorld( self.WheelPos[i] ) )
		self.Wheels[i]:SetModel( self.WheelModel )
		self.Wheels[i]:SetAngles( self:GetAngles() )
		self.Wheels[i]:Spawn()
			
	end
	for i = 1,#self.OtherWheelPos do
		
		self.OtherWheels[i] = ents.Create("prop_physics")
		self.OtherWheels[i]:SetPos( self:LocalToWorld( self.OtherWheelPos[i] ) )
		self.OtherWheels[i]:SetModel( self.OtherWheelModel )
		self.OtherWheels[i]:SetAngles( self:GetAngles() )
		self.OtherWheels[i]:Spawn()
			
	end

	self.WheelWelds = {}
	self.WheelPhys = {}	
	for i = 1,#self.WheelPos do
	
		constraint.NoCollide( self.Wheels[i], self, 0, 0 )	
		self.WheelWelds[i] = constraint.Axis( self.Wheels[i], self, 0, 0, Vector(0,1,0) , self.WheelPos[i], 0, 0, 1, 0 )
		self.WheelPhys[i] = self.Wheels[i]:GetPhysicsObject()
		self.WheelPhys[i]:Wake()
		self.WheelPhys[i]:SetMass( 2000 )
		self.WheelPhys[i]:EnableGravity( false )
		self.WheelPhys[i]:EnableCollisions( true )

	end
	self.OtherWheelWelds = {}
	self.OtherWheelPhys = {}	
	for i = 1,#self.OtherWheels do	
		constraint.NoCollide( self.OtherWheels[i], self, 0, 0 )	
		self.OtherWheelWelds[i] = constraint.Axis( self.OtherWheels[i], self, 0, 0, Vector(0,1,0) , self.OtherWheelPos[i], 0, 0, 1, 0 )
		self.OtherWheelPhys[i] = self.OtherWheels[i]:GetPhysicsObject()
		self.OtherWheelPhys[i]:Wake()
		self.OtherWheelPhys[i]:SetMass( 2000 )
		self.OtherWheelPhys[i]:EnableGravity( false )
		self.OtherWheelPhys[i]:EnableCollisions( true )
	end

end

function Meta:HelicopterDefaultInit()
	
	self.ValidSeats = { { self, "use" } }
	self.MaxRotorTimer = self.RotorTimer or 500
	
	self.HealthVal = self.InitialHealth
	local now = CurTime() - 60
	self.LastPrimaryAttack 		= now
	self.LastSecondaryAttack 	= now
	self.LastFireModeChange 	= now
	self.LastRadarScan 			= now
	self.LastFlare 				= now
	self.ChopperGunAttack 		= now
	
	self.LastChopperGunToggle = CurTime() 
	self.LastLaserUpdate = CurTime()
	self.LastSecondaryKeyDown = CurTime()
	self.LastSeatChange = CurTime()
	self:SetUseType( SIMPLE_USE )
	self.IsFlying = false
	self.Pilot = NULL
	self.DeathTimer = 0
	self.EngineTimeRate = 1

	self.Wheels = {}
	self.OtherWheels = {}
	
	self:HelicopterAttachLoadout()
	self:HelicopterCreateFXSound()
	
	self.MinigunRevolve = 0
	self.HoverVal = 0
	self.MoveRight = 0
	self.RotorVal = 0
	self.MaxRotorVal = self.TopRotorVal or 1600
	self.RotorMult = self.MaxRotorVal / 2000
	self.Started = false
	self.SpinUp = 0
	self.Pitch = 0
	self.VelPitch = 0
	self.PhysObj = self:GetPhysicsObject()

	-- Misc
	self:SetModel( self.Model )	
	self:PhysicsInit( SOLID_VPHYSICS )
	self:SetMoveType( MOVETYPE_VPHYSICS )
	self:SetSolid( SOLID_VPHYSICS )

	self:SetNetworkedInt( "health", self.HealthVal )
	self:SetNetworkedInt( "HudOffset", self.CrosshairOffset )
	self:SetNetworkedInt( "MaxHealth", self.InitialHealth )
	self:SetNetworkedInt( "MaxSpeed", self.MaxVelocity )
	
	if( self.MinigunPos ) then
	
		-- Equipment
		self.Miniguns = {}

		for i=1,#self.MinigunPos do
			
			self.Miniguns[i] = ents.Create("prop_physics_override")
			self.Miniguns[i]:SetPos( self:LocalToWorld( self.MinigunPos[i] ) )
			self.Miniguns[i]:SetAngles( self:GetAngles() )
			self.Miniguns[i]:SetModel( self.MinigunModel or "models/Airboatgun.mdl")  -- this model got the muzzle attachment.
			self.Miniguns[i]:SetParent( self )
			self.Miniguns[i]:SetSolid( SOLID_NONE )
			self.Miniguns[i]:SetRenderMode( RENDERMODE_TRANSALPHA )
			
			if( self.ShowMiniguns ) then
			
			else
			
				self.Miniguns[i]:SetColor( Color( 0,0,0,0 ) )
				
			end
			
			
			self.Miniguns[i]:Spawn()
		
		end
		
	end
	
	
	self:HelicopterCreateEngineSound()

	self:HelicopterCreatePilotSeat() -- Create Seats
	self:HelicopterCreatePassengerSeat()
	

	-- Misc
	self:SetModel( self.Model )	
	self:PhysicsInit( SOLID_VPHYSICS )
	self:SetMoveType( MOVETYPE_VPHYSICS )
	self:SetSolid( SOLID_VPHYSICS )
	
	self:SetNetworkedInt( "health", self.HealthVal )
	self:SetNetworkedInt( "HudOffset", self.CrosshairOffset )
	self:SetNetworkedInt( "MaxHealth", self.InitialHealth )
	self:SetNetworkedInt( "MaxSpeed", self.MaxVelocity )

	--self:SetSkin( math.random( 0, 1 ) )
	self:HelicopterCreateRotors() -- Create the rotor blades
	self:StartMotionController()
	
	-- self:GetPhysicsObject():SetMass( 123456 )
	self:GetPhysicsObject():SetMass( self.Mass or 423456 )
	
	
	if( self.SearchLightPos ) then
		
		self.SearchLight = ents.Create("prop_physics_override")
		self.SearchLight:SetModel( "models/props_wasteland/light_spotlight02_lamp.mdl" )
		self.SearchLight:SetPos( self:LocalToWorld( self.SearchLightPos ) )
		self.SearchLight:SetAngles( self:GetAngles() + self.SearchLightAng )
		-- self.SearchLight:SetParentAttachment(0)
		self.SearchLight:SetParent( self )
		self.SearchLight:Spawn()
		self:DeleteOnRemove( self.SearchLight )
	
		self.SearchLight.Lamp = ents.Create("env_projectedtexture")
		self.SearchLight.Lamp:SetParent( self.SearchLight )        
		self.SearchLight.Lamp:SetPos( self:LocalToWorld( self.SearchLightPos ) )
		self.SearchLight.Lamp:SetLocalAngles( self.SearchLight:GetAngles())
		self.SearchLight.Lamp:SetAngles( self.SearchLight:GetAngles())
		self.SearchLight.Lamp:SetKeyValue( "enableshadows", 1 )
		self.SearchLight.Lamp:SetKeyValue( "farz", 10000 )
		self.SearchLight.Lamp:SetKeyValue( "nearz", 32 )
		self.SearchLight.Lamp:SetKeyValue( "lightfov", 70 )
		self.SearchLight.Lamp:SetKeyValue( "BrightnessScale", 100 )
		self.SearchLight.Lamp:SetKeyValue( "lightcolor", "255 255 255"  ) -- Yellowish to look worn
		self.SearchLight.Lamp:SetKeyValue( "Appearance ", "omomomomomomomomomomomom" ) -- Slight flickering
		self.SearchLight.Lamp:Spawn()
		
		self.HeadLightSprites = ents.Create( "env_sprite" )
		self.HeadLightSprites:SetParent( self.SearchLight )	
		self.HeadLightSprites:SetPos( self:LocalToWorld( self.SearchLightPos ) + self.SearchLight:GetForward()*10 ) -----143.9 -38.4 -82
		self.HeadLightSprites:SetAngles( self.SearchLight:GetAngles() )
		self.HeadLightSprites:SetKeyValue( "spawnflags", 1 )
		self.HeadLightSprites:SetKeyValue( "renderfx", 0 )
		self.HeadLightSprites:SetKeyValue( "scale", 0.4 )
		self.HeadLightSprites:SetKeyValue( "rendermode", 9 )
		self.HeadLightSprites:SetKeyValue( "HDRColorScale", .75 )
		self.HeadLightSprites:SetKeyValue( "GlowProxySize", 2 )
		self.HeadLightSprites:SetKeyValue( "model", "sprites/light_glow02.vmt" )
		self.HeadLightSprites:SetKeyValue( "framerate", "10.0" )
		self.HeadLightSprites:SetKeyValue( "rendercolor", "255 255 255" )
		self.HeadLightSprites:SetKeyValue( "renderamt", 255 )
		self.HeadLightSprites:Spawn()
	
	end
	
end

function Meta:HelicopterDefaultOnRemove()

	self.LoopSound:Stop()
	if self.AlarmSound != NULL then
		self.AlarmSound:Stop()
	end
	
	if( self.RotorPropeller && IsValid( self.RotorPropeller ) ) then
		
		self.RotorPropeller:Remove()
		
	end
	
	if( self.TailPropeller && IsValid( self.TailPropeller ) ) then
		
		self.TailPropeller:Remove()
	
	end
	
	if IsValid( self.Wheels[1] )then	
		for i=1,#self.Wheels do
			if IsValid( self.Wheels[i] ) then
			self.Wheels[i]:Remove()
			end
		end
	end

	if IsValid( self.OtherWheels[1] ) then
		for i=1,#self.OtherWheels do
			if IsValid( self.OtherWheels[i] ) then
			self.OtherWheels[i]:Remove()
			end
		end
	end
	
	if ( IsValid( self.Pilot ) ) then
	
		self:HeloEjectPilotSpecial()
	
	end
	
	if( self.Destroyed ) then
		
		self:DeathFX()
		
		return
		
		
	end
	
end


function Meta:HelicopterDefaultDamageScript( dmginfo )
	
	if ( self.Destroyed ) then 	return end

	if( dmginfo:GetAttacker() == self ) then return end
	if( dmginfo:GetInflictor() == self ) then return end
	
	
	
	self:TakePhysicsDamage(dmginfo)
	self.HealthVal = self.HealthVal - dmginfo:GetDamage()
	
	self:SetNetworkedInt( "health",self.HealthVal )
	
	if( self.HealthVal < 0 ) then
		
		self.Destroyed = true
		self:DeathFX()
		
		return
	
	end
	
	if ( self.HealthVal < self.InitialHealth * 0.2 && !self.Burning ) then
		if self.AlarmSound != NULL then
			self.AlarmSound:PlayEx(511,110)
			self.AlarmSound:SetSoundLevel(511)
		end

		self.Burning = true
		
		local p = {}
		p[1] = self:GetPos() + self:GetForward() * 5 + self:GetRight() * -15 + self:GetUp() * 37
		p[2] = self:GetPos() + self:GetForward() * 5 + self:GetRight() * 15 + self:GetUp() * 37
		for _i=1,2 do
		
			local f = ents.Create("env_fire_trail")
			f:SetPos( p[_i] )
			f:SetParent( self )
			f:Spawn()
			
		end
		
	end
	
	
	local dpos = dmginfo:GetDamagePosition()
	
	if(  IsValid( self.TailPropeller ) && IsValid( self.tailrotoraxis ) ) then
		
		local trp = self.TailPropeller:GetPos()
		
		-- print( ( trp - dpos ):Length() )
		if( dpos:Distance( trp ) < 170 && dmginfo:GetDamage() > 100 ) then
			
			-- print("nothing")
			local f = ents.Create("env_fire_trail")
			f:SetPos( trp )
			f:SetParent( self )
			f:Spawn()
		
			self.tailrotoraxis:Remove()
			
			
			self.TailPropeller:Fire("kill","",3)
			self.TailPropeller:GetPhysicsObject():EnableGravity(true)
			self.TailPropeller:SetSolid( SOLID_VPHYSICS )
			self.TailPropeller:GetPhysicsObject():ApplyForceCenter( self.TailPropeller:GetForward() * 50000 )

			-- self.Burning = true
			-- self.Destroyed = true
			
			return
			
		end
	
	end
	
	if ( IsValid( self.RotorPropeller ) ) then
	
		local rp = self.RotorPropeller:GetPos()
		
		if( dpos:Distance( rp  ) < 50 && dmginfo:GetDamage() > 700 ) then -- Direct blow to the rotor
			
			self:DeathFX()
			
			return
			
		end
	
	end
	
end

function Meta:HelicopterCrash()
	
	if( self.Destroyed ) then
		
		return
		
	end
	
	if( self.LoopSound ) then
	
		self.LoopSound:Stop()
	
	end
	
	if( type( self.RocketVisuals ) == "table" ) then
	
		for k,v in pairs( self.RocketVisuals ) do
			
			if( v && IsValid( v ) && math.random(1,2) == 1 ) then
				
				local oldpos = v:GetPos()
				
				v:SetParent( nil )
				v:SetSolid( SOLID_VPHYSICS )	
				v:Fire("kill","",25)
				
				if( self.HealthVal < self.InitialHealth * 0.25 ) then
					
					v:Ignite(25,25)
				
				end
				
				local p = v:GetPhysicsObject()
				if( p ) then
					
					p:Wake()
					p:EnableGravity( true )
					p:EnableDrag( true )
					
				end
				
				v:SetPos( oldpos )
				
			end
			
		end
		
	end
	
	if( self.rotoraxis && IsValid( self.rotoraxis ) ) then
		
		self.rotoraxis:Remove()
		
	end
	
	if( self.tailrotoraxis && IsValid( self.tailrotoraxis ) ) then
		
		if( math.random( 1,4 ) == 1 ) then
			
			self.tailrotoraxis:Remove()
		
		end
	
	end
	
	if( self.RotorPropeller && IsValid( self.RotorPropeller ) ) then
	
		self.RotorPropeller:GetPhysicsObject():EnableGravity( true )
		-- self.RotorPropeller:SetOwner(NULL)
		self.RotorPropeller:Fire( "kill", "", 5 )
			
		-- bye bye
		self.RotorPhys:ApplyForceCenter( self:GetUp() * ( self.RotorVal * 100 ) + self:GetRight() * ( math.random( -1, 1 ) * ( self.RotorVal * 100 ) ) + self:GetForward() * ( math.random( -1, 1 ) * ( self.RotorVal * 100 ) )  )
		local ra = self.RotorPhys:GetAngles()
		self.RotorPhys:SetAngles( ra + Angle( math.random(-5,5),math.random(-5,5),math.random(-5,5) ) )

	end
	
	if( IsValid( self.TailPropeller ) ) then
		
		self.TailPropeller:GetPhysicsObject():EnableGravity( true )
		-- self.TailPropeller:SetOwner(NULL)
		self.TailPropeller:Fire( "kill", "", 5 )
		
	end
	

	
	if( self.InitialHealth && self.HealthVal && self.HealthVal < self.InitialHealth * 0.5 ) then
			
		self:Ignite( 25, 25 )
		
	end
	
	if( self.LoopSound ) then
	
		self.LoopSound:Stop()
	
	end
	
	if(  self.RotorVal && self.RotorVal > 200 ) then
		
		self:EmitSound("npc/combine_gunship/gunship_explode2.wav",511,125)
	
	end
	
	-- self:Fire( "kill", "", 25 )
	
	self.Destroyed = true
	
	return
	
end

function Meta:DefaultCollisionCallback( data, physobj )
	
	
	if( data.DeltaTime < 0.2 || data.Speed < 200 ) then return end
	
	-- print( data.Speed )
		
	if( self.Destroyed || ( data.Speed > 900 && data.HitWorld ) || !IsValid( self.tailrotoraxis ) ) then
		
		self:DeathFX()
		
		-- self:Remove()
		
		return
		
	end
	
	--print( data, physobj )
	if( self.Burning ) then
		
		-- self:NextThink( CurTime() + 999 )
		if( math.random( 1,2 ) == 1 ) then
		
			self:DeathFX()
		
		end
		
		
		return
		
	end

	
	if ( !data.HitEntity:IsPlayer() && self.IsFlying && data.Speed > self.MaxVelocity * 0.45 && data.DeltaTime > 0.2 ) then 
		
	--	print( "PhysImpact 1 ")
		if( self.HealthVal < self.InitialHealth * 0.2 ) then
		--	print( "PhysImpact 2")
			self:EmitSound("physics/metal/metal_large_debris2.wav",511,100)
			
			if( IsValid( self.ChopperGun ) ) then
			
				self.ChopperGun:EmitSound( "ambient/explosions/explode_3.wav", 511, 100 )
			
			end
			
			local p = self.Pilot
			
			self:HeloEjectPilotSpecial()

			--p:Kill()
			self:DeathFX()
		--	print( "PhysImpact 3 ")
			
			return 
			
		else
			--print( "PhysImpact 4 ")
			self:EmitSound("physics/metal/metal_box_break1.wav", 250, 60 )
		
		end
			
		if ( self:GetVelocity():Length() < self.MaxVelocity * 0.7 ) then
		--	print( "PhysImpact 5 ")
			self.HealthVal = self.HealthVal * ( 0.3 + ( math.random(10,25) / 100 ) )
			self:SetNetworkedInt("health",self.HealthVal)
		
		else
			--print( "PhysImpact 6 ")
			if( !self.Destroyed ) then
				--print( "PhysImpact 7 ")
				self:DeathFX()
				
				return
				
			end
			
		end
		
	end
	
end




function Meta:HelicopterDefaultPhysics( phys, deltatime )

	local a = self:GetAngles()
	local p,r = a.p,a.r
	local stallAng = ( p > 80 || p < -80 || r > 80 || r < -80 )

	self:HelicopterSpinThatThing()
	
	if ( stallAng ) then
		
		self.Speed = self.Speed / 1.15
		
	end
	
	if ( self.IsFlying && self.Started && !self.Destroyed ) then

		phys:Wake()
		self:CreateRotorwash()
		
		if( !IsValid( self.Pilot ) ) then return end
		
		local pilotAng = self.Pilot:GetAimVector():Angle()
		local a = self.Pilot:GetPos() + self.Pilot:GetAimVector() * 3000 + self:GetUp() * 256 -- This is the point the plane is chasing.
		local ta = ( self:GetPos() - a ):Angle()
		local ma = self:GetAngles()
		self.offs = self:VecAngD( ma.y, ta.y )		
		local r = r or 0
		local maxang = 42

		local vel = self:GetVelocity():Length()
		if ( vel > -600 && vel < 600 ) then
			
			self.isHovering = true
			self.BankingFactor = 15
		
		else
		
			self.isHovering = false
			self.BankingFactor = 4
			
		end
	
		if ( self.Pilot:KeyDown( IN_JUMP ) ) then
			
			self.HoverVal = self.HoverVal + 3
			
		elseif ( self.Pilot:KeyDown( IN_DUCK ) ) then
			
			self.HoverVal = self.HoverVal - 3
		
		end
		
		self.HoverVal = math.Clamp( self.HoverVal, -300, 300 )

		local _modifier = -1
		
		if( self.Speed < 0 ) then 
			
			_modifier = 1
			
		end
		
		if( self.offs < -160 || self.offs > 160 ) then
			
			r = 0

		else

			r = ( self.offs / self.BankingFactor ) * _modifier

		end
	
		if ( self:GetVelocity():Length() < 1000 ) then 
		
			if ( self.Pilot:KeyDown( IN_MOVELEFT ) ) then
				
				self.MoveRight = self.MoveRight - 3.5
				r  = -14.5
				
			elseif (  self.Pilot:KeyDown( IN_MOVERIGHT ) ) then
				
				self.MoveRight = self.MoveRight + 3.5
				r = 14.5
				
			else
				
				self.MoveRight = math.Approach( self.MoveRight, 0, 0.995 )
			
			end

			self.MoveRight = math.Clamp( self.MoveRight, -556, 556 )
		
		else
		
			self.MoveRight = math.Approach( self.MoveRight, r * 10, 0.555 )
		
		end
		
		
		if ( self.GotChopperGunner  ) then
			
			if ( pilotAng.p < 5 || pilotAng.p > 300 ) then pilotAng.p = 5 end
			
			if ( self.Pilot:KeyDown( IN_FORWARD ) ) then
			
				pilotAng.p = 8
			
			elseif ( self.Pilot:KeyDown( IN_BACK ) ) then
				
				pilotAng.p = -8	
				
			else
			
				pilotAng.p = math.cos( CurTime() - ( self:EntIndex() * 10 ) ) * 1.25
			
			end
				
			pilotAng.y = ma.y	
			
		end
		
		if ( ma.p > 4 ) then
	
			self.Speed = self.Speed + ma.p / 2.98
		
		elseif ( ma.p < -4 ) then
			
			self.Speed = self.Speed + ma.p / 2.7
		
		elseif ( ma.p > -3 && ma.p < 3 ) then
		
			self.Speed = self.Speed / 1.005
		
		end
		
		if ( self.Pilot:KeyDown( IN_WALK ) || ( !IsValid( self.PassengerSeat:GetDriver() ) && IsValid( self.LaserGuided ) ) ) then
			
			---- Pull up ( or down ) the nose if we're going too fast.
			if( math.floor(self:GetVelocity():Length() / 1.8 ) > 400 && !( self.MoveRight > 500 || self.MoveRight < -500 ) ) then 
			
				if( self.Speed > 0 ) then
					
					pilotAng.p = -15
				
				elseif( self.Speed < 0) then
					
					pilotAng.p = 25
					
				end
				
				self.HoverVal = self.HoverVal / 1.05
				
			else
				
				pilotAng.p = 1.0 + ( math.sin( CurTime() - (self:EntIndex() * 10 ) ) / 2 )
			
			end
			
			self.Speed = self.Speed / 1.0035
		
		end
		
		self.Speed = math.Clamp( self.Speed, self.MinVelocity, self.MaxVelocity )
		
		local pr = {}
		local wind = Vector( math.sin( CurTime() - ( self:EntIndex() * 2 ) ) * 6, math.cos( CurTime() - ( self:EntIndex() * 2 ) ) * 5.8, math.sin( CurTime() - ( self:EntIndex() * 3 ) ) * 7 )
		
		if( self.HealthVal < 400 ) then
		
			local t = t or 0.15
			t = math.Approach( t, 4.5, 0.15 )
			
			wind = Vector( math.sin(CurTime() - ( self:EntIndex()*10) )*38 + math.random(-64,64),math.cos(CurTime() - ( self:EntIndex()*10) )*38 + math.random(-64,64), -0.01 ) 
			pilotAng.y = pilotAng.y + t
			self.HoverVal = self.HoverVal / 2 - 5
			
		end

		pilotAng.p = math.Approach( pilotAng.p, self:GetAngles().p, 0.11 )
		
		local desiredPos = self:GetPos() + self:GetForward() * self.Speed + self:GetUp() * self.HoverVal + self:GetRight() * self.MoveRight + wind
		pr.secondstoarrive	= 1
		pr.pos 				= desiredPos
 		pr.maxangular		= maxang -- 400
		-- pr.maxangulardamp	= 50 -- 10 000
		pr.maxangulardamp	= maxang -- 10 000
		pr.maxspeed			= 1000000
		pr.maxspeeddamp		= 1200
		pr.dampfactor		= 0.8
		pr.teleportdistance	= 10000
		pr.deltatime		= deltatime
		pr.angle = pilotAng + Angle( math.sin(CurTime()*FrameTime())*5, math.cos(CurTime()*FrameTime())*5, r  )
		local velo = self:GetVelocity()
		local vdir = ( self:GetPos() - velo ):GetNormal()
		
		if( !IsValid( self.tailrotoraxis ) ) then
			
			local av = phys:GetAngleVelocity() * 100
			pr.pos = self:GetPos() + ( vdir * self.Speed  ) - Vector( 0,0,math.Clamp( math.abs(self.HoverVal), 150, 250 )  ) + VectorRand() * 32
			pr.angle = phys:GetAngles() + Angle( math.random(-5,5), -200, math.random(-5,5)  )
			pr.maxangular		= 242
			pr.maxangulardamp	= 242
			
		end
		
		if( stallAng ) then
			
			-- print("nope")
			return
			
		end
		
		phys:ComputeShadowControl(pr)
	
	else

		-- if( !IsValid( self.tailrotoraxis ) && self.Started && IsValid( self.rotoraxis ) ) then
			
			-- local a = self:GetAngles()
			-- local pr = {}
			-- local desiredPos = self:GetPos() + self:GetUp() * self.HoverVal + self:GetForward() * self.Speed - Vector( 0,0,55 )
			-- pr.secondstoarrive	= 1
			-- pr.pos 				= desiredPos
			-- pr.maxangular		= 100
			-- pr.maxangulardamp	= 100
			-- pr.maxspeed			= 1000000
			-- pr.maxspeeddamp		= 10000
			-- pr.dampfactor		= 0.8
			-- pr.teleportdistance	= 10000
			-- pr.deltatime		= deltatime
			-- pr.angle = self:GetAngles() + Angle( 0, 155, 0 )
			-- phys:ComputeShadowControl(pr)
	
		-- end
		
		self:RemoveRotorwash()
	
	end

end


print( "[NeuroPlanes] NeuroChopperBase.lua loaded!" )