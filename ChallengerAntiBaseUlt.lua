ChallengerAntiBaseUltVersion     = "0.04"

function ChallengerAntiBaseUltUpdaterino(data)
  if tonumber(data) > tonumber(ChallengerAntiBaseUltVersion) then
    PrintChat("<b><font color='#EE2EC'>Challenger AntiBaseUlt - </font></b> New version found! " ..tonumber(data).." Downloading update, please wait...")
    DownloadFileAsync("https://raw.githubusercontent.com/D3ftsu/GoS/master/ChallengerAntiBaseUlt.lua", SCRIPT_PATH .. "ChallengerAntiBaseUlt.lua", function() PrintChat("<b><font color='#EE2EC'>Challenger AntiBaseUlt - </font></b> Updated from v"..tonumber(ChallengerAntiBaseUltVersion).." to v"..tonumber(data)..". Please press F6 twice to reload.") return end)
  end
end

class "ChallengerAntiBaseUlt"

function ChallengerAntiBaseUlt:__init()
  PrintChat("<b><font color='#EE2EC'>Challenger Anti-BaseUlt - </font></b> Loaded v" ..ChallengerAntiBaseUltVersion)
  self.cfg = MenuConfig("AntiBaseUlt", "Anti-BaseUlt")
  self.cfg:Boolean("Enabled", "Enabled", true)
  self.SpellData = {
    ["Ashe"] = {
      MissileName = "EnchantedCrystalArrow",
      MissileSpeed = 1600,
    },

    ["Draven"] = {
      MissileName = "DravenDoubleShotMissile",
      MissileSpeed = 2000,
    },

    ["Ezreal"] = {
      MissileName = "EzrealTrueshotBarrage",
      MissileSpeed = 2000,
    },

    ["Jinx"] = {
      MissileName = "JinxR",
      MissileSpeed = 1700,
    }
  }
  self.missiles = {}
  self.RecallingTime = 0
  self.LastPrint = 0
  self.fountain = nil
  self.fountainRange = mapID == SUMMONERS_RIFT and 1050 or 750
  Callback.Add("ObjectLoad", function(Object) self:CreateObj(Object) end)
  Callback.Add("CreateObj", function(Object) self:CreateObj(Object) end)
  Callback.Add("ProcessRecall", function(unit, recall) self:ProcessRecall(unit, recall) end)
  Callback.Add("Tick", function() self:Tick() end)
end

function ChallengerAntiBaseUlt:CreateObj(Object)
  if GetObjectType(Object) == Obj_AI_SpawnPoint and GetTeam(Object) == GetTeam(myHero) then
    self.fountain = Object
  end
  if self.SpellData[GetObjectSpellOwner(Object)] and self.SpellData[GetObjectSpellOwner(Object)].MissileName == GetObjectSpellName(Object) and GetTeam(GetObjectSpellOwner(Object)) == MINION_ENEMY then
    table.insert(self.missiles, Object)
  end
end

function ChallengerAntiBaseUlt:ProcessRecall(unit, recall)
  if unit == myHero and recall.isStart then
    self.RecallingTime = GetTickCount() + recall.totalTime
  end
end

function ChallengerAntiBaseUlt:Tick()
  if not IsRecalling(myHero) or IsDead(myHero) then return end
  for i, missile in pairs(self.missiles) do
    if getdmg("R", GetObjectSpellOwner(missile), myHero, 3) > GetCurrentHP(myHero) and self:InFountain(GetObjectSpellEndPos(missile)) and self.RecallingTime > (GetDistance(missile, self.fountain) / self.SpellData[GetObjectSpellOwner(missile)].MissileSpeed * 1000) then
      MoveToXYZ(myHero.x+100,myHero.y, myHero.z+100)
      if GetTickCount()-self.LastPrint > 1000 then
        PrintChat("<b><font color='#EE2EC'>Challenger Anti-BaseUlt - </font></b> Prevented A Baseult From "..GetObjectName(GetObjectSpellOwner(missile))" ")
        self.LastPrint = GetTickCount()
      end
    end
  end
end

function ChallengerAntiBaseUlt:InFountain(pos)
  return GetDistance(self.fountain, pos) < self.fountainRange
end

GetWebResultAsync("https://raw.githubusercontent.com/D3ftsu/GoS/master/ChallengerAntiBaseUlt.version", ChallengerAntiBaseUltUpdaterino)
ChallengerAntiBaseUlt()
