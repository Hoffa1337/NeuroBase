include('shared.lua')

ENT.RenderGroup		= RENDERGROUP_TRANSLUCENT

local matHeatWave		= Material( "sprites/heatwave" )
local matFire			= Material( "effects/fire_cloud1" )
function ENT:Initialize()
	self.Seed = math.Rand( 0, 10000 )
end

function ENT:Draw()
	
	self.Entity:DrawModel()
	
	self.OnStart = self.OnStart or CurTime()
	self:EffectDraw_fire()
	
end

function ENT:OnRemove()
end



function ENT:EffectDraw_fire()

	local vOffset = self:GetPos() + self:GetForward() * -5
	local vNormal = (vOffset - self:GetPos()):GetNormalized()

	local scroll = self.Seed + (CurTime() * -10)
	
	local Scale = math.Clamp( (CurTime() - self.OnStart) * 5, 0, 1 )
			
	render.UpdateRefractTexture()
	render.SetMaterial( matHeatWave )
	render.StartBeam( 3 )
		render.AddBeam( vOffset, 8 * Scale, scroll, Color( 0, 0, 255, 128) )
		render.AddBeam( vOffset + vNormal * 16 * Scale, 16 * Scale, scroll + 2, Color( 255, 255, 255, 255) )
		render.AddBeam( vOffset + vNormal * 64 * Scale, 24 * Scale, scroll + 5, Color( 0, 0, 0, 0) )
	render.EndBeam()
	
	
end
