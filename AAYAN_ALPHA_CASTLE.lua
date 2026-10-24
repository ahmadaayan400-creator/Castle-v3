--==================================================
-- AAYAN ALPHA CASTLE
-- One complete LOCAL script (executor / LocalScript). Works in any game.
--
--  * A full stone / gold / diamond castle is built high above the map, locally.
--  * You are teleported inside. You cannot leave until the Royal Chamber opens.
--  * Find 3 hidden keys (gold, diamond, ruby) and 6 treasure chests.
--  * AAYAN_ZZZZ is locked inside the Royal Chamber. Open it with the 3 keys:
--    he walks to the throne and sits. Tap him to wear his avatar.
--  * After the chamber opens a SKIP button appears and takes you back to
--    your old position (your own avatar is restored too).
--
-- HONEST NOTES
--  * Everything is created on YOUR client, so only you see the castle.
--  * Re-running the script safely removes the old castle and returns you.
--  * Wearing the avatar is also local-only; some games block avatar changes,
--    the script then says so instead of pretending.
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
local HQ_HEIGHT = 550

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
for _, n in ipairs({ "AAYAN_ALPHA_HQ", "AAYAN_ALPHA_CASTLE", "AlphaHQMusic" }) do
	local o = workspace:FindFirstChild(n)
	if o then o:Destroy() end
end
for _, n in ipairs({ "AlphaHQInterface", "AAYAN_CASTLE_UI" }) do
	local o = PlayerGui:FindFirstChild(n)
	if o then o:Destroy() end
end

local HQ = Instance.new("Folder")
HQ.Name = "AAYAN_ALPHA_CASTLE"
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

local function at(x, y, z, ry)
	return CFrame.new(Center + Vector3.new(x, y, z)) * CFrame.Angles(0, math.rad(ry or 0), 0)
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
	return P(name, Vector3.new(sx, sy, sz), at(x, y, z, ry), color, mat, nil, collide)
end

-- vertical cylinder (centre y)
local function VC(name, radius, height, x, y, z, color, mat, collide)
	local p = P(name, Vector3.new(height, radius * 2, radius * 2),
		CFrame.new(Center + Vector3.new(x, y, z)) * CFrame.Angles(0, 0, math.pi / 2), color, mat, nil, collide)
	p.Shape = Enum.PartType.Cylinder
	return p
end

local function Ball(name, d, x, y, z, color, mat)
	local p = P(name, Vector3.new(d, d, d), at(x, y, z), color, mat, nil, false)
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
B("GrassIsland", 330, 8, 330, 0, -4, 0, GRASS, M.Grass)
for i, d in ipairs({ { 300, 30 }, { 236, 30 }, { 170, 30 }, { 104, 26 }, { 56, 24 } }) do
	local y = -8 - 15 - (i - 1) * 26
	B("Cliff" .. i, d[1], d[2], d[1], 0, y, 0, Color3.fromRGB(70 + i * 3, 66 + i * 3, 62 + i * 3), M.Slate)
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
for i = 1, 30 do
	B("WallStair", 6, i, 1.5, -103, i / 2, -98 + i * 1.5, STONE_LIGHT, M.Cobblestone)
end
-- stairs up to the east wall walkway
for i = 1, 30 do
	B("WallStair", 6, i, 1.5, 103, i / 2, -98 + i * 1.5, STONE_LIGHT, M.Cobblestone)
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
	t.Size = Vector3.new(2, 17, 2)
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
B("DaisStep1", 46, 1.2, 18, 0, 1.1, 93, STONE_LIGHT, M.Marble)
B("DaisStep2", 38, 1.2, 14, 0, 2.3, 95, STONE_LIGHT, M.Marble)
B("DaisStep3", 30, 1.2, 10, 0, 3.5, 97, STONE_LIGHT, M.Marble)
B("DaisCarpet", 12, 0.2, 18, 0, 4.2, 96, RED, M.Fabric, 0, false)
B("DaisGoldEdge1", 46, 0.3, 0.5, 0, 1.8, 84, GOLD, M.Metal, 0, false)
B("DaisGoldEdge2", 38, 0.3, 0.5, 0, 3.0, 88, GOLD, M.Metal, 0, false)
B("DaisGoldEdge3", 30, 0.3, 0.5, 0, 4.2, 92, GOLD, M.Metal, 0, false)

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
Seat.Size = Vector3.new(6, 1, 5)
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
-- ROYAL CHAMBER (locked room) + SECRET ROOM interior
--==================================================
section("Chamber")
local chamberDoor = B("RoyalChamberDoor", 1.6, 14, 8, -42, 7.5, 82, GOLD_DARK, M.Metal)
local chamberDoorTrim1 = B("DoorBand1", 1.9, 0.8, 8.2, -42, 3, 82, GOLD, M.Metal, 0, false)
local chamberDoorTrim2 = B("DoorBand2", 1.9, 0.8, 8.2, -42, 11, 82, GOLD, M.Metal, 0, false)
local chamberDoorLock = B("DoorLock", 2.2, 2.2, 2.2, -43, 7, 82, DIAMOND, M.Glass, 0, false)
chamberDoorLock.Reflectance = 0.3
-- three key slots
local slotParts = {}
for i, c in ipairs({ GOLD, DIAMOND, Color3.fromRGB(210, 20, 50) }) do
	slotParts[i] = B("KeySlot" .. i, 1.2, 1.2, 1.2, -43.1, 10 + (i - 2) * 1.8, 82, c, M.Neon, 0, false)
	slotParts[i].Transparency = 0.75
