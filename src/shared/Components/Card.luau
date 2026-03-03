-- Services
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

-- Object init
local module = {}
module.__index = module

-- Types
export type Props = {
	Screen: ScreenGui,
	Model: Instance?,
	Title: string?,
	Desc: string?,
}

export type CardType = {
	Container: CanvasGroup,
	Container_UiCorner: UICorner,
	Container_UiStroke: UIStroke,
	VF: ViewportFrame,
	VF_Camera: Camera,
	VF_WorldModel: WorldModel,
	VF_UIA: UIAspectRatioConstraint,
	VF_UiCorner: UICorner,
	VF_UiStroke: UIStroke,
	Title: TextLabel,
	Title_UiStroke: UIStroke,
	Desc: TextLabel,
	Desc_UiTSC: UITextSizeConstraint,
	props: Props,

	_modelRotateCon: RBXScriptConnection,
	_tweenAnimation: Tween?,
	_tweenInfo: TweenInfo,

	New: (props: Props) -> CardType,
	Init: (self: CardType) -> (),
	UpdateText: (self: CardType, props: TextProp) -> (),
	UpdateModel: (self: CardType, model: Instance) -> (),
	ActiveModel: (self: CardType, model: Instance) -> (),
	Control: (self: CardType, show: boolean) -> (),
} & typeof(module)

type TextProp = {
	Title: string?,
	Desc: string?,
}

-- Constructor
function module.New(props: Props): CardType
	local self: CardType = {} :: CardType
	self.Container = Instance.new("CanvasGroup")
	self.Container.Parent = props.Screen
	self.Container_UiCorner = Instance.new("UICorner")
	self.Container_UiStroke = Instance.new("UIStroke")
	self.VF = Instance.new("ViewportFrame")
	self.VF_Camera = Instance.new("Camera")
	self.VF_WorldModel = Instance.new("WorldModel")
	self.VF_UIA = Instance.new("UIAspectRatioConstraint")
	self.VF_UiCorner = Instance.new("UICorner")
	self.VF_UiStroke = Instance.new("UIStroke")
	self.Title = Instance.new("TextLabel")
	self.Title_UiStroke = Instance.new("UIStroke")
	self.Desc = Instance.new("TextLabel")
	self.Desc_UiTSC = Instance.new("UITextSizeConstraint")
	self.props = props
	self._tweenInfo = TweenInfo.new(0.2, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)

	setmetatable(self, module)
	self:Init()
	return self
end

-- Helper
local function Tweener(card: CardType, show: boolean)
	local goal = { GroupTransparency = show and 0 or 1 }
	local tween = TweenService:Create(card.Container, card._tweenInfo, goal)
	tween:Play()
	return tween
end

-- Methods

