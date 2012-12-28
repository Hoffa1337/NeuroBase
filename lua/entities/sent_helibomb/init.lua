
AddCSLuaFile( "cl_init.lua" );
AddCSLuaFile( "shared.lua" );
include( "shared.lua" );

ENT.SplodeTimer = 40
ENT.Disarmed = false

function ENT:Initialize()

	self:SetModel( "models/combine_helicopter/helicopter_bomb01.mdl" )
	self:PhysicsInit( SOLID_VPHYSICS )
	self:SetMoveType( MOVETYPE_VPHYSICS )
	self:SetSolid( SOLID_VPHYSICS )
	self.SeekSound = CreateSound(self,Sound("npc/attack_helicopter/aheli_mine_seek_loop1.wav")) 
	self.SeekSound:PlayEx(500,100)

	local phys = self:GetPhysicsObject()
	
	if ( phys:IsValid() ) then
		  
		phys:Wake()
		
	end
	
	self.HP = 90
	
end


function ENT:OnTakeDamage(dmginfo)

	self:TakePhysicsDamage(dmginfo)
	self.HP = self.HP - dmginfo:GetDamage()

	if ( self.HP < 5 ) then
	
		self:Remove()
		
	end
	
end

function ENT:Use( activator, caller )
	
	self.Disarmed = true
	
end

function ENT:Think()

	
	self.SeekSound:ChangePitch( 100 )
	
	self.SplodeTimer = self.SplodeTimer - 1
	
	if ( self.SplodeTimer <= 5 ) then
	
		if( self.mOwner && IsValid( self.mOwner) ) then
		
			util.BlastDamage( self.mOwner, self.mOwner, self:GetPos(), 512, 45 )
			
		else
		
			util.BlastDamage( self, self, self:GetPos(), 512, 45 )
			
		end
		
		self:EmitSound( "ambient/explosions/explode_7.wav", 200, 100 )
		
		local e = EffectData()
		e:SetOrigin(self:GetPos())
		e:SetScale(10)
		util.Effect("HelicopterMegaBomb", e)
		
		self:Remove()
		
	end
	
end

function ENT:OnRemove()

	self.SeekSound:Stop()
	
end
