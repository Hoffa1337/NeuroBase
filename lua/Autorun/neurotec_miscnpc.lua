//NPCs which use playermodels.
local Pilot_Jet_friendly =
{
	Name = "USAF Pilot friendly",
	Class = "npc_citizen",
	KeyValues =
	{
		citizentype = 4
	},
	Model = "models/military/pilot_usaf.mdl",
	Health = "300",
	Category = "NeuroTec Soldiers"
}

list.Set( "NPC", "neurotec_usaf_pilot_friendly", Pilot_Jet_friendly )

local Pilot_Jet_hostile =
{
	Name = "USAF Pilot hostile",
	Class = "npc_combine_s",
	KeyValues =
	{
		NumGrenades = 2,
		tacticalvariant = 2
	},
	Model = "models/military/pilot_usaf.mdl",
	Health = "300",
	Category = "NeuroTec Soldiers"
}

list.Set( "NPC", "neurotec_usaf_pilot_hostile", Pilot_Jet_hostile )