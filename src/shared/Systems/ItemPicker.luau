local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Card = require(ReplicatedStorage.Shared.Components.Card)

local module = {}
module.Player = Players.LocalPlayer
module.Mouse = module.Player:GetMouse()
module.MouseClickCon = nil

local isShowing = false

function module.Init(card: Card.CardType)
	if module.MouseClickCon then
		module.MouseClickCon:Disconnect()
	end

	module.MouseClickCon = module.Mouse.Button1Down:Connect(function()
		if isShowing then
			return
		end

		local unitRay = module.Mouse.UnitRay
		local rayRes = workspace:Raycast(unitRay.Origin, unitRay.Direction * 500)

		if not rayRes or not rayRes.Instance then
			return
		end

		local instance = rayRes.Instance
		local conf = instance:FindFirstChildOfClass("Configuration")

		while not conf and instance and instance ~= workspace do
			instance = instance.Parent
			if instance then
				conf = instance:FindFirstChildOfClass("Configuration")
			end
		end

		if not conf or not instance then
			return
		end

		local title = conf:FindFirstChild("Title") :: StringValue
		local desc = conf:FindFirstChild("Desc") :: StringValue

		card:UpdateText({
			Title = title and title.Value or nil,
			Desc = desc and desc.Value or nil,
		})
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

	module.Player.AncestryChanged:Once(function(a0: Instance, a1: Instance?)
		module.MouseClickCon:Disconnect()
	end)
end

return module
