-- game.AddParticles("particles/vman_explosion.pcf")
-- game.AddParticles("particles/neuro_tank_he.pcf")
-- game.AddParticles("particles/neuro_tank_ap.pcf")
-- game.AddParticles("particles/neuro_ricochet.pcf")

-- language.Add("#spawnmenu.category.tanks", "NeuroTec" )

-- spawnmenu.AddCreationTab( "#spawnmenu.category.tanks", function()

	
-- end,  "icon16/control_repeat_blue.png", 10 )
 

local Meta = FindMetaTable("Entity")
function Meta:NeuroCarsDefaultInit()
	
		
	self:SetShouldDrawInViewMode( true )
	local pos = self:GetPos()
	self.Emitter = ParticleEmitter( pos , false )
	self.SpriteMat = CreateMaterial("tank_headlight_sprite","UnlitGeneric",{
										["$basetexture"] = "sprites/light_glow02",
										["$nocull"] = 1,
										["$additive"] = 1,
										["$vertexalpha"] = 1,
										["$vertexcolor"] = 1,
									})
	self.LeftWheel = self:GetNetworkedEntity("NT_DWheel1", NULL )
	self.RightWheel = self:GetNetworkedEntity("NT_DWheel2", NULL )
	self.TurningValue = 0


end


function Meta:NeuroCarsDefaultDraw()

	
	self:DrawModel()
	
	local DrawHeadlightSprites = self:GetNetworkedBool("Tank_Headlights", false )
	
	if( DrawHeadlightSprites && self.HeadLights != nil ) then
		
		cam.Start3D(EyePos(),EyeAngles())
		
			render.SetMaterial( self.SpriteMat )
			
			for i=1,#self.HeadLights.Pos do
		
				render.DrawSprite( self:LocalToWorld( self.HeadLights.Pos[i] ), 16, 16, Color( 255, 255, 255, 105 ))
		
			end
			
		cam.End3D()
	
	end
	
	
	if( self:GetNetworkedBool("IsStarted", false ) ) then
		-- Exhaust	
		local pos = self.ExhaustPosition or Vector( -98, -5, 51 )
		
			local particle = self.Emitter:Add( "particle/smokesprites_000"..math.random(1,9), self:LocalToWorld( pos ) )

			if ( particle ) then
				
				--particle:SetVelocity( Vector( math.Rand( -1.5,1.5),math.Rand( -1.5,1.5),math.Rand( 2.5,15.5)  ) )
                particle:SetVelocity( self:GetForward() * -10 + self:GetRight() * -25 + self:GetUp() )
				particle:SetDieTime( math.Rand( 4, 6 ) )
				particle:SetStartAlpha( math.Rand( 20, 30 ) )
				particle:SetEndAlpha( 0 )
				particle:SetStartSize( math.Rand( 3, 5 ) )
				particle:SetEndSize( math.Rand( 8, 16 ) )
				particle:SetRoll( math.Rand(0, 360) )
				particle:SetRollDelta( math.Rand(-1, 1) )
				particle:SetColor( math.Rand(35,45), math.Rand(35,45), math.Rand(35,45) ) 
				particle:SetAirResistance( 100 ) 
				particle:SetGravity( VectorRand():GetNormalized()*math.Rand(7, 16)+Vector(0,0,math.Rand(70, 110)) ) 	

			end
	
	end
	
	self:DefaultDrawInfo()
	
end


