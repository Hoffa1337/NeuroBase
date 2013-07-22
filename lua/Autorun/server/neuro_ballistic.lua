/*********************************************************************/
/* 																	 */
/*  					NeuroTec Ballistic Code						 */
/* 																	 */
/*********************************************************************/

//Some variables we need

local Meta = FindMetaTable("Entity")
local g = 600 //Source engine gravity force
local DefaultMinRange = 2000  //Min range by default
local DefaultMaxRange = 15000  //Max range by default
local DefaultLaunchVelocity = 3000  //The default speed we use for artillery.

/* Description of what we are doing

Target: this the entity you aim (use target designator or something else)
x,y,z position of your target.
x0,y0,z0 your current position.
R: range of your target calculated with the target and your position.
v0: the initial speed of your shell while firing.
h: the difference on z axis = height.
theta: angle of the barrel.
*/


function Meta:BallisticCalculation(Target)
	
	-- local Target = self:GetNetworkedEntity("Target",NULL)

	if !IsValid(Target) then
		-- print("No target")
		return
	else
		
		local pos = self:GetPos()
		local TargetPos = Target:GetPos()
		local R = (TargetPos - pos):Length2D()
		local h = TargetPos.z - pos.z

		-- if self.MaxRange!=NULL then R = self.MaxRange else R = DefaultMaxRange end
		
		if self.MinRange==nil then self.MinRange = DefaultMinRange end
		if self.MaxRange==nil then self.MaxRange = DefaultMaxRange end
			
		if R < self.MinRange then R = self.MinRange end
		if R > self.MaxRange then R = self.MaxRange end
		
	
		-- local v0 = self:CalculateLaunchVelocity(R,h)
		local v0
		if self.LaunchVelocity!=Null or nil then
		-- local v0 = self:GetNetworkedFloat( self.LaunchVelocity , DefaultLaunchVelocity)
		v0 = self.LaunchVelocity else v0 = DefaultLaunchVelocity end
		
		local theta = math.deg(self:CalculateLaunchAngle(R,v0))
		print("R="..R..", v0="..v0..", theta="..theta.."\n")
		
		
	self:SetNetworkedFloat( "LaunchVelocity", v0 )
	self:SetNetworkedFloat( "LaunchAngle", theta )
	end
	return theta

end

function Meta:CalculateLaunchVelocity(R,h)
//Determine the initial velocity for the maximal range.
local theta = 45 //A 45° angle gives you the maximal range.
local v0 = math.sqrt( R * g / math.sin( math.rad(theta) ) )

return v0
end

function Meta:CalculateLaunchAngle(R,v0)

	local theta = 0.5 * math.asin( g * R / (v0*v0) )
	print(90- math.deg(theta))
	local ang
	-- if math.cos(2*theta)>=0 then ang = math.deg(theta)	end
	if (90-math.deg(theta))>=45 and (2*theta<=90) then
		ang = ( 90 - math.deg(theta) )
	else
		ang = self:GetAngles().p
	end
	print("theta generated = "..math.deg(theta).." instead of "..math.deg(ang) )
	
	return math.Round(ang,2)

end

function Meta:CalculateTrajectoryRange(v0,theta)

	local R = v0*v0 * math.sin( math.rad(2*theta) ) / g
		
	return R

end

/*
local function apr(a,b,c)

	local z = math.AngleDifference( b, a )
	return math.Approach( a, a + z, c )
	
end
*/