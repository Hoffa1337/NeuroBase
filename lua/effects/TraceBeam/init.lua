

EFFECT.Mat = Material( "cable/redlaser" )

/*---------------------------------------------------------
   Init( data table )
---------------------------------------------------------*/
function EFFECT:Init( data )
	self.StartPos 	= data:GetStart()	
	self.EndPos 	= data:GetOrigin()
	self:SetRenderBoundsWS( self.StartPos, self.EndPos )
end

/*---------------------------------------------------------
   THINK
---------------------------------------------------------*/
function EFFECT:Think( )

	-- if ( CurTime() > self.DieTime ) then

		-- // Awesome End Sparks
		-- local effectdata = EffectData()
			-- effectdata:SetOrigin( self.EndPos + self.Dir:GetNormalized() * -2 )
			-- effectdata:SetNormal( self.Dir:GetNormalized() * -3 )
			-- effectdata:SetMagnitude( 2 )
			-- effectdata:SetScale( 3 )
			-- effectdata:SetRadius( 6 )
		-- util.Effect( "Sparks", effectdata )
	
end

/*---------------------------------------------------------
   Draw the effect
---------------------------------------------------------*/
function EFFECT:Render( )	
	render.SetMaterial( self.Mat )
	
	render.DrawBeam( self.StartPos, 		
					 self.EndPos ,
					8,					
					 0,					
					 0,				
					 Color( 0, 255, 0, 255 ) )
						
end
