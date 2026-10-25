--==================================================
-- CASTLE OF MAXU  (AAYAN ALPHA EMPIRE)
-- One complete LOCAL script (executor / LocalScript). Works in any game.
--
--  * A dangerous stone / gold / diamond castle floats high in the sky.
--  * FREE ROAM: no locks, no keys. Walk anywhere, press SKIP any time to go back.
--  * Things to do: collect coins, 5 secrets, 6 chests, bounce pads, speed pads,
--    magic carpet flight, wake the dragon, fireworks, party mode, jukebox,
--    telescope, wishing fountain, royal crown + cape, sit on the throne, photo mode.
--  * Everything is created on YOUR client, so only you see the castle.
--  * Re-running the script safely removes the old castle and returns you.
--==================================================

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local UIS = game:GetService("UserInputService")

local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")

if _G.AAYAN_CASTLE_EXIT then pcall(_G.AAYAN_CASTLE_EXIT, true) end

--==================================================
-- SETTINGS
--==================================================
local AVATAR_NAME = "AAYAN_ZZZZ"
local MUSIC_ID = "rbxassetid://103768345751621"
local HQ_HEIGHT = 1800
local S = 2.0            -- castle scale (everything is built at this size)

local STONE = Color3.fromRGB(128, 126, 120)
local STONE_DARK = Color3.fromRGB(88, 86, 84)
local STONE_LIGHT = Color3.fromRGB(168, 164, 154)
local ROOF = Color3.fromRGB(96, 22, 24)
local WOOD = Color3.fromRGB(96, 62, 34)
local WOOD_DARK = Color3.fromRGB(58, 36, 20)
local IRON = Color3.fromRGB(52, 54, 60)
local GOLD = Color3.fromRGB(255, 190, 35)
local GOLD_DARK = Color3.fromRGB(120, 78, 12)
local RED = Color3.fromRGB(150, 12, 20)
local RED_DEEP = Color3.fromRGB(92, 6, 12)
local DIAMOND = Color3.fromRGB(150, 232, 255)
local WHITE = Color3.fromRGB(255, 255, 255)
local BLACK = Color3.fromRGB(8, 8, 8)
local GRASS = Color3.fromRGB(62, 96, 44)

local M = Enum.Material

--==================================================
-- SAFE GETTERS (the character can change in any game)
--==================================================
local function getChar() return Player.Character end
local function getHum()
	local c = Player.Character
	return c and c:FindFirstChildOfClass("Humanoid")
end
local function getRoot()
	local c = Player.Character
	return c and (c:FindFirstChild("HumanoidRootPart") or c.PrimaryPart)
end
local function getCam() return workspace.CurrentCamera end

local startChar = Player.Character or Player.CharacterAdded:Wait()
local startRoot = startChar:WaitForChild("HumanoidRootPart", 15) or startChar.PrimaryPart
if not startRoot then
	warn("[AAYAN CASTLE] no character root found")
	return
end

local OldCF = startRoot.CFrame          -- where you go back to
local OldDesc = nil                     -- your own avatar, restored on exit
do
	local h = getHum()
	if h then pcall(function() OldDesc = h:GetAppliedDescription() end) end
end

--==================================================
-- CLEAN OLD HQ
--==================================================
for _, n in ipairs({ "AAYAN_ALPHA_HQ", "AAYAN_ALPHA_CASTLE", "CASTLE_OF_MAXU", "AlphaHQMusic" }) do
	local o = workspace:FindFirstChild(n)
	if o then o:Destroy() end
end
for _, n in ipairs({ "AlphaHQInterface", "AAYAN_CASTLE_UI" }) do
	local o = PlayerGui:FindFirstChild(n)
	if o then o:Destroy() end
end

local HQ = Instance.new("Folder")
HQ.Name = "CASTLE_OF_MAXU"
HQ.Parent = workspace

local Center = startRoot.Position + Vector3.new(0, HQ_HEIGHT, 0)

