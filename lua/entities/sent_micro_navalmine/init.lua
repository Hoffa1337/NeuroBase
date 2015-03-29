AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include( 'shared.lua' )

function ENT:Initialize()

	-- if ( self:GetModel() ) then		
		-- self:SetModel( self:GetModel() )		
	-- else	
		self:SetModel( "models/magnet/submine/submine.mdl" )	
	-- end
	self:PhysicsInit( SOLID_VPHYSICS )
	self:SetMoveType( MOVETYPE_VPHYSICS )	
	self:SetSolid( SOLID_VPHYSICS )
	
	self.PhysObj = self:GetPhysicsObject()
	
	if ( self.PhysObj:IsValid() ) then
	
	-- print("walla")
		self.PhysObj:EnableGravity( true )
		self.PhysObj:SetMass( 55 )
		self.PhysObj:SetBuoyancyRatio( 0.925 )
		self.PhysObj:SetDamping( 3.0, 1.0 )
		self.PhysObj:EnableDrag( true )
		self.PhysObj:Wake()
		
	end
	self:SetAngles( self:GetAngles() + AngleRand() * math.Rand(-.85, .85 ) )
	self:EmitSound("hitmarker_sound.wav", 511, 100 )
	timer.Simple( math.random(1,4), function()
		
		if( IsValid( self ) ) then 
		
					
			local tr1,trace1 = {},{}
			tr1.start = self:GetPos() - Vector( 0,0,0 )
			tr1.endpos = self:GetPos() - Vector( 0,0,36000 )
			tr1.filter = { self, self.Owner }
			tr1.mask = MASK_SOLID_BRUSHONLY
			trace1 = util.TraceLine( tr1 )
			
			local tr2,trace2 = {},{}
			tr2.start = self:GetPos() + Vector( 0,0,512 )
			tr2.endpos = self:GetPos() - Vector( 0,0,36000 )
			tr2.filter = { self, self.Owner }
			tr2.mask = MASK_WATER
			trace2 = util.TraceLine( tr2 )

			local length = ( trace1.HitPos - trace2.HitPos ):Length()
			self.Roped = true 
			
			self.Rope = constraint.Rope( game.GetWorld(), self, 0, 0, trace1.HitPos, Vector(0,0,-7), length-8, 0, 99999, 1, "cable/rope", false  )
			
		end 
		
	
	
	end )

end
	function ENT:SpawnFunction( ply, tr, class )
		local tr,trace = {},{}
		tr.start = ply:GetShootPos()
		tr.endpos = tr.start + ply:GetAimVector() * 12500
		tr.filter = ply
		tr.mask = MASK_WATER + MASK_SOLID
		trace = util.TraceLine( tr )
		local SpawnPos = trace.HitPos + trace.HitNormal * 1
		local ent = ents.Create( class )
		ent:SetPos( SpawnPos )
		ent.Owner = ply 
		ent:SetAngles( ply:GetAngles() )
		ent:Spawn()
		ent:Activate()
		return ent
	end
function ENT:PhysicsCollide( data, physobj )
	
	if( !self.Roped ) then return end 
	
	if( data.HitEntity:GetClass() == self:GetClass() ) then return end 
	
	if( data.HitEntity == self.Owner ) then return end 
	
	if ( data.Speed > 1 && data.DeltaTime > 0.2 && self:WaterLevel() > 0 ) then 
	
		-- for i = 0, 15 do	
		
		local effect2 = EffectData()
		effect2:SetOrigin(self:GetPos()  )
		util.Effect("WaterSurfaceExplosion", effect2 )

		util.BlastDamage( self, self.Owner or self, data.HitPos, 128, math.random( 1725, 3250 ) )
		self:EmitSound("Torpedo_Impact.wav",511,100)
		self:PlayWorldSound("Torpedo_Impact.wav")
	
		self:Remove()
	
	end
	
end

function ENT:PhysicsUpdate()
	
	-- self:GetPhysicsObject():ApplyForceCenter( VectorRand() 	)
	-- for k,v in pairs( ents.FindInSphere( self:GetPos(), 2024 ) ) do
		
		-- if( v.HealthVal || string.find( v:GetClass(), "prop_vehicle") || v:IsVehicle() ) then
		
			
			-- self.PhysObj:ApplyForceCenter( ( self:GetPos() - v:GetPos() ):GetNormalized() * 1000 )
		
		
		-- end
	
	-- end
	
end

function ENT:OnRemove()

	
end
