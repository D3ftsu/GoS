class "ChallengerHumanizer"

function ChallengerHumanizer:__init()
  self.LastMove = 0
  self.PassedMovements = 0
  self.BlockedMovements = 0
  self.TotalMovements = 0
  self.LastSpell = 0
  self.PassedSpells = 0
  self.BlockedSpells = 0
  self.TotalSpells = 0
  self:LoadMenu()
  Callback.Add("IssueOrder", function(order) self:IssueOrder(order) end)
  Callback.Add("SpellCast", function(spell) self:SpellCast(spell) end)
  Callback.Add("Draw", function() self:Draw() end)
end

function ChallengerHumanizer:LoadMenu()
  self.ChallengerHumanizerMenu = MenuConfig("ChallengerHumanizer","Challenger Humanizer")
  self.ChallengerHumanizerMenu:Boolean("EnabledMH", "Enable Movement Humanizer", true)
  self.ChallengerHumanizerMenu:Slider("MaxM", "Max Movements Per Second", 4, 4, 30, 1, function(max) self.MovementHumanizerTick = (1000 / (max + math.random(-1, 2))) end)
  self.MovementHumanizerTick = (1000 / (self.ChallengerHumanizerMenu.MaxM:Value() + math.random(-1, 2)))
  self.ChallengerHumanizerMenu:Boolean("EnabledSH", "Enable Spell Humanizer", true)
  self.ChallengerHumanizerMenu:Slider("MaxS", "Max Spells Per Second", 6, 4, 30, 1, function(max) self.SpellHumanizerTick = (1000 / (max + math.random(-1, 2))) end)
  self.SpellHumanizerTick = (1000 / (self.ChallengerHumanizerMenu.MaxS:Value() + math.random(-1, 2)))
  self.ChallengerHumanizerMenu:Boolean("Draw", "Draw Stats", true)
end

function ChallengerHumanizer:IssueOrder(order)
  if order.flag == 2 and self:Orbwalking() and self.ChallengerHumanizerMenu.EnabledMH:Value() and (not _G.CE or not _G.CE.IsEvading()) then
    if self.MovementHumanizerTick >= (GetTickCount() - self.LastMove) then
      BlockOrder()
      self.BlockedMovements = self.BlockedMovements + 1
    else
      self.LastMove = GetTickCount()
      self.PassedMovements = self.PassedMovements + 1
    end
    self.TotalMovements = self.TotalMovements + 1
  end
end

function ChallengerHumanizer:SpellCast(spell)
  if self:Orbwalking() and spell.spellID < 4 and self.ChallengerHumanizerMenu.EnabledSH:Value() then
    if self.SpellHumanizerTick >= (GetTickCount() - self.LastSpell) then
      BlockCast()
      self.BlockedSpells = self.BlockedSpells + 1
    else
      self.LastSpell = GetTickCount()
      self.PassedSpells = self.PassedSpells + 1
    end
    self.TotalSpells = self.TotalSpells + 1
  end
end

function ChallengerHumanizer:Draw()
  if not self.ChallengerHumanizerMenu.Draw:Value() then return end
  DrawText("Passed Movements : "..tostring(self.PassedMovements),20,40,280,ARGB(255,0,255,255))
  DrawText("Blocked Movements : "..tostring(self.BlockedMovements),20,40,300,ARGB(255,0,255,255))
  DrawText("Total Movements : "..tostring(self.TotalMovements),20,40,320,ARGB(255,0,255,255))
  DrawText("Passed Spells : "..tostring(self.PassedSpells),20,40,340,ARGB(255,0,255,255))
  DrawText("Blocked Spells : "..tostring(self.BlockedSpells),20,40,360,ARGB(255,0,255,255))
  DrawText("Total Spells : "..tostring(self.TotalSpells),20,40,380,ARGB(255,0,255,255))
end

function ChallengerHumanizer:Mode() 
  if IOW_Loaded then 
    return IOW:Mode() 
  elseif DAC then  
    return DAC:Mode() 
  elseif PW_Loaded then 
    return PW:Mode() 
  elseif GoSWalkLoaded and GoSWalk.CurrentMode then 
    return ({"Combo", "Harass", "LaneClear", "LastHit"})[GoSWalk.CurrentMode+1] 
  elseif AutoCarry_Loaded then 
    return DACR:Mode() 
  end 
  return "" 
end

function ChallengerHumanizer:Orbwalking()
  return self:Mode() ~= ""
end

ChallengerHumanizer()
