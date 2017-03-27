if ChallengerCommonLoaded then return end

require("DamageLib")
require("OpenPredict")

ChallengerCommonVersion = 0.2
  
if GetUser() ~= "Deftsu" then GetWebResultAsync("https://raw.githubusercontent.com/D3ftsu/GoS/master/Common/ChallengerCommon.version", 
  function(data)
    if tonumber(data) > ChallengerCommonVersion then
      DownloadFileAsync("https://raw.githubusercontent.com/D3ftsu/GoS/master/Common/ChallengerCommon.lua", COMMON_PATH .. "ChallengerCommon.lua", function() print("Updated ChallengerCommon, Please press F6 twice to reload.") return end)
    end
  end) 
end

if not FileExist(COMMON_PATH.."DamageLib.lua") then
  DownloadFileAsync("https://raw.githubusercontent.com/D3ftsu/GoS/master/Common/DamageLib.lua", COMMON_PATH .. "DamageLib.lua", function() print("Downloaded DamageLib, Please press F6 twice to reload.") return end)
end

if not FileExist(COMMON_PATH.."OpenPredict.lua") then
  DownloadFileAsync("https://raw.githubusercontent.com/Jo7j/GoS/master/OpenPredict/OpenPredict.lua", COMMON_PATH .. "OpenPredict.lua", function() print("Downloaded OpenPredict, Please press F6 twice to reload.") return end)
end

class "ChallengerAntiGapcloser"

