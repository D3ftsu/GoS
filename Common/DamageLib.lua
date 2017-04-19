if DamageLibVersion then return end

DamageLibVersion = 0.49

if GetUser() ~= "Deftsu" then GetWebResultAsync("https://raw.githubusercontent.com/D3ftsu/GoS/master/Common/DamageLib.version", 
  function(data)
    if tonumber(data) > DamageLibVersion then
      DownloadFileAsync("https://raw.githubusercontent.com/D3ftsu/GoS/master/Common/DamageLib.lua", COMMON_PATH .. "DamageLib.lua", function() print("Updated DamageLib For "..GetGameVersion():sub(1,4)..", Please press F6 twice to reload.") return end)
    end
  end) 
end

--[[
It's designed to calculate the damage of the skills to champions, although most of the calculations work for creeps.
-------------------------------------------------------
Usage:
local target = GetCurrentTarget()
local damage = getdmg("R",target,source,3)
-------------------------------------------------------
Full function:
getdmg("SKILL",target,myHero,stagedmg,spelllvl)
]]

local DamageReductionTable = {
  ["Braum"] = {buff = "BraumShieldRaise", amount = function(target) return 1 - ({0.3, 0.325, 0.35, 0.375, 0.4})[GetCastLevel(target, _E)] end},
  ["Urgot"] = {buff = "urgotswapdef", amount = function(target) return 1 - ({0.3, 0.4, 0.5})[GetCastLevel(target, _R)] end},
  ["Alistar"] = {buff = "Ferocious Howl", amount = function(target) return ({0.5, 0.4, 0.3})[GetCastLevel(target, _R)] end},
  ["Amumu"] = {buff = "Tantrum", amount = function(target) return ({2, 4, 6, 8, 10})[GetCastLevel(target, _E)] end, damageType = 1},
  ["Galio"] = {buff = "GalioIdolOfDurand", amount = function(target) return 0.5 end},
  ["Garen"] = {buff = "GarenW", amount = function(target) return 0.7 end},
  ["Gragas"] = {buff = "GragasWSelf", amount = function(target) return ({0.1, 0.12, 0.14, 0.16, 0.18})[GetCastLevel(target, _W)] end},
  ["Annie"] = {buff = "MoltenShield", amount = function(target) return 1 - ({0.16,0.22,0.28,0.34,0.4})[GetCastLevel(target, _E)] end},
  ["Malzahar"] = {buff = "malzaharpassiveshield", amount = function(target) return 0.1 end}
}

_G.Ignite = (GetCastName(myHero, SUMMONER_1):lower():find("summonerdot") and SUMMONER_1 or (GetCastName(myHero, SUMMONER_2):lower():find("summonerdot") and SUMMONER_2 or nil))
_G.Smite = (GetCastName(myHero, SUMMONER_1):lower():find("smite") and SUMMONER_1 or (GetCastName(myHero, SUMMONER_2):lower():find("smite") and SUMMONER_2 or nil))

function string.ends(String,End)
  return End == "" or string.sub(String,-string.len(End)) == End
end

function GetHP(unit)
  return GetCurrentHP(unit)+GetDmgShield(unit)
end

function GetHP2(unit)
  return GetCurrentHP(unit)+GetDmgShield(unit)+GetMagicShield(unit)
end

function CalcPhysicalDamage(source, target, amount)
  local ArmorPenPercent = GetArmorPenPercent(source)
  local ArmorPenFlat = (0.4 + GetLevel(target) / 30) * GetArmorPenFlat(source)
  local BonusArmorPen = source.bonusArmorPenPercent

  if GetObjectType(source) == Obj_AI_Minion then
    ArmorPenPercent = 1
    ArmorPenFlat = 0
    BonusArmorPen = 1
  elseif GetObjectType(source) == Obj_AI_Turret then
    ArmorPenFlat = 0
    BonusArmorPen = 1
    if GetObjectName(source):find("3") or GetObjectName(source):find("4") then
      ArmorPenPercent = 0.25
    else
      ArmorPenPercent = 0.7
    end
  end

  if GetObjectType(source) == Obj_AI_Turret then
    if GetObjectType(target) == Obj_AI_Minion then
      amount = amount * 1.25
      if string.ends(GetObjectName(target), "MinionSiege") then
        amount = amount * 0.7
      end
      return amount
    end
  end

  local armor = GetArmor(target)
  local bonusArmor = GetArmor(target) - GetBaseArmor(target)
  local value = 100 / (100 + (armor * ArmorPenPercent) - (bonusArmor * (1 - BonusArmorPen)) - ArmorPenFlat)

  if armor < 0 then
    value = 2 - 100 / (100 - armor)
  elseif (armor * ArmorPenPercent) - (bonusArmor * (1 - BonusArmorPen)) - ArmorPenFlat < 0 then
    value = 1
  end
  return math.max(0, math.floor(DamageReductionMod(source, target, PassivePercentMod(source, target, value) * amount, 1)))
end

function CalcMagicalDamage(source, target, amount)
  local mr = GetMagicResist(target)
  local value = 100 / (100 + (mr * GetMagicPenPercent(source)) - GetMagicPenFlat(source))

  if mr < 0 then
    value = 2 - 100 / (100 - mr)
  elseif (mr * GetMagicPenPercent(source)) - GetMagicPenFlat(source) < 0 then
    value = 1
  end
  return math.max(0, math.floor(DamageReductionMod(source, target, PassivePercentMod(source, target, value) * amount, 2)))
end

function DamageReductionMod(source,target,amount,DamageType)
  if GetObjectType(source) == Obj_AI_Hero then
    if GotBuff(source, "Exhaust") > 0 then
      amount = amount * 0.6
    end
  end
 
  if GetObjectType(target) == Obj_AI_Hero then
    for i = 0, 63 do
      if GetBuffCount(target, i) > 0 then
        if GetBuffName(target, i) == "MasteryWardenOfTheDawn" then
          amount = amount * (1 - (0.06 * GetBuffCount(target, i)))
        end
    
        if DamageReductionTable[GetObjectName(target)] then
          if GetBuffName(target, i) == DamageReductionTable[GetObjectName(target)].buff and (not DamageReductionTable[GetObjectName(target)].damagetype or DamageReductionTable[GetObjectName(target)].damagetype == DamageType) then
            amount = amount * DamageReductionTable[GetObjectName(target)].amount(target)
          end
        end

        if GetObjectName(target) == "Maokai" and GetObjectType(source) ~= Obj_AI_Turret then
          if GetBuffName(target, i) == "MaokaiDrainDefense" then
            amount = amount * 0.8
          end
        end

        if GetObjectName(target) == "MasterYi" then
          if GetBuffName(target, i) == "Meditate" then
            amount = amount - amount * ({0.5, 0.55, 0.6, 0.65, 0.7})[GetCastLevel(target, _W)] / (GetObjectType(source) == Obj_AI_Turret and 2 or 1)
          end
        end
      end
    end

    if GetItemSlot(target, 1054) > 0 then
      amount = amount - 8
    end

    if GetObjectName(target) == "Kassadin" and DamageType == 2 then
      amount = amount * 0.85
    end

  end
  return amount
end

function PassivePercentMod(source, target, amount, damageType)
  local SiegeMinionList = {"Red_Minion_MechCannon", "Blue_Minion_MechCannon"}
  local NormalMinionList = {"Red_Minion_Wizard", "Blue_Minion_Wizard", "Red_Minion_Basic", "Blue_Minion_Basic"}

  if GetObjectType(source) == Obj_AI_Turret then
    if table.contains(SiegeMinionList, GetObjectName(target)) then
      amount = amount * 0.7
    elseif table.contains(NormalMinionList, GetObjectName(target)) then
      amount = amount * 1.14285714285714
    end
  end
  if GetObjectType(source) == Obj_AI_Hero then -- Masteries Feretorix(tm)
    if GetObjectType(target) == Obj_AI_Hero then
      if (GetItemSlot(source, 3036) > 0 or GetItemSlot(source, 3034) > 0) and GetMaxHP(source) < GetMaxHP(target) and damageType == 1 then
        amount = amount * (1 + math.min(GetMaxHP(target) - GetMaxHP(source), 500) / 50 * (GetItemSlot(source, 3036) > 0 and 0.015 or 0.01))
      end
    end
  end
  return amount
end

