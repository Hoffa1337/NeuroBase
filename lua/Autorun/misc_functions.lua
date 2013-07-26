local Meta = FindMetaTable("Entity")


function Meta:DrawHUDCircle(center,scale,color) 
//Draw circle whatever the size on the HUD

	local segmentdist = 360 / ( 2 * math.pi * math.max( scale.x, scale.y ) / 2 )
			if(boolean)then
				surface.SetDrawColor( 255, 0, 0,70)
			else
				surface.SetDrawColor( 255, 220, 0,70)
			end
	for i = 0, 360 - segmentdist, segmentdist do
		surface.DrawLine( center.x + math.cos( math.rad( i ) ) * scale.x, center.y - math.sin( math.rad( i ) ) * scale.y, center.x + math.cos( math.rad( i + segmentdist ) ) * scale.x, center.y - math.sin( math.rad( i + segmentdist ) ) * scale.y )
	end
end
