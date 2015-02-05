local PANEL = {}
function PANEL:PaintModel()
	if(!IsValid(self.Entity)) then return end
	local x, y = self:LocalToScreen(0, 0)
	self:LayoutEntity(self.Entity)
   
	local angCam = Angle(self.camAng.p,self.camAng.y,self.camAng.r)
	local posCam = angCam:Forward() *self.camDistance +self:GetCamPos()
	
	cam.Start3D(posCam,(self.vLookatPos -posCam):Angle(),self.fFOV,x,y,self:GetSize())
			cam.IgnoreZ( true )
			render.SuppressEngineLighting(true)
			render.SetLightingOrigin(self.Entity:GetPos())
			render.SetLightingOrigin(Vector(0,0,0))
			render.ResetModelLighting(self.colAmbientLight.r /255,self.colAmbientLight.g /255,self.colAmbientLight.b /255)
			render.SetColorModulation(self.colColor.r /255,self.colColor.g /255,self.colColor.b /255)
			render.SetBlend(self.colColor.a /255)
			for i = 0,6 do
					local col = self.DirectionalLight[i]
					if(col) then
							render.SetModelLighting(i,col.r /255,col.g /255,col.b /255)
					end
			end
			self.Entity:DrawModel()
			if(self.m_tbSubEnts) then
				for _, ent in ipairs(self.m_tbSubEnts) do
						if(ent:IsValid()) then 
							ent:DrawModel()
							if ((GetConVar("developer"):GetInt() > 1) && ent.selectable) then							
								local min, max = ent:GetRenderBounds()
								render.DrawWireframeBox( ent:GetPos(), ent:GetAngles(), min, max, Color(255,255,255,255), true )
							end
						end
				end
			end
			render.SuppressEngineLighting(false)
			cam.IgnoreZ( false )				
	cam.End3D()
	
	self:SetCamPos(self.campos*self.camdist)
	if(self.m_tbSubEnts[1]) then
		self:SetLookAt(self.m_tbSubEnts[1]:GetPos()+Vector(0,0,0))
	else
		self:SetLookAt(Vector(0,0,0))
	end

	self.LastPaint = RealTime()
end
 
function PANEL:Init()
	self:SetDrawOnTop(false)
	self:NoClipping(true)
end
 