-- Init
function module.Init(self: CardType)
	--[[
		Container
	]]
	local ctn: CanvasGroup = self.Container
	ctn.Name = "Container"
	ctn.AnchorPoint = Vector2.new(0.5, 0.5)
	ctn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
	ctn.BackgroundTransparency = 0.7
	ctn.Position = UDim2.fromScale(0.25, 0.5)
	ctn.Size = UDim2.fromScale(0.2, 0.75)

	local ctn_ui_corner: UICorner = self.Container_UiCorner
	ctn_ui_corner.Parent = ctn
	ctn_ui_corner.CornerRadius = UDim.new(0, 20)

	local ctn_ui_stroke: UIStroke = self.Container_UiStroke
	ctn_ui_stroke.Parent = ctn
	ctn_ui_stroke.Thickness = 1

	--[[
		VF
	]]
	local vf: ViewportFrame = self.VF
	vf.Name = "VF"
	vf.Parent = ctn
	vf.AnchorPoint = Vector2.new(0.5, 0)
	vf.BackgroundColor3 = Color3.new(0, 0, 0)
	vf.BackgroundTransparency = 1
	vf.Position = UDim2.fromScale(0.5, 0.1)
	vf.Size = UDim2.fromScale(0.75, 0.75)

	local vf_camera: Camera = self.VF_Camera
	vf_camera.Parent = vf
	vf_camera.Name = "VF_Camera"
	vf_camera.CFrame = CFrame.new(Vector3.new(0, 7, 10), Vector3.new(math.rad(0), math.rad(0), math.rad(0)))
	vf_camera.FieldOfView = 30
	vf.CurrentCamera = vf_camera

	local vf_world_model: WorldModel = self.VF_WorldModel
	vf_world_model.Parent = vf
	vf_world_model.Name = "VF_WorldModel"

	local vf_ui_a: UIAspectRatioConstraint = self.VF_UIA
	vf_ui_a.Parent = vf
	vf_ui_a.Name = "VF_UIA"

	local vf_ui_corner: UICorner = self.VF_UiCorner
	vf_ui_corner.Parent = vf
	vf_ui_corner.CornerRadius = UDim.new(0, 35)

	local vf_ui_stroke: UIStroke = self.VF_UiStroke
	vf_ui_stroke.Parent = vf
	vf_ui_stroke.Thickness = 1

	--[[
		Title
	]]
	local title: TextLabel = self.Title
	title.Parent = ctn
	title.Name = "Title"
	title.Text = self.props.Title or "PlaceHolder"
	title.AnchorPoint = Vector2.new(0.5, 0)
	title.BackgroundTransparency = 1
	title.Position = UDim2.fromScale(0.5, 0.55)
	title.Size = UDim2.fromScale(1, 0.1)
	title.Font = Enum.Font.Jura
	title.TextScaled = true
	title.TextColor3 = Color3.new(1, 1, 1)

	local title_ui_stroke: UIStroke = self.Title_UiStroke
	title_ui_stroke.Parent = title
	title_ui_stroke.Thickness = 1

	--[[
		Desc
	]]
	local desc: TextLabel = self.Desc
	desc.Parent = ctn
	desc.Name = "Desc"
	desc.Text = self.props.Desc or "PlaceHolder"
	desc.AnchorPoint = Vector2.new(0.5, 0)
	desc.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
	desc.BackgroundTransparency = 0.5
	desc.Position = UDim2.fromScale(0.5, 0.7)
	desc.Size = UDim2.fromScale(1, 0.25)
	desc.Font = Enum.Font.Jura
	desc.TextScaled = true
	desc.TextColor3 = Color3.new(1, 1, 1)
	desc.TextXAlignment = Enum.TextXAlignment.Center
	desc.TextYAlignment = Enum.TextYAlignment.Top

	local desc_ui_tsc: UITextSizeConstraint = self.Desc_UiTSC
	desc_ui_tsc.Parent = desc
	desc_ui_tsc.Name = "Desc_UiTSC"
	desc_ui_tsc.MaxTextSize = 24
	desc_ui_tsc.MinTextSize = 1

	if self.props.Model then
		self:UpdateModel(self.props.Model)
	end
end

-- Update text of the card
function module.UpdateText(self: CardType, props: TextProp)
	if props.Title then
		self.Title.Text = props.Title
	end
	if props.Desc then
		self.Desc.Text = props.Desc
	end
end

-- Update model of the card
function module.UpdateModel(self: CardType, model: Instance)
	if self._modelRotateCon then
		self._modelRotateCon:Disconnect()
	end

	self.VF_WorldModel:ClearAllChildren()
	model.Parent = self.VF_WorldModel

	-- Formule complexe pour placer la caméra à bonne distance
	if model:IsA("Model") or model:IsA("BasePart") then
		-- 1. Récupérer la taille (Size) de l'objet
		local _, size
		if model:IsA("Model") then
			_, size = model:GetBoundingBox()
		else
			size = model.Size
		end

		-- 2. Placer le modèle au centre du monde
		model:PivotTo(CFrame.new(0, 0, 0) * CFrame.Angles(0, 0, 0))

		-- 3. La Formule Magique : Calcul de la distance
		local radius = size.Magnitude / 2
		local halfFov = math.rad(self.VF_Camera.FieldOfView) / 2
		local perfectDistance = radius / math.sin(halfFov)

		-- On rajoute 15% de marge pour que l'objet ne touche pas les bords de l'écran
		local distanceWithMargin = perfectDistance * 1.15

		-- 4. Positionner la caméra
		-- On recule la caméra sur l'axe Z, et on la lève un peu sur l'axe Y pour une vue en légère plongée
		local cameraPos = Vector3.new(0, radius * 0.5, distanceWithMargin)
		self.VF_Camera.CFrame = CFrame.lookAt(cameraPos, Vector3.new(0, 0, 0))
	end

	self:ActiveModel(model)
end

-- Active model animation
function module.ActiveModel(self: CardType, model: Instance)
	self._modelRotateCon = RunService.PreRender:Connect(function()
		if model:IsA("Model") or model:IsA("BasePart") then
			local currentCFrame = model:GetPivot()
			model:PivotTo(currentCFrame * CFrame.Angles(0, math.rad(1), 0))
		end
	end)
end

-- Control the card (show/hide)
function module.Control(self: CardType, show: boolean)
	if self._tweenAnimation then
		self._tweenAnimation:Cancel()
		self._tweenAnimation = nil
	end
	self.props.Screen.Enabled = true
	self.Container.GroupTransparency = 0
	self._tweenAnimation = Tweener(self, show)
	if self._tweenAnimation then
		self._tweenAnimation.Completed:Once(function(a0: Enum.PlaybackState)
			if not show then
				self.props.Screen.Enabled = false
			end
		end)
	end
end

return module
