/*********************************************************************/
/* 																	 */
/*  					NEUROTEC MANAGER							 */
/* 																	 */
/*********************************************************************/

-- local NP,NT,NN,NW = {},{},{},{}

/*
for k, v in pairs( scripted_ents.GetList() ) do

	if ( string.find( v.t.Category, "Aviation" ) ) then
	NP=NP,v.t.ClassName		
	print( v.t.Category)
	end	
	if ( string.find( v.t.Category, "Tanks" ) ) then	
	NT=NT,v.t.ClassName		
	end
	
	if ( string.find( v.t.Category, "Naval" ) ) then	
	NN=NN,v.t.ClassName		
	end
	
	if ( string.find( v.t.Category, "Weapons" ) ) then	
	NW=NW,v.t.ClassName		
	end
	

end
*/
/* ***************************************delete this line to see the Neuro Tab (doesn't work yet)********************************************
base_weapons = {}
base_weapons[1] = "TargetDesignator"
base_weapons[2] = "weapon_jericho"
base_weapons[3] = "weapon_np_flaregun"
base_weapons[4] = "weapon_np_repairgun"
base_weapons[5] = "weapon_stinger"

helicopters= {}
helicopters[1] = "sent_AH-64_Apache_p"
helicopters[2] = "sent_mi-28_p"
aircraft = {}
aircraft[1] = "sent_Spitfire_p"
aircraft[2] = "sent_A-10_p"
aircraft[3] = "sent_He-111_p"
aircraft[4] = "sent_FA22raptor"
tank = {}
tank[1] = "sent_M1A2_p"

local function NeuroTecCreateContentTab()
-- spawnmenu.AddCreationTab( "NeuroTec", function()

local ply = LocalPlayer()

NeuroTecSheet = vgui.Create( "DPropertySheet" )
NeuroTecSheet:SetPos( 5, 30 )
NeuroTecSheet:SetSize( 340, 315 )

//NeuroBase sheet

	NBase_CollapsibleCategory = {}
		NBase_CollapsibleCategory[1] = vgui.Create("DCollapsibleCategory")
		NBase_CollapsibleCategory[1]:SetPos( 25,50 )
		NBase_CollapsibleCategory[1]:SetSize( 200, 50 ) -- Keep the second number at 50
		NBase_CollapsibleCategory[1]:SetExpanded( 1 )
		NBase_CollapsibleCategory[1]:SetLabel( "Weapons" )

	NBase_WeaponList = vgui.Create( "DPanelList" )
	NBase_WeaponList:SetAutoSize( true )
	NBase_WeaponList:SetSpacing( 5 )
	NBase_WeaponList:EnableHorizontal( true )
	NBase_WeaponList:EnableVerticalScrollbar( true )
	NBase_CollapsibleCategory[1]:SetContents( NBase_WeaponList )

	Spawnicons_weapons = {}
	for i = 1,#base_weapons do
		Spawnicons_weapons[i] = vgui.Create( "DImageButton", NBase_CollapsibleCategory[1] ) 
		Spawnicons_weapons[i]:SetSize( 128, 128 )
		Spawnicons_weapons[i]:SetImage( "vgui/entities/"..base_weapons[i]..".vtf" )
		Spawnicons_weapons[i].DoClick = function()
			Msg("This is still a work in progress... \n")
			RunConsoleCommand( "gm_spawn_neuroent", base_weapons[i] )
			-- ply:Give( base_weapons[i] )
			end
		NBase_WeaponList:AddItem( Spawnicons_weapons[i] )
	 end

NeuroTecSheet:AddSheet( "Base", NBase_CollapsibleCategory[1], "icon16/control_repeat_blue.png", false, false, "NeuroTec SWEPS" )







//NPlanes sheet
	NP_CollapsibleCategory = {}
		NP_CollapsibleCategory[1] = vgui.Create("DCollapsibleCategory")
		NP_CollapsibleCategory[1]:SetPos( 25,50 )
		NP_CollapsibleCategory[1]:SetSize( 200, 50 )
		NP_CollapsibleCategory[1]:SetExpanded( 1 )
		NP_CollapsibleCategory[1]:SetLabel( "Aircraft" )
		
		-- NP_CollapsibleCategory[2] = vgui.Create("DCollapsibleCategory")
		-- NP_CollapsibleCategory[2]:SetPos( 25,50 )
		-- NP_CollapsibleCategory[2]:SetSize( 200, 100 )
		-- NP_CollapsibleCategory[2]:SetExpanded( 0 )
		-- NP_CollapsibleCategory[2]:SetLabel( "Helicopters" )
	
	NP_AircraftList = vgui.Create( "DPanelList" )
	NP_AircraftList:SetAutoSize( true )
	NP_AircraftList:SetSpacing( 5 )
	NP_AircraftList:EnableHorizontal( true )
	NP_AircraftList:EnableVerticalScrollbar( true )
	NP_CollapsibleCategory[1]:SetContents( NP_AircraftList )

	-- NP_HelicoptersList = vgui.Create( "DPanelList" )
	-- NP_HelicoptersList:SetAutoSize( true )
	-- NP_HelicoptersList:SetSpacing( 5 )
	-- NP_HelicoptersList:EnableHorizontal( true )
	-- NP_HelicoptersList:EnableVerticalScrollbar( true )
	-- NP_CollapsibleCategory[2]:SetContents( NP_HelicoptersList )
	
	PlaneView = vgui.Create( "DModelPanel", NP_CollapsibleCategory[1])
	PlaneView:SetModel( "models/hawx/planes/A-6 Intruder.mdl" )
	-- PlaneView:SetSize( ScrH()*0.4, ScrH()*0.4 )
	PlaneView:SetSize( 128, 128 )
	PlaneView:SetCamPos( Vector( 512, 512, 512 ) )
	PlaneView:SetLookAt( Vector( 0, 0, 0 ) )
	NP_AircraftList:AddItem( PlaneView )
	
	Spawnicons_aircraft = {}
	for i = 1,#aircraft do
		Spawnicons_aircraft[i] = vgui.Create( "DImageButton", NP_CollapsibleCategory[1] ) 
		Spawnicons_aircraft[i]:SetSize( 128, 128 )
		Spawnicons_aircraft[i]:SetImage( "vgui/entities/"..aircraft[i]..".vtf" )
		Spawnicons_aircraft[i].DoClick = function()
			Msg("This is still a work in progress... \n")
			RunConsoleCommand( "gm_spawn_neuroent", aircraft[1] )
			end
		NP_AircraftList:AddItem( Spawnicons_aircraft[i] )
	 end
	-- Spawnicons_helicopters = {}
	-- for i = 1,#helicopters do
		-- Spawnicons_helicopters[i] = vgui.Create( "DImageButton", NP_CollapsibleCategory[2] ) 
		-- Spawnicons_helicopters[i]:SetSize( 128, 128 )
		-- Spawnicons_helicopters[i]:SetImage( "vgui/entities/"..helicopters[i]..".vtf" )
		-- Spawnicons_helicopters[i].DoClick = function()
			-- Msg("This is still a work in progress... \n")
			-- RunConsoleCommand( "gm_spawn_neuroent", helicopters[1] )
			-- end
		-- NP_HelicoptersList:AddItem( Spawnicons_helicopters[i] )
	 -- end
	 
NeuroTecSheet:AddSheet( "Aviation", NP_CollapsibleCategory[1], "icon16/control_repeat_blue.png", false, false, "Aircraft and Helicopters" )

	return NeuroTecSheet
	
end
spawnmenu.AddCreationTab( "NeuroTec", NeuroTecCreateContentTab, "icon16/control_repeat_blue.png", 200 )
