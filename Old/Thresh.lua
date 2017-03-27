if GetObjectName(GetMyHero()) ~= "Thresh" then return end
	
require('Inspired')
require('DeftLib')
require('IPrediction')

local ThreshMenu = MenuConfig("Thresh", "Thresh")
ThreshMenu:Menu("Combo", "Combo")
ThreshMenu.Combo:Boolean("Q", "Use Q", true)
ThreshMenu.Combo:Boolean("Q2", "Use Q2", true)
ThreshMenu.Combo:KeyBinding("Harass", "Use Q Only !", string.byte("C"))
ThreshMenu.Combo:Boolean("W", "Use W (Lantern)", true)
ThreshMenu.Combo:DropDown("ThrowLantern", "Throw lantern to: ", 1, {"Nearest Ally", "Selected Ally"})
ThreshMenu.Combo:Boolean("E", "Use E", true)
ThreshMenu.Combo:DropDown("EMode", "E Mode", 1, {"Pull", "Push"})
ThreshMenu.Combo:Boolean("R", "Use R", true)
ThreshMenu.Combo:Slider("Rmin", "Minimum Enemies in Range", 2, 1, 5, 1)

ThreshMenu:Menu("Misc", "Misc")
ThreshMenu.Misc:Boolean("Autoignite", "Auto Ignite", true)
ThreshMenu.Misc:Boolean("SaveAlly", "Save ally with lantern", true)
ThreshMenu.Misc:Slider("AroundAlly", "Save ally if enemies near: ", 2, 1, 5, 1)
ThreshMenu.Misc:Boolean("cc", "Auto lantern CCed allies", true)
ThreshMenu.Misc:Boolean("AntiDash", "Anti-Dash (Advanced Gap-Closer)", true)
ThreshMenu.Misc:Key("Lantern", "Throw Lantern", string.byte("G"))
ThreshMenu.Misc:Boolean("AutoR", "Auto R", true)
ThreshMenu.Misc:Slider("AutoRmin", "Minimum Enemies in Range", 3, 1, 5, 1)

ThreshMenu:Menu("Drawings", "Drawings")
ThreshMenu.Drawings:Boolean("Q", "Draw Q Range", true)
ThreshMenu.Drawings:Boolean("W", "Draw W Range", true)
ThreshMenu.Drawings:Boolean("E", "Draw E Range", true)
ThreshMenu.Drawings:Boolean("R", "Draw R Range", true)
ThreshMenu.Drawings:Boolean("DrawAlly", "Draw Selected Ally", true)
ThreshMenu.Drawings:Boolean("DrawText", "Draw Selected Text", true)

ThreshMenu:Menu("Interrupt", "Interrupt")
ThreshMenu.Interrupt:Menu("SupportedSpells", "Supported Spells")
ThreshMenu.Interrupt.SupportedSpells:Boolean("Q", "Use Q", true)
ThreshMenu.Interrupt.SupportedSpells:Boolean("E", "Use E", true)

DelayAction(function()
  local str = {[_Q] = "Q", [_W] = "W", [_E] = "E", [_R] = "R"}
  for i, spell in pairs(CHANELLING_SPELLS) do
    for _,k in pairs(GetEnemyHeroes()) do
      if spell["Name"] == GetObjectName(k) then
      ThreshMenu.Interrupt:Boolean(GetObjectName(k).."Inter", "On "..GetObjectName(k).." "..(type(spell.Spellslot) == 'number' and str[spell.Spellslot]), true)
      end
    end
  end
end, 1)

OnProcessSpell(function(unit, spell)
  if GetObjectType(unit) == Obj_AI_Hero and GetTeam(unit) ~= GetTeam(myHero) then
    if CHANELLING_SPELLS[spell.name] then
      if ValidTarget(unit, 1040) and IsReady(_Q) and GetObjectName(unit) == CHANELLING_SPELLS[spell.name].Name and ThreshMenu.Interrupt[GetObjectName(unit).."Inter"]:Value() and ThreshMenu.Interrupt.SupportedSpells.Q:Value() then
      Cast(_Q,unit)
      elseif ValidTarget(unit, 515) and IsReady(_E) and GetObjectName(unit) == CHANELLING_SPELLS[spell.name].Name and ThreshMenu.Interrupt[GetObjectName(unit).."Inter"]:Value() and ThreshMenu.Interrupt.SupportedSpells.E:Value() then
      Cast(_E,unit)
      end
    end
  end
end)

