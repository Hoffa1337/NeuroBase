
AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include('shared.lua')

ENT.PrintName	= "Naval AA System"
ENT.Model = "models/combine_helicopter/helicopter_bomb01.mdl"

ENT.InitialHealth = 800
ENT.HealthVal = nil

ENT.Destroyed = false
ENT.Burning = false
ENT.DeathTimer = 0

function ENT:Initialize()
	
	self.HealthVal = self.InitialHealth
	self:SetNetworkedInt( "health",self.HealthVal)
	self.RemoteControl = false
	
	self.LastMortarLaunch = CurTime()
	self.LastShellShower = CurTime()
	self.CannonFlipVal = true
	
	self.Target = NULL
	self.MaxDistance = 9000
	self.LastFlare = 0
	self.LastReminder = 0
	
	self.Armament = {
			
						{ 
							PrintName = "rocketramp",		 							// print name, used by the interface
							Mdl = "models/bf2/weapons/tow/tow_launcher.mdl",  		// model, used when creating the object
							Pos = Vector( -35, 17, 0), 								// Pos, Hard point location on the plane fuselage.
							Ang = Angle( 0, -90, 0 ), 									// Ang, object angle
							Type = "Effect", 										// Type, used when creating the object
							Cooldown = 5, 											// Cooldown between weapons
							isFirst	= nil,											// If a plane got 2 rockets of the same type, set the first rocket to isFirst = true.
							Class = "",
						}; 						
						{ 
							PrintName = "laserpod",		 							// print name, used by the interface
							Mdl = "models/hawx/weapons/an aaq 14 lantirn.mdl",  		// model, used when creating the object
							Pos = Vector( -15, -18, 11.5), 								// Pos, Hard point location on the plane fuselage.
							Ang = Angle( 0, 0, 0), 									// Ang, object angle
							Type = "Effect", 										// Type, used when creating the object
							Cooldown = 5, 											// Cooldown between weapons
							isFirst	= nil,											// If a plane got 2 rockets of the same type, set the first rocket to isFirst = true.
							Class = "",
						}; 					
						{ 
							PrintName = "rocketramp",		 							// print name, used by the interface
							Mdl = "models/jaanus/rpc_launcher.mdl",  		// model, used when creating the object
							Pos = Vector( -35, -18, 0), 								// Pos, Hard point location on the plane fuselage.
							Ang = Angle( 0, 180, 90 ), 									// Ang, object angle
							Type = "Effect", 										// Type, used when creating the object
							Cooldown = 5, 											// Cooldown between weapons
							isFirst	= nil,											// If a plane got 2 rockets of the same type, set the first rocket to isFirst = true.
							Class = "",
						}; 

				}
	
	// Armament
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
		self.RocketVisuals[i].Class = v.Class
		self.RocketVisuals[i]:Spawn()
		self.RocketVisuals[i].LastAttack = CurTime()
		
		if ( v.Damage && v.Radius ) then
			
			self.RocketVisuals[i].Damage = v.Damage
			self.RocketVisuals[i].Radius = v.Radius
		
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

	// Misc
	self:SetModel( self.Model )	
	self:PhysicsInit( SOLID_VPHYSICS )
	self:SetMoveType( MOVETYPE_VPHYSICS )
	self:SetSolid( SOLID_VPHYSICS )

	self.PhysObj = self:GetPhysicsObject()
	
	if ( self.PhysObj:IsValid() ) then
	
		self.PhysObj:Wake()
		self.PhysObj:SetMass( 500 )
		
	end
	
end

function ENT:OnTakeDamage(dmginfo)
	
	local dt = dmginfo:GetDamageType()
	
	if( dt & DMG_BLAST_SURFACE == DMG_BLAST_SURFACE || dt & DMG_BLAST == DMG_BLAST || dt & DMG_BURN == DMG_BURN   ) then 
		// Nothing, these can hurt us
	else
	
		local atk = dmginfo:GetAttacker()
		local infomessage = "This vehicle can only be damaged by armor piercing rounds and explosives!"
		
		if( self.LastReminder + 3 <= CurTime() && atk:IsPlayer() ) then
			
			self.LastReminder = CurTime()
			atk:PrintMessage( HUD_PRINTCENTER, infomessage )

		end
		
		return
		
	end
	
	self:TakePhysicsDamage( dmginfo )
	
	self.HealthVal = self.HealthVal - dmginfo:GetDamage()
	
	self:SetNetworkedInt( "health" , self.HealthVal )
	
	if ( self.HealthVal < 1 ) then
		
		self:ExplosionImproved()
	
		
	end
	
end

function ENT:OnRemove()

end

function ENT:PhysicsCollide( data, physobj )
end