function ChallengerAntiGapcloser:__init(menu, func)
  self.callbacks = {}
  self.activespells = {}
  self.spells = {
    ["AatroxQ"]                        = {Name = "Aatrox",       spellname = "Q | Dark Flight"},
    ["AhriTumble"]                     = {Name = "Ahri",         spellname = "R | Spirit Rush"},
    ["AkaliShadowDance"]               = {Name = "Akali",        spellname = "R | Shadow Dance"},
    ["AlphaStrike"]                    = {Name = "MasterYi",     spellname = "Q | Alpha Strike"},
    ["BandageToss"]                    = {Name = "Amumu",        spellname = "Q | Bandage Toss"},
    ["Crowstorm"]                      = {Name = "FiddleSticks", spellname = "R | Crowstorm "},
    ["DianaTeleport"]                  = {Name = "Diana",        spellname = "R | Lunar Rush"},
    ["EliseSpiderEDescent"]            = {Name = "Elise",        spellname = "E | Rappel"},
    ["EliseSpiderQCast"]               = {Name = "Elise",        spellname = "Q | Venomous Bite"},
    ["FioraQ"]                         = {Name = "Fiora",        spellname = "Q | Lunge"},
    ["FizzPiercingStrike"]             = {Name = "Fizz",         spellname = "E | Urchin Strike"},
    ["GarenQ"]                         = {Name = "Garen",        spellname = "Q | Decisive Strike"},
    ["GnarBigE"]                       = {Name = "Gnar",         spellname = "E | Crunch"},
    ["GnarE"]                          = {Name = "Gnar",         spellname = "E | Hop"},
    ["GragasE"]                        = {Name = "Gragas",       spellname = "E | Body Slam"},
    ["GravesMove"]                     = {Name = "Graves",       spellname = "E | Quickdraw"},
    ["Headbutt"]                       = {Name = "Alistar",      spellname = "W | Headbutt"},
    ["HecarimUlt"]                     = {Name = "Hecarim",      spellname = "R | Onslaught of Shadows"},
    ["IreliaGatotsu"]                  = {Name = "Irelia",       spellname = "Q | Bladesurge"},
    ["JarvanIVCataclysm"]              = {Name = "JarvanIV",     spellname = "R | Cataclysm"},
    ["JarvanIVDragonStrike"]           = {Name = "JarvanIV",     spellname = "Q | Dragon Strike"},
    ["JaxLeapStrike"]                  = {Name = "Jax",          spellname = "Q | Leap Strike"},
    ["JayceToTheSkies"]                = {Name = "Jayce",        spellname = "W | To The Skies!"},
    ["KatarinaE"]                      = {Name = "Katarina",     spellname = "E | Shunpo"},
    ["KennenLightningRush"]            = {Name = "Kennen",       spellname = "E | Lightning Rush"},
    ["KhazixE"]                        = {Name = "Khazix",       spellname = "E | Leap"},
    ["LeblancSlide"]                   = {Name = "Leblanc",      spellname = "W | Distortion"},
    ["LeblancSlideM"]                  = {Name = "Leblanc",      spellname = "R | Distortion"},
    ["LeonaZenithBlade"]               = {Name = "Leona",        spellname = "E | Zenith Blade"},
    ["LissandraE"]                     = {Name = "Lissandra",    spellname = "E | Glacial Path"},
    ["LucianE"]                        = {Name = "Lucian",       spellname = "E | Relentless Pursuit"},
    ["MaokaiUnstableGrowth"]           = {Name = "Maokai",       spellname = "W | Twisted Advance"},
    ["MonkeyKingNimbus"]               = {Name = "MonkeyKing",   spellname = "E | Nimbus Strike"},
    ["NautilusAnchorDrag"]             = {Name = "Nautilus",     spellname = "Q | Dredge Line"},
    ["Pantheon_LeapBash"]              = {Name = "Pantheon",     spellname = "W | Aegis of Zeonia"},
    ["PoppyHeroicCharge"]              = {Name = "Poppy",        spellname = "E | Heroic Charge"},
    ["QuinnE"]                         = {Name = "Quinn",        spellname = "E | Vault"},
    ["RenektonSliceAndDice"]           = {Name = "Renekton",     spellname = "E | Slice"},
    ["RiftWalk"]                       = {Name = "Kassadin",     spellname = "R | Riftwalk"},
    ["RivenTriCleave"]                 = {Name = "Riven",        spellname = "Q | Broken Wings"},
    ["RocketJump"]                     = {Name = "Tristana",     spellname = "W | Rocket Jump"},
    ["SejuaniArcticAssault"]           = {Name = "Sejuani",      spellname = "Q | Arctic Assault"},
    ["ShenShadowDash"]                 = {Name = "Shen",         spellname = "E | Shadow Dash"},
    ["TalonCutThroat"]                 = {Name = "Talon",        spellname = "E | Cutthroat"},
    ["UFSlash"]                        = {Name = "Malphite",     spellname = "R | Unstoppable Force"},
    ["UdyrBearStance"]                 = {Name = "Udyr",         spellname = "E | Bear Stance"},
    ["Valkyrie"]                       = {Name = "Corki",        spellname = "W | Valkyrie"},
    ["ViQ"]                            = {Name = "Vi",           spellname = "Q | Vault Breaker"},
    ["VolibearQ"]                      = {Name = "Volibear",     spellname = "Q | Rolling Thunder"},
    ["XenZhaoSweep"]                   = {Name = "XinZhao",      spellname = "E | Crescent Sweep"},
    ["YasuoDashWrapper"]               = {Name = "Yasuo",        spellname = "E | Sweeping Blade"},
    ["blindmonkqtwo"]                  = {Name = "LeeSin",       spellname = "Q | Resonating Strike"},
    ["khazixelong"]                    = {Name = "Khazix",       spellname = "E | Leap"},
    ["reksaieburrowed"]                = {Name = "RekSai",       spellname = "E | Tunnel"},
    ["TryndamereE"]                    = {Name = "Tryndamere",   spellname = "E | Spinning Slash"}
  }
  if menu then
    self:AddToMenu(menu)
  end
  if func then
    table.insert(self.callbacks, func)
  end
  Callback.Add("Tick",(function() self:Tick() end) )
  Callback.Add("ProcessSpell",(function(unit, spell) self:ProcessSpell(unit, spell) end) )
end

