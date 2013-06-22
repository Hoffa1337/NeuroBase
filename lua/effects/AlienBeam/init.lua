

EFFECT.Mat = Material("effects/tool_tracer")//Material( "cable/redlaser" )

/*---------------------------------------------------------
   Init( data table )
---------------------------------------------------------*/
function EFFECT:Init( data )
	self.StartPos 	= data:GetStart()	
	self.EndPos 	= data:GetOrigin()
	self.Entity:SetRenderBoundsWS( self.StartPos, self.EndPos )
end

/*---------------------------------------------------------
   THINK
---------------------------------------------------------*/
function EFFECT:Think( )
	
end

/*---------------------------------------------------------
   Draw the effect
---------------------------------------------------------*/
function EFFECT:Render( )	
	render.SetMaterial( self.Mat )
	
	
	render.DrawBeam( self.StartPos, 		
					 self.EndPos ,
					24,					
					 0,					
					 0,				
					 Color( 102, 204, 204, 225 ) )		 
end
