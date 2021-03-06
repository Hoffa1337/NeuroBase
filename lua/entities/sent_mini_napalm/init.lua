AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include( 'shared.lua' )
function ENT:Initialize()
	self:PhysicsInit( SOLID_VPHYSICS )
	self:SetMoveType( MOVETYPE_VPHYSICS )	
	self:SetSolid( SOLID_VPHYSICS )
	self.BurnTicker = 0
	self.PhysObj = self:GetPhysicsObject()
	if ( self.PhysObj ) then
		self.PhysObj:Wake()
	end
	local count = 0
	local tr,trace = {},{}
	for i=1,10 do
		tr.start = self:GetPos() 
		tr.endpos = tr.start + VectorRand() * 1500 
		tr.filter = self
		tr.mask = MASK_SOLID
		trace = util.TraceLine( tr )
		
		if( trace.Hit ) then 
			
			count = count + 1 
			
		end 
		
	end 
	
	if( count < 4 ) then 	
	
		self.Whistle = CreateSound( self, "WT/Misc/bomb_whistle.wav")
		self.Whistle:Play()
		
	end 
	
	util.SpriteTrail(self, 0, Color(255,255,255,math.random(11,12)), false, 3, math.random(0.5,1.1), 1, math.random(1,3), "trails/smoke.vmt");  
end

function ENT:Think()
	if( self.CollidedAndStuck ) then
		if( IsValid( self:GetPhysicsObject() ) ) then	
			self:PhysicsDestroy()
		end 
		for k,v in pairs( ents.FindInSphere( self:GetPos(), 800 ) ) do
			if( IsValid( v ) && v:GetPos().z < self:GetPos().z+150 && Neuro_inLOS( self, v ) ) then
				v:Ignite( 3, 100 )
			end 
		end 
		if( self.BurnTicker + 15 <= CurTime() ) then
			self:Remove()
		end 
	end
end

function ENT:PhysicsCollide( data, physobj )
	
	if( data.DeltaTime > .2 && data.Speed > 500 && !self.CollidedAndStuck ) then
		
		self.CollidedAndStuck = true 
		
		if (  !IsValid( self.Owner ) ) then  self.Owner = self	end
		if( IsValid( self.Owner )  && IsValid( self.Owner.Pilot ) ) then self.Owner = self.Owner.Pilot end 
		
		for i=1,5 do 
			local pos = VectorRand() * 128 
			pos.z = 0
		
			ParticleEffect( "neuro_gascan_explo", self:GetPos() + pos , Angle( 0,0,0 ), nil )
		end 
		
		ParticleEffect( "napalm_explosion", self:GetPos() , Angle( 0,0,0 ), nil )
		
		self:Ignite( 750, 750 )
	
		self:PlayWorldSound(  "WT/Misc/bomb_explosion_"..math.random(1,6)..".wav" )
		util.Decal("Scorch", data.HitPos + data.HitNormal * 32, data.HitPos - data.HitNormal * 32 )
		ParticleEffectAttach( "fireplume_small", PATTACH_ABSORIGIN_FOLLOW, self, 0 )
	
		-- self:SetMoveType( MOVETYPE_NONE )
		self:SetRenderMode( RENDERMODE_TRANSALPHA )
		self:SetColor( Color( 0,0,0,1 ) )

		self.BurnTicker = CurTime() 
				
		util.BlastDamage( self, self.Owner, data.HitPos, 256, math.random( 150,250 ) )
		
	end
	
end

function ENT:OnRemove()
	if( self.Whistle ) then 
	
		self.Whistle:FadeOut( 0.5 )
	
	end 
	
end
