local PANEL = {}

function PANEL:Init()

	local w,h = ScrW(),ScrH()
	local _f = "DefaultFixed"
	local blk = Color(0,0,0,255)
	local text
	local wB, hB = w/160, h/30
	
	self.panel = vgui.Create( "DPanel", self )
	self.panel:SetPos( wB*0.9, hB )
	self.panel:SetSize( w-(wB*1.8), h-(hB*1.3) )
	self.panel:SetBackgroundColor(Color(255,255,255,0))
		
	self.threeD = vgui.Create("D3DViewer", self.panel)
	self.threeD:SetPos( 0, 0 )
	self.threeD:SetSize( w-(wB*1.8), h/1.5 )
	self.threeD:SetUp()
	self.threeD:AllowSelection(false)
	
	self.HeightSlider = vgui.Create("DNumSlider", self.panel)
	self.HeightSlider:SetPos(wB*0.9, (h/1.5)+(hB/3))
	self.HeightSlider:SetSize(w-(wB*50), hB)
	self.HeightSlider:SetText("Height")
	self.HeightSlider:SetMin(-250)
	self.HeightSlider:SetMax(50)
	self.HeightSlider:SetDecimals(0)
	self.HeightSlider.OnValueChanged = function(Panel, Value)
		for k,v in pairs(self.HangarModels) do
			local x, y, z = v:GetPos()
			v:SetPos(Vector(-400,0,Value))
		end
	end

	self.BottomPanel = vgui.Create("DPanel", self.panel)
	self.BottomPanel:SetPos(wB*0.9, (h/1.5)+(hB/3)+(hB))
	self.BottomPanel:SetSize(w-(wB*1.8), hB*100)
	self.BottomPanel:SetBackgroundColor(Color(255,255,255,255))
	
	self.SpawnModeCheckbox = vgui.Create( "DCheckBoxLabel", self.BottomPanel )
	self.SpawnModeCheckbox:SetText( "Spawn and enter the vehicle?" )
	self.SpawnModeCheckbox:SetPos( wB, hB*6.5 )
	self.SpawnModeCheckbox:SetConVar( "neurotec_spawn_n_drive" ) 
	self.SpawnModeCheckbox:SetValue( 1 )
	self.SpawnModeCheckbox:SetTextColor(blk)            
	self.SpawnModeCheckbox:SizeToContents()  
	
	self.TempLabel = vgui.Create("DLabel", self.BottomPanel)
	self.TempLabel:SetText("WORK IN PROGRESS")
	-- self.TempLabel:SetPos((w-(wB*1.8))/2, (hB*100)/2)
	self.TempLabel:SetPos((self.BottomPanel:GetSize()/2)-wB*6, hB*3)
	self.TempLabel:SizeToContents() 
	self.TempLabel:SetTextColor(Color(255,0,0,255))
	

end

function PANEL:SpawnModel(ent)
	self.threeD:ClearModels()
	if(ent.VehicleType != nil) then
		if(ent.VehicleType == VEHICLE_PLANE) then
			if(string.find( ent.Category, "Micro" )) then
				self:SpawnHangar(-50)
				self.HeightSlider:SetValue(-50)
				self:SpawnMicroPlane(ent)
			else
				self:SpawnHangar(-50)
				self.HeightSlider:SetValue(-50)
				self:SpawnPlane(ent)
			end
		elseif(ent.VehicleType == VEHICLE_TANK) then
			if(ent.TankType == TANK_TYPE_CAR) then
				self:SpawnHangar(0)
				self.HeightSlider:SetValue(0)
				self:SpawnCar(ent)
			else
				self:SpawnHangar(0)
				self.HeightSlider:SetValue(0)
				self:SpawnTank(ent)
			end
		end
	end
end

function PANEL:SpawnCar(ent)
	local scale = 1
	self.threeD:AddModel(ent.Model, Vector(0,0,0), Angle(0,0,0), scale, false)

	if(ent.WheelMdls != nil) then
		for i=1, #ent.WheelMdls do
			self.threeD:AddModel(ent.WheelMdls[i], ent.WheelAxles[i], ent.WheelAngles[i], scale, false)
		end
	end
	
	if(ent.TowerModel != nil) then
		self.threeD:AddModel(ent.TowerModel, ent.TowerPos, Angle(0,0,0), scale, false)
	end	

	if(ent.BarrelModel != nil) then
		self.threeD:AddModel(ent.BarrelModel, ent.BarrelPos, Angle(0,0,0), scale, false)
	end

	if(ent.MGunModel != nil) then
		self.threeD:AddModel(ent.MGunModel, ent.MGunPos, Angle(0,0,0), scale, false)
	end

end

function PANEL:SpawnTank(ent)
	local scale = 1
	local ang = Angle(0,0,0)
	
	local bodyModel = ent.Model
	local bodyPos = Vector(0,0,5)
	local tank = self.threeD:AddModel(bodyModel, bodyPos, ang, scale, false)
	
	local towerModel = ent.TowerModel
	local towerPos = ent.TowerPos
	local tower = self.threeD:AddModel(towerModel, towerPos, ang, scale, false)
	
	local barrelModel = ent.BarrelModel
	local barrelPos = ent.BarrelPos
	local barrel = self.threeD:AddModel(barrelModel, barrelPos, ang, scale, false)
	
	if(ent.TrackModels != nil) then
		local trackModels = ent.TrackModels
		local trackModelLeft = trackModels[1]
		local trackModelRight = trackModels[2]
		local trackPos = ent.TrackPositions or {Vector(0,0,0), Vector(0,0,0)}
		local trackPosLeft = trackPos[1]
		local trackPosRight = trackPos[2]
		local trackLeft = self.threeD:AddModel(trackModelLeft, trackPosLeft, ang, scale, false)
		local trackRight = self.threeD:AddModel(trackModelRight, trackPosRight, ang, scale, false)
		self:SetUpTracks(trackLeft, "left")
		self:SetUpTracks(trackRight, "right")
	end
	
	local wheelModels = ent.TrackWheels
	if(wheelModels != nil) then
		local wheelModelLeft = wheelModels[1]
		local wheelModelRight = wheelModels[2]
		self.threeD:AddModel(wheelModelLeft, trackPosLeft, ang, scale, false)
		self.threeD:AddModel(wheelModelRight, trackPosLeft, ang, scale, false)
	end
