-- Global client stuff
local ScrW = ScrW
local ScrH = ScrH

local KeyCommands = { KEY_1, KEY_2, KEY_3, KEY_4, KEY_5, KEY_6, KEY_7, KEY_8, KEY_9, KEY_0 }

hook.Add("SetupMove", "NeuroTec_KeybindCallback", function( ply, mv, cmd )
	
	-- disable keybinds when we got the chatbox open
	if( ply:IsTyping() ) then return end
	
	if( !ply.LastKeyPress ) then ply.LastKeyPress = CurTime() end
	
	if( ply.LastKeyPress + 0.5 <= CurTime() ) then
		
		if( input.WasKeyTyped( KEY_F ) ) then
			
			ply.LastKeyPress = CurTime()
			doFLIR = !doFLIR
			
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