local EPred = IPrediction.Prediction({name=Flay, range=515, speed=math.huge, delay=0.3, width=160, type="linear", collision=false})
local target1 = TargetSelector(1040,TARGET_LESS_CAST_PRIORITY,DAMAGE_MAGIC,true,false)
local ally1 = TargetSelector(950,TARGET_LESS_CAST_PRIORITY,DAMAGE_MAGIC,true,true)

OnDraw(function(myHero)
local pos = GetOrigin(myHero)
if ThreshMenu.Drawings.Q:Value() then DrawCircle(pos,1000,1,25,GoS.Pink) end
if ThreshMenu.Drawings.W:Value() then DrawCircle(pos,950,1,25,GoS.Yellow) end
if ThreshMenu.Drawings.E:Value() then DrawCircle(pos,515,1,25,GoS.Blue) end
if ThreshMenu.Drawings.R:Value() then DrawCircle(pos,420,1,25,GoS.Green) end
if ThreshMenu.Combo.ThrowLantern:Value() == 2 and ThreshMenu.Drawings.DrawAlly:Value() and Wtarget ~= nil then 
  DrawCircle(GetOrigin(Wtarget),100,1,25,52224)
  if ThreshMenu.Drawings.DrawText:Value() then
  DrawText("Selected Ally: " .. GetObjectName(Wtarget), 18, 100, 100, 4294967040) 
  end
end
end)

OnTick(function(myHero)
    local target = GetCurrentTarget()
    local Qtarget = target1:GetTarget()
    local Wtarget = ally1:GetTarget()
	
    if IOW:Mode() == "Combo" then
	
      if IsReady(_E) and ThreshMenu.Combo.E:Value() and ValidTarget(target,515) then
        if ThreshMenu.Combo.EMode:Value() == 1 then
        CastE(target)
	elseif ThreshMenu.Combo.EMode:Value() == 2 then
        Cast(_E,target)
	end
      end
      
      if IsReady(_R) and ThreshMenu.Combo.R:Value() and EnemiesAround(GetOrigin(myHero),450) >= ThreshMenu.Combo.Rmin:Value() then
      CastSpell(_R)
      end
	  
      if IsReady(_W) and ThreshMenu.Combo.W:Value() then
        if ThreshMenu.Combo.ThrowLantern:Value() == 1 then
        CastW()
	elseif ThreshMenu.Combo.ThrowLantern:Value() == 2 then
        CastW2()
	end
      end
	  
      if IsReady(_Q) and ThreshMenu.Combo.Q:Value() then
      Cast(_Q,Qtarget)
      end
	  
      if ThreshMenu.Combo.Q2:Value() then
      CastQ2()
      end
	
    end
  
    if ThreshMenu.Combo.Harass:Value() then
    Cast(_Q,Qtarget)
    end
  
    if IsReady(_W) and ThreshMenu.Misc.Lantern:Value() then
    MoveToXYZ(GetMousePos())
    CastLantern()
    end
	
    if ThreshMenu.Misc.AutoR:Value() and IsReady(_R) and EnemiesAround(GetOrigin(myHero), 450) >= ThreshMenu.Misc.AutoRmin:Value() then
    CastSpell(_R)
    end
	
    if IsReady(_W) then
      if ThreshMenu.Misc.SaveAlly:Value() then
        for _,Ally in pairs(GetAllyHeroes()) do
          if IsObjectAlive(Ally) and GetPercentHP(Ally) <= 30 and IsReady(_W) and EnemiesAround(GetOrigin(Ally), 950) >= ThreshMenu.Misc.AroundAlly:Value() and GetDistance(Ally) <= 950 then
   	  CastSkillShot(_W,GetOrigin(FindLowestAlly()))
          end
        end
      end
      if ThreshMenu.Misc.cc:Value() then
        for _,Ally in ipairs(GetAllyHeroes()) do
          if IsObjectAlive(Ally) and GetDistance(Ally) <= 950 and GetPercentHP(Ally) <= 30 then
            local x,y,z = IPrediction.IsUnitStunned(Ally, 950, math.huge, 0.5, 315, myHero)
            if x and GetDistance(z) <= 950 and IsReady(_W) then
            CastSkillShot(_W,GetOrigin(Ally))
            end
          end
        end
      end
    end
	
    for i,enemy in pairs(GetEnemyHeroes()) do
      if Ignite and ThreshMenu.Misc.Autoignite:Value() then
        if IsReady(Ignite) and 20*GetLevel(myHero)+50 > GetCurrentHP(enemy)+GetDmgShield(enemy)+GetHPRegen(enemy)*3 and ValidTarget(enemy, 600) then
        CastTargetSpell(enemy, Ignite)
        end
      end
    end
	
end)