function ENT:Think()
	
	//print( "Destroyed", self.Destroyed )
	

	
	if ( self.Destroyed ) then 
		
		local effectdata = EffectData()
		effectdata:SetOrigin( self:GetPos() + self:GetRight() * math.random(-62,62) + self:GetForward() * math.random(-62,62)  )
		util.Effect( "immolate", effectdata )
		self.DeathTimer = self.DeathTimer + 1
		
		if self.DeathTimer > 100 then
		
			self:Remove()
		
		end
		
		return
		
	end
	
	if( self:WaterLevel() > 1 ) then
		
		return
		
	end
	
	self.Pilot = self.Owner.Pilot

	if( IsValid( self.Pilot ) && !IsValid( self.Target ) && !self.RemoteControl ) then
	
		for k,v in pairs( ents.FindInSphere( self:GetPos(), self.MaxDistance ) ) do
			
			if ( v:IsNPC() || type(v) == "CSENT_vehicle" ) then
			
				if ( v:GetVelocity():Length() > 100 && v:GetPos().z > ( self:GetPos().z + 300 ) ) then
				
					print(v:GetClass())
					if( v:GetPos().z > self:GetPos().z + 256 ) then
					
						self.Target = v
						self:SetNetworkedBool("DrawLaser", true )
						//print( "Target Found", v:GetClass(), v )
						
						return
					
					end
					
				end
				
			end
		
		end
		
	end
	
	if( IsValid( self.Pilot ) ) then
		
		if(  self.Pilot:KeyDown( IN_ATTACK ) && self.LastShellShower + 0.15 <= CurTime() ) then
			
			self:FireFLAK()
			self.LastShellShower = CurTime()
			
		end
		
		if( self.Pilot:KeyDown( IN_WALK ) && self.LastMortarLaunch + 1.0 <= CurTime() ) then
			
			self.LastMortarLaunch = CurTime()
			self:FireMortar()
		
		
		end
		
		if( self.Pilot:KeyDown( IN_JUMP ) && self.LastFlare + 1.15 <= CurTime() ) then
			
			self.LastFlare = CurTime()
			self:ShootFlare()
		
		end
		
		
		if( !IsValid( self.Target ) ) then
			
			local tr, trace = {},{}
			tr.start = self.Pilot:GetPos() + Vector(0,0,72)
			tr.endpos = self.Pilot:GetAimVector() * 25000
			tr.filter = { self, self.Owner, self.Pilot }
			tr.mask = MASK_SOLID
			trace = util.TraceLine( tr ) 
			
			//self:SCUDAim( trace.HitPos )
			self:SetAngles( LerpAngle( 0.1, self:GetAngles(), self.Pilot:EyeAngles() + Angle( 20 - self.Pilot:EyeAngles().p, 180, 0 ) ) )
		
		end
		
	else
	
		self:SetAngles( LerpAngle( 0.01, self:GetAngles(), ( self.Owner:GetAngles() + Angle( 45, 0, 0 ) ) ) )
	
	end
	
	if( IsValid( self.Target ) ) then
		
		self:SetAngles( LerpAngle( 0.25, self:GetAngles(), ( self:GetPos() - ( self.Target:GetPos() + self.Target:GetForward() * self.Target:GetVelocity():Length() ) ):Angle() ) )

		// Attack methods here
		
		local dist = ( self:GetPos() - self.Target:GetPos() ):Length()
		
		if( dist > self.MaxDistance ) then	
				
			self.Target = NULL
			
			return
			
		end
		
		if( self.Target:GetPos().z < self:GetPos().z + 300 ) then
			
			self.Target = NULL
		
			return
			
		end
		
	
		if( self:GetNetworkedBool("DrawLaser", false) ) then
			
			self:SetNetworkedBool("DrawLaser", false )
			
		end
	

	end
	
	self:NextThink(CurTime())
	
	return true
	
end

function ENT:ShootFlare()

	self.CannonFlipVal = !self.CannonFlipVal
	
	local a = 1
	if( self.CannonFlipVal ) then
		
		a = 3
		
	end
	
	local o = self.RocketVisuals[3]
	
	local f = ents.Create("nn_flare")
	f:SetPos( o:GetPos() )
	f:SetAngles( o:GetAngles() + Angle( math.Rand( -2.5, 2.5 ), math.Rand( -2.5, 2.5 ), math.Rand( -2.5, 2.5 ) ) )
	f:Spawn()
	f:SetOwner( self.Owner )
	f:Fire( "kill", "", 3 )
	f:GetPhysicsObject():SetMass( 1000 )
	f:SetVelocity( self:GetVelocity() )
	f:GetPhysicsObject():SetVelocity( o:GetForward() * 4000 )
	
	timer.Simple( math.Rand( 0.25, 2.5 ), 
		function(a,b,c)
		
			if ( IsValid( self ) ) then
			
				for k,v in pairs( ents.GetAll() ) do
				
					local c = v:GetClass()
					
					local logic = ( string.find( c, "rocket" ) != nil ||
									string.find( c, "missile" ) != nil ||
									string.find( c, "rpg" ) != nil ||
									string.find( c, "homing" ) != nil ||
									string.find( c, "heatseek" ) != nil  )
					
					local logic2 = ( v:GetOwner() != self )
					
					if ( logic && logic2 && v:GetPos():Distance( self:GetPos() ) < 5000 ) then
						
						if ( !IsValid( v.Target ) ) then
							
							v:ExplosionImproved()
							v:SetNetworkedEntity("Target", NULL )
							v:Remove()
							
						else
						
							v.Target = r
							
						end
						
					end
					
				end
				
			end
			
		end	)