function ChallengerAntiGapcloser:AddToMenu(menu)
  self.Menu = menu
  local SpellAdded = false
  local EnemyNames = {}
  
  OnLoad(function()
    for _, enemy in pairs(GetEnemyHeroes()) do
      table.insert(EnemyNames, GetObjectName(enemy))
    end
  end)

  self.Menu:Menu("AntiGapcloser", "Anti-Gapcloser")
  self.Menu.AntiGapcloser:Boolean("Enabled", "Enabled", true)
  OnLoad(function()
    for i, spells in pairs(self.spells) do
      if table.contains(EnemyNames, spells.Name) then
        self.Menu.AntiGapcloser:Boolean(i, spells.Name.." | "..spells.spellname, true)
        SpellAdded = true
      end
   end

    if not SpellAdded then
      self.Menu.AntiGapcloser:Info("Info", "No spell available to interrupt")
    end
  end)
end

function ChallengerAntiGapcloser:TriggerCallbacks(unit, spell)
  for i, cb in pairs(self.callbacks) do
    cb(unit, spell)
  end
end

function ChallengerAntiGapcloser:ProcessSpell(unit, spell)
  if not self.Menu.AntiGapcloser.Enabled:Value() or GetTeam(unit) == GetTeam(myHero) or GetObjectType(unit) ~= Obj_AI_Hero then return end
  if not self.spells[spell.name] or (not self.Menu.AntiGapcloser[spell.name] or not self.Menu.AntiGapcloser[spell.name]:Value()) then return end
  local added = spell.target == myHero and true or false

  if GetObjectName(spell.target) == "" and ((GetDistanceSqr(unit) > GetDistanceSqr(Vector(unit) + 300 * (Vector(spell.endPos) - Vector(unit)):normalized()) or GetDistanceSqr(unit) > GetDistanceSqr(Vector(unit) + 100 * (Vector(spell.endPos) - Vector(unit)):normalized())))  then
    added = true
  end

  if added then
    local data = {unit = unit, spell = spell, endTime = GetTickCount() + 900}
    table.insert(self.activespells, data)
    self:TriggerCallbacks(data.unit, data)
  end
end

function ChallengerAntiGapcloser:Tick()
  for i = #self.activespells, 1, -1 do
    if self.activespells[i].endTime - GetTickCount() > 0 then
      self:TriggerCallbacks(self.activespells[i].unit, self.activespells[i])
    else
      table.remove(self.activespells, i)
    end
  end
end

class "ChallengerInterrupter"

function ChallengerInterrupter:__init(menu, func)
  self.callbacks = {}
  self.activespells = {}
  self.spells = {
    ["CaitlynAceintheHole"]         = {Name = "Caitlyn",      spellname = "R | Ace in the Hole"},
    ["Crowstorm"]                   = {Name = "FiddleSticks", spellname = "R | Crowstorm"},
    ["Drain"]                       = {Name = "FiddleSticks", spellname = "W | Drain"},
    ["GalioIdolOfDurand"]           = {Name = "Galio",        spellname = "R | Idol of Durand"},
    ["ReapTheWhirlwind"]            = {Name = "Janna",        spellname = "R | Monsoon"},
    ["KarthusFallenOne"]            = {Name = "Karthus",      spellname = "R | Requiem"},
    ["KatarinaR"]                   = {Name = "Katarina",     spellname = "R | Death Lotus"},
    ["LucianR"]                     = {Name = "Lucian",       spellname = "R | The Culling"},
    ["AlZaharNetherGrasp"]          = {Name = "Malzahar",     spellname = "R | Nether Grasp"},
    ["Meditate"]                    = {Name = "MasterYi",     spellname = "W | Meditate"},
    ["MissFortuneBulletTime"]       = {Name = "MissFortune",  spellname = "R | Bullet Time"},
    ["AbsoluteZero"]                = {Name = "Nunu",         spellname = "R | Absoulte Zero"},
    ["PantheonRJump"]               = {Name = "Pantheon",     spellname = "R | Jump"},
    ["PantheonRFall"]               = {Name = "Pantheon",     spellname = "R | Fall"},
    ["ShenStandUnited"]             = {Name = "Shen",         spellname = "R | Stand United"},
    ["Destiny"]                     = {Name = "TwistedFate",  spellname = "R | Destiny"},
    ["UrgotSwap2"]                  = {Name = "Urgot",        spellname = "R | Hyper-Kinetic Position Reverser"},
    ["VarusQ"]                      = {Name = "Varus",        spellname = "Q | Piercing Arrow"},
    ["VelkozR"]                     = {Name = "Velkoz",       spellname = "R | Lifeform Disintegration Ray"},
    ["InfiniteDuress"]              = {Name = "Warwick",      spellname = "R | Infinite Duress"},
    ["XerathLocusOfPower2"]         = {Name = "Xerath",       spellname = "R | Rite of the Arcane"}
  }
  if menu then
    self:AddToMenu(menu)
  end
  if func then
    table.insert(self.callbacks, func)
  end
  Callback.Add("Tick",(function() self:Tick() end))
  Callback.Add("ProcessSpell",(function(unit, spell) self:ProcessSpell(unit, spell) end))