IPrediction.OnDash(function(target, pos)
  if IsReady(_E) and ValidTarget(target, 515) and GetDistance(pos) < 125 and ThreshMenu.Misc.AntiDash:Value() then
  local EPos = Vector(myHero) + (Vector(myHero) - Vector(pos))
  CastSkillShot(_E, EPos)
  end
end, EPred)	   

function CastE(unit)
  local EPos = Vector(myHero) + (Vector(myHero) - Vector(unit))
  CastSkillShot(_E,EPos)
end

function CastW()
  if FindNearestAlly() and GetDistance(FindNearestAlly()) < 950 and GetCastName(myHero,_Q) == "threshqleap" then
    CastSkillShot(_W, GetOrigin(FindNearestAlly()))
  end
end

function CastW2()
  if Wtarget ~= nil and GetDistance(Wtarget) < 950 and GetCastName(myHero,_Q) == "threshqleap" then
    CastSkillShot(_W,GetOrigin(Wtarget))
  end
end

function CastQ2()
  if GetCastName(myHero,_Q) == "threshqleap" then
    CastSpell(_Q)
  end
end

function CastLantern()
  if ThreshMenu.Combo.ThrowLantern:Value() == 2 and Wtarget ~= nil and GetDistance(Wtarget) < 950 and IsObjectAlive(Wtarget) then
  CastSkillShot(_W,GetOrigin(Wtarget))
  elseif ThreshMenu.Combo.ThrowLantern:Value() == 1 and GetDistance(FindNearestAlly()) < 950 then
  CastSkillShot(_W,GetOrigin(FindNearestAlly()))
  end
end
	
function FindLowestAlly()
  LowestAlly = nil
  for _,Ally in pairs(GetAllyHeroes()) do
    if IsObjectAlive(Ally) and GetDistance(Ally) <= 950 then
      if LowestAlly == nil then
        LowestAlly = Ally
      elseif GetPercentHP(Ally) < GetPercentHP(LowestAlly) then
        LowestAlly = Ally
      end
    end
  end
  return LowestAlly
end

function FindNearestAlly()
  local NearestAlly = nil
  for _,Ally in pairs(GetAllyHeroes()) do
    if NearestAlly == nil and IsObjectAlive(Ally) then
      NearestAlly = Ally
    elseif IsObjectAlive(Ally) and GetDistance(Ally) < GetDistance(NearestAlly) then
      NearestAlly = Ally
    end
  end
  return NearestAlly
end

AddGapcloseEvent(_E, 515, false, ThreshMenu)

PrintChat(string.format("<font color='#1244EA'>Thresh:</font> <font color='#FFFFFF'> By Deftsu Loaded, Have A Good Game ! </font>"))
PrintChat("Have Fun Using D3Carry Scripts: " ..GetObjectBaseName(myHero)) 
