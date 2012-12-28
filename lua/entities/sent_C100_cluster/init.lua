AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include( 'shared.lua' )

function ENT:Initialize()

	self:SetModel( "models/hawx/weapons/cbu-94 blackoutbomb.mdl" )
	self:PhysicsInit( SOLID_VPHYSICS )
	self:SetMoveType( MOVETYPE_VPHYSICS )	
	self:SetSolid( SOLID_VPHYSICS )
	self.PhysObj = self:GetPhysicsObject()
	
	if (self.PhysObj:IsValid()) then
		self.PhysObj:Wake()
		self.PhysObj:EnableGravity( true )
	end
	
	util.SpriteTrail(self, 0, Color( 255,255,255,math.random( 50, 70 ) ), false, 16, math.Rand(0.5,1.1), 0.1, math.random(1,3), "trails/smoke.vmt")
	
end

function ENT:PhysicsCollide( data, physobj )
	
	if ( IsValid( self.Owner ) ) then
	
		util.BlastDamage( self.Owner, self.Owner, data.HitPos, 700, math.random( 100, 455 ) )
		
	end
	
	self:EmitSound( "ambient/fire/gascan_ignite1.wav",211,100 )
	
	util.Decal("Scorch", data.HitPos + data.HitNormal * 10, data.HitPos - data.HitNormal * 10 )
	
	local fx = EffectData()
	fx:SetOrigin( data.HitPos )
	fx:SetStart( data.HitPos )
	fx:SetScale( 0.8 )
	util.Effect( "ac130_napalm", fx )
	
	self:Remove()
	
end

