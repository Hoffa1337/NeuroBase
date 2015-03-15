AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include( 'shared.lua' )

function ENT:Initialize()

	if ( self:GetModel() ) then
		
		self:SetModel( self:GetModel() )
		
	else
	
		self:SetModel( "models/starchick971/hawx/weapons/drop tank.mdl" )
	
	end
	
	self:PhysicsInit( SOLID_VPHYSICS )
	self:SetMoveType( MOVETYPE_VPHYSICS )	
	self:SetSolid( SOLID_VPHYSICS )
	self.BurnTicker = 0
	
	self.PhysObj = self:GetPhysicsObject()
	
	if ( self.PhysObj ) then
		
		self.PhysObj:Wake()
		-- self.PhysObj:EnableGravity(true)
		-- self.PhysObj:EnableDrag(false)
		-- self.PhysObj:SetMass(250)

	end
	
	self.SpawnTime = CurTime()
	-- self:EmitSound("weapons/mortar/mortar_shell_incomming1.wav",25,110)
	self:EmitSound("WT/Misc/bomb_whistle.wav")

	util.SpriteTrail(self, 0, Color(255,255,255,math.random(11,12)), false, 3, math.random(0.5,1.1), 1, math.random(1,3), "trails/smoke.vmt");  
end

function ENT:PhysicsUpdate()


end
function ENT:Think()

	if( self.CollidedAndStuck ) then
		
		for k,v in pairs( ents.FindInSphere( self:GetPos(), 100 ) ) do
		
			if( IsValid( v ) ) then
			
				v:Ignite( 3, 100 )
			
			end 
			
		end 
		
		if( self.BurnTicker + 30 <= CurTime() ) then
			
			self:Remove()
			
			
		end 
		
	end

end

function ENT:PhysicsCollide( data, physobj )
	
	if( data.HitEntity == game.GetWorld() && !self.CollidedAndStuck ) then
		
		self.CollidedAndStuck = true 
		
		if (  !IsValid( self.Owner ) ) then  self.Owner = self	end
		if( IsValid( self.Owner )  && IsValid( self.Owner.Pilot ) ) then self.Owner = self.Owner.Pilot end 
		
		
		for i=1,10 do 
			local pos = VectorRand() * 128 
			pos.z = 0
			ParticleEffect( "neuro_gascan_explo", self:GetPos() + pos , Angle( 0,0,0 ), nil )
	
		end 
		-- 
		-- ParticleEffect( "neuro_gascan_explo_air", self:GetPos() + pos , Angle( 0,0,0 ), nil )
		
		self:EmitSound(  "WT/Misc/bomb_explosion_"..math.random(1,6)..".wav", 511, 100 )
		
		util.BlastDamage( self, self.Owner, data.HitPos, 256, math.random( 150,250 ) )
		
		util.Decal("Scorch", data.HitPos + data.HitNormal * 32, data.HitPos - data.HitNormal * 32 )
		-- fireplume_small
		
		ParticleEffectAttach( "fireplume_small", PATTACH_ABSORIGIN_FOLLOW, self, 0 )
	
		-- self:Remove()
		self:SetMoveType( MOVETYPE_NONE )
		self:SetRenderMode( RENDERMODE_TRANSALPHA )
		self:SetColor( Color( 0,0,0,1 ) )
		-- self:DrawShadow( false ) 
		self.BurnTicker = CurTime() 
		
	end
	
end

function ENT:OnRemove()
end
