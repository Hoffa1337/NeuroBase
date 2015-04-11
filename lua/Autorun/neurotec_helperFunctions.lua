-- First introducted 11/04/2015 by Smithy285

--[[---------------------------------------------------------------------------
CollatzConjecture & Circle - math2.lua
-----------------------------------------------------------------------------]]
amath = {}

function amath.CollatzConjecture( n ) 
	local num, rem = math.modf( n / 2 ) 
	local r 

	if ( rem == 0 ) then
		r = n / 2
	else 
		r = 3 * n + 1
	end 
	
	return r 
end

function amath.Circle( Pos, Width )
	Pos.x = Pos.x + math.cos( CurTime() ) * Width
	Pos.y = Pos.y + math.sin( CurTime() ) * Width
	
	return Pos
end


--[[---------------------------------------------------------------------------
funcDerivate - math_derivative.lua
-----------------------------------------------------------------------------]]
// This can be used to get the derivative from a value.
local LastT = CurTime()
local LastA = 0

function funcDerivate( value ) 
	local A = value
	local D
	local t = CurTime()
	local dT = t - LastT
	LastT = t
	local dA = A - LastA
	LastA = A

	if ( dT != 0 ) then
		D = math.Round( dA / dT )
	else
		D = 0
	end

	return D
end

--[[---------------------------------------------------------------------------
Explode_Shake - explode_shake.lua
-----------------------------------------------------------------------------]]
function Explode_Shake()
	for _, ply in pairs( player.GetAll() ) do
		found = false
		for k, v in pairs( ents.GetAll() ) do
			if v:GetClass() == "env_explosion" or v:GetClass() == "env_physexplosion" then
				found = true
			end
		end

		if not found then ply.ShakeTime = nil end

		for k, v in pairs( ents.GetAll() ) do
			if ( v:GetClass() == "env_explosion" or v:GetClass() == "env_physexplosion" ) and ply:Alive() then
				if ply.ShakeTime then
					if ply.ShakeTime < ( CurTime() - 1 ) then
						v:Remove()
					end
				else
					ply.ShakeTime = CurTime()
				end

				if ply:GetPos():Distance( v:GetPos() ) <= 250 then
					ply:ViewPunch( Angle( math.random( -10, 10 ), math.random( -10, 10 ), math.random( -10, 10 ) ) )
				elseif ply:GetPos():Distance( v:GetPos() ) <= 500 then
					ply:ViewPunch( Angle( math.random( -5, 5 ), math.random( -5, 5 ), math.random( -5, 5 ) ) )
				elseif ply:GetPos():Distance( v:GetPos() ) <= 750 then
					ply:ViewPunch( Angle( math.random( -1, 1 ), math.random( -1, 1 ), math.random( -1, 1 ) ) )
				end
			end
		end
	end
end
// hook.Add( "Think", "Explode_Shake_Think", Explode_Shake )

--[[---------------------------------------------------------------------------
Revision - !revision.lua
-----------------------------------------------------------------------------]]
function Revision()
	--[[
	return " v1337 gary D: broke mah revision script" end

	local __files, __addons = file.Find("addons/*", "GAME" )

	if( !__addons ) then return "... WAIT!! Why the fuck did you delete your addon folder??" end
	PrintTable( __addons )

	local NeuroplanesFolderName = nil

	for k,v in pairs( __addons ) do
		if( string.find( string.lower(v), "neurobase" ) || string.find( string.lower(v), "nbase") ) then
			NeuroplanesFolderName = v
			print( v )
			break 	
		end
	end

	print( "FOLDER -",NeuroplanesFolderName)

	if( NeuroplanesFolderName ) then
		local svnfile = file.Read("addons/"..string.lower(NeuroplanesFolderName).."/.svn/wc.db", "GAME" )
		print( svnfile )
		if( !svnfile ) then return "Revision not found" end
		
		local idx1,idx2 = string.find( svnfile, "/svn/neurobase/!svn/rvr/" )
		local a,b = string.find( svnfile, "http://svn")
		return string.Replace( string.Replace( string.sub( svnfile, idx2, a ), string.char(10),""), "h", "" )
	end
	--]]

	return "Revision not found"
end


--[[---------------------------------------------------------------------------
COS, SIN, TAN, DrawHUDEllipse, DrawHUDRect & DrawHUDOutlineRect - misc_functions.lua
-----------------------------------------------------------------------------]]
local Meta = FindMetaTable( "Entity" )

function COS( ang )
	return math.cos( ang )
end

function SIN( ang )
	return math.sin( ang )
end

function TAN( ang )
	return math.tan( ang )
end

function DrawHUDEllipse( center, scale, color ) 
	// Draw an ellipse whatever the size of the HUD
	// center: a vector with 0 on z axis (ex: Vector( ScrW()/2,ScrH()/2, 0 )
	// scale : same as center. You can get a circle if x and y axis are equal
	// color : use Color(red,green,blue,alpha) values between 0-255.

	local segmentdist = 360 / ( 2 * math.pi * math.max( scale.x, scale.y ) / 2 )
	surface.SetDrawColor( color )
	for i = 0, 360 - segmentdist, segmentdist do
		surface.DrawLine( center.x + math.cos( math.rad( i ) ) * scale.x, center.y - math.sin( math.rad( i ) ) * scale.y, center.x + math.cos( math.rad( i + segmentdist ) ) * scale.x, center.y - math.sin( math.rad( i + segmentdist ) ) * scale.y )
	end
end


function DrawHUDLine( startpos, endpos, color )
	surface.SetDrawColor( color )
	surface.DrawLine( startpos.x, startpos.y, endpos.x, endpos.y  )
end

function DrawHUDRect( startpos, width, height, color )
	surface.SetDrawColor( color )
	surface.DrawRect( startpos.x, startpos.y, width, height )
end

function DrawHUDOutlineRect( startpos, width, height, color )
	surface.SetDrawColor( color )
	surface.DrawOutlinedRect( startpos.x, startpos.y, width, height )
end