local conns = {}
local function bind(sig, fn)
	local c = sig:Connect(fn)
	conns[#conns + 1] = c
	return c
end

--==================================================
-- BUILD HELPERS
--==================================================
local CUR = HQ

local function section(name)
	local f = Instance.new("Folder")
	f.Name = name
	f.Parent = HQ
	CUR = f
	return f
end

local function V(x, y, z)
	return Center + Vector3.new(x, y, z) * S
end

local function at(x, y, z, ry)
	return CFrame.new(V(x, y, z)) * CFrame.Angles(0, math.rad(ry or 0), 0)
end

local function P(name, size, cf, color, mat, parent, collide)
	local p = Instance.new("Part")
	p.Name = name
	p.Size = size
	p.CFrame = cf
	p.Color = color
	p.Material = mat or M.SmoothPlastic
	p.Anchored = true
	p.CanCollide = collide ~= false
	p.TopSurface = Enum.SurfaceType.Smooth
	p.BottomSurface = Enum.SurfaceType.Smooth
	p.Parent = parent or CUR
	return p
end

-- block by centre
local function B(name, sx, sy, sz, x, y, z, color, mat, ry, collide)
	return P(name, Vector3.new(sx, sy, sz) * S, at(x, y, z, ry), color, mat, nil, collide)
end

-- vertical cylinder (centre y)
local function VC(name, radius, height, x, y, z, color, mat, collide)
	local p = P(name, Vector3.new(height, radius * 2, radius * 2) * S,
		CFrame.new(V(x, y, z)) * CFrame.Angles(0, 0, math.pi / 2), color, mat, nil, collide)
	p.Shape = Enum.PartType.Cylinder
	return p
end

local function Ball(name, d, x, y, z, color, mat)
	local p = P(name, Vector3.new(d, d, d) * S, at(x, y, z), color, mat, nil, false)
	p.Shape = Enum.PartType.Ball
	return p
end

local function addLight(part, color, range, brightness)
	local l = Instance.new("PointLight")
	l.Color = color
	l.Range = range
	l.Brightness = brightness
	l.Shadows = false
	l.Parent = part
	return l
end

local function torch(x, y, z, lit)
	local h = B("TorchBracket", 0.6, 2.4, 0.6, x, y, z, IRON, M.Metal, 0, false)
	local cup = B("TorchCup", 1.2, 0.5, 1.2, x, y + 1.4, z, GOLD_DARK, M.Metal, 0, false)
	if lit ~= false then
		local fire = Instance.new("Fire")
		fire.Size = 3.2
		fire.Heat = 6
		fire.Color = Color3.fromRGB(255, 150, 40)
		fire.SecondaryColor = Color3.fromRGB(255, 70, 20)
		fire.Parent = cup
		addLight(cup, Color3.fromRGB(255, 160, 70), 22, 1.6)
	end
	return cup
end

local function merlons(name, x1, z1, x2, z2, y, along, step, sx, sy, sz, color)
	-- row of battlement blocks between two points along x or z
	local n = math.floor(math.abs(along) / step)
	for i = 0, n do
		local t = (i + 0.5) * step
		if t > math.abs(along) then break end
		if x1 ~= x2 then
			B(name, sx, sy, sz, math.min(x1, x2) + t, y, z1, color or STONE, M.Cobblestone)
		else
			B(name, sz, sy, sx, x1, y, math.min(z1, z2) + t, color or STONE, M.Cobblestone)
		end
	end
end

local function banner(x, y, z, ry, w, h)
	w, h = w or 4, h or 10
	B("Banner", w, h, 0.3, x, y, z, RED, M.Fabric, ry, false)
	B("BannerTrimTop", w + 0.6, 0.5, 0.5, x, y + h / 2, z, GOLD, M.Metal, ry, false)
	B("BannerTrimBottom", w + 0.6, 0.5, 0.5, x, y - h / 2, z, GOLD, M.Metal, ry, false)
	B("BannerCrest", w * 0.35, w * 0.35, 0.4, x, y + h * 0.12, z, GOLD, M.Metal, ry + 45, false)
end

local function window(x, y, z, w, h, ry)
	-- stone frame + diamond-blue glass
	B("WindowFrame", w + 1.4, h + 1.4, 0.6, x, y, z, STONE_LIGHT, M.Granite, ry, false)
	local g = B("WindowGlass", w, h, 0.5, x, y, z, DIAMOND, M.Glass, ry, false)
	g.Transparency = 0.35
	g.Reflectance = 0.25
	B("WindowBarV", 0.3, h, 0.7, x, y, z, STONE_DARK, M.Metal, ry, false)
	B("WindowBarH", w, 0.3, 0.7, x, y, z, STONE_DARK, M.Metal, ry, false)
end

--==================================================
-- TERRAIN: grass island, cliff underside, courtyard
--==================================================
section("Terrain")
B("GrassIsland", 330, 8, 450, 0, -4, -60, GRASS, M.Grass)
for i, d in ipairs({ { 300, 30 }, { 236, 30 }, { 170, 30 }, { 104, 26 }, { 56, 24 } }) do
	local y = -8 - 15 - (i - 1) * 26
	B("Cliff" .. i, d[1], d[2], d[1] + 120, 0, y, -60, Color3.fromRGB(70 + i * 3, 66 + i * 3, 62 + i * 3), M.Slate)
end
B("CourtyardStone", 216, 0.5, 216, 0, 0.25, 0, STONE_LIGHT, M.Cobblestone)
B("RoyalPath", 14, 0.2, 130, 0, 0.55, -66, Color3.fromRGB(176, 150, 112), M.Pavement, 0, true)
B("RoyalPathBorderL", 0.5, 0.25, 130, -7.25, 0.6, -66, GOLD_DARK, M.Metal)
B("RoyalPathBorderR", 0.5, 0.25, 130, 7.25, 0.6, -66, GOLD_DARK, M.Metal)

--==================================================
-- OUTER CURTAIN WALL (8 thick, 30 high) + battlements
--==================================================
section("Walls")
B("WallNorth", 228, 30, 8, 0, 15, 110, STONE, M.Brick)
B("WallWest", 8, 30, 228, -110, 15, 0, STONE, M.Brick)
B("WallEast", 8, 30, 228, 110, 15, 0, STONE, M.Brick)
B("WallSouthL", 99, 30, 8, -60.5, 15, -110, STONE, M.Brick)
B("WallSouthR", 99, 30, 8, 60.5, 15, -110, STONE, M.Brick)
B("GateLintel", 22, 8, 8, 0, 26, -110, STONE_DARK, M.Brick)
B("GateArchGold", 22.6, 1, 8.6, 0, 22.4, -110, GOLD, M.Metal, 0, false)
-- portcullis bars (raised, decorative)
for i = -4, 4 do
	B("PortcullisBar", 0.5, 6, 0.5, i * 2.4, 25, -108, IRON, M.Metal, 0, false)
end
B("PortcullisBeam", 22, 0.6, 0.6, 0, 22.8, -108, IRON, M.Metal, 0, false)

-- battlements on all walls (outer + inner edge blocks)
for _, z in ipairs({ -110, 110 }) do
	for x = -112, 112, 8 do
		if not (z == -110 and math.abs(x) < 13) then
			B("Merlon", 4, 4, 8, x, 32, z, STONE, M.Cobblestone)
		end
	end
end
for _, x in ipairs({ -110, 110 }) do
	for z = -112, 112, 8 do
		B("Merlon", 8, 4, 4, x, 32, z, STONE, M.Cobblestone)
	end
end
-- wall buttresses (outside)
for i = -90, 90, 30 do
	B("Buttress", 6, 22, 4, i, 11, -114, STONE_DARK, M.Brick)
	B("Buttress", 6, 22, 4, i, 11, 114, STONE_DARK, M.Brick)
	B("Buttress", 4, 22, 6, -114, 11, i, STONE_DARK, M.Brick)
	B("Buttress", 4, 22, 6, 114, 11, i, STONE_DARK, M.Brick)
end

-- stairs up to the west wall walkway (blocks down to the floor)
for i = 1, 60 do
	B("WallStair", 6, i * 0.5, 0.75, -103, i / 4, -98 + i * 0.75, STONE_LIGHT, M.Cobblestone)
end
-- stairs up to the east wall walkway
for i = 1, 60 do
	B("WallStair", 6, i * 0.5, 0.75, 103, i / 4, -98 + i * 0.75, STONE_LIGHT, M.Cobblestone)
end

--==================================================
-- TOWERS
--==================================================
section("Towers")

local function tower(name, x, z, radius, height, roofed)
	VC(name .. "Body", radius, height, x, height / 2, z, STONE, M.Brick)
	VC(name .. "Band", radius + 0.8, 2, x, height * 0.55, z, STONE_DARK, M.Granite)
	VC(name .. "Gold", radius + 0.5, 0.8, x, height - 3, z, GOLD, M.Metal)
	-- top platform
	VC(name .. "Top", radius + 1.5, 1.5, x, height + 0.75, z, STONE_LIGHT, M.Cobblestone)
	-- battlements ring
	local n = 14
	for i = 0, n - 1 do
		local a = i / n * math.pi * 2
		B(name .. "Merlon", 3, 3.5, 3, x + math.cos(a) * (radius + 0.6), height + 3.2, z + math.sin(a) * (radius + 0.6), STONE,
			M.Cobblestone, -math.deg(a))
	end
	if roofed then
		-- conical roof from stacked discs
		local layers = 9
		for i = 1, layers do
			local r = (radius + 2.5) * (1 - (i - 1) / layers)
			VC(name .. "Roof" .. i, math.max(r, 0.6), 2, x, height + 3 + i * 2, z, ROOF, M.Slate)
		end
		Ball(name .. "Finial", 2, x, height + 3 + layers * 2 + 2, z, GOLD, M.Metal)
		B(name .. "Spire", 0.4, 8, 0.4, x, height + 3 + layers * 2 + 5, z, GOLD, M.Metal, 0, false)
	end
	-- arrow slits
	for i = 1, 4 do
		local a = i / 4 * math.pi * 2 + 0.4
		B(name .. "Slit", 1, 5, 1, x + math.cos(a) * (radius + 0.1), height * 0.45, z + math.sin(a) * (radius + 0.1), BLACK, M.SmoothPlastic, -math.deg(a), false)
	end
end

tower("TowerSW", -110, -110, 13, 46, true)
tower("TowerSE", 110, -110, 13, 46, true)
tower("TowerNE", 110, 110, 13, 46, true)
tower("TowerNW", -110, 110, 13, 46, false)   -- open top: a key waits up there
tower("GateTowerL", -22, -110, 9, 38, true)
tower("GateTowerR", 22, -110, 9, 38, true)

-- ladder up the NW tower from the wall walkway (climbable)
do
	local t = Instance.new("TrussPart")
	t.Name = "NW_Tower_Ladder"
	t.Size = Vector3.new(2, 17 * S, 2)
	t.CFrame = at(-110, 38.5, 96)
	t.Anchored = true
	t.Material = M.Wood
	t.Color = WOOD
	t.Parent = CUR
end

for _, p in ipairs({ { -14, -104 }, { 14, -104 }, { -30, -104 }, { 30, -104 } }) do
	torch(p[1], 14, p[2] + 0, true)
end

--==================================================
-- KEEP / GREAT HALL (inner 80 x 80, 40 high)
--==================================================
section("Keep")

-- floors
B("HallFloor", 88, 1, 86, 0, 0, 62, Color3.fromRGB(205, 200, 190), M.Marble)
B("HallFloorInlay", 60, 0.1, 60, 0, 0.55, 62, Color3.fromRGB(150, 146, 138), M.Marble, 0, false)
B("ChamberFloor", 32, 1, 36, -59, 0, 86, WOOD, M.WoodPlanks)
B("SecretFloor", 16, 1, 18, 52, 0, 44, STONE_DARK, M.Slate)

-- south wall with a great door gap (16 wide, 20 high)
B("KeepSouthL", 36, 40, 4, -26, 20, 22, STONE, M.Brick)
B("KeepSouthR", 36, 40, 4, 26, 20, 22, STONE, M.Brick)
B("KeepDoorLintel", 16, 20, 4, 0, 30, 22, STONE, M.Brick)
B("DoorArchGold", 16.8, 1, 4.6, 0, 20.4, 21.8, GOLD, M.Metal, 0, false)
B("DoorPostL", 1.2, 20, 5, -8.6, 10, 21.5, STONE_LIGHT, M.Granite)
B("DoorPostR", 1.2, 20, 5, 8.6, 10, 21.5, STONE_LIGHT, M.Granite)
-- north wall
B("KeepNorth", 92, 40, 4, 0, 20, 104, STONE, M.Brick)
-- west wall: gap for the Royal Chamber door (z 78..86, 14 high)
B("KeepWestA", 4, 40, 58, -42, 20, 49, STONE, M.Brick)
B("KeepWestB", 4, 40, 18, -42, 20, 95, STONE, M.Brick)
B("KeepWestLintel", 4, 26, 8, -42, 27, 82, STONE, M.Brick)
-- east wall: gap for the secret panel (z 40..48, 12 high)
B("KeepEastA", 4, 40, 20, 42, 20, 30, STONE, M.Brick)
B("KeepEastB", 4, 40, 56, 42, 20, 76, STONE, M.Brick)
B("KeepEastLintel", 4, 28, 8, 42, 26, 44, STONE, M.Brick)
-- roof slab + battlements
B("KeepRoof", 92, 3, 86, 0, 41.5, 63, STONE_DARK, M.Slate)
for x = -44, 44, 8 do
	B("KeepMerlon", 4, 4, 4, x, 45, 22, STONE, M.Cobblestone)
	B("KeepMerlon", 4, 4, 4, x, 45, 104, STONE, M.Cobblestone)
end
for z = 26, 100, 8 do
	B("KeepMerlon", 4, 4, 4, -44, 45, z, STONE, M.Cobblestone)
	B("KeepMerlon", 4, 4, 4, 44, 45, z, STONE, M.Cobblestone)
end
-- ceiling beams
for z = 30, 98, 14 do
	B("CeilingBeam", 84, 2, 2, 0, 38.5, z, WOOD_DARK, M.Wood, 0, false)
end
-- gold wall trim
B("HallTrimS", 80, 1, 0.4, 0, 12, 23.8, GOLD, M.Metal, 0, false)
B("HallTrimN", 80, 1, 0.4, 0, 12, 101.8, GOLD, M.Metal, 0, false)
B("HallTrimE", 0.4, 1, 80, 39.8, 12, 62, GOLD, M.Metal, 0, false)
B("HallTrimW", 0.4, 1, 80, -39.8, 12, 62, GOLD, M.Metal, 0, false)

-- chamber shell (west annex)
B("ChamberWest", 4, 40, 40, -74, 20, 86, STONE, M.Brick)
B("ChamberNorth", 32, 40, 4, -60, 20, 104, STONE, M.Brick)
-- south wall of the chamber with a barred window (x -61..-55, y 7..15)
B("ChamberSouthA", 13, 40, 4, -67.5, 20, 68, STONE, M.Brick)
B("ChamberSouthB", 13, 40, 4, -48.5, 20, 68, STONE, M.Brick)
B("ChamberSouthBottom", 6, 7, 4, -58, 3.5, 68, STONE, M.Brick)
B("ChamberSouthTop", 6, 25, 4, -58, 27.5, 68, STONE, M.Brick)
for i = -2, 2 do
	B("WindowBar", 0.4, 8, 0.4, -58 + i * 1.2, 11, 68, IRON, M.Metal)
end
B("WindowBarH1", 6, 0.4, 0.4, -58, 8.5, 68, IRON, M.Metal)
B("WindowBarH2", 6, 0.4, 0.4, -58, 13.5, 68, IRON, M.Metal)
B("ChamberRoof", 34, 3, 40, -59, 41.5, 86, STONE_DARK, M.Slate)
for x = -76, -44, 8 do
	B("ChamberMerlon", 4, 4, 4, x, 45, 68, STONE, M.Cobblestone)
	B("ChamberMerlon", 4, 4, 4, x, 45, 104, STONE, M.Cobblestone)
end

-- secret annex (east)
B("SecretSouth", 20, 40, 4, 54, 20, 34, STONE, M.Brick)
B("SecretNorth", 20, 40, 4, 54, 20, 54, STONE, M.Brick)
B("SecretEast", 4, 40, 24, 62, 20, 44, STONE, M.Brick)
B("SecretRoof", 22, 3, 24, 53, 41.5, 44, STONE_DARK, M.Slate)

-- windows on the keep (outside faces)
for _, z in ipairs({ 34, 62, 90 }) do
	window(-44.4, 22, z, 3.2, 10, 90)
	window(44.4, 22, z + 0, 3.2, 10, 90)
end
window(-30, 22, 21.4, 3.2, 10, 0)
window(30, 22, 21.4, 3.2, 10, 0)
window(-20, 22, 105.4, 3.2, 10, 0)
window(20, 22, 105.4, 3.2, 10, 0)

--==================================================
-- HALL INTERIOR: pillars, carpet, chandeliers, torches
--==================================================
section("Hall")

local pillarZ = { 34, 50, 66, 82 }
for _, px in ipairs({ -24, 24 }) do
	for _, pz in ipairs(pillarZ) do
		VC("PillarBase", 3.2, 1.6, px, 1.3, pz, GOLD_DARK, M.Metal)
		VC("Pillar", 2.3, 38, px, 20, pz, STONE_LIGHT, M.Marble)
		VC("PillarRing", 2.7, 1, px, 8, pz, GOLD, M.Metal, false)
		VC("PillarCapital", 3.2, 2, px, 39, pz, GOLD, M.Metal, false)
		banner(px + (px < 0 and 2.45 or -2.45), 22, pz, px < 0 and 90 or -90, 3, 9)
		torch(px + (px < 0 and 2.6 or -2.6), 11, pz + 2.6, true)
	end
end

-- red carpet with gold borders
B("RedCarpet", 14, 0.2, 74, 0, 0.6, 58, RED, M.Fabric, 0, false)
B("CarpetGoldL", 0.6, 0.25, 74, -7.3, 0.65, 58, GOLD, M.Metal, 0, false)
B("CarpetGoldR", 0.6, 0.25, 74, 7.3, 0.65, 58, GOLD, M.Metal, 0, false)
B("CarpetGoldEndS", 14.6, 0.25, 0.6, 0, 0.65, 21.2, GOLD, M.Metal, 0, false)

-- chandeliers
for _, cz in ipairs({ 38, 62, 86 }) do
	for i = 0, 3 do
		B("ChandelierChain", 0.3, 6, 0.3, (i - 1.5) * 0.001, 36, cz, IRON, M.Metal, 0, false)
	end
	local ring = VC("ChandelierRing", 5, 0.8, 0, 31, cz, GOLD, M.Metal, false)
	local ring2 = VC("ChandelierRing2", 3, 0.8, 0, 31.6, cz, GOLD, M.Metal, false)
	for i = 0, 7 do
		local a = i / 8 * math.pi * 2
		local c = B("Candle", 0.5, 1.6, 0.5, math.cos(a) * 4.4, 32.4, cz + math.sin(a) * 4.4, WHITE, M.SmoothPlastic, 0, false)
		local f = Ball("Flame", 0.7, math.cos(a) * 4.4, 33.5, cz + math.sin(a) * 4.4, Color3.fromRGB(255, 190, 90), M.Neon)
	end
	local lp = B("ChandelierLight", 1, 1, 1, 0, 31, cz, GOLD, M.Neon, 0, false)
	lp.Transparency = 1
	addLight(lp, Color3.fromRGB(255, 200, 120), 46, 1.8)
	Ball("ChandelierDiamond", 1.6, 0, 29.5, cz, DIAMOND, M.Glass).Reflectance = 0.3
end

-- statues (stone knights) by the door
local function knight(x, z, ry)
	B("KnightBase", 4, 1.2, 4, x, 1.1, z, STONE_DARK, M.Granite, ry)
	B("KnightLegL", 1.1, 4, 1.1, x - 0.7, 3.7, z, STONE, M.Marble, ry)
	B("KnightLegR", 1.1, 4, 1.1, x + 0.7, 3.7, z, STONE, M.Marble, ry)
	B("KnightTorso", 3, 3.6, 1.8, x, 7.4, z, STONE_LIGHT, M.Marble, ry)
	B("KnightHead", 1.6, 1.8, 1.6, x, 10.1, z, STONE_LIGHT, M.Marble, ry)
	B("KnightHelmet", 1.9, 0.6, 1.9, x, 11.1, z, GOLD, M.Metal, ry)
	B("KnightSword", 0.4, 7, 0.4, x + 2, 6.3, z, GOLD, M.Metal, ry)
	B("KnightShield", 0.4, 3.2, 2.4, x - 2, 7, z, RED, M.Metal, ry)
end
knight(-12, 28, 0)
knight(12, 28, 0)

--==================================================
-- THRONE + DAIS
--==================================================
section("Throne")
B("DaisStep1", 70, 1.2, 18, 0, 1.1, 93, STONE_LIGHT, M.Marble)
B("DaisStep2", 62, 1.2, 14, 0, 2.3, 95, STONE_LIGHT, M.Marble)
B("DaisStep3", 54, 1.2, 10, 0, 3.5, 97, STONE_LIGHT, M.Marble)
B("DaisCarpet", 12, 0.2, 18, 0, 4.2, 96, RED, M.Fabric, 0, false)
B("DaisGoldEdge1", 70, 0.3, 0.5, 0, 1.8, 84, GOLD, M.Metal, 0, false)
B("DaisGoldEdge2", 62, 0.3, 0.5, 0, 3.0, 88, GOLD, M.Metal, 0, false)
B("DaisGoldEdge3", 54, 0.3, 0.5, 0, 4.2, 92, GOLD, M.Metal, 0, false)

-- the throne itself (faces -Z, towards the hall door)
B("ThroneBase", 9, 1.6, 7.6, 0, 5.2, 98, GOLD_DARK, M.Metal)
B("ThroneSeatGold", 8, 1.2, 6.6, 0, 6.4, 98, GOLD, M.Metal)
B("ThroneCushion", 6.4, 0.9, 5.4, 0, 7.4, 98, RED_DEEP, M.Fabric)
B("ThroneBack", 8.4, 16, 1.6, 0, 14.4, 101.2, GOLD, M.Metal)
B("ThroneBackInlay", 6, 13, 0.4, 0, 14.4, 100.2, RED_DEEP, M.Fabric, 0, false)
B("ThroneArmL", 1.4, 3.6, 6.6, -4.2, 8.2, 98, GOLD, M.Metal)
B("ThroneArmR", 1.4, 3.6, 6.6, 4.2, 8.2, 98, GOLD, M.Metal)
B("ThroneArmCapL", 1.8, 0.8, 7, -4.2, 10.2, 98, GOLD_DARK, M.Metal, 0, false)
B("ThroneArmCapR", 1.8, 0.8, 7, 4.2, 10.2, 98, GOLD_DARK, M.Metal, 0, false)
B("ThroneCrownSpikeL", 1.4, 6, 1.2, -3.2, 23.5, 101.2, GOLD, M.Metal)
B("ThroneCrownSpikeM", 1.6, 8, 1.2, 0, 24.5, 101.2, GOLD, M.Metal)
B("ThroneCrownSpikeR", 1.4, 6, 1.2, 3.2, 23.5, 101.2, GOLD, M.Metal)
local function gem(x, y, z, s)
	local g = B("DiamondGem", s, s, s * 0.5, x, y, z, DIAMOND, M.Glass, 0, false)
	g.CFrame = g.CFrame * CFrame.Angles(0, 0, math.rad(45))
	g.Reflectance = 0.3
	g.Transparency = 0.1
	local core = Ball("GemCore", s * 0.4, x, y, z - 0.3, WHITE, M.Neon)
	return g
end
gem(0, 18.5, 100.2, 2.4)
gem(-3, 12, 100.2, 1.4)
gem(3, 12, 100.2, 1.4)
gem(0, 27.5, 101.2, 1.8)
gem(-4.2, 11, 95.2, 1)
gem(4.2, 11, 95.2, 1)

local Seat = Instance.new("Seat")
Seat.Name = "ThroneSeat"
Seat.Size = Vector3.new(6, 1, 5) * S
Seat.CFrame = at(0, 8.2, 98)
Seat.Transparency = 1
Seat.Anchored = true
Seat.CanCollide = false
Seat.Parent = CUR

-- backdrop: big banners + rose window + warm light
banner(-16, 22, 101.6, 180, 7, 18)
banner(16, 22, 101.6, 180, 7, 18)
do
	local rose = VC("RoseWindowGlass", 6, 0.6, 0, 30, 101.7, Color3.fromRGB(190, 60, 70), M.Glass, false)
	rose.Orientation = Vector3.new(90, 0, 0)
	rose.CFrame = at(0, 30, 101.7) * CFrame.Angles(math.pi / 2, 0, 0)
	rose.Transparency = 0.25
	for i = 0, 7 do
		local a = i / 8 * math.pi * 2
		local seg = B("RosePane", 2, 2, 0.5, math.cos(a) * 3.2, 30 + math.sin(a) * 3.2, 101.5, i % 2 == 0 and DIAMOND or GOLD, M.Glass, 0, false)
		seg.Transparency = 0.3
	end
	VC("RoseRim", 6.8, 0.8, 0, 30, 101.4, GOLD, M.Metal, false).CFrame = at(0, 30, 101.4) * CFrame.Angles(math.pi / 2, 0, 0)
	local lp = B("ThroneLight", 1, 1, 1, 0, 18, 92, GOLD, M.Neon, 0, false)
	lp.Transparency = 1
	addLight(lp, Color3.fromRGB(255, 205, 120), 40, 2.2)
end
torch(-18, 9, 100, true)
torch(18, 9, 100, true)

--==================================================
-- ROYAL BEDROOM (open) + SECRET ROOM interior
--==================================================
section("Chamber")
-- open archway into the royal bedroom (no locks)
B("BedroomArchGold", 1, 1, 8.6, -42, 14.6, 82, GOLD, M.Metal, 0, false)
-- furniture inside
B("Bed", 8, 2, 14, -70, 1.5, 78, WOOD, M.Wood)
B("BedCover", 7.6, 0.8, 9, -70, 2.8, 80, RED_DEEP, M.Fabric, 0, false)
B("BedHead", 8, 6, 1, -70, 4, 71, WOOD_DARK, M.Wood)
B("Table", 6, 0.8, 4, -66, 4, 98, WOOD, M.Wood)
for _, d in ipairs({ { -68.5, 96.5 }, { -63.5, 96.5 }, { -68.5, 99.5 }, { -63.5, 99.5 } }) do
	B("TableLeg", 0.6, 3.6, 0.6, d[1], 2.2, d[2], WOOD_DARK, M.Wood)
end
B("Bookshelf", 12, 12, 2, -58, 6.5, 102, WOOD_DARK, M.Wood)
for i = 0, 9 do
	B("Book", 0.8, 3, 1, -63 + i * 1.1, 4.6, 101, Color3.fromHSV((i * 0.13) % 1, 0.7, 0.7), M.SmoothPlastic, 0, false)
	B("Book", 0.8, 3, 1, -63 + i * 1.1, 9.4, 101, Color3.fromHSV((i * 0.19 + 0.3) % 1, 0.6, 0.7), M.SmoothPlastic, 0, false)
end
B("ChamberRug", 14, 0.2, 14, -58, 0.6, 86, RED_DEEP, M.Fabric, 0, false)
torch(-72, 10, 76, true)
torch(-72, 10, 96, true)
torch(-46, 10, 96, true)
do
	local lp = B("ChamberLight", 1, 1, 1, -58, 26, 86, GOLD, M.Neon, 0, false)
	lp.Transparency = 1
	addLight(lp, Color3.fromRGB(255, 190, 110), 36, 1.4)
end

-- secret room dressing
section("SecretRoom")
B("SecretCarpet", 10, 0.2, 12, 52, 0.6, 44, Color3.fromRGB(40, 20, 90), M.Fabric, 0, false)
B("SecretPedestal", 3, 3, 3, 57, 2, 44, STONE_LIGHT, M.Marble)
for _, p in ipairs({ { 46.5, 38 }, { 46.5, 50 }, { 58, 38 }, { 58, 50 } }) do
	torch(p[1], 9, p[2], true)
end
do
	local lp = B("SecretLight", 1, 1, 1, 52, 20, 44, DIAMOND, M.Neon, 0, false)
	lp.Transparency = 1
	addLight(lp, Color3.fromRGB(170, 220, 255), 30, 1.4)
end
for i = 0, 5 do
	local g = Ball("TreasureGem", 1.2, 49 + i * 1.8, 1.4, 52, Color3.fromHSV(i / 6, 0.7, 1), M.Neon)
end

-- the bookshelf that is really a door (east wall, z 40..48)
local secretDoor = B("SecretBookshelfDoor", 4, 12, 8, 42, 6.5, 44, WOOD_DARK, M.Wood)
local secretBooks = {}
for r = 0, 2 do
	for i = 0, 6 do
		secretBooks[#secretBooks + 1] = B("Book", 0.8, 2.4, 0.9, 40.2, 2.5 + r * 3.6, 41 + i * 1.1,
			Color3.fromHSV((i * 0.11 + r * 0.3) % 1, 0.7, 0.65), M.SmoothPlastic, 0, false)
	end
end
B("SecretShelfBoard", 0.6, 0.5, 8, 40.4, 4.3, 44, WOOD, M.Wood, 0, false)
B("SecretShelfBoard", 0.6, 0.5, 8, 40.4, 7.9, 44, WOOD, M.Wood, 0, false)

--==================================================
-- COURTYARD PROPS: fountain, crates, lamps, treasure
--==================================================
section("Courtyard")
-- fountain
VC("FountainBasin", 9, 2.4, 0, 1.2, -46, STONE_LIGHT, M.Marble)
VC("FountainWater", 8, 1.6, 0, 1.7, -46, Color3.fromRGB(70, 160, 220), M.Glass, false).Transparency = 0.35
VC("FountainColumn", 1.4, 8, 0, 5, -46, STONE_LIGHT, M.Marble)
VC("FountainBowl", 3.6, 1, 0, 9.4, -46, GOLD, M.Metal, false)
Ball("FountainDiamond", 2.4, 0, 11.4, -46, DIAMOND, M.Glass).Reflectance = 0.3
do
	local lp = B("FountainLight", 1, 1, 1, 0, 10, -46, DIAMOND, M.Neon, 0, false)
	lp.Transparency = 1
	addLight(lp, Color3.fromRGB(150, 220, 255), 30, 1.2)
end

-- lamp posts along the royal path
for _, z in ipairs({ -90, -66, -24, 0 }) do
	for _, x in ipairs({ -10, 10 }) do
		B("LampPost", 0.6, 9, 0.6, x, 4.5, z, IRON, M.Metal)
		local lamp = B("LampGlass", 1.8, 1.8, 1.8, x, 9.6, z, Color3.fromRGB(255, 210, 140), M.Neon, 0, false)
		lamp.Transparency = 0.2
		addLight(lamp, Color3.fromRGB(255, 190, 110), 24, 1.3)
	end
end

-- hedges / trees give the courtyard life
local function tree(x, z, s)
	VC("TreeTrunk", 1.2 * s, 8 * s, x, 4 * s, z, WOOD_DARK, M.Wood)
	Ball("TreeLeaves", 9 * s, x, 11 * s, z, Color3.fromRGB(44, 100, 52), M.Grass)
	Ball("TreeLeaves2", 6 * s, x + 2 * s, 14 * s, z + 1 * s, Color3.fromRGB(52, 116, 58), M.Grass)
end
tree(-70, -80, 1)
tree(70, -80, 1)
tree(-88, 10, 1.1)
tree(88, 10, 1.1)

-- crates and barrels (one hides the ruby key)
local crates = {}
local function crate(x, z, ry)
	local c = B("Crate", 4, 4, 4, x, 2.5, z, WOOD, M.WoodPlanks, ry)
	B("CrateBandA", 4.2, 0.5, 4.2, x, 1.3, z, IRON, M.Metal, ry, false)
	B("CrateBandB", 4.2, 0.5, 4.2, x, 3.7, z, IRON, M.Metal, ry, false)
	crates[#crates + 1] = c
	return c
end
local function barrel(x, z)
	VC("Barrel", 1.6, 4, x, 2.5, z, WOOD, M.Wood)
	VC("BarrelBand", 1.7, 0.4, x, 1.6, z, IRON, M.Metal, false)
	VC("BarrelBand", 1.7, 0.4, x, 3.5, z, IRON, M.Metal, false)
end
crate(-96, -92, 15)
crate(-90, -90, -20)
crate(96, -96, 5)
crate(-98, 40, 0)
crate(98, 30, 25)
crate(70, 96, 10)
barrel(-93, -84)
barrel(92, -90)
barrel(-94, 32)
barrel(100, 40)
barrel(75, 92)

-- west armoury shed
B("ShedWall", 16, 12, 1, -88, 6.5, -20, WOOD_DARK, M.WoodPlanks)
B("ShedWallSide", 1, 12, 14, -96, 6.5, -13, WOOD_DARK, M.WoodPlanks)
B("ShedRoof", 18, 1, 17, -89, 13, -13, ROOF, M.Slate, 0)
for i = 0, 3 do
	B("ShedSword", 0.5, 7, 0.3, -94 + i * 3, 7, -19.3, GOLD, M.Metal, 0, false)
end

--==================================================
-- LAVA MOAT + DRAWBRIDGE
--==================================================
section("Moat")
do
	local function water(name, sx, sz, x, z)
		local w = B(name, sx, 1.2, sz, x, -0.2, z, Color3.fromRGB(255, 84, 16), M.Neon, 0, false)
		w.Transparency = 0.15
		addLight(w, Color3.fromRGB(255, 90, 30), 60, 1.6)
		return w
	end
	water("MoatNorth", 292, 15, 0, 127.5)
	water("MoatWest", 15, 240, -127.5, 0)
	water("MoatEast", 15, 240, 127.5, 0)
	water("MoatSouthL", 138, 15, -77, -127.5)
	water("MoatSouthR", 138, 15, 77, -127.5)
	-- stone edge of the moat
	B("MoatEdgeNorth", 292, 1.4, 2, 0, 0.7, 135.5, STONE_DARK, M.Cobblestone)
	B("MoatEdgeWest", 2, 1.4, 270, -135.5, 0.7, 0, STONE_DARK, M.Cobblestone)
	B("MoatEdgeEast", 2, 1.4, 270, 135.5, 0.7, 0, STONE_DARK, M.Cobblestone)
	B("MoatEdgeSouthL", 134, 1.4, 2, -78, 0.7, -135.5, STONE_DARK, M.Cobblestone)
	B("MoatEdgeSouthR", 134, 1.4, 2, 78, 0.7, -135.5, STONE_DARK, M.Cobblestone)
	-- drawbridge across the south moat (wood + iron + chains)
	B("Drawbridge", 16, 1, 18, 0, 0.3, -127.5, WOOD, M.WoodPlanks)
	for i = -3, 3 do
		B("BridgePlank", 16, 0.15, 0.3, 0, 0.9, -127.5 + i * 2.4, WOOD_DARK, M.Wood, 0, false)
	end
	B("BridgeRailL", 0.8, 3, 18, -8, 2, -127.5, WOOD_DARK, M.Wood)
	B("BridgeRailR", 0.8, 3, 18, 8, 2, -127.5, WOOD_DARK, M.Wood)
	for _, sx in ipairs({ -8, 8 }) do
		for i = 0, 5 do
			B("BridgePost", 1.2, 4, 1.2, sx, 2.5, -136 + i * 3.4, IRON, M.Metal)
		end
	end
	for _, cx in ipairs({ -6.5, 6.5 }) do
		for i = 0, 7 do
			B("BridgeChain", 0.4, 0.4, 1.4, cx, 22 - i * 2.2, -112 - i * 2.2, IRON, M.Metal, 0, false)
		end
	end
	B("OuterPath", 14, 0.2, 44, 0, 0.55, -160, Color3.fromRGB(176, 150, 112), M.Pavement, 0, true)
end

--==================================================
-- OUTER VILLAGE (south of the gate)
--==================================================
section("Village")
do
	local function house(x, z, ry, w, d, h, wallColor, roofColor)
		local c = at(x, 0, z, ry)
		local base = P("HouseWalls", Vector3.new(w, h, d) * S, c * CFrame.new(0, h / 2 * S, 0), wallColor, M.Brick)
		P("HouseDoor", Vector3.new(3, 6, 0.5) * S, c * CFrame.new(0, 3 * S, -d / 2 * S - 0.1), WOOD_DARK, M.Wood, nil, false)
		P("HouseWindowL", Vector3.new(2.4, 2.4, 0.5) * S, c * CFrame.new(-w / 3 * S, h * 0.6 * S, -d / 2 * S - 0.1), Color3.fromRGB(255, 214, 140), M.Neon, nil, false)
		P("HouseWindowR", Vector3.new(2.4, 2.4, 0.5) * S, c * CFrame.new(w / 3 * S, h * 0.6 * S, -d / 2 * S - 0.1), Color3.fromRGB(255, 214, 140), M.Neon, nil, false)
		P("HouseBeamA", Vector3.new(0.5, h, 0.5) * S, c * CFrame.new(-w / 2 * S, h / 2 * S, -d / 2 * S), WOOD_DARK, M.Wood, nil, false)
		P("HouseBeamB", Vector3.new(0.5, h, 0.5) * S, c * CFrame.new(w / 2 * S, h / 2 * S, -d / 2 * S), WOOD_DARK, M.Wood, nil, false)
		-- gable roof from two tilted slabs
		local slope = math.rad(32)
		local rw = (w / 2 + 1.5) / math.cos(slope)
		P("RoofL", Vector3.new(rw, 0.8, d + 3) * S, c * CFrame.new(-w / 4 * S, (h + w / 4 * math.tan(slope)) * S, 0) * CFrame.Angles(0, 0, slope), roofColor, M.Slate)
		P("RoofR", Vector3.new(rw, 0.8, d + 3) * S, c * CFrame.new(w / 4 * S, (h + w / 4 * math.tan(slope)) * S, 0) * CFrame.Angles(0, 0, -slope), roofColor, M.Slate)
		P("Chimney", Vector3.new(2, 6, 2) * S, c * CFrame.new(w / 3 * S, (h + 4) * S, d / 4 * S), STONE_DARK, M.Brick)
		return base
	end
	local wc = { Color3.fromRGB(190, 176, 150), Color3.fromRGB(166, 150, 130), Color3.fromRGB(205, 192, 170), Color3.fromRGB(150, 140, 126) }
	local rc = { ROOF, Color3.fromRGB(70, 44, 30), Color3.fromRGB(44, 70, 80), Color3.fromRGB(88, 60, 30) }
	local spots = {
		{ -48, -150, 10 }, { -78, -156, -8 }, { -108, -148, 20 }, { -60, -190, 0 },
		{ 48, -150, -10 }, { 78, -156, 8 }, { 108, -148, -20 }, { 60, -190, 0 },
		{ -96, -184, 15 }, { 96, -184, -15 },
	}
	for i, sp in ipairs(spots) do
		house(sp[1], sp[2], sp[3], 14 + (i % 3) * 3, 12 + (i % 2) * 3, 9 + (i % 4), wc[i % 4 + 1], rc[(i + 1) % 4 + 1])
	end
	for _, tp in ipairs({ { -30, -170 }, { 30, -170 }, { -120, -170 }, { 120, -170 }, { -20, -205 }, { 20, -205 } }) do
		VC("VillageTreeTrunk", 1.1, 8, tp[1], 4, tp[2], WOOD_DARK, M.Wood)
		Ball("VillageTreeLeaves", 9, tp[1], 11, tp[2], Color3.fromRGB(46, 108, 50), M.Grass)
	end
	-- lantern posts down the outer path
	for _, z in ipairs({ -142, -158, -174 }) do
		for _, x in ipairs({ -9, 9 }) do
			B("OuterLampPost", 0.6, 9, 0.6, x, 4.5, z, IRON, M.Metal)
			local lamp = B("OuterLamp", 1.8, 1.8, 1.8, x, 9.6, z, Color3.fromRGB(255, 210, 140), M.Neon, 0, false)
			addLight(lamp, Color3.fromRGB(255, 190, 110), 24, 1.2)
		end
	end
end

--==================================================
-- COURTYARD LIFE: market, forge, well, training yard, stables
--==================================================
section("CourtyardLife")
do
	local awn = { RED, Color3.fromRGB(40, 90, 150), Color3.fromRGB(200, 150, 30), Color3.fromRGB(30, 110, 70) }
	local function stall(x, z, ry, i)
		B("StallPostA", 0.6, 9, 0.6, x - 4, 4.5, z - 3, WOOD_DARK, M.Wood, ry)
		B("StallPostB", 0.6, 9, 0.6, x + 4, 4.5, z - 3, WOOD_DARK, M.Wood, ry)
		B("StallPostC", 0.6, 9, 0.6, x - 4, 4.5, z + 3, WOOD_DARK, M.Wood, ry)
		B("StallPostD", 0.6, 9, 0.6, x + 4, 4.5, z + 3, WOOD_DARK, M.Wood, ry)
		B("StallAwning", 10, 0.5, 8, x, 9.2, z, awn[i % 4 + 1], M.Fabric, ry)
		B("StallCounter", 8, 3, 2.4, x, 1.8, z - 2, WOOD, M.WoodPlanks, ry)
		B("StallGoods1", 1.4, 1.4, 1.4, x - 2.5, 4, z - 2, Color3.fromRGB(200, 60, 40), M.SmoothPlastic, ry, false)
		B("StallGoods2", 1.4, 1.4, 1.4, x, 4, z - 2, Color3.fromRGB(220, 170, 50), M.SmoothPlastic, ry, false)
		B("StallGoods3", 1.4, 1.4, 1.4, x + 2.5, 4, z - 2, Color3.fromRGB(70, 140, 70), M.SmoothPlastic, ry, false)
	end
	stall(-48, -70, 0, 0)
	stall(-48, -90, 0, 1)
	stall(48, -70, 0, 2)
	stall(48, -90, 0, 3)
	stall(-48, -24, 0, 1)
	stall(48, -24, 0, 2)

	-- forge / blacksmith
	B("ForgeBase", 8, 4, 6, 70, 2.5, -40, STONE, M.Brick)
	B("ForgeChimney", 3, 14, 3, 70, 11, -37, STONE_DARK, M.Brick)
	local coals = B("ForgeCoals", 6, 0.6, 4, 70, 4.7, -40, Color3.fromRGB(255, 90, 30), M.Neon, 0, false)
	local ff = Instance.new("Fire")
	ff.Size = 7
	ff.Heat = 9
	ff.Parent = coals
	addLight(coals, Color3.fromRGB(255, 120, 50), 24, 2)
	B("AnvilBase", 2.4, 2, 2.4, 62, 2, -40, IRON, M.Metal)
	B("AnvilTop", 4.4, 1, 1.8, 62, 3.5, -40, Color3.fromRGB(80, 82, 90), M.Metal)
	B("ForgeRoof", 14, 0.6, 12, 68, 12, -42, WOOD_DARK, M.Wood)
	for _, d in ipairs({ { 62, -46 }, { 74, -46 }, { 62, -36 }, { 74, -36 } }) do
		B("ForgePost", 0.7, 12, 0.7, d[1], 6, d[2], WOOD_DARK, M.Wood)
	end

	-- well
	VC("WellWall", 4, 3.4, -66, 1.7, -40, STONE, M.Cobblestone)
	VC("WellWater", 3.2, 0.5, -66, 2.9, -40, Color3.fromRGB(40, 110, 170), M.Glass, false)
	B("WellPostA", 0.7, 9, 0.7, -69, 7, -40, WOOD_DARK, M.Wood)
	B("WellPostB", 0.7, 9, 0.7, -63, 7, -40, WOOD_DARK, M.Wood)
	B("WellBeam", 7, 0.7, 0.7, -66, 11.4, -40, WOOD_DARK, M.Wood)
	B("WellRoofL", 9, 0.5, 6, -66, 12.4, -40, ROOF, M.Slate)

	-- training yard dummies and archery targets
	for i = 0, 3 do
		local x = 70 + i * 6
		B("DummyPost", 0.8, 6, 0.8, x, 3, 4, WOOD, M.Wood)
		B("DummyArms", 4, 0.8, 0.8, x, 5, 4, WOOD, M.Wood)
		Ball("DummyHead", 1.8, x, 7, 4, Color3.fromRGB(190, 160, 110), M.Fabric)
		B("DummyBody", 2.2, 3, 1.4, x, 4, 4, Color3.fromRGB(170, 140, 90), M.Fabric, 0, false)
	end
	for i = 0, 2 do
		local z = 26 + i * 8
		VC("TargetStand", 0.4, 7, 98, 3.5, z, WOOD_DARK, M.Wood)
		local function disc(nm, r, th, dx, col, mat)
			local d = P(nm, Vector3.new(th, r * 2, r * 2) * S, CFrame.new(V(97.4 + dx, 6.5, z)), col, mat, nil, false)
			d.Shape = Enum.PartType.Cylinder
			return d
		end
		disc("TargetBoard", 2.6, 0.6, 0, Color3.fromRGB(240, 235, 225), M.SmoothPlastic)
		disc("TargetRed", 1.7, 0.7, -0.05, RED, M.SmoothPlastic)
		disc("TargetGold", 0.7, 0.8, -0.1, GOLD, M.Metal)
	end

	-- stables
	B("StableFloor", 30, 0.4, 18, -80, 0.4, -60, Color3.fromRGB(150, 120, 70), M.Ground)
	B("StableBack", 30, 11, 1, -80, 6, -69, WOOD_DARK, M.WoodPlanks)
	B("StableSideL", 1, 11, 18, -95, 6, -60, WOOD_DARK, M.WoodPlanks)
	B("StableSideR", 1, 11, 18, -65, 6, -60, WOOD_DARK, M.WoodPlanks)
	B("StableRoof", 33, 1, 21, -80, 12, -60, ROOF, M.Slate)
	for i = 0, 3 do
		B("StallDivider", 0.6, 6, 10, -92 + i * 8, 3.5, -64, WOOD, M.Wood)
		B("Hay", 5, 2, 3, -88 + i * 8, 1.4, -68, Color3.fromRGB(220, 190, 80), M.Fabric)
	end
	-- haystacks
	for _, h in ipairs({ { -100, -48 }, { -102, -44 }, { 102, -62 }, { 104, -58 } }) do
		Ball("HayStack", 7, h[1], 3, h[2], Color3.fromRGB(214, 184, 78), M.Fabric)
	end

	-- garden with hedge rows (east of the keep)
	local hedge = Color3.fromRGB(38, 90, 44)
	for i = 0, 5 do
		B("HedgeRow", 24, 4, 2.4, 76, 2.2, 96 - i * 7, hedge, M.Grass)
	end
	for _, f in ipairs({ { 66, 92 }, { 86, 85 }, { 66, 71 }, { 86, 64 } }) do
		for k = 0, 4 do
			Ball("Flower", 1.2, f[1] + k * 1.8, 1, f[2], Color3.fromHSV((k * 0.19 + f[1] * 0.01) % 1, 0.7, 1), M.Neon)
		end
	end

	-- wall-top beacons on every tower
	for _, p in ipairs({ { -110, -110 }, { 110, -110 }, { 110, 110 } }) do
		local br = B("BeaconBowl", 4, 1, 4, p[1], 65, p[2], GOLD_DARK, M.Metal, 0, false)
		local bf = Instance.new("Fire")
		bf.Size = 12
		bf.Parent = br
		addLight(br, Color3.fromRGB(255, 150, 60), 40, 2)
	end
end

--==================================================
-- THE ROYAL TROPHY (beside the throne) + GOLD STATUE
--==================================================
section("Trophy")
local TROPHY_X, TROPHY_Z, DAIS_TOP = 12, 97, 4.1
do
	local gy = DAIS_TOP
	-- three-tier base
	B("TrophyBase1", 8, 1.2, 8, TROPHY_X, gy + 0.6, TROPHY_Z, STONE_DARK, M.Granite)
	B("TrophyBase2", 6.6, 1, 6.6, TROPHY_X, gy + 1.7, TROPHY_Z, STONE_LIGHT, M.Marble)
	B("TrophyBase3", 5.4, 0.8, 5.4, TROPHY_X, gy + 2.6, TROPHY_Z, GOLD_DARK, M.Metal)
	B("TrophyBase4", 4.4, 0.6, 4.4, TROPHY_X, gy + 3.3, TROPHY_Z, GOLD, M.Metal)
	-- gold trim round the base
	B("TrophyTrimF", 8.3, 0.3, 0.3, TROPHY_X, gy + 1.15, TROPHY_Z - 4.1, GOLD, M.Metal, 0, false)
	B("TrophyTrimB", 8.3, 0.3, 0.3, TROPHY_X, gy + 1.15, TROPHY_Z + 4.1, GOLD, M.Metal, 0, false)
	B("TrophyTrimL", 0.3, 0.3, 8.3, TROPHY_X - 4.1, gy + 1.15, TROPHY_Z, GOLD, M.Metal, 0, false)
	B("TrophyTrimR", 0.3, 0.3, 8.3, TROPHY_X + 4.1, gy + 1.15, TROPHY_Z, GOLD, M.Metal, 0, false)
	-- stem
	local y = gy + 3.6
	VC("TrophyFoot", 2.2, 0.8, TROPHY_X, y + 0.4, TROPHY_Z, GOLD, M.Metal, false)
	VC("TrophyStem", 0.9, 4, TROPHY_X, y + 2.8, TROPHY_Z, GOLD, M.Metal, false)
	VC("TrophyKnotLow", 1.6, 0.8, TROPHY_X, y + 2.2, TROPHY_Z, GOLD_DARK, M.Metal, false)
	Ball("TrophyKnot", 2.2, TROPHY_X, y + 4.2, TROPHY_Z, GOLD, M.Metal)
	VC("TrophyCollar", 1.8, 0.7, TROPHY_X, y + 5.5, TROPHY_Z, GOLD_DARK, M.Metal, false)
	-- cup: stacked discs that widen like a goblet
	local radii = { 1.7, 2.1, 2.5, 2.85, 3.15, 3.35, 3.45, 3.5 }
	for i, r in ipairs(radii) do
		VC("TrophyCup" .. i, r, 0.9, TROPHY_X, y + 5.9 + i * 0.85, TROPHY_Z, GOLD, M.Metal, false)
	end
	VC("TrophyRim", 3.7, 0.5, TROPHY_X, y + 5.9 + #radii * 0.85 + 0.35, TROPHY_Z, GOLD_DARK, M.Metal, false)
	local inner = VC("TrophyInner", 3.1, 0.2, TROPHY_X, y + 5.9 + #radii * 0.85 + 0.55, TROPHY_Z, RED_DEEP, M.Neon, false)
	-- handles: arcs of balls on both sides
	for _, side in ipairs({ -1, 1 }) do
		for i = 0, 8 do
			local a = i / 8 * math.pi
			Ball("TrophyHandle", 0.9, TROPHY_X + side * (3.7 + math.sin(a) * 2.2), y + 8.4 + math.cos(a) * 2.4, TROPHY_Z, GOLD, M.Metal)
		end
	end
	-- laurel leaves round the cup
	for i = 0, 11 do
		local a = i / 12 * math.pi * 2
		local lf = B("Laurel", 0.5, 1.6, 0.2, TROPHY_X + math.cos(a) * 3.55, y + 8.2, TROPHY_Z + math.sin(a) * 3.55, Color3.fromRGB(255, 214, 80), M.Metal, -math.deg(a), false)
	end
	-- crown of diamonds on top
	for i = 0, 4 do
		local a = i / 5 * math.pi * 2
		local sp = B("TrophyCrownSpike", 0.5, 2, 0.5, TROPHY_X + math.cos(a) * 2.2, y + 14.4, TROPHY_Z + math.sin(a) * 2.2, GOLD, M.Metal, 0, false)
		Ball("TrophyCrownGem", 0.8, TROPHY_X + math.cos(a) * 2.2, y + 15.6, TROPHY_Z + math.sin(a) * 2.2, DIAMOND, M.Glass).Reflectance = 0.3
	end
	local big = Ball("TrophyDiamond", 3, TROPHY_X, y + 15.2, TROPHY_Z, DIAMOND, M.Glass)
	big.Reflectance = 0.35
	big.Transparency = 0.1
	local glow = Ball("TrophyDiamondCore", 1.2, TROPHY_X, y + 15.2, TROPHY_Z, WHITE, M.Neon)
	addLight(glow, Color3.fromRGB(190, 235, 255), 36, 2.2)
	-- nameplate on the front of the base
	local plate = B("TrophyPlate", 5, 1.4, 0.3, TROPHY_X, gy + 1.7, TROPHY_Z - 3.4, GOLD_DARK, M.Metal, 0, false)
	local sg = Instance.new("SurfaceGui")
	sg.Face = Enum.NormalId.Front
	sg.CanvasSize = Vector2.new(500, 140)
	sg.LightInfluence = 0
	sg.Parent = plate
	local pl = Instance.new("TextLabel")
	pl.Size = UDim2.fromScale(1, 1)
	pl.BackgroundTransparency = 1
	pl.Text = "ALPHA EMPIRE"
	pl.TextColor3 = Color3.fromRGB(255, 236, 170)
	pl.Font = Enum.Font.GothamBlack
	pl.TextScaled = true
	pl.Parent = sg
	-- spot light from above so it shines
	local spot = B("TrophySpot", 1, 1, 1, TROPHY_X, gy + 30, TROPHY_Z, WHITE, M.Neon, 0, false)
	spot.Transparency = 1
	addLight(spot, Color3.fromRGB(255, 226, 150), 46, 2.4)
	-- sword stand on the other side of the throne
	local sx = -23
	B("SwordStandBase", 6, 1, 6, sx, gy + 0.5, TROPHY_Z, STONE_DARK, M.Granite)
	B("SwordBlade", 0.7, 14, 0.2, sx, gy + 8.5, TROPHY_Z, Color3.fromRGB(215, 224, 235), M.Metal, 0, false)
	B("SwordGuard", 4, 0.7, 0.7, sx, gy + 2.2, TROPHY_Z, GOLD, M.Metal, 0, false)
	B("SwordHilt", 0.6, 2.4, 0.6, sx, gy + 0.6 + 0.8, TROPHY_Z, GOLD_DARK, M.Metal, 0, false)
	Ball("SwordPommel", 0.9, sx, gy + 1.2, TROPHY_Z, GOLD, M.Metal)
end

--==================================================
-- GIANT ALPHA EMPIRE FLAG on top of the keep
--==================================================
section("Flag")
local FLAG = {}
do
	local FU = S / 1.4         -- flag scale follows the castle scale
	local N = 36               -- number of cloth segments
	local SEG = 3 * FU         -- width of one segment (studs)
	local FH = 56 * FU         -- flag height (studs)
	local POLE_H = 150 * FU
	local baseY = 43 * S       -- top of the keep roof (relative to Center)
	local px, pz = 0, 62 * S
	local function raw(name, size, cf, color, mat)
		return P(name, size, cf, color, mat, nil, false)
	end
	local pole = raw("FlagPole", Vector3.new(2 * FU, POLE_H, 2 * FU), CFrame.new(Center + Vector3.new(px, baseY + POLE_H / 2, pz)), GOLD, M.Metal)
	pole.CanCollide = true
	raw("FlagPoleBase", Vector3.new(7 * FU, 3 * FU, 7 * FU), CFrame.new(Center + Vector3.new(px, baseY + 1.5 * FU, pz)), GOLD_DARK, M.Metal)
	for i = 1, 6 do
		raw("FlagPoleRing", Vector3.new(3 * FU, 0.9 * FU, 3 * FU), CFrame.new(Center + Vector3.new(px, baseY + i * (POLE_H / 7), pz)), GOLD_DARK, M.Metal)
	end
	local top = Instance.new("Part")
	top.Name = "FlagFinial"
	top.Shape = Enum.PartType.Ball
	top.Size = Vector3.new(6, 6, 6) * FU
	top.CFrame = CFrame.new(Center + Vector3.new(px, baseY + POLE_H + 2 * FU, pz))
	top.Color = GOLD
	top.Material = M.Metal
	top.Anchored = true
	top.CanCollide = false
	top.Parent = CUR
	raw("FlagCrossbar", Vector3.new(SEG * N + 6 * FU, 1.4 * FU, 1.4 * FU), CFrame.new(Center + Vector3.new(px + (SEG * N) / 2 + 1.5 * FU, baseY + POLE_H - 3 * FU, pz)), GOLD, M.Metal)
	local lamp = raw("FlagGlow", Vector3.new(2, 2, 2), CFrame.new(Center + Vector3.new(px, baseY + POLE_H + 8 * FU, pz)), WHITE, M.Neon)
	lamp.Transparency = 1
	addLight(lamp, Color3.fromRGB(255, 80, 70), 90, 2.5)

	-- ONE flag design, 864 x 448 canvas units; every segment shows a 24px slice.
	-- Text sizes stay under Roblox's 100 limit, so the letters are crisp and large.
	local PX = 24
	local FULLW, FULLH = N * PX, 448
	local function buildFace(parent, offsetX)
		local clip = Instance.new("Frame")
		clip.Size = UDim2.fromScale(1, 1)
		clip.BackgroundTransparency = 1
		clip.ClipsDescendants = true
		clip.Parent = parent
		local art = Instance.new("Frame")
		art.Position = UDim2.fromOffset(offsetX, 0)
		art.Size = UDim2.fromOffset(FULLW, FULLH)
		art.BackgroundColor3 = Color3.fromRGB(150, 10, 18)
		art.BorderSizePixel = 0
		art.Parent = clip
		local g = Instance.new("UIGradient")
		g.Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(120, 4, 12)),
			ColorSequenceKeypoint.new(0.5, Color3.fromRGB(196, 20, 30)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(100, 2, 10)),
		})
		g.Rotation = 20
		g.Parent = art
		local function bar(x, y, w, h, c)
			local f = Instance.new("Frame")
			f.Position = UDim2.fromOffset(x, y)
			f.Size = UDim2.fromOffset(w, h)
			f.BackgroundColor3 = c or GOLD
			f.BorderSizePixel = 0
			f.Parent = art
			return f
		end
		local light = Color3.fromRGB(255, 226, 140)
		bar(0, 0, FULLW, 16)
		bar(0, FULLH - 16, FULLW, 16)
		bar(0, 0, 16, FULLH)
		bar(FULLW - 16, 0, 16, FULLH)
		bar(26, 26, FULLW - 52, 4, light)
		bar(26, FULLH - 30, FULLW - 52, 4, light)
		bar(26, 26, 4, FULLH - 52, light)
		bar(FULLW - 30, 26, 4, FULLH - 52, light)
		local function label(text, y, h, size, color, font)
			local t = Instance.new("TextLabel")
			t.Position = UDim2.fromOffset(120, y)
			t.Size = UDim2.fromOffset(FULLW - 240, h)
			t.BackgroundTransparency = 1
			t.Text = text
			t.TextColor3 = color
			t.TextSize = size
			t.TextStrokeColor3 = Color3.fromRGB(50, 0, 4)
			t.TextStrokeTransparency = 0
			t.Font = font
			t.Parent = art
			return t
		end
		label("ALPHA", 60, 150, 100, Color3.fromRGB(255, 214, 90), Enum.Font.GothamBlack)
		label("EMPIRE", 200, 150, 100, Color3.fromRGB(255, 214, 90), Enum.Font.GothamBlack)
		for _, cx in ipairs({ 66, FULLW - 66 }) do
			local d1 = bar(cx - 36, FULLH / 2 - 36, 72, 72, GOLD)
			d1.Rotation = 45
			local d2 = bar(cx - 26, FULLH / 2 - 26, 52, 52, Color3.fromRGB(120, 4, 12))
			d2.Rotation = 45
			local d3 = bar(cx - 14, FULLH / 2 - 14, 28, 28, DIAMOND)
			d3.Rotation = 45
		end
	end

	FLAG.segs = {}
	for i = 0, N - 1 do
		local seg = Instance.new("Part")
		seg.Name = "FlagSeg"
		seg.Size = Vector3.new(SEG + 0.15 * FU, FH, 0.25 * FU)
		seg.Color = Color3.fromRGB(150, 10, 18)
		seg.Material = M.Fabric
		seg.Anchored = true
		seg.CanCollide = false
		seg.Parent = CUR
		-- The Front face is seen from -Z, where +X points LEFT, so its slices run in reverse.
		local f1 = Instance.new("SurfaceGui")
		f1.Face = Enum.NormalId.Front
		f1.CanvasSize = Vector2.new(PX, FULLH)
		f1.LightInfluence = 0.1
		f1.Parent = seg
		buildFace(f1, -(N - 1 - i) * PX)
		local f2 = Instance.new("SurfaceGui")
		f2.Face = Enum.NormalId.Back
		f2.CanvasSize = Vector2.new(PX, FULLH)
		f2.LightInfluence = 0.1
		f2.Parent = seg
		buildFace(f2, -i * PX)
		FLAG.segs[i + 1] = seg
	end
	FLAG.N, FLAG.SEG, FLAG.FH, FLAG.FU = N, SEG, FH, FU
	FLAG.origin = Vector3.new(px, baseY + POLE_H - 4 * FU - FH / 2, pz)
	FLAG.center = Center + FLAG.origin + Vector3.new(1.5 * FU + SEG * N / 2, 0, 0)
	FLAG.top = Center + Vector3.new(px, baseY + POLE_H + 2 * FU, pz)

	local t0 = os.clock()
	bind(RunService.Heartbeat, function()
		local t = os.clock() - t0
		for i, seg in ipairs(FLAG.segs) do
			if not seg.Parent then return end
			local w = (i - 1) / (N - 1)
			local phase = t * 2.6 - i * 0.45
			local dz = math.sin(phase) * 2.2 * FU * w
			local dy = math.sin(phase * 0.5) * 0.5 * FU * w
			local yaw = math.cos(phase) * 0.1 * w
			seg.CFrame = CFrame.new(Center + FLAG.origin + Vector3.new(1.5 * FU + (i - 0.5) * SEG, dy, dz)) * CFrame.Angles(0, yaw, 0)
		end
	end)
end

--==================================================
-- WARRIOR GUARDS: gate, drawbridge and royal path
--==================================================
section("Warriors")
local GUARDS = {}
do
	local function warrior(x, z, ry, plume, dx, dz, amp)
		local c = at(x, 0, z, ry)
		local list = {}
		local function wp(name, size, ox, oy, oz, color, mat, shape)
			local p = P(name, size * S, c * CFrame.new(Vector3.new(ox, oy, oz) * S), color, mat, nil, false)
			if shape then p.Shape = shape end
			list[#list + 1] = p
			return p
		end
		local steel = Color3.fromRGB(150, 156, 168)
		local darkSteel = Color3.fromRGB(70, 74, 84)
		-- legs and boots
		wp("Boot", Vector3.new(1.5, 1, 2.2), -0.9, 0.5, -0.2, darkSteel, M.Metal)
		wp("Boot", Vector3.new(1.5, 1, 2.2), 0.9, 0.5, -0.2, darkSteel, M.Metal)
		wp("Leg", Vector3.new(1.2, 3.4, 1.3), -0.9, 2.7, 0, steel, M.Metal)
		wp("Leg", Vector3.new(1.2, 3.4, 1.3), 0.9, 2.7, 0, steel, M.Metal)
		wp("Knee", Vector3.new(1.4, 0.8, 1.5), -0.9, 3.2, -0.1, GOLD_DARK, M.Metal)
		wp("Knee", Vector3.new(1.4, 0.8, 1.5), 0.9, 3.2, -0.1, GOLD_DARK, M.Metal)
		-- kilt of plates
		wp("Tasset", Vector3.new(3.6, 1.6, 1.8), 0, 4.9, 0, RED_DEEP, M.Fabric)
		wp("Belt", Vector3.new(3.8, 0.5, 2), 0, 5.8, 0, GOLD, M.Metal)
		-- chest, emblem, back cape
		wp("Torso", Vector3.new(3.6, 3.4, 2), 0, 7.7, 0, steel, M.Metal)
		wp("ChestPlate", Vector3.new(3.2, 2.6, 0.5), 0, 7.9, -1.1, Color3.fromRGB(176, 182, 194), M.Metal)
		wp("ChestEmblem", Vector3.new(1, 1, 0.3), 0, 8.1, -1.4, RED, M.Neon).CFrame = c * CFrame.new(Vector3.new(0, 8.1, -1.4) * S) * CFrame.Angles(0, 0, math.rad(45))
		wp("Cape", Vector3.new(3.2, 6.4, 0.3), 0, 6.6, 1.2, RED, M.Fabric)
		wp("CapeTrim", Vector3.new(3.4, 0.4, 0.4), 0, 3.4, 1.2, GOLD, M.Metal)
		-- pauldrons + arms
		wp("Pauldron", Vector3.new(1.8, 1.8, 1.8), -2.4, 9.1, 0, GOLD, M.Metal, Enum.PartType.Ball)
		wp("Pauldron", Vector3.new(1.8, 1.8, 1.8), 2.4, 9.1, 0, GOLD, M.Metal, Enum.PartType.Ball)
		wp("Arm", Vector3.new(1, 3, 1.1), -2.5, 7.3, -0.1, steel, M.Metal)
		wp("Arm", Vector3.new(1, 3, 1.1), 2.5, 7.3, -0.1, steel, M.Metal)
		wp("Gauntlet", Vector3.new(1.2, 1, 1.3), -2.5, 5.6, -0.2, darkSteel, M.Metal)
		wp("Gauntlet", Vector3.new(1.2, 1, 1.3), 2.5, 5.6, -0.2, darkSteel, M.Metal)
		-- head, helmet, visor, plume
		wp("Neck", Vector3.new(1, 0.6, 1), 0, 9.7, 0, darkSteel, M.Metal)
		wp("Helmet", Vector3.new(2.2, 2.4, 2.2), 0, 11, 0, steel, M.Metal)
		wp("HelmetTop", Vector3.new(2.3, 0.6, 2.3), 0, 12.4, 0, GOLD, M.Metal)
		wp("Visor", Vector3.new(1.7, 0.35, 0.3), 0, 11.2, -1.15, BLACK, M.SmoothPlastic)
		wp("VisorSlit", Vector3.new(0.3, 1.2, 0.3), 0, 10.7, -1.15, BLACK, M.SmoothPlastic)
		wp("Crest", Vector3.new(0.4, 1.2, 2.6), 0, 13, 0, GOLD, M.Metal)
		wp("Plume", Vector3.new(0.5, 3.2, 1.2), 0, 14, 0.6, plume or RED, M.Fabric)
		-- spear in the right hand (stands upright), tip gold
		wp("SpearShaft", Vector3.new(0.35, 16, 0.35), 3.4, 8.5, -0.8, WOOD_DARK, M.Wood)
		wp("SpearTip", Vector3.new(0.7, 2.4, 0.3), 3.4, 17.4, -0.8, GOLD, M.Metal)
		wp("SpearCollar", Vector3.new(0.8, 0.5, 0.8), 3.4, 16.2, -0.8, GOLD_DARK, M.Metal)
		-- shield in the left hand
		wp("Shield", Vector3.new(3, 4.2, 0.5), -3.5, 7.3, -1.2, RED, M.Metal)
		wp("ShieldRim", Vector3.new(3.4, 4.6, 0.3), -3.5, 7.3, -1, GOLD, M.Metal)
		wp("ShieldBoss", Vector3.new(1.1, 1.1, 0.5), -3.5, 7.3, -1.6, GOLD, M.Metal, Enum.PartType.Ball)
		-- remember every part relative to the warrior so it can walk (patrol code lives further down)
		local g = { parts = {}, base = c, dir = Vector3.new(dx or 0, 0, dz or 1), amp = amp or 6, speed = 0.5 + math.random() * 0.2, clock = math.random() * 6, cur = c, arm = {} }
		for _, p in ipairs(list) do
			local rel = c:ToObjectSpace(p.CFrame)
			local isArm = (p.Name == "Arm" or p.Name == "Gauntlet") and rel.X > 0
			g.parts[#g.parts + 1] = { part = p, rel = rel, arm = isArm }
			if p.Name == "Arm" and isArm then g.shoulder = rel * CFrame.new(0, 1.5 * S, 0) end
		end
		GUARDS[#GUARDS + 1] = g
	end
	-- two at the gate arch, four on the drawbridge
	warrior(-13, -103, 0, nil, 1, 0, 3)
	warrior(13, -103, 0, nil, 1, 0, 3)
	warrior(-5.5, -121, 0, Color3.fromRGB(240, 200, 50), 0, 1, 5)
	warrior(5.5, -121, 0, Color3.fromRGB(240, 200, 50), 0, 1, 5)
	warrior(-5.5, -134, 0, nil, 0, 1, 4)
	warrior(5.5, -134, 0, nil, 0, 1, 4)
	-- honour guard lining the royal path, facing inwards
	for _, z in ipairs({ -84, -62, -40, -18 }) do
		warrior(-13, z, -90, Color3.fromRGB(240, 200, 50), 0, 1, 8)
		warrior(13, z, 90, Color3.fromRGB(240, 200, 50), 0, 1, 8)
	end
end

--==================================================
-- DANGER DECOR: spikes, skulls, pikes, dragons, braziers, lava vents
--==================================================
section("Danger")
local DANGER = {}
do
	local bone = Color3.fromRGB(232, 226, 206)

	local function skull(x, y, z, ry, s)
		s = s or 1
		local c = at(x, y, z, ry)
		local function sp(name, size, ox, oy, oz, color, mat, shape)
			local p = P(name, size * S * s, c * CFrame.new(Vector3.new(ox, oy, oz) * S * s), color, mat, nil, false)
			if shape then p.Shape = shape end
			return p
		end
		sp("Skull", Vector3.new(3.2, 3.2, 3.2), 0, 0, 0, bone, M.Marble, Enum.PartType.Ball)
		sp("SkullJaw", Vector3.new(2.2, 0.9, 2), 0, -1.8, -0.3, bone, M.Marble)
		sp("SkullEyeL", Vector3.new(0.9, 1.1, 0.6), -0.7, 0.2, -1.4, BLACK, M.SmoothPlastic, Enum.PartType.Ball)
		sp("SkullEyeR", Vector3.new(0.9, 1.1, 0.6), 0.7, 0.2, -1.4, BLACK, M.SmoothPlastic, Enum.PartType.Ball)
		sp("SkullGlowL", Vector3.new(0.35, 0.35, 0.3), -0.7, 0.2, -1.75, Color3.fromRGB(255, 40, 40), M.Neon, Enum.PartType.Ball)
		sp("SkullGlowR", Vector3.new(0.35, 0.35, 0.3), 0.7, 0.2, -1.75, Color3.fromRGB(255, 40, 40), M.Neon, Enum.PartType.Ball)
		sp("SkullNose", Vector3.new(0.5, 0.8, 0.4), 0, -0.6, -1.5, BLACK, M.SmoothPlastic)
		for i = -2, 2 do
			sp("SkullTooth", Vector3.new(0.3, 0.55, 0.3), i * 0.4, -1.4, -1.1, WHITE, M.SmoothPlastic)
		end
	end
	DANGER.skull = skull

	-- skulls over the gate and on the front towers
	for i = -2, 2 do
		skull(i * 4.5, 26, -114.4, 0, 1)
	end
	skull(-110, 30, -123.8, 0, 1.6)
	skull(110, 30, -123.8, 0, 1.6)
	skull(-22, 22, -119.2, 0, 1.3)
	skull(22, 22, -119.2, 0, 1.3)

	-- pikes with skulls along the outer path
	for _, z in ipairs({ -146, -162, -178 }) do
		for _, x in ipairs({ -10, 10 }) do
			B("PikePole", 0.6, 13, 0.6, x, 6.5, z, WOOD_DARK, M.Wood)
			skull(x, 14.2, z, 0, 0.8)
			B("PikeBanner", 0.2, 4, 3, x + (x < 0 and 1.8 or -1.8), 10.5, z, RED, M.Fabric, 0, false)
		end
	end

	-- spikes along the wall tops (between the merlons), 2 stacked cones each
	local function spike(x, z)
		VC("WallSpikeBase", 1.1, 3, x, 33.5, z, IRON, M.Metal, false)
		VC("WallSpikeTip", 0.5, 3, x, 36.5, z, Color3.fromRGB(120, 124, 134), M.Metal, false)
	end
	for x = -108, 108, 8 do
		if math.abs(x) > 14 then
			spike(x, 110)
			spike(x, -110)
		end
	end
	for z = -108, 108, 8 do
		spike(-110, z)
		spike(110, z)
	end

	-- braziers with red fire along the royal path
	local function brazier(x, z)
		VC("BrazierPost", 0.7, 4, x, 2, z, IRON, M.Metal)
		local bowl = B("BrazierBowl", 3, 1, 3, x, 4.4, z, GOLD_DARK, M.Metal, 0, false)
		local f = Instance.new("Fire")
		f.Size = 8
		f.Heat = 8
		f.Color = Color3.fromRGB(255, 70, 30)
		f.SecondaryColor = Color3.fromRGB(150, 10, 10)
		f.Parent = bowl
		addLight(bowl, Color3.fromRGB(255, 70, 40), 30, 1.8)
	end
	for _, z in ipairs({ -100, -78, -56, -34, -12 }) do
		brazier(-19, z)
		brazier(19, z)
	end

	-- lava vents in the courtyard with DANGER signs
	local function sign(x, y, z, ry, text)
		B("SignPost", 0.5, y, 0.5, x, y / 2, z, WOOD_DARK, M.Wood, ry, false)
		local board = B("SignBoard", 6, 3, 0.4, x, y + 1, z, Color3.fromRGB(240, 190, 20), M.SmoothPlastic, ry, false)
		local sg = Instance.new("SurfaceGui")
		sg.Face = Enum.NormalId.Front
		sg.CanvasSize = Vector2.new(360, 180)
		sg.LightInfluence = 0
		sg.Parent = board
		local tl = Instance.new("TextLabel")
		tl.Size = UDim2.fromScale(1, 1)
		tl.BackgroundTransparency = 1
		tl.Text = text
		tl.TextColor3 = BLACK
		tl.Font = Enum.Font.GothamBlack
		tl.TextScaled = true
		tl.Parent = sg
	end
	DANGER.sign = sign
	for _, v in ipairs({ { -72, -30 }, { 72, -30 }, { -72, -86 }, { 72, -86 }, { -86, -58 }, { 86, -58 } }) do
		local disc = VC("LavaVent", 4, 0.4, v[1], 0.6, v[2], Color3.fromRGB(255, 90, 20), M.Neon, false)
		local f = Instance.new("Fire")
		f.Size = 9
		f.Heat = 10
		f.Color = Color3.fromRGB(255, 110, 30)
		f.SecondaryColor = Color3.fromRGB(180, 20, 10)
		f.Parent = disc
		addLight(disc, Color3.fromRGB(255, 100, 40), 28, 1.8)
		VC("LavaVentRim", 4.8, 0.5, v[1], 0.5, v[2], BLACK, M.Slate, false)
		sign(v[1], 6, v[2] - 7, 0, "DANGER")
	end
	sign(-14, 7, -138, 0, "DANGER LAVA")
	sign(14, 7, -138, 0, "DANGER LAVA")

	-- dragon head builder (front faces -Z)
	function DANGER.dragon(x, y, z, ry, sc, fireOn)
		local c = at(x, y, z, ry)
		local scale = S * sc
		local scaleColor = Color3.fromRGB(46, 12, 16)
		local function dp(name, size, ox, oy, oz, color, mat, shape)
			local p = P(name, size * scale, c * CFrame.new(Vector3.new(ox, oy, oz) * scale), color, mat or M.Slate, nil, false)
			if shape then p.Shape = shape end
			return p
		end
		dp("DragonPlinth", Vector3.new(16, 3, 16), 0, 1.5, 0, STONE_DARK, M.Granite).CanCollide = true
		dp("DragonNeck", Vector3.new(6, 14, 6), 0, 9, 5, scaleColor).CanCollide = true
		for i = 0, 4 do
			dp("DragonNeckSpike", Vector3.new(1, 2.4, 1), 0, 6 + i * 2.6, 8.2, Color3.fromRGB(150, 20, 24), M.Metal)
		end
		dp("DragonHead", Vector3.new(8, 6, 9), 0, 16, -1, scaleColor)
		dp("DragonSnout", Vector3.new(5, 3.4, 7), 0, 15, -8, scaleColor)
		dp("DragonJaw", Vector3.new(4.6, 1.5, 8), 0, 12.2, -7, Color3.fromRGB(34, 8, 12))
		for i = -2, 2 do
			dp("DragonToothUp", Vector3.new(0.5, 1.3, 0.5), i * 0.9, 13, -10.6, WHITE, M.SmoothPlastic)
			dp("DragonToothDn", Vector3.new(0.5, 1.2, 0.5), i * 0.9, 13.1, -9.6, WHITE, M.SmoothPlastic)
		end
		for _, sx in ipairs({ -1, 1 }) do
			local horn = dp("DragonHorn", Vector3.new(1.3, 1.3, 8), sx * 3.4, 20, 2, Color3.fromRGB(210, 200, 170), M.Marble)
			horn.CFrame = c * CFrame.new(Vector3.new(sx * 3.4, 20, 2) * scale) * CFrame.Angles(math.rad(-38), 0, 0)
			local eye = dp("DragonEye", Vector3.new(1.3, 1.3, 1.3), sx * 3.2, 17.4, -5.4, Color3.fromRGB(255, 30, 30), M.Neon, Enum.PartType.Ball)
			addLight(eye, Color3.fromRGB(255, 40, 30), 22, 1.6)
		end
		local mouth = dp("DragonMouth", Vector3.new(1, 1, 1), 0, 13.2, -12.4, WHITE, M.SmoothPlastic)
		mouth.Transparency = 1
		local fire = Instance.new("Fire")
		fire.Size = 16 * sc
		fire.Heat = 12
		fire.Color = Color3.fromRGB(255, 120, 30)
		fire.SecondaryColor = Color3.fromRGB(180, 20, 10)
		fire.Enabled = fireOn and true or false
		fire.Parent = mouth
		return fire, dp("DragonHitbox", Vector3.new(8, 8, 9), 0, 15, -3, WHITE, M.SmoothPlastic), mouth
	end

	-- the dragon bust above the gate breathes fire all the time
	local gateFire, gateBox = DANGER.dragon(0, 31, -112, 0, 0.7, true)
	gateBox.Transparency = 1
	-- the courtyard dragon waits to be woken up (used by the free-roam code)
	DANGER.yardFire, DANGER.yardBox = DANGER.dragon(32, 0, -58, 0, 1, false)
	DANGER.yardBox.Transparency = 1
	DANGER.yardBox.CanCollide = false
end

--==================================================
-- LIGHTING (restored on exit)
--==================================================
local lightingBackup = {
	ClockTime = Lighting.ClockTime, Brightness = Lighting.Brightness, Ambient = Lighting.Ambient,
	OutdoorAmbient = Lighting.OutdoorAmbient, FogEnd = Lighting.FogEnd, FogStart = Lighting.FogStart,
	FogColor = Lighting.FogColor, ExposureCompensation = Lighting.ExposureCompensation,
}
local lightingMade = {}
pcall(function()
	Lighting.ClockTime = 18.6
	Lighting.Brightness = 2.2
	Lighting.Ambient = Color3.fromRGB(70, 60, 70)
	Lighting.OutdoorAmbient = Color3.fromRGB(90, 80, 95)
	Lighting.FogEnd = 1500
	Lighting.FogStart = 300
	Lighting.FogColor = Color3.fromRGB(120, 90, 110)
	local bloom = Instance.new("BloomEffect")
	bloom.Name = "AAYAN_CASTLE_BLOOM"
	bloom.Intensity = 0.4
	bloom.Size = 24
	bloom.Threshold = 1.1
	bloom.Parent = Lighting
	lightingMade[#lightingMade + 1] = bloom
	local cc = Instance.new("ColorCorrectionEffect")
	cc.Name = "AAYAN_CASTLE_CC"
	cc.TintColor = Color3.fromRGB(255, 238, 220)
	cc.Saturation = 0.12
	cc.Contrast = 0.08
	cc.Parent = Lighting
	lightingMade[#lightingMade + 1] = cc
	local sky = Instance.new("Sky")
	sky.Name = "AAYAN_CASTLE_SKY"
	sky.Parent = Lighting
	lightingMade[#lightingMade + 1] = sky
end)

--==================================================
-- MUSIC
--==================================================
local Sound = Instance.new("Sound")
Sound.Name = "AlphaHQMusic"
Sound.SoundId = MUSIC_ID
Sound.Volume = 0.6
Sound.Looped = true
Sound.Parent = workspace
pcall(function() Sound:Play() end)

--==================================================
-- UI: root, toasts, counters, tasks panel
--==================================================
local SG = Instance.new("ScreenGui")
SG.Name = "AAYAN_CASTLE_UI"
SG.ResetOnSpawn = false
SG.IgnoreGuiInset = true
SG.DisplayOrder = 300
SG.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
SG.Parent = PlayerGui

local function corner(p, r)
	local c = Instance.new("UICorner")
	c.CornerRadius = UDim.new(0, r)
	c.Parent = p
	return c
end
local function stroke(p, color, th)
	local s = Instance.new("UIStroke")
	s.Color = color
	s.Thickness = th or 1.5
	s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	s.Parent = p
	return s
end
local function tween(o, t, props, style, dir)
	local tw = TweenService:Create(o, TweenInfo.new(t, style or Enum.EasingStyle.Quad, dir or Enum.EasingDirection.Out), props)
	tw:Play()
	return tw
end

local function scaleFor()
	local c = getCam()
	local v = c and c.ViewportSize or Vector2.new(1280, 720)
	return math.clamp(math.min(v.X / 900, v.Y / 520), 0.55, 1.2)
end

-- toasts (top centre)
local toastHolder = Instance.new("Frame")
toastHolder.AnchorPoint = Vector2.new(0.5, 0)
toastHolder.Position = UDim2.new(0.5, 0, 0, 70)
toastHolder.Size = UDim2.fromOffset(360, 200)
toastHolder.BackgroundTransparency = 1
toastHolder.ZIndex = 50
toastHolder.Parent = SG
local tl = Instance.new("UIListLayout")
tl.Padding = UDim.new(0, 6)
tl.HorizontalAlignment = Enum.HorizontalAlignment.Center
tl.Parent = toastHolder

local function toast(text, good)
	local f = Instance.new("Frame")
	f.Size = UDim2.fromOffset(340, 38)
	f.BackgroundColor3 = Color3.fromRGB(14, 10, 8)
	f.BackgroundTransparency = 1
	f.ZIndex = 50
	f.Parent = toastHolder
	corner(f, 10)
	local s = stroke(f, good == false and Color3.fromRGB(255, 90, 90) or GOLD, 1.6)
	s.Transparency = 1
	local l = Instance.new("TextLabel")
	l.Size = UDim2.new(1, -16, 1, 0)
	l.Position = UDim2.fromOffset(8, 0)
	l.BackgroundTransparency = 1
	l.Text = text
	l.TextColor3 = WHITE
	l.TextSize = 13
	l.Font = Enum.Font.GothamBold
	l.TextWrapped = true
	l.TextTransparency = 1
	l.ZIndex = 51
	l.Parent = f
	tween(f, 0.25, { BackgroundTransparency = 0.15 })
	tween(s, 0.25, { Transparency = 0 })
	tween(l, 0.25, { TextTransparency = 0 })
	task.delay(3.4, function()
		if not f.Parent then return end
		tween(f, 0.3, { BackgroundTransparency = 1 })
		tween(s, 0.3, { Transparency = 1 })
		tween(l, 0.3, { TextTransparency = 1 })
		task.delay(0.35, function() f:Destroy() end)
	end)
end

-- progress counter (bottom left)
local counter = Instance.new("TextLabel")
counter.AnchorPoint = Vector2.new(0, 1)
counter.Position = UDim2.new(0, 14, 1, -14)
counter.Size = UDim2.fromOffset(330, 30)
counter.BackgroundColor3 = Color3.fromRGB(14, 10, 8)
counter.BackgroundTransparency = 0.25
counter.TextColor3 = GOLD
counter.TextSize = 13
counter.Font = Enum.Font.GothamBold
counter.ZIndex = 40
counter.Visible = false
counter.Parent = SG
corner(counter, 9)
stroke(counter, GOLD_DARK, 1.2)

--==================================================
-- INTRO SCREEN
--==================================================
local Black = Instance.new("Frame")
Black.Size = UDim2.fromScale(1, 1)
Black.BackgroundColor3 = Color3.new(0, 0, 0)
Black.BorderSizePixel = 0
Black.ZIndex = 100
Black.Parent = SG

local Intro = Instance.new("TextLabel")
Intro.Size = UDim2.new(1, 0, 0, 70)
Intro.Position = UDim2.new(0, 0, 0.5, -35)
Intro.BackgroundTransparency = 1
Intro.Text = "TELEPORTING TO ALPHA EMPIRE CASTLE"
Intro.TextColor3 = WHITE
Intro.Font = Enum.Font.GothamBlack
Intro.TextScaled = true
Intro.ZIndex = 101
Intro.Parent = Black

-- ALPHA EMPIRE BOOT SCREEN ("edit"): pixel logo, typed tasks, systems list, progress, ACCESS GRANTED
local panel = Instance.new("Frame")
panel.AnchorPoint = Vector2.new(0.5, 0)
panel.Position = UDim2.new(0.5, 0, 0, 12)
panel.Size = UDim2.fromOffset(900, 430)
panel.BackgroundColor3 = Color3.fromRGB(8, 4, 4)
panel.BackgroundTransparency = 0.03
panel.ClipsDescendants = true
panel.ZIndex = 200
panel.Visible = false
panel.Parent = SG
local panelScale = Instance.new("UIScale")
panelScale.Scale = scaleFor()
panelScale.Parent = panel
corner(panel, 12)
local panelStroke = stroke(panel, Color3.fromRGB(255, 40, 40), 2.6)
local pg = Instance.new("UIGradient")
pg.Color = ColorSequence.new({
	ColorSequenceKeypoint.new(0, Color3.fromRGB(30, 4, 8)),
	ColorSequenceKeypoint.new(1, Color3.fromRGB(6, 4, 4)),
})
pg.Rotation = 90
pg.Parent = panel

local function pf(x, y, w, h, color, z, parent)
	local f = Instance.new("Frame")
	f.Position = UDim2.fromOffset(x, y)
	f.Size = UDim2.fromOffset(w, h)
	f.BackgroundColor3 = color
	f.BorderSizePixel = 0
	f.ZIndex = z or 201
	f.Parent = parent or panel
	return f
end
local function pt(text, x, y, w, h, size, color, font, align, z)
	local l = Instance.new("TextLabel")
	l.Position = UDim2.fromOffset(x, y)
	l.Size = UDim2.fromOffset(w, h)
	l.BackgroundTransparency = 1
	l.Text = text
	l.TextColor3 = color
	l.TextSize = size
	l.Font = font or Enum.Font.Code
	l.TextXAlignment = align or Enum.TextXAlignment.Left
	l.ZIndex = z or 202
	l.Parent = panel
	return l
end

-- header
local bar = pf(0, 0, 900, 44, Color3.fromRGB(150, 10, 18))
local warnTxt = pt("DANGER  //  ALPHA EMPIRE PROTOCOL", 16, 0, 640, 44, 22, WHITE, Enum.Font.GothamBlack)
local fileTxt = pt("alpha_empire.boot", 690, 0, 196, 44, 12, Color3.fromRGB(255, 200, 200), Enum.Font.Code, Enum.TextXAlignment.Right)
for i = 0, 32 do
	pf(i * 28, 44, 14, 7, GOLD)
end

-- pixel-art logo "ALPHA EMPIRE" (5x5 letters built from frames)
local GLYPH = {
	A = { " ### ", "#   #", "#####", "#   #", "#   #" },
	L = { "#    ", "#    ", "#    ", "#    ", "#####" },
	P = { "#### ", "#   #", "#### ", "#    ", "#    " },
	H = { "#   #", "#   #", "#####", "#   #", "#   #" },
	E = { "#####", "#    ", "#### ", "#    ", "#####" },
	M = { "#   #", "## ##", "# # #", "#   #", "#   #" },
	I = { "#####", "  #  ", "  #  ", "  #  ", "#####" },
	R = { "#### ", "#   #", "#### ", "#  # ", "#   #" },
}
local logoCells = {}
do
	local CELL, GAP = 9, 12
	local text = "ALPHA EMPIRE"
	local totalW = 0
	for i = 1, #text do totalW = totalW + (text:sub(i, i) == " " and 30 or (5 * CELL + GAP)) end
	local x0 = math.floor((900 - totalW) / 2)
	local cx = x0
	local col = 0
	for i = 1, #text do
		local ch = text:sub(i, i)
		if ch == " " then
			cx = cx + 30
		else
			local g = GLYPH[ch]
			for row = 1, 5 do
				for cidx = 1, 5 do
					if g[row]:sub(cidx, cidx) == "#" then
						local cell = pf(cx + (cidx - 1) * CELL, 64 + (row - 1) * CELL, CELL - 1, CELL - 1, Color3.fromRGB(255, 205, 70), 203)
						cell.BackgroundTransparency = 1
						logoCells[#logoCells + 1] = { f = cell, col = col + cidx }
					end
				end
			end
			col = col + 6
			cx = cx + 5 * CELL + GAP
		end
	end
end
pf(150, 118, 600, 2, GOLD, 202)

-- left: tasks typed out
local TASK_LINES = {
	{ "> BOOTING ALPHA EMPIRE CASTLE ............ OK", Color3.fromRGB(140, 255, 160) },
	{ "> MODE    : FREE ROAM  (NO LOCKS, NO KEYS)", Color3.fromRGB(255, 226, 150) },
	{ "> TASK 01: COLLECT COINS, OPEN 6 CHESTS", WHITE },
	{ "> TASK 02: FIND THE 5 HIDDEN SECRET STARS", WHITE },
	{ "> TASK 03: BEAT THE PARKOUR RACE", WHITE },
	{ "> TASK 04: DEFEAT THE SKELETON KING", WHITE },
	{ "> TASK 05: SHOP, EMOTES, WEATHER, SKY MODES", WHITE },
	{ "> WARNING : DANGER ZONE  -  SKIP GOES BACK", Color3.fromRGB(255, 90, 90) },
}
local lineLabels = {}
for i, ln in ipairs(TASK_LINES) do
	local l = pt(ln[1], 24, 132 + (i - 1) * 25, 480, 24, 15, ln[2])
	l.MaxVisibleGraphemes = 0
	lineLabels[i] = l
end

-- right: systems online
local SYSTEMS = { "COIN SHOP", "WARRIOR PATROL", "PARKOUR RACE", "SKELETON KING", "TREASURE MAP", "MINIMAP", "EMOTES + SWORD", "WEATHER", "SKY MODES", "AUTO SAVE" }
pt("SYSTEMS", 530, 128, 330, 20, 13, Color3.fromRGB(255, 226, 150), Enum.Font.GothamBlack)
local sysLabels = {}
for i, name in ipairs(SYSTEMS) do
	local l = pt("", 530, 150 + (i - 1) * 19, 340, 18, 14, WHITE)
	l.RichText = true
	l.Text = '<font color="#46ff8c">[ OK ]</font>  ' .. name
	l.Visible = false
	sysLabels[i] = l
end

-- hex stream + progress
local hexLine = pt("", 24, 392, 852, 18, 11, Color3.fromRGB(140, 60, 60))
local progBack = pf(24, 344, 852, 16, Color3.fromRGB(34, 14, 14), 202)
corner(progBack, 6)
local progFill = pf(0, 0, 0, 16, Color3.fromRGB(255, 60, 50), 203, progBack)
progFill.Size = UDim2.fromScale(0, 1)
corner(progFill, 6)
local progTxt = pt("LOADING CASTLE  0%", 24, 364, 852, 22, 15, Color3.fromRGB(255, 190, 190))
local scan = pf(0, 0, 900, 3, Color3.fromRGB(255, 80, 70), 204)
scan.BackgroundTransparency = 0.55
-- corner brackets
for _, c in ipairs({ { 6, 6 }, { 880, 6 }, { 6, 410 }, { 880, 410 } }) do
	pf(c[1], c[2], 14, 3, GOLD, 205)
	pf(c[1] + (c[1] > 400 and 11 or 0), c[2] + (c[2] > 200 and -11 or 0), 3, 14, GOLD, 205)
end

-- the boot screen starts only after the intro screen is gone, so its 8 seconds are really seen
local function startPanel()
	panel.Visible = true
	task.spawn(function()
		local t0 = os.clock()
		local per = 4.2 / #lineLabels
		local granted = false
		local hexChars = "0123456789ABCDEF"
		while panel.Parent and os.clock() - t0 < 8 do
			local t = os.clock() - t0
			-- logo assembles column by column
			for _, c in ipairs(logoCells) do
				local a = math.clamp((t - c.col * 0.03) / 0.35, 0, 1)
				c.f.BackgroundTransparency = 1 - a
			end
			for i, l in ipairs(lineLabels) do
				local a = math.clamp((t - 0.6 - (i - 1) * per) / per, 0, 1)
				l.MaxVisibleGraphemes = math.floor(#l.Text * a)
			end
			for i, l in ipairs(sysLabels) do
				l.Visible = t > 1.4 + i * 0.42
			end
			local prog = math.clamp(t / 7.2, 0, 1)
			progFill.Size = UDim2.fromScale(prog, 1)
			progTxt.Text = string.format("LOADING CASTLE  %d%%", math.floor(prog * 100))
			local pulse = (math.sin(t * 9) + 1) / 2
			if t < 7 then
				bar.BackgroundColor3 = Color3.fromRGB(110 + math.floor(pulse * 90), 8, 14)
				panelStroke.Color = Color3.fromRGB(255, 30 + math.floor(pulse * 60), 30)
				if math.random() < 0.1 then
					warnTxt.Position = UDim2.fromOffset(16 + math.random(-5, 5), math.random(-2, 2))
				else
					warnTxt.Position = UDim2.fromOffset(16, 0)
				end
			elseif not granted then
				granted = true
				warnTxt.Position = UDim2.fromOffset(16, 0)
				warnTxt.Text = "ACCESS GRANTED  //  WELCOME TO ALPHA EMPIRE"
				bar.BackgroundColor3 = Color3.fromRGB(20, 150, 70)
				panelStroke.Color = Color3.fromRGB(60, 255, 140)
				progFill.BackgroundColor3 = Color3.fromRGB(60, 255, 140)
				progTxt.Text = "LOADING CASTLE  100%   -   READY"
			end
			-- random hex stream
			local s = {}
			for k = 1, 96 do
				local n = math.random(1, 16)
				s[k] = hexChars:sub(n, n)
				if k % 8 == 0 then s[k] = s[k] .. " " end
			end
			hexLine.Text = table.concat(s)
			scan.Position = UDim2.fromOffset(0, (t * 280) % 430)
			task.wait()
		end
	end)
	task.delay(8, function()
		if not panel.Parent then return end
		tween(panel, 0.5, { BackgroundTransparency = 1 })
		for _, d in ipairs(panel:GetDescendants()) do
			if d:IsA("TextLabel") then tween(d, 0.5, { TextTransparency = 1 })
			elseif d:IsA("Frame") then tween(d, 0.5, { BackgroundTransparency = 1 })
			elseif d:IsA("UIStroke") then tween(d, 0.5, { Transparency = 1 }) end
		end
		task.delay(0.6, function() panel:Destroy() end)
	end)
end

local Closed = false

--==================================================
-- FREE ROAM: everything there is to do in the castle
--==================================================
local SkipShow
local markDirty = function() end   -- replaced by the save system
local saveNow, stopExtras, showHud
local SECRETS, CHESTS = {}, {}
local crownColor, capeColor = GOLD, RED
local GALFOLDER, starsVisible = nil, true
local worn = false                     -- true while the royal crown / cape is worn
local royalParts = {}

local function prompt(part, action, object, fn, hold, dist)
	local pr = Instance.new("ProximityPrompt")
	pr.ActionText = action
	pr.ObjectText = object or ""
	pr.HoldDuration = hold or 0.3
	pr.MaxActivationDistance = dist or 12
	pr.RequiresLineOfSight = false
	pr.Parent = part
	bind(pr.Triggered, function() fn(pr) end)
	return pr
end

local function burst(pos, color, n, dist, life)
	for _ = 1, n do
		local p = Instance.new("Part")
		p.Shape = Enum.PartType.Ball
		p.Size = Vector3.new(2, 2, 2)
		p.Color = color
		p.Material = M.Neon
		p.Anchored = true
		p.CanCollide = false
		p.CanQuery = false
		p.CastShadow = false
		p.Position = pos
		p.Parent = HQ
		local dir = Vector3.new(math.random() - 0.5, math.random() - 0.5, math.random() - 0.5)
		if dir.Magnitude < 0.01 then dir = Vector3.new(0, 1, 0) end
		tween(p, life, { Position = pos + dir.Unit * dist * (0.5 + math.random() * 0.5), Size = Vector3.new(0.3, 0.3, 0.3), Transparency = 1 })
		task.delay(life + 0.1, function() p:Destroy() end)
	end
end

local function rcolor()
	return Color3.fromHSV(math.random(), 0.75, 1)
end

local baseWalk = 16
do
	local h = getHum()
	if h then baseWalk = h.WalkSpeed end
end

-- counters --------------------------------------------------------
local coins, TOTAL_COINS = 0, 0
local secretsFound, TOTAL_SECRETS = 0, 5
local function updateCounter()
	counter.Text = string.format("COINS %d/%d     SECRETS %d/%d", coins, TOTAL_COINS, secretsFound, TOTAL_SECRETS)
end

-- speed boost ------------------------------------------------------
local boostToken = 0
local function speedBoost(mult, secs)
	local h = getHum()
	if not h then return end
	boostToken = boostToken + 1
	local mine = boostToken
	h.WalkSpeed = baseWalk * mult
	task.delay(secs, function()
		if boostToken == mine then
			local hh = getHum()
			if hh then hh.WalkSpeed = baseWalk end
		end
	end)
end

--==================================================
-- 1. GOLD COINS (spinning, collect by walking into them)
--==================================================
section("Coins")
local coinList = {}
do
	local function addCoin(x, y, z)
		local p = Instance.new("Part")
		p.Name = "Coin"
		p.Shape = Enum.PartType.Cylinder
		p.Size = Vector3.new(0.6, 4, 4)
		p.Color = GOLD
		p.Material = M.Neon
		p.Anchored = true
		p.CanCollide = false
		p.CanQuery = false
		p.CastShadow = false
		local base = V(x, y, z)
		p.CFrame = CFrame.new(base)
		p.Parent = CUR
		coinList[#coinList + 1] = { part = p, base = base, phase = math.random() * 6, got = false, i = #coinList + 1 }
		TOTAL_COINS = TOTAL_COINS + 1
	end
	for _, gx in ipairs({ -84, -60, 60, 84 }) do
		for _, gz in ipairs({ -100, -80, -60, -36, -12, 12 }) do
			addCoin(gx, 3.6, gz)
		end
	end
	for z = 30, 92, 8 do addCoin(0, 3.6, z) end
	for _, pz in ipairs({ 34, 50, 66, 82 }) do
		addCoin(-16, 3.6, pz)
		addCoin(16, 3.6, pz)
	end
	for _, z in ipairs({ -30, -5, 20, 45, 70 }) do
		addCoin(-107, 34, z)
		addCoin(107, 34, z)
	end
	for _, v in ipairs({ { -30, -150 }, { 30, -150 }, { -70, -170 }, { 70, -170 }, { 0, -170 }, { 0, -195 }, { -96, -196 }, { 96, -196 } }) do
		addCoin(v[1], 3.6, v[2])
	end
	addCoin(-20, 7.6, 96)
	addCoin(20, 7.6, 96)
	addCoin(-58, 3.6, 86)
	addCoin(-66, 3.6, 92)
end

local coinT = 0
local collectAcc = 0
bind(RunService.Heartbeat, function(dt)
	if Closed then return end
	coinT = coinT + dt
	for _, c in ipairs(coinList) do
		if not c.got and c.part.Parent then
			c.part.CFrame = CFrame.new(c.base + Vector3.new(0, math.sin(coinT * 2 + c.phase) * 0.8, 0)) * CFrame.Angles(0, coinT * 3 + c.phase, 0)
		end
	end
	collectAcc = collectAcc + dt
	if collectAcc < 0.05 then return end
	collectAcc = 0
	local r = getRoot()
	if not r then return end
	local pos = r.Position
	for _, c in ipairs(coinList) do
		if not c.got and (pos - c.base).Magnitude < 8 then
			c.got = true
			coins = coins + 1
			updateCounter()
			local part = c.part
			tween(part, 0.35, { Size = Vector3.new(0.6, 9, 9), Transparency = 1 })
			task.delay(0.4, function() part:Destroy() end)
			markDirty()
			if coins % 15 == 0 then
				toast("Coin collector!  " .. coins .. " coins", true)
			end
		end
	end
end)

--==================================================
-- 2. BOUNCE PADS and 3. SPEED PADS
--==================================================
section("Pads")
local pads = {}
do
	for _, v in ipairs({ { -26, -14 }, { 26, -14 }, { -60, -45 }, { 60, -45 }, { -26, -100 }, { 26, -100 } }) do
		local pad = VC("BouncePad", 4, 0.6, v[1], 0.8, v[2], Color3.fromRGB(60, 255, 120), M.Neon, false)
		VC("BouncePadRim", 4.8, 0.5, v[1], 0.6, v[2], GOLD_DARK, M.Metal, false)
		addLight(pad, Color3.fromRGB(60, 255, 120), 16, 1.2)
		pads[#pads + 1] = { kind = "bounce", pos = pad.Position, rad = 4.4 * S, last = 0 }
	end
	for _, z in ipairs({ -96, -66, -36 }) do
		local pad = B("SpeedPad", 10, 0.4, 8, 0, 0.8, z, Color3.fromRGB(40, 200, 255), M.Neon, 0, false)
		local sg = Instance.new("SurfaceGui")
		sg.Face = Enum.NormalId.Top
		sg.CanvasSize = Vector2.new(400, 320)
		sg.LightInfluence = 0
		sg.Parent = pad
		local tl = Instance.new("TextLabel")
		tl.Size = UDim2.fromScale(1, 1)
		tl.BackgroundTransparency = 1
		tl.Text = ">>>"
		tl.TextColor3 = WHITE
		tl.Font = Enum.Font.GothamBlack
		tl.TextScaled = true
		tl.Rotation = -90
		tl.Parent = sg
		addLight(pad, Color3.fromRGB(40, 200, 255), 14, 1)
		pads[#pads + 1] = { kind = "speed", pos = pad.Position, rad = 5 * S, last = 0 }
	end
end
bind(RunService.Heartbeat, function()
	if Closed then return end
	local r = getRoot()
	if not r then return end
	local pos = r.Position
	local now = os.clock()
	for _, p in ipairs(pads) do
		local d = Vector3.new(pos.X - p.pos.X, 0, pos.Z - p.pos.Z).Magnitude
		if d < p.rad and pos.Y - p.pos.Y < 9 and pos.Y - p.pos.Y > -2 and now - p.last > 0.8 then
			p.last = now
			if p.kind == "bounce" then
				r.AssemblyLinearVelocity = Vector3.new(r.AssemblyLinearVelocity.X, 175, r.AssemblyLinearVelocity.Z)
			else
				speedBoost(2.2, 4)
			end
		end
	end
end)

--==================================================
-- 4. MAGIC CARPET: a guided flight around the castle
--==================================================
section("Carpet")
local ride = nil
local stopBtn = Instance.new("TextButton")
stopBtn.AnchorPoint = Vector2.new(0.5, 1)
stopBtn.Position = UDim2.new(0.5, 0, 1, -24)
stopBtn.Size = UDim2.fromOffset(190, 46)
stopBtn.BackgroundColor3 = RED
stopBtn.Text = "STOP RIDE"
stopBtn.TextColor3 = WHITE
stopBtn.Font = Enum.Font.GothamBlack
stopBtn.TextSize = 18
stopBtn.ZIndex = 60
stopBtn.Visible = false
stopBtn.Parent = SG
corner(stopBtn, 12)
stroke(stopBtn, GOLD, 2)

local carpetStart = at(-18, 2.2, -96)
do
	local cp = B("MagicCarpetPad", 9, 0.4, 13, -18, 0.8, -96, RED, M.Fabric, 0, false)
	B("MagicCarpetTrim", 9.6, 0.3, 0.6, -18, 1, -102, GOLD, M.Metal, 0, false)
	B("MagicCarpetTrim", 9.6, 0.3, 0.6, -18, 1, -90, GOLD, M.Metal, 0, false)
	B("MagicCarpetStar", 3, 0.2, 3, -18, 1.1, -96, GOLD, M.Neon, 45, false)
	prompt(cp, "Ride the magic carpet", "Castle flight", function()
		if ride or Closed then return end
		local r = getRoot()
		local h = getHum()
		if not r then return end
		local c = Instance.new("Part")
		c.Name = "FlyingCarpet"
		c.Size = Vector3.new(7, 0.4, 10)
		c.Color = RED
		c.Material = M.Fabric
		c.Anchored = true
		c.CanCollide = false
		c.Parent = HQ
		ride = { t0 = os.clock(), start = r.CFrame, carpet = c, wasSit = false }
		r.Anchored = true
		if h then h.Sit = true end
		stopBtn.Visible = true
		toast("Magic carpet! Jump or press STOP RIDE to land.", true)
	end, 0.5, 14)
end

local function endRide()
	local rd = ride
	if not rd then return end
	ride = nil
	stopBtn.Visible = false
	pcall(function() rd.carpet:Destroy() end)
	local r = getRoot()
	local h = getHum()
	if h then h.Sit = false end
	if r then
		r.Anchored = false
		pcall(function() getChar():PivotTo(rd.start + Vector3.new(0, 3, 0)) end)
		r.AssemblyLinearVelocity = Vector3.zero
	end
end
bind(stopBtn.Activated, endRide)
bind(UIS.JumpRequest, function() if ride then endRide() end end)

bind(RunService.Heartbeat, function()
	if not ride or Closed then return end
	local r = getRoot()
	if not r then ride = nil stopBtn.Visible = false return end
	local t = os.clock() - ride.t0
	local cx, cz = Center.X, Center.Z + 40 * S
	local R, H = 175 * S, 150 * S
	local a0 = math.atan2(ride.start.Position.Z - cz, ride.start.Position.X - cx)
	local function P3(a)
		return Vector3.new(cx + math.cos(a) * R, Center.Y + H + math.sin(a * 3) * 30, cz + math.sin(a) * R)
	end
	local pos, look
	if t < 3 then
		local k = TweenService:GetValue(t / 3, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
		pos = ride.start.Position:Lerp(P3(a0), k)
		look = pos + Vector3.new(-math.sin(a0), 0, math.cos(a0))
	elseif t < 43 then
		local a = a0 + (t - 3) / 40 * math.pi * 2
		pos = P3(a)
		look = pos + Vector3.new(-math.sin(a), -0.1, math.cos(a))
	elseif t < 46 then
		local k = TweenService:GetValue((t - 43) / 3, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
		pos = P3(a0 + math.pi * 2):Lerp(ride.start.Position + Vector3.new(0, 3, 0), k)
		look = pos + Vector3.new(-math.sin(a0), 0, math.cos(a0))
	else
		endRide()
		return
	end
	local cf = CFrame.lookAt(pos, look)
	r.CFrame = cf * CFrame.new(0, 1.6, 0)
	ride.carpet.CFrame = cf * CFrame.new(0, -1.6, 0)
end)

--==================================================
-- 5. THRONE: sit on it
--==================================================
prompt(Seat, "Sit on the throne", "Alpha Empire throne", function()
	local h = getHum()
	local c = getChar()
	if not h or not c then return end
	pcall(function()
		c:PivotTo(CFrame.lookAt(Seat.Position + Vector3.new(0, 0.5 * S + 3, 0), Seat.Position + Vector3.new(0, 3, -20)))
	end)
	h.Sit = true
	toast("You sit on the throne of the ALPHA EMPIRE.", true)
end, 0.4, 16 * S)

--==================================================
-- 6. ROYAL CROWN AND CAPE
--==================================================
section("Crown")
local function removeRoyal()
	for _, p in ipairs(royalParts) do pcall(function() p:Destroy() end) end
	royalParts = {}
	worn = false
end

local function wearRoyal()
	local c = getChar()
	local head = c and c:FindFirstChild("Head")
	local torso = c and (c:FindFirstChild("UpperTorso") or c:FindFirstChild("Torso"))
	if not head or not torso then toast("Your character is not ready", false) return end
	if worn then removeRoyal() toast("Crown and cape removed.", true) return end
	local function piece(size, base, offset, color, mat, shape)
		local p = Instance.new("Part")
		p.Size = size
		p.Color = color
		p.Material = mat
		if shape then p.Shape = shape end
		p.CanCollide = false
		p.Massless = true
		p.CastShadow = false
		p.CFrame = base.CFrame * offset
		p.Parent = c
		local w = Instance.new("WeldConstraint")
		w.Part0 = base
		w.Part1 = p
		w.Parent = p
		royalParts[#royalParts + 1] = p
		return p
	end
	piece(Vector3.new(0.4, 2.2, 2.2), head, CFrame.new(0, 0.75, 0) * CFrame.Angles(0, 0, math.pi / 2), crownColor, M.Metal, Enum.PartType.Cylinder)
	for i = 0, 5 do
		local a = i / 6 * math.pi * 2
		piece(Vector3.new(0.3, 1, 0.3), head, CFrame.new(math.cos(a) * 1, 1.35, math.sin(a) * 1), crownColor, M.Metal)
		piece(Vector3.new(0.35, 0.35, 0.35), head, CFrame.new(math.cos(a) * 1, 1.95, math.sin(a) * 1), i % 2 == 0 and Color3.fromRGB(255, 40, 60) or DIAMOND, M.Neon, Enum.PartType.Ball)
	end
	piece(Vector3.new(2.5, 3.6, 0.15), torso, CFrame.new(0, -0.3, 0.7) * CFrame.Angles(math.rad(8), 0, 0), capeColor, M.Fabric)
	piece(Vector3.new(2.6, 0.25, 0.2), torso, CFrame.new(0, 1.5, 0.65), GOLD, M.Metal)
	worn = true
	burst(head.Position, GOLD, 24, 10, 0.9)
	toast("You wear the ROYAL CROWN and CAPE. Use it again to take it off.", true)
end

do
	B("CrownPedestal", 4, 4, 4, -14, 2.5, 40, STONE_LIGHT, M.Marble)
	B("CrownPedestalTop", 4.6, 0.6, 4.6, -14, 4.8, 40, GOLD, M.Metal)
	local disp = B("CrownDisplay", 2.6, 1.2, 2.6, -14, 6.6, 40, GOLD, M.Metal, 0, false)
	Ball("CrownDisplayGem", 1, -14, 8, 40, Color3.fromRGB(255, 40, 60), M.Neon)
	addLight(disp, Color3.fromRGB(255, 220, 140), 22, 1.6)
	prompt(disp, "Wear royal crown and cape", "Royal crown", wearRoyal, 0.4, 16)
end

--==================================================
-- 7. DRAGON: wake it up and it breathes fire
--==================================================
do
	local busy = false
	prompt(DANGER.yardBox, "Wake the dragon", "Dragon", function()
		if busy then return end
		busy = true
		toast("The dragon roars!", true)
		DANGER.yardFire.Enabled = true
		task.delay(6, function()
			DANGER.yardFire.Enabled = false
			busy = false
		end)
	end, 0.4, 28)
end

--==================================================
-- 8. FIREWORKS
--==================================================
section("Fireworks")
local function fireworks(count, origin)
	task.spawn(function()
		for _ = 1, count do
			if Closed then return end
			local start = origin + Vector3.new(math.random(-20, 20), 0, math.random(-20, 20))
			local rocket = Instance.new("Part")
			rocket.Shape = Enum.PartType.Ball
			rocket.Size = Vector3.new(3, 3, 3)
			rocket.Color = Color3.fromRGB(255, 240, 200)
			rocket.Material = M.Neon
			rocket.Anchored = true
			rocket.CanCollide = false
			rocket.CanQuery = false
			rocket.Position = start
			rocket.Parent = HQ
			addLight(rocket, Color3.fromRGB(255, 220, 160), 24, 2)
			local top = start + Vector3.new(0, math.random(160, 230), 0)
			tween(rocket, 1.2, { Position = top }, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
			task.delay(1.25, function()
				rocket:Destroy()
				burst(top, rcolor(), 46, 90, 1.6)
				burst(top, rcolor(), 30, 55, 1.4)
			end)
			task.wait(0.4)
		end
	end)
end

do
	B("CannonBase", 8, 2, 8, -28, 1.4, -34, STONE_DARK, M.Granite)
	local barrel = VC("CannonBarrel", 1.6, 10, -28, 6, -34, IRON, M.Metal, false)
	barrel.CFrame = at(-28, 5.6, -34) * CFrame.Angles(0, 0, math.rad(75)) 
	B("CannonWheelL", 0.8, 4, 4, -31, 2.4, -34, WOOD_DARK, M.Wood, 0, false)
	B("CannonWheelR", 0.8, 4, 4, -25, 2.4, -34, WOOD_DARK, M.Wood, 0, false)
	local label = B("CannonGold", 5, 0.6, 5, -28, 2.6, -34, GOLD, M.Metal, 0, false)
	prompt(label, "Launch fireworks", "Firework cannon", function()
		toast("Fireworks!", true)
		fireworks(8, V(-28, 8, -34))
	end, 0.4, 16)
end

--==================================================
-- 9. PARTY MODE (disco lights) and 10. ROYAL MUSIC
--==================================================
section("DJ")
local partyOn = false
local partyLights = {}
do
	B("DJTable", 9, 3.4, 4, 30, 2.2, 40, GOLD_DARK, M.Metal)
	B("DJTop", 9.4, 0.4, 4.4, 30, 4.1, 40, BLACK, M.SmoothPlastic)
	for i = -1, 1 do
		VC("DJDeck", 1.3, 0.4, 30 + i * 3, 4.5, 40, Color3.fromRGB(40, 220, 255), M.Neon, false)
	end
	local dj = B("DJPrompt", 2, 2, 2, 30, 6, 40, WHITE, M.SmoothPlastic, 0, false)
	dj.Transparency = 1
	prompt(dj, "Party mode on / off", "DJ stand", function()
		partyOn = not partyOn
		partyLights = {}
		if partyOn then
			for _, d in ipairs(HQ:GetDescendants()) do
				if d:IsA("PointLight") and d.Range >= 28 then
					partyLights[#partyLights + 1] = { light = d, color = d.Color }
				end
			end
			toast("PARTY MODE ON", true)
		else
			toast("Party mode off", true)
		end
	end, 0.4, 16)
	local lastParty = nil
	bind(RunService.Heartbeat, function()
		if Closed then return end
		if partyOn then
			local t = os.clock()
			for i, pl in ipairs(partyLights) do
				if pl.light.Parent then pl.light.Color = Color3.fromHSV((t * 0.35 + i * 0.13) % 1, 0.85, 1) end
			end
			lastParty = partyLights
		elseif lastParty then
			for _, pl in ipairs(lastParty) do
				if pl.light.Parent then pl.light.Color = pl.color end
			end
			lastParty = nil
		end
	end)

	-- jukebox
	B("JukeboxBody", 4, 6, 3, 38, 3.5, 40, WOOD_DARK, M.Wood)
	B("JukeboxGlass", 3, 3, 0.4, 38, 4.4, 38.4, Color3.fromRGB(255, 120, 200), M.Neon, 0, false)
	local jb = B("JukeboxTop", 4.4, 0.8, 3.4, 38, 6.9, 40, GOLD, M.Metal, 0, false)
	prompt(jb, "Music on / off", "Royal jukebox", function()
		local ok = pcall(function() Sound.Playing = not Sound.Playing end)
		toast(Sound.Playing and "Music on" or "Music off", true)
	end, 0.3, 16)
end

--==================================================
-- 11. TELESCOPE: zoom in on the galaxy
--==================================================
section("Telescope")
do
	B("ScopeLegA", 0.5, 5, 0.5, 106, 32.5, 4, IRON, M.Metal, 0, false)
	B("ScopeLegB", 0.5, 5, 0.5, 108.5, 32.5, 2.5, IRON, M.Metal, 0, false)
	B("ScopeLegC", 0.5, 5, 0.5, 108.5, 32.5, 5.5, IRON, M.Metal, 0, false)
	local tube = VC("ScopeTube", 0.9, 7, 107, 36, 4, GOLD, M.Metal, false)
	tube.CFrame = at(107, 36, 4) * CFrame.Angles(math.rad(35), 0, math.rad(90))
	local lens = Ball("ScopeLens", 1.4, 105, 38.8, 4, DIAMOND, M.Glass)
	local busy = false
	prompt(tube, "Look through the telescope", "Telescope", function()
		if busy then return end
		busy = true
		local cam2 = getCam()
		local old = cam2 and cam2.FieldOfView or 70
		if cam2 then tween(cam2, 0.6, { FieldOfView = 14 }) end
		toast("Look up at the galaxy!", true)
		task.delay(7, function()
			local c3 = getCam()
			if c3 then tween(c3, 0.6, { FieldOfView = old }) end
			busy = false
		end)
	end, 0.3, 14)
end

--==================================================
-- 12. WISHING FOUNTAIN
--==================================================
section("Wish")
do
	local wp = B("WishSpot", 6, 2, 3, 0, 3, -35, WHITE, M.SmoothPlastic, 0, false)
	wp.Transparency = 1
	local outcomes = {
		function() toast("Wish granted: SUPER SPEED!", true) speedBoost(2.4, 8) end,
		function()
			toast("Wish granted: MEGA JUMP!", true)
			local r = getRoot()
			if r then r.AssemblyLinearVelocity = Vector3.new(0, 230, 0) end
		end,
		function() coins = coins + 5 updateCounter() toast("Wish granted: +5 coins!", true) end,
		function() toast("Wish granted: FIREWORKS!", true) fireworks(5, V(0, 8, -46)) end,
		function() toast("The fountain whispers: a bookshelf in the hall is not what it seems...", true) end,
	}
	prompt(wp, "Throw a coin and make a wish", "Wishing fountain", function()
		if coins < 1 then toast("You need at least 1 coin.", false) return end
		coins = coins - 1
		updateCounter()
		burst(V(0, 10, -46), DIAMOND, 30, 12, 1)
		outcomes[math.random(1, #outcomes)]()
	end, 0.4, 22)
end

--==================================================
-- 13. SECRETS (5) and 14. TREASURE CHESTS (6, +10 coins each)
--==================================================
section("Secrets")
local function secret(x, y, z, hint)
	local star = B("SecretStar", 2.4, 2.4, 2.4, x, y, z, Color3.fromRGB(190, 120, 255), M.Neon, 45, false)
	addLight(star, Color3.fromRGB(190, 120, 255), 18, 1.4)
	local entry = { x = x, y = y, z = z, found = false }
	local t0 = math.random() * 5
	local base = star.CFrame
	bind(RunService.Heartbeat, function()
		if entry.found or not star.Parent then return end
		star.CFrame = base * CFrame.new(0, math.sin(os.clock() * 2 + t0) * 0.6, 0) * CFrame.Angles(0, os.clock() * 2, 0)
	end)
	local pr
	local function take(silent)
		if entry.found then return end
		entry.found = true
		if pr then pr:Destroy() end
		secretsFound = secretsFound + 1
		updateCounter()
		if not silent then
			burst(star.Position, Color3.fromRGB(190, 120, 255), 30, 14, 1)
			toast("SECRET FOUND  (" .. secretsFound .. "/" .. TOTAL_SECRETS .. ")   " .. hint, true)
			if secretsFound == TOTAL_SECRETS then
				toast("ALL SECRETS FOUND! You are an Alpha Empire legend.", true)
				fireworks(10, V(0, 8, 40))
			end
		end
		star:Destroy()
		markDirty()
	end
	pr = prompt(star, "Touch the secret", "Secret star", function() take(false) end, 0.5, 12)
	entry.take = take
	SECRETS[#SECRETS + 1] = entry
end

secret(57, 6, 44, "Behind the cold torch.")
secret(-110, 50.5, 106, "On top of the north-west tower.")
secret(112, 4, -198, "Behind the village.")
secret(-107, 34.5, 66, "High on the west wall.")
secret(-58, 4, 100, "Behind the royal bookshelf.")

-- the cold torch that opens the secret room
do
	local cup = torch(39.4, 9, 30, false)
	local leverOpened = false
	prompt(cup, "Pull the cold torch", "Torch", function(pr)
		if leverOpened then return end
		leverOpened = true
		pr:Destroy()
		toast("A hidden door grinds open...", true)
		tween(secretDoor, 1.6, { CFrame = secretDoor.CFrame * CFrame.new(0, 13 * S, 0) })
		for _, b in ipairs(secretBooks) do
			tween(b, 1.6, { CFrame = b.CFrame * CFrame.new(0, 13 * S, 0) })
		end
	end, 0.6, 14)
end

local function chest(x, y, z, ry)
	local base = B("ChestBase", 3.4, 1.8, 2.4, x, y + 0.9, z, WOOD, M.WoodPlanks, ry)
	local lid = B("ChestLid", 3.4, 0.9, 2.4, x, y + 2.2, z, WOOD_DARK, M.WoodPlanks, ry, false)
	B("ChestBandA", 0.5, 2.8, 2.6, x, y + 1.3, z, GOLD, M.Metal, ry, false)
	local lock = B("ChestLock", 0.8, 0.9, 0.5, x, y + 1.9, z, GOLD, M.Metal, ry, false)
	lock.CFrame = base.CFrame * CFrame.new(0, 0.8 * S, -1.3 * S)
	local entry = { x = x, y = y, z = z, found = false }
	local lidBase = lid.CFrame
	TOTAL_COINS = TOTAL_COINS + 10
	local pr
	local function take(silent)
		if entry.found then return end
		entry.found = true
		if pr then pr:Destroy() end
		local openCF = lidBase * CFrame.new(0, 0.6 * S, 1 * S) * CFrame.Angles(math.rad(-70), 0, 0)
		if silent then
			lid.CFrame = openCF
			return
		end
		tween(lid, 0.5, { CFrame = openCF })
		local gemPart = Ball("ChestGem", 1.1, x, y + 2.4, z, DIAMOND, M.Neon)
		addLight(gemPart, DIAMOND, 12, 1.5)
		burst(gemPart.Position, GOLD, 24, 12, 1)
		coins = coins + 10
		updateCounter()
		toast("Treasure chest!  +10 coins", true)
		markDirty()
	end
	pr = prompt(base, "Open chest", "Treasure", function() take(false) end, 0.5, 14)
	entry.take = take
	CHESTS[#CHESTS + 1] = entry
end
chest(96, 0.3, 94, 200)
chest(76, 0.3, 70, 90)
chest(-107, 30.4, 10, 90)
chest(107, 30.4, -70, 270)
chest(55, 0.9, 38.5, 0)
chest(94, 0.3, -96, 150)

--==================================================
-- EXTRAS PACK: menu, shop, patrol, parkour, boss, maps, emotes, weather, sky, save
--==================================================
local X = { menuItems = {}, modals = {} }   -- shared table keeps the number of locals low

-- generic UI helpers ---------------------------------------------
local function mkButton(parent, text, w, h)
	local b = Instance.new("TextButton")
	b.Size = UDim2.fromOffset(w, h)
	b.BackgroundColor3 = Color3.fromRGB(14, 10, 8)
	b.BackgroundTransparency = 0.1
	b.Text = text
	b.TextColor3 = GOLD
	b.Font = Enum.Font.GothamBold
	b.TextSize = 12
	b.ZIndex = 45
	b.AutoButtonColor = true
	b.Parent = parent
	corner(b, 9)
	stroke(b, GOLD_DARK, 1.3)
	return b
end

local function closeModals()
	for _, m in ipairs(X.modals) do m.Visible = false end
end

local function makeModal(titleText, w, h)
	local f = Instance.new("Frame")
	f.AnchorPoint = Vector2.new(0.5, 0.5)
	f.Position = UDim2.fromScale(0.5, 0.5)
	f.Size = UDim2.fromOffset(w, h)
	f.BackgroundColor3 = Color3.fromRGB(12, 10, 8)
	f.BackgroundTransparency = 0.04
	f.ZIndex = 70
	f.Visible = false
	f.Parent = SG
	corner(f, 14)
	stroke(f, GOLD, 2)
	local us = Instance.new("UIScale")
	local cam0 = getCam()
	local vy = cam0 and cam0.ViewportSize.Y or 720
	us.Scale = math.clamp((vy - 30) / h, 0.5, 1)
	us.Parent = f
	local t = Instance.new("TextLabel")
	t.Size = UDim2.new(1, -60, 0, 38)
	t.Position = UDim2.fromOffset(16, 0)
	t.BackgroundTransparency = 1
	t.Text = titleText
	t.TextColor3 = GOLD
	t.Font = Enum.Font.GothamBlack
	t.TextSize = 18
	t.TextXAlignment = Enum.TextXAlignment.Left
	t.ZIndex = 71
	t.Parent = f
	local x = Instance.new("TextButton")
	x.Size = UDim2.fromOffset(32, 28)
	x.Position = UDim2.new(1, -42, 0, 6)
	x.BackgroundColor3 = Color3.fromRGB(60, 16, 22)
	x.Text = "X"
	x.TextColor3 = WHITE
	x.Font = Enum.Font.GothamBold
	x.TextSize = 14
	x.ZIndex = 72
	x.Parent = f
	corner(x, 8)
	bind(x.Activated, function() f.Visible = false end)
	X.modals[#X.modals + 1] = f
	return f
end

local function toggleModal(f)
	local v = not f.Visible
	closeModals()
	f.Visible = v
end

-- left-side MENU --------------------------------------------------
local menuBtn = mkButton(SG, "MENU", 100, 32)
menuBtn.Position = UDim2.new(0, 14, 0, 264)
menuBtn.Visible = false
local menuList = Instance.new("ScrollingFrame")
menuList.Position = UDim2.new(0, 14, 0, 302)
menuList.Size = UDim2.fromOffset(116, 190)
menuList.BackgroundTransparency = 1
menuList.BorderSizePixel = 0
menuList.ScrollBarThickness = 3
menuList.AutomaticCanvasSize = Enum.AutomaticSize.Y
menuList.CanvasSize = UDim2.fromOffset(0, 0)
menuList.Visible = false
menuList.ZIndex = 45
menuList.Parent = SG
local ml = Instance.new("UIListLayout")
ml.Padding = UDim.new(0, 5)
ml.Parent = menuList
bind(menuBtn.Activated, function() menuList.Visible = not menuList.Visible end)

local function addMenu(text, fn)
	local b = mkButton(menuList, text, 108, 32)
	bind(b.Activated, function() fn(b) end)
	return b
end

-- the shared "coin purse" helpers ---------------------------------
local owned = { crown_gold = true, cape_red = true }
local crownId, capeId = "gold", "red"
local PK = { running = false, t0 = 0, best = nil, done = false }
local BOSS = { kills = 0 }

--==================================================
-- 1. COIN SHOP
--==================================================
do
	local crownOpts = {
		{ id = "gold", name = "Gold crown", color = GOLD, price = 0 },
		{ id = "diamond", name = "Diamond crown", color = DIAMOND, price = 10 },
		{ id = "ruby", name = "Ruby crown", color = Color3.fromRGB(225, 30, 60), price = 10 },
		{ id = "emerald", name = "Emerald crown", color = Color3.fromRGB(40, 220, 110), price = 15 },
		{ id = "void", name = "Void crown", color = Color3.fromRGB(130, 60, 230), price = 25 },
	}
	local capeOpts = {
		{ id = "red", name = "Royal red cape", color = RED, price = 0 },
		{ id = "blue", name = "Royal blue cape", color = Color3.fromRGB(40, 90, 230), price = 8 },
		{ id = "purple", name = "Purple cape", color = Color3.fromRGB(140, 50, 220), price = 8 },
		{ id = "black", name = "Black cape", color = Color3.fromRGB(24, 24, 30), price = 12 },
		{ id = "gold", name = "Golden cape", color = GOLD, price = 20 },
	}
	X.crownOpts, X.capeOpts = crownOpts, capeOpts

	local shop = makeModal("ROYAL SHOP", 400, 440)
	local purse = Instance.new("TextLabel")
	purse.Size = UDim2.new(1, -32, 0, 22)
	purse.Position = UDim2.fromOffset(16, 40)
	purse.BackgroundTransparency = 1
	purse.TextColor3 = WHITE
	purse.Font = Enum.Font.GothamBold
	purse.TextSize = 14
	purse.TextXAlignment = Enum.TextXAlignment.Left
	purse.ZIndex = 71
	purse.Parent = shop
	local list = Instance.new("ScrollingFrame")
	list.Position = UDim2.fromOffset(12, 68)
	list.Size = UDim2.new(1, -24, 1, -80)
	list.BackgroundTransparency = 1
	list.BorderSizePixel = 0
	list.ScrollBarThickness = 4
	list.AutomaticCanvasSize = Enum.AutomaticSize.Y
	list.CanvasSize = UDim2.fromOffset(0, 0)
	list.ZIndex = 71
	list.Parent = shop
	local ll = Instance.new("UIListLayout")
	ll.Padding = UDim.new(0, 6)
	ll.SortOrder = Enum.SortOrder.LayoutOrder
	ll.Parent = list

	local function equipCrown(opt)
		crownColor = opt.color
		crownId = opt.id
		if worn then removeRoyal() wearRoyal() end
	end
	local function equipCape(opt)
		capeColor = opt.color
		capeId = opt.id
		if worn then removeRoyal() wearRoyal() end
	end
	X.equipCrown, X.equipCape = equipCrown, equipCape

	local order = 0
	local refresh
	local function head(text)
		order = order + 1
		local l = Instance.new("TextLabel")
		l.LayoutOrder = order
		l.Size = UDim2.new(1, -8, 0, 22)
		l.BackgroundTransparency = 1
		l.Text = text
		l.TextColor3 = Color3.fromRGB(255, 226, 150)
		l.Font = Enum.Font.GothamBlack
		l.TextSize = 13
		l.TextXAlignment = Enum.TextXAlignment.Left
		l.ZIndex = 72
		l.Parent = list
	end
	local function row(name, color, btnText, enabled, fn)
		order = order + 1
		local f = Instance.new("Frame")
		f.LayoutOrder = order
		f.Size = UDim2.new(1, -8, 0, 40)
		f.BackgroundColor3 = Color3.fromRGB(24, 18, 12)
		f.BorderSizePixel = 0
		f.ZIndex = 72
		f.Parent = list
		corner(f, 9)
		local sw = Instance.new("Frame")
		sw.Size = UDim2.fromOffset(18, 18)
		sw.Position = UDim2.fromOffset(10, 11)
		sw.BackgroundColor3 = color or GOLD
		sw.BorderSizePixel = 0
		sw.ZIndex = 73
		sw.Parent = f
		corner(sw, 9)
		local n = Instance.new("TextLabel")
		n.Size = UDim2.new(1, -150, 1, 0)
		n.Position = UDim2.fromOffset(38, 0)
		n.BackgroundTransparency = 1
		n.Text = name
		n.TextColor3 = WHITE
		n.Font = Enum.Font.GothamBold
		n.TextSize = 13
		n.TextXAlignment = Enum.TextXAlignment.Left
		n.ZIndex = 73
		n.Parent = f
		local b = Instance.new("TextButton")
		b.Size = UDim2.fromOffset(96, 28)
		b.Position = UDim2.new(1, -106, 0, 6)
		b.BackgroundColor3 = enabled and Color3.fromRGB(150, 12, 20) or Color3.fromRGB(40, 40, 44)
		b.Text = btnText
		b.TextColor3 = WHITE
		b.Font = Enum.Font.GothamBold
		b.TextSize = 12
		b.ZIndex = 73
		b.Parent = f
		corner(b, 8)
		bind(b.Activated, function() fn() end)
	end

	local function buy(price, what)
		if coins < price then
			toast("Not enough coins for " .. what .. " (need " .. price .. ").", false)
			return false
		end
		coins = coins - price
		updateCounter()
		markDirty()
		return true
	end

	refresh = function()
		for _, c in ipairs(list:GetChildren()) do
			if c:IsA("Frame") or c:IsA("TextLabel") then c:Destroy() end
		end
		order = 0
		purse.Text = "Your coins: " .. coins
		head("CROWNS")
		for _, o in ipairs(crownOpts) do
			local key = "crown_" .. o.id
			if owned[key] then
				local eq = (crownId == o.id)
				row(o.name, o.color, eq and "EQUIPPED" or "EQUIP", not eq, function() equipCrown(o) refresh() markDirty() end)
			else
				row(o.name, o.color, "BUY  " .. o.price, true, function()
					if buy(o.price, o.name) then owned[key] = true equipCrown(o) toast(o.name .. " bought and equipped.", true) refresh() end
				end)
			end
		end
		head("CAPES")
		for _, o in ipairs(capeOpts) do
			local key = "cape_" .. o.id
			if owned[key] then
				local eq = (capeId == o.id)
				row(o.name, o.color, eq and "EQUIPPED" or "EQUIP", not eq, function() equipCape(o) refresh() markDirty() end)
			else
				row(o.name, o.color, "BUY  " .. o.price, true, function()
					if buy(o.price, o.name) then owned[key] = true equipCape(o) toast(o.name .. " bought and equipped.", true) refresh() end
				end)
			end
		end
		head("BOOSTS")
		row("Speed boost (30 sec)", Color3.fromRGB(40, 200, 255), "BUY  5", true, function()
			if buy(5, "speed boost") then speedBoost(2.4, 30) toast("Speed boost for 30 seconds!", true) refresh() end
		end)
		row("Mega jump", Color3.fromRGB(60, 255, 120), "BUY  3", true, function()
			if buy(3, "mega jump") then
				local r = getRoot()
				if r then r.AssemblyLinearVelocity = Vector3.new(0, 260, 0) end
				refresh()
			end
		end)
		row("Fireworks show", Color3.fromRGB(255, 120, 200), "BUY  4", true, function()
			if buy(4, "fireworks") then
				local r = getRoot()
				fireworks(8, (r and r.Position or V(0, 8, 40)) + Vector3.new(0, -2, 0))
				refresh()
			end
		end)
	end
	X.refreshShop = refresh
	refresh()
	X.shop = shop
	addMenu("SHOP", function() refresh() toggleModal(shop) end)
end

--==================================================
-- 2. WARRIOR PATROL (the guards walk and salute you)
--==================================================
do
	local ROT_SALUTE = math.rad(120)
	bind(RunService.Heartbeat, function(dt)
		if Closed then return end
		local r = getRoot()
		local pp = r and r.Position
		for _, g in ipairs(GUARDS) do
			local basePos = g.base.Position
			local cur = g.cur.Position
			local near = false
			local face
			if pp then
				local dv = Vector3.new(pp.X - cur.X, 0, pp.Z - cur.Z)
				if dv.Magnitude < 30 * S and dv.Magnitude > 0.1 then
					near = true
					face = dv.Unit
				end
			end
			local pos
			local bob = 0
			if near then
				pos = cur
			else
				g.clock = g.clock + dt * g.speed
				local s = math.sin(g.clock)
				pos = basePos + g.dir * (s * g.amp * S)
				local sign = (math.cos(g.clock) >= 0) and 1 or -1
				face = g.dir * sign
				bob = math.abs(math.sin(g.clock * 6)) * 0.45 * S
			end
			local target = CFrame.lookAt(Vector3.new(pos.X, basePos.Y + bob, pos.Z), Vector3.new(pos.X, basePos.Y + bob, pos.Z) + face)
			g.cur = g.cur:Lerp(target, math.clamp(dt * 7, 0, 1))
			local cf = g.cur
			local sal = near and g.shoulder
			for _, e in ipairs(g.parts) do
				if sal and e.arm then
					local sh = g.shoulder
					e.part.CFrame = cf * sh * CFrame.Angles(ROT_SALUTE, 0, 0) * sh:Inverse() * e.rel
				else
					e.part.CFrame = cf * e.rel
				end
			end
		end
	end)
end

--==================================================
-- 3. PARKOUR RACE (timer, best time, coin reward)
--==================================================
section("Parkour")
do
	local N = 20
	local sx, sz = -150, -146
	local startPad = B("ParkourStart", 8, 1, 8, sx, 0.5, sz, Color3.fromRGB(60, 255, 120), M.Neon)
	addLight(startPad, Color3.fromRGB(60, 255, 120), 24, 1.5)
	DANGER.sign(sx - 6, 6, sz + 6, 180, "PARKOUR RACE")
	local x, y, z = sx, 0, sz
	for i = 1, N do
		z = z - 5
		y = y + 1.8
		x = sx + math.sin(i * 1.1) * 8
		local sz2 = (i % 4 == 0) and 2.6 or 3.4
		local part = B("ParkourPlat", sz2, 0.6, sz2, x, y, z, Color3.fromHSV((i / N) * 0.8, 0.7, 1), M.Neon)
		if i % 5 == 0 then addLight(part, part.Color, 20, 1.2) end
	end
	local fx, fy, fz = x, y + 1.8, z - 8
	local finish = B("ParkourFinish", 14, 1, 14, fx, fy, fz, GOLD, M.Metal)
	B("ParkourFinishGlow", 10, 0.3, 10, fx, fy + 0.6, fz, Color3.fromRGB(255, 240, 160), M.Neon, 0, false)
	for _, o in ipairs({ { -6, -6 }, { 6, -6 }, { -6, 6 }, { 6, 6 } }) do
		B("FinishPost", 0.8, 10, 0.8, fx + o[1], fy + 5.5, fz + o[2], GOLD_DARK, M.Metal)
	end
	Ball("FinishOrb", 3.4, fx, fy + 6, fz, DIAMOND, M.Glass)
	local fl = addLight(finish, Color3.fromRGB(255, 226, 150), 50, 2)
	local finishPos = finish.Position

	local lab = Instance.new("TextLabel")
	lab.AnchorPoint = Vector2.new(0.5, 0)
	lab.Position = UDim2.new(0.5, 0, 0, 68)
	lab.Size = UDim2.fromOffset(300, 34)
	lab.BackgroundColor3 = Color3.fromRGB(12, 10, 8)
	lab.BackgroundTransparency = 0.2
	lab.TextColor3 = Color3.fromRGB(120, 255, 170)
	lab.Font = Enum.Font.GothamBlack
	lab.TextSize = 16
	lab.Visible = false
	lab.ZIndex = 50
	lab.Parent = SG
	corner(lab, 10)
	stroke(lab, Color3.fromRGB(60, 255, 120), 1.4)

	prompt(startPad, "Start the race", "Parkour", function()
		PK.running = true
		PK.t0 = os.clock()
		lab.Visible = true
		toast("GO! Reach the golden platform at the top.", true)
	end, 0.3, 14)
	prompt(finish, "Teleport back to the start", "Finish", function()
		pcall(function() getChar():PivotTo(CFrame.new(startPad.Position + Vector3.new(0, 5, 0))) end)
		PK.running = false
		lab.Visible = false
	end, 0.4, 20)

	bind(RunService.Heartbeat, function()
		if Closed or not PK.running then return end
		local r = getRoot()
		if not r then return end
		local t = os.clock() - PK.t0
		lab.Text = string.format("PARKOUR  %.1fs   BEST  %s", t, PK.best and string.format("%.1fs", PK.best) or "--")
		local p = r.Position
		local topY = finishPos.Y + 0.5 * S
		if math.abs(p.X - finishPos.X) < 7 * S and math.abs(p.Z - finishPos.Z) < 7 * S and p.Y - topY > -3 and p.Y - topY < 14 then
			PK.running = false
			local newBest = (not PK.best) or t < PK.best
			if newBest then PK.best = t end
			if not PK.done then
				PK.done = true
				coins = coins + 30
				updateCounter()
				toast(string.format("PARKOUR COMPLETE in %.1fs!  +30 coins", t), true)
			else
				toast(string.format("Finished in %.1fs  (best %.1fs)", t, PK.best), true)
			end
			fireworks(5, finishPos)
			markDirty()
			task.delay(3, function() lab.Visible = false end)
		end
	end)
end

--==================================================
-- 4. SKELETON KING (boss arena at the far end of the village road)
--==================================================
section("Boss")
do
	local AX, AZ = 0, -255          -- arena centre (castle units)
	local K = 1.6                   -- boss size factor
	local MAXHP = 100
	local bone = Color3.fromRGB(224, 218, 198)
	local dark = Color3.fromRGB(34, 28, 34)

	-- road + arena
	B("BossRoad", 14, 0.2, 52, 0, 0.55, -208, Color3.fromRGB(150, 128, 100), M.Pavement, 0, true)
	VC("BossArena", 44, 1.2, AX, 0.6, AZ, STONE_DARK, M.Slate)
	VC("BossArenaInner", 36, 0.3, AX, 1.3, AZ, Color3.fromRGB(60, 22, 26), M.Slate, false)
	VC("BossArenaGold", 30, 0.3, AX, 1.5, AZ, GOLD_DARK, M.Metal, false)
	VC("BossArenaCore", 28, 0.3, AX, 1.7, AZ, Color3.fromRGB(40, 12, 16), M.Slate, false)
	for i = 0, 7 do
		local a = i / 8 * math.pi * 2
		local bx, bz = AX + math.cos(a) * 38, AZ + math.sin(a) * 38
		VC("ArenaPillar", 2.2, 14, bx, 8, bz, STONE_LIGHT, M.Marble)
		local bowl = B("ArenaBowl", 4, 1, 4, bx, 15.4, bz, GOLD_DARK, M.Metal, 0, false)
		local f = Instance.new("Fire")
		f.Size = 10
		f.Heat = 10
		f.Color = Color3.fromRGB(255, 70, 40)
		f.SecondaryColor = Color3.fromRGB(150, 10, 10)
		f.Parent = bowl
		addLight(bowl, Color3.fromRGB(255, 80, 50), 40, 2)
		if i % 2 == 0 then DANGER.skull(bx, 17.6, bz, 0, 0.8) end
	end
	DANGER.sign(-10, 8, -208, 0, "BOSS ARENA")
	DANGER.sign(10, 8, -208, 0, "KING AHEAD")

	-- the boss rig ---------------------------------------------------
	local c = at(AX, 1.8, AZ, 0)
	local list = {}
	local function bp(name, size, ox, oy, oz, color, mat, shape, grp)
		local p = P(name, size * S * K, c * CFrame.new(Vector3.new(ox, oy, oz) * S * K), color, mat or M.Metal, nil, false)
		if shape then p.Shape = shape end
		list[#list + 1] = { part = p, grp = grp, color = color }
		return p
	end
	-- legs and pelvis
	for _, sx in ipairs({ -1, 1 }) do
		bp("BossLeg", Vector3.new(1.6, 6.2, 1.6), sx * 1.8, 3.1, 0, bone, M.Marble)
		bp("BossKnee", Vector3.new(2.2, 1.6, 2.2), sx * 1.8, 3.4, 0, bone, M.Marble, Enum.PartType.Ball)
		bp("BossFoot", Vector3.new(2.2, 0.9, 3.6), sx * 1.8, 0.45, -0.8, dark, M.Slate)
	end
	bp("BossPelvis", Vector3.new(6, 1.8, 3), 0, 7, 0, bone, M.Marble)
	bp("BossSpine", Vector3.new(1.3, 3.4, 1.3), 0, 9.3, 0.1, bone, M.Marble)
	for i = 0, 4 do
		bp("BossRib", Vector3.new(6.4 - i * 0.2, 0.55, 3), 0, 9.6 + i * 1.05, -0.2, bone, M.Marble)
		bp("BossRibSideL", Vector3.new(0.5, 0.55, 3.2), -3.2 + i * 0.1, 9.6 + i * 1.05, -0.2, bone, M.Marble)
		bp("BossRibSideR", Vector3.new(0.5, 0.55, 3.2), 3.2 - i * 0.1, 9.6 + i * 1.05, -0.2, bone, M.Marble)
	end
	bp("BossHeart", Vector3.new(1.4, 1.4, 1.4), 0, 11.2, -0.6, Color3.fromRGB(255, 40, 50), M.Neon, Enum.PartType.Ball)
	bp("BossShoulder", Vector3.new(9, 1.4, 2), 0, 14.6, 0, dark, M.Metal)
	bp("BossPauldronL", Vector3.new(3, 3, 3), -4.8, 14.8, 0, GOLD, M.Metal, Enum.PartType.Ball)
	-- left arm
	bp("BossArmL", Vector3.new(1.3, 5.6, 1.3), -5, 11.6, 0, bone, M.Marble)
	bp("BossHandL", Vector3.new(1.8, 1.8, 1.8), -5, 8.6, 0, bone, M.Marble, Enum.PartType.Ball)
	-- right arm + great sword (animated as a group)
	bp("BossPauldronR", Vector3.new(3, 3, 3), 4.8, 14.8, 0, GOLD, M.Metal, Enum.PartType.Ball, true)
	bp("BossArmR", Vector3.new(1.3, 5.6, 1.3), 5, 11.6, -0.2, bone, M.Marble, nil, true)
	bp("BossHandR", Vector3.new(1.8, 1.8, 1.8), 5, 8.6, -0.4, bone, M.Marble, Enum.PartType.Ball, true)
	bp("BossSwordHilt", Vector3.new(0.9, 2.6, 0.9), 5, 8.4, -0.4, WOOD_DARK, M.Wood, nil, true)
	bp("BossSwordGuard", Vector3.new(4.6, 0.8, 1), 5, 9.8, -0.4, GOLD, M.Metal, nil, true)
	bp("BossSwordBlade", Vector3.new(1.4, 15, 0.5), 5, 17.6, -0.4, Color3.fromRGB(190, 196, 210), M.Metal, nil, true)
	bp("BossSwordEdge", Vector3.new(0.3, 15, 0.7), 5, 17.6, -0.4, Color3.fromRGB(255, 60, 60), M.Neon, nil, true)
	-- skull, jaw, eyes, crown
	bp("BossSkull", Vector3.new(5, 5, 5), 0, 17.2, 0, bone, M.Marble, Enum.PartType.Ball)
	bp("BossJaw", Vector3.new(3.2, 1.1, 3.4), 0, 14.7, -1, bone, M.Marble)
	for i = -2, 2 do
		bp("BossTooth", Vector3.new(0.4, 0.8, 0.4), i * 0.6, 15.4, -2.5, WHITE, M.SmoothPlastic)
	end
	for _, sx in ipairs({ -1, 1 }) do
		bp("BossEyeSocket", Vector3.new(1.5, 1.7, 1), sx * 1.1, 17.6, -2.2, BLACK, M.SmoothPlastic, Enum.PartType.Ball)
		local eye = bp("BossEye", Vector3.new(0.7, 0.7, 0.5), sx * 1.1, 17.6, -2.6, Color3.fromRGB(255, 30, 30), M.Neon, Enum.PartType.Ball)
		addLight(eye, Color3.fromRGB(255, 40, 40), 36, 2)
	end
	bp("BossCrownRing", Vector3.new(0.9, 4.6, 4.6), 0, 19.8, 0, GOLD, M.Metal, Enum.PartType.Cylinder)
	for i = 0, 6 do
		local a = i / 7 * math.pi * 2
		bp("BossCrownSpike", Vector3.new(0.7, 2.2, 0.7), math.cos(a) * 2.2, 21.2, math.sin(a) * 2.2, GOLD, M.Metal)
	end
	bp("BossCloak", Vector3.new(10, 11, 0.5), 0, 10.6, 2.4, Color3.fromRGB(100, 8, 16), M.Fabric)
	bp("BossCloakTrim", Vector3.new(10.4, 0.6, 0.7), 0, 5.2, 2.4, GOLD, M.Metal)

	-- fix the crown ring orientation (cylinder default is along X)
	for _, e in ipairs(list) do
		e.rel = c:ToObjectSpace(e.part.CFrame)
		if e.part.Name == "BossCrownRing" then
			e.rel = e.rel * CFrame.Angles(0, 0, math.pi / 2)
		end
	end
	local shoulderR = CFrame.new(Vector3.new(5, 14.4, 0) * S * K)

	-- hitbox with the strike prompt
	local hit = P("BossHitbox", Vector3.new(14, 36, 14) * S * K, c * CFrame.new(0, 14 * S * K, 0), WHITE, M.SmoothPlastic, nil, false)
	hit.Transparency = 1
	hit.CanQuery = true
	local strike = Instance.new("ProximityPrompt")
	strike.ActionText = "Strike the Skeleton King"
	strike.ObjectText = "BOSS"
	strike.HoldDuration = 0.05
	strike.MaxActivationDistance = 60 * S
	strike.RequiresLineOfSight = false
	strike.Parent = hit

	-- boss health bar (screen)
	local barFrame = Instance.new("Frame")
	barFrame.AnchorPoint = Vector2.new(0.5, 0)
	barFrame.Position = UDim2.new(0.5, 0, 0, 108)
	barFrame.Size = UDim2.fromOffset(380, 26)
	barFrame.BackgroundColor3 = Color3.fromRGB(20, 8, 10)
	barFrame.Visible = false
	barFrame.ZIndex = 50
	barFrame.Parent = SG
	corner(barFrame, 8)
	stroke(barFrame, Color3.fromRGB(255, 50, 60), 1.8)
	local barFill = Instance.new("Frame")
	barFill.Size = UDim2.fromScale(1, 1)
	barFill.BackgroundColor3 = Color3.fromRGB(220, 24, 36)
	barFill.BorderSizePixel = 0
	barFill.ZIndex = 51
	barFill.Parent = barFrame
	corner(barFill, 8)
	local barText = Instance.new("TextLabel")
	barText.Size = UDim2.fromScale(1, 1)
	barText.BackgroundTransparency = 1
	barText.Text = "SKELETON KING"
	barText.TextColor3 = WHITE
	barText.Font = Enum.Font.GothamBlack
	barText.TextSize = 14
	barText.ZIndex = 52
	barText.Parent = barFrame

	-- red flash when the slam lands
	local flash = Instance.new("Frame")
	flash.Size = UDim2.fromScale(1, 1)
	flash.BackgroundColor3 = Color3.fromRGB(255, 20, 20)
	flash.BackgroundTransparency = 1
	flash.BorderSizePixel = 0
	flash.ZIndex = 90
	flash.Parent = SG

	local st = { hp = MAXHP, dead = false, yaw = c, atkNext = os.clock() + 6, atkStart = nil, lastHit = 0, hover = 0 }
	local function setHP(v)
		st.hp = math.clamp(v, 0, MAXHP)
		barFill.Size = UDim2.fromScale(st.hp / MAXHP, 1)
		barText.Text = "SKELETON KING   " .. math.ceil(st.hp) .. "%"
	end
	setHP(MAXHP)

	local function shake(dur, power)
		task.spawn(function()
			local t0 = os.clock()
			while os.clock() - t0 < dur and not Closed do
				local h = getHum()
				if h then h.CameraOffset = Vector3.new((math.random() - 0.5) * power, (math.random() - 0.5) * power, 0) end
				task.wait()
			end
			local h = getHum()
			if h then h.CameraOffset = Vector3.zero end
		end)
	end

	local function shockwave()
		local ring = Instance.new("Part")
		ring.Shape = Enum.PartType.Cylinder
		ring.Size = Vector3.new(1.5, 4, 4)
		ring.CFrame = CFrame.new(V(AX, 2.2, AZ)) * CFrame.Angles(0, 0, math.pi / 2)
		ring.Color = Color3.fromRGB(255, 40, 40)
		ring.Material = M.Neon
		ring.Transparency = 0.1
		ring.Anchored = true
		ring.CanCollide = false
		ring.CanQuery = false
		ring.Parent = HQ
		tween(ring, 1.0, { Size = Vector3.new(1.5, 100 * S, 100 * S), Transparency = 1 })
		task.delay(1.1, function() ring:Destroy() end)
		local r = getRoot()
		if r then
			local d = Vector3.new(r.Position.X - c.Position.X, 0, r.Position.Z - c.Position.Z).Magnitude
			if d < 55 * S then
				shake(0.5, 2.4)
				flash.BackgroundTransparency = 0.55
				tween(flash, 0.6, { BackgroundTransparency = 1 })
				toast("The Skeleton King slams the ground!", false)
			end
		end
	end

	local function die()
		st.dead = true
		strike.Enabled = false
		BOSS.kills = BOSS.kills + 1
		coins = coins + (BOSS.kills == 1 and 100 or 25)
		updateCounter()
		markDirty()
		toast("SKELETON KING DEFEATED!  +" .. (BOSS.kills == 1 and 100 or 25) .. " coins", true)
		fireworks(8, V(AX, 8, AZ))
		for _, e in ipairs(list) do
			local p = e.part
			local off = Vector3.new((math.random() - 0.5) * 60, math.random() * 30 + 10, (math.random() - 0.5) * 60) * S
			tween(p, 1.6, { CFrame = p.CFrame * CFrame.new(off) * CFrame.Angles(math.random() * 3, math.random() * 3, math.random() * 3), Transparency = 1 })
		end
		burst(c.Position + Vector3.new(0, 20 * S, 0), Color3.fromRGB(255, 200, 80), 60, 80, 1.5)
		task.delay(25, function()
			if Closed then return end
			for _, e in ipairs(list) do e.part.Transparency = 0 end
			st.dead = false
			strike.Enabled = true
			setHP(MAXHP)
			st.atkNext = os.clock() + 6
			toast("The Skeleton King has risen again...", false)
		end)
	end

	bind(strike.Triggered, function()
		if st.dead then return end
		local now = os.clock()
		if now - st.lastHit < 0.2 then return end
		st.lastHit = now
		setHP(st.hp - 5)
		burst(hit.Position + Vector3.new(math.random(-6, 6), math.random(0, 14), math.random(-6, 6)), Color3.fromRGB(255, 70, 70), 10, 18, 0.5)
		for _, e in ipairs(list) do
			if e.part.Name == "BossSkull" or e.part.Name == "BossRib" then
				e.part.Color = WHITE
				task.delay(0.07, function() if e.part.Parent then e.part.Color = e.color end end)
			end
		end
		if st.hp <= 0 then die() end
	end)

	bind(RunService.Heartbeat, function(dt)
		if Closed then return end
		local r = getRoot()
		local pp = r and r.Position
		-- show the bar only while you are near the arena
		local near = false
		if pp then
			local d = Vector3.new(pp.X - c.Position.X, 0, pp.Z - c.Position.Z).Magnitude
			near = d < 110 * S
			if near and not st.dead and os.clock() > st.atkNext and not st.atkStart then
				st.atkStart = os.clock()
			end
		end
		barFrame.Visible = near and not st.dead
		if st.dead then return end
		-- face the player slowly, hover a little
		st.hover = st.hover + dt
		local face = pp and Vector3.new(pp.X - c.Position.X, 0, pp.Z - c.Position.Z) or Vector3.new(0, 0, -1)
		if face.Magnitude < 0.1 then face = Vector3.new(0, 0, -1) end
		local target = CFrame.lookAt(Vector3.new(c.Position.X, c.Position.Y + math.sin(st.hover * 1.6) * 1.2 * S, c.Position.Z), Vector3.new(c.Position.X, c.Position.Y, c.Position.Z) + face)
		st.yaw = st.yaw:Lerp(target, math.clamp(dt * 1.5, 0, 1))
		-- sword attack: raise for 1s, slam, recover
		local ang = 0
		if st.atkStart then
			local t = os.clock() - st.atkStart
			if t < 1.0 then
				ang = -math.rad(150) * (t / 1.0)
			elseif t < 1.2 then
				ang = -math.rad(150) + math.rad(210) * ((t - 1.0) / 0.2)
				if not st.slammed then
					st.slammed = true
					shockwave()
				end
			elseif t < 2.0 then
				ang = math.rad(60) * (1 - (t - 1.2) / 0.8)
			else
				st.atkStart = nil
				st.slammed = false
				st.atkNext = os.clock() + 6 + math.random() * 3
			end
		end
		local cf = st.yaw
		for _, e in ipairs(list) do
			if e.grp then
				e.part.CFrame = cf * shoulderR * CFrame.Angles(ang, 0, 0) * shoulderR:Inverse() * e.rel
			else
				e.part.CFrame = cf * e.rel
			end
		end
		hit.CFrame = cf * CFrame.new(0, 14 * S * K, 0)
	end)
end


--==================================================
-- 5. TREASURE MAP (big) and 6. MINIMAP (always on)
--==================================================
do
	local WX1, WX2, WZ1, WZ2 = -165, 165, -285, 165
	local function toFrac(px, pz)
		local ux = (px - Center.X) / S
		local uz = (pz - Center.Z) / S
		return (ux - WX1) / (WX2 - WX1), 1 - (uz - WZ1) / (WZ2 - WZ1)
	end
	local function unitPos(ux, uz)
		return UDim2.new((ux - WX1) / (WX2 - WX1), 0, 1 - (uz - WZ1) / (WZ2 - WZ1), 0)
	end

	-- builds one map into `parent`; returns an update function
	local function buildMap(parent, big)
		local bg = Instance.new("Frame")
		bg.Size = UDim2.fromScale(1, 1)
		bg.BackgroundColor3 = Color3.fromRGB(26, 46, 28)
		bg.BorderSizePixel = 0
		bg.ClipsDescendants = true
		bg.ZIndex = parent.ZIndex + 1
		bg.Parent = parent
		corner(bg, 10)
		local function rect(x1, z1, x2, z2, color, transp, outline, round)
			local f = Instance.new("Frame")
			local a = unitPos(x1, z2)
			local b = unitPos(x2, z1)
			f.Position = a
			f.Size = UDim2.new(b.X.Scale - a.X.Scale, 0, b.Y.Scale - a.Y.Scale, 0)
			f.BackgroundColor3 = color
			f.BackgroundTransparency = transp
			f.BorderSizePixel = 0
			f.ZIndex = bg.ZIndex + 1
			f.Parent = bg
			if outline then stroke(f, outline, 1.2) end
			if round then corner(f, 100) end
			return f
		end
		rect(-165, -285, 165, 165, Color3.fromRGB(26, 46, 28), 0)
		rect(-136, -136, 136, 136, Color3.fromRGB(190, 70, 20), 0.25)           -- lava moat
		rect(-114, -114, 114, 114, Color3.fromRGB(110, 106, 100), 0)           -- castle walls
		rect(-104, -104, 104, 104, Color3.fromRGB(150, 146, 136), 0)           -- courtyard
		rect(-42, 22, 42, 104, Color3.fromRGB(200, 160, 60), 0, Color3.fromRGB(255, 220, 120))   -- keep
		rect(-76, 68, -42, 104, Color3.fromRGB(150, 60, 60), 0)                -- bedroom
		rect(-7, -136, 7, 22, Color3.fromRGB(176, 150, 112), 0)                -- royal path
		rect(-7, -250, 7, -136, Color3.fromRGB(176, 150, 112), 0.2)            -- outer road
		rect(-60, -200, 60, -145, Color3.fromRGB(96, 76, 60), 0.4)             -- village
		rect(-44, -299, 44, -211, Color3.fromRGB(90, 30, 40), 0, Color3.fromRGB(255, 70, 70), true)  -- boss arena
		rect(-160, -250, -140, -146, Color3.fromRGB(60, 200, 120), 0.35)       -- parkour
		rect(-12, -52, 12, -40, Color3.fromRGB(70, 160, 220), 0, nil, true)    -- fountain
		for _, tw in ipairs({ { -110, -110 }, { 110, -110 }, { 110, 110 }, { -110, 110 } }) do
			rect(tw[1] - 13, tw[2] - 13, tw[1] + 13, tw[2] + 13, Color3.fromRGB(180, 176, 166), 0, nil, true)
		end
		local dsz = big and 6 or 3
		local function dot(ux, uz, color, size)
			local f = Instance.new("Frame")
			f.AnchorPoint = Vector2.new(0.5, 0.5)
			f.Size = UDim2.fromOffset(size or dsz, size or dsz)
			f.Position = unitPos(ux, uz)
			f.BackgroundColor3 = color
			f.BorderSizePixel = 0
			f.ZIndex = bg.ZIndex + 3
			f.Parent = bg
			corner(f, 100)
			return f
		end
		local coinDots, secretMarks, chestMarks = {}, {}, {}
		for _, cn in ipairs(coinList) do
			coinDots[#coinDots + 1] = { dot = dot((cn.base.X - Center.X) / S, (cn.base.Z - Center.Z) / S, GOLD, big and 5 or 3), c = cn }
		end
		if big then
			for _, sc in ipairs(SECRETS) do
				local l = Instance.new("TextLabel")
				l.AnchorPoint = Vector2.new(0.5, 0.5)
				l.Size = UDim2.fromOffset(22, 22)
				l.Position = unitPos(sc.x, sc.z)
				l.BackgroundTransparency = 1
				l.Text = "X"
				l.TextColor3 = Color3.fromRGB(210, 150, 255)
				l.TextStrokeTransparency = 0
				l.Font = Enum.Font.GothamBlack
				l.TextSize = 20
				l.ZIndex = bg.ZIndex + 4
				l.Parent = bg
				secretMarks[#secretMarks + 1] = { l = l, e = sc }
			end
			for _, ch in ipairs(CHESTS) do
				local d = dot(ch.x, ch.z, Color3.fromRGB(150, 90, 40), 8)
				d.ZIndex = bg.ZIndex + 4
				stroke(d, GOLD, 1)
				chestMarks[#chestMarks + 1] = { d = d, e = ch }
			end
		end
		local me = dot(0, 0, WHITE, big and 12 or 7)
		me.ZIndex = bg.ZIndex + 6
		stroke(me, Color3.fromRGB(255, 60, 60), 1.6)
		local nose = dot(0, 0, Color3.fromRGB(255, 60, 60), big and 6 or 4)
		nose.ZIndex = bg.ZIndex + 7
		return function(t)
			local r = getRoot()
			if r then
				local fx, fy = toFrac(r.Position.X, r.Position.Z)
				me.Position = UDim2.fromScale(fx, fy)
				local look = r.CFrame.LookVector
				nose.Position = UDim2.new(fx, look.X * (big and 9 or 5), fy, -look.Z * (big and 9 or 5))
			end
			for _, cd in ipairs(coinDots) do cd.dot.Visible = not cd.c.got end
			for _, sm in ipairs(secretMarks) do
				sm.l.Visible = not sm.e.found
				sm.l.TextTransparency = 0.2 + 0.4 * math.abs(math.sin(t * 3))
			end
			for _, cm in ipairs(chestMarks) do cm.d.Visible = not cm.e.found end
		end
	end

	local mini = Instance.new("Frame")
	mini.Position = UDim2.new(0, 14, 0, 66)
	mini.Size = UDim2.fromOffset(140, 191)
	mini.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
	mini.ZIndex = 44
	mini.Visible = false
	mini.Parent = SG
	corner(mini, 10)
	stroke(mini, GOLD, 1.6)
	local updMini = buildMap(mini, false)
	X.mini = mini

	local bigModal = makeModal("TREASURE MAP   (purple X = secret, brown = chest)", 400, 540)
	local holder = Instance.new("Frame")
	holder.Position = UDim2.fromOffset(15, 44)
	holder.Size = UDim2.fromOffset(370, 480)
	holder.BackgroundTransparency = 1
	holder.ZIndex = 71
	holder.Parent = bigModal
	local updBig = buildMap(holder, true)
	addMenu("MAP", function() toggleModal(bigModal) end)

	local acc = 0
	bind(RunService.Heartbeat, function(dt)
		if Closed then return end
		acc = acc + dt
		if acc < 0.15 then return end
		acc = 0
		local t = os.clock()
		if mini.Visible then updMini(t) end
		if bigModal.Visible then updBig(t) end
	end)
end

--==================================================
-- 7. EMOTES + ROYAL SWORD
--==================================================
section("Emotes")
do
	local emoModal = makeModal("EMOTES", 340, 330)
	local R15 = {
		{ "WAVE", "rbxassetid://507770239" }, { "POINT", "rbxassetid://507770453" },
		{ "DANCE", "rbxassetid://507771019" }, { "DANCE 2", "rbxassetid://507776043" },
		{ "DANCE 3", "rbxassetid://507777268" }, { "LAUGH", "rbxassetid://507770818" },
		{ "CHEER", "rbxassetid://507770677" },
	}
	local R6 = {
		"rbxassetid://128777973", "rbxassetid://128853357", "rbxassetid://182435998", "rbxassetid://182491037",
		"rbxassetid://182491065", "rbxassetid://129423131", "rbxassetid://129423030",
	}
	local track = nil
	local function stopEmote()
		if track then pcall(function() track:Stop(0.2) end) track = nil end
	end
	local function playEmote(index)
		local h = getHum()
		if not h then toast("Your character is not ready", false) return end
		local is15 = h.RigType == Enum.HumanoidRigType.R15
		local id = is15 and R15[index][2] or R6[index]
		local ok, tr = pcall(function()
			local animator = h:FindFirstChildOfClass("Animator")
			if not animator then animator = Instance.new("Animator") animator.Parent = h end
			local a = Instance.new("Animation")
			a.AnimationId = id
			return animator:LoadAnimation(a)
		end)
		if not ok or not tr then toast("This game does not allow that emote.", false) return end
		stopEmote()
		track = tr
		pcall(function() tr.Priority = Enum.AnimationPriority.Action tr:Play(0.2) end)
	end
	for i, e in ipairs(R15) do
		local b = mkButton(emoModal, e[1], 96, 38)
		b.ZIndex = 72
		b.TextSize = 13
		b.Position = UDim2.fromOffset(16 + ((i - 1) % 3) * 106, 52 + math.floor((i - 1) / 3) * 48)
		bind(b.Activated, function() playEmote(i) end)
	end
	local stopB = mkButton(emoModal, "STOP", 96, 38)
	stopB.ZIndex = 72
	stopB.Position = UDim2.fromOffset(16 + 1 * 106, 52 + 2 * 48)
	bind(stopB.Activated, stopEmote)

	-- royal sword as a real Tool (local only)
	local sword = nil
	local function removeSword()
		if sword then pcall(function() sword:Destroy() end) sword = nil end
	end
	local function giveSword()
		if sword then removeSword() toast("Royal sword put away.", true) return end
		local bp2 = Player:FindFirstChildOfClass("Backpack")
		local h = getHum()
		if not bp2 or not h then toast("Tools are not available in this game.", false) return end
		local tool = Instance.new("Tool")
		tool.Name = "Royal Sword"
		tool.CanBeDropped = false
		tool.GripPos = Vector3.new(0, 0, -1.5)
		local handle = Instance.new("Part")
		handle.Name = "Handle"
		handle.Size = Vector3.new(0.5, 0.7, 5.4)
		handle.Color = Color3.fromRGB(205, 212, 226)
		handle.Material = M.Metal
		handle.CanCollide = false
		handle.Parent = tool
		local function extra(size, off, color, mat)
			local p = Instance.new("Part")
			p.Size = size
			p.Color = color
			p.Material = mat
			p.CanCollide = false
			p.Massless = true
			p.CFrame = handle.CFrame * off
			p.Parent = tool
			local w = Instance.new("WeldConstraint")
			w.Part0 = handle
			w.Part1 = p
			w.Parent = p
		end
		extra(Vector3.new(2.4, 0.5, 0.5), CFrame.new(0, 0, 1.4), GOLD, M.Metal)
		extra(Vector3.new(0.5, 0.5, 1.2), CFrame.new(0, 0, 2.4), WOOD_DARK, M.Wood)
		extra(Vector3.new(0.7, 0.7, 0.7), CFrame.new(0, 0, 3.1), GOLD, M.Metal)
		extra(Vector3.new(0.12, 0.2, 4.6), CFrame.new(0, 0, -0.4), Color3.fromRGB(255, 60, 70), M.Neon)
		tool.Parent = bp2
		pcall(function() h:EquipTool(tool) end)
		sword = tool
		bind(tool.Activated, function()
			local v = Instance.new("StringValue")
			v.Name = "toolanim"
			v.Value = "Slash"
			v.Parent = tool
			local hrp = getRoot()
			if hrp then burst(hrp.Position + hrp.CFrame.LookVector * 4, Color3.fromRGB(255, 255, 255), 8, 6, 0.3) end
		end)
		toast("Royal sword equipped. Tap to swing.", true)
	end
	local swB = mkButton(emoModal, "SWORD ON/OFF", 202, 38)
	swB.ZIndex = 72
	swB.Position = UDim2.fromOffset(16, 52 + 3 * 48)
	bind(swB.Activated, giveSword)
	local note = Instance.new("TextLabel")
	note.Position = UDim2.fromOffset(16, 52 + 4 * 48 - 2)
	note.Size = UDim2.new(1, -32, 0, 36)
	note.BackgroundTransparency = 1
	note.Text = "Emotes use Roblox's default animations. Some games block them."
	note.TextColor3 = Color3.fromRGB(190, 180, 160)
	note.Font = Enum.Font.Gotham
	note.TextSize = 11
	note.TextWrapped = true
	note.ZIndex = 72
	note.Parent = emoModal
	addMenu("EMOTES", function() toggleModal(emoModal) end)

	-- walking cancels an emote
	bind(RunService.Heartbeat, function()
		if Closed or not track then return end
		local h = getHum()
		if h and h.MoveDirection.Magnitude > 0.2 then stopEmote() end
	end)
	X.stopEmotes = function() stopEmote() removeSword() end
end


--==================================================
-- 8. WEATHER  and  9. SKY MODES
--==================================================
section("Weather")
do
	local modes = { "CLEAR", "RAIN", "STORM", "FIRE RAIN", "SNOW" }
	local WX = { i = 1, part = nil, emitter = nil, nextBolt = 0 }
	local function clearWeather()
		if WX.part then WX.part:Destroy() WX.part = nil WX.emitter = nil end
	end
	local function makeEmitter()
		local part = Instance.new("Part")
		part.Name = "WeatherEmitter"
		part.Anchored = true
		part.CanCollide = false
		part.CanQuery = false
		part.Transparency = 1
		part.Size = Vector3.new(160, 1, 160)
		part.Parent = HQ
		local pe = Instance.new("ParticleEmitter")
		pe.Parent = part
		WX.part, WX.emitter = part, pe
		return pe
	end
	local function applyMode(i)
		WX.i = i
		clearWeather()
		local m = modes[i]
		if m == "RAIN" or m == "STORM" then
			local pe = makeEmitter()
			pe.Rate = (m == "STORM") and 900 or 500
			pe.Lifetime = NumberRange.new(1.2, 1.4)
			pe.Speed = NumberRange.new(130, 160)
			pe.EmissionDirection = Enum.NormalId.Bottom
			pe.SpreadAngle = Vector2.new(4, 4)
			pe.Size = NumberSequence.new(0.35)
			pe.Squash = NumberSequence.new(-4)
			pe.Orientation = Enum.ParticleOrientation.VelocityParallel
			pe.Color = ColorSequence.new(Color3.fromRGB(170, 200, 255))
			pe.Transparency = NumberSequence.new(0.35)
			pe.LightEmission = 0.4
			pe.Acceleration = Vector3.new(0, -80, 0)
		elseif m == "FIRE RAIN" then
			local pe = makeEmitter()
			pe.Texture = "rbxasset://textures/particles/sparkles_main.dds"
			pe.Rate = 260
			pe.Lifetime = NumberRange.new(2, 2.6)
			pe.Speed = NumberRange.new(50, 70)
			pe.EmissionDirection = Enum.NormalId.Bottom
			pe.SpreadAngle = Vector2.new(8, 8)
			pe.Size = NumberSequence.new(1.6, 0.3)
			pe.Color = ColorSequence.new(Color3.fromRGB(255, 160, 40), Color3.fromRGB(255, 40, 20))
			pe.Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0), NumberSequenceKeypoint.new(1, 1) })
			pe.LightEmission = 1
			pe.Acceleration = Vector3.new(0, -30, 0)
		elseif m == "SNOW" then
			local pe = makeEmitter()
			pe.Texture = "rbxasset://textures/particles/sparkles_main.dds"
			pe.Rate = 320
			pe.Lifetime = NumberRange.new(8, 10)
			pe.Speed = NumberRange.new(8, 14)
			pe.EmissionDirection = Enum.NormalId.Bottom
			pe.SpreadAngle = Vector2.new(35, 35)
			pe.Size = NumberSequence.new(1.1)
			pe.RotSpeed = NumberRange.new(-60, 60)
			pe.Color = ColorSequence.new(Color3.fromRGB(240, 248, 255))
			pe.Transparency = NumberSequence.new(0.1)
			pe.LightEmission = 0.6
			pe.Acceleration = Vector3.new(0, -3, 0)
		end
		WX.nextBolt = os.clock() + 2
		return m
	end

	local weatherBtn
	weatherBtn = addMenu("WEATHER: CLEAR", function(b)
		local i = WX.i % #modes + 1
		local m = applyMode(i)
		b.Text = "WEATHER: " .. m
		toast("Weather: " .. m, true)
	end)

	local function lightning()
		local r = getRoot()
		local origin = (r and r.Position or Center)
		local tx = origin.X + math.random(-250, 250)
		local tz = origin.Z + math.random(-250, 250)
		local top = Vector3.new(tx + math.random(-60, 60), Center.Y + 900, tz + math.random(-60, 60))
		local bottom = Vector3.new(tx, Center.Y + 2, tz)
		local prev = top
		local bolts = {}
		for k = 1, 9 do
			local a = k / 9
			local nextP = top:Lerp(bottom, a) + Vector3.new(math.random(-40, 40), 0, math.random(-40, 40)) * (k == 9 and 0 or 1)
			local seg = Instance.new("Part")
			local len = (nextP - prev).Magnitude
			seg.Size = Vector3.new(3, 3, len)
			seg.CFrame = CFrame.lookAt((prev + nextP) / 2, nextP)
			seg.Color = Color3.fromRGB(230, 235, 255)
			seg.Material = M.Neon
			seg.Anchored = true
			seg.CanCollide = false
			seg.CanQuery = false
			seg.Parent = HQ
			bolts[#bolts + 1] = seg
			prev = nextP
		end
		local light = Instance.new("Part")
		light.Anchored = true
		light.CanCollide = false
		light.Transparency = 1
		light.Size = Vector3.one
		light.Position = bottom + Vector3.new(0, 30, 0)
		light.Parent = HQ
		addLight(light, Color3.fromRGB(220, 230, 255), 160, 6)
		for _, s2 in ipairs(bolts) do tween(s2, 0.35, { Transparency = 1 }) end
		task.delay(0.45, function()
			for _, s2 in ipairs(bolts) do s2:Destroy() end
			light:Destroy()
		end)
		-- brief screen flash
		for _, o in ipairs(lightingMade) do
			if o:IsA("ColorCorrectionEffect") then
				local oldB = o.Brightness
				o.Brightness = 0.5
				tween(o, 0.5, { Brightness = oldB })
			end
		end
	end

	bind(RunService.Heartbeat, function()
		if Closed or not WX.part then return end
		local r = getRoot()
		if r then WX.part.Position = r.Position + Vector3.new(0, 70, 0) end
		if modes[WX.i] == "STORM" and os.clock() > WX.nextBolt then
			WX.nextBolt = os.clock() + math.random(3, 8)
			lightning()
		end
	end)
	X.clearWeather = clearWeather
end

section("SkyModes")
do
	local presets = {
		GALAXY = {
			lighting = { ClockTime = 0, Brightness = 1.6, Ambient = Color3.fromRGB(110, 40, 90), OutdoorAmbient = Color3.fromRGB(140, 60, 170),
				FogColor = Color3.fromRGB(48, 10, 40), FogStart = 1500, FogEnd = 9000, ExposureCompensation = 0.25 },
			bloom = 1.1, tint = Color3.fromRGB(255, 205, 225), sat = 0.45, blank = true, stars = 9000, galaxy = true,
		},
		NIGHT = {
			lighting = { ClockTime = 0, Brightness = 1.2, Ambient = Color3.fromRGB(45, 50, 90), OutdoorAmbient = Color3.fromRGB(60, 70, 120),
				FogColor = Color3.fromRGB(14, 18, 40), FogStart = 1500, FogEnd = 8000, ExposureCompensation = 0.1 },
			bloom = 0.6, tint = Color3.fromRGB(210, 225, 255), sat = 0.15, blank = true, stars = 6000, galaxy = false,
		},
		SUNSET = {
			lighting = { ClockTime = 17.7, Brightness = 2.4, Ambient = Color3.fromRGB(130, 90, 80), OutdoorAmbient = Color3.fromRGB(170, 110, 90),
				FogColor = Color3.fromRGB(230, 130, 90), FogStart = 900, FogEnd = 7000, ExposureCompensation = 0 },
			bloom = 0.5, tint = Color3.fromRGB(255, 225, 200), sat = 0.25, blank = false, stars = 0, galaxy = false,
		},
		DAY = {
			lighting = { ClockTime = 13.5, Brightness = 3, Ambient = Color3.fromRGB(135, 135, 145), OutdoorAmbient = Color3.fromRGB(160, 165, 175),
				FogColor = Color3.fromRGB(190, 210, 235), FogStart = 1500, FogEnd = 9000, ExposureCompensation = 0 },
			bloom = 0.3, tint = Color3.fromRGB(255, 252, 245), sat = 0.1, blank = false, stars = 0, galaxy = false,
		},
	}
	local order = { "GALAXY", "NIGHT", "SUNSET", "DAY" }
	local idx = 1
	local function applySky(name)
		local cfg = presets[name]
		pcall(function()
			-- fresh Sky object (a day sky needs Roblox's default textures back)
			for i, o in ipairs(lightingMade) do
				if o:IsA("Sky") then o:Destroy() table.remove(lightingMade, i) break end
			end
			local sky = Instance.new("Sky")
			sky.Name = "AAYAN_CASTLE_SKY"
			sky.StarCount = cfg.stars
			sky.CelestialBodiesShown = not cfg.blank
			if cfg.blank then
				for _, f in ipairs({ "SkyboxBk", "SkyboxDn", "SkyboxFt", "SkyboxLf", "SkyboxRt", "SkyboxUp" }) do sky[f] = "" end
			end
			sky.Parent = Lighting
			lightingMade[#lightingMade + 1] = sky
			TweenService:Create(Lighting, TweenInfo.new(2.5, Enum.EasingStyle.Sine), cfg.lighting):Play()
			for _, o in ipairs(lightingMade) do
				if o:IsA("BloomEffect") then
					TweenService:Create(o, TweenInfo.new(2.5), { Intensity = cfg.bloom }):Play()
				elseif o:IsA("ColorCorrectionEffect") then
					TweenService:Create(o, TweenInfo.new(2.5), { TintColor = cfg.tint, Saturation = cfg.sat }):Play()
				end
			end
		end)
		starsVisible = cfg.galaxy
		if GALFOLDER then GALFOLDER.Parent = cfg.galaxy and HQ or nil end
	end
	addMenu("SKY: GALAXY", function(b)
		idx = idx % #order + 1
		applySky(order[idx])
		b.Text = "SKY: " .. order[idx]
		toast("Sky mode: " .. order[idx], true)
	end)
end

addMenu("PHOTO MODE", function()
	menuList.Visible = false
	closeModals()
	SG.Enabled = false
	task.delay(6, function() if SG.Parent then SG.Enabled = true end end)
end)

--==================================================
-- 10. SAVE PROGRESS (executors with file access) + HUD glue
--==================================================
do
	local HttpService = game:GetService("HttpService")
	local FILE = "ALPHA_EMPIRE_CASTLE_SAVE.json"
	local canFile = (type(writefile) == "function") and (type(readfile) == "function") and (type(isfile) == "function")
	local dirty = false
	local loadedMsg = nil

	local function collect()
		local got, sec, chs, own = {}, {}, {}, {}
		for _, c in ipairs(coinList) do if c.got then got[#got + 1] = c.i end end
		for i, e in ipairs(SECRETS) do if e.found then sec[#sec + 1] = i end end
		for i, e in ipairs(CHESTS) do if e.found then chs[#chs + 1] = i end end
		for k, v in pairs(owned) do if v then own[#own + 1] = k end end
		return { v = 1, coins = coins, got = got, secrets = sec, chests = chs, best = PK.best, pkdone = PK.done,
			kills = BOSS.kills, crown = crownId, cape = capeId, owned = own }
	end
	local function save()
		if not canFile then return end
		dirty = false
		pcall(function() writefile(FILE, HttpService:JSONEncode(collect())) end)
	end
	local function apply(d)
		for _, i in ipairs(d.got or {}) do
			local c = coinList[i]
			if c and not c.got then c.got = true c.part:Destroy() end
		end
		for _, i in ipairs(d.secrets or {}) do
			local e = SECRETS[i]
			if e then e.take(true) end
		end
		for _, i in ipairs(d.chests or {}) do
			local e = CHESTS[i]
			if e then e.take(true) end
		end
		coins = tonumber(d.coins) or 0
		PK.best = tonumber(d.best)
		PK.done = d.pkdone and true or false
		BOSS.kills = tonumber(d.kills) or 0
		for _, k in ipairs(d.owned or {}) do owned[k] = true end
		for _, o in ipairs(X.crownOpts) do if o.id == d.crown and owned["crown_" .. o.id] then X.equipCrown(o) end end
		for _, o in ipairs(X.capeOpts) do if o.id == d.cape and owned["cape_" .. o.id] then X.equipCape(o) end end
		updateCounter()
		X.refreshShop()
	end

	if canFile then
		local ok, text = pcall(function()
			if isfile(FILE) then return readfile(FILE) end
			return nil
		end)
		if ok and text then
			local ok2, data = pcall(function() return HttpService:JSONDecode(text) end)
			if ok2 and type(data) == "table" then
				local ok3 = pcall(apply, data)
				loadedMsg = ok3 and ("Progress loaded: " .. coins .. " coins, " .. secretsFound .. " secrets.") or "Saved progress could not be read."
			end
		end
		markDirty = function() dirty = true end
		task.spawn(function()
			while not Closed do
				task.wait(3)
				if dirty and not Closed then save() end
			end
		end)
	else
		loadedMsg = "Auto-save is off: this executor has no file access."
	end
	saveNow = function() if canFile then save() end end

	local sure = 0
	addMenu("RESET SAVE", function(b)
		if not canFile then toast("No file access, nothing to reset.", false) return end
		if os.clock() - sure < 4 then
			pcall(function() if type(delfile) == "function" and isfile(FILE) then delfile(FILE) else writefile(FILE, "{}") end end)
			dirty = false
			markDirty = function() end
			toast("Save deleted. Run the script again for a fresh start.", true)
			b.Text = "RESET SAVE"
		else
			sure = os.clock()
			b.Text = "SURE? TAP AGAIN"
			task.delay(4, function() if b.Parent then b.Text = "RESET SAVE" end end)
		end
	end)

	showHud = function()
		menuBtn.Visible = true
		X.mini.Visible = true
		if loadedMsg then toast(loadedMsg, true) end
	end
end

stopExtras = function()
	pcall(function() if X.clearWeather then X.clearWeather() end end)
	pcall(function() if X.stopEmotes then X.stopEmotes() end end)
	pcall(function()
		local h = getHum()
		if h then h.CameraOffset = Vector3.zero end
	end)
end


--==================================================
-- NAME ON THE ROYAL BANNER + EXIT (SKIP) UI
--==================================================
local nameBox = Instance.new("TextBox")
nameBox.AnchorPoint = Vector2.new(1, 0.5)
nameBox.Position = UDim2.new(1, -16, 0.5, -26)
nameBox.Size = UDim2.fromOffset(210, 40)
nameBox.BackgroundColor3 = BLACK
nameBox.BackgroundTransparency = 0.1
nameBox.PlaceholderText = "ENTER YOUR NAME"
nameBox.PlaceholderColor3 = Color3.fromRGB(150, 150, 150)
nameBox.Text = ""
nameBox.TextColor3 = GOLD
nameBox.Font = Enum.Font.GothamBold
nameBox.TextSize = 15
nameBox.ClearTextOnFocus = false
nameBox.ZIndex = 40
nameBox.Visible = false
nameBox.Parent = SG
corner(nameBox, 10)
stroke(nameBox, RED, 2)

local showBtn = Instance.new("TextButton")
showBtn.AnchorPoint = Vector2.new(1, 0.5)
showBtn.Position = UDim2.new(1, -16, 0.5, 24)
showBtn.Size = UDim2.fromOffset(210, 38)
showBtn.BackgroundColor3 = RED
showBtn.Text = "SHOW ON THE ROYAL BANNER"
showBtn.TextColor3 = WHITE
showBtn.Font = Enum.Font.GothamBold
showBtn.TextSize = 12
showBtn.ZIndex = 40
showBtn.Visible = false
showBtn.Parent = SG
corner(showBtn, 10)
stroke(showBtn, GOLD, 2)

-- royal banner (name board on the hall's north wall, above the dais)
local nameBoard = B("NAME_BANNER", 22, 9, 0.5, 0, 17, 101.4, RED, M.Fabric, 0, false)
nameBoard.Transparency = 1
local nbGui = Instance.new("SurfaceGui")
nbGui.Face = Enum.NormalId.Back
nbGui.AlwaysOnTop = false
nbGui.LightInfluence = 0
nbGui.CanvasSize = Vector2.new(1100, 450)
nbGui.Parent = nameBoard
local nbText = Instance.new("TextLabel")
nbText.Size = UDim2.fromScale(0.94, 0.8)
nbText.Position = UDim2.fromScale(0.03, 0.1)
nbText.BackgroundTransparency = 1
nbText.Text = ""
nbText.TextColor3 = GOLD
nbText.TextStrokeColor3 = BLACK
nbText.TextStrokeTransparency = 0
nbText.Font = Enum.Font.GothamBlack
nbText.TextScaled = true
nbText.Parent = nbGui

bind(showBtn.Activated, function()
	local n = nameBox.Text:gsub("^%s+", ""):gsub("%s+$", "")
	if n == "" then return end
	if #n > 24 then n = n:sub(1, 24) end
	nbText.Text = n:upper()
	nameBoard.Transparency = 0
	toast("Your name is on the Royal Banner", true)
end)

-- SKIP button: only appears after the chamber has opened
local skipBtn = Instance.new("TextButton")
skipBtn.AnchorPoint = Vector2.new(0.5, 0)
skipBtn.Position = UDim2.new(0.5, 0, 0, -60)
skipBtn.Size = UDim2.fromOffset(150, 42)
skipBtn.BackgroundColor3 = Color3.fromRGB(20, 14, 6)
skipBtn.Text = "SKIP  >>"
skipBtn.TextColor3 = GOLD
skipBtn.Font = Enum.Font.GothamBlack
skipBtn.TextSize = 18
skipBtn.ZIndex = 60
skipBtn.Visible = false
skipBtn.Parent = SG
corner(skipBtn, 12)
stroke(skipBtn, GOLD, 2.2)

--==================================================
-- EXIT / CLEANUP
--==================================================
Closed = false

local function restoreCamera()
	local c = getCam()
	if not c then return end
	c.CameraType = Enum.CameraType.Custom
	local h = getHum()
	if h then c.CameraSubject = h end
end

local function exitCastle(teleportBack)
	if Closed then return end
	Closed = true
	pcall(function() if saveNow then saveNow() end end)
	pcall(function() if stopExtras then stopExtras() end end)
	for _, c in ipairs(conns) do pcall(function() c:Disconnect() end) end
	conns = {}

	pcall(function()
		if ride then endRide() end
		if worn then removeRoyal() end
		local h = getHum()
		if h then h.WalkSpeed = baseWalk h.Sit = false end
	end)
	if teleportBack then
		local r = getRoot()
		if r then
			pcall(function()
				local c = getChar()
				c:PivotTo(OldCF + Vector3.new(0, 3, 0))
				r.AssemblyLinearVelocity = Vector3.zero
				r.AssemblyAngularVelocity = Vector3.zero
			end)
		end
	end
	restoreCamera()
	pcall(function()
		for k, v in pairs(lightingBackup) do Lighting[k] = v end
		for _, o in ipairs(lightingMade) do o:Destroy() end
	end)
	pcall(function() Sound:Stop() Sound:Destroy() end)
	pcall(function() HQ:Destroy() end)
	pcall(function() SG:Destroy() end)
	if _G.AAYAN_CASTLE_EXIT == exitCastle then _G.AAYAN_CASTLE_EXIT = nil end
end
_G.AAYAN_CASTLE_EXIT = exitCastle

SkipShow = function()
	skipBtn.Visible = true
	tween(skipBtn, 0.5, { Position = UDim2.new(0.5, 0, 0, 16) }, Enum.EasingStyle.Back)
end

bind(skipBtn.Activated, function() exitCastle(true) end)

--==================================================
--==================================================
-- GALAXY MODE: switched on the moment you arrive at the castle
--==================================================
local galaxyIsOn = false
local galaxyRocks = {}
local function galaxyOn()
	if galaxyIsOn or Closed then return end
	galaxyIsOn = true
	pcall(function()
		TweenService:Create(Lighting, TweenInfo.new(3.5, Enum.EasingStyle.Sine), {
			ClockTime = 0,
			Brightness = 1.6,
			Ambient = Color3.fromRGB(110, 40, 90),
			OutdoorAmbient = Color3.fromRGB(140, 60, 170),
			FogColor = Color3.fromRGB(48, 10, 40),
			FogStart = 1500,
			FogEnd = 9000,
			ExposureCompensation = 0.25,
		}):Play()
	end)
	for _, o in ipairs(lightingMade) do
		pcall(function()
			if o:IsA("Sky") then
				o.StarCount = 9000
				o.CelestialBodiesShown = false
				for _, f in ipairs({ "SkyboxBk", "SkyboxDn", "SkyboxFt", "SkyboxLf", "SkyboxRt", "SkyboxUp" }) do o[f] = "" end
			elseif o:IsA("BloomEffect") then
				TweenService:Create(o, TweenInfo.new(3), { Intensity = 1.1, Threshold = 0.9, Size = 40 }):Play()
			elseif o:IsA("ColorCorrectionEffect") then
				TweenService:Create(o, TweenInfo.new(3), { TintColor = Color3.fromRGB(255, 205, 225), Saturation = 0.45, Contrast = 0.15 }):Play()
			end
		end)
	end

	GALFOLDER = section("Galaxy")
	local rnd = Random.new(77)
	local palette = {
		Color3.fromRGB(150, 60, 255), Color3.fromRGB(255, 50, 70), Color3.fromRGB(255, 70, 190),
		Color3.fromRGB(40, 220, 255), Color3.fromRGB(255, 120, 80),
	}
	local function neonBall(size, pos, color, trans)
		local p = Instance.new("Part")
		p.Shape = Enum.PartType.Ball
		p.Size = Vector3.new(size, size, size)
		p.Position = pos
		p.Color = color
		p.Material = M.Neon
		p.Transparency = trans
		p.Anchored = true
		p.CanCollide = false
		p.CanQuery = false
		p.CastShadow = false
		p.Parent = CUR
		return p
	end
	-- nebula clouds far around the castle
	for i = 1, 18 do
		local dir = Vector3.new(rnd:NextNumber(-1, 1), rnd:NextNumber(-0.15, 0.9), rnd:NextNumber(-1, 1)).Unit
		neonBall(rnd:NextNumber(900, 2000), Center + dir * rnd:NextNumber(3200, 4600), palette[i % #palette + 1], rnd:NextNumber(0.82, 0.92))
	end
	-- spiral galaxy overhead (3 arms of glowing stars)
	for arm = 0, 2 do
		for k = 1, 90 do
			local r = 150 + k * 26
			local a = k * 0.12 + arm * (math.pi * 2 / 3)
			local pos = Center + Vector3.new(math.cos(a) * r, 1500 + math.sin(k * 0.4) * 40, math.sin(a) * r)
			neonBall(rnd:NextNumber(8, 26), pos, palette[(k + arm) % #palette + 1], rnd:NextNumber(0, 0.4))
		end
	end
	neonBall(420, Center + Vector3.new(0, 1500, 0), Color3.fromRGB(255, 230, 255), 0.35)
	-- ringed planets
	local planets = {
		{ Vector3.new(-2600, 700, 1500), 520, Color3.fromRGB(190, 80, 255) },
		{ Vector3.new(2800, 1100, -1800), 380, Color3.fromRGB(70, 160, 255) },
		{ Vector3.new(500, 1800, 3200), 640, Color3.fromRGB(255, 120, 90) },
	}
	for _, pl in ipairs(planets) do
		neonBall(pl[2], Center + pl[1], pl[3], 0.1)
		local ring = Instance.new("Part")
		ring.Shape = Enum.PartType.Cylinder
		ring.Size = Vector3.new(6, pl[2] * 1.9, pl[2] * 1.9)
		ring.CFrame = CFrame.new(Center + pl[1]) * CFrame.Angles(0, 0, math.rad(78))
		ring.Color = Color3.fromRGB(255, 232, 190)
		ring.Material = M.Neon
		ring.Transparency = 0.45
		ring.Anchored = true
		ring.CanCollide = false
		ring.CanQuery = false
		ring.Parent = CUR
	end
	-- floating asteroids that slowly orbit the castle
	for i = 1, 56 do
		local p = Instance.new("Part")
		local sz = rnd:NextNumber(8, 34)
		p.Size = Vector3.new(sz, sz * rnd:NextNumber(0.6, 1), sz * rnd:NextNumber(0.7, 1.2))
		p.Color = Color3.fromRGB(70, 66, 82)
		p.Material = M.Slate
		p.Anchored = true
		p.CanCollide = false
		p.CanQuery = false
		p.Parent = CUR
		galaxyRocks[#galaxyRocks + 1] = {
			part = p, r = rnd:NextNumber(500, 1100), a = rnd:NextNumber(0, 6.28),
			y = rnd:NextNumber(150, 700), sp = rnd:NextNumber(0.01, 0.04), spin = rnd:NextNumber(-1, 1),
		}
	end
	bind(RunService.Heartbeat, function(dt)
		for _, g in ipairs(galaxyRocks) do
			if not g.part.Parent then return end
			g.a = g.a + g.sp * dt
			g.part.CFrame = CFrame.new(Center + Vector3.new(math.cos(g.a) * g.r, g.y, math.sin(g.a) * g.r))
				* CFrame.Angles(g.a * g.spin, g.a * 2 * g.spin, 0)
		end
	end)
	-- glitter drifting down over the castle
	local em = Instance.new("Part")
	em.Anchored = true
	em.CanCollide = false
	em.CanQuery = false
	em.Transparency = 1
	em.Size = Vector3.new(700, 2, 700)
	em.Position = Center + Vector3.new(0, 420, 0)
	em.Parent = CUR
	local pe = Instance.new("ParticleEmitter")
	pe.Texture = "rbxasset://textures/particles/sparkles_main.dds"
	pe.Rate = 70
	pe.Lifetime = NumberRange.new(8, 12)
	pe.Speed = NumberRange.new(2, 6)
	pe.SpreadAngle = Vector2.new(180, 180)
	pe.Size = NumberSequence.new(4, 0)
	pe.LightEmission = 1
	pe.Color = ColorSequence.new(Color3.fromRGB(190, 120, 255), Color3.fromRGB(110, 220, 255))
	pe.Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 1), NumberSequenceKeypoint.new(0.2, 0.1), NumberSequenceKeypoint.new(1, 1) })
	pe.EmissionDirection = Enum.NormalId.Bottom
	pe.Parent = em
	-- shooting stars
	task.spawn(function()
		while not Closed do
			task.wait(rnd:NextNumber(1.0, 2.4))
			if Closed then break end
			if starsVisible then
			local start = Center + Vector3.new(rnd:NextNumber(-1600, 1600), rnd:NextNumber(500, 1400), rnd:NextNumber(-1600, 1600))
			local dir = Vector3.new(rnd:NextNumber(-1, 1), rnd:NextNumber(-0.5, -0.1), rnd:NextNumber(-1, 1)).Unit
			local st = Instance.new("Part")
			st.Size = Vector3.new(3, 3, 140)
			st.Color = Color3.fromRGB(220, 240, 255)
			st.Material = M.Neon
			st.Anchored = true
			st.CanCollide = false
			st.CanQuery = false
			st.CFrame = CFrame.lookAt(start, start + dir)
			st.Parent = HQ
			local tw = TweenService:Create(st, TweenInfo.new(1.1, Enum.EasingStyle.Linear), {
				CFrame = CFrame.lookAt(start + dir * 1800, start + dir * 1801), Transparency = 1,
			})
			tw:Play()
			task.delay(1.2, function() st:Destroy() end)
			end
		end
	end)
	-- big "GALAXY MODE" flash
	local gl = Instance.new("TextLabel")
	gl.AnchorPoint = Vector2.new(0.5, 0.5)
	gl.Position = UDim2.fromScale(0.5, 0.3)
	gl.Size = UDim2.fromOffset(640, 70)
	gl.BackgroundTransparency = 1
	gl.Text = "GALAXY MODE ON"
	gl.TextColor3 = Color3.fromRGB(210, 170, 255)
	gl.TextStrokeTransparency = 0
	gl.TextStrokeColor3 = Color3.fromRGB(40, 10, 90)
	gl.Font = Enum.Font.GothamBlack
	gl.TextSize = 54
	gl.TextTransparency = 1
	gl.ZIndex = 120
	gl.Parent = SG
	tween(gl, 0.8, { TextTransparency = 0 })
	task.delay(3, function()
		tween(gl, 0.8, { TextTransparency = 1, TextStrokeTransparency = 1 })
		task.delay(0.9, function() gl:Destroy() end)
	end)
end

-- CINEMATIC ENTRY: orbit the castle, then zoom onto the giant ALPHA EMPIRE flag
local Spawn = at(0, 4.5, -88)

local cam = getCam()
if cam then cam.CameraType = Enum.CameraType.Scriptable end

task.wait(1.0)
tween(Intro, 0.7, { TextTransparency = 1 })
task.wait(0.7)
Black.BackgroundTransparency = 1
Black:Destroy()
startPanel()

local flagCap = Instance.new("TextLabel")
flagCap.AnchorPoint = Vector2.new(0.5, 1)
flagCap.Position = UDim2.new(0.5, 0, 1, -40)
flagCap.Size = UDim2.fromOffset(700, 60)
flagCap.BackgroundTransparency = 1
flagCap.Text = "ALPHA EMPIRE"
flagCap.TextColor3 = GOLD
flagCap.TextStrokeTransparency = 0
flagCap.Font = Enum.Font.GothamBlack
flagCap.TextScaled = true
flagCap.TextTransparency = 1
flagCap.TextStrokeTransparency = 1
flagCap.ZIndex = 120
flagCap.Parent = SG

local lastCamPos = nil
do
	local look = V(0, 40, 20)
	local radius, height = 330 * S / 1.4, 170 * S / 1.4
	local t0, dur = os.clock(), 9
	while os.clock() - t0 < dur and not Closed do
		local a = (os.clock() - t0) / dur * math.pi * 2 + math.pi
		cam = getCam()
		local pos = look + Vector3.new(math.sin(a) * radius, height, math.cos(a) * radius)
		if cam then cam.CFrame = CFrame.lookAt(pos, look) end
		lastCamPos = pos
		RunService.RenderStepped:Wait()
	end

	-- swoop in on the flag and finish there
	local fc = FLAG.center
	local from = lastCamPos or (look + Vector3.new(0, height, -radius))
	local to = fc + Vector3.new(0, -2, -70 * FLAG.FU)
	local t1, dur2 = os.clock(), 3.6
	while os.clock() - t1 < dur2 and not Closed do
		local a = math.clamp((os.clock() - t1) / dur2, 0, 1)
		a = TweenService:GetValue(a, Enum.EasingStyle.Quart, Enum.EasingDirection.InOut)
		cam = getCam()
		if cam then cam.CFrame = CFrame.lookAt(from:Lerp(to, a), look:Lerp(fc, a)) end
		RunService.RenderStepped:Wait()
	end
	tween(flagCap, 0.6, { TextTransparency = 0, TextStrokeTransparency = 0 })
	local t2 = os.clock()
	while os.clock() - t2 < 3.2 and not Closed do
		local k = os.clock() - t2
		cam = getCam()
		-- slow final push-in on the flag
		if cam then cam.CFrame = CFrame.lookAt(to + Vector3.new(0, 0, k * 5), fc) end
		RunService.RenderStepped:Wait()
	end
end

-- fade to black, teleport in
local Fade = Instance.new("Frame")
Fade.Size = UDim2.fromScale(1, 1)
Fade.BackgroundColor3 = Color3.new(0, 0, 0)
Fade.BackgroundTransparency = 1
Fade.BorderSizePixel = 0
Fade.ZIndex = 130
Fade.Parent = SG
tween(Fade, 0.7, { BackgroundTransparency = 0 })
tween(flagCap, 0.5, { TextTransparency = 1, TextStrokeTransparency = 1 })
task.wait(0.8)

--==================================================
-- TELEPORT IN
--==================================================
local function placeInside()
	local c = getChar()
	local r = getRoot()
	if not c or not r then return end
	pcall(function()
		c:PivotTo(CFrame.lookAt(Spawn.Position, Spawn.Position + Vector3.new(0, 0, 10)))
		r.AssemblyLinearVelocity = Vector3.zero
		r.AssemblyAngularVelocity = Vector3.zero
	end)
end

if not Closed then
	placeInside()
	galaxyOn()
	task.wait(0.25)
	restoreCamera()
	cam = getCam()
	tween(Fade, 0.8, { BackgroundTransparency = 1 })
	task.delay(0.9, function() Fade:Destroy() flagCap:Destroy() end)
	counter.Visible = true
	SkipShow()
	if showHud then showHud() end
	nameBox.Visible = true
	showBtn.Visible = true
	updateCounter()
end

-- respawn inside the castle (any game)
bind(Player.CharacterAdded, function()
	task.wait(0.6)
	if Closed then return end
	placeInside()
	restoreCamera()
end)

--==================================================
-- KEEP EVERYONE INSIDE
--==================================================
-- invisible collision box around the island, plus a position guard
section("Barrier")
do
	local function wall(name, sx, sy, sz, x, y, z)
		local p = B(name, sx, sy, sz, x, y, z, WHITE, M.SmoothPlastic)
		p.Transparency = 1
		p.CanQuery = false
		return p
	end
	wall("BarrierN", 340, 400, 4, 0, 150, 168)
	wall("BarrierS", 340, 400, 4, 0, 150, -290)
	wall("BarrierW", 4, 400, 460, -168, 150, -60)
	wall("BarrierE", 4, 400, 460, 168, 150, -60)
	wall("BarrierTop", 340, 4, 460, 0, 350, -60)
end

local guardT = 0
bind(RunService.Heartbeat, function(dt)
	if Closed then return end
	guardT = guardT + dt
	if guardT < 0.25 then return end
	guardT = 0
	local r = getRoot()
	if not r then return end
	local rel = r.Position - Center
	if math.abs(rel.X) > 160 * S or rel.Z > 162 * S or rel.Z < -282 * S or rel.Y < -40 * S or rel.Y > 330 * S then
		placeInside()
		toast("You cannot leave the castle yet.", false)
	end
end)

--==================================================
-- GOLD SHINE ON THE THRONE
--==================================================
local shineParts = {}
for _, d in ipairs(HQ:GetDescendants()) do
	if d:IsA("BasePart") and (d.Name == "ThroneSeatGold" or d.Name == "ThroneBack" or d.Name == "ThroneArmL" or d.Name == "ThroneArmR") then
		shineParts[#shineParts + 1] = d
	end
end
local shineT = 0
bind(RunService.Heartbeat, function(dt)
	shineT = shineT + dt * 0.6
	local c = Color3.fromHSV(0.12 + math.sin(shineT) * 0.012, 0.8, 1)
	for _, p in ipairs(shineParts) do p.Color = c end
end)

print("[CASTLE OF MAXU] loaded. Re-run the script any time to return to your old position.")
