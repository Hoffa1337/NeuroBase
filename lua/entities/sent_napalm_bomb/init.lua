AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include( 'shared.lua' )
function ENT:OnTakeDamage(dmginfo)
	
	if( !self.HealthVal ) then self.HealthVal = 100 end 
  	if( self.HealthVal < 0 ) then return end
	self:TakePhysicsDamage( dmginfo )
	
	self.HealthVal = self.HealthVal - dmginfo:GetDamage()
	
	self:SetNetworkedInt( "health" , self.HealthVal )
	
	if ( self.HealthVal < 0 ) then

		ParticleEffect( "ap_impact_wall", self:GetPos(), self:GetAngles(), nil )
		util.BlastDamage( self, self, self:GetPos(), 256, 256 )
		self:Remove()
		return
		
		
	end
	
end
function ENT:Initialize()


	if ( self:GetModel() ) then	
	
		self:SetModel( self:GetModel() )	
		
	else	
	
		self:SetModel( "models/military2/bomb/bomb_mk82s.mdl" )
	
	end	
	
	self.Detonated = false
		
	self:PhysicsInit( SOLID_VPHYSICS )
	self:SetMoveType( MOVETYPE_VPHYSICS )	
	self:SetSolid( SOLID_VPHYSICS )

	self.PhysObj = self:GetPhysicsObject()
	
	if (self.PhysObj:IsValid()) then
		
		self.PhysObj:Wake()
		self.PhysObj:EnableDrag( true )
		
	end
	
	util.SpriteTrail(self, 0, Color(255,255,255,math.random(20,40)), false, 3, math.random(0.5,1.1), 3, math.random(1,3), "trails/smoke.vmt");  

end

function ENT:PhysicsUpdate()

	local tr, trace = {},{}
	tr.start = self:GetPos()
	tr.endpos = tr.start + self:GetForward() * 250
	tr.filter = self
	trace = util.TraceLine( tr )
	
	if ( trace.Hit && trace.HitSky ) then
		
		self:Remove()
		
	end

end

function ENT:PhysicsCollide( data, physobj )
	
	if( self.Detonated ) then return end
	
	if (  !IsValid( self.Owner ) ) then
	
		self.Owner = ents.GetAll()[1]
	
	end

	
	if (data.Speed > 150 && data.DeltaTime > 0.8 ) then 
		
		//self:EmitSound( "LockOn/ExplodeNapalm.mp3", 511, 100 )
					
		for i=1,15 do
			
			local tr, trace = {}, {}
			tr.start = self:GetPos() + Vector(0,0,752) + self:GetForward() * 256 * i + Vector(math.random(-512,512),math.random(-512,512),0)
			tr.endpos = self:GetPos() + Vector(0,0,-512) + self:GetForward() * 256 * i + Vector(math.random(-512,512),math.random(-512,512),0)
			tr.filter = self
			tr.mask = MASK_SOLID
			trace = util.TraceLine( tr )
	
			if( trace.Hit ) then
				
				for k,v in pairs( ents.FindInSphere( trace.HitPos, 1024 ) ) do
					
					if( v:IsNPC() || v:IsPlayer() || v.HealthVal || v:GetClass() == "prop_physics" ) then
						
						v:Ignite( math.random(10,20), 256 )
					
					end
					
				end
				
				timer.Simple( i / 30, function() 
						
						if( IsValid( self ) ) then
						
							local explo = EffectData()
							explo:SetOrigin( trace.HitPos )
							explo:SetScale( 1.0 + math.Rand( -.2,.2) )
							util.Effect("Napalm_Bomb", explo)
							
							util.BlastDamage( self, self.Owner, trace.HitPos, 3048, 55 ) 
							
							util.Decal("Scorch", trace.HitPos + trace.HitNormal * 512, trace.HitPos - trace.HitNormal * 512 )
							
						end
						
					end )
				
			end
			
		end
		
		self:SetMoveType( MOVETYPE_NONE )
		self:SetColor( Color( 0,0,0,0 ) )
		self:SetRenderMode( RENDERMODE_TRANSALPHA )
		self:Fire("kill","",3)
		self.Detonated = true
		
	end
	
end

function ENT:OnRemove()
	
	//self:StopSound( "LockOn/ExplodeNapalm.mp3" )
	
end
