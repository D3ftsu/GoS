if GetObjectName(GetMyHero()) ~= "Jinx" then return end

require('Inspired')
require('IPrediction')
require('DeftLib')
require('DamageLib')

local JinxMenu = MenuConfig("Jinx", "Jinx")
JinxMenu:Menu("Combo", "Combo")
JinxMenu.Combo:Menu("Q", "Q Settings")
JinxMenu.Combo.Q:Boolean("useQ", "Use Q", true)
JinxMenu.Combo.Q:Boolean("Qrange", "Swap Q for Range", true)
JinxMenu.Combo.Q:Boolean("Qaoe", "Swap Q for AOE", true)
JinxMenu.Combo.Q:Boolean("Qmana", "Swap to Minigun if low mana", true)
JinxMenu.Combo.Q:Slider("mana", "Minimum Mana", 20, 0, 100, 1)
JinxMenu.Combo.Q:Boolean("noenemy", "Swap to Minigun if no enemy", true)
JinxMenu.Combo:Menu("W", "W Settings")
JinxMenu.Combo.W:Boolean("useW", "Use W", true)
JinxMenu.Combo.W:Slider("Min", "Minimum W Range", 650, 0, 1200, 1)
JinxMenu.Combo:Menu("E", "E Settings")
JinxMenu.Combo.E:Boolean("useE", "Use E", true)
JinxMenu.Combo.E:Boolean("ECC", "Use Auto E on Slow/Immobile/Dash", true)
JinxMenu.Combo:Menu("R", "R Settings")
JinxMenu.Combo.R:Boolean("OverKill", "Overkill Check", true)
JinxMenu.Combo.R:Slider("Min", "Minimum R Range", 600, 0, 1500, 1)
JinxMenu.Combo.R:Slider("Max", "Maximum R Range", 1700, 0, 4000, 1)
JinxMenu.Combo:KeyBinding("FireKey", "Ult Fire Key (2000 Range)", string.byte("T"))
JinxMenu.Combo:Boolean("Items", "Use Items", true)
JinxMenu.Combo:Slider("myHP", "if HP % <", 50, 0, 100, 1)
JinxMenu.Combo:Slider("targetHP", "if Target HP % >", 20, 0, 100, 1)
JinxMenu.Combo:Boolean("QSS", "Use QSS", true)
JinxMenu.Combo:Slider("QSSHP", "if My Health % <", 75, 0, 100, 1)

JinxMenu:Menu("Harass", "Harass")
JinxMenu.Harass:Menu("Q", "Q Settings")
JinxMenu.Harass.Q:Boolean("useQ", "Use Q", true)
JinxMenu.Harass.Q:Boolean("Qrange", "Swap Q for Range", true)
JinxMenu.Harass.Q:Boolean("Qaoe", "Swap Q for AOE", true)
JinxMenu.Harass.Q:Boolean("Qmana", "Swap to Minigun if low mana", true)
JinxMenu.Harass.Q:Slider("mana", "Minimum Mana", 20, 0, 100, 1)
JinxMenu.Harass.Q:Boolean("noenemy", "Swap to Minigun if no enemy", true)
JinxMenu.Harass:Menu("W", "W Settings")
JinxMenu.Harass.W:Boolean("useW", "Use W", true)
JinxMenu.Harass.W:Slider("MinW", "Minimum W Range", 650, 0, 1200, 1)
JinxMenu.Harass.W:Slider("Mana", "if Mana % >", 30, 0, 80, 1)

JinxMenu:Menu("Killsteal", "Killsteal")
JinxMenu.Killsteal:Boolean("W", "Killsteal with W", true)
JinxMenu.Killsteal:Boolean("R", "Killsteal with R", true)

if Ignite ~= nil then 
JinxMenu:Menu("Misc", "Misc")
JinxMenu.Misc:Boolean("AutoIgnite", "Auto Ignite", true) 
end
	
JinxMenu:Menu("Lasthit", "Lasthit")
JinxMenu.Lasthit:Boolean("Farm", "Always swap to Minigun", true)

JinxMenu:Menu("LaneClear", "LaneClear")
JinxMenu.LaneClear:Boolean("Farm", "Always swap to Minigun", true)

JinxMenu:Menu("Drawings", "Drawings")
JinxMenu.Drawings:Boolean("W", "Draw W Range", true)
JinxMenu.Drawings:Boolean("E", "Draw E Range", true)

