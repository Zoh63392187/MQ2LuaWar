--[[
Todo:

Aura
Buffs->offensive
Buffs->Burns

Credit Blasty
]]

local mq = require('mq')
require('ImGui')

if mq.TLO.Me.Class.ShortName() ~= 'WAR' then
	mq.cmd('/beep')
	mq.cmd('/beep')
	print('Wrong class... Did the file name not say it all?')
	os.exit()
end

local srcName = 'MQ2LuaWar'
local version = '0.1'
local classSettings = {
	Melee_taunt=false,
	Melee_AOE_taunt=false,
	Melee_snare=false,
	Defensive_disc_cycle=false,
	Defensive_buffs_cycle=false,	
	Defensive_da=false,
	Defensive_buffs_aura=false,
	Offensive_disc_cycle=false,
	Offensive_buffs_cycle=false,	
	Misc_powersource=false,
	Misc_monitor_food_drink=false,
	Misc_monitor_endurance=false,
	Burn_always=false
}
local keepAlive = true
local powerSourceChecked = os.time()

local function initIni()
	if not mq.TLO.Ini(srcName..'_'..mq.TLO.Me.CleanName()..'.ini',"Settings")() then
		print('Creating Ini file')
		
		for k,v in pairs(classSettings) do
			mq.cmd('/ini "'..srcName..'_'..mq.TLO.Me.CleanName()..'.ini" "Settings" '..k..' "0"')
			classSettings[k] = false
		end
	else 
		for k,v in pairs(classSettings) do
			if mq.TLO.Ini(srcName..'_'..mq.TLO.Me.CleanName()..'.ini',"Settings",k)() == "0" or mq.TLO.Ini(srcName..'_'..mq.TLO.Me.CleanName()..'.ini',"Settings",k)() == "1" then
				if mq.TLO.Ini(srcName..'_'..mq.TLO.Me.CleanName()..'.ini',"Settings",k)() == '1' then
					classSettings[k] = true
				else
					classSettings[k] = false
				end
			else
				mq.cmd('/beep')
				mq.cmd('/beep')
				print('Invalid Ini file')
				os.exit()
			end
		end
	end
end

local function updateIni(var,value)
	mq.cmd('/ini "'..srcName..'_'..mq.TLO.Me.CleanName()..'.ini" "Settings" "'..var..'" "'..value..'"')
end

local function setup()
	print('\ay Welcome to '..srcName..' '..version)
	initIni()
end

local function checkIni()
	for k,v in pairs(classSettings) do
		if classSettings[k] == true then
			updateIni(k,'1')
		elseif classSettings[k] == false then
			updateIni(k,'0')
		end
	end
end

local function buildWindow()
	local update

	keepAlive = ImGui.Begin(srcName, keepAlive)
	ImGui.SetWindowSize(srcName, 350, 400)
	ImGui.SetWindowSize(srcName, 350, 400, ImGuiCond.Always)
	
	ImGui.TextColored(IM_COL32(255, 255, 0, 255), 'Melee:')
	ImGui.Separator()
	
    classSettings.Melee_taunt, update = ImGui.Checkbox('Taunt', classSettings.Melee_taunt)
	if update then checkIni() end
	ImGui.SameLine()
	classSettings.Melee_AOE_taunt, update = ImGui.Checkbox('AOE Taunt', classSettings.Melee_AOE_taunt)
	if update then checkIni() end
	ImGui.SameLine()
	classSettings.Melee_snare, update = ImGui.Checkbox('Snare', classSettings.Melee_snare)
	if update then checkIni() end
	ImGui.NewLine()
	
	ImGui.TextColored(IM_COL32(255, 255, 0, 255), 'Disciplines:')
	ImGui.Separator()
	classSettings.Defensive_disc_cycle, update = ImGui.Checkbox('Defensive cycle', classSettings.Defensive_disc_cycle)
	if update then checkIni() end
	ImGui.SameLine()
	classSettings.Offensive_disc_cycle, update = ImGui.Checkbox('Offensive cycle', classSettings.Offensive_disc_cycle)
	if update then checkIni() end
	ImGui.SameLine()
	classSettings.Defensive_da, update = ImGui.Checkbox('DA', classSettings.Defensive_da)
	if update then checkIni() end
	ImGui.NewLine()
	
	ImGui.TextColored(IM_COL32(255, 255, 0, 255), 'Buffs:')
	ImGui.Separator()
	classSettings.Defensive_buffs_cycle, update = ImGui.Checkbox('Defensive', classSettings.Defensive_buffs_cycle)
	if update then checkIni() end
	ImGui.SameLine()
	classSettings.Offensive_buffs_cycle, update = ImGui.Checkbox('Offensive', classSettings.Offensive_buffs_cycle)
	if update then checkIni() end
	ImGui.SameLine()
	classSettings.Burn_always, update = ImGui.Checkbox('Burn Always', classSettings.Burn_always)
	if update then checkIni() end
	classSettings.Defensive_buffs_aura, update = ImGui.Checkbox('Aura', classSettings.Defensive_buffs_aura)
	if update then checkIni() end
	ImGui.NewLine()
	
	ImGui.TextColored(IM_COL32(255, 255, 0, 255), 'Monitor:')
	ImGui.Separator()
	classSettings.Misc_monitor_endurance, update = ImGui.Checkbox('Endurance', classSettings.Misc_monitor_endurance)
	if update then checkIni() end
	ImGui.SameLine()
	classSettings.Misc_monitor_food_drink, update = ImGui.Checkbox('Food/Drink', classSettings.Misc_monitor_food_drink)
	if update then checkIni() end
	ImGui.SameLine()
	classSettings.Misc_powersource, update = ImGui.Checkbox('PowerSource', classSettings.Misc_powersource)
	if update then checkIni() end
	ImGui.NewLine()
			
	ImGui.End()
