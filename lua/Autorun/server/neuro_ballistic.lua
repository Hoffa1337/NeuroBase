/*********************************************************************/
/* 																	 */
/*  					NeuroTec Ballistic Code						 */
/* 																	 */
/*********************************************************************/

--Some variables we need

local Meta = FindMetaTable("Entity")
local g = 600 --Default ource engine gravity force.
-- local g = -physenv.GetGravity( ).z --To get the server's gravity force.
local DefaultMinRange = 2000  --Min range by default.
local DefaultMaxRange = 15000  --Max range by default.
local DefaultLaunchVelocity = 3000  --The default speed we use for artillery.
local DefaultAccuracy = 0.85 --It is the default accuracy of the cannon in meters.
local InMeters = 0.3048/16 //This is constant to convert map grid unit to meters.
local InFeet = 1/16 //Constant to get distances from map unit in feet.

/* Description of what we are doing

Target: this the entity you aim (use target designator or something else)
TargetPos: position of your target.
pos: your current position.
R: range of your target calculated with the target and your position.
v0: the initial speed of your shell while firing.
h: the difference on z axis = height.
theta: angle of the barrel.
*/

function Meta:BallisticTargetting(Target) //Use an entity as argument.

	-- local Target = self:GetNetworkedEntity("Target",NULL)
	
	if !IsValid(Target) then
		-- print("No target")
		return
	else
		local TargetPos = Target:GetPos()
		self:BallisticCalculation(TargetPos)
	end
 
end

function Meta:BallisticCalculation(TargetPos) //Use a vector as argument.
		
		local pos = self:GetPos()
		local R = (TargetPos - pos):Length2D()
		local h = (TargetPos.z - pos.z)
				
		if self.MinRange==nil then self.MinRange = DefaultMinRange end
		if self.MaxRange==nil then self.MaxRange = DefaultMaxRange end
			
		if R*InMeters < self.MinRange then R = self.MinRange/InMeters end
		if R*InMeters > self.MaxRange then R = self.MaxRange/InMeters end
		
		if self.Accuracy==nil then self.Accuracy=DefaultAccuracy end
		 self.Accuracy = math.Clamp( self.Accuracy, 0, 100 )
	
		local v0
		if self.LaunchVelocity!=nil then
		--v0 = self:GetNetworkedFloat( self.LaunchVelocity , DefaultLaunchVelocity)
		v0 = self.LaunchVelocity else v0 = DefaultLaunchVelocity
		end
		
		local LaunchAngle = -self:CalculateLaunchAngle(R,v0,h)
				
	self:SetNetworkedFloat( "LaunchVelocity", v0 )
	self:SetNetworkedFloat( "LaunchAngle", LaunchAngle )
-- print("R="..R..", Height= "..h..", v0="..v0..", Angle="..LaunchAngle.."\n")		

	return LaunchAngle	
end

function Meta:CalculateLaunchAngle(R,v0,h)
		
	-- if self.IsArtillery == nil then self.IsArtillery = false end

	local theta
	local sgn
	if h<0 then sgn =1 else sgn =1 end //Not sure if the 2nd solution of the equation works properly.
	
	local tan = (v0*v0 +sgn*math.sqrt( v0*v0*v0*v0-g*(g*R*R+2*h*v0*v0) ) )/(g*R)

	theta = math.atan( tan )

	return math.Round(math.deg(theta),2)

end

function Meta:CalculateTrajectoryRange(v0,theta,h)
	
	local cos = math.cos(math.rad(theta))
	local sin = math.sin(math.rad(theta))
	local sgn
	if h>=0 then sgn =1 else sgn =-1 end
	local NewR = v0*cos/g * (v0*sin + sgn*math.sqrt( v0*v0*sin*sin + 2*g*h) )
		print(NewR)
	return NewR
	-- return v0*v0 * math.sin( math.rad(2*theta) ) / g

end
