

local matRefraction	= Material( "refract_ring" )

/*---------------------------------------------------------
   Initializes the effect. The data is a table of data
   which was passed from the server.
---------------------------------------------------------*/
function EFFECT:Init( data )

	self.Magnitude = data:GetMagnitude()
	self.Scale = data:GetScale()

	self.Refract = 0

	self.Size = 16 * self.Magnitude

	self.Entity:SetRenderBounds( Vector()*-256, Vector()*256 )

end


/*---------------------------------------------------------
   THINK
   Returning false makes the entity die
---------------------------------------------------------*/
function EFFECT:Think( )

	self.Refract = self.Refract + self.Scale * FrameTime()
	self.Size = 256 * self.Refract^(0.2)

	if ( self.Refract >= 1 ) then return false end

	return true

end


/*---------------------------------------------------------
   Draw the effect
---------------------------------------------------------*/
function EFFECT:Render()

	local Distance = EyePos():Distance( self.Entity:GetPos() )
	local Pos = self.Entity:GetPos() + (EyePos()-self.Entity:GetPos()):GetNormal() * Distance * (self.Refract^(0.3)) * 0.8

	matRefraction:SetMaterialFloat( "$refractamount", math.sin( self.Refract * math.pi ) * 0.1 )
	render.SetMaterial( matRefraction )
	render.UpdateRefractTexture()
	render.DrawSprite( Pos, self.Size, self.Size )

end