end

function ENT:FireMortar()

	local shell = ents.Create("sent_np_mortar_shell")
	shell:SetPos( self.RocketVisuals[3]:GetPos() + self.RocketVisuals[3]:GetForward() * 70 )
	shell:SetAngles( self.RocketVisuals[3]:GetAngles() + Angle( math.Rand( -3.55,3.55 ),math.Rand( -3.55,3.55 ),math.Rand( -1.55,1.55 ) ) ) // 01001000 01000001 01010010 01000100 01000011 01001111 01000100 01000101 01000100
	shell:SetOwner( self.Owner )
	shell.Owner = self.Pilot
	shell:Spawn()
	shell:GetPhysicsObject():ApplyForceCenter( shell:GetForward() * math.random( 29000, 37000 ) )
	
	self:EmitSound( "weapons/mortar/mortar_fire1.wav", 511, math.random( 75,80 ) )
	
end

function ENT:FireFLAK()

	self.CannonFlipVal = !self.CannonFlipVal
	
	local a = 1
	if( self.CannonFlipVal ) then
		
		a = 3
		
	end
	
	local shell = ents.Create("sent_AA_flak")
	shell:SetPos( self.RocketVisuals[a]:GetPos() + self.RocketVisuals[3]:GetForward() * 70 )
	shell:SetAngles( self.RocketVisuals[3]:GetAngles() + Angle( math.Rand( -3.55,3.55 ),math.Rand( -3.55,3.55 ),math.Rand( -1.55,1.55 ) ) ) // 01001000 01000001 01010010 01000100 01000011 01001111 01000100 01000101 01000100
	shell:SetOwner( self.Owner )
	shell.Owner = self.Pilot
	shell:Spawn()
	shell:GetPhysicsObject():ApplyForceCenter( shell:GetForward() * 950000 )
	//shell:Ignite( 100, 100 )
		
	for i = 1,5 do

		local sm = EffectData()
		sm:SetStart( self.RocketVisuals[a]:GetPos() + self.RocketVisuals[3]:GetForward() * 55 ) // 68 61 72 64 20 63 6f 64 65 64 20 76 61 6c 75 65 73 20 44 3a
		sm:SetOrigin( self.RocketVisuals[a]:GetPos() + self.RocketVisuals[3]:GetForward() * 55 ) // 3a 62 61 72 66 3a
		sm:SetScale( 6.5 )
		util.Effect( "A10_muzzlesmoke", sm )
			
	end
	
	self:EmitSound( "weapons/mortar/mortar_fire1.wav", 511, math.random(110,117) )
	
end

function ENT:TurretAttack( wep )

 	local bullet = {} 
 	bullet.Num 		= 1
 	bullet.Src 		= wep:GetPos() + self.Weapon:GetForward() * 100
 	bullet.Dir 		= wep:GetAngles():Forward()					// Dir of bullet 
 	bullet.Spread 	= Vector( .019, .019, .019 )				// Aim Cone 
 	bullet.Tracer	= 1											// Show a tracer on every x bullets  
 	bullet.Force	= 0						 					// Amount of force to give to phys objects 
 	bullet.Damage	= 0
 	bullet.AmmoType = "Ar2" 
 	bullet.TracerName 	= "AirboatGunHeavyTracer" 
 	bullet.Callback    = function ( a, b, c )
							
							local e = EffectData()
							e:SetOrigin( b.HitPos )
							e:SetNormal( b.HitNormal )
							e:SetScale( 4.5 )
							util.Effect("HelicopterMegaBomb", e)
						
							util.BlastDamage( self.Owner, self.Owner, b.HitPos, 250, 10 )
							
							return { damage = true, effects = DoDefaultEffect } 
							
						end 
 	
	wep:FireBullets( bullet )
	
	wep:EmitSound( "A10fart.mp3", 510, 98 )
	
	local effectdata = EffectData()
	effectdata:SetStart( wep:GetPos() + self:GetForward() * 80 )
	effectdata:SetOrigin( wep:GetPos() + self:GetForward() * 80 )
	effectdata:SetEntity( wep )
	effectdata:SetNormal( wep:GetForward() )
	util.Effect( "A10_muzzlesmoke", effectdata )  

	self.LastPrimaryAttack = CurTime()
	
end