end
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
counter.Size = UDim2.fromOffset(250, 30)
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

local keys = { gold = false, diamond = false, ruby = false }
local chestsOpen = 0
local TOTAL_CHESTS = 6
local chamberOpened = false

local function keyCount()
	local n = 0
	for _, v in pairs(keys) do if v then n = n + 1 end end
	return n
end

local function updateCounter()
	counter.Text = string.format("KEYS %d/3    TREASURE %d/%d", keyCount(), chestsOpen, TOTAL_CHESTS)
	for i, name in ipairs({ "gold", "diamond", "ruby" }) do
		if slotParts[i] then slotParts[i].Transparency = keys[name] and 0 or 0.75 end
	end
end

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
Intro.Text = "TELEPORTING TO ALPHA CASTLE"
Intro.TextColor3 = WHITE
Intro.Font = Enum.Font.GothamBlack
Intro.TextScaled = true
Intro.ZIndex = 101
Intro.Parent = Black

-- tasks panel: typed out like an editor, gone after 8 seconds
local panel = Instance.new("Frame")
panel.AnchorPoint = Vector2.new(0.5, 0)
panel.Position = UDim2.new(0.5, 0, 0, 24)
panel.Size = UDim2.fromOffset(560, 262)
panel.BackgroundColor3 = Color3.fromRGB(10, 8, 6)
panel.BackgroundTransparency = 0.08
panel.ZIndex = 200
panel.Parent = SG
local panelScale = Instance.new("UIScale")
panelScale.Scale = scaleFor()
panelScale.Parent = panel
corner(panel, 14)
stroke(panel, GOLD, 2)

local bar = Instance.new("Frame")
bar.Size = UDim2.new(1, 0, 0, 26)
bar.BackgroundColor3 = Color3.fromRGB(30, 20, 8)
bar.BorderSizePixel = 0
bar.ZIndex = 201
bar.Parent = panel
corner(bar, 14)
local barTitle = Instance.new("TextLabel")
barTitle.Size = UDim2.new(1, -20, 1, 0)
barTitle.Position = UDim2.fromOffset(12, 0)
barTitle.BackgroundTransparency = 1
barTitle.Text = "alpha_castle.tasks"
barTitle.TextColor3 = GOLD
barTitle.TextSize = 12
barTitle.Font = Enum.Font.Code
barTitle.TextXAlignment = Enum.TextXAlignment.Left
barTitle.ZIndex = 202
barTitle.Parent = bar

local TASK_TEXT = table.concat({
	"ALPHA CASTLE  -  YOUR TASKS",
	"",
	"1. Search the castle for 3 ROYAL KEYS:",
	"   GOLD  /  DIAMOND  /  RUBY",
	"2. Find the hidden secrets and 6 TREASURE CHESTS.",
	"3. Use all 3 keys on the sealed ROYAL CHAMBER door.",
	"4. Free " .. AVATAR_NAME .. " and watch him take the throne.",
	"5. Tap him to wear his avatar, then press SKIP.",
	"",
	"You cannot leave the castle until the chamber opens.",
}, "\n")