function PANEL:SetUp()

	self.pnlModel = vgui.Create("DModelPanel",self)
	self.pnlModel.selected = NULL
	self.pnlModel.selectedModel = NULL
	self.allowSelection = false
	self.maxCam = 650
	self.minCam = 100
	
	local w,h = self:GetSize()
	self.pnlModel:SetSize(w,h)
	self.pnlModel.m_tbSubEnts = {}
	self.pnlModel.camAng = Angle(0,0,0)
	self.pnlModel.camdist = 400
	self.pnlModel.campos = Vector(1,0,0.2)
	self.pnlModel:SetCamPos(Vector(0,0,0))
	self.pnlModel:SetLookAt(Vector(-1,0,0.2))
	self.pnlModel.gX, self.pnlModel.xY = 0
	self.pnlModel:SetPos(0,0)
	self.pnlModel:SetModel("models/error.mdl")
	self.pnlModel.Entity:SetPos(Vector(0,0,-1000))
	self.pnlModel:SetFOV(90)
	self.pnlModel.colAmbientLight = Color(0,0,0,0)
	self.pnlModel.colColor = Color(255,255,255,255)
	self.pnlModel.ScreenToVector = function( panel, sX, sY, sW, sH, ang, fov )
		local d = 4 * sH / ( 6 * math.tan( 0.5 * fov ) )
		local vF = ang:Forward()
		local vR = ang:Right()
		local vU = ang:Up()			
		return ( d * vF + ( sX - 0.5 * sW ) * vR + ( 0.5 * sH - sY ) * vU ):GetNormalized()
	end		
	self.pnlModel:SetPaintedManually(true)
	self.pnlModel.Paint = self.PaintModel
	self.pnlModel:SetCamPos(self.pnlModel.campos*self.pnlModel.camdist)
	self.pnlModel:SetAmbientLight(Vector( 25, 25, 25 ))
	self.pnlModel.LayoutEntity = function(pnl)
			pnl:RunAnimation()
	end			
	self.click = false
	
	self.touchPnl = vgui.Create("DPanel",self)
	local width, height = self:GetSize()
	local x, y = self:GetPos()
	self.touchPnl:SetSize(width, height)
	self.touchPnl:SetPos(x, y)
	self.xL, self.yL = 0, 0
	
	self.touchPnl.OnMousePressed = function(panel, mc)
		self:OnMouseClick(mc, self.pnlModel.gX, self.pnlModel.gY)
		
		if(self.allowSelection) then
			if(mc == MOUSE_LEFT && input.IsKeyDown( KEY_LALT )) then
				self.click = true
				self.xC, self.yC = self.touchPnl:CursorPos()
				if(self.pnlModel.selected != NULL) then
					self:UnselectModel(self.pnlModel.selected)
				end
			end
		else
			if(mc == MOUSE_LEFT) then
				self.click = true
				self.xC, self.yC = self.touchPnl:CursorPos()
				if(self.pnlModel.selected != NULL) then
					self:UnselectModel(self.pnlModel.selected)
				end
			end
		end
		
		if (mc == MOUSE_LEFT && !input.IsKeyDown( KEY_LALT )) then
			if(self.allowSelection) then
				local model = self:GetSelectedModel()
				if(model != NULL) then
					if(self.selectedModel != NULL) then
						self:SetSelectable(self.selectedModel, true)
					end
					self.selectedModel = model
					self:SetSelectable(model, false)
					model:SetMaterial("models/player/shared/ice_player")
					self:OnModelSelection(model)
				else
					if(self.selectedModel != NULL) then
						self:SetSelectable(self.selectedModel, true)
						self.selectedModel = NULL
						self:OnModelSelection(NULL)
					end
				end			
			end		
		end
	end
	self.touchPnl.OnMouseReleased = function(panel, mc)
		if(mc == MOUSE_LEFT) then
			self.click = false
		end
	end
	self.touchPnl.OnCursorMoved = function(panel, x, y)
		self.pnlModel.gX = x
		self.pnlModel.gY = y
		
		if self.click then
			local minCamAngle = 3.5
			local maxCamAngle = 46
			local linearFunc = ((maxCamAngle-90)/(self.maxCam-self.minCam))*(self.pnlModel.camdist-self.maxCam)+maxCamAngle
			self.xL = self.xL + (x - self.xC)/8
			self.yL = math.Clamp( (self.yL + (y - self.yC)/8), 3.5, linearFunc)
			
			self.xC = x
			self.yC = y
			
			self.pnlModel.campos.x = math.cos( self.xL*math.pi/180 )
			self.pnlModel.campos.y = math.sin( self.xL*math.pi/180 )
			self.pnlModel.campos.z = math.sin( self.yL*math.pi/180 )
		end
		
		if(self.allowSelection && !input.IsKeyDown( KEY_LALT )) then
		
			local gX = x or 0			
			local gY = y or 0
			
			local sW, sH = self:GetSize()
			local angCam = Angle(self.pnlModel.camAng.p,self.pnlModel.camAng.y,self.pnlModel.camAng.r)
			local posCam = angCam:Forward() *self.pnlModel.camDistance +self.pnlModel:GetCamPos()
			local testAng = (self.pnlModel.vLookatPos -posCam):Angle()
			local radFOV = math.rad(self.pnlModel:GetFOV())
			local vec3D = self.pnlModel:ScreenToVector( gX, gY, sW, sH, testAng, radFOV )		

			if(self.pnlModel.m_tbSubEnts) then
				local dist = 1
				local maxD = self.maxCam+100
				local found = false
				while(dist < maxD && not found) do
					for _, ent in ipairs(self.pnlModel.m_tbSubEnts) do
						if(ent:IsValid() && ent.selectable && not found) then 				
							local min, max = ent:GetRenderBounds()
							min = min + ent:GetPos()
							max = max + ent:GetPos()
							local newVec = posCam + (vec3D * dist)
							local x = newVec.x
							local y = newVec.y
							local z = newVec.z
							if( (x > min.x && x < max.x) && (y > min.y && y < max.y) && (z > min.z && z < max.z) ) then
								self:SelectModel(ent)
								found = true
							else
								self:UnselectModel(ent)
							end
						end
					end	
					dist = dist + 0.5
				end	
			end	
			
		end
	end
	
	self.touchPnl.OnMouseWheeled = function(panel, delta)
		local increment = 20
		if(delta < 0 ) then
			self.pnlModel.camdist = math.Clamp((self.pnlModel.camdist + increment), self.minCam, self.maxCam)
			if(self.pnlModel.m_tbSubEnts[1]) then
				self.pnlModel:SetLookAt(self.pnlModel.m_tbSubEnts[1]:GetPos()+Vector(0,0,0))
			else
				self.pnlModel:SetLookAt(Vector(0,0,0))
			end
		elseif(delta > 0) then
			self.pnlModel.camdist = math.Clamp((self.pnlModel.camdist - increment), self.minCam, self.maxCam)
			if(self.pnlModel.m_tbSubEnts[1]) then
				self.pnlModel:SetLookAt(self.pnlModel.m_tbSubEnts[1]:GetPos()+Vector(0,0,0))
			else
				self.pnlModel:SetLookAt(Vector(0,0,0))
			end
		end
	end
	
	self.touchPnl.OnCursorExited = function(panel)
		self.click = false
	end
