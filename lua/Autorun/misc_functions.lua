local Meta = FindMetaTable("Entity")


function DrawHUDEllipse(center,scale,color) 
//
/****************************************************************************/
/* Draw an ellipse whatever the size of the HUD							 	*/
/* center: a vector with 0 on z axis (ex: Vecctor( ScrW()/2,ScrH()/2, 0 )	*/
/* scale : same as center. You can get a circle if x and y axis are equal	*/
/* color : use Color(red,green,blue,alpha) values between 0-255.			*/
/****************************************************************************/


	local segmentdist = 360 / ( 2 * math.pi * math.max( scale.x, scale.y ) / 2 )
	surface.SetDrawColor( color )
	for i = 0, 360 - segmentdist, segmentdist do
		surface.DrawLine( center.x + math.cos( math.rad( i ) ) * scale.x, center.y - math.sin( math.rad( i ) ) * scale.y, center.x + math.cos( math.rad( i + segmentdist ) ) * scale.x, center.y - math.sin( math.rad( i + segmentdist ) ) * scale.y )
	end
end


function DrawHUDLine(startpos,endpos,color)
	surface.SetDrawColor( color )
	surface.DrawLine( startpos.x, startpos.y, endpos.x, endpos.y  )

end