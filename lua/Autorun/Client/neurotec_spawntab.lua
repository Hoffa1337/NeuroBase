/*********************************************************************/
/* 																	 */
/*  					NEUROTEC MANAGER							 */
/* 																	 */
/*********************************************************************/

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

NB_sweps_list = {}
NB_tools_list = {}

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
			if( v.TankType && (v.TankType == TANK_TYPE_CAR) ) then
				table.insert( NT_ents_cars_list, v )			
			elseif( v.TankType && (v.TankType == TANK_TYPE_ARTILLERY) && !(v.VehicleType == STATIC_GUN) ) then
				table.insert( NT_ents_artillery_list, v )			
			elseif( v.TankType && (v.TankType == TANK_TYPE_AA) ) then
				table.insert( NT_ents_AAgun_list, v )
			elseif( v.TankType && ((v.TankType == TANK_TYPE_LIGHT)or(v.TankType == TANK_TYPE_MEDIUM)or(v.TankType == TANK_TYPE_HEAVY)or(v.TankType == TANK_TYPE_SUPERHEAVY) )) then
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
			elseif (v.WeaponType == WEAPON_GUN  )or(v.VehicleType == STATIC_GUN  )or(v.VehicleType == WEAPON_TURRET  ) then
				table.insert( NW_ents_gun_list, v )
			elseif (v.WeaponType == WEAPON_MINE  ) then
				table.insert( NW_ents_mine_list, v )
			elseif( string.find( cat, "neurotec weapons" ) ) then
				table.insert( NW_ents_list, v )
			end
			
		end
		
-- PrintTable(NP_ents_warbirds_list)
	end
	
	table.SortByMember( NT_ents_list, "Category", true )
	
	for k, v in pairs( weapons.GetList( )) do
		if( v.Category ) then 
		local cat = string.lower( v.Category )			
			if( string.find( cat, "neurotec weapons" ) )	then			
				table.insert( NB_sweps_list, v )
			end
			if( string.find( cat, "military accessories" ) )	then
				table.insert( NB_tools_list, v )
			end
		end
	end
	-- PrintTable(NB_tools_list)
end )

local function NeuroTecCreateContentTab()

local ply = LocalPlayer()

local icon_size = 200
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
				for i = 1,#NB_sweps_list do
						-- NB_SwepsContentIconsListItem[i] = SwepsContent:Add( "DImageButton" )
						-- NB_SwepsContentIconsListItem[i]:SetSize( icon_size, icon_size )
						-- NB_SwepsContentIconsListItem[i]:SetImage( "vgui/entities/"..NB_sweps_list[i]..".vtf" )
						-- NB_SwepsContentIconsListItem[i].DoClick = function()
							-- Msg("This is still a work in progress... \n")
							-- end			-- NB_SwepsContentIconsListItem[i] = SwepsContent:Add( "DImageButton" )
						NB_SwepsContentIconsListItem[i] = SwepsContent:Add( "ContentIcon" )
						-- NB_SwepsContentIconsListItem[i]:SetSize( icon_size, icon_size )
						NB_SwepsContentIconsListItem[i]:SetMaterial( "vgui/entities/"..NB_sweps_list[i].ClassName..".vtf" )
						NB_SwepsContentIconsListItem[i]:SetName( NB_sweps_list[i].PrintName )
						NB_SwepsContentIconsListItem[i].DoClick = function() RunConsoleCommand( "gm_spawnswep", NB_sweps_list[i].ClassName ) end
						NB_SwepsContentIconsListItem[i].OpenMenu = function()
							local menu = DermaMenu()
							menu:AddOption( "Copy to clipboard", function() SetClipboardText( NB_sweps_list[i].ClassName ) ply:ChatPrint( NB_sweps_list[i].PrintName.." copied to clipboard." ) end )
							menu:Open()
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
				for i = 1,#NB_tools_list do
						-- NB_ToolsIconsListItem[i] = ToolsContent:Add( "DImageButton" )
						-- NB_ToolsIconsListItem[i]:SetSize( icon_size, icon_size )
						-- NB_ToolsIconsListItem[i]:SetImage( "vgui/entities/"..NB_tools_list[i].ClassName..".vtf" )
						-- NB_ToolsIconsListItem[i].DoClick = function()
							-- Msg("This is still a work in progress... \n")
							-- end
						NB_ToolsIconsListItem[i] = ToolsContent:Add( "ContentIcon" )
						-- NB_ToolsIconsListItem[i]:SetSize( icon_size, icon_size )
						NB_ToolsIconsListItem[i]:SetMaterial( "vgui/entities/"..NB_tools_list[i].ClassName..".vtf" )
						NB_ToolsIconsListItem[i]:SetName( NB_tools_list[i].PrintName )
						NB_ToolsIconsListItem[i].DoClick = function() RunConsoleCommand( "give", NB_tools_list[i].ClassName ) end
						NB_ToolsIconsListItem[i].OpenMenu = function()
							local menu = DermaMenu()
							menu:AddOption( "Copy to clipboard", function() SetClipboardText( NB_tools_list[i].ClassName ) ply:ChatPrint( NB_sweps_list[i].PrintName.." copied to clipboard." ) end )
							menu:Open()
						end
				end