local code = Instance.new("TextLabel")
code.Position = UDim2.fromOffset(16, 36)
code.Size = UDim2.new(1, -32, 1, -46)
code.BackgroundTransparency = 1
code.Text = TASK_TEXT .. "|"
code.MaxVisibleGraphemes = 0
code.TextColor3 = Color3.fromRGB(255, 226, 150)
code.TextSize = 15
code.Font = Enum.Font.Code
code.TextXAlignment = Enum.TextXAlignment.Left
code.TextYAlignment = Enum.TextYAlignment.Top
code.TextWrapped = true
code.ZIndex = 202
code.Parent = panel

task.spawn(function()
	local total = #code.Text
	local t0 = os.clock()
	local dur = 4.2
	while panel.Parent and os.clock() - t0 < dur do
		local a = (os.clock() - t0) / dur
		code.MaxVisibleGraphemes = math.floor(total * a)
		task.wait()
	end
	if not panel.Parent then return end
	code.Text = TASK_TEXT
	code.MaxVisibleGraphemes = -1
end)

task.delay(8, function()
	if not panel.Parent then return end
	local tw = tween(panel, 0.5, { BackgroundTransparency = 1 })
	for _, d in ipairs(panel:GetDescendants()) do
		if d:IsA("TextLabel") then tween(d, 0.5, { TextTransparency = 1, BackgroundTransparency = 1 })
		elseif d:IsA("Frame") then tween(d, 0.5, { BackgroundTransparency = 1 })
		elseif d:IsA("UIStroke") then tween(d, 0.5, { Transparency = 1 }) end
	end
	task.delay(0.6, function() panel:Destroy() end)
end)

--==================================================
-- AVATAR: AAYAN_ZZZZ locked in the Royal Chamber
--==================================================
local avatar, avatarHum, avatarRoot
local avatarUserId
local avatarDesc
local animTracks = {}
local worn = false

local function loadAnim(hum, id)
	local ok, track = pcall(function()
		local animator = hum:FindFirstChildOfClass("Animator")
		if not animator then
			animator = Instance.new("Animator")
			animator.Parent = hum
		end
		local a = Instance.new("Animation")
		a.AnimationId = id
		return animator:LoadAnimation(a)
	end)
	return ok and track or nil
end

local function playOnly(name)
	for n, t in pairs(animTracks) do
		if n == name then
			if not t.IsPlaying then pcall(function() t:Play(0.2) end) end
		else
			pcall(function() t:Stop(0.2) end)
		end
	end
end

local function wearAvatar()
	local hum = getHum()
	if not hum then toast("Your character is not ready", false) return end
	if not avatarDesc then toast("Avatar data is not available", false) return end
	local ok = pcall(function() hum:ApplyDescription(avatarDesc) end)
	task.wait(0.4)
	local match = false
	pcall(function()
		local a = hum:GetAppliedDescription()
		match = (a.Shirt == avatarDesc.Shirt and a.Pants == avatarDesc.Pants and a.HeadColor == avatarDesc.HeadColor)
	end)
	if ok and match then
		worn = true
		toast("You are now wearing " .. AVATAR_NAME .. "'s avatar", true)
	else
		toast("This game did not accept the avatar change", false)
	end
end

local function attachAvatarPrompts()
	if not avatarRoot then return end
	local pr = Instance.new("ProximityPrompt")
	pr.ObjectText = AVATAR_NAME
	pr.ActionText = "Wear this avatar"
	pr.HoldDuration = 0.3
	pr.MaxActivationDistance = 14
	pr.RequiresLineOfSight = false
	pr.Enabled = false
	pr.Name = "WearPrompt"
	pr.Parent = avatarRoot
	local cd = Instance.new("ClickDetector")
	cd.MaxActivationDistance = 40
	cd.Name = "WearClick"
	cd.Parent = avatar:FindFirstChild("Head") or avatarRoot
	bind(pr.Triggered, function() wearAvatar() end)
	bind(cd.MouseClick, function()
		if chamberOpened then wearAvatar() else toast("Open the Royal Chamber first", false) end
	end)
end