end

function ChallengerInterrupter:AddToMenu(menu)
  self.Menu = menu
  local SpellAdded = false
  local EnemyNames = {}

  OnLoad(function()
    for _, enemy in ipairs(GetEnemyHeroes()) do
      table.insert(EnemyNames, GetObjectName(enemy))
    end
  end)

  self.Menu:Menu("Interrupter","Interrupter")
  self.Menu.Interrupter:Boolean("Enabled", "Enabled", true)
  OnLoad(function()
    for i, spells in pairs(self.spells) do
      if table.contains(EnemyNames, spells.Name) then
        self.Menu.Interrupter:Boolean(i, spells.Name.." | "..spells.spellname, true)
        SpellAdded = true
      end
    end

    if not SpellAdded then
     self.Menu.Interrupter:Info("Info", "No spell available to interrupt")
    end
  end)
end

function ChallengerInterrupter:TriggerCallbacks(unit, spell)
  for i, callback in pairs(self.callbacks) do
    callback(unit, spell)
  end
end

function ChallengerInterrupter:ProcessSpell(unit, spell)
  if not self.Menu.Interrupter.Enabled:Value() or GetTeam(unit) == GetTeam(myHero) or GetObjectType(unit) ~= Obj_AI_Hero or not self.spells[spell.name] or (self.Menu and not self.Menu.Interrupter[spell.name]:Value()) then return end
  local data = {unit = unit, spell = spell, endTime = GetTickCount() + 2500}
  table.insert(self.activespells, data)
  self:TriggerCallbacks(data.unit, data)
end

function ChallengerInterrupter:Tick()
  for i = #self.activespells, 1, -1 do
    if self.activespells[i].endTime - GetTickCount() > 0 then
      self:TriggerCallbacks(self.activespells[i].unit, self.activespells[i])
    else
      table.remove(self.activespells, i)
    end
  end
end

MODE_AUTO = 1
MODE_LESSATTACK = 2
MODE_LESSCAST = 3
MODE_LOWHP = 4
MODE_MOSTAD = 5
MODE_MOSTAP = 6
MODE_CLOSEST = 7
MODE_NEARMOUSE = 8
DAMAGETYPE_PHYSICAL = 1
DAMAGETYPE_MAGICAL = 2

class "ChallengerTargetSelector"

