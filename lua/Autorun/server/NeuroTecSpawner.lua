if true then return end

//local NeuroTest = CreateConVar( "Neuro_testvar", "1", FCVAR_NOTIFY | FCVAR_GAMEDLL );
AddCSLuaFile( "NeuroTecMenu.lua" )
include( 'NeuroTecMenu.lua' )
local ViewPoint
function NeuroSpawner( ply, tr)

	for k,v in pairs( ents.GetAll() ) do
	local c = v:GetClass()
	local PointExist = ( string.find( c, "sent_spawnpoint" ) != nil )
			
			if PointExist then
			ViewPoint = v:GetPos()
			end
	end
	
	local entname = ply:GetNetworkedString( "objectENT" )
--	local entname = ply:GetInfo( "ObjectENT" )
	local Skin = ply:GetNetworkedInt( "Skin", 0 )
//	local SpawnPos = ply:GetNetworkedVector( "SpawnPoint", tr.HitPos + tr.HitNormal * 10 )
	if entname then
	local ent = ents.Create( entname )
--	ent:SetPos( ViewPoint + Vector( 0, 0, 10 ) )
	ent:SetPos( ply:GetPos() + ply:GetForward() * 500 + Vector( 0, 0, 50 ) )
--	ent:SetPos( Vector( 0, 0, 10 ) )
	ent:Spawn()
	undo.Create( entname:GetName() ) 
	undo.AddEntity( ent ) 
	undo.SetPlayer( ply ) 
	undo.Finish()
	
	end
	print(ViewPoint)
	print(entname)
	print(Skin)
end
concommand.Add("Neuro_SpawnObject",NeuroSpawner)
hook.Add( "NeuroSpawn", "NeuroTecSpawner", NeuroSpawner )

print( "[NeuroPlanes] NeuroTecSpawner.lua loaded!" )