task.spawn(function()
	local ok, id = pcall(function() return Players:GetUserIdFromNameAsync(AVATAR_NAME) end)
	if ok and id then avatarUserId = id end
	if avatarUserId then
		pcall(function() avatarDesc = Players:GetHumanoidDescriptionFromUserId(avatarUserId) end)
		pcall(function() avatar = Players:CreateHumanoidModelFromUserId(avatarUserId) end)
	end
	if not avatar then
		-- fallback: neutral figure so the castle still works
		local okd, m = pcall(function()
			return Players:CreateHumanoidModelFromDescription(avatarDesc or Instance.new("HumanoidDescription"), Enum.HumanoidRigType.R15)
		end)
		if okd then avatar = m end
		toast("Could not load " .. AVATAR_NAME .. "'s avatar, using a neutral figure", false)
	end
	if not avatar or not HQ.Parent then return end

	avatar.Name = "AAYAN_ZZZZ_AVATAR"
	avatarHum = avatar:FindFirstChildOfClass("Humanoid")
	avatarRoot = avatar:FindFirstChild("HumanoidRootPart") or avatar.PrimaryPart
	if not avatarHum or not avatarRoot then avatar:Destroy() avatar = nil return end
	avatarHum.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
	avatarRoot.Anchored = true
	avatar.Parent = HQ
	local pos = Center + Vector3.new(-58, 3.6, 86)
	avatar:PivotTo(CFrame.lookAt(pos, pos + Vector3.new(1, 0, 0)))

	-- floating name tag
	local head = avatar:FindFirstChild("Head")
	if head then
		local bb = Instance.new("BillboardGui")
		bb.Size = UDim2.fromOffset(180, 30)
		bb.StudsOffset = Vector3.new(0, 2.6, 0)
		bb.AlwaysOnTop = false
		bb.MaxDistance = 90
		bb.Parent = head
		local t = Instance.new("TextLabel")
		t.Size = UDim2.fromScale(1, 1)
		t.BackgroundTransparency = 1
		t.Text = AVATAR_NAME
		t.TextColor3 = GOLD
		t.TextStrokeTransparency = 0.2
		t.Font = Enum.Font.GothamBlack
		t.TextScaled = true
		t.Parent = bb
	end

	local r15 = avatarHum.RigType == Enum.HumanoidRigType.R15
	if r15 then
		animTracks.idle = loadAnim(avatarHum, "rbxassetid://507766388")
		animTracks.walk = loadAnim(avatarHum, "rbxassetid://507777826")
		animTracks.sit = loadAnim(avatarHum, "rbxassetid://2506281703")
	else
		animTracks.idle = loadAnim(avatarHum, "rbxassetid://180435571")
		animTracks.walk = loadAnim(avatarHum, "rbxassetid://180426354")
		animTracks.sit = loadAnim(avatarHum, "rbxassetid://178130996")
	end
	for _, t in pairs(animTracks) do t.Looped = true end
	playOnly("idle")
	attachAvatarPrompts()
end)

local function avatarToThrone()
	if not avatar or not avatarHum or not avatarRoot then return end
	task.spawn(function()
		avatarRoot.Anchored = false
		pcall(function() avatarRoot:SetNetworkOwner(Player) end)
		avatarHum.WalkSpeed = 14
		local route = {
			Vector3.new(-30, 4, 82), Vector3.new(-6, 4, 84), Vector3.new(0, 5, 90),
		}
		playOnly("walk")
		for _, p in ipairs(route) do
			if not avatar.Parent then return end
			avatarHum:MoveTo(Center + p)
			local t0 = os.clock()
			local done = false
			local c = avatarHum.MoveToFinished:Connect(function() done = true end)
			while not done and os.clock() - t0 < 6 and avatar.Parent do task.wait(0.1) end
			c:Disconnect()
		end
		if not avatar.Parent then return end
		-- take the throne
		avatarRoot.AssemblyLinearVelocity = Vector3.zero
		local okSit = pcall(function() Seat:Sit(avatarHum) end)
		avatarRoot.Anchored = true
		avatar:PivotTo(CFrame.lookAt(Seat.Position + Vector3.new(0, 1.9, 0), Seat.Position + Vector3.new(0, 1.9, -10)))
		playOnly("sit")
		local pr = avatarRoot:FindFirstChild("WearPrompt")
		if pr then pr.Enabled = true end
		toast(AVATAR_NAME .. " takes the throne. Tap him to wear his avatar.", true)
	end)
end

--==================================================
-- PROMPT HELPERS: keys, chests, secrets
--==================================================
local function prompt(part, action, object, fn, hold, dist)
	local pr = Instance.new("ProximityPrompt")
	pr.ActionText = action
	pr.ObjectText = object or ""
	pr.HoldDuration = hold or 0.4
	pr.MaxActivationDistance = dist or 9
	pr.RequiresLineOfSight = false
	pr.Parent = part
	bind(pr.Triggered, function() fn(pr) end)
	return pr
end