function ChallengerTargetSelector:__init(range, damageType, includeShields, from, focusSelected, menu, isOrb, mode)
  self.range = range or -1
  self.damageType = damageType or 1
  self.includeShields = includeShields or false
  self.from = from
  self.focusSelected = focusSelected or false
  self.Mode = mode or 1
  self.IsInvulnerable = function(target, damageType, includeShields)
    if GotBuff(target, "kindredrnodeathbuff") > 0 and GetPercentHP(target) <= 10 then
      return true
    end
    if damageType == 2 and includeShields then
      if GotBuff(target, "BlackShield") > 0 or GotBuff(target, "BansheesVeil") > 0 or GotBuff(target, "SivirShield") > 0 or GotBuff(target, "ShroudofDarkness") > 0 then
        return true
      end
    end
    return false
  end
  self.CalcDamage = function(target, DamageType, value) return DamageType == 1 and CalcPhysicalDamage(myHero, target, value) or CalcMagicalDamage(myHero, target, value) end
  self.IsValidTarget = function(target, range, damageType, includeShields, from)
    local includeShields = includeShields or false
    return self:ValidTarget(target) and GetDistanceSqr(GetOrigin(target), from or GetOrigin(myHero)) < math.pow(range <= 0 and (GetRange(myHero)+GetHitBox(myHero)+GetHitBox(target)) or range, 2) and not self.IsInvulnerable(target, damageType, includeShields)
  end
  self.sorting = {
    [1] = function(a,b) return self.CalcDamage(a, self.damageType, 100) / (1 + GetCurrentHP(a)) * self:GetPriority(a) > self.CalcDamage(b, self.damageType, 100) / (1 + GetCurrentHP(b)) * self:GetPriority(b) end,
    [2] = function(a,b) return self.CalcDamage(a, 1, 100) / (1 + GetCurrentHP(a)) * self:GetPriority(a) > self.CalcDamage(b, 1, 100) / (1 + GetCurrentHP(b)) * self:GetPriority(b) end,
    [3] = function(a,b) return self.CalcDamage(a, 2, 100) / (1 + GetCurrentHP(a)) * self:GetPriority(a) > self.CalcDamage(b, 2, 100) / (1 + GetCurrentHP(b)) * self:GetPriority(b) end,
    [4] = function(a,b) return GetCurrentHP(a) < GetCurrentHP(b) end,
    [5] = function(a,b) return a.totalDamage > b.totalDamage end,
    [6] = function(a,b) return GetBonusAP(a) > GetBonusAP(b) end,
    [7] = function(a,b) return GetDistance(a, self.from and self.from or GetOrigin(myHero)) < GetDistance(b, self.from and self.from or GetOrigin(myHero)) end,
    [8] = function(a,b) return GetDistance(a, mousePos) < GetDistance(b, mousePos) end
  }
  self.SelectedTarget = nil
  if menu then
    self.Menu = menu
    self.Menu:Menu("TargetSelector", "Target Selector")
    self.Menu.TargetSelector:Menu("FocusTargetSettings", "Focus Target Settings")
    self.Menu.TargetSelector.FocusTargetSettings:Boolean("FocusSelected", "Focus Selected Target", true)
    self.Menu.TargetSelector.FocusTargetSettings:Boolean("ForceFocusSelected", "Attack Only Selected Target", false)
    OnLoad(function() 
    self.Menu.TargetSelector:Boolean("AutoPriority", "Auto Arrange Priorities", true, function(var) 
      if var then
        for i, enemy in pairs(GetEnemyHeroes()) do
          self.Menu.TargetSelector["TargetSelector" ..GetObjectName(enemy).. "Priority"]:Value(self:GetDBPriority(GetObjectName(enemy)))
        end
      end
    end)
    for i, enemy in pairs(GetEnemyHeroes()) do
      self.Menu.TargetSelector:Slider("TargetSelector" ..GetObjectName(enemy).. "Priority", GetObjectName(enemy), self.Menu.TargetSelector.AutoPriority:Value() and self:GetDBPriority(GetObjectName(enemy)) or 1, 1, 5, 1)
    end
    end)
    self.Menu.TargetSelector:DropDown("TargetingMode", "Target Mode", 1, {"Auto Priority", "Less Attack", "Less Cast", "Lowest HP", "Most AD", "Most AP", "Closest", "Closest to Mouse"})
  end
  Callback.Add("WndMsg", function(msg, key) self:WndMsg(msg, key) end)
  if isOrb then Callback.Add("Draw", function() self:Draw() end) end
end

function ChallengerTargetSelector:ValidTarget(unit, range, checkTeam, from)
  local range = range or math.huge
  if unit == nil or not unit.valid or not IsVisible(unit) or IsDead(unit) or not IsTargetable(unit) or IsImmune(unit, myHero) or GetObjectBaseName(unit) == "WardCorpse" or (checkTeam and GetTeam(unit) == GetTeam(myHero)) then return false end
  return GetDistanceSqr(from and from or GetOrigin(myHero), GetOrigin(unit)) < range*range
end

function ChallengerTargetSelector:Draw()
  if (self.Menu and self.Menu.TargetSelector.FocusTargetSettings.FocusSelected:Value() or self.focusSelected) and self:ValidTarget(self.SelectedTarget) then
    DrawCircle(GetOrigin(self.SelectedTarget), 150, 2, 20, ARGB(255,255,0,0))
  end