net.Receive( "NeuroCarsWheels", function( len, pl )
	
	local ply = LocalPlayer()
	local tank = ply:GetScriptedVehicle()
	
	-- print("someobody called?")
	if( IsValid( tank ) && tank.SteerOrder ) then
		
		local expectedSize = #tank.SteerOrder
		local wheel = net.ReadEntity()
		local dir = net.ReadInt( 4 ) or 1-- big data right here
		-- print( dir )
		if( !tank.Wheels ) then
			tank.Wheels = {}
		end
		if( #tank.Wheels < expectedSize ) then
		
			table.insert( tank.Wheels, {  wheel, dir }  )
			
		end
		
		-- print( "Received wheel", #tank.Wheels )
		
	end
	
	
end )

function Meta:DefaultNeuroCarThink()
	
	self.Pilot = self:GetNetworkedEntity( "Pilot", NULL )
	
	-- if( !self.Wheels ) then return end
	if( self.Wheels && IsValid( self.Pilot ) ) then
		-- local started = self:GetNetworkedBool("InFlight", true )
		-- if( !started ) then return end 
		
		local num = #self.Wheels
		for k,v in ipairs( self.Wheels ) do
			
			-- print( v[2] )
			-- print( v[1], v[2] )
			local wheel = v[1]
			local dir = v[2] != 0 && v[2] or 1
			-- print( dir )
			if( IsValid( wheel ) && !wheel:GetNetworkedBool("Disabled",false) ) then
				-- if( !wheel.LastAngle ) then wheel.LastAngle = wheel:GetAngles() end
				local myang = self:GetAngles()
				-- local wa = wheel:GetAngles()
				
				-- wa:RotateAroundAxis( self:GetUp(), -math.AngleDifference( wa.y, myang.y ) )
				-- wheel:SetAngles( wa )
				
				-- local as = self.Entity:GetPhysicsObject():GetAngleVelocity()
				-- print( math.floor( as.x ), math.floor( as.y ), math.floor( as.z ) )
				 -- or self.Pilot:KeyDown( IN_MOVELEFT )  or self.Pilot:KeyDown( IN_MOVERIGHT )
				local l,r,f,b = self:GetNetworkedInt("TurnLeft",false), self:GetNetworkedBool("TurnRight",false), self.Pilot:KeyDown( IN_FORWARD ), self.Pilot:KeyDown( IN_BACK )
				
				-- print( l , r )
				local la = wheel:GetAngles()
				local maxwheelyaw = self.DriveWheelMaxYaw or 45
				local maxdiff = maxwheelyaw - math.Clamp( self:GetVelocity():Length()/13, 0, 20 ) -- not a drift car
				
				if( ( l && f ) || ( r && b ) || ( l && !r && !f && !b ) ) then
				
					self.TurningValue = Lerp( 0.08, self.TurningValue, maxdiff )
					
				elseif( ( r && f ) || ( l && b ) || ( r && !l && !f && !b ) ) then
					
					self.TurningValue = Lerp( 0.08, self.TurningValue, -maxdiff )
				
				else
					
					self.TurningValue = Lerp( 0.15, self.TurningValue, 0 )
					
				end
				
				if( dir > 0 ) then
				
					la:RotateAroundAxis( self:GetUp(),self.TurningValue)
				
				else
				
					la:RotateAroundAxis( self:GetUp(),-self.TurningValue)
				
				end
				
				local wdiff = math.abs( math.AngleDifference( la.y, myang.y ) )
				-- if( dir 
				-- print( math.abs( math.AngleDifference( la.y, myang.y ) ) )
				-- if( wdiff > < maxdiff ) then
					
					wheel:SetAngles( la )
				
				-- end
				-- return
				
			end
			
		end
	-- /*
	else
	
		
		if( !IsValid( self.LeftWheel ) ) then
			
			self.LeftWheel = self:GetNetworkedEntity("NT_DWheel1", NULL )
			
		end
		
		if( !IsValid( self.RightWheel ) ) then
		
			self.RightWheel = self:GetNetworkedEntity("NT_DWheel2", NULL )
			
		end
		

		
		
		if( IsValid( self.LeftWheel ) && IsValid( self.RightWheel ) && IsValid( self.Pilot ) ) then
		
			local l,r,f,b = self.Pilot:KeyDown( IN_MOVELEFT ), self.Pilot:KeyDown( IN_MOVERIGHT ), self.Pilot:KeyDown( IN_FORWARD ), self.Pilot:KeyDown( IN_BACK )
			-- local left,right = , 
			
			local myang = self:GetAngles()
			local la = self.LeftWheel:GetAngles()
			local ra = self.RightWheel:GetAngles()
			local ldiff = math.AngleDifference( myang.y, la.y )
			local rdiff = math.AngleDifference( myang.y, ra.y )
			local maxwheelyaw = self.DriveWheelMaxYaw or 45
			
			local maxdiff = maxwheelyaw - math.Clamp( self:GetVelocity():Length()/12, 0, 25 ) -- not a drift car
			
			-- print("huh")
			if( ( l && f ) || ( r && b ) || ( l && !r && !f && !b ) ) then
			
				self.TurningValue = Lerp( 0.2, self.TurningValue, maxdiff )
				
				-- print("right")
			elseif( ( r && f ) || ( l && b ) || ( r && !l && !f && !b ) ) then
				-- print("left")
				self.TurningValue = Lerp( 0.2, self.TurningValue, -maxdiff )
			
			else
				
				self.TurningValue = Lerp( 0.3, self.TurningValue, 0 )
				
			end
			
			la:RotateAroundAxis( self:GetUp(),self.TurningValue)
			ra:RotateAroundAxis( self:GetUp(), self.TurningValue )
			self.LeftWheel:SetAngles( la )
			self.RightWheel:SetAngles( ra )
			
		end
	
	end
	
end

local IsZoomed = false
local LastZoom = CurTime()

local overlayingpanel
local wheeldirection, wheeldelay = 0, 0




-- hook.Add("PlayerSpawnedSENT", "NeuroTanksAddLanguage", function( ply, ent ) 
	
	-- if( ent.FolderName && ent.PrintName ) then
			
		-- language.Add( ent.FolderName, ent.PrintName )
		
		-- print( "Added Language for "..ent.FolderName.." as "..ent.PrintName )
	-- end


-- end )

hook.Add("AdjustMouseSensitivity", "NeuroTanksAdjustSensitivity", function(default_sensitivity)
	
	
	local ply = LocalPlayer()
	local tank = ply:GetScriptedVehicle()
	
	if( tank.VehicleType && ( tank.VehicleType == VEHICLE_TANK || tank.VehicleType == STATIC_GUN ) ) then
		
		local thirdperson = tank.MouseScale3rdPerson or 0.295
		local firstperson = tank.MouseScale1stPerson or 0.15
		
		if( GetConVarNumber("sensitivity", 0 ) > 15 ) then
			
			thirdperson = thirdperson / GetConVarNumber("sensitivity", 0 ) 
			firstperson = firstperson / GetConVarNumber("sensitivity", 0 ) 
		
		end
		
		if( GetConVarNumber( "jet_cockpitview", 0 ) > 0 ) then
			
			return firstperson
			
		else
		
			return thirdperson
			
		end
	
	end
	
    return -1
	
end)

-- NEUROTANKS_DO_RECOIL = false

-- if( !SinglePlayer( ) ) then

	-- local function ReadRecoilData( data )
		
		-- if( data:ReadBool() ) then
			
			-- NEUROTANKS_DO_RECOIL = true
			
		-- end
		
	-- end
	-- usermessage.Hook( "NeuroTanks_SendRecoil", ReadRecoilData );


-- end



local linearp = 0
function ScreenToVector( sX, sY, sW, sH, ang, fov )
	local d = 4 * sH / ( 6 * math.tan( 0.5 * fov ) )
	local vF = ang:Forward()
	local vR = ang:Right()
	local vU = ang:Up()			
	return ( d * vF + ( sX - 0.5 * sW ) * vR + ( 0.5 * sH - sY ) * vU ):GetNormalized()
end		

if( table.HasValue( hook.GetTable(), "MouseWheelHook" ) ) then
	
	hook.Remove("Think", "MouseWheelHook" )
end
 
hook.Add("Think", "MouseWheelHook", function()
	-- if( 
	if wheeldirection == 0 then return end
	wheeldelay = wheeldelay - 1
	if wheeldelay < 0 then wheeldelay = 0 end
	if wheeldelay == 0 then wheeldirection = 0 end
	
 
end )

-- timer.Create('mousewheeloverlay',1/5,0,function()

-- end)
local oldinputismousedown = input.IsMouseDown
local ScrollDelta = 0
function input.IsMouseDown(enum)
	if enum == MOUSE_WHEEL_DOWN || enum == MOUSE_WHEEL_UP then
		if enum == MOUSE_WHEEL_DOWN then --old code dont ask why this isnt shortened, i don't remmeber
			-- print("test")
			if wheeldirection < 0 then return true end
		else
			if wheeldirection > 0 then return true end
		end
		return false
	else
		return oldinputismousedown(enum)
	end
end 
local _count = 0;

local dirs = { Vector( 2000, 0, 0 ), Vector( 0, 2000, 0 ), Vector( 0, 0, 700 ) };


local function IsSafeVector( pos ) 

	local safe = pos
	
	for k,v in pairs( dirs ) do
		
		local tr,trace = {},{}
		tr.start = pos + v
		tr.endpos = pos - v	
		-- tr.mask = MASK_SOLID
		trace = util.TraceLine( tr )
		if( trace.Hit ) then
			
			safe = trace.HitPos

			-- print( "bad camera pos" )
			break
			
		end
		
	end
	
	return safe
	
end

local MouseClicker = false





function TankDefaultCalcView( ply, Origin, Angles, Fov, ent )
	
	if( !IsValid( ent ) ) then return end
	-- print( type(ply),type(Origin),type(Angles),type(Fov), type( ent ) )
	-- if true then return false end
	
	local tank = ply:GetScriptedVehicle()
	local barrel = ply:GetNetworkedEntity("Barrel",NULL)
	local fov = GetConVarNumber("fov_desired")
	if( !ply.LastMousePosNetSync ) then
		
		ply.LastMousePosNetSync = CurTime()
		
	end
	local view = {
		origin = Origin,
		angles = Angles
		}

	if( IsValid( tank ) && ply:GetNetworkedBool( "InFlight", false )  ) then
			

		if( !tank._3DCameraPosition ) then
			
			tank._3DCameraPosition = tank:GetPos()
			-- tank._3DCameraBuildUp = 0
			
		end
		
		if( GetConVarNumber("tank_wotstyle") > 0 && tank.ArtyView && GetConVarNumber("jet_cockpitview") == 1  ) then

				--- dont do like afto and create a DFrame each frame..
				if( overlayingpanel == nil ) then
	
					overlayingpanel = vgui.Create('DFrame')
					overlayingpanel.Tank = tank
					overlayingpanel:SetSize(ScrW()+100,ScrH()+100)
					overlayingpanel:SetPos(-50,-50)
					overlayingpanel:SetAlpha(0)
					overlayingpanel.OnMouseWheeled = function(panel, mc)
						wheeldirection = mc
						wheeldelay = 1
				
					end
					-- local overlayingpanel.oldpaint = overlayingpanel.Paint
					-- overlayingpanel.Paint = function()
					
						
						-- overlayingpanel.oldpaint()
						
					-- end 
					
					overlayingpanel.OnMousePressed = function(panel, mc)
						
						if( !IsValid( LocalPlayer():GetScriptedVehicle() ) ) then 	
						
							gui.EnableScreenClicker( false ) 
							overlayingpanel:Remove()
							timer.Simple( 0, function() 
								
								RunConsoleCommand("-attack")
								RunConsoleCommand("-attack2")
								
								return 
								
							end ) 
							
						end 
						
						if( mc == MOUSE_LEFT ) then
							
							RunConsoleCommand("+attack")
							
						elseif( mc == MOUSE_RIGHT ) then
							
							RunConsoleCommand("+attack2")
						
						end 
						
					end
					overlayingpanel.OnMouseReleased = function(panel, mc)

						RunConsoleCommand("-attack")
						RunConsoleCommand("-attack2")
						
					end
					
					 
				end 

				if( !ply.TankCamPos ) then
				
					ply.TankCamPos = Vector(0,0,500)
					
				end

				gui.EnableScreenClicker( true  )
		
			
				local x,y = gui.MousePos()
				local midx = ScrW()/2
				local midy = ScrH()/2
				local midposx = Vector( midx, 0, 0 )
				local midposy = Vector( 0, midy, 0 )
				local mouseposx = Vector( x, 0, 0 )
				local mouseposy = Vector( 0,y, 0 )
				local left = x <= midx
				local right = x > midx
				local down = y >= midy
				local up = y < midy 
				local speedy = math.floor(( mouseposx - midposx ):Length()/300)
				local speedx = math.floor(( mouseposy - midposy ):Length()/300)
				local lowz = ( tank:GetPos() + Vector( 0,0,300 ) ).z
				local lasttankcam = ply.TankCamPos
				local mz = tank:GetPos()
				local zdist = math.Clamp( ( ( mz.z + ply.TankCamPos.z + 700) - mz.z )/100, 0, 100 )*1.5
				-- print( zdist )
				--  12262.1875
 
				local cammult = zdist 
				if( up ) then 
					ply.TankCamPos.x = ply.TankCamPos.x + speedx*cammult
				elseif( down ) then
					ply.TankCamPos.x = ply.TankCamPos.x - speedx*cammult
				end
				if( left ) then
					ply.TankCamPos.y = ply.TankCamPos.y + speedy*cammult
				elseif( right ) then
					ply.TankCamPos.y = ply.TankCamPos.y - speedy*cammult
				end
				
				local newZ = Lerp( 0.3, ply.TankCamPos.z, ply.TankCamPos.z + (-wheeldirection*2000) )
				ply.TankCamPos.z = newZ
				-- if( util.IsInWorld( targetpos ) ) then 
				
					targetpos = LerpVector( 0.5, Origin, tank:GetPos() + ply.TankCamPos + Vector( 0, 0, 700 ) )
				
				-- end 
				
				local vec = ScreenToVector(x, y, ScrW(), ScrH(), Angle( 65, 0, 0 ), 89.54) -- I hate myself for doing that.
				local realVec = targetpos + (vec*999999)
				local tr, trace = {},{}
				tr.start = targetpos
				tr.endpos = realVec
				tr.filter = tank
				trace = util.TraceLine( tr ) 

				ply.ImpactPosition = trace.HitPos
				if(  ply.LastMousePosNetSync + 0.2 <= CurTime() ) then
					 
					ply.LastMousePosNetSync = CurTime()
					SendMousePosToServer( trace.HitPos  )			
			
				end
				-- local orig = view.origin
				view = {
				origin = targetpos,
				angles = Angle( 65, 0, 0 ),
				fov = fov			
				}
 
			return view
			
		else
		
			-- if( overlayingpanel ) then
			
				-- overlayingpanel:Remove()
				
			-- end
			-- print("nope")
			ply.TankCamPos = Vector( 0, 0,1000 )
			gui.EnableScreenClicker( false  )
			if( ply.LastMousePosNetSync && ply.LastMousePosNetSync + 0.5 <= CurTime() ) then
				 
				ply.LastMousePosNetSync = CurTime()
				SendMousePosToServer( Vector(0,0,0)  )			
		
			end
			
		end
		
		local ang,pAng,bAng = ply:GetAimVector():Angle(), tank:GetAngles(), barrel:GetAngles()
		
		local pos
		
		if( GetConVarNumber("jet_cockpitview") > 0 ) then
			
			if( GetConVarNumber( "tank_wotstyle", 0 ) > 0 ) then
				
				-- local tr,trace = {},{}
				-- tr.start = ply:GetPos() + ply:GetUp() * 250
				-- tr.endpos = ply:GetPos()
				-- tr.mask = MASK_SOLID
				-- trace = util.TraceLine( tr )
				-- if( !tank.WoTLookOutPos ) then
					-- tank.WoTLookOutPos = tank:WorldToLocal( trace.HitPos + trace.HitNormal*42 )--tank:GetPos() + tank:GetRight() * 32 + Vector( 0,0,72 )
				-- end	
				 
				-- pos = tank:LocalToWorld( tank.WoTLookOutPos )
				if( tank.CamLocalToTank ) then
					
					pos = tank:LocalToWorld( ent.CockpitPosition )
				
				else
				
					pos = barrel:LocalToWorld( ent.CockpitPosition )
				
				end
				ang = ang -- Angle( ang.p, bAng.y, ang.r )
				
				
			else
				
				pos = barrel:LocalToWorld( ent.CockpitPosition )
				ang = bAng
				
			end
			
			
		else
			
			local camdist = math.Clamp( GetConVarNumber("tank_camdistance",0 ), 0, 200 )
			
			linearp = Lerp( 0.11, linearp, math.floor( ent:GetVelocity():Length()/15 ) ) + camdist
			
			-- print( linearp )
			local newpos = ent:GetPos() + ent:GetUp() * (ent.CamUp+(camdist*2)) + ply:GetAimVector() * -(ent.CamDist+linearp)
			
			-- local endpoint = newpos
			
			if ( ent.CameraChaseTower ) then
					
				newpos = barrel:GetPos() + tank:GetUp() * ( ent.CamUp + camdist*2 ) + ply:GetAimVector() * -( ent.CamDist+linearp )
					
			end
		
			local tr, trace = {},{}
			tr.start = ent:GetPos() + ent:GetUp() * 200
			tr.endpos = newpos
			tr.filter = { ent, ply, tank, barrel }
			tr.mask = MASK_SOLID_BRUSHONLY
			trace = util.TraceLine( tr )
			
			local height = 170+camdist*2
			
			newpos = trace.HitPos + trace.HitNormal * 8
			
			if( newpos.z < ent:GetPos().z + height ) then newpos.z = ent:GetPos().z + height end
			
			pos = newpos--LerpVector( 0.93, Origin, newpos  ) + tank:GetRight() * 25
		
		end

		-- local SVehicle = ply:GetScriptedVehicle()
		--print( SVehicle )
	
			if( ply:KeyDown( IN_WALK ) && !ply:KeyDown( IN_DUCK ) ) then
				
				-- if( GetConVarNumber("jet_cockpitview") > 0  ) then
					
					if( GetConVarNumber( "tank_wotstyle", 0 ) > 0 ) then
					
						fov = 15	
						-- ang.p = ang.p - 4
						
					else
					
						fov = 20
						
					end
					-- ang = pAng
					
				-- else
					
					-- if( ent.HasStaticSecondaryGuns ) then
					
						-- pos = tank:LocalToWorld( ent.StaticGunPositions[1] + tank:GetUp() * 16 )
						-- ang.y = ang.y + ent.StaticGunAngles[1].y
						
					-- end
					
				-- end
			
			end
			
			

		
		local tAng = tank:GetAngles()
		
		-- local Shell = tank:GetNetworkedEntity("NeuroTanksCameraShell", NULL )
		-- if( IsValid( Shell ) ) then
			
			-- pos = Shell:GetPos() + Shell:GetForward() * -92
			-- ang = Shell:GetAngles()
		
		-- end
		
		-- if( !SinglePlayer() ) then
			
			-- if( NEUROTANKS_DO_RECOIL ) then
				
				-- ang = ang + Angle( math.Rand( 1.1, 3.9 ),math.Rand( -.5, .5 ),math.Rand( -.9, .9 ) ) * ent.TankType / 2
				-- pos = pos + Vector( math.Rand( -5,5 ),math.Rand( -5,5 ),math.Rand( -5,5 ) )
				
				-- NEUROTANKS_DO_RECOIL = false
				
			-- end
		
		-- end
		-- tank._3DCameraBuildUp = Lerp( 0.01, _3DCameraBuildUp, 0.7 )
		tank._3DCameraPosition = LerpVector( 0.99, tank._3DCameraPosition, pos )
		
		if( GetConVarNumber("tank_artillery_killcam", 0 ) > 0 ) then
		
			local Shell = ply:GetNetworkedEntity("ArtilleryShell", NULL )
			if( IsValid( Shell ) ) then
				
				pos = Shell:GetPos() 
				tank.ShellLastPos = Shell:GetPos()
				tank.ShellLastAlive = CurTime()
				
			else
				
				if( tank.ShellLastPos && tank.ShellLastAlive + 3 >= CurTime() ) then
						
					pos = tank.ShellLastPos
					
				elseif( tank.ShellLastPos && tank.ShellLastAlive + 3 < CurTime() ) then
				
					tank.ShelLastPos = nil
					-- self.ShellLastAlive = nil
					
				end
				
				
			end
			
		end
		
		local atgm = tank:GetNetworkedEntity("ATGM_projectile",NULL)
		if( IsValid( atgm ) && inLOS( barrel, atgm ) ) then
			
			tank._3DCameraPosition = atgm:GetPos() + atgm:GetForward() * 32 
			ang = atgm:GetAngles()
			
		end
		
		local _newang = Angle( Angles.p, Angles.y, 0 )
		if( GetConVarNumber("jet_cockpitview",0 ) == 1 ) then
			_newang = Angle( ang.p, ang.y, ang.r/1.25 )
		end
		
		
		view = {
			origin = tank._3DCameraPosition,
			angles = _newang,--Angle( Angles.p, ang.y, 0 )
			fov = fov
			}
	else
		
		gui.EnableScreenClicker( false  )
		if( overlayingpanel ) then 
		
			overlayingpanel:Remove()
		
		end 
		
	end
	
	return view


end

function Meta:TankDefaultCalcView( ply, Origin, Angles, Fov )

	local tank = ply:GetNetworkedEntity("Tank", NULL )
	local barrel = ply:GetNetworkedEntity("Barrel",NULL)

	local view = {
		origin = Origin,
		angles = Angles
		}

	if( IsValid( tank ) && ply:GetNetworkedBool( "InFlight", false )  ) then

		local fov = GetConVarNumber("fov_desired")
		local ang,pAng,bAng = ply:GetAimVector():Angle(), tank:GetAngles(), barrel:GetAngles()
		
		local pos
		
		if( GetConVarNumber("jet_cockpitview") > 0 ) then
				
			pos = barrel:LocalToWorld( self.CockpitPosition )
			ang = bAng
			
		else
			
			pos = tank:GetPos() + tank:GetUp() * self.CamUp + ply:GetAimVector() * -self.CamDist
		
		end
		
		local SVehicle = ply:GetScriptedVehicle()
		--print( SVehicle )
		if( GetConVarNumber("jet_cockpitview") > 0  ) then
			
			if( ply:KeyDown( IN_WALK ) || ( IsValid( SVehicle ) && SVehicle.HasMGun == false && ply:KeyDown( IN_ATTACK2 ) ) ) then
			
				fov = 20
		
			end
			
		else
			
			fov = GetConVarNumber("fov_desired")
		
		end
		
		local tAng = tank:GetAngles()
		

		local _newang =  Angle( Angles.p, ang.y, 0)
		
		if( GetConVarNumber("jet_cockpitview",0) == 1 ) then
			
			_newang = Angle( ang.p, ang.y, ang.r / 1.2 )
			 
		end
		
		view = {
			origin = pos,
			angles = _newang,
			fov = fov
			}

	end

	return view


end

function Meta:TankDefaultDrawStuff()

	-- if( !self.CrewFaces ) then
		-- self.CrewFaces = 
		-- { 
			-- { Material( tostring( FacePath..faces[math.random(1,50)])), TankDriver },
			-- { Material( tostring( FacePath..faces[math.random(151,206)])), TankLoader },
			-- { Material( tostring( FacePath..faces[math.random(101, 150)])), TankCommander },
			-- { Material( tostring( FacePath..faces[math.random(51,100)])), TankGunner }
			
		-- }
		
	-- end
	
	if( self.ExhaustPosition && self:GetNetworkedBool("IsStarted", false ) ) then
	
		-- Exhaust
		local particle = self.Emitter:Add( "particle/smokesprites_000"..math.random(1,9), self:LocalToWorld( self.ExhaustPosition ) )
	
		if ( particle ) then
			
			particle:SetVelocity( Vector( math.Rand( -1.5,1.5),math.Rand( -1.5,1.5),math.Rand( 2.5,15.5)  ) )
			particle:SetDieTime( math.Rand( 3, 5 ) )
			particle:SetStartAlpha( math.Rand( 20, 30 ) )
			particle:SetEndAlpha( 0 )
			particle:SetStartSize( math.Rand( 2, 4 ) )
			particle:SetEndSize( math.Rand( 6, 11 ) )
			particle:SetRoll( math.Rand(0, 360) )
			particle:SetRollDelta( math.Rand(-1, 1) )
			particle:SetColor( math.Rand(35,45), math.Rand(35,45), math.Rand(35,45) ) 
			particle:SetAirResistance( 100 ) 
			particle:SetGravity( VectorRand():GetNormalized()*math.Rand(5, 11)+Vector(0,0,math.Rand(60, 90)) ) 	

		end
		
	end
	
end

print( "[NeuroTanks] NeuroTanksDrawFunctions.lua loaded!" )