local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Card = require(ReplicatedStorage.Shared.Components.Card)
local ItemPicker = require(ReplicatedStorage.Shared.Systems.ItemPicker)

local player: Player = Players.LocalPlayer
local playerGui: PlayerGui = player.PlayerGui
local character: Model = player.Character or player.CharacterAdded:Wait()
character.Archivable = true

local conf = Instance.new("Configuration")
conf.Name = "Configuration"
conf.Parent = character

local title: StringValue = Instance.new("StringValue")
title.Name = "Title"
title.Parent = conf
title.Value = "You"

local desc: StringValue = Instance.new("StringValue")
desc.Name = "Desc"
desc.Parent = conf
desc.Value = "WTF ? Is that YOU ??? (how you do that ?)"

local screen: ScreenGui = Instance.new("ScreenGui")
screen.Parent = playerGui
screen.Name = "ScreenGui"
screen.IgnoreGuiInset = true
screen.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screen.Enabled = true

local card = Card.New({
	Screen = screen,
})
card:Init()
card:Control(false)
ItemPicker.Init(card)