end

function ChallengerTargetSelector:WndMsg(msg, key)
  if msg == WM_LBUTTONDOWN and (self.Menu and self.Menu.TargetSelector.FocusTargetSettings.FocusSelected:Value() or self.focusSelected) then
    local target, distance = nil, math.huge
    for i, enemy in pairs(GetEnemyHeroes()) do
      if self:ValidTarget(enemy) then
        local distance2 = GetDistanceSqr(enemy, GetMousePos())
        if distance2 < distance and distance2 < GetHitBox(enemy)^2.25 then
          target = enemy
          distance = distance2
        else
          self.SelectedTarget = nil
        end
      end
    end
    if target then self.SelectedTarget = target end
  end
end

function ChallengerTargetSelector:SetPriority(unit, prio)
  if not self.Menu.TargetSelector["TargetSelector" ..GetObjectName(unit).. "Priority"] then return end
  self.Menu.TargetSelector["TargetSelector" ..GetObjectName(unit).. "Priority"]:Value(math.max(1, math.min(5, prio)))
end

function ChallengerTargetSelector:GetPriority(unit)
  local prio = 1
  if self.Menu == nil then return prio end
  if self.Menu.TargetSelector["TargetSelector" ..GetObjectName(unit).. "Priority"] ~= nil then
    prio = self.Menu.TargetSelector["TargetSelector" ..GetObjectName(unit).. "Priority"]:Value()
  end
  if prio == 2 then
    return 1.5
  elseif prio == 3 then
    return 1.75
  elseif prio == 4 then
    return 2
  elseif prio == 5 then 
    return 2.5
  end
  return prio
end

function ChallengerTargetSelector:GetDBPriority(charName)
  local p1 = {"Alistar", "Amumu", "Bard", "Blitzcrank", "Braum", "Cho'Gath", "Dr. Mundo", "Garen", "Gnar", "Hecarim", "Janna", "Jarvan IV", "Leona", "Lulu", "Malphite", "Nami", "Nasus", "Nautilus", "Nunu", "Olaf", "Rammus", "Renekton", "Sejuani", "Shen", "Shyvana", "Singed", "Sion", "Skarner", "Sona", "Taric", "TahmKench", "Thresh", "Volibear", "Warwick", "MonkeyKing", "Yorick", "Zac", "Zyra"}
  local p2 = {"Aatrox", "Darius", "Elise", "Evelynn", "Galio", "Gangplank", "Gragas", "Irelia", "Jax", "Lee Sin", "Maokai", "Morgana", "Nocturne", "Pantheon", "Poppy", "Rengar", "Rumble", "Ryze", "Swain", "Trundle", "Tryndamere", "Udyr", "Urgot", "Vi", "XinZhao", "RekSai"}
  local p3 = {"Akali", "Diana", "Ekko", "Fiddlesticks", "Fiora", "Fizz", "Heimerdinger", "Jayce", "Kassadin", "Kayle", "Kha'Zix", "Lissandra", "Mordekaiser", "Nidalee", "Riven", "Shaco", "Vladimir", "Yasuo", "Zilean"}
  local p4 = {"Ahri", "Anivia", "Annie", "Ashe", "Azir", "Brand", "Caitlyn", "Cassiopeia", "Corki", "Draven", "Ezreal", "Graves", "Jinx", "Kalista", "Karma", "Karthus", "Katarina", "Kennen", "KogMaw", "Kindred", "Leblanc", "Lucian", "Lux", "Malzahar", "MasterYi", "MissFortune", "Orianna", "Quinn", "Sivir", "Syndra", "Talon", "Teemo", "Tristana", "TwistedFate", "Twitch", "Varus", "Vayne", "Veigar", "Velkoz", "Viktor", "Xerath", "Zed", "Ziggs", "Jhin", "Soraka"}
  if table.contains(p1, charName) then return 1 end
  if table.contains(p2, charName) then return 2 end
  if table.contains(p3, charName) then return 3 end
  return table.contains(p4, charName) and 4 or 1
end