local DamageLibTable = {
  ["Aatrox"] = {
    {Slot = "Q", Stage = 1, DamageType = 1, Damage = function(source, target, level) return ({10, 35, 60, 95, 120})[level] + 1.1 * source.totalDamage end},
    {Slot = "W", Stage = 1, DamageType = 1, Damage = function(source, target, level) return ({45, 80, 115, 150, 185})[level] + 0.75 * GetBonusDmg(source) end},
    {Slot = "E", Stage = 1, DamageType = 1, Damage = function(source, target, level) return ({70, 110, 150, 190, 230})[level] + 0.7 * GetBonusDmg(source) end},
    {Slot = "R", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({200, 300, 400})[level] + GetBonusAP(source) end},
  },

  ["Ahri"] = {
    {Slot = "Q", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({40, 65, 90, 115, 140})[level] + 0.35 * GetBonusAP(source) end},
    {Slot = "Q", Stage = 2, DamageType = 3, Damage = function(source, target, level) return ({40, 65, 90, 115, 140})[level] + 0.35 * GetBonusAP(source) end},
    {Slot = "W", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({40, 65, 90, 115, 140})[level] + 0.4 * GetBonusAP(source) end},
    {Slot = "W", Stage = 2, DamageType = 2, Damage = function(source, target, level) return ({12, 19.5, 27, 34.5, 42})[level] + 0.12 * GetBonusAP(source) end},
    {Slot = "E", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({60, 95, 130, 165, 200})[level] + 0.50 * GetBonusAP(source) end},
    {Slot = "R", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({70, 110, 150})[level] + 0.3 * GetBonusAP(source) end},
  },

  ["Akali"] = {
    {Slot = "Q", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({35, 55, 75, 95, 115})[level] + 0.4 * GetBonusAP(source) end},
    {Slot = "Q", Stage = 2, DamageType = 2, Damage = function(source, target, level) return ({45, 70, 95, 120, 145})[level] + 0.5 * GetBonusAP(source) end},
    {Slot = "E", Stage = 1, DamageType = 1, Damage = function(source, target, level) return ({70, 100, 130, 160, 190})[level] + 0.6 * GetBonusAP(source) + 0.8 * GetBonusDmg(source) end},
    {Slot = "R", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({50, 100, 150})[level] + 0.35 * GetBonusAP(source) end},
  },

  ["Alistar"] = {
    {Slot = "Q", Stage = 1, DamageType = 1, Damage = function(source, target, level) return ({60, 105, 150, 195, 240})[level] + 0.5 * GetBonusAP(source) end},
    {Slot = "W", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({55, 110, 165, 220, 275})[level] + 0.7 * GetBonusAP(source) end},
  },

  ["Amumu"] = {
    {Slot = "Q", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({80, 130, 180, 230, 280})[level] + 0.7 * GetBonusAP(source) end},
    {Slot = "W", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({10, 15, 20, 25, 30})[level] + (({0.01, 0.0125, 0.015, 0.0175, 0.02})[level] + 0.01 * GetBonusAP(source) / 100) * GetMaxHP(target) end},
    {Slot = "E", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({75, 100, 125, 150, 175})[level] + 0.5 * GetBonusAP(source) end},
    {Slot = "R", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({150, 250, 350})[level] + 0.8 * GetBonusAP(source) end},
  },

  ["Anivia"] = {
    {Slot = "Q", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({60, 85, 110, 135, 160})[level] + 0.4 * GetBonusAP(source) end},
    {Slot = "Q", Stage = 2, DamageType = 2, Damage = function(source, target, level) return ({60, 90, 120, 150, 180})[level] * 2 + GetBonusAP(source) end},
    {Slot = "E", Stage = 1, DamageType = 2, Damage = function(source, target, level) return (({50, 75, 100, 125, 150})[level] + 0.5 * GetBonusAP(source)) * (GotBuff(target, "chilled") and 2 or 1) end},
    {Slot = "R", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({40, 60, 80})[level] + 0.125 * GetBonusAP(source) end},
    {Slot = "R", Stage = 2, DamageType = 2, Damage = function(source, target, level) return ({120, 180, 240})[level] + 0.375 * GetBonusAP(source) end},
  },

  ["Annie"] = {
    {Slot = "Q", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({80, 115, 150, 185, 220})[level] + 0.8 * GetBonusAP(source) end},
    {Slot = "W", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({70, 115, 160, 205, 250})[level] + 0.85 * GetBonusAP(source) end},
    {Slot = "R", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({210, 365, 520})[level] + 0.9 * GetBonusAP(source) end},
  },

  ["Ashe"] = {
    {Slot = "W", Stage = 1, DamageType = 1, Damage = function(source, target, level) return ({20, 35, 50, 65, 80})[level] + source.totalDamage end},
    {Slot = "R", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({250, 425, 600})[level] + GetBonusAP(source) end},
    {Slot = "R", Stage = 2, DamageType = 2, Damage = function(source, target, level) return (({200, 400, 600})[level] + GetBonusAP(source)) / 2 end},
  },

  ["AurelionSol"] = {
    {Slot = "Q", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({70, 110, 150, 190, 230})[level] + 0.65 * GetBonusAP(source) end},
    {Slot = "R", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({150, 250, 350})[level] + 0.7 * GetBonusAP(source) end},
  },
  
  ["Azir"] = {
    {Slot = "Q", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({65, 85, 105, 125, 145})[level] + 0.5 * GetBonusAP(source) end},
    {Slot = "W", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({55, 60, 75, 80, 90})[level] + 0.6 * GetBonusAP(source) end},
    {Slot = "E", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({80, 120, 160, 200, 240})[level] + 0.4 * GetBonusAP(source) end},
    {Slot = "R", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({150, 225, 300})[level] + 0.6 * GetBonusAP(source) end},
  },

  ["Blitzcrank"] = {
    {Slot = "Q", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({80, 135, 190, 245, 300})[level] + GetBonusAP(source) end},
    {Slot = "E", Stage = 1, DamageType = 1, Damage = function(source, target, level) return source.totalDamage end},
    {Slot = "R", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({250, 375, 500})[level] + GetBonusAP(source) end},
  },

  ["Bard"] = {
    {Slot = "Q", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({80, 125, 170, 215, 260})[level] + 0.65 * GetBonusAP(source) end},
  },

  ["Brand"] = {
    {Slot = "Q", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({80, 110, 140, 170, 200})[level] + 0.55 * GetBonusAP(source) end},
    {Slot = "W", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({75, 120, 165, 210, 255})[level] + 0.6 * GetBonusAP(source) end},
    {Slot = "E", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({70, 90, 110, 130, 150})[level] + 0.35 * GetBonusAP(source) end},
    {Slot = "R", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({100, 200, 300})[level] + 0.25 * GetBonusAP(source) end},
  },

  ["Braum"] = {
    {Slot = "Q", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({60, 105, 150, 195, 240})[level] + 0.025 * GetMaxHP(source) end},
    {Slot = "R", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({150, 250, 350})[level] + 0.6 * GetBonusAP(source) end},
  },

  ["Caitlyn"] = {
    {Slot = "Q", Stage = 1, DamageType = 1, Damage = function(source, target, level) return ({30, 70, 110, 150, 190})[level] + ({1.3, 1.4, 1.5, 1.6, 1.7})[level] * source.totalDamage end},
    {Slot = "E", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({70, 110, 150, 190, 230})[level] + 0.8 * GetBonusAP(source) end},
    {Slot = "R", Stage = 1, DamageType = 1, Damage = function(source, target, level) return ({250, 475, 700})[level] + 2 * source.totalDamage end},
  },

  ["Camille"] = {
    {Slot = "Q", Stage = 1, DamageType = 1, Damage = function(source, target, level) return ({0.2, 0.25, 0.3, 0.35, 0.4})[level] * source.totalDamage end},
    {Slot = "W", Stage = 1, DamageType = 1, Damage = function(source, target, level) return ({65, 95, 125, 155, 185})[level] + 0.6 * GetBonusDmg(source) end},    
    {Slot = "E", Stage = 1, DamageType = 1, Damage = function(source, target, level) return ({70, 115, 160, 205, 250})[level] + 0.75 * GetBonusDmg(source) end},
    {Slot = "R", Stage = 1, DamageType = 1, Damage = function(source, target, level) return ({5, 10, 15})[level] + ({0.04, 0.06, 0.08})[level] * GetCurrentHP(source) end},
  },

  ["Cassiopeia"] = {
    {Slot = "Q", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({75, 120, 165, 210, 255})[level] + 0.7 * GetBonusAP(source) end},
    {Slot = "W", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({20, 35, 50, 65, 80})[level] + 0.15 * GetBonusAP(source) end},
    {Slot = "E", Stage = 1, DamageType = 2, Damage = function(source, target, level) return 48 + 4 * GetLevel(source) + 0.1 * GetBonusAP(source) + (target.isPoisoned and ({10, 40, 70, 100, 130})[level] + 0.35 * GetBonusAP(source) or 0) end},
    {Slot = "R", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({150, 250, 350})[level] + 0.5 * GetBonusAP(source) end},
  },

  ["Chogath"] = {
    {Slot = "Q", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({80, 135, 190, 245, 305})[level] + GetBonusAP(source) end},
    {Slot = "W", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({75, 125, 175, 225, 275})[level] + 0.7 * GetBonusAP(source) end},
    {Slot = "E", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({20, 35, 50, 65, 80})[level] + 0.3 * GetBonusAP(source) end},
    {Slot = "R", Stage = 1, DamageType = 3, Damage = function(source, target, level) return ({300, 475, 650})[level] + 0.5 * GetBonusAP(source) end},
  },

  ["Corki"] = {
    {Slot = "Q", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({70, 115, 150, 205, 250})[level] + 0.5 * GetBonusAP(source) + 0.5 * source.totalDamage end},
    {Slot = "W", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({60, 90, 120, 150, 180})[level] + 0.4 * GetBonusAP(source) end},
    {Slot = "W", Stage = 2, DamageType = 2, Damage = function(source, target, level) return ({30, 45, 60, 75, 90})[level] + (1.5 * source.totalDamage) + 0.2 * GetBonusAP(source) end},
    {Slot = "E", Stage = 1, DamageType = 1, Damage = function(source, target, level) return ({20, 32, 44, 56, 68})[level] + 0.4 * source.totalDamage end},
    {Slot = "R", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({75, 100, 125})[level] + 0.2 * GetBonusAP(source) + ({0.15, 0.45, 0.75})[level] * source.totalDamage end},
    {Slot = "R", Stage = 2, DamageType = 2, Damage = function(source, target, level) return ({150, 200, 250})[level] + 0.4 * GetBonusAP(source) + ({0.3, 0.90, 1.5})[level] * source.totalDamage end},
  },

  ["Darius"] = {
    {Slot = "Q", Stage = 1, DamageType = 1, Damage = function(source, target, level) return ({40, 70, 100, 130, 160})[level] + (({0.5, 1.1, 1.2, 1.3, 1.4})[level] * source.totalDamage) end},
    {Slot = "W", Stage = 1, DamageType = 1, Damage = function(source, target, level) return 0.4 * source.totalDamage end},
    {Slot = "R", Stage = 1, DamageType = 3, Damage = function(source, target, level) return ({100, 200, 300})[level] + 0.75 * GetBonusDmg(source) end},
  },

  ["Diana"] = {
    {Slot = "Q", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({60, 95, 130, 165, 200})[level] + 0.7 * GetBonusAP(source) end},
    {Slot = "W", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({22, 34, 46, 58, 70})[level] + 0.2 * GetBonusAP(source) end},
    {Slot = "R", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({100, 160, 220})[level] + 0.6 * GetBonusAP(source) end},
  },

  ["DrMundo"] = {
    {Slot = "Q", Stage = 1, DamageType = 2, Damage = function(source, target, level) if GetObjectType(target) == Obj_AI_Minion then return math.min(({300, 350, 400, 450, 500})[level],math.max(({80, 130, 180, 230, 280})[level], ({15, 17.5, 20, 22.5, 25})[level] / 100 * GetCurrentHP(target))) end; return math.max(({80, 130, 180, 230, 280})[level],({15, 17.5, 20, 22.5, 25})[level] / 100 * GetCurrentHP(target)) end},
    {Slot = "W", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({35, 50, 65, 80, 95})[level] + 0.2 * GetBonusAP(source) end}
  },

  ["Draven"] = {
    {Slot = "Q", Stage = 1, DamageType = 1, Damage = function(source, target, level) return ({30, 35, 40, 45, 50})[level] + ({65, 75, 85, 95, 105})[level] / 100 * GetBonusDmg(source) end},
    {Slot = "E", Stage = 1, DamageType = 1, Damage = function(source, target, level) return ({70, 105, 140, 175, 210})[level] + 0.5 * source.totalDamage end},
    {Slot = "R", Stage = 1, DamageType = 1, Damage = function(source, target, level) return ({175, 275, 375})[level] + 1.1 * source.totalDamage end},
  },

  ["Ekko"] = {
    {Slot = "Q", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({60, 75, 90, 105, 120})[level] + 0.3 * GetBonusAP(source) end},
    {Slot = "Q", Stage = 2, DamageType = 2, Damage = function(source, target, level) return ({40, 65, 90, 115, 140})[level] + 0.6 * GetBonusAP(source) end},
    {Slot = "W", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({150, 195, 240, 285, 330})[level] + 0.8 * GetBonusAP(source) end},
    {Slot = "E", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({50, 80, 110, 140, 170})[level] + 0.2 * GetBonusAP(source) end},
    {Slot = "R", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({150, 300, 450})[level] + 1.5 * GetBonusAP(source) end}
  },

  ["Elise"] = {
    {Slot = "Q", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({40, 75, 110, 145, 180})[level] + (0.08 + 0.03 / 100 * GetBonusAP(source)) * GetCurrentHP(target) end},
    {Slot = "QM", Stage = 2, DamageType = 2, Damage = function(source, target, level) return ({60, 100, 140, 180, 220})[level] + (0.08 + 0.03 / 100 * GetBonusAP(source)) * (GetMaxHP(target) - GetCurrentHP(target)) end},
    {Slot = "W", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({75, 125, 175, 225, 275})[level] + 0.8 * GetBonusAP(source) end},
  },

  ["Evelynn"] = {
    {Slot = "Q", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({40, 50, 60, 70, 80})[level] + ({35, 40, 45, 50, 55})[level] / 100 * GetBonusAP(source) + ({50, 55, 60, 65, 70})[level] / 100 * source.totalDamage end},
    {Slot = "E", Stage = 1, DamageType = 1, Damage = function(source, target, level) return ({70, 110, 150, 190, 230})[level] + GetBonusAP(source) + source.totalDamage end},
    {Slot = "R", Stage = 1, DamageType = 2, Damage = function(source, target, level) return (({0.15, 0.20, 0.25})[level] + 0.01 / 100 * GetBonusAP(source)) * GetCurrentHP(target) end},
  },

  ["Ezreal"] = {
    {Slot = "Q", Stage = 1, DamageType = 1, Damage = function(source, target, level) return ({35, 55, 75, 95, 115})[level] + 0.4 * GetBonusAP(source) + 1.1 * source.totalDamage end},
    {Slot = "W", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({70, 115, 160, 205, 250})[level] + 0.8 * GetBonusAP(source) end},
    {Slot = "E", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({75, 125, 175, 225, 275})[level] + 0.75 * GetBonusAP(source) + 0.5 * source.totalDamage end},
    {Slot = "R", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({350, 500, 650})[level] + 0.9 * GetBonusAP(source) + source.totalDamage end},
  },

  ["Fiddlesticks"] = {
    {Slot = "W", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({80, 105, 130, 155, 180})[level] + 0.45 * GetBonusAP(source) end},
    {Slot = "E", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({65, 85, 105, 125, 145})[level] + 0.45 * GetBonusAP(source) end},
    {Slot = "R", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({125, 225, 325})[level] + 0.45 * GetBonusAP(source) end},
  },

  ["Fiora"] = {
    {Slot = "Q", Stage = 1, DamageType = 1, Damage = function(source, target, level) return ({65, 75, 85, 95, 105})[level] + ({0.95, 1, 1.05, 1.1, 1.15})[level] * source.totalDamage end},
    {Slot = "W", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({90, 130, 170, 210, 250})[level] + GetBonusAP(source) end},
  },

  ["Fizz"] = {
    {Slot = "Q", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({10, 25, 40, 55, 70})[level] + 0.55 * GetBonusAP(source) end},
    {Slot = "W", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({25, 40, 55, 70, 85})[level] + 0.3 * GetBonusAP(source) end},
    {Slot = "E", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({70, 120, 170, 220, 270})[level] + 0.75 * GetBonusAP(source) end},
    {Slot = "R", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({150, 250, 350})[level] + 0.6 * GetBonusAP(source) end},
    {Slot = "R", Stage = 2, DamageType = 2, Damage = function(source, target, level) return ({225, 325, 425})[level] + 0.8 * GetBonusAP(source) end},
    {Slot = "R", Stage = 3, DamageType = 2, Damage = function(source, target, level) return ({300, 400, 500})[level] + 1.2 * GetBonusAP(source) end},
  },

  ["Galio"] = {
    {Slot = "Q", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({80, 135, 190, 245, 300})[level] + 0.6 * GetBonusAP(source) end},
    {Slot = "E", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({60, 105, 150, 195, 240})[level] + 0.5 * GetBonusAP(source) end},
    {Slot = "R", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({360, 540, 720})[level] + GetBonusAP(source) end},
  },

  ["Gangplank"] = {
    {Slot = "Q", Stage = 1, DamageType = 1, Damage = function(source, target, level) return ({20, 45, 70, 95, 120})[level] + source.totalDamage end},
    {Slot = "R", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({35, 60, 85})[level] + 0.1 * GetBonusAP(source) end},
  },

  ["Garen"] = {
    {Slot = "Q", Stage = 1, DamageType = 1, Damage = function(source, target, level) return ({30, 55, 80, 105, 130})[level] + 1.4 * source.totalDamage end},
    {Slot = "E", Stage = 1, DamageType = 1, Damage = function(source, target, level) return ({20, 45, 70, 95, 120})[level] + ({70, 80, 90, 100, 110})[level] / 100 * source.totalDamage end},
    {Slot = "R", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({175, 350, 525})[level] + ({28.57, 33.33, 40})[level] / 100 * (GetMaxHP(target) - GetCurrentHP(target)) end},
  },

  ["Gnar"] = {
    {Slot = "Q", Stage = 1, DamageType = 1, Damage = function(source, target, level) return ({5, 35, 65, 95, 125})[level] + 1.15 * source.totalDamage end},
    {Slot = "QM", Stage = 2, DamageType = 1, Damage = function(source, target, level) return ({5, 45, 85, 125, 165})[level] + 1.2 * source.totalDamage end},
    {Slot = "W", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({10, 20, 30, 40, 50})[level] + GetBonusAP(source) + ({6, 8, 10, 12, 14})[level] / 100 * GetMaxHP(target) end},
    {Slot = "WM", Stage = 2, DamageType = 1, Damage = function(source, target, level) return ({25, 45, 65, 85, 105})[level] + source.totalDamage end},
    {Slot = "E", Stage = 1, DamageType = 1, Damage = function(source, target, level) return ({20, 60, 100, 140, 180})[level] + GetMaxHP(source) * 0.06 end},
    {Slot = "EM", Stage = 2, DamageType = 1, Damage = function(source, target, level) return ({20, 60, 100, 140, 180})[level] + GetMaxHP(source) * 0.06 end},
    {Slot = "R", Stage = 1, DamageType = 1, Damage = function(source, target, level) return ({200, 300, 400})[level] + 0.5 * GetBonusAP(source) + 0.2 * source.totalDamage end},
  },

  ["Gragas"] = {
    {Slot = "Q", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({80, 120, 160, 200, 240})[level] + 0.6 * GetBonusAP(source) end},
    {Slot = "W", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({20, 50, 80, 110, 140})[level] + 8 / 100 * GetMaxHP(target) + 0.3 * GetBonusAP(source) end},
    {Slot = "E", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({80, 130, 180, 230, 280})[level] + 0.6 * GetBonusAP(source) end},
    {Slot = "R", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({200, 300, 400})[level] + 0.7 * GetBonusAP(source) end},
  },

  ["Graves"] = {
    {Slot = "Q", Stage = 1, DamageType = 1, Damage = function(source, target, level) return ({55, 70, 85, 100, 115})[level] + 0.75 * source.totalDamage end},
    {Slot = "Q", Stage = 2, DamageType = 1, Damage = function(source, target, level) return ({80, 125, 170, 215, 260})[level] + ({0.4, 0.6, 0.8, 1, 1.2})[level] * source.totalDamage end},
    {Slot = "W", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({60, 110, 160, 210, 260})[level] + 0.6 * GetBonusAP(source) end},
    {Slot = "R", Stage = 1, DamageType = 1, Damage = function(source, target, level) return ({250, 400, 550})[level] + 1.5 * source.totalDamage end},
  },

  ["Hecarim"] = {
    {Slot = "Q", Stage = 1, DamageType = 1, Damage = function(source, target, level) return ({50, 85, 120, 155, 190})[level] + 0.6 * source.totalDamage end},
    {Slot = "W", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({20, 30, 40, 50, 60})[level] + 0.2 * GetBonusAP(source) end},
    {Slot = "E", Stage = 1, DamageType = 1, Damage = function(source, target, level) return ({40, 75, 110, 145, 180})[level] + 0.5 * source.totalDamage end},
    {Slot = "R", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({150, 250, 350})[level] + GetBonusAP(source) end},
  },

  ["Heimerdinger"] = {
    {Slot = "W", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({60, 90, 120, 150, 180})[level] + 0.45 * GetBonusAP(source) end},
    {Slot = "W", Stage = 2, DamageType = 2, Damage = function(source, target, level) return ({135, 180, 225})[GetCastLevel(source, _R)] + 0.45 * GetBonusAP(source) end},
    {Slot = "E", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({60, 100, 140, 180, 220})[level] + 0.6 * GetBonusAP(source) end},
    {Slot = "E", Stage = 2, DamageType = 2, Damage = function(source, target, level) return ({150, 200, 250})[GetCastLevel(source, _R)] + 0.6 * GetBonusAP(source) end},
  },

  ["Irelia"] = {
    {Slot = "Q", Stage = 1, DamageType = 1, Damage = function(source, target, level) return ({20, 50, 80, 110, 140})[level] + 1.2 * source.totalDamage end},
    {Slot = "W", Stage = 1, DamageType = 3, Damage = function(source, target, level) return ({15, 30, 45, 60, 75})[level] end},
    {Slot = "E", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({80, 120, 160, 200, 240})[level] + 0.5 * GetBonusAP(source) end},
    {Slot = "R", Stage = 1, DamageType = 1, Damage = function(source, target, level) return ({80, 120, 160})[level] + 0.5 * GetBonusAP(source) + 0.7 * source.totalDamage end},
  },

  ["Janna"] = {
    {Slot = "Q", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({60, 85, 110, 135, 160})[level] + 0.35 * GetBonusAP(source) end},
    {Slot = "W", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({60, 115, 170, 225, 280})[level] + 0.5 * GetBonusAP(source) end},
  },

  ["JarvanIV"] = {
    {Slot = "Q", Stage = 1, DamageType = 1, Damage = function(source, target, level) return ({70, 115, 160, 205, 250})[level] + 1.2 * source.totalDamage end},
    {Slot = "E", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({60, 105, 150, 195, 240})[level] + 0.8 * GetBonusAP(source) end},
    {Slot = "R", Stage = 1, DamageType = 1, Damage = function(source, target, level) return ({200, 325, 450})[level] + 1.5 * source.totalDamage end},
  },

  ["Jax"] = {
    {Slot = "Q", Stage = 1, DamageType = 1, Damage = function(source, target, level) return ({70, 110, 150, 190, 230})[level] + source.totalDamage + 0.6 * GetBonusAP(source) end},
    {Slot = "W", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({40, 75, 110, 145, 180})[level] + 0.6 * GetBonusAP(source) end},
    {Slot = "E", Stage = 1, DamageType = 1, Damage = function(source, target, level) return ({50, 75, 100, 125, 150})[level] + 0.5 * source.totalDamage end},
    {Slot = "R", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({100, 160, 220})[level] + 0.7 * GetBonusAP(source) end},
  },

  ["Jayce"] = {
    {Slot = "Q", Stage = 1, DamageType = 1, Damage = function(source, target, level) return ({70, 120, 170, 220, 270, 320})[level] + 1.2 * source.totalDamage end},
    {Slot = "QM", Stage = 2, DamageType = 1, Damage = function(source, target, level) return ({35, 70, 105, 140, 175, 210})[level] + source.totalDamage end},
    {Slot = "W", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({25, 40, 55, 70, 85, 100})[level] + 0.25 * GetBonusAP(source) end},
    {Slot = "E", Stage = 1, DamageType = 2, Damage = function(source, target, level) return (({8, 10.4, 12.8, 15.2, 17.6, 20})[level] / 100) * GetMaxHP(target) + source.totalDamage end},
    {Slot = "R", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({20, 60, 100, 140})[level] + 0.25 * GetBonusDmg(source) end},
  },

  ["Jhin"] = {
    {Slot = "Q", Stage = 1, DamageType = 1, Damage = function(source, target, level) return ({50, 75, 100, 125, 150})[level] + ({0.3, 0.35, 0.4, 0.45, 0.5})[level] * source.totalDamage + 0.6 * GetBonusAP(source) end},
    {Slot = "W", Stage = 1, DamageType = 1, Damage = function(source, target, level) return ({50, 85, 120, 155, 190})[level] + 0.5 * source.totalDamage end},
    {Slot = "E", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({20, 80, 140, 200, 260})[level] + 1.20 * source.totalDamage + GetBonusAP(source) end},
    {Slot = "R", Stage = 1, DamageType = 1, Damage = function(source, target, level) return ({40, 100, 160})[level] + 0.2 * source.totalDamage * (1 + (100 - GetPercentHP(target)) * 1.025) end},
    {Slot = "R", Stage = 2, DamageType = 1, Damage = function(source, target, level) return ({40, 100, 160})[level] + 0.2 * source.totalDamage * (1 + (100 - GetPercentHP(target)) * 1.025) * 2 end}, -- GetCritDamage..
  },

  ["Jinx"] = {
    {Slot = "Q", Stage = 1, DamageType = 1, Damage = function(source, target, level) return 0.1 * source.totalDamage end},
    {Slot = "W", Stage = 1, DamageType = 1, Damage = function(source, target, level) return ({10, 60, 110, 160, 210})[level] + 1.4 * source.totalDamage end},
    {Slot = "E", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({70, 120, 170, 220, 270})[level] + GetBonusAP(source) end},
    {Slot = "R", Stage = 1, DamageType = 1, Damage = function(source, target, level) return ({25, 35, 45})[level] + ({25, 30, 35})[level] / 100 * (GetMaxHP(target) - GetCurrentHP(target)) + 0.15 * source.totalDamage end},
    {Slot = "R", Stage = 2, DamageType = 1, Damage = function(source, target, level) return ({250, 350, 450})[level] + ({25, 30, 35})[level] / 100 * (GetMaxHP(target) - GetCurrentHP(target)) + 1.5 * source.totalDamage end},
  },

  ["Karma"] = {
    {Slot = "Q", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({80, 125, 170, 215, 260})[level] + 0.6 * GetBonusAP(source) end},
    {Slot = "Q", Stage = 2, DamageType = 2, Damage = function(source, target, level) return ({80, 125, 170, 215, 260})[level] + ({25, 75, 125, 175})[GetCastLevel(source, _R)] + 0.9 * GetBonusAP(source) end},
    {Slot = "W", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({60, 110, 160, 210, 260})[level] + 0.9 * GetBonusAP(source) end},
    {Slot = "W", Stage = 2, DamageType = 2, Damage = function(source, target, level) return ({60, 110, 160, 210, 260})[level] + 0.9 * GetBonusAP(source) end},
  },

  ["Karthus"] = {
    {Slot = "Q", Stage = 1, DamageType = 2, Damage = function(source, target, level) return (({40, 60, 80, 100, 120})[level] + 0.3 * GetBonusAP(source)) * 2 end},
    {Slot = "Q", Stage = 2, DamageType = 2, Damage = function(source, target, level) return ({40, 60, 80, 100, 120})[level] + 0.3 * GetBonusAP(source) end},
    {Slot = "E", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({30, 50, 70, 90, 110})[level] + 0.2 * GetBonusAP(source) end},
    {Slot = "R", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({250, 400, 550})[level] + 0.6 * GetBonusAP(source) end},
  },

  ["Kassadin"] = {
    {Slot = "Q", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({65, 95, 125, 155, 185})[level] + 0.7 * GetBonusAP(source) end},
    {Slot = "W", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({40, 65, 90, 115, 140})[level] + 0.6 * GetBonusAP(source) end},
    {Slot = "W", Stage = 2, DamageType = 2, Damage = function(source, target, level) return 20 + 0.1 * GetBonusAP(source) end},
    {Slot = "E", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({80, 105, 130, 155, 180})[level] + 0.7 * GetBonusAP(source) end},
    {Slot = "R", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({80, 100, 120})[level] + 0.3 * GetBonusAP(source) end},
    {Slot = "R", Stage = 2, DamageType = 2, Damage = function(source, target, level) return ({40, 50, 60})[level] + 0.1 * GetBonusAP(source) end},
  },

  ["Katarina"] = {
    {Slot = "Q", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({75, 105, 135, 165, 195})[level] + 0.3 * GetBonusAP(source) end},
    {Slot = "E", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({30, 45, 60, 75, 90})[level] + 0.25 * GetBonusAP(source) + 0.5 * source.totalDamage end},
    {Slot = "R", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({25, 37.5, 50})[level] + 0.22 * GetBonusDmg(source) + 0.19 * GetBonusAP(source) end},
    {Slot = "R", Stage = 2, DamageType = 2, Damage = function(source, target, level) return ({375, 562.5, 750})[level] + 3.3 * GetBonusDmg(source) + 2.85 * GetBonusAP(source) end},
  },

  ["Kayle"] = {
    {Slot = "Q", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({60, 110, 160, 210, 260})[level] + source.totalDamage + 0.6 * GetBonusAP(source) end},
    {Slot = "E", Stage = 1, DamageType = 2, Damage = function(source, target, level) return GotBuff(source, "judicatorrighteousfury") > 0 and ({20, 30, 40, 50, 60})[level] + 0.30 * GetBonusAP(source) or ({10, 15, 20, 25, 30})[level] + 0.15 * GetBonusAP(source) end},
  },

  ["Kennen"] = {
    {Slot = "Q", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({75, 115, 155, 195, 235})[level] + 0.75 * GetBonusAP(source) end},
    {Slot = "W", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({40, 50, 60, 70, 80})[level] / 100 * source.totalDamage end},
    {Slot = "W", Stage = 2, DamageType = 2, Damage = function(source, target, level) return ({65, 95, 125, 155, 185})[level] + 0.55 * GetBonusAP(source) end},
    {Slot = "E", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({85, 125, 165, 205, 245})[level] + 0.6 * GetBonusAP(source) end},
    {Slot = "R", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({40, 75, 110})[level] + 0.2 * GetBonusAP(source) end},
  },

  ["Khazix"] = {
    {Slot = "Q", Stage = 1, DamageType = 1, Damage = function(source, target, level) return ({70, 95, 120, 145, 170})[level] + 1.2 * GetBonusDmg(source) end},
    {Slot = "Q", Stage = 2, DamageType = 1, Damage = function(source, target, level) return ({105, 142.5, 180, 217.5, 255})[level] + 1.56 * source.totalDamage end},
    {Slot = "Q", Stage = 3, DamageType = 1, Damage = function(source, target, level) return ({70, 95, 120, 145, 170})[level] + 2.24 * source.totalDamage + 10 * GetLevel(source) end},
    {Slot = "Q", Stage = 4, DamageType = 1, Damage = function(source, target, level) return ({105, 142.5, 180, 217.5, 255})[level] + 2.6 * source.totalDamage + 10 * GetLevel(source) end},
    {Slot = "W", Stage = 1, DamageType = 1, Damage = function(source, target, level) return ({80, 110, 140, 170, 200})[level] + source.totalDamage end},
    {Slot = "E", Stage = 1, DamageType = 1, Damage = function(source, target, level) return ({65, 100, 135, 170, 205})[level] + 0.2 * source.totalDamage end},
  },

  ["Kogmaw"] = {
    {Slot = "Q", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({80, 130, 180, 230, 280})[level] + 0.5 * GetBonusAP(source) end},
    {Slot = "W", Stage = 1, DamageType = 2, Damage = function(source, target, level) local dmg = (({0.03, 0.04, 0.05, 0.06, 0.07})[level] + (0.01*GetBonusAP(source))) * GetMaxHP(target) ; if GetObjectType(target) == Obj_AI_Minion and dmg > 100 then dmg = 100 end ; return dmg end},
    {Slot = "E", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({60, 105, 150, 195, 240})[level] + 0.5 * GetBonusAP(source) end},
    {Slot = "R", Stage = 1, DamageType = 2, Damage = function(source, target, level) return (({100, 140, 180})[level] + 0.65 * source.totalDamage + 0.25 * GetBonusAP(source)) * (GetPercentHP(target) < 25 and 3 or (GetPercentHP(target) < 50 and 2 or 1)) end},
  },

  ["Kalista"] = {
    {Slot = "Q", Stage = 1, DamageType = 1, Damage = function(source, target, level) return ({10, 70, 130, 190, 250})[level] + source.totalDamage end},
    {Slot = "W", Stage = 1, DamageType = 2, Damage = function(source, target, level) return (({12, 14, 16, 18, 20})[level] / 100) * GetMaxHP(target) end},
    {Slot = "E", Stage = 1, DamageType = 1, Damage = function(source, target, level) local count = GotBuff(target, "kalistaexpungemarker") if count > 0 then return (({20, 30, 40, 50, 60})[level] + 0.6* (source.totalDamage)) + ((count - 1)*(({10, 14, 19, 25, 32})[level]+({0.2, 0.225, 0.25, 0.275, 0.3})[level] * (source.totalDamage))) end; return 0 end},
  },

  ["Kindred"] = {
    {Slot = "Q", Stage = 1, DamageType = 1, Damage = function(source, target, level) return ({55, 75, 95, 115, 135})[level] + source.totalDamage * 0.2 end},
    {Slot = "W", Stage = 1, DamageType = 1, Damage = function(source, target, level) return ({25, 30, 35, 40, 45})[level] + source.totalDamage * 0.4 end},
    {Slot = "E", Stage = 1, DamageType = 1, Damage = function(source, target, level) return ({40, 75, 110, 145, 180})[level] + source.totalDamage * 0.2 + GetMaxHP(target) * 0.05 end},
  },

  ["Leblanc"] = {
    {Slot = "Q", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({55, 90, 125, 160, 195})[level] + 0.5 * GetBonusAP(source) end},
    {Slot = "W", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({40, 55, 70, 85, 100})[level] + 0.2 * GetBonusAP(source) end},
    {Slot = "E", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({40, 60, 80, 100, 120})[level] + 0.5 * GetBonusAP(source) end},
  },

  ["LeeSin"] = {
    {Slot = "Q", Stage = 1, DamageType = 1, Damage = function(source, target, level) return ({50, 80, 110, 140, 170})[level] + 0.9 * source.totalDamage end},
    {Slot = "Q", Stage = 2, DamageType = 1, Damage = function(source, target, level) return ({50, 80, 110, 140, 170})[level] + 0.9 * source.totalDamage + 0.08 * (GetMaxHP(target) - GetCurrentHP(target)) end},
    {Slot = "E", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({60, 95, 130, 165, 200})[level] + source.totalDamage end},
    {Slot = "R", Stage = 1, DamageType = 1, Damage = function(source, target, level) return ({150, 300,450})[level] + 2 * GetBonusDmg(source) end},
  },

  ["Leona"] = {
    {Slot = "Q", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({30, 55, 80, 105, 130})[level] + 0.3 * GetBonusAP(source) end},
    {Slot = "W", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({60, 100, 140, 180, 220})[level] + 0.4 * GetBonusAP(source) end},
    {Slot = "E", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({60, 100, 140, 180, 220})[level] + 0.4 * GetBonusAP(source) end},
    {Slot = "R", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({100, 175, 250})[level] + 0.8 * GetBonusAP(source) end},
  },

  ["Lissandra"] = {
    {Slot = "Q", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({70, 100, 130, 160, 190})[level] + 0.7 * GetBonusAP(source) end},
    {Slot = "W", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({70, 110, 150, 190, 230})[level] + 0.4 * GetBonusAP(source) end},
    {Slot = "E", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({70, 115, 160, 205, 250})[level] + 0.6 * GetBonusAP(source) end},
    {Slot = "R", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({150, 250, 350})[level] + 0.7 * GetBonusAP(source) end},
  },

  ["Lucian"] = {
    {Slot = "Q", Stage = 1, DamageType = 1, Damage = function(source, target, level) return ({80, 115, 150, 185, 220})[level] + ({0.6, 0.7, 0.8, 0.9, 1})[level] * source.totalDamage end},
    {Slot = "W", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({60, 100, 140, 180, 220})[level] + 0.9 * GetBonusAP(source) end},
    {Slot = "R", Stage = 1, DamageType = 1, Damage = function(source, target, level) return ({40, 50, 60})[level] + 0.1 * GetBonusAP(source) + 0.25 * source.totalDamage end},
  },

  ["Lulu"] = {
    {Slot = "Q", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({80, 125, 170, 215, 260})[level] + 0.5 * GetBonusAP(source) end},
    {Slot = "E", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({80, 110, 140, 170, 200})[level] + 0.4 * GetBonusAP(source) end},
  },

  ["Lux"] = {
    {Slot = "Q", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({50, 100, 150, 200, 250})[level] + 0.7 * GetBonusAP(source) end},
    {Slot = "E", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({60, 105, 150, 195, 240})[level] + 0.6 * GetBonusAP(source) end},
    {Slot = "R", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({300, 400, 500})[level] + 0.75 * GetBonusAP(source) end},
  },

  ["Malphite"] = {
    {Slot = "Q", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({70, 120, 170, 220, 270})[level] + 0.6 * GetBonusAP(source) end},
    {Slot = "W", Stage = 1, DamageType = 1, Damage = function(source, target, level) return ({30, 38, 46, 54, 62})[level] / 100 * source.totalDamage + 0.15 * (GetArmor(source) - GetBaseArmor(source)) end},
    {Slot = "E", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({60, 100, 140, 180, 220})[level] + 0.3 * GetArmor(source) + 0.2 * GetBonusAP(source) end},
    {Slot = "R", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({200, 300, 400})[level] + GetBonusAP(source) end},
  },

  ["Malzahar"] = {
    {Slot = "Q", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({70, 110, 150, 190, 230})[level] + 0.7 * GetBonusAP(source) end},
    {Slot = "W", Stage = 1, DamageType = 2, Damage = function(source, target, level) return (({4, 4.5, 5, 5.5, 6})[level] / 100 + 0.01 / 100 * GetBonusAP(source)) * GetMaxHP(target) end},
    {Slot = "E", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({80, 115, 150, 185, 220})[level] + 0.7 * GetBonusAP(source) end},
    {Slot = "R", Stage = 1, DamageType = 2, Damage = function(source, target, level) return 2.5 * (({6, 8, 10})[level] / 100 + 0.015 * GetBonusAP(source) / 100) * GetMaxHP(target) end},
  },

  ["Maokai"] = {
    {Slot = "Q", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({70, 115, 160, 205, 250})[level] + 0.4 * GetBonusAP(source) end},
    {Slot = "W", Stage = 1, DamageType = 2, Damage = function(source, target, level) return (({9, 10, 11, 12, 13})[level] / 100 + 0.03 / 100 * GetBonusAP(source)) * GetMaxHP(target) end},
    {Slot = "E", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({40, 60, 80, 100, 120})[level] + 0.4 * GetBonusAP(source) end},
    {Slot = "E", Stage = 2, DamageType = 2, Damage = function(source, target, level) return ({80, 120, 160, 200, 240})[level] + 0.6 * GetBonusAP(source) end},
    {Slot = "R", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({100, 150, 200})[level] + 0.5 * GetBonusAP(source) end},
  },

  ["MasterYi"] = {
    {Slot = "Q", Stage = 1, DamageType = 1, Damage = function(source, target, level) return ({25, 60, 95, 130, 165})[level] + source.totalDamage + 0.6 * source.totalDamage end},
    {Slot = "E", Stage = 1, DamageType = 3, Damage = function(source, target, level) return ({10, 12.5, 15, 17.5, 20})[level] / 100 * source.totalDamage + ({14, 23, 32, 41, 50})[level] end},
  },

  ["MissFortune"] = {
    {Slot = "Q", Stage = 1, DamageType = 1, Damage = function(source, target, level) return ({20, 40, 60, 80, 100})[level] + 0.35 * GetBonusAP(source) + source.totalDamage end},
    {Slot = "W", Stage = 1, DamageType = 2, Damage = function(source, target, level) return 0.06 * source.totalDamage end},
    {Slot = "E", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({80, 115, 150, 185, 220})[level] + 0.8 * GetBonusAP(source) end},
    {Slot = "R", Stage = 1, DamageType = 1, Damage = function(source, target, level) return 0.75 * source.totalDamage + 0.2 * GetBonusAP(source) end},
  },

  ["MonkeyKing"] = {
    {Slot = "Q", Stage = 1, DamageType = 1, Damage = function(source, target, level) return ({30, 60, 90, 120, 150})[level] + 0.1 * source.totalDamage end},
    {Slot = "W", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({70, 115, 160, 205, 250})[level] + 0.6 * GetBonusAP(source) end},
    {Slot = "E", Stage = 1, DamageType = 1, Damage = function(source, target, level) return ({60, 105, 150, 195, 240})[level] + 0.8 * source.totalDamage end},
    {Slot = "R", Stage = 1, DamageType = 1, Damage = function(source, target, level) return ({20, 110, 200})[level] + 1.1 * source.totalDamage end},
  },

  ["Mordekaiser"] = {
    {Slot = "Q", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({80, 110, 140, 170, 200})[level] + source.totalDamage + 0.4 * GetBonusAP(source) end},
    {Slot = "W", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({24, 38, 52, 66, 80})[level] + 0.2 * GetBonusAP(source) end},
    {Slot = "E", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({70, 115, 160, 205, 250})[level] + 0.6 * GetBonusAP(source) end},
    {Slot = "R", Stage = 1, DamageType = 2, Damage = function(source, target, level) return (({24, 29, 34})[level] / 100 + 0.04 / 100 * GetBonusAP(source)) * GetMaxHP(target) end},
  },

  ["Morgana"] = {
    {Slot = "Q", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({80, 135, 190, 245, 300})[level] + 0.9 * GetBonusAP(source) end},
    {Slot = "W", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({8, 16, 24, 32, 40})[level] + 0.11 * GetBonusAP(source) end},
    {Slot = "R", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({150, 225, 300})[level] + 0.7 * GetBonusAP(source) end},
  },

  ["Nami"] = {
    {Slot = "Q", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({75, 130, 185, 240, 295})[level] + 0.5 * GetBonusAP(source) end},
    {Slot = "W", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({70, 110, 150, 190, 230})[level] + 0.5 * GetBonusAP(source) end},
    {Slot = "E", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({25, 40, 55, 70, 85})[level] + 0.2 * GetBonusAP(source) end},
    {Slot = "R", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({150, 250, 350})[level] + 0.6 * GetBonusAP(source) end},
  },

  ["Nasus"] = {
    {Slot = "Q", Stage = 1, DamageType = 1, Damage = function(source, target, level) return GetBuffData(source, "nasusqstacks").Stacks + ({30, 50, 70, 90, 110})[level] end},
    {Slot = "E", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({55, 95, 135, 175, 215})[level] + 0.6 * GetBonusAP(source) end},
    {Slot = "E", Stage = 2, DamageType = 2, Damage = function(source, target, level) return ({11, 19, 27, 35, 43})[level] + 0.12 * GetBonusAP(source) end},
    {Slot = "R", Stage = 1, DamageType = 2, Damage = function(source, target, level) return (({3, 4, 5})[level] / 100 + 0.01 / 100 * GetBonusAP(source)) * GetMaxHP(target) end},
  },

  ["Nautilus"] = {
    {Slot = "Q", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({60, 105, 150, 195, 240})[level] + 0.75 * GetBonusAP(source) end},
    {Slot = "W", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({30, 40, 50, 60, 70})[level] + 0.4 * GetBonusAP(source) end},
    {Slot = "E", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({60, 100, 140, 180, 220})[level] + 0.3 * GetBonusAP(source) end},
    {Slot = "R", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({200, 325, 450})[level] + 0.8 * GetBonusAP(source) end},
    {Slot = "R", Stage = 2, DamageType = 2, Damage = function(source, target, level) return ({125, 175, 225})[level] + 0.4 * GetBonusAP(source) end},
  },

  ["Nidalee"] = {
    {Slot = "Q", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({70, 85, 100, 115, 130})[level] + 0.4 * GetBonusAP(source) end},
    {Slot = "QM", Stage = 2, DamageType = 2, Damage = function(source, target, level) local dmg = (({5, 30, 55, 80})[GetCastLevel(source, _R)] + 0.4 * GetBonusAP(source) + 0.75 * source.totalDamage) * ((GetMaxHP(target) - GetCurrentHP(target)) / GetMaxHP(target) * 1.5 + 1) dmg = dmg * (GotBuff(target, "nidaleepassivehunted") > 0 and 1.4 or 1) return dmg end},
    {Slot = "W", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({40, 80, 120, 160, 200})[level] + 0.2 * GetBonusAP(source) end},
    {Slot = "W", Stage = 2, DamageType = 2, Damage = function(source, target, level) return ({60, 110, 160, 210})[GetCastLevel(source, _R)] + 0.3 * GetBonusAP(source) end},
    {Slot = "E", Stage = 2, DamageType = 2, Damage = function(source, target, level) return ({70, 130, 190, 250})[GetCastLevel(source, _R)] + 0.45 * GetBonusAP(source) end},
  },

  ["Nocturne"] = {
    {Slot = "Q", Stage = 1, DamageType = 1, Damage = function(source, target, level) return ({60, 105, 150, 195, 240})[level] + 0.75 * source.totalDamage end},
    {Slot = "E", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({80, 120, 160, 200, 260})[level] + GetBonusAP(source) end},
    {Slot = "R", Stage = 1, DamageType = 1, Damage = function(source, target, level) return ({150, 250, 350})[level] + 1.2 * source.totalDamage end},
  },

  ["Nunu"] = {
    {Slot = "Q", Stage = 1, DamageType = 3, Damage = function(source, target, level) return ({400, 550, 700, 850, 1000})[level] end},
    {Slot = "E", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({85, 130, 175, 225, 275})[level] + GetBonusAP(source) end},
    {Slot = "R", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({625, 875, 1125})[level] + 2.5 * GetBonusAP(source) end},
  },

  ["Olaf"] = {
    {Slot = "Q", Stage = 1, DamageType = 1, Damage = function(source, target, level) return ({70, 115, 160, 205, 250})[level] + 0.55 * GetBonusDmg(source) end},
    {Slot = "E", Stage = 1, DamageType = 3, Damage = function(source, target, level) return ({70, 115, 160, 205, 250})[level] + 0.4 * source.totalDamage end},
  },

  ["Orianna"] = {
    {Slot = "Q", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({60, 90, 120, 150, 180})[level] + 0.5 * GetBonusAP(source) end},
    {Slot = "W", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({70, 115, 160, 205, 250})[level] + 0.7 * GetBonusAP(source) end},
    {Slot = "E", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({60, 90, 120, 150, 180})[level] + 0.3 * GetBonusAP(source) end},
    {Slot = "R", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({150, 225, 300})[level] + 0.7 * GetBonusAP(source) end},
  },

  ["Pantheon"] = {
    {Slot = "Q", Stage = 1, DamageType = 1, Damage = function(source, target, level) return (({65, 105, 145, 185, 225})[level] + 1.4 * source.totalDamage) * ((GetCurrentHP(target) / GetMaxHP(target) < 0.15) and 2 or 1) end},
    {Slot = "W", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({50, 75, 100, 125, 150})[level] + GetBonusAP(source) end},
    {Slot = "E", Stage = 1, DamageType = 1, Damage = function(source, target, level) return (({13, 23, 33, 43, 53})[level] + 0.6 * source.totalDamage) * ((GetObjectType(target) == Obj_AI_Hero) and 2 or 1) end},
    {Slot = "R", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({400, 700, 1000})[level] + GetBonusAP(source) end},
    {Slot = "R", Stage = 2, DamageType = 2, Damage = function(source, target, level) return (({400, 700, 1000})[level] + GetBonusAP(source)) * 0.5 end},
  },

  ["Poppy"] = {
    {Slot = "Q", Stage = 1, DamageType = 1, Damage = function(source, target, level) return ({35, 55, 75, 95, 115})[level] + 0.80 * source.totalDamage + 0.07 * GetMaxHP(target) end},
    {Slot = "Q", Stage = 2, DamageType = 1, Damage = function(source, target, level) return ({70, 110, 150, 190, 230})[level] + 1.6 * source.totalDamage + 0.14 * GetMaxHP(target) end},
    {Slot = "W", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({70, 110, 150, 190, 230})[level] + 0.7 * GetBonusAP(source) end},
    {Slot = "E", Stage = 1, DamageType = 1, Damage = function(source, target, level) return ({50, 70, 90, 110, 130})[level] + 0.5 * source.totalDamage end},
    {Slot = "E", Stage = 2, DamageType = 1, Damage = function(source, target, level) return ({100, 140, 180, 220, 260})[level] + source.totalDamage end},
    {Slot = "R", Stage = 1, DamageType = 1, Damage = function(source, target, level) return ({100, 150, 200})[level] + 0.45 * GetBonusDmg(source) end},
  },

  ["Quinn"] = {
    {Slot = "Q", Stage = 1, DamageType = 1, Damage = function(source, target, level) local damage = (({20, 45, 70, 95, 120})[level] + ({0.8, 0.9, 1.0, 1.1, 1.2})[level] * source.totalDamage) + 0.35 * GetBonusAP(source) ; damage = damage + damage * ((100 - GetPercentHP(target)) / 100) ; return damage end},
    {Slot = "E", Stage = 1, DamageType = 1, Damage = function(source, target, level) return ({40, 70, 100, 130, 160})[level] + 0.2 * source.totalDamage end},
    {Slot = "R", Stage = 1, DamageType = 1, Damage = function(source, target, level) return 0.4 * source.totalDamage end},
  },

  ["Rammus"] = {
    {Slot = "Q", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({100, 150, 200, 250, 300})[level] + GetBonusAP(source) end},
    {Slot = "W", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({15, 25, 35, 45, 55})[level] + 0.1 * GetArmor(source) end},
    {Slot = "R", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({65, 130, 195})[level] + 0.3 * GetBonusAP(source) end},
  },

  ["Renekton"] = {
    {Slot = "Q", Stage = 1, DamageType = 1, Damage = function(source, target, level) return ({60, 90, 120, 150, 180})[level] + 0.8 * source.totalDamage end},
    {Slot = "Q", Stage = 2, DamageType = 1, Damage = function(source, target, level) return ({60, 90, 120, 150, 180})[level] + 0.8 * source.totalDamage * 1.5 end},
    {Slot = "W", Stage = 1, DamageType = 1, Damage = function(source, target, level) return ({10, 30, 50, 70, 90})[level] + 1.5 * source.totalDamage end},
    {Slot = "W", Stage = 2, DamageType = 1, Damage = function(source, target, level) return ({10, 30, 50, 70, 90})[level] + 1.5 * source.totalDamage * 1.5 end},
    {Slot = "E", Stage = 1, DamageType = 1, Damage = function(source, target, level) return ({30, 60, 90, 120, 150})[level] + 0.9 * source.totalDamage end},
    {Slot = "E", Stage = 1, DamageType = 1, Damage = function(source, target, level) return ({30, 60, 90, 120, 150})[level] + 0.9 * source.totalDamage * 1.5 end},
    {Slot = "R", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({40, 80, 120})[level] + 0.1 * GetBonusAP(source) end},
  },

  ["Rengar"] = {
    {Slot = "Q", Stage = 1, DamageType = 1, Damage = function(source, target, level) return ({25, 45, 65, 85, 105})[level] + ({20, 30, 40, 50, 60})[level] / 100 * GetBonusDmg(source) end},
    {Slot = "Q", Stage = 2, DamageType = 1, Damage = function(source, target, level) return ({60, 68, 76, 82, 88, 94, 100, 108, 116, 124, 132, 140, 148, 156, 164, 172, 180, 188, 196})[GetLevel(source)] + 1.1 * GetBonusDmg(source) end},
    {Slot = "W", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({50, 80, 110, 140, 170})[level] + 0.8 * GetBonusAP(source) end},
    {Slot = "E", Stage = 1, DamageType = 1, Damage = function(source, target, level) return ({50, 100, 150, 200, 250})[level] + 0.7 * source.totalDamage end},
    {Slot = "E", Stage = 2, DamageType = 1, Damage = function(source, target, level) return ({50, 65, 80, 95, 110, 125, 140, 155, 170, 185, 200, 215, 230, 245, 260, 275, 290, 305})[GetLevel(source)] + 0.7 * source.totalDamage end},
  },

  ["Riven"] = {
    {Slot = "Q", Stage = 1, DamageType = 1, Damage = function(source, target, level) return ({10, 30, 50, 70, 90})[level] + (source.totalDamage / 100) * ({40, 45, 50, 55, 60})[level] end},
    {Slot = "W", Stage = 1, DamageType = 1, Damage = function(source, target, level) return ({50, 80, 110, 140, 170})[level] + GetBonusDmg(source) end},
    {Slot = "R", Stage = 1, DamageType = 1, Damage = function(source, target, level) return (({100, 150, 200})[level] + 0.6 * GetBonusDmg(source)) * math.max(0.04 * math.min(100 - GetPercentHP(target), 75), 1) end},
  },

  ["Rumble"] = {
    {Slot = "Q", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({75, 135, 195, 255, 315})[level] + GetBonusAP(source) end},
    {Slot = "Q", Stage = 2, DamageType = 2, Damage = function(source, target, level) return ({112.5, 202.5, 292.5, 382.5, 472.5})[level] + 1.5 * GetBonusAP(source) end},
    {Slot = "E", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({45, 70, 95, 120, 145})[level] + 0.4 * GetBonusAP(source) end},
    {Slot = "E", Stage = 2, DamageType = 2, Damage = function(source, target, level) return ({67.5, 105, 142.5, 180, 217.5})[level] + 0.6 * GetBonusAP(source) end},
    {Slot = "R", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({130, 185, 240})[level] + 0.3 * GetBonusAP(source) end},
    {Slot = "R", Stage = 2, DamageType = 2, Damage = function(source, target, level) return ({650, 925, 1200})[level] + 1.5 * GetBonusAP(source) end},
  },

  ["Ryze"] = {
    {Slot = "Q", Stage = 1, DamageType = 2, Damage = function(source, target, level) return (({60, 85, 110, 135, 160, 185})[level] + 0.45 * GetBonusAP(source) + 0.03 * GetMaxMana(source)) * (1 + (GotBuff(target, "RyzeE") > 0 and ({40, 55, 70, 85, 100, 100})[level] / 100 or 0)) end},
    {Slot = "W", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({80, 100, 120, 140, 160})[level] + 0.2 * GetBonusAP(source) + 0.01 * GetMaxMana(source) end},
    {Slot = "E", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({50, 75, 100, 125, 150})[level] + 0.3 * GetBonusAP(source) + 0.02 * GetMaxMana(source) end},
  },

  ["Sejuani"] = {
    {Slot = "Q", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({80, 125, 170, 215, 260})[level] end},
    {Slot = "W", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({4, 4.5, 5, 5.5, 6})[level] / 100 * GetMaxHP(target) end},
    {Slot = "W", Stage = 2, DamageType = 2, Damage = function(source, target, level) return ({10, 17.5, 25, 32.5, 40})[level] + (({4, 6, 8, 10, 12})[level] / 100) * GetMaxHP(source) + 0.15 * GetBonusAP(source) end},
    {Slot = "E", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({60, 90, 120, 150, 180})[level] + 0.5 * GetBonusAP(source) end},
    {Slot = "R", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({150, 250, 350})[level] + 0.8 * GetBonusAP(source) end},
  },

  ["Shaco"] = {
    {Slot = "W", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({35, 50, 65, 80, 95})[level] + 0.2 * GetBonusAP(source) end},
    {Slot = "E", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({5, 35, 65, 95, 125})[level] + ({3, 4, 5, 6, 7, 8})[level] / 100 * (GetMaxHP(target) - GetCurrentHP(target)) + 0.9 * GetBonusAP(source) + 0.85 * source.totalDamage end},
    {Slot = "R", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({300, 450, 600})[level] + GetBonusAP(source) end},
  },

  ["Shen"] = {
    {Slot = "Q", Stage = 1, DamageType = 2, Damage = function(source, target, level) local dmg = (({2, 2.5, 3, 3.5, 4})[level] + 0.015 * GetBonusAP(source)) * GetMaxHP(target) / 100; if GetObjectType(target) == Obj_AI_Hero then return dmg end; return math.min(({30, 50, 70, 90, 110})[level]+dmg, ({75, 100, 125, 150, 175})[level]) end},
    {Slot = "Q", Stage = 2, DamageType = 2, Damage = function(source, target, level) local dmg = (({4, 4.5, 5, 5.5, 6})[level] + 0.02 * GetBonusAP(source)) * GetMaxHP(target) / 100; if GetObjectType(target) == Obj_AI_Hero then return dmg end; return math.min(({30, 50, 70, 90, 110})[level]+dmg, ({75, 100, 125, 150, 175})[level]) end},
    {Slot = "E", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({50, 85, 120, 155, 190})[level] + 0.5 * GetBonusAP(source) end},
  },

  ["Shyvana"] = {
    {Slot = "Q", Stage = 1, DamageType = 1, Damage = function(source, target, level) return ({80, 85, 90, 95, 100})[level] / 100 * source.totalDamage end},
    {Slot = "W", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({20, 32, 45, 57, 70})[level] + 0.2 * source.totalDamage + 0.1 * GetBonusAP(source) end},
    {Slot = "E", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({60, 100, 140, 180, 220})[level] + 0.3 * GetBonusAP(source) end},
    {Slot = "R", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({150, 250, 350})[level] + 0.7 * GetBonusAP(source) end},
  },

  ["Singed"] = {
    {Slot = "Q", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({22, 34, 46, 58, 70})[level] + 0.3 * GetBonusAP(source) end},
    {Slot = "E", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({50, 65, 80, 95, 110})[level] + 0.75 * GetBonusAP(source) + ({4, 5.5, 7, 8.5, 10})[level] / 100 * GetMaxHP(target) end},
  },

  ["Sion"] = {
    {Slot = "Q", Stage = 1, DamageType = 1, Damage = function(source, target, level) return ({20, 40, 60, 80, 100})[level] + 0.6 * source.totalDamage end},
    {Slot = "Q", Stage = 2, DamageType = 1, Damage = function(source, target, level) return ({60, 120, 180, 240, 300})[level] + 1.8 * source.totalDamage end},
    {Slot = "W", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({40, 65, 90, 115, 140})[level] + 0.4 * GetBonusAP(source) + ({10, 11, 12, 13, 14})[level] / 100 * GetMaxHP(target) end},
    {Slot = "E", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({70, 105, 140, 175, 210})[level] + 0.4 * GetBonusAP(source) end},
    {Slot = "E", Stage = 2, DamageType = 2, Damage = function(source, target, level) return (({70, 105, 140, 175, 210})[level] + 0.4 * GetBonusAP(source)) * 1.5 end},
    {Slot = "R", Stage = 1, DamageType = 1, Damage = function(source, target, level) return ({150, 300, 450})[level] + 0.4 * source.totalDamage end},
    {Slot = "R", Stage = 2, DamageType = 1, Damage = function(source, target, level) return (({150, 300, 450})[level] + 0.4 * source.totalDamage) * 2 end},
  },

  ["Sivir"] = {
    {Slot = "Q", Stage = 1, DamageType = 1, Damage = function(source, target, level) return ({25, 45, 65, 85, 105})[level] + ({70, 80, 90, 100, 110})[level] / 100 * source.totalDamage + 0.5 * GetBonusAP(source) end},
    {Slot = "W", Stage = 1, DamageType = 1, Damage = function(source, target, level) return ({60, 65, 70, 75, 80})[level] / 100 * source.totalDamage end},
  },

  ["Skarner"] = {
    {Slot = "Q", Stage = 1, DamageType = 1, Damage = function(source, target, level) return ({20, 30, 40, 50, 60})[level] + 0.4 * source.totalDamage end},
    {Slot = "E", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({40, 75, 110, 145, 180})[level] + 0.4 * GetBonusAP(source) end},
    {Slot = "R", Stage = 1, DamageType = 2, Damage = function(source, target, level) return (({20, 60, 100})[level] + 0.5 * GetBonusAP(source)) + (0.60 * source.totalDamage) end},
  },

  ["Sona"] = {
    {Slot = "Q", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({40, 70, 100, 130, 160})[level] + 0.4 * GetBonusAP(source) end},
    {Slot = "R", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({150, 250, 350})[level] + 0.5 * GetBonusAP(source) end},
  },

  ["Soraka"] = {
    {Slot = "Q", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({70, 110, 150, 190, 230})[level] + 0.35 * GetBonusAP(source) end},
    {Slot = "E", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({70, 110, 150, 190, 230})[level] + 0.4 * GetBonusAP(source) end},
  },

  ["Swain"] = {
    {Slot = "Q", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({30, 47.5, 65, 82.5, 100})[level] + 0.3 * GetBonusAP(source) end},
    {Slot = "W", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({80, 120, 160, 200, 240})[level] + 0.7 * GetBonusAP(source) end},
    {Slot = "E", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({50, 80, 110, 140, 170})[level] + GetBonusAP(source) end},
    {Slot = "R", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({50, 70, 90})[level] + 0.2 * GetBonusAP(source) end},
  },

  ["Syndra"] = {
    {Slot = "Q", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({50, 95, 140, 185, 230})[level] + 0.75 * GetBonusAP(source) end},
    {Slot = "W", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({70, 110, 150, 190, 230})[level] + 0.7 * GetBonusAP(source) end},
    {Slot = "E", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({70, 115, 160, 205, 250})[level] + 0.5 * GetBonusAP(source) end},
    {Slot = "R", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({270, 405, 540})[level] + 0.6 * GetBonusAP(source) end},
    {Slot = "R", Stage = 2, DamageType = 2, Damage = function(source, target, level) return ({90, 135, 180})[level] + 0.2 * GetBonusAP(source) end},
  },

  ["Talon"] = {
    {Slot = "Q", Stage = 1, DamageType = 1, Damage = function(source, target, level) return ({60, 85, 110, 135, 160})[level] + GetBonusDmg(source) end},
    {Slot = "Q", Stage = 2, DamageType = 1, Damage = function(source, target, level) return ({120, 150, 180, 210, 240})[level] + 1.5 * GetBonusDmg(source) end},
    {Slot = "W", Stage = 1, DamageType = 1, Damage = function(source, target, level) return ({50, 60, 70, 80, 90})[level] + 0.4 * GetBonusDmg(source) end},
    {Slot = "W", Stage = 2, DamageType = 1, Damage = function(source, target, level) return ({60, 90, 120, 150, 180})[level] + 0.7 * GetBonusDmg(source) end},
    {Slot = "R", Stage = 1, DamageType = 1, Damage = function(source, target, level) return ({80, 120, 160})[level] + 0.8 * GetBonusDmg(source) end},
  },

  ["Taliyah"] = {
    {Slot = "Q", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({60, 80, 100, 120, 140})[level] + 0.4 * GetBonusAP(source) end},
    {Slot = "Q", Stage = 2, DamageType = 2, Damage = function(source, target, level) return ({180, 240, 300, 360, 420})[level] + 1.2 * GetBonusAP(source) end},
    {Slot = "W", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({60, 80, 100, 120, 140})[level] + 0.4 * GetBonusAP(source) end},
    {Slot = "E", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({70, 90, 110, 130, 150})[level] + 0.4 * GetBonusAP(source) end},
    {Slot = "E", Stage = 2, DamageType = 2, Damage = function(source, target, level) return ({160, 210, 260, 310, 360})[level] + 0.8 * GetBonusAP(source) end},
  },

  ["Taric"] = {
    {Slot = "W", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({40, 80, 120, 160, 200})[level] + 0.2 * GetArmor(source) end},
    {Slot = "E", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({40, 70, 100, 130, 160})[level] + 0.2 * GetBonusAP(source) end},
    {Slot = "R", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({150, 250, 350})[level] + 0.5 * GetBonusAP(source) end},
  },

  ["TahmKench"] = {
    {Slot = "Q", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({80, 130, 180, 230, 280})[level] + 0.7 * GetBonusAP(source) end},
    {Slot = "W", Stage = 1, DamageType = 2, Damage = function(source, target, level) return GetObjectType(target) == Obj_AI_Minion and ({400, 450, 500, 550, 600})[level] or (({0.20, 0.23, 0.26, 0.29, 0.32})[level] + 0.02 * GetBonusAP(source) / 100) * GetMaxHP(target) end},
    {Slot = "W", Stage = 2, DamageType = 2, Damage = function(source, target, level) return ({100, 150, 200, 250, 300})[level] + 0.6 * GetBonusAP(source) end},
  },


  ["Teemo"] = {
    {Slot = "Q", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({80, 125, 170, 215, 260})[level] + 0.8 * GetBonusAP(source) end},
    {Slot = "E", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({34, 68, 102, 136, 170})[level] + 0.7 * GetBonusAP(source) end},
    {Slot = "E", Stage = 2, DamageType = 2, Damage = function(source, target, level) return ({10, 20, 30, 40, 50})[level] + 0.3 * GetBonusAP(source) end},
    {Slot = "R", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({200, 325, 450})[level] + 0.5 * GetBonusAP(source) end},
  },

  ["Thresh"] = {
    {Slot = "Q", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({80, 120, 160, 200, 240})[level] + 0.5 * GetBonusAP(source) end},
    {Slot = "E", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({65, 95, 125, 155, 185})[level] + 0.4 * GetBonusAP(source) end},
    {Slot = "R", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({250, 400, 550})[level] + GetBonusAP(source) end},
  },

  ["Tristana"] = {
    {Slot = "W", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({60, 110, 160, 210, 260})[level] + 0.5 * GetBonusAP(source) end},
    {Slot = "E", Stage = 1, DamageType = 1, Damage = function(source, target, level) return ({60, 70, 80, 90, 100})[level] + ({0.5, 0.65, 0.8, 0.95, 1.10})[level] * source.totalDamage + 0.5 * GetBonusAP(source) end},
    {Slot = "R", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({300, 400, 500})[level] + GetBonusAP(source) end},
  },

  ["Trundle"] = {
    {Slot = "Q", Stage = 1, DamageType = 1, Damage = function(source, target, level) return ({20, 40, 60, 80, 100})[level] + ({0, 0.5, 0.1, 0.15, 0.2})[level] * source.totalDamage end},
    {Slot = "R", Stage = 1, DamageType = 2, Damage = function(source, target, level) return (({20, 24, 28})[level] / 100 + 0.02 * GetBonusAP(source) / 100) * GetMaxHP(target) end},
  },

  ["Tryndamere"] = {
    {Slot = "E", Stage = 1, DamageType = 1, Damage = function(source, target, level) return ({70, 100, 130, 160, 190})[level] + 1.2 * source.totalDamage + GetBonusAP(source) end},
  },

  ["TwistedFate"] = {
    {Slot = "Q", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({60, 105, 150, 195, 240})[level] + 0.65 * GetBonusAP(source) end},
    {Slot = "W", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({40, 60, 80, 100, 120})[level] + source.totalDamage + 0.5 * GetBonusAP(source) end},
    {Slot = "W", Stage = 2, DamageType = 2, Damage = function(source, target, level) return ({30, 45, 60, 75, 90})[level] + source.totalDamage + 0.5 * GetBonusAP(source) end},
    {Slot = "W", Stage = 3, DamageType = 2, Damage = function(source, target, level) return ({15, 22.5, 30, 37.5, 45})[level] + source.totalDamage + 0.5 * GetBonusAP(source) end},
    {Slot = "E", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({55, 80, 105, 130, 155})[level] + 0.5 * GetBonusAP(source) end},
  },

  ["Twitch"] = {
    {Slot = "E", Stage = 1, DamageType = 1, Damage = function(source, target, level) return (GotBuff(target, "twitchdeadlyvenom") * ({15, 20, 25, 30, 35})[level] + 0.2 * GetBonusAP(source) + 0.25 * source.totalDamage) + ({20, 35, 50, 65, 80})[level] end},
    {Slot = "E", Stage = 2, DamageType = 1, Damage = function(source, target, level) return ({15, 20, 25, 30, 35})[level] + 0.2 * GetBonusAP(source) + 0.25 * source.totalDamage + ({20, 35, 50, 65, 80})[level] end},
  },

  ["Udyr"] = {
    {Slot = "Q", Stage = 1, DamageType = 1, Damage = function(source, target, level) return ({30, 60, 90, 120, 150})[level] + (({120, 130, 140, 150, 160})[level] / 100) * source.totalDamage end},
    {Slot = "R", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({10, 20, 30, 40, 50})[level] + 0.25 * GetBonusAP(source) end},

  },

  ["Urgot"] = {
    {Slot = "Q", Stage = 1, DamageType = 1, Damage = function(source, target, level) return ({10, 40, 70, 100, 130})[level] + 0.85 * source.totalDamage end},
    {Slot = "E", Stage = 1, DamageType = 1, Damage = function(source, target, level) return ({75, 130, 185, 240, 295})[level] + 0.6 * source.totalDamage end},
  },

  ["Varus"] = {
    {Slot = "Q", Stage = 1, DamageType = 1, Damage = function(source, target, level) return ({10, 47, 83, 120, 157})[level] + source.totalDamage end},
    {Slot = "Q", Stage = 2, DamageType = 1, Damage = function(source, target, level) return ({15, 70, 125, 180, 235})[level] + 1.5 * source.totalDamage end},
    {Slot = "W", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({10, 14, 18, 22, 26})[level] + 0.25 * GetBonusAP(source) end},
    {Slot = "W", Stage = 2, DamageType = 2, Damage = function(source, target, level) return (({2, 2.75, 3.5, 4.25, 5})[level] / 100 + 0.02 * GetBonusAP(source) / 100) * GetMaxHP(target) end},
    {Slot = "E", Stage = 1, DamageType = 1, Damage = function(source, target, level) return ({65, 100, 135, 170, 205})[level] + 0.6 * source.totalDamage end},
    {Slot = "R", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({100, 175, 250})[level] + GetBonusAP(source) end},
  },

  ["Vayne"] = {
    {Slot = "Q", Stage = 1, DamageType = 1, Damage = function(source, target, level) return ({30, 35, 40, 45, 50})[level] / 100 * source.totalDamage end},
    {Slot = "W", Stage = 1, DamageType = 3, Damage = function(source, target, level) return math.max(({40, 60, 80, 100, 120})[level], (({6, 7.5, 9, 10.5, 12})[level] / 100) * GetMaxHP(target)) end},
    {Slot = "E", Stage = 1, DamageType = 1, Damage = function(source, target, level) return ({45, 80, 115, 150, 185})[level] + 0.5 * source.totalDamage end},
  },

  ["Veigar"] = {
    {Slot = "Q", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({70, 110, 150, 190, 230})[level] + 0.6 * GetBonusAP(source) end},
    {Slot = "W", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({100, 150, 200, 250, 300})[level] + GetBonusAP(source) end},
    {Slot = "R", Stage = 1, DamageType = 2, Damage = function(source, target, level) local dmg = GetPercentHP(target) > 33.3 and ({175, 250, 325})[level] + 0.75 * GetBonusAP(source) or ({350, 500, 650})[level] + 1.5 * GetBonusAP(source); return dmg+((0.015 * dmg) * (100 - ((GetCurrentHP(target) / GetMaxHP(target)) * 100))) end},
  },

  ["Velkoz"] = {
    {Slot = "Q", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({80, 120, 160, 200, 240})[level] + 0.6 * GetBonusAP(source) end},
    {Slot = "W", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({30, 50, 70, 90, 110})[level] + ({45, 75, 105, 135, 165})[level] + 0.4 * GetBonusAP(source) end},
    {Slot = "E", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({70, 100, 130, 160, 190})[level] + 0.3 * GetBonusAP(source) end},
    {Slot = "R", Stage = 1, DamageType = 3, Damage = function(source, target, level) return (GotBuff(target, "velkozresearchedstack") > 0 and ({450, 625, 800})[level] + 1.25* GetBonusAP(source) or CalcMagicalDamage(source, target, ({450, 625, 800})[level] + 1.25 * GetBonusAP(source))) end},
  },

  ["Vi"] = {
    {Slot = "Q", Stage = 1, DamageType = 1, Damage = function(source, target, level) return ({50, 75, 100, 125, 150})[level] + 0.8 * source.totalDamage end},
    {Slot = "W", Stage = 1, DamageType = 1, Damage = function(source, target, level) return (({4, 5.5, 7, 8.5, 10})[level] / 100 + 0.01 * source.totalDamage / 35) * GetMaxHP(target) end},
    {Slot = "E", Stage = 1, DamageType = 1, Damage = function(source, target, level) return ({5, 20, 35, 50, 65})[level] + 1.15 * source.totalDamage + 0.7 * GetBonusAP(source) end},
    {Slot = "R", Stage = 1, DamageType = 1, Damage = function(source, target, level) return ({150, 300, 450})[level] + 1.4 * source.totalDamage end},
  },

  ["Viktor"] = {
    {Slot = "Q", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({60, 80, 100, 120, 140})[level] + 0.4 * GetBonusAP(source) end},
    {Slot = "E", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({70, 110, 150, 190, 230})[level] + 0.5 * GetBonusAP(source) end},
    {Slot = "E", Stage = 2, DamageType = 2, Damage = function(source, target, level) return ({90, 170, 250, 330, 410})[level] + 1.2 * GetBonusAP(source) end},
    {Slot = "R", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({100, 175, 250})[level] + 0.5 * GetBonusAP(source) end},
    {Slot = "R", Stage = 2, DamageType = 2, Damage = function(source, target, level) return ({150, 250, 350})[level] + 0.6 * GetBonusAP(source) end},
  },

  ["Vladimir"] = {
    {Slot = "Q", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({80, 100, 120, 140, 160})[level] + 0.6 * GetBonusAP(source) end},
    {Slot = "W", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({60, 80, 100, 120, 140})[level] end},
    {Slot = "E", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({30, 45, 60, 75, 90})[level] + 0.5 * GetBonusAP(source) + 0.3 * GetMaxHP(source) end},
    {Slot = "E", Stage = 2, DamageType = 2, Damage = function(source, target, level) return ({60, 90, 120, 150, 180})[level] + GetBonusAP(source) + 0.6 * GetMaxHP(source) end},
    {Slot = "R", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({150, 250, 350})[level] + 0.7 * GetBonusAP(source) end},
  },

  ["Volibear"] = {
    {Slot = "Q", Stage = 1, DamageType = 1, Damage = function(source, target, level) return ({30, 60, 90, 120, 150})[level] end},
    {Slot = "W", Stage = 1, DamageType = 1, Damage = function(source, target, level) return (({60, 110, 160, 210, 260})[level]) * ((GetMaxHP(target) - GetCurrentHP(target)) / GetMaxHP(target) + 1) end},
    {Slot = "E", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({60, 105, 150, 195, 240})[level] + 0.6 * GetBonusAP(source) end},
    {Slot = "R", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({75, 115, 155})[level] + 0.3 * GetBonusAP(source) end},
  },

  ["Warwick"] = {
    {Slot = "Q", Stage = 1, DamageType = 2, Damage = function(source, target, level) return math.max(({75, 125, 175, 225, 275})[level],(({8, 10, 12, 14, 16})[level] / 100  * GetMaxHP(target)) + GetBonusAP(source)) end},
    {Slot = "R", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({150, 250, 350})[level] + 2 * source.totalDamage end},
  },

  ["Xerath"] = {
    {Slot = "Q", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({80, 120, 160, 200, 240})[level] + 0.75 * GetBonusAP(source) end},
    {Slot = "W", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({60, 90, 120, 150, 180})[level] + 0.6 * GetBonusAP(source) end},
    {Slot = "E", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({80, 110, 140, 170, 200})[level] + 0.45 * GetBonusAP(source) end},
    {Slot = "R", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({200, 230, 260})[level] + 0.43 * GetBonusAP(source) end},
  },

  ["XinZhao"] = {
    {Slot = "Q", Stage = 1, DamageType = 1, Damage = function(source, target, level) return ({15, 30, 45, 60, 75})[level] + 0.2 * source.totalDamage end},
    {Slot = "E", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({70, 110, 150, 190, 230})[level] + 0.6 * GetBonusAP(source) end},
    {Slot = "R", Stage = 1, DamageType = 1, Damage = function(source, target, level) return ({75, 175, 275})[level] + source.totalDamage + 0.15 * GetCurrentHP(target) end},
  },

  ["Yasuo"] = {
    {Slot = "Q", Stage = 1, DamageType = 1, Damage = function(source, target, level) return ({20, 40, 60, 80, 100})[level] + source.totalDamage end},
    {Slot = "E", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({60, 70, 80, 90, 100})[level] + 0.2 * GetBonusDmg(source) + 0.6 * GetBonusAP(source) end},
    {Slot = "R", Stage = 1, DamageType = 1, Damage = function(source, target, level) return ({200, 300, 400})[level] + 1.5 * source.totalDamage end},
  },

  ["Yorick"] = {
    {Slot = "Q", Stage = 1, DamageType = 1, Damage = function(source, target, level) return ({30, 60, 90, 120, 150})[level] + 1.2 * source.totalDamage end},
    {Slot = "W", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({60, 95, 130, 165, 200})[level] + GetBonusAP(source) end},
    {Slot = "E", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({55, 85, 115, 145, 175})[level] + source.totalDamage end},
  },

  ["Zac"] = {
    {Slot = "Q", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({70, 110, 150, 190, 230})[level] + 0.5 * GetBonusAP(source) end},
    {Slot = "W", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({40, 55, 70, 85, 100})[level] + (({4, 5, 6, 7, 8})[level] / 100 + 0.02 * GetBonusAP(source) / 100) * GetMaxHP(target) end},
    {Slot = "E", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({80, 130, 180, 230, 280})[level] + 0.7 * GetBonusAP(source) end},
    {Slot = "R", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({140, 210, 280})[level] + 0.4 * GetBonusAP(source) end},
  },

  ["Zed"] = {
    {Slot = "Q", Stage = 1, DamageType = 1, Damage = function(source, target, level) return ({70, 105, 140, 175, 210})[level] + source.totalDamage end},
    {Slot = "E", Stage = 1, DamageType = 1, Damage = function(source, target, level) return ({65, 90, 115, 140, 165})[level] + 0.8 * source.totalDamage end},
    {Slot = "R", Stage = 1, DamageType = 1, Damage = function(source, target, level) return source.totalDamage end},
  },

  ["Ziggs"] = {
    {Slot = "Q", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({75, 120, 165, 210, 255})[level] + 0.65 * GetBonusAP(source) end},
    {Slot = "W", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({70, 105, 140, 175, 210})[level] + 0.35 * GetBonusAP(source) end},
    {Slot = "E", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({40, 65, 90, 115, 140})[level] + 0.3 * GetBonusAP(source) end},
    {Slot = "R", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({300, 450, 600})[level] + 1.1 * GetBonusAP(source) end},
  },

  ["Zilean"] = {
    {Slot = "Q", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({90, 145, 200, 260, 320})[level] + 0.9 * GetBonusAP(source) end},
  },

  ["Zyra"] = {
    {Slot = "Q", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({60, 95, 130, 165, 200})[level] + 0.6 * GetBonusAP(source) end},
    {Slot = "E", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({60, 95, 130, 165, 200})[level] + 0.5 * GetBonusAP(source) end},
    {Slot = "R", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({180, 265, 350})[level] + 0.7 * GetBonusAP(source) end},
  }

}