end

function PANEL:SetUpTracks(ent, side)
	if ent then
		if(side == "left") then
			local bMin, bMax = ent:GetRenderBounds()
			bMin = bMin + (-ent:GetAngles():Right() * 30) + (-ent:GetAngles():Forward() * 10)
			bMax = bMax + (-ent:GetAngles():Right() * 10) + (ent:GetAngles():Up() * 10) + (ent:GetAngles():Forward() * 10)
			ent:SetRenderBounds(bMin, bMax)
		elseif(side == "right") then
			local bMin, bMax = ent:GetRenderBounds()
			bMin = bMin + (ent:GetAngles():Right() * 10) + (-ent:GetAngles():Forward() * 10)
			bMax = bMax + (ent:GetAngles():Right() * 30) + (ent:GetAngles():Up() * 10) + (ent:GetAngles():Forward() * 10)
			ent:SetRenderBounds(bMin, bMax)			
		end
	end
end

function PANEL:SpawnPlane(ent)
	local scale = 0.5
	self.threeD:AddModel(ent.Model, Vector(0,0,0), Angle(0,0,0), scale, false)
end

function PANEL:SpawnMicroPlane(ent)
	local scale = 3
	self.threeD:AddModel(ent.Model, Vector(0,0,0), Angle(0,0,0), scale, false)
	if(ent.TailModel != nil) then
		self.threeD:AddModel(ent.TailModel, ent.TailPos, Angle(0,0,0), scale, false)
	end	
	if(ent.WingModels != nil) then
		for i=1, #ent.WingModels do
			self.threeD:AddModel(ent.WingModels[i], ent.WingPositions[i], Angle(0,0,0), scale, false)
		end
	end
	if(ent.ControlSurfaces != nil) then
		self.threeD:AddModel(ent.ControlSurfaces.Elevator.Mdl, ent.ControlSurfaces.Elevator.Pos*scale, ent.ControlSurfaces.Elevator.Ang, scale, false)
		self.threeD:AddModel(ent.ControlSurfaces.Rudder.Mdl, ent.ControlSurfaces.Rudder.Pos*scale, ent.ControlSurfaces.Rudder.Ang, scale, false)
		for _,v in pairs(ent.ControlSurfaces.Ailerons) do
			self.threeD:AddModel(v.Mdl, v.Pos*scale, v.Ang, scale, false)
		end
		if(ent.ControlSurfaces.Flaps != nil) then
			for _,v in pairs(ent.ControlSurfaces.Flaps) do
				self.threeD:AddModel(v.Mdl, v.Pos*scale, v.Ang, scale, false)
			end
		end
	end
	if(ent.PropellerPos != nil) then
		if(type(ent.PropellerPos) == "table") then
			for i=1, #ent.PropellerModels do
				self.threeD:AddModel(ent.PropellerModels[i], ent.PropellerPos[i]*scale, Angle(0,0,0), scale, false)
			end
		else
			if(ent.PropellerModel != nil) then
				self.threeD:AddModel(ent.PropellerModel, ent.PropellerPos, Angle(0,0,0), scale, false)
			end
		end
	end
	if(ent.WheelModels != nil) then
		for i=1, #ent.WheelModels do
			self.threeD:AddModel(ent.WheelModels[i], ent.WheelPos[i]*scale, Angle(0,0,0), scale, false)
		end
	end
	local visuals = {}
	if(ent.VisualModels != nil) then
		for _,v in pairs(ent.VisualModels) do
			local visual = self.threeD:AddModel(v.Mdl, v.Pos*scale, v.Ang, scale, false)
			table.insert(visuals, visual)
		end
	end
	for k,v in pairs(visuals) do
		v:SetColor(0,0,0,255)
		print(v:GetPos())
	end
end

function PANEL:SpawnHangar(height)
	local offset = self.threeD:AddModel("models/error.mdl", Vector(0,0,0), false)
	if(offset) then
		offset:SetMaterial("Models/effects/vol_light001")
		offset:SetAngles(Angle(0,0,180))
	end
	self.HangarModels = {
		self.threeD:AddModel("models/aftokinito/WoT/Misc/hangar_prem1.mdl", Vector(-400,0,height), false),
		self.threeD:AddModel("models/aftokinito/WoT/Misc/hangar_prem2.mdl", Vector(-400,0,height-7), false),
		self.threeD:AddModel("models/aftokinito/WoT/Misc/hangar_prem3.mdl", Vector(-400,0,height), false)
	}
end

function PANEL:SetEnt(ent)
	self.ent = ent
	self:SpawnModel(self.ent)
end

function PANEL:Think( )
	if ( input.IsKeyDown( KEY_TAB ) ) then
		self.threeD:Remove()
		self:Remove()
	end
end

derma.DefineControl("DNeuroSpawnRC","Neuro Menu is cool",PANEL,"DFrame")

print( "[NeuroBase] DNeuroTecSpawnRC.lua loaded!" )