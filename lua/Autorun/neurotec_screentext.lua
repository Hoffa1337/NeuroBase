if SERVER then 

	util.AddNetworkString("NeuroTec_NetMessage")
	
	local Meta = FindMetaTable("Player")
	
	function Meta:SendScreenMessage( msg, pos, _type )
		
		net.Start("NeuroTec_NetMessage")
			net.WriteString(msg)
			net.WriteVector( pos )
			net.WriteInt( _type, 16 )
		net.Send( self )
	
	end 

end 

-- Clientside stuff
if CLIENT then //end 

net.Receive( "NeuroTec_NetMessage", function( len, pl )
	
	local ply = LocalPlayer()
	local Msg = net.ReadString()
	local Pos = net.ReadVector()
	local Type = net.ReadInt( 16 )
	
	-- HitMarker( msg, Type, pos )
end )

local _hitmarkers = 0 

local function removeHitMarkerHook( id )
	if( _hitmarkers > 0 ) then 
	
		_hitmarkers = _hitmarkers - 1
	
	end 
	
	hook.Remove("HUDPaint", id )
	-- print( "removed hitindicator", _hitmarkers  )
	
end 
function HitMarker( damage )
	_hitmarkers = _hitmarkers + 1
	-- if( _hitmarkers > 33 ) then 
		-- _hitmarkers = 0 
	-- end 
	
	local ply = LocalPlayer()
	local startpos = ply:GetEyeTrace().HitPos
	-- math.randomseed(CurTime()  )
	local endy = math.random( 25,75 ) + ( 10 * _hitmarkers )
	local StartTime = CurTime() 
	local endpos = 0 
	local endx = math.random( -155, 205 )
	local marker = _hitmarkers
	local tits1 = 0 
	local tits2 = 0 
	
	-- local posx = math.random( -1,1 )
	hook.Add("HUDPaint", "_HitIndicator".._hitmarkers, function()
		
		local endTime = CurTime() - StartTime  
		endpos = Lerp( 0.125, endpos, endy )
		
		if( endTime > 1 ) then 
			
			tits1 = math.Approach( tits1, 255, 1 )
			tits2 = math.Approach( tits2, 200, 1 )
			
		end 
		
		local newpos = startpos:ToScreen()
		-- print("newpos", newpos )
		surface.SetFont( "Base03" )
		surface.SetTextColor( 0, 0, 0, 200 - tits2 )
		surface.SetTextPos( newpos.x + endx ,  newpos.y - endpos ) 
		surface.DrawText( damage )
		surface.SetFont( "Base02" )
		if( string.len(damage) > 9 ) then 


			surface.SetTextColor( 25, 255, 25, 255 - tits1 )
			
		else 
		
			surface.SetTextColor( 255, 25, 25, 255 - tits1 )
			
		end 
		
		surface.SetTextPos( newpos.x + endx ,  newpos.y - endpos ) 
		surface.DrawText( damage )
		
		
		-- print( _hitmarkers, endy )
		-- print( "_HitIndicator".._hitmarkers )
		if( endTime > 2  ) then 	
			
		
			removeHitMarkerHook( "_HitIndicator"..marker )
			-- hook.Remove("HUDPaint", "_HitIndicator".._hitmarkers )
			
		end 
		
	end )
	
	
end 

end -- END OF CLIENTSIDE

print( "[NeuroBase] neurotec_screentext.lua loaded!" )