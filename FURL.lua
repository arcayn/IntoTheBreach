-- GENERATE A LOCAL COLOR MAPS LIST

local color_maps = {}
local x = 0
local z = true
while z do
	x = x + 1
	local newColor = GetColorMap(x)
	if newColor == nil then
		z = false
	else
		table.insert(color_maps, newColor)
	end
end

-- OVERRIDE THE CURRENT FUNCTIONS

function GetColorCount()
	return #color_maps
end
function GetColorMap(id)
	return color_maps[id]
end

-- RELOAD ANIMATIONS TO ACCOMMODATE ADDED COLOR SCHEMES

local function reloadAnims()
	for i,v in pairs(ANIMS) do
		if type(v) == "table" then
			if v.Height then
				if v.Height == GetColorCount() - 1 then
					if v.IsVek then local foo = "foo"
					else
						v.Height = GetColorCount()
					end
				end
			end
		end
	end
end

-- GENERATE VEK SPRITES

local function setUpVek(mod,object)

	-- LOCALISE

	local name = object.Name
	local filename = object.Filename
	local path = object.Path or "units"
	local innerPath = object.ResourcePath or "units/aliens"
	local height = object.Height or 3;
	
	local standards = {
		Default = true, 
		Animated = true, 
		Death  = true, 
		Submerged = true, 
		Name = true, 
		Filename = true, 
		Path = true, 
		ResourcePath = true,
		Emerge = true,
		Height = true,
		Portrait = true,
		HasAlpha = true,
		HasBoss = true,
		Type = true,
	};
	
	-- SET UP RESOURCE LOADING
	
	local function replaceSprite(addition)
		modApi:appendAsset("img/"..innerPath.."/"..filename..addition..".png",mod.resourcePath.."/"..path.."/"..filename..addition..".png")
	end
	
	-- LOAD
	
	if object.Default then replaceSprite("") end
	if object.Animated then replaceSprite("a") end
	if object.Emerge then replaceSprite("_emerge") end
	if object.Death then replaceSprite("_death") end
	if object.Submerged then replaceSprite("_Bw") end
	
	-- ADD PORTRAITS
	
	if object.Portrait then 
		if object.Portrait then
			modApi:appendAsset("img/portraits/enemy/"..object.Portrait.."1.png",mod.resourcePath.."/"..path.."/"..object.Portrait..".png") 
		end
		if object.HasAlpha then
			if object.HasAlpha == 1 then
				modApi:appendAsset("img/portraits/enemy/"..object.Portrait.."2.png",mod.resourcePath.."/"..path.."/"..object.Portrait.."_alpha.png")
			else
				modApi:appendAsset("img/portraits/enemy/"..object.Portrait.."2.png",mod.resourcePath.."/"..path.."/"..object.Portrait..".png")
			end
		end
		if object.HasBoss then
			if object.HasBoss == 1 then
				modApi:appendAsset("img/portraits/enemy/"..object.Portrait.."B.png",mod.resourcePath.."/"..path.."/"..object.Portrait.."_boss.png")
			elseif object.HasBoss == 2 then
				modApi:appendAsset("img/portraits/enemy/"..object.Portrait.."B.png",mod.resourcePath.."/"..path.."/"..object.Portrait.."_alpha.png")
			else
				modApi:appendAsset("img/portraits/enemy/"..object.Portrait.."B.png",mod.resourcePath.."/"..path.."/"..object.Portrait..".png")
			end
		end
	end
	
	-- MODIFY THE OBJECTS PASSED
	
	local function addImage(obj, addition)
		if obj == nil then obj = {} end
		obj.Image = innerPath.."/"..filename..addition..".png"
		obj.Height = height
		obj.IsVek = true
		return obj
	end
	
	-- DEAL WITH CUSTOM ANIMS
	
	for index, value in pairs(object) do
		if standards[index] then 
		else
			replaceSprite("_"..index)
			ANIMS[name.."_"..index] = ANIMS.EnemyUnit:new(addImage(value,"_"..index))
		end
	end
	
	local function addDeath(obj, addition)
		obj.NumFrames = obj.NumFrames or 8
		obj.Time = obj.Time or 0.14
		obj.Loop = obj.Loop or false
		obj = addImage(obj, addition)
		return obj
	end
	
	-- LOAD ANIMATIONS
	
	if object.Default         then ANIMS[name] =             ANIMS.EnemyUnit:new(addImage(object.Default,"")) end
	if object.Animated        then ANIMS[name.."a"] =        ANIMS.EnemyUnit:new(addImage(object.Animated,"a")) end
	if object.Submerged       then ANIMS[name.."w"] =        ANIMS.EnemyUnit:new(addImage(object.Submerged,"_Bw")) end
	if object.Emerge          then ANIMS[name.."e"] =        ANIMS.BaseEmerge:new(addImage(object.Emerge,"_emerge")) end
	if object.Death           then ANIMS[name.."d"] =        ANIMS.EnemyUnit:new(addDeath(object.Death,"_death")) end
