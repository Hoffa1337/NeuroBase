include('shared.lua')

function ENT:Initialize()

	self:SetShouldDrawInViewMode( true )
	self.CamDist = 90
	self.CamUp = 20
	
end

function ENT:CalcView( ply, Origin, Angles, Fov )

	local turret = ply:GetNetworkedEntity("Turret",nil)
	local barrel = ply:GetNetworkedEntity("Barrel",nil)

	local view = {
		origin = Origin,
		angles = Angles
		}

	if( turret && ValidEntity( turret ) && ply:GetNetworkedBool( "InFlight", false )  ) then

		local pos
		
		if( GetConVarNumber("jet_cockpitview") > 0 ) then
				
			pos = turret:LocalToWorld( Vector( -1, 0, 8 ) ) //Origin//
			
		else
			
		pos = turret:GetPos() + turret:GetUp() * self.CamUp + ply:GetAimVector() * -self.CamDist -- + turret:GetForward() * -self.CamDist
		
		end

		local fov = GetConVarNumber("fov_desired")
		local ang,pAng = ply:GetAimVector():Angle(), turret:GetAngles()
		
		--local pos = turret:GetPos() + turret:GetForward() * -350 + turret:GetUp() * 72
		local tAng = turret:GetAngles()
		
		
		view = {
			origin = pos,
			angles = Angle( ang.p, ang.y, 0 ),
			fov = fov
			}

	end

	return view

end

function ENT:Draw()

	local p = LocalPlayer()
	self:DrawModel()
	
	if ( p:GetEyeTrace().Entity == self && EyePos():Distance( self:GetPos() ) < 512 ) then
			
			AddWorldTip(self:EntIndex(),"Health: "..tostring( math.floor( self:GetNetworkedInt( "health" , 0 ) ) ), 0.5, self:GetPos() + Vector(0,0,72), self )
			
	end
	
end