function getdmg(spell,target,source,stage,level)
  local source = source or myHero
  local stage = stage or 1
  local swagtable = {}
  local k = 0
  if stage > 4 then stage = 4 end
  if spell == "Q" or spell == "W" or spell == "E" or spell == "R" or spell == "QM" or spell == "WM" or spell == "EM" then
    local level = level or GetCastLevel(source, ({["Q"] = _Q, ["QM"] = _Q, ["W"] = _W, ["WM"] = _W, ["E"] = _E, ["EM"] = _E, ["R"] = _R})[spell])
    if level <= 0 then return 0 end
    if level > 5 then level = 5 end
    if DamageLibTable[GetObjectName(source)] then
      for i, spells in pairs(DamageLibTable[GetObjectName(source)]) do
        if spells.Slot == spell then
          table.insert(swagtable, spells)
        end
      end
      if stage > #swagtable then stage = #swagtable end
      for v = #swagtable, 1, -1 do
        local spells = swagtable[v]
        if spells.Stage == stage then
          if spells.DamageType == 1 then
            return CalcPhysicalDamage(source, target, spells.Damage(source, target, level))
          elseif spells.DamageType == 2 then
            return CalcMagicalDamage(source, target, spells.Damage(source, target, level))
          elseif spells.DamageType == 3 then
            return spells.Damage(source, target, level)
          end
        end
      end
    end
  end
  if spell == "AA" then
    return CalcPhysicalDamage(source, target, source.totalDamage)
  end
  if spell == "IGNITE" then
    if Ignite then
      return 50+20*GetLevel(source) - (GetHPRegen(target)*3)
    end
  end
  if spell == "SMITE" then
    if Smite then
      if GetObjectType(target) == Obj_AI_Hero then
        if GetCastName(source, Smite) == "s5_summonersmiteplayerganker" then
          return 20+8*GetLevel(source)
        end
        if GetCastName(source, Smite) == "s5_summonersmiteduel" then
          return 54+6*GetLevel(source)
        end
      end
      return ({390, 410, 430, 450, 480, 510, 540, 570, 600, 640, 680, 720, 760, 800, 850, 900, 950, 1000})[GetLevel(source)]
    end
  end
  if spell == "BILGEWATER" then
    return CalcMagicalDamage(source, target, 100)
  end
  if spell == "BOTRK" then
    return CalcMagicalDamage(source, target, 100)
  end
  if spell == "HEXTECH" then
    return CalcMagicalDamage(source, target, 150+0.4*GetBonusAP(source))
  end
  return 0
end
