local spellstr = {[0] = "Q", [1] = "W", [2] = "E", [3] = "R"}

class "ChallengerSmite"

function ChallengerSmite:__init()
  self.Smite = GetCastName(myHero, 4):lower():find("smite") and 4 or (GetCastName(myHero, 5):lower():find("smite") and 5 or nil)
  if not self.Smite then PrintChat("<b><font color='#EE2EC'>Challenger Smite - </font></b> <font color='#ff0000'> Smite Not Found !</font>") return end
  if mapID ~= SUMMONERS_RIFT and mapID ~= TWISTED_TREELINE then PrintChat("<b><font color='#EE2EC'>Challenger Smite - </font></b> <font color='#ff0000'> Map Not Supported !</font>") return end
  PrintChat("<b><font color='#EE2EC'>Challenger Smite - </font></b> Loaded v" ..ChallengerSmiteVersion)
  require("DamageLib")
  self.Spells = {}
  self.MobManager = {}
  self.Objects = {
    [SUMMONERS_RIFT] = {
      {RealName = "Baron Nashor", ObjectName = "SRU_Baron"},
      {RealName = "Rift Herald", ObjectName = "SRU_RiftHerald"},
      {RealName = "Blue Sentinel", ObjectName = "SRU_Blue"},
      {RealName = "Red Brambleback", ObjectName = "SRU_Red"},
      {RealName = "Water Dragon", ObjectName = "SRU_Dragon_Water"},
      {RealName = "Fire Dragon", ObjectName = "SRU_Dragon_Fire"},
      {RealName = "Earth Dragon", ObjectName = "SRU_Dragon_Earth"},
      {RealName = "Air Dragon", ObjectName = "SRU_Dragon_Air"},
      {RealName = "Elder Dragon", ObjectName = "SRU_Dragon_Elder"},
      {RealName = "Crimson Raptor", ObjectName = "SRU_Razorbeak", DisabledByDefault = true},
      {RealName = "Greater Murk Wolf", ObjectName = "SRU_Murkwolf", DisabledByDefault = true},
      {RealName = "Gromp", ObjectName = "SRU_Gromp", DisabledByDefault = true},
      {RealName = "Rift Scuttler", ObjectName = "Sru_Crab", DisabledByDefault = true},
      {RealName = "Ancient Krug", ObjectName = "SRU_Krug", DisabledByDefault = true}
    },
    [TWISTED_TREELINE] = {
      {RealName = "Vilemaw", ObjectName = "TT_Spiderboss"},
      {RealName = "Big Golem", ObjectName = "TTNGolem"},
      {RealName = "Giant Wolf", ObjectName = "TTNWolf"},
      {RealName = "Wraith", ObjectName = "TTNWraith"}
    }
  }
  self:LoadSpellData()
  self:LoadMenu()
  Callback.Add("Draw", function() self:Loop() self:Draw() end)
  Callback.Add("CreateObj", function(Object) self:CreateObj(Object) end)
  Callback.Add("DeleteObj", function(Object) self:DeleteObj(Object) end)
end

