if PilotSkils == nil then

PilotSkills = {
	Disable_Immunity = PilotSkill("Evasion","Mech unaffected by Webbing and Smoke."),
	Extra_XP = PilotSkill("Experienced","Gain +2 bonus XP\nper kill."),
	Self_Shield = PilotSkill("Starting Shield","Mech starts every mission with a Shield."),
	Road_Runner = PilotSkill("Maneuverable","Mech can move through enemy units."),
	Shifty = PilotSkill("Sidestep","After attacking, gain 1 free tile movement."),
	Deploy_Anywhere = PilotSkill("Preemptive Strike", "Deploy anywhere on the map, damaging adjacent enemies."),
	Survive_Death = PilotSkill("Vek", "Normal Pilots cannot be equipped. Loses 25 XP when the unit is disabled."),
	Pain_Immunity = PilotSkill("Cauterize", "Fire heals instead of damaging Mech."),
	Power_Repair = PilotSkill("Frenzied Repair", "Push adjacent tiles when repairing."),
	Freeze_Walk = PilotSkill("Frozen Stance", "Stopping on any liquid tile freezes it, making it safe to stand on."),
	Armored = PilotSkill("Armored", "Mech gains Armored."),
	Flying = PilotSkill("Flying", "Mech gains Flying."),
	Double_Shot = PilotSkill("Double Shot", "Mech can act twice if it does not move."),
	Post_Move = PilotSkill("Fire-and-Forget", "Move again after shooting."),
	Youth_Move = PilotSkill("Impulsive", "Gain +3 Move on first turn of every mission."),
	Retaliation = PilotSkill("Retaliation", "Deal 1 damage to adjacent enemies after surviving damage."),
	TimeTravel = PilotSkill("Temporal Reset", "Gain 1 extra 'Reset Turn' every battle."),
	Mantis_Skill = PilotSkill("Mantis", "2 damage melee attack replaces Repair."),
	Rock_Skill = PilotSkill("Rockman", "+3 Health and\nImmune to Fire."),
	Zoltan_Skill = PilotSkill("Zoltan", "+1 Reactor Core.\nReduce Mech HP to 1.\nGain Shield every turn."),
	Road = PilotSkill("Zoltan", "+1 Reactor Core.\nReduce Mech HP to 1.\nGain Shield every turn."),
}
end

function GetSkillInfo(skill)
	if skill == "" then return PilotSkill() end
	return PilotSkills[skill]
end

local ftcsv = dofile(GetWorkingDir().."scripts/personalities/ftcsv.lua") -- script for parsing csv file

local function split(str, pat)
	local t = {} 
	local fpat = "(.-)" .. pat
	local last_end = 1
	local s, e, cap = str:find(fpat, 1)
	while s do
		if s ~= 1 or cap ~= "" then
			table.insert(t,cap)
		end
		last_end = e+1
		s, e, cap = str:find(fpat, last_end)
	end
	if last_end <= #str then
		cap = str:sub(last_end)
		table.insert(t, cap)
	end
	return t
end

local PilotPersonality = {Label = "NULL"}
CreateClass(PilotPersonality)

local Names = {}--ret[1]
local Keys = {}--ret[2]

local function GetKey(index)
	if index > 3 and Keys[index] ~= "" then return Keys[index] end
	return ""
end

function PilotPersonality:GetPilotDialog(event)
	if self[event] ~= nil then 
		if type(self[event]) == "table" then
			return random_element(self[event])
		end
		
		return self[event]
	end
	
	LOG("No pilot dialog found for "..event.." event in "..self.Label)
	return ""
end

function GetPilotDialog(personality, event)
    if Personality[personality] == nil then
        LOG("No  dialog found for personality:"..personality..", event: ".. event)
        return ""
    end
    
    local text = Personality[personality]:GetPilotDialog(event)
	text = string.gsub(text, "#squad", Game:GetSquad())
	text = string.gsub(text, "#corp", Game:GetCorp().name)
	return text
end