local function keyObject(kind, label, color, x, y, z)
	section("Key_" .. kind)
	local handle = B("KeyHandle", 0.8, 0.8, 3, x, y, z, color, M.Neon, 0, false)
	local ring = VC("KeyRing", 1.1, 0.5, x, y, z - 1.8, color, M.Neon, false)
	ring.CFrame = at(x, y, z - 1.8) * CFrame.Angles(math.pi / 2, 0, 0)
	B("KeyTooth", 0.6, 1.2, 0.6, x, y - 0.5, z + 1.2, color, M.Neon, 0, false)
	B("KeyTooth", 0.6, 0.8, 0.6, x, y - 0.4, z + 0.5, color, M.Neon, 0, false)
	addLight(handle, color, 14, 1.5)
	local objs = CUR:GetChildren()
	local pr
	pr = prompt(handle, "Take the key", label, function()
		if keys[kind] then return end
		keys[kind] = true
		for _, o in ipairs(objs) do o:Destroy() end
		toast(label .. " found   (" .. keyCount() .. "/3)", true)
		updateCounter()
	end, 0.6, 10)
	-- slow bob so it is easy to spot
	task.spawn(function()
		local t = 0
		while handle.Parent do
			t = t + 0.05
			for _, o in ipairs(objs) do
				if o:IsA("BasePart") and o.Parent then
					o.CFrame = o.CFrame * CFrame.new(0, math.sin(t) * 0.01, 0)
				end
			end
			task.wait(0.05)
		end
	end)
end

local function chest(x, y, z, ry)
	section("Chest")
	local base = B("ChestBase", 3.4, 1.8, 2.4, x, y + 0.9, z, WOOD, M.WoodPlanks, ry)
	local lid = B("ChestLid", 3.4, 0.9, 2.4, x, y + 2.2, z, WOOD_DARK, M.WoodPlanks, ry, false)
	B("ChestBandA", 0.5, 2.8, 2.6, x, y + 1.3, z, GOLD, M.Metal, ry, false)
	local lock = B("ChestLock", 0.8, 0.9, 0.5, x, y + 1.9, z, GOLD, M.Metal, ry, false)
	lock.CFrame = base.CFrame * CFrame.new(0, 0.8, -1.3)
	local opened = false
	local lidBase = lid.CFrame
	prompt(base, "Open chest", "Treasure", function(pr)
		if opened then return end
		opened = true
		pr:Destroy()
		tween(lid, 0.5, { CFrame = lidBase * CFrame.new(0, 0.6, 1) * CFrame.Angles(math.rad(-70), 0, 0) })
		local gemPart = Ball("ChestGem", 1.1, x, y + 2.4, z, DIAMOND, M.Neon)
		addLight(gemPart, DIAMOND, 12, 1.5)
		chestsOpen = chestsOpen + 1
		updateCounter()
		toast("Treasure found!   (" .. chestsOpen .. "/" .. TOTAL_CHESTS .. ")", true)
	end, 0.5, 9)
end

--==================================================
-- SECRETS: where everything is hidden
--==================================================

-- KEY 1  GOLD: on top of the open north-west tower (stairs -> west wall -> ladder)
keyObject("gold", "GOLD KEY", GOLD, -110, 48.2, 108)

-- KEY 2  DIAMOND: secret room behind the bookshelf (pull the unlit torch)
keyObject("diamond", "DIAMOND KEY", DIAMOND, 57, 4.4, 44)

-- KEY 3  RUBY: inside one of the crates in the courtyard
local rubyCrateIndex = 4
for i, c in ipairs(crates) do
	prompt(c, "Search crate", "Crate", function(pr)
		if i == rubyCrateIndex then
			pr:Destroy()
			if not keys.ruby then
				keys.ruby = true
				toast("RUBY KEY found   (" .. keyCount() .. "/3)", true)
				updateCounter()
			end
		else
			pr:Destroy()
			toast("Only dust and straw in this crate.", true)
		end
	end, 0.5, 8)
end

-- secret door lever: the one torch that is NOT burning (hall, east wall)
do
	section("Lever")
	local cup = torch(39.4, 9, 30, false)
	local leverOpened = false
	prompt(cup, "Pull the cold torch", "Torch", function(pr)
		if leverOpened then return end
		leverOpened = true
		pr:Destroy()
		toast("A hidden door grinds open...", true)
		local goal = secretDoor.CFrame * CFrame.new(0, 13, 0)
		tween(secretDoor, 1.6, { CFrame = goal }, Enum.EasingStyle.Quad)
		for _, b in ipairs(secretBooks) do
			tween(b, 1.6, { CFrame = b.CFrame * CFrame.new(0, 13, 0) }, Enum.EasingStyle.Quad)
		end
	end, 0.6, 8)
