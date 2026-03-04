local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Card = require(ReplicatedStorage.Shared.Components.Card)

local module = {}
module.Player = Players.LocalPlayer
module.Mouse = module.Player:GetMouse()
module.MouseClickCon = nil

local isShowing = false -- Debounce flag to prevent multiple clicks while card is showing

function module.Init(card: Card.CardType)
	-- Disconnect previous connection if it exists to prevent memory leaks or double firing
	if module.MouseClickCon then
		module.MouseClickCon:Disconnect()
	end

	module.MouseClickCon = module.Mouse.Button1Down:Connect(function()
		if isShowing then
			return
		end

		-- Create a ray from the camera through the mouse position
		local unitRay = module.Mouse.UnitRay
		-- Extend the ray to 500 studs to detect objects far away
		local rayRes = workspace:Raycast(unitRay.Origin, unitRay.Direction * 500)

		if not rayRes or not rayRes.Instance then
			return
		end

		local instance = rayRes.Instance
		-- Look for a specific configuration folder to identify interactive objects
		local conf = instance:FindFirstChildOfClass("Configuration")

		-- Traverse up the hierarchy (parent by parent) to find the Configuration if we clicked a child part
		while not conf and instance and instance ~= workspace do
			instance = instance.Parent
			if instance then
				conf = instance:FindFirstChildOfClass("Configuration")
			end
		end

		if not conf or not instance then
			return
		end

		-- Type casting (::) tells the script editor that we expect these to be StringValues
		local title = conf:FindFirstChild("Title") :: StringValue
		local desc = conf:FindFirstChild("Desc") :: StringValue

		card:UpdateText({
			Title = title and title.Value or nil,
			Desc = desc and desc.Value or nil,
		})

		-- Archivable must be true to allow :Clone(). If false, Clone() returns nil.
		if not instance.Archivable then
			return
		end

		print(`instance -> {instance}`)
		card:UpdateModel(instance:Clone())

		isShowing = true
		card:Control(true)

		task.wait(5)

		card:Control(false)
		isShowing = false
	end)

	-- Cleanup connection if the player leaves or script is destroyed
	module.Player.AncestryChanged:Once(function(a0: Instance, a1: Instance?)
		module.MouseClickCon:Disconnect()
	end)
end

return module