function ChallengerSmite:LoadSpellData()
  self.SpellData = {
    {ChampionName = "Aatrox", Range = 650, Slot = 0, CastType = "Skillshot"},
    {ChampionName = "Alistar", Range = 365, Slot = 0, CastType = "Self"},
    {ChampionName = "Amumu", Range = 350, Slot = 2, CastType = "Self"},
    {ChampionName = "ChoGath", Range = 325, Slot = 3, CastType = "Targetted"},
    {ChampionName = "Diana", Range = 900, Slot = 0, CastType = "Skillshot"},
    {ChampionName = "Ekko", Range = 1075, Slot = 0, CastType = "Skillshot"},
    {ChampionName = "Elise", Range = 475, Slot = 0, CastType = "Targetted"},
    {ChampionName = "Evelynn", Range = 225, Slot = 2, CastType = "Targetted"},
    {ChampionName = "Fiddlesticks", Range = 750, Slot = 2, CastType = "Targetted"},
    {ChampionName = "Fizz", Range = 550, Slot = 0, CastType = "Targetted"},
    {ChampionName = "Gragas", Range = 600, Slot = 2, CastType = "Skillshot"},
    {ChampionName = "Hecarim", Range = 350, Slot = 0, CastType = "Self"},
    {ChampionName = "Irelia", Range = 750, Slot = 0, CastType = "Targetted"},
    {ChampionName = "JarvanIV", Range = 770, Slot = 0, CastType = "Skillshot"},
    {ChampionName = "Jax", Range = 700, Slot = 0, CastType = "Targetted"},
    {ChampionName = "KhaZix", Range = 325, Slot = 0, CastType = "Targetted"},
    {ChampionName = "LeeSin", Range = 1300, Stage = 2, Slot = 0, CastType = "Self"},
    {ChampionName = "Maokai", Range = 600, Slot = 0, CastType = "Skillshot"},
    {ChampionName = "MasterYi", Range = 600, Slot = 0, CastType = "Targetted"},
    {ChampionName = "Mundo", Range = 1050, Slot = 0, CastType = "Skillshot"},
    {ChampionName = "Nocturne", Range = 1200, Slot = 0, CastType = "Skillshot"},
    {ChampionName = "Nunu", Range = 300, Slot = 0, CastType = "Targetted"},
    {ChampionName = "Olaf", Range = 325, Slot = 2, CastType = "Targetted"},
    {ChampionName = "Pantheon", Range = 600, Slot = 0, CastType = "Targetted"},
    {ChampionName = "Poppy", Range = 525, Slot = 2, CastType = "Targetted"},
    {ChampionName = "Quinn", Range = 1050, Slot = 0, CastType = "Skillshot"},
    {ChampionName = "Sejuani", Range = 625, Slot = 0, CastType = "Skillshot"},
    {ChampionName = "Shaco", Range = 625, Slot = 2, CastType = "Targetted"},
    {ChampionName = "TahmKench", Range = 875, Slot = 0, CastType = "Skillshot"},
    {ChampionName = "Tryndamere", Range = 660, Slot = 2, CastType = "Skillshot"},
    {ChampionName = "Twitch", Range = 950, Slot = 2, CastType = "Self"},
    {ChampionName = "Volibear", Range = 400, Slot = 1, CastType = "Targetted"},
    {ChampionName = "Warwick", Range = 400, Slot = 0, CastType = "Targetted"},
    {ChampionName = "XinZhao", Range = 600, Slot = 2, CastType = "Targetted"},
    {ChampionName = "Zac", Range = 550, Slot = 0, CastType = "Skillshot"},
  }
  for i, spell in pairs(self.SpellData) do
    if spell.ChampionName == GetObjectName(myHero) then
      table.insert(self.Spells, spell)
    end
  end
  self.SpellData = {}
end

function ChallengerSmite:LoadMenu()
  self.Menu = MenuConfig("ChallengerSmite", "Challenger Smite")
  self.Menu:KeyBinding("Enabled", "Enabled", string.byte("M"))
  self.Menu:KeyBinding("Combo", "Combo Key", 32)
  self.Menu:Boolean("Charge", "Save 1 Charge For Jungle", true)
  self.Menu:Menu("SpellSmite", "Spell Smite")
  self.Menu.SpellSmite:Boolean("Enabled", "Enabled", true)
  for i, spell in pairs(self.Spells) do
    self.Menu.SpellSmite:Boolean(spellstr[spell.Slot], "Use "..spellstr[spell.Slot])
  end
  self.Menu:Menu("Camps", "Camps")
  for i, mob in pairs(self.Objects[mapID]) do
    self.Menu.Camps:Boolean(mob.ObjectName, mob.RealName, not mob.DisabledByDefault)
  end
  self.Menu:Menu("Smote", "Champion Smite")
  self.Menu.Smote:Boolean("Enabled", "Enabled", true)
  for i, enemy in pairs(GetEnemyHeroes()) do
    self.Menu.Smote:DropDown(GetObjectName(enemy), GetObjectName(enemy), 3, {"Disabled", "Combo", "Killsteal"})
  end
  self.Menu:Menu("Drawings", "Drawings")
  self.Menu.Drawings:Boolean("Status", "Draw Status", true)
  self.Menu.Drawings:Boolean("Range", "Draw Range", true)