function ChallengerTargetSelector:GetTarget()
  if (self.Menu and self.Menu.TargetSelector.FocusTargetSettings.FocusSelected:Value() or self.focusSelected) and self.IsValidTarget(self.SelectedTarget, (self.Menu and self.Menu.TargetSelector.FocusTargetSettings.ForceFocusSelected:Value()) and math.huge or self.range, self.damageType, self.includeShields, self.from) then
    return self.SelectedTarget
  end
  local targets = {}
  for i, enemy in pairs(GetEnemyHeroes()) do
    if self.IsValidTarget(enemy, self.range, self.damageType, self.includeShields, self.from) then
      table.insert(targets, enemy)
    end
  end
  self.SortMode = self.Mode or (self.Menu and self.Menu.TargetSelector.TargetingMode:Value() or 1)
  table.sort(targets, self.sorting[self.SortMode])
  return #targets > 0 and targets[1] or nil
end

SORT_HEALTH_ASC = function(a, b) return GetCurrentHP(a) < GetCurrentHP(b) end
SORT_HEALTH_DEC = function(a, b) return GetCurrentHP(a) > GetCurrentHP(b) end
SORT_MAXHEALTH_ASC = function(a, b) return GetMaxHP(a) < GetMaxHP(b) end
SORT_MAXHEALTH_DEC = function(a, b) return GetMaxHP(a) > GetMaxHP(b) end
TEAM_ALL = "All"
TEAM_ENEMY = "Enemy"
TEAM_ALLY = "Ally"
TEAM_JUNGLE = "Jungle"

class "ChallengerMinionManager"

function ChallengerMinionManager:__init(mode, range, from, sort)
  self.mode = mode
  self.range = range
  self.from = from
  self.sort = type(sort) == "function" and sort
  self.objects = {}
  self.minionTable = {
    All = {},
    Ally = {},
    Enemy = {},
    Jungle = {}
  }

  Callback.Add("ObjectLoad", function(Object) self:CreateObj(Object) end)
  Callback.Add("CreateObj", function(Object) self:CreateObj(Object) end)
  Callback.Add("DeleteObj", function(Object) self:DeleteObj(Object) end)
  self:update()
end

function ChallengerMinionManager:CreateObj(Object)
  if GetObjectType(Object) == Obj_AI_Minion and not IsDead(Object) and (GetObjectName(Object):find("Minion") or GetTeam(Object) == 300) then
    table.insert(self.minionTable["All"], Object)
    if GetTeam(Object) == MINION_ENEMY then
      table.insert(self.minionTable["Enemy"], Object)
    elseif GetTeam(Object) == MINION_ALLY then
      table.insert(self.minionTable["Ally"], Object)
    else
      table.insert(self.minionTable["Jungle"], Object)
    end
  end
end

function ChallengerMinionManager:DeleteObj(Object)
  for _, object in pairs(self.minionTable) do
    if object == Object then
      table.remove(self.minionTable, _)
    end
  end
end

function ChallengerMinionManager:update()
  self.objects = {}

  for _, object in pairs(self.minionTable[self.mode]) do
    if not IsDead(object) and GetDistance(object) <= self.range then
      table.insert(self.objects, object)
    end
  end

  if self.sort then 
    table.sort(self.objects, self.sort) 
  end
end

_G.ChallengerCommon = {AntiGapcloser = ChallengerAntiGapcloser, Interrupter = ChallengerInterrupter, TargetSelector = ChallengerTargetSelector, MinionManager = ChallengerMinionManager}
_G.ChallengerCommonLoaded = true
_G.SpellSlot = {Q = 0, W = 1, E = 2, R = 3, Summoner1 = 4, Summoner2 = 5, Item1 = 6, Item2 = 7, Item3 = 8, Item4 = 9, Item5 = 10, Item6 = 11, Trinket = 12, Recall = 13, OathSworn = 92, Interact = 94, Internal = 10000}
_G.Game = {MapID = GetMapID(), PrintChat = function(str) print(str) end, Version = GetGameVersion(), Ping = function() return GetLatency() end, CursorPos = function() return GetMousePos() end, CursorPos2D = function() return GetCursorPos() end, Time = function() return GetGameTimer() end}
