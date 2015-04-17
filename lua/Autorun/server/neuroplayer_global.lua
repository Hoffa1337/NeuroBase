local Meta = FindMetaTable( "Player" )

function Meta:Neuro_PlayerMakeSmall( )	
	
	local hull_width = 10 
	local mins,maxs =  Vector( -hull_width, -hull_width, 0 ), Vector( hull_width, hull_width, 72 )
	local dmins, dmaxs = Vector( -hull_width, -hull_width, 0 ), Vector( hull_width, hull_width, 36 )
	mins.z = mins.z * .125
	maxs.z = maxs.z * .125
	self:ResetHull()
	self:SetHull( mins, maxs )
	self:SetViewOffset( Vector(0,0,10 ) )

	self:SetViewOffsetDucked( Vector(0,0,7 ) )
	self:SetNWBool("NeuroMiniMe",true)
	self:SetModelScale( .145, 1 )
	self:SetRunSpeed( 400 * .5 ) 
	self:SetWalkSpeed( 200 * .5 )
	self:SetJumpPower( 200 * .75 )
	self:SetStepSize( 8 )

end 

hook.Add("PlayerSpawn", "Neuro_MinifyPlayerSpawnStuff", function( ply ) 
	
	if( ply:GetNWBool("NeuroMiniMe") ) then 
	
		ply:SetRunSpeed( 400 * .5 ) 
		ply:SetWalkSpeed( 200 * .5 )
		ply:SetJumpPower( 200 * .75 )
		ply:SetStepSize( 8 )

	end 
	
end )

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