NeuroTecSheet:AddSheet( "NeuroBase", NB_Scroll, "icon16/control_repeat_blue.png", false, false, "NeuroTec SWEPs" )

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
NeuroTecSheet:AddSheet( "NeuroPlanes", NeuroPlaneTab, "vgui/plane.png", false, false, "Test" )

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
				{Category = "Other Ground Vehicles",
				CategoryEntities = NT_ents_ground_list
				},
				{Category ="Artillery",
				CategoryEntities = NT_ents_artillery_list
				}
			}

local NeuroTanksTab = NeuroTecCreateContentTab_CollapsibleCatergoriesSpawnicons(Tanks,w,icon_size)
NeuroTecSheet:AddSheet( "NeuroTanks", NeuroTanksTab, "vgui/tank.png", false, false, "Armored Ground Units" )

//NeuroNaval
local Naval = { {Category = "Battleships",
				CategoryEntities = NN_ents_list
				},
				{Category = "Submarines",
				CategoryEntities = NN_ents_submarines_list
				}
			}
local NeuroNavalTab = NeuroTecCreateContentTab_CollapsibleCatergoriesSpawnicons(Naval,w,icon_size)
NeuroTecSheet:AddSheet( "NeuroNaval", NeuroNavalTab, "vgui/anchor.png", false, false, "Avast Ye Matey!" )

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
NeuroTecSheet:AddSheet( "NeuroWeapons", NeuroWeaponsTab, "vgui/weps.png", false, false, "Weapons of Mass Mingebagging" )

//Miscellaneous
local Miscellaneous = { {Category = "Misc",
				CategoryEntities = N_ents_misc_list
				}
			}
local NeuroMiscTab = NeuroTecCreateContentTab_CollapsibleCatergoriesSpawnicons(Miscellaneous,w,icon_size)
NeuroTecSheet:AddSheet( "Miscellaneous", NeuroMiscTab, "icon16/control_repeat_blue.png", false, false, "Various Stuff" )

	return NeuroTecSheet
	
end
spawnmenu.AddCreationTab( "NeuroTec", NeuroTecCreateContentTab, "vgui/skull.png", 200 )

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
				local StatsPanel = {}
				if CategoriesList[i].CategoryEntities then
					for k,v in pairs( CategoriesList[i].CategoryEntities ) do			
							CategoryContentIconsListItem[k] = CategoryContent[i]:Add( "DImageButton" )
							CategoryContentIconsListItem[k].label = NeuroTecCreateContentTab_Label(CategoryContentIconsListItem[k],v,icon_size)
							CategoryContentIconsListItem[k]:SetSize( icon_size, icon_size )
							local _icon = "vgui/entities/"..v.ClassName..".vtf"
							if( !file.Exists( "materials/".._icon, "GAME" ) ) then
								_icon = "vgui/error.png"
							end
							CategoryContentIconsListItem[k]:SetImage( _icon )

							CategoryContentIconsListItem[k].DoClick = function()
								RunConsoleCommand("neurotec_spawnvehicle", v.ClassName )
								-- CategoryContentIconsListItem[k].label:SetText( "Go!" )
								end
							CategoryContentIconsListItem[k].DoRightClick = function()
								NeuroTecCreateContentTab_StatsPanel(StatsPanel[k],Scroll,v)
								end
							CategoryContentIconsListItem[k].OnCursorEntered = function()
								-- CategoryContentIconsListItem[k].label:SetText( "" )
								end							
							CategoryContentIconsListItem[k].OnCursorExited = function()
								-- CategoryContentIconsListItem[k].label:SetText( v.PrintName )
								end
					end				
				end				
		end
		

	return Scroll
