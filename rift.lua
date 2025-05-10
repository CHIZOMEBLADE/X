local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local UIS = game:GetService("UserInputService")
local Players = game:GetService("Players")
local StarterGui = game:GetService("StarterGui")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer

if not game:IsLoaded() then game.Loaded:Wait() end
task.wait(2)

-- 🥚 Eggs to look for
local eggs = {
	"rainbow-egg",
	"event-1",
	"event-2",
	"event-3",
	"nightmare-egg",
	"void-egg",
	"man-egg",
}

local Webhook_URL = "https://discord.com/api/webhooks/1366282077305176087/sIBDWP7AEQzUPTxnKYgx-4qOGOW9iyWEh7gEtdpBkFtKZmJhrUHG6lyorV67oOu8bQMR"

local function notify(title, text)
	StarterGui:SetCore("SendNotification", {
		Title = title,
		Text = text
	})
end

local function spoofIsland(height)
	if height > 0 and height < 410 then return "Floating Island (Island 1)" end
	if height >= 410 and height < 2650 then return "Outer Space (Island 2)" end
	if height >= 2650 and height < 6850 then return "Twilight (Island 3)" end
	if height >= 6850 and height < 10130 then return "The Void (Island 4)" end
	if height >= 10130 then return "Zen (Island 5)" end
	return "Unknown"
end

local function spoofEgg(rift)
	local names = {
		["nightmare-egg"] = "Nightmare Egg",
		["void-egg"] = "Void Egg",
		["event-1"] = "Bunny Egg",
		["event-2"] = "Pastel Egg",
		["man-egg"] = "Aura Egg",
		["rainbow-egg"] = "Rainbow Egg",
		["event-3"] = "Throwback Egg",
	}
	return names[rift] or rift
end

local function sendWebhook(eggName)
	local serverId = game.JobId
	local placeId = game.PlaceId
	local joinLink = string.format("https://www.roblox.com/games/%d?jobId=%s", placeId, serverId)

	local data = {
		["content"] = "@here",
		["embeds"] = {{
			["title"] = "✨ Egg Found! (" .. eggName .. ")",
			["description"] = "[Click here to join the server! 🚀](" .. joinLink .. ")",
			["color"] = tonumber(0x00ff00),
		}}
	}

	httprequest({
		Url = Webhook_URL,
		Method = "POST",
		Headers = {
			["Content-Type"] = "application/json"
		},
		Body = HttpService:JSONEncode(data)
	})
end

local function serverHop()
	local PlaceId = game.PlaceId
	local JobId = game.JobId

	local req = httprequest({
		Url = string.format("https://games.roblox.com/v1/games/%d/servers/Public?sortOrder=Desc&limit=100&excludeFullGames=true", PlaceId)
	})

	local success, body = pcall(function()
		return HttpService:JSONDecode(req.Body)
	end)

	if success and body and body.data then
		local servers = {}
		for _, server in pairs(body.data) do
			if server.playing < server.maxPlayers and server.id ~= JobId then
				table.insert(servers, server)
			end
		end
		if #servers > 0 then
			local selected = servers[math.random(1, #servers)]
			task.wait(2)

			-- ⚡ Re-execute script after teleport
			QueueOnTeleport = queue_on_teleport or queueonteleport or syn and syn.queue_on_teleport
			if QueueOnTeleport then
				QueueOnTeleport([[ 
					loadstring(game:HttpGet("https://raw.githubusercontent.com/CHIZOMEBLADE/X/main/rift.lua"))()
				]])
			end

			TeleportService:TeleportToPlaceInstance(PlaceId, selected.id, LocalPlayer)
		end
	end
end

-- Rift Search Start 🔥
notify("Searching for Rifts...", " ")

local found = false
local riftsFolder = workspace:WaitForChild("Rendered"):WaitForChild("Rifts")

for _, Rift in ipairs(riftsFolder:GetChildren()) do
	if table.find(eggs, Rift.Name) then
		-- Check if Luck exists
		local LuckText = Rift:FindFirstChild("Display") and Rift.Display:FindFirstChild("SurfaceGui") and Rift.Display.SurfaceGui:FindFirstChild("Icon") and Rift.Display.SurfaceGui.Icon:FindFirstChild("Luck")
		local Luck = LuckText and LuckText.Text or "x0"

		if Luck == "x5" or Luck == "x10" or Luck == "x25" or Rift.Name == "man-egg" then
			local foundRift = spoofEgg(Rift.Name)
			local height = math.floor(Rift:GetPivot().Position.Y)
			local island = spoofIsland(height)

			notify("Rift Found!", foundRift.." at "..height.." studs ("..island..")")
			sendWebhook(foundRift)

			local highlight = Instance.new("Highlight")
			highlight.FillTransparency = 1
			highlight.Parent = Rift

			found = true
			break -- ✅ Found 1, stop searching
		end
	end
end

if not found then
	notify("No Rifts Found", "Hopping servers...")
	task.wait(2)
	serverHop()
end

-- Manual X key server hop
UIS.InputBegan:Connect(function(input, processed)
	if processed then return end
	if input.KeyCode == Enum.KeyCode.X then
		repeat serverHop() task.wait(5) until false
	end
end)
