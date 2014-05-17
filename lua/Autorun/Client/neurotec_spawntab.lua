/*********************************************************************/
/* 																	 */
/*  					NEUROTEC MANAGER							 */
/* 																	 */
/*********************************************************************/

-- local NP,NT,NN,NW = {},{},{},{}

NP_ents_list = {}
NP_ents_helicopters_list = {}
NP_ents_warbirds_list = {}
N_ents_misc_list = {}
NT_ents_list = {}
NN_ents_list = {}
NW_ents_list = {}
hook.Add("InitPostEntity", "NeuroTecBuildSpawnMenu", function() 

	for k, v in pairs( scripted_ents.GetSpawnable( )) do
		
		if( v.Category ) then 
			
			local cat = string.lower( v.Category )
			if( string.find( cat, "neurotec aviation" ) || string.find( cat, "neurotec civil" ) ) then
				table.insert( NP_ents_list, v.ClassName )
			end
			if( string.find( cat, "neurotec warbirds" ) ) then
				table.insert( NP_ents_warbirds_list, v.ClassName )
			end

			if( string.find( cat, "neurotec helicopters" )) then
				table.insert( NP_ents_helicopters_list, v.ClassName )
			end

			if( string.find( cat, "neurotec fun" ) || string.find( cat, "neurotec admin" ) || string.find( cat, "neurotec work" ) ) then
				table.insert( N_ents_misc_list, v.ClassName )
			end

			-- tanks only
			if( v.TankType && string.find( cat, "neurotec tanks" ) || string.find( cat, "neurotec ground" ) ) then
				table.insert( NT_ents_list, v )
				-- print("woop")
			end


			if( string.find( cat, "neurotec naval" )  ) then
				table.insert( NN_ents_list, v.ClassName )
			end

			if( string.find( cat, "neurotec weapons" ) ) then
				table.insert( NW_ents_list, v.ClassName )
			end
			
		end
		
	end

end )