end

-- SET UP MECH SPRITES

function setUpMech(mod, object)

	-- LOCALISE

	local name = object.Name
	local filename = object.Filename
	local path = object.Path or "units"
	local innerPath = object.ResourcePath or "units/player";
	
	local standards = {
		Default = true, 
		Animated = true, 
		Broken = true,
		Icon = true, 
		Death  = true, 
		Submerged = true, 
		SubmergedBroken = true, 
		Name = true, 
		Filename = true, 
		Path = true, 
		ResourcePath = true,
		Type = true,
	};
	
	-- SET UP RESOURCE LOADING
	
	local function replaceSprite(addition)
		modApi:appendAsset("img/"..innerPath.."/"..filename..addition..".png",mod.resourcePath.."/"..path.."/"..filename..addition..".png")
	end
	
	-- MODIFY OBJECTS
	
	local function addImage(obj, addition)
		if obj == nil then obj = {} end
		obj.Image = innerPath.."/"..filename..addition..".png"
		return obj
	end
	
	-- DEAL WITH CUSTOM ANIMS
	
	for index, value in pairs(object) do
		if standards[index] then 
		else
			replaceSprite("_"..index)
			ANIMS[name.."_"..index] = ANIMS.MechUnit:new(addImage(value,"_"..index))
		end
	end
	
	-- LOAD
	
	if object.Default then replaceSprite("") end
	if object.Animated then replaceSprite("_a") end
	if object.Broken then replaceSprite("_broken") end
	if object.Icon then replaceSprite("_ns") end
	if object.Icon then replaceSprite("_h") end
	if object.Death then replaceSprite("_death") end
	if object.Submerged then replaceSprite("_w") end
	if object.SubmergedBroken then replaceSprite("_w_broken") end
	
	-- LOAD ANIMATIONS
	
	if object.Default         then ANIMS[name] =             ANIMS.MechUnit:new(addImage(object.Default,"")) end
	if object.Animated        then ANIMS[name.."a"] =        ANIMS.MechUnit:new(addImage(object.Animated,"_a")) end
	if object.Submerged       then ANIMS[name.."w"] =        ANIMS.MechUnit:new(addImage(object.Submerged,"_w")) end
	if object.Death           then ANIMS[name.."d"] =        ANIMS.MechUnit:new(addImage(object.Submerged,"_death")) end
	if object.Broken          then ANIMS[name.."_broken"] =  ANIMS.MechUnit:new(addImage(object.Broken,"_broken")) end
	if object.SubmergedBroken then ANIMS[name.."w_broken"] = ANIMS.MechUnit:new(addImage(object.SubmergedBroken,"_w_broken")) end
	if object.Icon            then ANIMS[name.."_ns"] =      ANIMS.MechIcon:new(addImage(object.Icon,"_ns")) end
	if object.Death           then ANIMS[name.."d"] =        ANIMS.EnemyUnit:new(addDeath(object.Death,"_death")) end
end

-- ADD GENERIC ANIMATIONS

local function addAnim(mod, object)

	-- LOCALISE AND REMOVE IRRELEVANT VARIABLES

	local name = object.Name
	object.Name = nil
	local filename = object.Filename
	object.Filename = nil
	local path = object.Path or "anims"
	object.Path = nil
	local innerPath = object.ResourcePath or "effects"
	object.innerPath = nil
	local baseAnim = object.Base or "Animation"
	
	-- SET UP LOADING
	
	local function replaceSprite(addition)
		modApi:appendAsset("img/"..innerPath.."/"..filename..addition..".png",mod.resourcePath.."/"..path.."/"..filename..addition..".png")
	end
	
	-- LOAD
	
	replaceSprite("")
	
	-- MODIFY OBJECCT
	
	local function addImage(obj, addition)
		if obj == nil then obj = {} end
		obj.Image = innerPath.."/"..filename..addition..".png"
		return obj
	end
	
	-- LOAD ANIMATION
	
	ANIMS[name] =  ANIMS[baseAnim]:new(addImage(object,""))