end

function ChallengerSmite:Draw()
  if IsDead(myHero) then return end
  if not self.Menu.Drawings.Status:Value() and not self.Menu.Drawings.Range:Value() then return end
  local wts = WorldToScreen(1, GetOrigin(myHero))
  if wts.flag then
    if self.Menu.Drawings.Status:Value() then
      if self.Menu.Enabled:Value() then
        if CanUseSpell(myHero, self.Smite) == READY then
          DrawText("Smite: ON", 20, wts.x-40, wts.y+60, ARGB(200,248,248,255))
        else
          DrawText("Smite: Cooldown", 20, wts.x-40, wts.y+60, ARGB(200,200,0,0))
        end
      else
        DrawText("Smite: OFF", 20, wts.x-40, wts.y+60, ARGB(200,255,0,0))
      end
    end
    if self.Menu.Drawings.Range:Value() then
      DrawCircle(GetOrigin(myHero), 570, 2, 20, CanUseSpell(myHero, self.Smite) == READY and ARGB(200,0,255,0) or ARGB(200,255,0,0))
    end
  end
end

function ChallengerSmite:Loop()
  if IsDead(myHero) or not self.Menu.Enabled:Value() then return end
  for i, mob in pairs(self.MobManager) do
    if ValidTarget(mob, 500+GetHitBox(myHero)) and GotBuff(mob, "kindredrnodeathbuff") == 0 and self.Menu.Camps[GetObjectName(mob)]:Value() then
      if self.Menu.SpellSmite.Enabled:Value() then
        self:SpellSmite(mob)
      end
      if GetCurrentHP(mob) < getdmg("SMITE", mob) and CanUseSpell(myHero, self.Smite) == READY then
        CastTargetSpell(mob, self.Smite)
      end
    end
  end
  for i, enemy in pairs(GetEnemyHeroes()) do
    if self.Menu.Smote[GetObjectName(enemy)]:Value() ~= 1 and (not self.Menu.Charge:Value() or GetSpellData(myHero, self.Smite).ammo == 2) and ValidTarget(enemy, 570) and GotBuff(enemy, "kindredrnodeathbuff") == 0 then
      if self.Menu.Smote[GetObjectName(enemy)]:Value() == 2 and self.Menu.Combo:Value() and (GetCastName(myHero, self.Smite) == "s5_summonersmiteplayerganker" or GetCastName(myHero, self.Smite) == "s5_summonersmiteduel") then
        CastTargetSpell(enemy, self.Smite)
      else
        if GetCastName(myHero, self.Smite) == "s5_summonersmiteplayerganker" and GetCurrentHP(enemy)+GetGetDmgShield(enemy) < getdmg("SMITE", enemy) then
          CastTargetSpell(enemy, self.Smite)
        end
      end
    end
  end
end

function ChallengerSmite:SpellSmite(unit)
  for i, spell in pairs(self.Spells) do
    if self.Menu.SpellSmite[spellstr[spell.Slot]]:Value() and ValidTarget(unit, spell.Range) and getdmg(spellstr[spell.Slot], unit)+(CanUseSpell(myHero,self.Smite) == READY and getdmg("SMITE",unit) or 0) > GetCurrentHP(unit) and CanUseSpell(myHero, spell.Slot) == READY then
      if spell.CastType == "Self" then
        CastSpell(spell.Slot)
      elseif spell.CastType == "Targetted" then
        CastTargetSpell(unit, spell.Slot)
      elseif spell.CastType == "Skillshot" then
        CastSkillshot(spell.Slot, GetOrigin(unit))
      end
    end
  end
end

function ChallengerSmite:CreateObj(Object)
  if GetTeam(Object) ~= 300 or GetObjectBaseName(Object):lower():find("mini") or GetObjectBaseName(Object):lower():find("respawn") then return end
  table.insert(self.MobManager, Object)
end

function ChallengerSmite:DeleteObj(Object)
  if GetTeam(Object) ~= 300 then return end
  for i, mob in pairs(self.MobManager) do
    if mob == Object then
      table.remove(self.MobManager, i)
    end
  end
end

OnLoad(function()
  ChallengerSmite()
end)