end
 
function PANEL:SelectModel(ent)
	ent:SetMaterial("models/player/shared/gold_player")
	self.pnlModel.selected = ent
end

function PANEL:UnselectModel(ent)
	ent:SetMaterial("")
	self.pnlModel.selected = NULL
end
 
function PANEL:OnModelSelection(ent)
end
 
function PANEL:OnMouseClick(mc, x, y) //To be overwritten at parent
end

function PANEL:AllowSelection(boolYesNo)
	self.allowSelection = boolYesNo
end

function PANEL:SetSelectable(ent, selectable)
	if ent then
		ent.selectable = selectable
		if selectable then
			ent:SetMaterial("")
		end
	end
end

function PANEL:AddModel(mdl, pos, ang, scale, selectable)
	if(mdl) then
		-- local ent = ClientsideModel(mdl,RENDERGROUP_OPAQUE )
		local ent = ents.CreateClientProp()
		ent:SetModel(mdl)
		ent:SetNoDraw(true)
		ent:Spawn()
		ent:Activate()
		ent:SetPos(pos)
		if(ang) then 
			ent:SetAngles(ang)
		else 
			ent:SetAngles(Angle(0,0,0)) 
		end
		if(scale) then
			local matrix = Matrix()
			matrix:Scale(Vector(scale,scale,scale))
			ent:EnableMatrix("RenderMultiply", matrix)
		end
		ent.selectable = selectable
		table.insert(self.pnlModel.m_tbSubEnts,ent)
		return ent
	else
		return null
	end
end

function PANEL:ClearModels()
	self.pnlModel.m_tbSubEnts = {}
end

function PANEL:GetSelectedModel()
	return (self.pnlModel.selected)
end
 
function PANEL:Think()
end
 
function PANEL:OnRemove()
	self.pnlModel.Entity:Remove()
	self.pnlModel.Entity = nil
	self.pnlModel.m_tbSubEnts = {}
	local pnlModel = self.pnlModel
	local touchPnl = self.touchPnl
	pnlModel:Remove()
	touchPnl:Remove()
	self:Remove()
end
 
function PANEL:Hide()
	self:SetVisible(false)
end
 
function PANEL:Paint()
end
 
function PANEL:PaintOver()  
	self.pnlModel:Paint()
end     

derma.DefineControl("D3DViewer","A 3D viewer",PANEL,"DPanel")