end

-- six treasure chests (hidden spots)
chest(96, 0.3, 94, 200)       -- NE courtyard corner, behind the tower base
chest(76, 0.3, 70, 90)        -- behind the keep, east side
chest(-107, 30.4, 10, 90)     -- on the west wall walkway
chest(107, 30.4, -70, 270)    -- on the east wall walkway (use the east stairs)
chest(55, 0.9, 38.5, 0)       -- inside the secret room
chest(94, 0.3, -96, 150)      -- south-east corner

--==================================================
-- ROYAL CHAMBER DOOR
--==================================================
local SkipShow
local doorPrompt
do
	doorPrompt = prompt(chamberDoor, "Unlock", "Royal Chamber", function()
		if chamberOpened then return end
		local n = keyCount()
		if n < 3 then
			toast("The door needs " .. (3 - n) .. " more key(s).", false)
			return
		end
		chamberOpened = true
		doorPrompt:Destroy()
		toast("The Royal Chamber opens!", true)
		tween(chamberDoor, 1.8, { CFrame = chamberDoor.CFrame * CFrame.new(0, 15, 0) }, Enum.EasingStyle.Quad)
		chamberDoorLock.CanCollide = false
		tween(chamberDoorLock, 1.2, { Transparency = 1 })
		for _, t in ipairs({ chamberDoorTrim1, chamberDoorTrim2 }) do
			tween(t, 1.8, { CFrame = t.CFrame * CFrame.new(0, 15, 0) }, Enum.EasingStyle.Quad)
		end
		task.delay(1.6, avatarToThrone)
		task.delay(2.2, function() if SkipShow then SkipShow() end end)
	end, 0.8, 10)
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
local Closed = false

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
	for _, c in ipairs(conns) do pcall(function() c:Disconnect() end) end
	conns = {}

	if worn and OldDesc then
		local h = getHum()
		if h then pcall(function() h:ApplyDescription(OldDesc) end) end
	end
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
-- CINEMATIC ENTRY
--==================================================
local Spawn = at(0, 4.5, -88)

local cam = getCam()
if cam then cam.CameraType = Enum.CameraType.Scriptable end

task.wait(1.4)
tween(Intro, 0.7, { TextTransparency = 1 })
task.wait(0.7)
Black.BackgroundTransparency = 1
Black:Destroy()

do
	local look = Center + Vector3.new(0, 22, 20)
	local radius, height = 210, 80
	local t0, dur = os.clock(), 5
	while os.clock() - t0 < dur and not Closed do
		local a = (os.clock() - t0) / dur * math.pi * 2 + math.pi
		cam = getCam()
		if cam then cam.CFrame = CFrame.lookAt(look + Vector3.new(math.sin(a) * radius, height, math.cos(a) * radius), look) end
		RunService.RenderStepped:Wait()
	end

	-- fly in through the gate to the courtyard
	local from = look + Vector3.new(0, height, -radius)
	local to = Center + Vector3.new(0, 12, -80)
	local focusFrom, focusTo = look, Center + Vector3.new(0, 16, 40)
	local t1, dur2 = os.clock(), 2.6
	while os.clock() - t1 < dur2 and not Closed do
		local a = math.clamp((os.clock() - t1) / dur2, 0, 1)
		a = TweenService:GetValue(a, Enum.EasingStyle.Quart, Enum.EasingDirection.InOut)
		cam = getCam()
		if cam then cam.CFrame = CFrame.lookAt(from:Lerp(to, a), focusFrom:Lerp(focusTo, a)) end
		RunService.RenderStepped:Wait()
	end
end

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
	task.wait(0.25)
	restoreCamera()
	counter.Visible = true
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
	wall("BarrierS", 340, 400, 4, 0, 150, -168)
	wall("BarrierW", 4, 400, 340, -168, 150, 0)
	wall("BarrierE", 4, 400, 340, 168, 150, 0)
	wall("BarrierTop", 340, 4, 340, 0, 350, 0)
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
	if math.abs(rel.X) > 160 or math.abs(rel.Z) > 160 or rel.Y < -40 or rel.Y > 330 then
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

print("[AAYAN CASTLE] loaded. Re-run the script any time to return to your old position.")
