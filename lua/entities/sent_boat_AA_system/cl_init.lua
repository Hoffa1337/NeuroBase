include('shared.lua')

function ENT:Initialize()

end

function ENT:Draw()

	local p = LocalPlayer()
	self:DrawModel()
	
	if ( p:GetEyeTrace().Entity == self && EyePos():Distance( self:GetPos() ) < 512 ) then
			
		AddWorldTip(self:EntIndex(),"Health: "..tostring( math.floor( self:GetNetworkedInt( "health" , 0 ) ) ), 0.5, self:GetPos() + Vector(0,0,72), self )
			
	end
	

	local tr, trace = {}, {}
	trace.start = self:GetPos() + self:GetForward() * 500
	trace.endpos = trace.start + self:GetForward() * 35000
	trace.filter = self
	trace.mask = MASK_SOLID
	tr = util.TraceLine( trace )
	
	cam.Start3D( self:GetPos(), self:GetAngles() )
	
		render.SetMaterial( Material("sprites/bluelaser1") )
		render.DrawBeam( self:GetPos(), tr.HitPos, 2, 0, 12.5, Color(255, 0, 0, 255))

		local Size = math.random() * 1.35 
		render.SetMaterial( Material("Sprites/light_glow02_add_noz") )
		render.DrawQuadEasy( tr.HitPos, tr.HitNormal, Size, Size, Color( 255,0,0,255 ), 0 )
		
	cam.End3D()
		

end
