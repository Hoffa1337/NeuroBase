/*********************************************************************/
/* 																	 */
/*  					NeuroTec Ballistic Code						 */
/* 																	 */
/*********************************************************************/

//Some variables we need

local Meta = FindMetaTable("Entity")
local g = 600 //Source engine gravity force
local DefaultMaxRange = 1000  //Max range by default

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
	print("No target")
	return
	else
	
	
	local pos = self:GetPos()
	local TargetPos = Target:GetPos()
	local R
	if self.MaxRange!=NULL then R = self.MaxRange else R = DefaultMaxRange end
	
	local h = TargetPos.z - pos.z
	
	local v0 = self:LaunchVelocity(R,h)
	local theta = self:LaunchAngle(R,v0)
	end
	
	return theta

end

function Meta:LaunchVelocity(R,h)
//Determine the initial velocity for the maximal range.
local theta = 45 //A 45° angle gives you the maximal range.
local v0 = math.sqrt( R * g / math.sin( math.rad(theta) ) )

return v0
end

function Meta:LaunchAngle(R,v0)

	local theta = 0.5 * math.asin( g * R / (v0*v0) )
	local ang = self:GetAngles().p
	
	if math.cos(2*theta)>=0 then ang = math.deg(theta)	end
	
	return ang

end

local function apr(a,b,c)

	local z = math.AngleDifference( b, a )
	return math.Approach( a, a + z, c )
	
end