local function addPersonalities(new_filelist)
	for index, curr in ipairs(new_filelist) do
		local ret = ftcsv.parse(curr.file, ',', {headers = false})
		Names = ret[1]
		Keys = ret[2]
		
		for index, id in ipairs(ret[2]) do
			if index > curr.start and id ~= "" then
				local parent = ret[3][index]
				
				if Personality[id] == nil then
					if parent == "" or Personality[parent] == nil then
						Personality[id] = PilotPersonality:new()
					else
						Personality[id] = Personality[parent]:new()
					end
				
					Personality[id].Label = Names[index]
					Personality[id].Name = ret[4][index]
				end
			end
		end
		
		for i,row in ipairs(ret) do
			local trigger = row[2]
			if i >= curr.start and trigger ~= "" then
				for index, text in ipairs(row) do
					if GetKey(index) ~= "" and text ~= "" then
						--text = "\""..text
						if string.sub(text,#text) == "," then
							text = string.sub(text,1,#text-1)
						end
						text = string.gsub(text,"“","")
						text = string.gsub(text,"”","")
						text = string.gsub(text,"‘","'")
						text = string.gsub(text,"…","...")
						text = string.gsub(text,"’","'")
						text = string.gsub(text,"–","-")
						
						local final_texts = {text}
						if trigger ~= "Region_Names" then--don't split up Region_Names
							final_texts = split(text,"\",%s*\n*")
						end
						
						for i, v in ipairs(final_texts) do
							final_texts[i] = string.gsub(v,"\"","")
						end
						
						Personality[GetKey(index)][trigger] = final_texts
					end
				end
			end
		end
	end
end

return function(mod, object)

	LOG("here")
	-- LOCALISE

	local pilotID = object.PilotID
	local filename = object.PortraitFilename
	local path = object.Path or ""
	local pathAdd = object.ResourcePath or "pilots"
	local innerPath = "portraits/"..pathAdd
	local personalityFilename = object.PersonalityFilename
	
	-- SET UP PORTRAIT LOADING
	
	local function replaceSprite(addition)
		modApi:appendAsset("img/"..innerPath.."/"..pilotID..addition..".png",mod.resourcePath.."/"..path.."/"..filename..addition..".png")
	end
	
	-- LOAD PORTRAITS
	
	replaceSprite("")
	replaceSprite("_2")
	replaceSprite("_blink")
	
	-- LOCALISE MORE STUFF
	
	local isDroppable = object.IsDroppable or false
	local isRecruit = object.IsRecruit
	local pilotType = object.Type
	local voice = object.Voice
	local skill = object.Skill
	local personality = object.Personality
	local sex = SEX_AI
	local name = object.Name
	local powerCost = object.PowerCost or 0
	local rarity = 1
	
	-- DO SOME MODIFIERS
	
	if pilotType == "male" then sex = SEX_MALE
	elseif pilotType == "female" then sex = SEX_FEMALE
	elseif pilotType == "vek" then sex = SEX_VEK end
	
	if isDroppble then rarity = 1
	else rarity = 0 end
	
	
	-- CREATE THE PILOT
	
	local realPortrait = pathAdd.."/"..pilotID
	local realVoice = "/voice/"..voice
	
	_G[pilotID] = Pilot:new{
		Sex = sex,
		Skill = skill,
		Personality = personality,
		PowerCost = powerCost,
		Name = name,
		Voice = realVoice,
		Portrait = realPortrait,
		Rarity = rarity,
	}
	
	if object.CustomSkill then
		PilotSkills[skill] = object.CustomSkill
	end
	
		PilotList[#PilotList+1] = pilotID
	
	
	-- ADD TO RECRUITS
	LOG(pilotID..sex..skill..personality..name..powerCost)
	if isRecruit then

		table.insert(Pilot_Recruits, pilotID)
	end
	
	-- ADD PERSONALITIES (BIG BIT OF STUFF)
	local new_filelist = { 
		{file = mod.resourcePath.."/"..path.."/"..personalityFilename..".csv", start = 3 }
	}
	addPersonalities(new_filelist)
end