OnDraw(function(myHero)
local pos = GetOrigin(myHero)
if JinxMenu.Drawings.W:Value() then DrawCircle(pos,1500,1,0,GoS.Yellow) end
if JinxMenu.Drawings.E:Value() then DrawCircle(pos,920,1,0,GoS.Blue) end
end)

local target1 = TargetSelector(1480,TARGET_LESS_CAST_PRIORITY,DAMAGE_PHYSICAL,true,false)
local target2 = TargetSelector(960,TARGET_LESS_CAST_PRIORITY,DAMAGE_PHYSICAL,true,false)
local target3 = TargetSelector(4000,TARGET_LESS_CAST_PRIORITY,DAMAGE_PHYSICAL,true,false)
local EPred = IPrediction.Prediction({name="JinxE", range=900, speed=1750, delay=0.7658, width=120, type="linear", collision=false})
local TimeToSwap = true
local Minigun = false

OnUpdateBuff(function(unit,buff)
  if unit == myHero and buff.Name == "jinxqicon" then
  Minigun = true
  end
end)

OnRemoveBuff(function(unit,buff)
  if unit == myHero and buff.Name == "jinxqicon" then
  Minigun = false
  end
end)

OnTick(function(myHero)
    local target = GetCurrentTarget()
    local QSS = GetItemSlot(myHero,3140) > 0 and GetItemSlot(myHero,3140) or GetItemSlot(myHero,3139) > 0 and GetItemSlot(myHero,3139) or nil
    local BRK = GetItemSlot(myHero,3153) > 0 and GetItemSlot(myHero,3153) or GetItemSlot(myHero,3144) > 0 and GetItemSlot(myHero,3144) or nil
    local YMG = GetItemSlot(myHero,3142) > 0 and GetItemSlot(myHero,3142) or nil
    local Wtarget = target1:GetTarget()
    local Etarget = target2:GetTarget()
    local Rtarget = target3:GetTarget()
    local RangeCheck = 25*GetCastLevel(myHero, _Q) + 50 + 600

    if IsReady(_E) and ValidTarget(Etarget, 960) and JinxMenu.Combo.E.ECC:Value() then
      local hit, pos = EPred:Predict(Etarget)
      if hit >= 4 then
      CastSkillShot(_E, pos)
      end
    end

    if IOW:Mode() == "Combo" then
	
      local IOWTarget = IOW:GetTarget()
	
      if IsReady(_Q) and JinxMenu.Combo.Q.useQ:Value() then
        if Minigun and TimeToSwap then 
	  if JinxMenu.Combo.Q.Qrange:Value() and ValidTarget(target, RangeCheck) and EnemiesAround(GetOrigin(myHero), 525) == 0 then
            if GetDistance(target) > 600 and Minigun then
            CastSpell(_Q)
	    end
            if GetPercentMP(myHero) >= JinxMenu.Combo.Q.mana:Value() and JinxMenu.Combo.Q.Qaoe:Value() and ValidTarget(IOWTarget) and EnemiesAround(GetOrigin(IOWTarget), 150) > 1 then
            CastSpell(_Q)
            end
          end
	elseif not Minigun and TimeToSwap and JinxMenu.Combo.Q.Qrange:Value() and ValidTarget(target) and GetDistance(target) <= 550 then
	CastSpell(_Q)
        end
      end 
	
      if IsReady(_W) and JinxMenu.Combo.W.useW:Value() and ValidTarget(target, 1480) and GetDistance(target) > JinxMenu.Combo.W.Min:Value() then
      Cast(_W,Wtarget)
      end
	
      if IsReady(_E) and JinxMenu.Combo.E.useE:Value() then
      Cast(_E,Etarget)
      end
	  
      if JinxMenu.Combo.Q.noenemy:Value() and EnemiesAround(GetOrigin(myHero), RangeCheck) == 0 and not Minigun then
      CastSpell(_Q)
      end

      if QSS and IsReady(QSS) and JinxMenu.Combo.QSS:Value() and IsImmobile(myHero) or IsSlowed(myHero) or toQSS and GetPercentHP(myHero) < JinxMenu.Combo.QSSHP:Value() then
      CastSpell(QSS)
      end

    end

    if IOW:Mode() == "Harass" then
	
      local IOWTarget = IOW:GetTarget()
	
      if IsReady(_Q) and JinxMenu.Harass.Q.useQ:Value() then
        if Minigun and TimeToSwap then 
	  if JinxMenu.Harass.Q.Qrange:Value() and ValidTarget(target, RangeCheck) and EnemiesAround(GetOrigin(myHero), 525) == 0 then
            if GetDistance(target) > 600 and Minigun then
            CastSpell(_Q)
	    end
            if GetPercentMP(myHero) >= JinxMenu.Harass.Q.mana:Value() and JinxMenu.Harass.Q.Qaoe:Value() and ValidTarget(IOWTarget) and EnemiesAround(GetOrigin(IOWTarget), 150) > 1 then
            CastSpell(_Q)
            end
          end
        elseif not Minigun and TimeToSwap and JinxMenu.Harass.Q.Qrange:Value() and ValidTarget(target) and GetDistance(target) <= 550 then
	CastSpell(_Q)
	end
      end 
	
      if IsReady(_W) and JinxMenu.Harass.W.useW:Value() and ValidTarget(target, 1480) and GetDistance(target) > JinxMenu.Harass.W.Min:Value() then
      Cast(_W,Wtarget)
      end
	  
      if JinxMenu.Harass.Q.noenemy:Value() and EnemiesAround(GetOrigin(myHero), RangeCheck) == 0 and not Minigun then
      CastSpell(_Q)
      end
		
    end

    if IOW:Mode() == "LastHit" and not Minigun and JinxMenu.Lasthit.Farm:Value() then
    CastSpell(_Q)
    end
  
    if IOW:Mode() == "LaneClear" and not Minigun and JinxMenu.LaneClear.Farm:Value() then
    CastSpell(_Q)
    end
  
    for i,enemy in pairs(GetEnemyHeroes()) do
	
	if IOW:Mode() == "Combo" then	
	  if BRK and IsReady(BRK) and JinxMenu.Combo.Items:Value() and ValidTarget(enemy, 550) and GetPercentHP(myHero) < JinxMenu.Combo.myHP:Value() and GetPercentHP(enemy) > JinxMenu.Combo.targetHP:Value() then
          CastTargetSpell(enemy, BRK)
          end

          if YMG and IsReady(YMG) and JinxMenu.Combo.Items:Value() and ValidTarget(enemy, 600) then
          CastSpell(YMG)
          end	
        end
		
	if Ignite and JinxMenu.Misc.AutoIgnite:Value() then
          if IsReady(Ignite) and 20*GetLevel(myHero)+50 > GetCurrentHP(enemy)+GetDmgShield(enemy)+GetHPRegen(enemy)*3 and ValidTarget(enemy, 600) then
          CastTargetSpell(enemy, Ignite)
          end
        end
		
        if IsReady(_W) and ValidTarget(enemy, 1480) and JinxMenu.Killsteal.W:Value() and GetDistance(enemy) >= JinxMenu.Combo.W.Min:Value() and GetHP(enemy) < getdmg("W",enemy) then  
        Cast(_W,enemy)
	end
	
	if IsReady(_R) and ValidTarget(enemy, JinxMenu.Combo.R.Max:Value()) and JinxMenu.Killsteal.R:Value() and GetDistance(enemy) > JinxMenu.Combo.R.Min:Value() then
          if JinxMenu.Combo.R.OverKill:Value() then
	    if GetHP(enemy) < getdmg("R", enemy) and getdmg("W",enemy) < GetHP(enemy) then 
            Cast(_R,enemy, myHero, UltSpeed(enemy), 0.316, JinxMenu.Combo.R.Max:Value(), 140, 3, true, false, true)
            end
	  elseif GetHP(enemy) < getdmg("R", enemy) then 
            Cast(_R,enemy, myHero, UltSpeed(enemy), 0.316, JinxMenu.Combo.R.Max:Value(), 140, 3, true, false, true)
	  end
        end

   end

end)

OnProcessSpell(function(unit, spell)
  if unit == myHero and spell.name == "JinxQ" then
    TimeToSwap = false
    DelayAction(function() TimeToSwap = true end, spell.windUpTime * 500 + spell.animationTime*1000 - GetLatency() / 2)
  end
end)

function UltSpeed(unit)
  if ValidTarget(unit) then
    local dd = GetDistance(unit)
    local speed = GetDistance(unit) > 1350 and (2295000 + (GetDistance(unit) - 1350) * 2200) / GetDistance(unit) or 1700
    return speed
  end
end

AddGapcloseEvent(_E, 0, false)

PrintChat(string.format("<font color='#1244EA'>Jinx:</font> <font color='#FFFFFF'> By Deftsu Loaded, Have A Good Game ! </font>"))
PrintChat("Have Fun Using D3Carry Scripts: " ..GetObjectBaseName(myHero)) 
