require('Inspired')

local BasePositions = {
  [SUMMONERS_RIFT] = {
    [100] = Vector(14340, 171, 14390),
    [200] = Vector(400, 200, 400)
  },

  [CRYSTAL_SCAR] = {
    [100] = Vector(13321, -37, 4163),
    [200] = Vector(527, -35, 4163)
  },

  [TWISTED_TREELINE] = {
    [100] = Vector(14320, 151, 7235),
    [200] = Vector(1060, 150, 7297)
  }
}

local Base = BasePositions[GetMapID()][GetTeam(myHero)]

local SpellData = {
  ["Ashe"] = {
    Delay = 250,
    MissileSpeed = 1600,
    Damage = function(target) return CalcDamage(myHero, target, 0, 75 + 175*GetCastLevel(myHero,_R) + GetBonusAP(myHero)) end
  },

  ["Draven"] = {
    Delay = 400,
    MissileSpeed = 2000,
    Damage = function(target) return CalcDamage(myHero, target, 75 + 100*GetCastLevel(myHero,_R) + 1.1*GetBonusDmg(myHero)) end
  },

  ["Ezreal"] = {
    Delay = 1000,
    MissileSpeed = 2000,
    Damage = function(target) return CalcDamage(myHero, target, 0, 200 + 150*GetCastLevel(myHero,_R) + .9*GetBonusAP(myHero)+GetBonusDmg(myHero)) end
  },

  ["Jinx"] = {
    Delay = 600,
    MissileSpeed = 1700,
    Damage = function(target) return CalcDamage(myHero, target, math.max(50*GetCastLevel(myHero, _R)+75+GetBonusDmg(myHero)+(0.05*GetCastLevel(myHero, _R)+0.2)*(GetMaxHP(target)-GetCurrentHP(target)))) end
  }
}

local BaseultMenu = MenuConfig("Baseult", "Baseult")

if SpellData[GetObjectName(myHero)] then
  BaseultMenu:Boolean("Enabled", "Enabled", true)
  PrintChat(string.format("<font color='#1244EA'>Baseult</font> <font color='#FFFFFF'> For "..GetObjectName(myHero).." Loaded, Have Fun Getting Some Kills ! </font>"))
  Delay = SpellData[GetObjectName(myHero)].Delay
  MissileSpeed = SpellData[GetObjectName(myHero)].MissileSpeed
  Damage = SpellData[GetObjectName(myHero)].Damage
end

OnProcessRecall(function(unit,recall)
if GetTeam(myHero) ~= GetTeam(unit) then
  if SpellData[GetObjectName(myHero)] then
    if GetObjectName(myHero) == "Jinx" then
      MissileSpeed = GetDistance(Base) > 1350 and (2295000 + (GetDistance(Base) - 1350) * 2200) / GetDistance(Base) or 1700
    end
    if IsReady(_R) and BaseultMenu.Enabled:Value() and Damage(unit) > GetCurrentHP(unit)+GetDmgShield(unit)+GetHPRegen(unit)*8 then
      if (recall.totalTime-recall.passedTime) > Delay + (GetDistance(Base) * 1000 / MissileSpeed) then
        DelayAction(function() CastSkillShot(_R,Base) end, ((recall.totalTime-recall.passedTime)- (Delay + (GetDistance(Base) * 1000 / MissileSpeed)))/1000)
      end
    end
  end
end
end)
