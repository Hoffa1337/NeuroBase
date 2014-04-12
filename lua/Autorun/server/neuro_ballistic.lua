/*********************************************************************/
/* 																	 */
/*  					NeuroTec Ballistic Code						 */
/* 																	 */
/*********************************************************************/

--Some variables we need

local Meta = FindMetaTable("Entity")
local g = 600 --Default ource engine gravity force.
-- local g = -physenv.GetGravity( ).z --To get the server's gravity force.
local DefaultMinRange = 450  --Min range by default.
local DefaultMaxRange = TANK_RANGE_ARTILLERY_SHELL  --Max range by default.
local DefaultLaunchVelocity = AMMO_VELOCITY_ARTILLERY_SHELL  --The default speed we use for artillery.
local AverageTravellingVelocity = AMMO_VELOCITY_HE_SHELL-- 33500/3 --AMMO_VELOCITY_HE_SHELL  --The default speed we use for common tanks.
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
			
		-- if R*InMeters < self.MinRange then R = self.MinRange/InMeters end
		-- if R*InMeters > self.MaxRange then R = self.MaxRange/InMeters end
	
		
		if( self.TankType == TANK_TYPE_ARTILLERY ) then
			
			if R < self.MinRange then R = self.MaxRange end
			if R > self.MaxRange then R = self.MinRange end
			
		else
			
			if R < self.MinRange then R = self.MinRange end
			if R > self.MaxRange then R = self.MaxRange end
			
		end
		
		if self.Accuracy==nil then self.Accuracy=DefaultAccuracy end
		 self.Accuracy = math.Clamp( self.Accuracy, 0, 100 )
		local speed = DefaultLaunchVelocity
		if( self.AmmoTypes &&  self.AmmoIndex ) then 
			
			speed = TANK_AMMO_SPEEDS[ self.AmmoTypes[ self.AmmoIndex ].Type ]
			if( TANK_AMMO_RANGE[ self.AmmoTypes[self.AmmoIndex ].Type ] ) then
			
				R = TANK_AMMO_RANGE[ self.AmmoTypes[self.AmmoIndex ].Type ]

			end			
			
		end
		local v0 = speed
		-- local v0 = AMMO_VELOCITY_ARTILLERY_SHELL								//Uncomment this line to test the R/C SU-8 artillery.
	
	
	
	local LaunchAngle = -self:CalculateLaunchAngle(R,v0,h, false )

	if( self.TankType == TANK_TYPE_ARTILLERY ) then
	
		local maxpitch = self.MaxBarrelPitch or 60
		-- local highArc = true
		
		if( R >= 6000 ) then 
			
			LaunchAngle = -self:CalculateLaunchAngle(R,v0,h, true )
			
		end
		-- local TooSteep = false
		
		-- if( LaunchAngle < 0 ) then
			-- if( LaunchAngle <= -maxpitch ) then
				-- LaunchAngle = -self:CalculateLaunchAngle(R,v0,h, false )
			-- end
		-- end
		-- print( -maxpitch, LaunchAngle, LaunchAngle > maxpitch  )
		-- if( math.abs(LaunchAngle) >= math.abs(maxpitch)  ) then
			
			-- LaunchAngle = -self:CalculateLaunchAngle(R,v0,h, false )
			
		-- end	
		
	end
	
	self.Owner:SetNetworkedFloat( "LaunchVelocity", v0 )
	self.Owner:SetNetworkedFloat( "LaunchAngle", LaunchAngle )
	
	local R =CalculateTrajectoryRange(v0,LaunchAngle,h)
	self.Owner:SetNetworkedFloat( "Range", R )
	
	-- print( LaunchAngle )
-- print("R="..R..", Height= "..h..", v0="..v0..", Angle="..LaunchAngle.."\n")		

	return LaunchAngle	
end

function Meta:CalculateLaunchAngle(R,v0,h,HighArc)
		
	-- if self.IsArtillery == nil then self.IsArtillery = false end

	local theta,sgn,tan,discriminant

	-- if h<0 then sgn =1 else sgn =1 end //Not sure if the 2nd solution of the equation works properly.
	if ( self.TankType == TANK_TYPE_ARTILLERY && HighArc ) then 
		
		sgn =1 
		
	else 
		
		sgn =-1 
		
	end --//Not sure if the 2nd solution of the equation works properly.

	discriminant = v0*v0*v0*v0-g*(g*R*R+2*h*v0*v0)
	if discriminant < 0 then discriminant = 0 end
	tan = (v0*v0 +sgn*math.sqrt( discriminant ) )/(g*R)
	theta = math.deg( math.atan( tan ) )
-- print("LaunchAngle: "..theta)
	return math.Round(theta,2)

end

function CalculateTrajectoryRange(v0,theta,h)
	
	local cos = math.cos(math.rad(theta))
	local sin = math.sin(math.rad(theta))
	local sgn
	if h>=0 then sgn =1 else sgn =-1 end
	local NewR = v0*cos/g * (v0*sin + sgn*math.sqrt( v0*v0*sin*sin + 2*g*h) )

	return NewR
	-- return v0*v0 * math.sin( math.rad(2*theta) ) / g

end
print( "NeuroTec Ballistics Loaded") 