end

-- PRETTIFIED VERSION OF MODAPI:APPENDASSET()

local function addResource(mod, object)

	-- LOCALISE

	local filename = object.Filename
	local path = object.Path or ""
	local innerPath = object.ResourcePath or ""
	
	-- SET UP LOADING
	
	local function replaceSprite(addition)
		modApi:appendAsset("img/"..innerPath.."/"..filename..addition..".png",mod.resourcePath.."/"..path.."/"..filename..addition..".png")
	end
	
	-- LOAD
	
	replaceSprite("")
end

-- GENERATE NEW COLOR PALETTES
	
local function loadColors(mod, object)

	-- LOCALISE

	local newColor = {}
	local name = object.Name
	
	-- UPDATE COLOR IDS TABLE
	
	FURL_COLORS[name] = GetColorCount()
	
	-- GENERATE PALETTE TABLE FROM PASSED VARIABLES
	
	table.insert(newColor, GL_Color(object.PlateHighlight[1],object.PlateHighlight[2],object.PlateHighlight[3]))
	table.insert(newColor, GL_Color(object.PlateLight[1],object.PlateLight[2],object.PlateLight[3]))
	table.insert(newColor, GL_Color(object.PlateMid[1],object.PlateMid[2],object.PlateMid[3]))
	table.insert(newColor, GL_Color(object.PlateDark[1],object.PlateDark[2],object.PlateDark[3]))
	table.insert(newColor, GL_Color(object.PlateOutline[1],object.PlateOutline[2],object.PlateOutline[3]))
	table.insert(newColor, GL_Color(object.PlateShadow[1],object.PlateShadow[2],object.PlateShadow[3]))
	table.insert(newColor, GL_Color(object.BodyColor[1],object.BodyColor[2],object.BodyColor[3]))
	table.insert(newColor, GL_Color(object.BodyHighlight[1],object.BodyHighlight[2],object.BodyHighlight[3]))
	
	-- INSERT NEW PALETTE TABLE
	
	table.insert(color_maps, newColor)
	
	-- RELOAD ALL ANIMATIONS
	
	reloadAnims()
	
	-- RELOAD PAWNS (IN THEORY - DON'T KNOW WHY THIS DOESN'T WORK. FOR NOW PAWN SCRIPTS WILL HAVE TO BE LOADED AFTER FUR SCRIPTS)
	
	--[[if object.PawnLocation then 
		local pawnloc = object.PawnLocation
		require(pawnloc)
	end]]--
	
	
end

-- SET UP PILOT PORTRAITS

local function addPilot(mod, object)

	-- LOCALISE

	local filename = object.PilotID
	local path = object.Path or ""
	local pathAdd = object.ResourcePath or "pilots"
	local innerPath = "portraits/"..pathAdd
	
	-- SET UP LOADING
	
	local function replaceSprite(addition)
		modApi:appendAsset("img/"..innerPath.."/"..filename..addition..".png",mod.resourcePath.."/"..path.."/"..filename..addition..".png")
	end
	
	-- LOAD
	
	replaceSprite("")
	replaceSprite("_2")
	replaceSprite("_blink")
end
	
-- MAIN FUNCTION
	
return function(mod,table)

	-- INITIALISE COLOR PALETTE TABLE

	if FURL_COLORS == nil then FURL_COLORS = {} end
	
	-- RUN RELEVANT FUNCTIONS
	
	for i=1,#table do
		local object = table[i]
		local animType = object.Type or "null"
		if animType == "enemy" then
			setUpVek(mod, object)
		elseif animType == "mech" then
			setUpMech(mod, object)
		elseif animType == "anim" then
			addAnim(mod, object)
		elseif animType == "base" then
			addResource(mod, object)
		elseif animType == "color" then
			loadColors(mod, object)
		elseif animType == "pilot" then
			addPilot(mod, object)
		else
			LOG("Error: missing or invalid type value")
		end
	end
end