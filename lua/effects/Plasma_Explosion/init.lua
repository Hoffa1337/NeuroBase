function EFFECT:Init( data )
local pos = data:GetOrigin()
ParticleEffect("plasma_explosion", Pos, Angle(0,0,0), nil)
end
function EFFECT:Think( )
return false
end
function EFFECT:Render()
end



