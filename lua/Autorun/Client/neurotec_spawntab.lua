/*********************************************************************/
/* 																	 */
/*  					NEUROTEC MANAGER							 */
/* 																	 */
/*********************************************************************/

-- local NP,NT,NN,NW = {},{},{},{}

NP_ents_list = {}
NP_ents_helicopters_list = {}
NP_ents_warbirds_list = {}
NT_ents_list = {}
NT_ents_ground_list = {}
NT_ents_cars_list = {}
NT_ents_artillery_list = {}
NT_ents_AAgun_list = {}
NN_ents_list = {}
NN_ents_submarines_list = {}
NW_ents_list = {}
NW_ents_bomb_list = {}
NW_ents_missile_list = {}
NW_ents_gun_list = {}
NW_ents_mine_list = {}
N_ents_misc_list = {}
hook.Add("InitPostEntity", "NeuroTecBuildSpawnMenu", function() 

	for k, v in pairs( scripted_ents.GetSpawnable( )) do
		
		if( v.Category ) then 
			
			//aviation
			local cat = string.lower( v.Category )
			if( (v.VehicleType == VEHICLE_PLANE) || string.find( cat, "neurotec aviation" ) || string.find( cat, "neurotec civil" ) ) then
				table.insert( NP_ents_list, v )
			end
			if( (v.VehicleType == VEHICLE_WARBIRD) && string.find( cat, "neurotec warbirds" ) ) then
				table.insert( NP_ents_warbirds_list, v )
			end
			if ( (v.VehicleType == VEHICLE_HELICOPTER) ) then
				table.insert( NP_ents_helicopters_list, v )
			end			
			//misc
			if( string.find( cat, "neurotec fun" ) || string.find( cat, "neurotec admin" ) || string.find( cat, "neurotec work" ) ) then
				table.insert( N_ents_misc_list, v )
			end
			//tanks
			if( v.TankType && (v.VehicleType == TANK_TYPE_CAR) ) then
				table.insert( NT_ents_cars_list, v )			
			elseif( v.TankType && (v.VehicleType == TANK_TYPE_ARTILLERY) ) then
				table.insert( NT_ents_artillery_list, v )			
			elseif( v.TankType && (v.VehicleType == TANK_TYPE_AA) ) then
				table.insert( NT_ents_AAgun_list, v )
			elseif( v.TankType && ((v.VehicleType == TANK_TYPE_LIGHT)or(v.VehicleType == TANK_TYPE_MEDIUM)or(v.VehicleType == TANK_TYPE_HEAVY)or(v.VehicleType == TANK_TYPE_SUPERHEAVY) )) then
				table.insert( NT_ents_list, v )			
			elseif( v.TankType && string.find( cat, "neurotec tanks" ) || string.find( cat, "neurotec ground" ) ) then
				table.insert( NT_ents_ground_list, v )
			end
			//naval
			if (v.VehicleType == VEHICLE_SUBMARINE  )  then
				table.insert( NN_ents_submarines_list, v )	
			elseif( string.find( cat, "neurotec naval" )  ) then
				table.insert( NN_ents_list, v )
			end
			//weapons
			if (v.WeaponType == WEAPON_BOMB  ) then
				table.insert( NW_ents_bomb_list, v )
			elseif (v.WeaponType == WEAPON_MISSILE  ) or (v.WeaponType == WEAPON_ROCKET  )or (v.WeaponType == WEAPON_TORPEDO  ) then
				table.insert( NW_ents_missile_list, v )
			elseif (v.WeaponType == WEAPON_GUN  ) then
				table.insert( NW_ents_gun_list, v )
			elseif (v.WeaponType == WEAPON_MINE  ) then
				table.insert( NW_ents_mine_list, v )
			elseif( string.find( cat, "neurotec weapons" ) ) then
				table.insert( NW_ents_list, v )
			end
			
		end
		
	end
-- PrintTable(NP_ents_warbirds_list)
end )