/*-- ***************************************delete this line to see the Neuro Tab (doesn't work yet)********************************************
base_weapons = {}
base_weapons[1] = "TargetDesignator"
base_weapons[2] = "weapon_jericho"
base_weapons[3] = "weapon_np_flaregun"
base_weapons[4] = "weapon_np_repairgun"
base_weapons[5] = "weapon_stinger"

helicopter= {}
helicopter[1] = "sent_AH-64_Apache_p"
helicopter[2] = "sent_mi-28_p"
aircraft = {}
aircraft[1] = "sent_Spitfire_p"
aircraft[2] = "sent_A-10_p"
aircraft[3] = "sent_He-111_p"
aircraft[4] = "sent_FA22raptor"
tank = {}
tank[1] = "sent_Stryker_p"
tank[2] = "sent_bmp3_p"
tank[3] = "sent_T-80BV_p"
tank[4] = "sent_paladin_p"

local function NeuroTecCreateContentTab()
-- spawnmenu.AddCreationTab( "NeuroTec", function()

local ply = LocalPlayer()

local icon_size = 128
local w = ScrW()*0.57

NeuroTecSheet = vgui.Create( "DPropertySheet" )
NeuroTecSheet:SetPos( 5, 30 )
NeuroTecSheet:SetSize( 340, 315 )


//NeuroBase
	local NB_Scroll = vgui.Create( "DScrollPanel" )
	
	local NB_List = vgui.Create( "DIconLayout",NB_Scroll )
	NB_List:SetSize( w, 50 )
	NB_List:SetSpaceY( 5 )
	NB_List:SetSpaceX( 5 )

		local NB_CollapsibleCategory = {}
		NB_CollapsibleCategory[1] = NB_List:Add( "DCollapsibleCategory" )
		NB_CollapsibleCategory[1]:SetSize( w, 50 )
		NB_CollapsibleCategory[1]:SetExpanded( 1 )
		NB_CollapsibleCategory[1]:SetLabel( "Scripted Weapons" )

			local SwepsContent   = vgui.Create( "DIconLayout" )
			NB_CollapsibleCategory[1]:SetContents( SwepsContent )
			SwepsContent:SetSize( 1340, 50 )
			SwepsContent:SetSpaceY( 5 )
			SwepsContent:SetSpaceX( 5 )

				local NB_SwepsContentIconsListItem = {}
				for i = 1,4 do
						NB_SwepsContentIconsListItem[i] = SwepsContent:Add( "DImageButton" )
						NB_SwepsContentIconsListItem[i]:SetSize( icon_size, icon_size )
						NB_SwepsContentIconsListItem[i]:SetImage( "vgui/entities/"..base_weapons[i]..".vtf" )
						NB_SwepsContentIconsListItem[i].DoClick = function()
							Msg("This is still a work in progress... \n")
							end
				end

		NB_CollapsibleCategory[2] = NB_List:Add( "DCollapsibleCategory" )
		NB_CollapsibleCategory[2]:SetSize( w, 50 )
		NB_CollapsibleCategory[2]:SetExpanded( 1 )
		NB_CollapsibleCategory[2]:SetLabel( "Neuro Tools" )
		
			local ToolsContent   = vgui.Create( "DIconLayout" )
			NB_CollapsibleCategory[2]:SetContents( ToolsContent )
			ToolsContent:SetSize( w, 50 )
			ToolsContent:SetSpaceY( 5 )
			ToolsContent:SetSpaceX( 5 )

				local NB_ToolsIconsListItem = {}
				for i = 1,4 do
						NB_ToolsIconsListItem[i] = ToolsContent:Add( "DImageButton" )
						NB_ToolsIconsListItem[i]:SetSize( icon_size, icon_size )
						NB_ToolsIconsListItem[i]:SetImage( "vgui/entities/"..base_weapons[i]..".vtf" )
						NB_ToolsIconsListItem[i].DoClick = function()
							Msg("This is still a work in progress... \n")
							end
				end

NeuroTecSheet:AddSheet( "NeuroBase", NB_Scroll, "icon16/control_repeat_blue.png", false, false, "NeuroTec SWEPs" )


//NeuroPlanes
	local NP_Scroll = vgui.Create( "DScrollPanel" )
	
	local NP_List = vgui.Create( "DIconLayout",NP_Scroll )
	NP_List:SetSize( w, 50 )
	NP_List:SetSpaceY( 5 )
	NP_List:SetSpaceX( 5 )

		local NP_CollapsibleCategory = {}
		NP_CollapsibleCategory[1] = NP_List:Add( "DCollapsibleCategory" )
		NP_CollapsibleCategory[1]:SetSize( w, 50 )
		NP_CollapsibleCategory[1]:SetExpanded( 1 )
		NP_CollapsibleCategory[1]:SetLabel( "Aircraft" )

			local AircraftContent   = vgui.Create( "DIconLayout" )
			NP_CollapsibleCategory[1]:SetContents( AircraftContent )
			AircraftContent:SetSize( w, 50 )
			AircraftContent:SetSpaceY( 5 )
			AircraftContent:SetSpaceX( 5 )

				local NP_AircraftContentIconsListItem = {}
				for i = 1,#aircraft do
						NP_AircraftContentIconsListItem[i] = AircraftContent:Add( "DImageButton" )
						NP_AircraftContentIconsListItem[i]:SetSize( icon_size, icon_size )
						NP_AircraftContentIconsListItem[i]:SetImage( "vgui/entities/"..aircraft[i]..".vtf" )
						NP_AircraftContentIconsListItem[i].DoClick = function()
							Msg("This is still a work in progress... \n")
							end
				end

		NP_CollapsibleCategory[2] = NP_List:Add( "DCollapsibleCategory" )
		NP_CollapsibleCategory[2]:SetSize( w, 50 )
		NP_CollapsibleCategory[2]:SetExpanded( 1 )
		NP_CollapsibleCategory[2]:SetLabel( "Helicopters" )
		
			local HelicoptersContent   = vgui.Create( "DIconLayout" )
			NP_CollapsibleCategory[2]:SetContents( HelicoptersContent )
			HelicoptersContent:SetSize( w, 50 )
			HelicoptersContent:SetSpaceY( 5 )
			HelicoptersContent:SetSpaceX( 5 )

				local NP_HelicoptersIconsListItem = {}
				for i = 1,#helicopter do
						NP_HelicoptersIconsListItem[i] = HelicoptersContent:Add( "DImageButton" )
						NP_HelicoptersIconsListItem[i]:SetSize( icon_size, icon_size )
						NP_HelicoptersIconsListItem[i]:SetImage( "vgui/entities/"..helicopter[i]..".vtf" )
						NP_HelicoptersIconsListItem[i].DoClick = function()
							Msg("This is still a work in progress... \n")
							end
				end

		NP_CollapsibleCategory[3] = NP_List:Add( "DCollapsibleCategory" )
		NP_CollapsibleCategory[3]:SetSize( w, 50 )
		NP_CollapsibleCategory[3]:SetExpanded( 1 )
		NP_CollapsibleCategory[3]:SetLabel( "Warbirds" )

			local WarbirdsContent   = vgui.Create( "DIconLayout" )
			NP_CollapsibleCategory[3]:SetContents( WarbirdsContent )
			WarbirdsContent:SetSize( w, 50 )
			WarbirdsContent:SetSpaceY( 5 )
			WarbirdsContent:SetSpaceX( 5 )

				local NP_AircraftContentIconsListItem = {}
				for i = 1,#aircraft do
						NP_AircraftContentIconsListItem[i] = WarbirdsContent:Add( "DImageButton" )
						NP_AircraftContentIconsListItem[i]:SetSize( icon_size, icon_size )
						NP_AircraftContentIconsListItem[i]:SetImage( "vgui/entities/"..aircraft[i]..".vtf" )
						NP_AircraftContentIconsListItem[i].DoClick = function()
							Msg("This is still a work in progress... \n")
							end
				end

NeuroTecSheet:AddSheet( "NeuroPlanes", NP_Scroll, "icon16/control_repeat_blue.png", false, false, "Aviation" )

//NeuroTanks
	local NT_Scroll = vgui.Create( "DScrollPanel" )
	-- NT_Scroll:SetSize( 355, 200 )
	-- NT_Scroll:SetPos( 10, 30 )
	
	local NT_List = vgui.Create( "DIconLayout",NT_Scroll )
	NT_List:SetSize( w, 50 )
	NT_List:SetSpaceY( 5 )
	NT_List:SetSpaceX( 5 )

		local NT_CollapsibleCategory = {}
		NT_CollapsibleCategory[1] = NT_List:Add( "DCollapsibleCategory" )
		NT_CollapsibleCategory[1]:SetSize( w, 50 )
		NT_CollapsibleCategory[1]:SetExpanded( 1 )
		NT_CollapsibleCategory[1]:SetLabel( "Ground Units" )

			local GroundUnitContent   = vgui.Create( "DIconLayout" )
			NT_CollapsibleCategory[1]:SetContents( GroundUnitContent )
			GroundUnitContent:SetSize( w, 50 )
			GroundUnitContent:SetSpaceY( 5 )
			GroundUnitContent:SetSpaceX( 5 )

				local NT_GroundUnitIconsListItem = {}
				for i = 1,4 do
						NT_GroundUnitIconsListItem[i] = GroundUnitContent:Add( "DImageButton" )
						NT_GroundUnitIconsListItem[i]:SetSize( icon_size, icon_size )
						NT_GroundUnitIconsListItem[i]:SetImage( "vgui/entities/"..tank[i]..".vtf" )
						NT_GroundUnitIconsListItem[i].DoClick = function()
							Msg("This is still a work in progress... \n")
							end
				end

		NT_CollapsibleCategory[2] = NT_List:Add( "DCollapsibleCategory" )
		NT_CollapsibleCategory[2]:SetSize( w, 50 )
		NT_CollapsibleCategory[2]:SetExpanded( 1 )
		NT_CollapsibleCategory[2]:SetLabel( "Tanks" )
		
		local TanksContent   = vgui.Create( "DIconLayout" )
		NT_CollapsibleCategory[2]:SetContents( TanksContent )
		TanksContent:SetSize( w, 50 )
		TanksContent:SetSpaceY( 5 )
		TanksContent:SetSpaceX( 5 )

		local NT_TankIconsListItem = {}

		for k,v in pairs( NT_ents_list ) do
			-- print(  )
			NT_TankIconsListItem[k] = TanksContent:Add( "DImageButton" )
			NT_TankIconsListItem[k]:SetSize( icon_size, icon_size )
			NT_TankIconsListItem[k]:SetImage( "vgui/entities/"..v.ClassName..".vtf" )
			NT_TankIconsListItem[k].DoClick = function()
				RunConsoleCommand("neurotec_spawnvehicle", v.ClassName )
			end
			local t = vgui.Create("DLabel", NT_TankIconsListItem[k] )
			-- t:SetPos( 3,3 )
			t:SetSize( 100,100 )
			t:SetFont("HUDNumber")
			t:SetText( v.PrintName )
			-- t:SetWrap(true)
			-- t:SizeToContents()
			-- Label( v.PrintName, NT_TankIconsListItem[k] )
			
		end

		NT_CollapsibleCategory[3] = NT_List:Add( "DCollapsibleCategory" )
		NT_CollapsibleCategory[3]:SetSize( w, 50 )
		NT_CollapsibleCategory[3]:SetExpanded( 1 )
		NT_CollapsibleCategory[3]:SetLabel( "Artillery" )
		
			local ArtilleryContent   = vgui.Create( "DIconLayout" )
			NT_CollapsibleCategory[3]:SetContents( ArtilleryContent )
			ArtilleryContent:SetSize( w, 50 )
			ArtilleryContent:SetSpaceY( 5 )
			ArtilleryContent:SetSpaceX( 5 )

				local NT_ArtilleryIconsListItem = {}
				for i = 1,#tank do
						NT_ArtilleryIconsListItem[i] = ArtilleryContent:Add( "DImageButton" )
						NT_ArtilleryIconsListItem[i]:SetSize( icon_size, icon_size )
						NT_ArtilleryIconsListItem[i]:SetImage( "vgui/entities/"..tank[i]..".vtf" )
						NT_ArtilleryIconsListItem[i].DoClick = function()
							Msg("This is still a work in progress... \n")
							end
				end

NeuroTecSheet:AddSheet( "NeuroTanks", NT_Scroll, "icon16/control_repeat_blue.png", false, false, "Ground Forces!" )

//NeuroNaval
	local NN_Scroll = vgui.Create( "DScrollPanel" )
	
	local NN_List = vgui.Create( "DIconLayout",NN_Scroll )
	NN_List:SetSize( w, 50 )
	NN_List:SetSpaceY( 5 )
	NN_List:SetSpaceX( 5 )

		local NN_CollapsibleCategory = {}
		NN_CollapsibleCategory[1] = NN_List:Add( "DCollapsibleCategory" )
		NN_CollapsibleCategory[1]:SetSize( w, 50 )
		NN_CollapsibleCategory[1]:SetExpanded( 1 )
		NN_CollapsibleCategory[1]:SetLabel( "Battleships" )

			local BattleshipsContent   = vgui.Create( "DIconLayout" )
			NN_CollapsibleCategory[1]:SetContents( BattleshipsContent )
			BattleshipsContent:SetSize( w, 50 )
			BattleshipsContent:SetSpaceY( 5 )
			BattleshipsContent:SetSpaceX( 5 )

				local NN_BattleshipsContentIconsListItem = {}
				for i = 1,#aircraft do
						NN_BattleshipsContentIconsListItem[i] = BattleshipsContent:Add( "DImageButton" )
						NN_BattleshipsContentIconsListItem[i]:SetSize( icon_size, icon_size )
						NN_BattleshipsContentIconsListItem[i]:SetImage( "vgui/entities/"..aircraft[i]..".vtf" )
						NN_BattleshipsContentIconsListItem[i].DoClick = function()
							Msg("This is still a work in progress... \n")
							end
				end

		NN_CollapsibleCategory[2] = NN_List:Add( "DCollapsibleCategory" )
		NN_CollapsibleCategory[2]:SetSize( w, 50 )
		NN_CollapsibleCategory[2]:SetExpanded( 1 )
		NN_CollapsibleCategory[2]:SetLabel( "Submarines" )
		
			local SubmarinesContent   = vgui.Create( "DIconLayout" )
			NP_CollapsibleCategory[2]:SetContents( SubmarinesContent )
			SubmarinesContent:SetSize( w, 50 )
			SubmarinesContent:SetSpaceY( 5 )
			SubmarinesContent:SetSpaceX( 5 )

				local NN_SubmarinesIconsListItem = {}
				for i = 1,#helicopter do
						NN_SubmarinesIconsListItem[i] = SubmarinesContent:Add( "DImageButton" )
						NN_SubmarinesIconsListItem[i]:SetSize( icon_size, icon_size )
						NN_SubmarinesIconsListItem[i]:SetImage( "vgui/entities/"..helicopter[i]..".vtf" )
						NN_SubmarinesIconsListItem[i].DoClick = function()
							Msg("This is still a work in progress... \n")
							end
				end

NeuroTecSheet:AddSheet( "NeuroNaval", NN_Scroll, "icon16/control_repeat_blue.png", false, false, "Naval strike!" )

//Miscellaneous
	local NMisc_Scroll = vgui.Create( "DScrollPanel" )
	
	local NMisc_List = vgui.Create( "DIconLayout",NMisc_Scroll )
	NMisc_List:SetSize( w, 50 )
	NMisc_List:SetSpaceY( 5 )
	NMisc_List:SetSpaceX( 5 )

		local NMisc_CollapsibleCategory = {}
		NMisc_CollapsibleCategory[1] = NMisc_List:Add( "DCollapsibleCategory" )
		NMisc_CollapsibleCategory[1]:SetSize( w, 50 )
		NMisc_CollapsibleCategory[1]:SetExpanded( 1 )
		NMisc_CollapsibleCategory[1]:SetLabel( "Admin" )

			local MiscContent_1   = vgui.Create( "DIconLayout" )
			NMisc_CollapsibleCategory[1]:SetContents( MiscContent_1 )
			MiscContent_1:SetSize( w, 50 )
			MiscContent_1:SetSpaceY( 5 )
			MiscContent_1:SetSpaceX( 5 )

				local NMisc_MiscContentIconsListItem_1 = {}
				for i = 1,#base_weapons do
						NMisc_MiscContentIconsListItem_1[i] = MiscContent_1:Add( "DImageButton" )
						NMisc_MiscContentIconsListItem_1[i]:SetSize( icon_size, icon_size )
						NMisc_MiscContentIconsListItem_1[i]:SetImage( "vgui/entities/"..base_weapons[i]..".vtf" )
						NMisc_MiscContentIconsListItem_1[i].DoClick = function()
							Msg("This is still a work in progress... \n")
							end
				end

		NMisc_CollapsibleCategory[2] = NMisc_List:Add( "DCollapsibleCategory" )
		NMisc_CollapsibleCategory[2]:SetSize( w, 50 )
		NMisc_CollapsibleCategory[2]:SetExpanded( 1 )
		NMisc_CollapsibleCategory[2]:SetLabel( "Work in Progress" )
		
			local MiscContent_2   = vgui.Create( "DIconLayout" )
			NMisc_CollapsibleCategory[2]:SetContents( MiscContent_2 )
			MiscContent_2:SetSize( w, 50 )
			MiscContent_2:SetSpaceY( 5 )
			MiscContent_2:SetSpaceX( 5 )

				local NMisc_MiscContentIconsListItem_2 = {}
				for i = 1,#aircraft do
						NMisc_MiscContentIconsListItem_2[i] = MiscContent_2:Add( "DImageButton" )
						NMisc_MiscContentIconsListItem_2[i]:SetSize( icon_size, icon_size )
						NMisc_MiscContentIconsListItem_2[i]:SetImage( "vgui/entities/"..aircraft[i]..".vtf" )
						NMisc_MiscContentIconsListItem_2[i].DoClick = function()
							Msg("This is still a work in progress... \n")
							end
				end

		NMisc_CollapsibleCategory[3] = NMisc_List:Add( "DCollapsibleCategory" )
		NMisc_CollapsibleCategory[3]:SetSize( w, 50 )
		NMisc_CollapsibleCategory[3]:SetExpanded( 1 )
		NMisc_CollapsibleCategory[3]:SetLabel( "Work in Progress" )
		
			local MiscContent_3   = vgui.Create( "DIconLayout" )
			NMisc_CollapsibleCategory[3]:SetContents( MiscContent_3 )
			MiscContent_3:SetSize( w, 50 )
			MiscContent_3:SetSpaceY( 5 )
			MiscContent_3:SetSpaceX( 5 )

				local EntView = MiscContent_3:Add( "DModelPanel" )
				EntView:SetModel( "models/hawx/planes/A-6 Intruder.mdl" )
				EntView:SetSize( icon_size*2, icon_size*2 )
				EntView:SetCamPos( Vector( 512, 512, 512 ) )
				EntView:SetLookAt( Vector( 0, 0, 0 ) )
				
				local NMisc_MiscContentIconsListItem_3 = {}
				for i = 1,#tank do
						NMisc_MiscContentIconsListItem_3[i] = MiscContent_3:Add( "DImageButton" )
						NMisc_MiscContentIconsListItem_3[i]:SetSize( icon_size, icon_size )
						NMisc_MiscContentIconsListItem_3[i]:SetImage( "vgui/entities/"..tank[i]..".vtf" )
						NMisc_MiscContentIconsListItem_3[i].DoClick = function()
							Msg("This is still a work in progress... \n")
							end
				end

NeuroTecSheet:AddSheet( "Miscellaneous", NMisc_Scroll, "icon16/control_repeat_blue.png", false, false, "Work in Progress" )


	return NeuroTecSheet
	
end
spawnmenu.AddCreationTab( "NeuroTec", NeuroTecCreateContentTab, "icon16/control_repeat_blue.png", 200 )
