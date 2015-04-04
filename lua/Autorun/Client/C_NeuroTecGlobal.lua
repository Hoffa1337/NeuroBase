-- Global client stuff
local ScrW = ScrW
local ScrH = ScrH
hook.Add("OnEntityCreated", "NeuroTanks_AssignName", function( ent )
	
	if( string.find( ent:GetClass(), "sent_" ) != nil && string.find( ent:GetClass(), "_p" ) != nil && language.GetPhrase( ent:GetClass() ) == ent:GetClass() ) then
		
		timer.Simple( 1, function() if( IsValid( ent ) ) then language.Add( ent:GetClass(), ent.PrintName ) end  end )
		timer.Simple( 1, function() if( IsValid( ent ) && ent.TankType ) then killicon.Add( ent:GetClass(), ent.KillIcon or "TankKillIcon",Color( 255,255,255, 255 ) ) end end )
		-- timer.Simple( 1, function() print( "Translated "..ent:GetClass().." to "..ent.PrintName ) end )
		
	end

end )
local KeyCommands = { KEY_1, KEY_2, KEY_3, KEY_4, KEY_5, KEY_6, KEY_7, KEY_8, KEY_9, KEY_0 }

hook.Add("SetupMove", "NeuroTec_KeybindCallback", function( ply, mv, cmd )
		-- print( ply:IsTyping(), vgui.CursorVisible )
	-- disable keybinds when we got the chatbox open
	if( ply:IsTyping() ) then return end
	-- if( ply.doFLIR == nil ) then ply.doFLIR = false end
	
	if( !ply.LastKeyPress ) then ply.LastKeyPress = CurTime() end

	if( ply.LastKeyPress + 0.5 <= CurTime()  && !vgui.CursorVisible() ) then
		
		if( input.WasKeyTyped( KEY_F )  ) then
			
			ply.LastKeyPress = CurTime()
			ply.doFLIR = !ply.doFLIR
			 
		end
		
		for k,v in ipairs( KeyCommands ) do	
			-- print( v, k )
			
			if( input.WasKeyTyped( v ) ) then
				-- print("pressed "..k )
				ply.LastKeyPress = CurTime()
				ply:ConCommand("neurotec_swapseat "..k )
				
				break
				
			end
			
		end
				
		
	end
	
end ) 

local G_ForceCounter = 0 
local _KeyDownDuration = 0 
local LastVelo = Vector(0,0,0)
local blur = 0 
local addalpha = 0
local delay = 0 
local darkness = 0 

hook.Add("Initialize", "AddNeuroScreenspace", function() 

	function GAMEMODE:RenderScreenspaceEffects()
		local ply = LocalPlayer()
		local plane = ply:GetScriptedVehicle() 
		if( IsValid( plane ) && plane:GetVelocity():Length() > 570 * 1.8 ) then 
				
			-- print("walla")
			local cv = plane:GetVelocity()
			
			if( ply:KeyDown( IN_FORWARD ) || ply:KeyDown( IN_MOVELEFT ) || ply:KeyDown( IN_MOVERIGHT ) || ply:KeyDown( IN_BACK ) ) then
			
				G_ForceCounter = math.Approach( G_ForceCounter, 600, 1 )
			
			else
				
					
				G_ForceCounter = math.Approach( G_ForceCounter, 0, 2 )
			
			
			end 
		else 
			
					
			G_ForceCounter = math.Approach( G_ForceCounter, 0, 2 )
			
			
		end 
								
		
		if( G_ForceCounter > 350 ) then 
			
			blur = math.Approach( blur, 0.1, 0.01 )
			addalpha = math.Approach( addalpha, 0.25, 0.025 )
			darkness = math.Approach( darkness, 255, 0.5 )
			NetworkedScreenRumble( blur, blur )
			-- ply:SetFOV( 55, 5.5 )
			
		else
		
			darkness  = math.Approach( darkness, 0, 1.75 )
			blur = math.Approach( blur, 0, 0.01 )
			addalpha = math.Approach( addalpha, 0, 0.01 )
			-- ply:SetFOV( 90, 5.5 )
			
		end 
		
		surface.SetDrawColor(Color( 0,0,0,darkness) )
		surface.DrawRect( 0, 0,ScrW(),ScrH() ) 
		
		DrawMotionBlur( addalpha, blur, blur)

	end

end ) 

local Meta = FindMetaTable("Entity")

function Meta:DefaultDrawInfo()
	
	self:DrawModel()
	
	local p = LocalPlayer()
	
	local driver = self:GetNetworkedEntity("Pilot", NULL )
	local extra = ""
	local ammo = self:GetNetworkedInt("NeuroTanks_AmmoCount", 0 )
	local fuel = self:GetNetworkedInt("TankMaxFuel", 0 )
	local cfuel = self:GetNetworkedInt( "TankFuel", 0 )
	if( p == driver ) then return end
	
	if( self.Description ) then
		
		extra = self.Description.."\n"
		
	end
		
	if( IsValid( driver ) ) then
		
		extra = tostring(driver:Name().."\n")

	end
	
	if( ammo > 0 ) then
		
		extra = extra.."Ammo: "..ammo.."\n"
		
	end
	
	if( fuel > 0 ) then
		
		extra = extra.."Fuel: "..math.floor( cfuel * 100 / fuel ).."%"
		
	end
	
	if( self.BurstFire ) then
		
		extra = extra.."\n(Burst Fire)"
		
	end
	
	if( self.IsAutoLoader ) then
		
		extra = extra.."\n(Auto Loader)\n"
		
	end
	
	if ( AddWorldTip != nil && p:GetEyeTrace().Entity == self && EyePos():Distance( self:GetPos() ) < 1000 && p != driver ) then
			
		AddWorldTip(self:EntIndex(),self.PrintName.."\n"..extra.."Health: "..tostring( math.floor( self:GetNetworkedInt( "health" , 0 ) ) ), 0.5, self:GetPos() + Vector(0,0,72), self )
			
	end

end