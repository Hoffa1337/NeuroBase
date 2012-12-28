-- Global client stuff
local ScrW = ScrW
local ScrH = ScrH

local Meta = FindMetaTable("Entity")

function Meta:DefaultDrawInfo()
	
	self:DrawModel()
	
	local p = LocalPlayer()
	
	local driver = self:GetNetworkedEntity("Pilot", NULL )
	local extra = ""
	local ammo = self:GetNetworkedInt("NeuroTanks_AmmoCount", 0 )
	local fuel = self:GetNetworkedInt("TankMaxFuel", 0 )
	local cfuel = self:GetNetworkedInt( "TankFuel", 0 )
	
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
		
		extra = extra.."\n(Auto Loader)"
		
	end
	
	if ( AddWorldTip != nil && p:GetEyeTrace().Entity == self && EyePos():Distance( self:GetPos() ) < 1000 && p != driver ) then
			
		AddWorldTip(self:EntIndex(),self.PrintName.."\n"..extra.."Health: "..tostring( math.floor( self:GetNetworkedInt( "health" , 0 ) ) ), 0.5, self:GetPos() + Vector(0,0,72), self )
			
	end

end