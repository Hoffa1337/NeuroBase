AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include( 'shared.lua' )
ENT.Model = "models/roller_spikes.mdl"
function ENT:Initialize()

	self.Entity:SetModel( self.Model )
	self.Entity:PhysicsInit( SOLID_NONE )
	self.Entity:SetMoveType( MOVETYPE_NONE )	
	self.Entity:SetSolid( SOLID_NONE )
	self.Entity:SetColor( 0, 0, 0, 0 )
	
end

function ENT:Think()

	if( IsValid( self.Owner ) ) then
	
		if( !IsValid( self.Owner.Target ) ) then
		
			self.Owner.Target = self
			
		end
		
	else
	
		self:Remove()
		
		return false
		
	end
	
end