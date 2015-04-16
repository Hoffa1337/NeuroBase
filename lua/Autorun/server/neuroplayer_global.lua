local Meta = FindMetaTable( "Player" )

function Meta:Neuro_PlayerMakeSmall( )	

	local mins,maxs =  Vector( -8, -8, 0 ), Vector( 8, 8, 72 )
	local dmins, dmaxs = Vector( -8, -8, 0 ), Vector( 8, 8, 36 )
	mins.z = mins.z * .125
	maxs.z = maxs.z * .125
	self:ResetHull()
	self:SetHull( mins, maxs )
	self:SetViewOffset( Vector(0,0,12 ) )
	self:SetJumpPower( 200 * .75 )
	self:SetViewOffsetDucked( Vector(0,0,7 ) )
	self:SetNWBool("NeuroMiniMe",true)
	self:SetModelScale( .135, 1 )
	self:SetRunSpeed( 400 * .5 ) 
	self:SetWalkSpeed( 200 * .5 )
	self:SetStepSize( 8 )

end 


function Meta:Neuro_PlayerMakeBig()

	self:ResetHull()
	self:SetViewOffset( Vector(0,0,72) )
	self:SetViewOffsetDucked( Vector(0,0,36) )
	self:SetJumpPower( 200 )
	self:SetNWBool("NeuroMiniMe",false )
	self:SetModelScale( 1, 1 )
	self:SetRunSpeed( 400 ) 
	self:SetWalkSpeed( 200 )
	self:SetStepSize( 18 )

end 
