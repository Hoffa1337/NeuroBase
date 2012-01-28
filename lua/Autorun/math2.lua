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

