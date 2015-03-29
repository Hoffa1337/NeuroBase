
include('shared.lua')
local scale = Vector(0.25, 0.25, 0.25)
local navalViewArea = Material("VGUI/ui/viewconemarker.png" )
function ENT:Initialize()
	local mat = Matrix()
	mat:Scale(scale)
	self:EnableMatrix("RenderMultiply", mat )


end

function ENT:Draw()
		
	if( LocalPlayer() == self:GetOwner() ) then 
	
		local tr,trace = {},{}
		tr.start = self:GetPos() + Vector( 0,0,1555 )
		tr.endpos = tr.start + Vector(0,0,-1555 )
		tr.mask = MASK_WATER 
		tr.filter = { self }
		trace = util.TraceLine( tr )
		local campos = self:GetPos()
			
		campos.z = trace.HitPos.z + trace.HitNormal.z 
				
		cam.Start3D2D( campos,  Angle( 0, self:GetAngles().y, 0 ) , 1 )


			surface.SetDrawColor( Color( 255,255,255,55 ))
			surface.SetMaterial( navalViewArea )
			surface.DrawTexturedRectRotated( 0,0, 64, 64, 0 )


		cam.End3D2D()
		
	end 
	local dist = ( LocalPlayer():GetPos() - self:GetPos() ):Length()
		
	print( dist )
	-- print( math.Clamp(math.floor( 255 * dist/2000  ) ,0,255  ) )
	if( dist < 1020 ) then 
		
		self:SetRenderMode( RENDERMODE_TRANSALPHA )

		self:SetColor( Color( 255,255,255, 255 - ( math.floor(dist/4) ) ) )
		print( self:GetColor() )
	end 
	
	self:DrawModel()
end

function ENT:OnRemove()
end