-- ***************************************delete this line to see the Neuro Tab (doesn't work yet)********************************************
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

/*
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
			NT_TankIconsListItem[k].label = NeuroTecCreateContentTab_Label(NT_TankIconsListItem[k],v.PrintName,icon_size)
			NT_TankIconsListItem[k]:SetSize( icon_size, icon_size )
			NT_TankIconsListItem[k]:SetImage( "vgui/entities/"..v.ClassName..".vtf" )
			NT_TankIconsListItem[k].DoClick = function()
				RunConsoleCommand("neurotec_spawnvehicle", v.ClassName )
				NT_TankIconsListItem[k].label:SetText( "Go!" )
				end
			NT_TankIconsListItem[k].OnCursorEntered = function() NT_TankIconsListItem[k].label:SetText( "" ) end
			NT_TankIconsListItem[k].OnCursorExited = function() NT_TankIconsListItem[k].label:SetText( v.PrintName ) end
		
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
*/
//NeuroPlanes
local Aviation = { {Category = "Aircraft",
				CategoryEntities = NP_ents_list
				},
				{Category ="Helicopters",
				CategoryEntities = NP_ents_helicopters_list
				},
				{Category = "Warbirds",
				CategoryEntities = NP_ents_warbirds_list
				}
			}	
local NeuroPlaneTab = NeuroTecCreateContentTab_CollapsibleCatergoriesSpawnicons(Aviation,w,icon_size)
NeuroTecSheet:AddSheet( "NeuroPlanes", NeuroPlaneTab, "icon16/control_repeat_blue.png", false, false, "Test" )

//NeuroTanks
local Tanks = { {Category ="Tanks",
				CategoryEntities = NT_ents_list
				},
				{Category ="Wheeled Armor",
				CategoryEntities = NT_ents_cars_list
				},
				{Category = "AntiAir vehicles",
				CategoryEntities = NT_ents_AAgun_list
				},
				{Category ="Artillery",
				CategoryEntities = NT_ents_artillery_list
				}
			}

local NeuroTanksTab = NeuroTecCreateContentTab_CollapsibleCatergoriesSpawnicons(Tanks,w,icon_size)
NeuroTecSheet:AddSheet( "NTanks", NeuroTanksTab, "icon16/control_repeat_blue.png", false, false, "Test" )

//NeuroNaval
local Naval = { {Category = "Battleships",
				CategoryEntities = NN_ents_list
				},
				{Category = "Submarines",
				CategoryEntities = NN_ents_submarines_list
				}
			}
local NeuroNavalTab = NeuroTecCreateContentTab_CollapsibleCatergoriesSpawnicons(Naval,w,icon_size)
NeuroTecSheet:AddSheet( "NeuroNaval", NeuroNavalTab, "icon16/control_repeat_blue.png", false, false, "Test" )

//NeuroWeapons
local Weapons = { {Category = "Weapons",
				CategoryEntities = NW_ents_list
				},
				{Category = "Bombs",
				CategoryEntities = NW_ents_bomb_list
				},
				{Category = "Missiles and Rockets",
				CategoryEntities = NW_ents_missile_list
				},
				{Category = "Turrets and guns",
				CategoryEntities = NW_ents_gun_list
				},
				{Category = "Mines",
				CategoryEntities = NW_ents_mine_list
				}
			}
local NeuroWeaponsTab = NeuroTecCreateContentTab_CollapsibleCatergoriesSpawnicons(Weapons,w,icon_size)
NeuroTecSheet:AddSheet( "NeuroWeapons", NeuroWeaponsTab, "icon16/control_repeat_blue.png", false, false, "Test" )

//Miscellaneous
local Miscellaneous = { {Category = "Misc",
				CategoryEntities = N_ents_misc_list
				}
			}
local NeuroMiscTab = NeuroTecCreateContentTab_CollapsibleCatergoriesSpawnicons(Miscellaneous,w,icon_size)
NeuroTecSheet:AddSheet( "Miscellaneous", NeuroMiscTab, "icon16/control_repeat_blue.png", false, false, "Test" )

	return NeuroTecSheet
	
end
spawnmenu.AddCreationTab( "NeuroTec", NeuroTecCreateContentTab, "icon16/control_repeat_blue.png", 200 )

function NeuroTecCreateContentTab_CollapsibleCatergoriesSpawnicons(CategoriesList,width,icon_size)

	local Scroll = vgui.Create( "DScrollPanel" )
	-- NT_Scroll:SetSize( 355, 200 )
	-- NT_Scroll:SetPos( 10, 30 )
	
	local List = vgui.Create( "DIconLayout",Scroll )
	List:SetSize( width, 50 )
	List:SetSpaceY( 5 )
	List:SetSpaceX( 5 )

		local CollapsibleCategory = {}
		local CategoryContent = {}
		for i=1,#CategoriesList do
		CollapsibleCategory[i] = List:Add( "DCollapsibleCategory" )
		CollapsibleCategory[i]:SetSize( width, 50 )
		CollapsibleCategory[i]:SetExpanded( 1 )
		if CategoriesList[i].Category then
		CollapsibleCategory[i]:SetLabel( CategoriesList[i].Category )
		end
		
			CategoryContent[i]   = vgui.Create( "DIconLayout" )
			CollapsibleCategory[i]:SetContents( CategoryContent[i] )
			CategoryContent[i]:SetSize( width, 50 )
			CategoryContent[i]:SetSpaceY( 5 )
			CategoryContent[i]:SetSpaceX( 5 )
			
				local CategoryContentIconsListItem = {}
				if CategoriesList[i].CategoryEntities then
					for k,v in pairs( CategoriesList[i].CategoryEntities ) do			
							CategoryContentIconsListItem[k] = CategoryContent[i]:Add( "DImageButton" )
							CategoryContentIconsListItem[k].label = NeuroTecCreateContentTab_Label(CategoryContentIconsListItem[k],v.PrintName,icon_size)
							CategoryContentIconsListItem[k]:SetSize( icon_size, icon_size )
							CategoryContentIconsListItem[k]:SetImage( "vgui/entities/"..v.ClassName..".vtf" )
							CategoryContentIconsListItem[k].DoClick = function()
								RunConsoleCommand("neurotec_spawnvehicle", v.ClassName )
								CategoryContentIconsListItem[k].label:SetText( "Go!" )
								end
							CategoryContentIconsListItem[k].OnCursorEntered = function()
								CategoryContentIconsListItem[k].label:SetText( "" )
								//Need to code a windows which displays entity's status here.
								end
							
							CategoryContentIconsListItem[k].OnCursorExited = function()
								CategoryContentIconsListItem[k].label:SetText( v.PrintName )
								//close the windows status here
								end
					end				
				end				
		end
		

	return Scroll
end

function NeuroTecCreateContentTab_Label(parent,text,icon_size)

	local t = vgui.Create("DLabel", parent )
	t:SetText( text )
	t:SetFont("ChatFont")
	-- t:SetPos( (icon_size-string.len(text))/2,icon_size-20 )
	t:SetPos( 5, icon_size-20 )
	-- t:SetSize( icon_size,50 )
	-- t:SetWrap(true)
	t:SizeToContents()
	-- Label( v.PrintName, NT_TankIconsListItem[k] )

	return t
end