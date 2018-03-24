return function(mod,table)
	for i=1,#table do
		local object = table[i]
		local name = object.Name
		local filename = object.Filename
		local path = object.Path or "units"
		local innerPath = object.ResourcePath or "units/aliens"
		local height = object.Height or 3
		
		local function replaceSprite(addition)
			modApi:appendAsset("img/"..innerPath.."/"..filename..addition..".png",mod.resourcePath.."/"..path.."/"..filename..addition..".png")
		end
		
		if object.Default then replaceSprite("") end
		if object.Animated then replaceSprite("a") end
		if object.Emerge then replaceSprite("_emerge") end
		if object.Death then replaceSprite("_death") end
		if object.Submerged then replaceSprite("_Bw") end
		
		local function addImage(obj, addition)
			if obj == nil then obj = {} end
			obj.Image = innerPath.."/"..filename..addition..".png"
			obj.Height = height
			return obj
		end
		
		if object.Default         then ANIMS[name] =             ANIMS.EnemyUnit:new(addImage(object.Default,"")) end
		if object.Animated        then ANIMS[name.."a"] =        ANIMS.EnemyUnit:new(addImage(object.Animated,"a")) end
		if object.Submerged       then ANIMS[name.."w"] =        ANIMS.EnemyUnit:new(addImage(object.Submerged,"_Bw")) end
		if object.Emerge          then ANIMS[name.."e"] =        ANIMS.BaseEmerge:new(addImage(object.Emerge,"_emerge")) end
		if object.Death           then ANIMS[name.."d"] =        ANIMS.EnemyUnit:new(addImage(object.Death,"_death")) end
	end
end