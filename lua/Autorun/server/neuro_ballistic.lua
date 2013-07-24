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
local DefaultAccuracy = 85 --It is the default accuracy of the cannon in percent regarding the range.
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
		local h = (TargetPos.z - pos.z)
		
		-- if self.MaxRange!=NULL then R = self.MaxRange else R = DefaultMaxRange end
		
		if self.MinRange==nil then self.MinRange = DefaultMinRange end
		if self.MaxRange==nil then self.MaxRange = DefaultMaxRange end
			
		if R < self.MinRange then R = self.MinRange end
		if R > self.MaxRange then R = self.MaxRange end
		
		if self.Accuracy==nil then self.Accuracy=DefaultAccuracy end
		 self.Accuracy = math.Clamp( self.Accuracy, 0, 100 )
	
		-- local v0 = self:CalculateLaunchVelocity(R,h)
		local v0

		if self.LaunchVelocity!=nil then

		-- local v0 = self:GetNetworkedFloat( self.LaunchVelocity , DefaultLaunchVelocity)
		v0 = self.LaunchVelocity else v0 = DefaultLaunchVelocity end
		
		local theta = -self:CalculateLaunchAngle(R,v0,h)
		-- local offset = self:CalculateHeightOffset(R,v0,h)

		-- local LaunchAngle = -self:CalculateLaunchAngle(self:CalculateTrajectoryRange(v0,theta,h),v0,h )	
		local LaunchAngle = theta
				
print("R="..R..", height= "..h..", v0="..v0..", theta="..theta.."\n")		
	self:SetNetworkedFloat( "LaunchVelocity", v0 )
	self:SetNetworkedFloat( "LaunchAngle", theta )
	end
	return LaunchAngle

end

function Meta:CalculateLaunchVelocity(R,h)
----Determine the initial velocity for the maximal range.
local theta = 45 --A 45° angle gives you the maximal range.

return math.sqrt( R * g / math.sin( math.rad(theta) ) )
end

function Meta:CalculateLaunchAngle(R,v0,h)

	local theta
	local sgn
	if h<0 then sgn =1 else sgn =-1 end
	
	local tan = (v0*v0 +sgn*math.sqrt( v0*v0*v0*v0-g*(g*R*R+2*h*v0*v0) ) )/(g*R)

	theta = math.atan( tan )

	-- local theta = 0.5 * math.asin( g * R / (v0*v0) )
	-- local ang
	-- if (90-math.deg(theta))>=45 and (2*theta<=90) then
		-- ang = ( 90 - math.deg(theta) )
	-- else
		-- ang = self:GetAngles().p
	-- end
		-- ang = math.deg(theta) 
	-- return math.Round(ang,2)
	return math.Round(math.deg(theta),2)

end

function Meta:CalculateTrajectoryRange(v0,theta,h)

	-- local R = v0*v0 * math.sin( math.rad(2*theta) ) / g
	
	local cos = math.cos(math.rad(theta))
	local sin = math.sin(math.rad(theta))
	local sgn
	if h>=0 then sgn =1 else sgn =-1 end
	local NewR = v0*cos/g * (v0*sin + sgn*math.sqrt( v0*v0*sin*sin + 2*g*h) )
		print(NewR)
	return NewR
	-- return v0*v0 * math.sin( math.rad(2*theta) ) / g

end

function Meta:CalculateHeightOffset(R,theta,v0,h)

	local cos = math.cos(math.rad(theta))
	local sin = math.sin(math.rad(theta))
		
	-- local offset = v0*v0*cos/g * math.sqrt( v0*v0*sin*sin + 2*g*h) --Attempt to get the correction.
	local offset = math.random(-10,10)*R/100 --You will reach your target if you are lucky! 80%
	return 	offset 

end

/**Vector method**/
function Meta:BallisticCalculationV(TargetPos)
	
		local pos = self:GetPos()
		local R = (TargetPos - pos):Length2D()
		local h = TargetPos.z - pos.z
		
		-- if self.MaxRange!=NULL then R = self.MaxRange else R = DefaultMaxRange end
		
		if self.MinRange==nil then self.MinRange = DefaultMinRange end
		if self.MaxRange==nil then self.MaxRange = DefaultMaxRange end
			
		if R < self.MinRange then R = self.MinRange end
		if R > self.MaxRange then R = self.MaxRange end
		
		if self.Accuracy==nil then self.Accuracy=DefaultAccuracy end
		 self.Accuracy = math.Clamp( self.Accuracy, 0, 100 )
	
		-- local v0 = self:CalculateLaunchVelocity(R,h)
		local v0
		if self.LaunchVelocity!=NULL or nil then
		-- local v0 = self:GetNetworkedFloat( self.LaunchVelocity , DefaultLaunchVelocity)
		v0 = self.LaunchVelocity else v0 = DefaultLaunchVelocity end
		
		local theta = -self:CalculateLaunchAngle(R,v0,h)
		-- local offset = self:CalculateHeightOffset(R,v0,h)

		-- local LaunchAngle = -self:CalculateLaunchAngle(self:CalculateTrajectoryRange(v0,theta,h),v0,h )	
		local LaunchAngle = theta
				
-- print("R="..R..", height= "..h..", v0="..v0..", theta="..theta.."\n")		
	self:SetNetworkedFloat( "LaunchVelocity", v0 )
	self:SetNetworkedFloat( "LaunchAngle", theta )
	
	return LaunchAngle

end