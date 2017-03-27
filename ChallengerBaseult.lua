ChallengerBaseultVersion = 0.12

class "ChallengerBaseult"

function ChallengerBaseult:__init()
  self.enemySpawnPos = nil
  self.SpellData = {
    ["Ashe"] = {
      Delay = 0.25,
      MissileSpeed = 1600,
      Damage = function(target) return CalcDamage(myHero, target, 0, 75 + 175*GetCastLevel(myHero,_R) + GetBonusAP(myHero)) end
    },

    ["Draven"] = {
      Delay = 0.4,
      MissileSpeed = 2000,
      Damage = function(target) return CalcDamage(myHero, target, 75 + 100*GetCastLevel(myHero,_R) + 1.1*GetBonusDmg(myHero)) end
    },

    ["Ezreal"] = {
      Delay = 1,
      MissileSpeed = 2000,
      Damage = function(target) return CalcDamage(myHero, target, 0, 200 + 150*GetCastLevel(myHero,_R) + .9*GetBonusAP(myHero)+GetBonusDmg(myHero))*0.9 end
    },

    ["Jinx"] = {
      Delay = 0.6,
      MissileSpeed = 1700,
      Damage = function(target) return CalcDamage(myHero, target, math.max(50*GetCastLevel(myHero, _R)+75+GetBonusDmg(myHero)+(0.05*GetCastLevel(myHero, _R)+0.2)*(GetMaxHP(target)-GetCurrentHP(target)))) end
    }
  }

  if not self.SpellData[GetObjectName(myHero)] then PrintChat("<b><font color='#EE2EC'>Challenger Baseult -</font></b><b><font color='#ff0000'> "..GetObjectName(myHero).." Is Not Supported! </font></b>") return end
  PrintChat(string.format("<b><font color='#EE2EC'>Challenger Baseult</font></b> For "..GetObjectName(myHero).." Loaded, Have Fun ! "))
  self.Recalling = {}
  self.BaseultMenu = MenuConfig("ChallengerBaseult", "Challenger Baseult")
  self.BaseultMenu:KeyBinding("Baseult", "Baseult", string.byte("H"), true, function() end, true)
  self.BaseultMenu:KeyBinding("PanicKey", "Do Not Use Ultimate in Fight", 32, false)
  PermaShow(self.BaseultMenu.Baseult)
  if GetObjectName(myHero) == "Jinx" or GetObjectName(myHero) == "Ashe" then
    self.BaseultMenu:Boolean("Collision", "Check for collision", true)
  else
    self.BaseultMenu:Boolean("Collision", "Check for collision", false)
  end
  self.Delay = self.SpellData[GetObjectName(myHero)].Delay
  self.MissileSpeed = self.SpellData[GetObjectName(myHero)].MissileSpeed
  self.Damage = self.SpellData[GetObjectName(myHero)].Damage
  Callback.Add("ObjectLoad", function(Object) self:ObjectLoad(Object) end)
  Callback.Add("CreateObj", function(Object) self:CreateObj(Object) end)
  Callback.Add("Tick", function() self:Tick() end)
  Callback.Add("ProcessRecall", function(unit,recall) self:ProcessRecall(unit,recall) end)
end

function ChallengerBaseult:ObjectLoad(Object)
  if GetObjectType(Object) == Obj_AI_SpawnPoint and GetTeam(Object) ~= GetTeam(myHero) then
    self.enemySpawnPos = Object
  end
end

function ChallengerBaseult:CreateObj(Object)
  if GetObjectType(Object) == Obj_AI_SpawnPoint and GetTeam(Object) ~= GetTeam(myHero) then
    self.enemySpawnPos = Object
  end
end

function ChallengerBaseult:Tick()
  if GetObjectName(myHero) == "Draven" then
    SpellReady = CanUseSpell(myHero, _R) == READY and GetCastName(myHero,_R) == "DravenRCast"
  else
    SpellReady = CanUseSpell(myHero, _R) == READY
  end
  if SpellReady then
    for i, recall in pairs(self.Recalling) do
      local dmg = self.Damage(recall.champ)
      if dmg >= GetCurrentHP(recall.champ) and self.enemySpawnPos ~= nil then
        local TimeToRecall = recall.duration - (GetGameTimer() - recall.start) + GetLatency() / 2000
        local BaseDistance = GetDistance(self.enemySpawnPos)
        if GetObjectName(myHero) == "Jinx" then
          self.MissileSpeed = BaseDistance > 1350 and (2295000 + (BaseDistance - 1350) * 2200) / BaseDistance or 1700
        end
        local TimeToHit = self.Delay + BaseDistance / self.MissileSpeed + GetLatency() / 2000
        if TimeToRecall < TimeToHit and TimeToHit < 7.8 and TimeToHit - TimeToRecall < 1.5 and dmg >= GetCurrentHP(recall.champ) and self.BaseultMenu.Baseult:Value() and not self.BaseultMenu.PanicKey:Value() then
          if self.BaseultMenu.Collision:Value() then
            if self:Collision(recall.champ) == 0 then
              CastSkillShot(_R, GetOrigin(self.enemySpawnPos))
            end
          else
            CastSkillShot(_R, GetOrigin(self.enemySpawnPos))
          end
        end
      end
    end
  end
end

function ChallengerBaseult:ProcessRecall(unit,recall)
  if GetTeam(unit) ~= GetTeam(myHero) then 
    if recall.isStart then
      table.insert(self.Recalling, {champ = unit, start = GetGameTimer(), duration = (recall.totalTime/1000)})
    else
      for i, recall in pairs(self.Recalling) do
        if recall.champ == unit then
          table.remove(self.Recalling, i)
        end
      end
    end
  end
end

function ChallengerBaseult:Collision(unit)
  local count = 0
  for i, enemy in pairs(GetEnemyHeroes()) do
    if enemy and IsObjectAlive(enemy) and GetNetworkID(unit) ~= GetNetworkID(enemy) and self.enemySpawnPos ~= nil then
      local pointSegment, pointLine, isOnSegment = VectorPointProjectionOnLineSegment(GetOrigin(myHero), GetOrigin(self.enemySpawnPos), GetOrigin(enemy))
      if isOnSegment and GetDistanceSqr(pointSegment, GetOrigin(enemy)) < (60+GetHitBox(enemy))^2 and GetDistanceSqr(GetOrigin(myHero), GetOrigin(self.enemySpawnPos)) > GetDistanceSqr(GetOrigin(myHero), GetOrigin(enemy)) then
        count = count + 1
      end
    end
  end
  return count
end

if GetUser() ~= "Deftsu" then 
  GetWebResultAsync("https://raw.githubusercontent.com/D3ftsu/GoS/master/ChallengerBaseult.version", function(data)
    if tonumber(data) > ChallengerBaseultVersion then
      PrintChat("<b><font color='#EE2EC'>Challenger Baseult - </font></b> New version found! " ..data.." Downloading update, please wait...")
      DownloadFileAsync("https://raw.githubusercontent.com/D3ftsu/GoS/master/ChallengerBaseult.lua", SCRIPT_PATH .. "ChallengerBaseult.lua", function() PrintChat("<b><font color='#EE2EC'>Challenger Baseult - </font></b> Updated from v"..tostring(ChallengerBaseultVersion).." to v"..data..". Please press F6 twice to reload.") return end)
    end
  end)
end
ChallengerBaseult()