end
local __Stats ={}
local function GenerateTankStats( parent, text, icon_size )

end

hook.Add("Initialize", "NTSP_AddFonts", function()

	surface.CreateFont( "NeuroTankSpawnName", {
	 font = "Impact",
	 size = 20,
	 weight = 400,
	 blursize = 0,
	 scanlines = 0,
	 antialias = true,
	 underline = false,
	 italic = false,
	 strikeout = false,
	 symbol = false,
	 rotary = false,
	 shadow = false,
	 additive = false,
	 outline = true
	} )

end )

function NeuroTecCreateContentTab_Label(parent,text,icon_size)

	local name = text.PrintName

	if( string.find( text.Category, "NeuroTec Tanks - " ) != nil ) then
		
		local maxspeed = 62
		local maxdamage = 5000
		local maxhealth = 9000
		
		__Stats = {
					{ "Speed", ( text.MaxVelocity or 0 ) / maxspeed };
					{ "Armor" , ( text.InitialHealth or 0 ) / maxhealth };
					{ ( text.MinDamage or "nil" ).."-"..( text.MaxDamage or "nil" ), ( text.MaxDamage or 0 ) / maxdamage  };
					
				}
					
		local size = 14
		local graph_size = icon_size/2.5
		local xp,yp = icon_size - graph_size, icon_size - ( size * ( #__Stats + 1 ) )-- icon_size-70
		local _font = "ChatFont"
		
		name = name.. " / "..string.Replace( text.Category, "NeuroTec Tanks - ", "" )
		-- local tier = vgui.Create("DLabel", parent )
		-- tier:SetText( string.Replace( text.Category, "NeuroTec Tanks - ", "" ) )
		-- tier:SetFont("ChatFont")
		-- tier:SetPos( xp, yp+(#__Stats+1*size) )
		-- tier:SizeToContents()
		
		for _k,v in pairs( __Stats ) do
		
			local DProgress = vgui.Create( "DProgress", parent )
			DProgress:SetPos( xp, yp+(size*_k-2) )
			DProgress:SetSize( graph_size, size )
			DProgress:SetFraction(  v[2] )
			
			local lb = vgui.Create("DLabel", parent )
			lb:SetText( v[1] )
			lb:SetTextColor( Color( 0, 0, 0, 150 ) ) -- 
			lb:SetFont( _font )
			lb:SetPos( xp+2, yp+(size*_k-2) )
			lb:SizeToContents()
			
		end
					
	
	end
		
	local t = vgui.Create("DLabel", parent )
	t:SetText( name )
	t:SetFont("NeuroTankSpawnName")
	t:SetPos( 5, 5 )
	-- t:SetTextColor( Color( 
	t:SizeToContents()
	
	return t
	
end

function NeuroTecCreateContentTab_StatsPanel(frame,parent,ent)

	local w,h = ScrW(),ScrH()

	if (frame!=nil) then frame:Close() end
	-- frame = vgui.Create( "DFrame", parent )
	frame = vgui.Create( "DFrame" )
	frame:SetPos( w*0.03, h*0.15 )
	frame:SetSize( h, h*0.8 )
	frame:SetTitle( ent.PrintName )
	frame:SetDraggable( true )
	frame:SetSizable( false )
	frame:ShowCloseButton( true )
	frame:MakePopup()
	
	local panel = vgui.Create( "DPanel", frame )
	-- panel:SetParent( frame )
	panel:SetPos( 4, 25 )
	panel:SetSize( h-8, h*0.8-28 )
	panel:SetBackgroundColor(Color(255,255,255,100))
	
	if ent.Model then
		local View = vgui.Create( "DAdjustableModelPanel", panel )
		View:SetModel( ent.Model )
		View:SetPos( 0, 2 )
		View:SetSize( h*0.6-6, h*0.4 )
		View:SetCamPos( Vector( 512, 512, 512 ) )
		View:SetLookAt( Vector( 0, 0, 0 ) )
	else
		local lb = vgui.Create("DLabel", panel )
		lb:SetText( "Interactive view of the entity" )
		-- lb:SetTextColor( Color( 0, 0, 0, 150 ) ) -- 
		-- lb:SetFont( _font )
		lb:SetPos( h*0.2, h*0.2 )
		lb:SizeToContents()
	end
	
	local NeuroProperties = vgui.Create( "DProperties",panel )
	NeuroProperties:SetPos( 2, h*0.4 )
	-- NeuroProperties:SetSize( h-10, h*0.8-h*0.4-2 )
	NeuroProperties:SetSize( h-10, h*0.4-32 )

	//Description (Wiki?)
	if (ent.Description) then
		local Name = NeuroProperties:CreateRow( ent.PrintName, "Type" )
		Name:Setup( "Generic" )
		Name:SetValue( ent.Description )
		Name.DataChanged = function( _, val ) print( val ) end
	end
	if (ent.Category) then
		local Name = NeuroProperties:CreateRow( ent.PrintName, "Category" )
		Name:Setup( "Generic" )
		Name:SetValue( ent.Category )
		Name.DataChanged = function( _, val ) print( val ) end
	end
	local Country = NeuroProperties:CreateRow( ent.PrintName, "Country" )
	Country:Setup( "Generic" )
	Country:SetValue( "N/A" )
	Country.DataChanged = function( _, val ) print( val ) end

	if (ent.MaxVelocity) then
		local Speed = NeuroProperties:CreateRow( ent.PrintName, "Speed" )
		Speed:Setup( "Generic" )
		Speed:SetValue( "".. ent.MaxVelocity .." units/s" )
		Speed.DataChanged = function( _, val ) print( val ) end
	end
	//Armament
	if (ent.InitialHealth) then
		local Speed = NeuroProperties:CreateRow( ent.PrintName, "Armor (HP)" )
		Speed:Setup( "Generic" )
		Speed:SetValue( ent.InitialHealth )
		Speed.DataChanged = function( _, val ) print( val ) end
	end
	if (ent.AmmoTypes) then
		local Ammo={}
		for i=1,#ent.AmmoTypes do
			Ammo[i] = NeuroProperties:CreateRow( "Armament", "Ammo" )
			Ammo[i]:Setup( "Generic" )
			Ammo[i]:SetValue( AmmoTypes[i].PrintName )
			Ammo[i].DataChanged = function( _, val ) print( val ) end
		end
	end
		if (ent.Armament) then
		local Ammo={}
		for i=1,#ent.Armament do
			if (ent.Armament[i].Type != "Effect") or !(ent.Armament[i].Type != "Flarepod") then
				Ammo[i] = NeuroProperties:CreateRow( "Armament", "Ammo "..i )
				Ammo[i]:Setup( "Generic" )
				Ammo[i]:SetValue( ent.Armament[i].PrintName )
				Ammo[i].DataChanged = function( _, val ) print( val ) end
			end
		end
	end
	if (ent.MaxRange) then
		local MaxRange = NeuroProperties:CreateRow( ent.PrintName, "Maximum Range" )
		MaxRange:Setup( "Generic" )
		MaxRange:SetValue( ent.MaxRange )
		MaxRange.DataChanged = function( _, val ) print( val ) end
	end
	
	//Customize
	local Lock = NeuroProperties:CreateRow( "Custom", "Lock? (Unavailable)" )
	Lock:Setup( "Boolean" )
	Lock:SetValue( true )
	local Skin = NeuroProperties:CreateRow( "Custom", "Skin (Unavailable)" )
	Skin:Setup( "Float", {min = 0, max = 5} )
	Skin:SetValue( 0 )
	local color = NeuroProperties:CreateRow( "Custom", "Color (Unavailable)" )
	color:Setup( "VectorColor" )
	color:SetValue( Vector( 1, 0, 0 ) )
	
	local summary = vgui.Create( "DPanel", frame )
	-- summary:SetParent( frame )
	summary:SetPos( h+2-h*0.4, 27 )
	summary:SetSize( h*0.4-8, h*0.4-4 )
	summary:SetBackgroundColor(Color(255,255,255,100))

	// return panel
end