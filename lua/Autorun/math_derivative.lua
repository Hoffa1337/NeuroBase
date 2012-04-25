//This can be used to get the derivative from a value.
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
				if (dT != 0) then
					D= math.Round(dA/dT)
				else
					D= 0;
				end		
	return D 

end
