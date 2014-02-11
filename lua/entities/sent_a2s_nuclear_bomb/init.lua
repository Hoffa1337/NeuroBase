AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include( 'shared.lua' )
function ENT:OnTakeDamage(dmginfo)
 self:NA_RPG_damagehook()
 end
function ENT:Initialize()
	

	self:SetModel( "models/military2/bomb/bomb_kab.mdl" )
	self:PhysicsInit( SOLID_VPHYSICS )
	self:SetMoveType( MOVETYPE_VPHYSICS )	
	self:SetSolid( SOLID_VPHYSICS )
	self.Detonated = false
	
	self.Owner = self:GetOwner().Owner or self // lolol
	
	self.PhysObj = self:GetPhysicsObject()
	 
	if ( self.PhysObj:IsValid() ) then
	
		self.PhysObj:Wake()
	
	end

	util.SpriteTrail( self, 0, Color( 180,180,180,math.random(40,60)), false, 16, math.random(1,2), 1, math.random(1,3), "trails/smoke.vmt");  
	
end

function ENT:PhysicsCollide( data, physobj )
	
	if( self.Detonated ) then return end
	
	if ( IsValid( data.HitEntity ) && data.HitEntity:GetOwner() == self:GetOwner() ) then -- // Plox gief support for SetOwner ( table )
		
		return
		
	end
	
	if (data.Speed > 100 && data.DeltaTime > 0.2 ) then 
		
		local hc  = 0
		
		local tr,trace = {},{}
		
		for i=1,30 do
			
			tr.start = data.HitPos
			tr.endpos = data.HitPos + Vector( math.random( -4000, 4000 ),math.random( -4000, 4000 ),math.random( -4000, 4000 ) )
			tr.mask = MASK_SOLID
			trace = util.TraceLine( tr )
			
			if( trace.Hit && !trace.HitSky ) then
				
				hc = hc + 1
				
			end
			
		end
		
		if( hc < 5 ) then
			
			local fx = EffectData()
			fx:SetOrigin( self:GetPos() )
			fx:SetNormal( data.HitNormal )
			fx:SetScale( 0.176 )

			util.Effect("nuke_effect_air", fx)
		
		else
					
			local fx = EffectData()
			fx:SetOrigin( self:GetPos() )
			fx:SetNormal( data.HitNormal )
			fx:SetScale( 1.0 )

			util.Effect("Missile_Nuke", fx)
		
		end
		
		local v = data.HitPos + Vector( 0,0,256 )
		local p = self.Owner
		
		if( !IsValid( p ) ) then
			
			p = self
			
		end
		
		local pp = self:GetPos()
		
		util.BlastDamage( p, p, v, 8000, math.random( 6000, 8000 ) )  

		
		self:SetColor( 0,0,0,0 )
		self:Fire("kill","",30)
		self:SetSolid( SOLID_NONE )
		self:SetMoveType( MOVETYPE_NONE )
		
		self.Detonated = true 
		self:Remove()
		
		
	end
	
end

function ENT:PhysicsUpdate()

	if ( !IsValid( self.Owner ) ) then
		self.Owner = self
	end
	
end

function ENT:Think()
end 

function ENT:OnRemove()
end