end

local CheckCombat = function ()
	if mq.TLO.Zone.ID() == 190 then
		return false		
	end
		
	if mq.TLO.Me.Combat() and mq.TLO.Target.Type() == "NPC" then
		-- Melee:
		if classSettings.Melee_taunt == true then
			if mq.TLO.Me.AbilityReady("Taunt")() and mq.TLO.Target.PctAggro() < 100 and mq.TLO.Target.Distance() < 20 then
				mq.cmd('/doability Taunt')
			end
			if mq.TLO.Me.CombatAbilityReady("Phantom Aggressor Rk. II")() then
				mq.cmd('/doability "Phantom Aggressor Rk. II"')
			end
			if mq.TLO.Me.CombatAbilityReady("Namdrows' Roar Rk. III")() then
				mq.cmd("/doability \"Namdrows' Roar Rk. III\"")
			end
			if mq.TLO.Me.CombatAbilityReady("Bristle Rk. III")() then
				mq.cmd('/doability "Bristle Rk. III"')
			end
			if mq.TLO.Me.CombatAbilityReady("Penumbral Precision Rk. II")() and not mq.TLO.Me.Buff("Penumbral Precision").ID() then
				mq.cmd('/doability "Penumbral Precision Rk. II"')
			end
		end
		if classSettings.Melee_AOE_taunt == true then
			local i = 1
			while (mq.TLO.Me.XTarget(i).ID() and mq.TLO.Me.XTarget(i).ID() > 0) do
				if mq.TLO.Me.XTarget(i).Type() == "NPC" and mq.TLO.Me.XTarget(i).Distance() <= 40 and mq.TLO.Me.XTarget(i).PctAggro() ~= 100 then
					if mq.TLO.Me.CombatAbilityReady("Hurricane Blades Rk. III")() then
						mq.cmd('/doability "Hurricane Blades Rk. III"')
					elseif mq.TLO.Me.CombatAbilityReady("Rallying Roar")() then
						mq.cmd('/doability "Rallying Roar"')
					elseif mq.TLO.Me.AltAbilityReady("Area Taunt")() then
						mq.cmd('/alt act 110')
					else 
						mq.cmd('/tar id '..mq.TLO.Me.XTarget(i).ID())
					end
				end
				i = i+1
			end	
			i = 1
		end		
		if classSettings.Melee_snare == true then
			if mq.TLO.Me.AltAbilityReady("Call of Challenge")() then
				mq.cmd('/alt act 552')
			end
		end
		-- Disciplins:
		if classSettings.Defensive_disc_cycle == true then
			if mq.TLO.Me.ActiveDisc.ID() == 62062 or mq.TLO.Me.ActiveDisc.ID() == nil then
				if mq.TLO.Me.CombatAbilityReady("Resolute Stand Rk. III")() then
					mq.cmd('/stopdisc')
					mq.cmd('/doability "Resolute Stand Rk. III"')
				elseif mq.TLO.Me.CombatAbilityReady("Armor of Akhevan Runes Rk. III")() then
					mq.cmd('/stopdisc')
					mq.cmd('/doability "Armor of Akhevan Runes Rk. III"')
				elseif mq.TLO.Me.CombatAbilityReady("Fortitude Discipline")() then
					mq.cmd('/stopdisc')
					mq.cmd('/doability "Fortitude Discipline"')
				end
			end
		end
		if classSettings.Offensive_disc_cycle == true then
			if mq.TLO.Me.ActiveDisc.ID() == 62062 or mq.TLO.Me.ActiveDisc.ID() == nil then
				if mq.TLO.Me.CombatAbilityReady("Brightfeld's Onslaught Discipline Rk. II")() then
					mq.cmd('/stopdisc')
					mq.cmd('/doability "Brightfeld\'s Onslaught Discipline Rk. II"')
				elseif mq.TLO.Me.CombatAbilityReady("Mighty Strike Discipline")() then
					mq.cmd('/stopdisc')
					mq.cmd('/doability "Mighty Strike Discipline"')
				elseif mq.TLO.Me.CombatAbilityReady("Weapon Affiliation")() then
					mq.cmd('/stopdisc')
					mq.cmd('/doability "Weapon Affiliation"')
				end
			end
		end
		if classSettings.Defensive_da == true then
			if mq.TLO.Me.PctHPs() < 30 and mq.TLO.Me.CombatAbilityReady("Flash of Anger")() then
				mq.cmd('/doability "Flash of Anger"')
			end
		end	
		-- Buffs:
		if classSettings.Defensive_buffs_cycle == true then
			if classSettings.Defensive_disc_cycle == true then
				if mq.TLO.Me.ActiveDisc.ID() == 62062 then
					if mq.TLO.Me.AltAbilityReady("Blade Guardian")() then
						mq.cmd('/alt act 967')
					end
					if mq.TLO.Me.AltAbilityReady("Brace For Impact")() then
						mq.cmd('/alt act 1686')
					end
					if mq.TLO.Me.AltAbilityReady("Resplendent Glory")() then
						mq.cmd('/alt act 130')
					end
					if mq.TLO.Me.AltAbilityReady("Warlord's Bravery")() then
						mq.cmd('/alt act 804')
					end
					if mq.TLO.Me.AltAbilityReady("Warlord's Resurgence")() then
						mq.cmd('/alt act 911')
					end
					if mq.TLO.Me.AltAbilityReady("Warlord's Tenacity")() then
						mq.cmd('/alt act 300')
					end
				end
			else
				if mq.TLO.Me.AltAbilityReady("Blade Guardian")() then
					mq.cmd('/alt act 967')
				end
				if mq.TLO.Me.AltAbilityReady("Brace For Impact")() then
					mq.cmd('/alt act 1686')
				end
				if mq.TLO.Me.AltAbilityReady("Resplendent Glory")() then
					mq.cmd('/alt act 130')
				end
				if mq.TLO.Me.AltAbilityReady("Warlord's Bravery")() then
					mq.cmd('/alt act 804')
				end
				if mq.TLO.Me.AltAbilityReady("Warlord's Resurgence")() then
					mq.cmd('/alt act 911')
				end
				if mq.TLO.Me.AltAbilityReady("Warlord's Tenacity")() then
					mq.cmd('/alt act 300')
				end
			end
		end
		if classSettings.Offensive_buffs_cycle == true then
		
		end
		if classSettings.Burn_always == true then
		
		end
			
		-- Monitor
		if classSettings.Misc_powersource == true then
			if mq.TLO.Me.Inventory("powersource")() and mq.TLO.Me.Inventory("powersource").PctPower() < 1 and powerSourceChecked <= os.time() then
				print("Powersource at 0%")
				mq.cmd('/beep')
				mq.cmd('/beep')
				powerSourceChecked = os.time()+10
			end
		end
		if classSettings.Misc_monitor_food_drink == true then
			if mq.TLO.Me.Hunger() <= 4000 then
				print('Eating!')
				mq.cmd('/useitem Misty Thicket Picnic')
				mq.delay(1000)
			end
			if mq.TLO.Me.Thirst() <= 4000 then
				print('Drinking!')
				mq.cmd('/useitem Kaladim Constitutional')
				mq.delay(1000)
			end
		end
		if classSettings.Misc_monitor_endurance == true then
			if mq.TLO.Me.PctEndurance() < 10 and mq.TLO.Me.CombatAbilityReady("Night's Calming Rk. III")() then
				mq.cmd("/doability \"Night's Calming Rk. III\"")
			end
		end		
		-- Basic Melee
		if mq.TLO.Me.CombatAbilityReady("Primal Defense Rk. III")() and not mq.TLO.Me.ActiveDisc() then
			mq.cmd('/doability "Primal Defense Rk. III"')			
		end
		if mq.TLO.Me.CombatAbilityReady("Shield Rupture Rk. II")() then
			mq.cmd('/doability "Shield Rupture Rk. II"')
		end
		if mq.TLO.Me.AltAbilityReady("Knee Strike")() then
			mq.cmd('/alt act 801')
		end
		if mq.TLO.Me.AbilityReady("Disarm")() and mq.TLO.Target.Distance() < 14 then
			mq.cmd('/doability Disarm')
		end
		if mq.TLO.Me.AltAbilityReady("Gut Punch")() then
			mq.cmd('/alt act 3732')
		end
		if not mq.TLO.Me.Song("Commanding Voice").ID() then
			mq.cmd('/doability "Commanding Voice"')
		end	
		if not mq.TLO.Me.Song("Full Moon's Champion Rk. III").ID() then
			mq.cmd("/doability \"Full Moon's Champion Rk. III\"")
		end
		if mq.TLO.Me.AltAbilityReady("Imperator's Command")() then
			mq.cmd('/alt act 2011')
		end
		if not mq.TLO.Me.Song("Battle Leap Warcry VI").ID() then
			mq.cmd('/alt act 611')
		end		
	end	
end

setup()
mq.imgui.init('MQ2LuaWar', buildWindow)

while keepAlive do
	CheckCombat()
	mq.delay(500)
end