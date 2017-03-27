if GetObjectName(GetMyHero()) ~= "Xerath" then return end

require('Inspired')
require('DeftLib')
require('DamageLib')

local XerathMenu = MenuConfig("Xerath", "Xerath")
XerathMenu:Menu("Combo", "Combo")
XerathMenu.Combo:Boolean("Q", "Use Q", true)
XerathMenu.Combo:Boolean("W", "Use W", true)
XerathMenu.Combo:Boolean("E", "Use E", true)
XerathMenu.Combo:KeyBinding("R", "Use R", string.byte("R"))
XerathMenu.Combo:KeyBinding("RT", "Tab Click R", string.byte("T"), true)
XerathMenu.Combo:Boolean("delay", "Use Delays", true)
XerathMenu.Combo:Slider("delay1", "Delay on First R", 150, 0, 1000, 1)
XerathMenu.Combo:Slider("delay2", "Delay on Second R", 200, 0, 1000, 1)
XerathMenu.Combo:Slider("delay3", "Delay on Third R", 75, 0, 1000, 1)

XerathMenu:Menu("Harass", "Harass")
XerathMenu.Harass:Boolean("Q", "Use Q", true)
XerathMenu.Harass:Boolean("W", "Use W", true)
XerathMenu.Harass:Boolean("E", "Use E", true)
XerathMenu.Harass:Slider("Mana", "if Mana % is More than", 30, 0, 80, 1)

XerathMenu:Menu("Killsteal", "Killsteal")
XerathMenu.Killsteal:Boolean("W", "Killsteal with W", true)
XerathMenu.Killsteal:Boolean("E", "Killsteal with E", true)

if Ignite ~= nil then
XerathMenu:Menu("Misc", "Misc")
XerathMenu.Misc:Boolean("AutoIgnite", "Auto Ignite", true)
end

XerathMenu:Menu("LaneClear", "LaneClear")
XerathMenu.LaneClear:Boolean("Q", "Use Q", true)
XerathMenu.LaneClear:Boolean("W", "Use W", false)
XerathMenu.LaneClear:Slider("Mana", "if Mana % >", 30, 0, 80, 1)

XerathMenu:Menu("JungleClear", "JungleClear")
XerathMenu.JungleClear:Boolean("Q", "Use Q", true)
XerathMenu.JungleClear:Boolean("W", "Use W", true)
XerathMenu.JungleClear:Boolean("E", "Use E", true)
XerathMenu.JungleClear:Slider("Mana", "if Mana % >", 30, 0, 80, 1)

XerathMenu:Menu("Drawings", "Drawings")
XerathMenu.Drawings:Boolean("Qmin", "Draw Q Min Range", true)
XerathMenu.Drawings:Boolean("Qmax", "Draw Q Max Range", true)
XerathMenu.Drawings:Boolean("W", "Draw W Range", true)
XerathMenu.Drawings:Boolean("E", "Draw E Range", true)
XerathMenu.Drawings:Boolean("R", "Draw R Range", true)
XerathMenu.Drawings:Boolean("RT", "Draw R Target", true)
XerathMenu.Drawings:Boolean("Rdmg", "Draw R Damage", true)

XerathMenu:Menu("Interrupt", "Interrupt (E)")

DelayAction(function()
  local str = {[_Q] = "Q", [_W] = "W", [_E] = "E", [_R] = "R"}
  for i, spell in pairs(CHANELLING_SPELLS) do
    for _,k in pairs(GetEnemyHeroes()) do
        if spell["Name"] == GetObjectName(k) then
        XerathMenu.Interrupt:Boolean(GetObjectName(k).."Inter", "On "..GetObjectName(k).." "..(type(spell.Spellslot) == 'number' and str[spell.Spellslot]), true)
        end
    end
  end
end, 1)

OnProcessSpell(function(unit, spell)
    if GetObjectType(unit) == Obj_AI_Hero and GetTeam(unit) ~= GetTeam(myHero) and IsReady(_E) then
      if CHANELLING_SPELLS[spell.name] then
        if ValidTarget(unit, 650) and GetObjectName(unit) == CHANELLING_SPELLS[spell.name].Name and XerathMenu.Interrupt[GetObjectName(unit).."Inter"]:Value() then
        Cast(_E,unit)
        end
      end
    end
end)

local IsChanneled = false
local QCharged = false
local minrange = 750
local chargedrange = 750
local chargedTime = GetTickCount()
local rRange = {3200, 4400, 5600}
local RCast = 0
local Rdelay1 = 0
local Rdelay2 = 0
local Rdelay3 = 0
local shouldCastR = false
local target1 = TargetSelector(1550,TARGET_LESS_CAST_PRIORITY,DAMAGE_MAGIC,true,false)
local target2 = TargetSelector(1250,TARGET_LESS_CAST_PRIORITY,DAMAGE_MAGIC,true,false)
local target3 = TargetSelector(1005,TARGET_LESS_CAST_PRIORITY,DAMAGE_MAGIC,true,false)
local target4 = TargetSelector(5600,TARGET_LESS_CAST_PRIORITY,DAMAGE_MAGIC,true,false)

OnDraw(function(myHero)
local pos = GetOrigin(myHero)
local Rtarget = target4:GetTarget()
if XerathMenu.Drawings.Qmin:Value() then DrawCircle(pos,750,1,25,GoS.Pink) end
if XerathMenu.Drawings.Qmax:Value() then DrawCircle(pos,1500,1,25,GoS.Red) end
if XerathMenu.Drawings.W:Value() then DrawCircle(pos,1150,1,25,GoS.Yellow) end
if XerathMenu.Drawings.E:Value() then DrawCircle(pos,975,1,25,GoS.Blue) end
if XerathMenu.Drawings.R:Value() and GetCastLevel(myHero,_R) > 0 then DrawCircle(pos,rRange[GetCastLevel(myHero,_R)],1,25,GoS.Green) end
if XerathMenu.Drawings.RT:Value() and ValidTarget(Rtarget) then DrawCircle(GetOrigin(Rtarget),50,1,0,ARGB(255,255,0,0)) end
for i,enemy in pairs(GetEnemyHeroes()) do
  if ValidTarget(enemy) and XerathMenu.Drawings.Rdmg:Value() then
    local barPos = GetHPBarPos(enemy)
    if barPos.x > 0 and barPos.y > 0 then
      local offset = 103 * (GetHP2(enemy)/GetMaxHP(enemy))
      if getdmg("R",enemy)*3 > 0 and IsReady(_R) then
      local off = 103*(getdmg("R",enemy)*3/GetMaxHP(enemy))
      DrawLine(barPos.x+1+offset-off, barPos.y-1, barPos.x+1+offset, barPos.y-1, 5, 0xDFFFE258)
      DrawLine(barPos.x+1+offset-off, barPos.y-1, barPos.x+1+offset-off, barPos.y+10-10, 1, 0xDF8866F4)
      DrawText("R", 11, barPos.x+1+offset-off, barPos.y-5-10, 0xDF55F855)
      DrawText(""..getdmg("R",enemy), 10, barPos.x+4+offset-off, barPos.y+5-10, 0xDFFF5858)
      offset = offset - off
      end
    end
  end
end
end)

OnTick(function(myHero)
    local mousePos = GetMousePos()
    local Qtarget = target1:GetTarget()
    local Wtarget = target2:GetTarget()
    local Etarget = target3:GetTarget()
    local Rtarget = target4:GetTarget()
	
    if not QCharged and chargedrange ~= minrange then
    chargedrange = minrange
    end

    if QCharged and chargedTime + ((1500 + 3000) + 1000) < GetTickCount() then
    QCharged = false
    chargedrange = minrange
    end	

    if QCharged then
    chargedrange = math.floor((math.min(minrange + (1500 - minrange) * ((GetTickCount() - chargedTime) / 1500) - 100, 1500)))
    end

    if RCast == 1 and Rdelay1 <= GetTickCount() and ValidTarget(Rtarget) then
      Cast(_R, Rtarget)
      elseif RCast == 2 and Rdelay2 <= GetTickCount() then
      Cast(_R, Rtarget)
      elseif RCast == 3 and Rdelay3 <= GetTickCount() then
      Cast(_R, Rtarget)
      IOW.movementEnabled = true
      IOW.attacksEnabled = true
      IsChanneled = false
    end

    if IOW:Mode() == "Combo" then
	
      if QCharged and XerathMenu.Combo.Q:Value() and ValidTarget(Qtarget, 1550) then
        DelayAction(function()
        Cast2(_Q, Qtarget, chargedrange)
	end, 1)
      elseif IsReady(_Q) and ValidTarget(Qtarget, 1550) and XerathMenu.Combo.Q:Value() then
      CastSkillShot(_Q, mousePos)
      end
  
      if not QCharged then
      	if IsReady(_W) and XerathMenu.Combo.W:Value() and ValidTarget(Wtarget, 1250) then
        Cast(_W,Wtarget)
        end

        if IsReady(_E) and XerathMenu.Combo.E:Value() and ValidTarget(Etarget, 1005) then
        Cast(_E,Etarget)
        end
      end
      
    end
    
    if XerathMenu.Combo.R:Value() and GetCastLevel(myHero,_R) > 0 then
      if ValidTarget(Rtarget, rRange[GetCastLevel(myHero,_R)]) and not IsChanneled and RCast == 0 and IsReady(_R) then
      CastSpell(_R)
      end
    end
    
    if XerathMenu.Combo.RT:Value() and GetCastLevel(myHero,_R) > 0 then
      if ValidTarget(Rtarget, rRange[GetCastLevel(myHero,_R)]) and not IsChanneled and RCast == 0 and IsReady(_R) and GetHP2(RTarget) < getdmg("R",RTarget)*3 then
      CastSpell(_R)
      end 
    end

    if IOW:Mode() == "Harass" then
	  
      if QCharged and XerathMenu.Harass.Q:Value() and ValidTarget(Qtarget, 1550) then
        DelayAction(function()
        Cast2(_Q, Qtarget, chargedrange)
	end, 1)
      end
	  
      if GetPercentMP(myHero) >= XerathMenu.Harass.Mana:Value() then
        if IsReady(_Q) and ValidTarget(Qtarget, 1550) and XerathMenu.Harass.Q:Value() then
        CastSkillShot(_Q, mousePos)
	end
	
	if not QCharged then
          if IsReady(_W) and XerathMenu.Harass.W:Value() and ValidTarget(Wtarget, 1250) then
          Cast(_W,Wtarget)
          end
  
          if IsReady(_E) and XerathMenu.Harass.E:Value() and ValidTarget(Etarget, 1005) then
          Cast(_E,Etarget)
          end
	end
      end

    end

    for i,enemy in pairs(GetEnemyHeroes()) do

        if Ignite and XerathMenu.Misc.AutoIgnite:Value() then
          if IsReady(Ignite) and 20*GetLevel(myHero)+50 > GetHP(enemy)+GetHPRegen(enemy)*3 and ValidTarget(enemy, 600) then
          CastTargetSpell(enemy, Ignite)
          end
        end
                
       if IsReady(_W) and ValidTarget(enemy, 1250) and XerathMenu.Killsteal.W:Value() and GetHP2(enemy) < getdmg("W",enemy) then
       Cast(_W,enemy)
       elseif IsReady(_E) and ValidTarget(enemy, 1005) and XerathMenu.Killsteal.E:Value() and GetHP2(enemy) < getdmg("E",enemy) then  
       Cast(_E,enemy)
       end
    end
    
    if IOW:Mode() == "LaneClear" then
		
      if QCharged then
        local BestPos, BestHit = GetLineFarmPosition(1500, 100)
	if chargedrange <= 1500 and GetDistanceSqr(BestPos) < math.pow(chargedrange - 100, 2) and BestPos and BestHit > 2 then
        DelayAction(function() CastSkillShot2(_Q, BestPos) end, 1)
	end
      end
		
      if GetPercentMP(myHero) >= XerathMenu.LaneClear.Mana:Value() then
       	
        if IsReady(_Q) and XerathMenu.LaneClear.Q:Value() then
	  local BestPos, BestHit = GetLineFarmPosition(1500, 100)
	  if BestPos and BestHit > 2 then
	  CastSkillShot(_Q, mousePos) 
          end
        end
		 
        if IsReady(_W) and XerathMenu.LaneClear.W:Value() then
          local BestPos, BestHit = GetFarmPosition(1150, 200)
          if BestPos and BestHit > 2 then 
          CastSkillShot(_W, BestPos)
          end
	end
        
      end

    end

    for i,mobs in pairs(minionManager.objects) do
        if IOW:Mode() == "LaneClear" and GetTeam(mobs) == 300 then
          if QCharged and XerathMenu.JungleClear.Q:Value() and ValidTarget(mobs, 1500) then
            DelayAction(function()
            CastSkillShot2(_Q, GetOrigin(mobs))
 	    end, 1)
          end

          if GetPercentMP(myHero) >= XerathMenu.JungleClear.Mana:Value() then
            if IsReady(_Q) and XerathMenu.JungleClear.Q:Value() and ValidTarget(mobs, 1500) then
            CastSkillShot(_Q,mousePos)
	    end
		
	    if IsReady(_W) and XerathMenu.JungleClear.W:Value() and ValidTarget(mobs, 1150) then
	    CastSpell(_W,GetOrigin(mobs))
	    end
		
	    if IsReady(_E) and XerathMenu.JungleClear.E:Value() and ValidTarget(mobs, 975) then
	    CastSkillShot(_E,GetOrigin(mobs))
            end
          end
        end
    end       

end)

OnRemoveBuff(function(unit,buff)
  if unit == myHero then
  
    if buff.Name == "XerathArcanopulseChargeUp"  then
    QCharged = false
    end

    if buff.Name == "xerathqlaunchsound" then
    QCharged = false
    end
	
  end
end)

OnProcessSpell(function(unit,spell)
  if unit == myHero then
    
    if spell.name == "xerathlocuspulse" then
      lastR = GetTickCount()
      if shouldCastR and RCast == 1 then
      shouldCastR = false 
      end

      RCast = RCast + 1

      if RCast == 2 then
      local delay = (XerathMenu.Combo.delay:Value() and XerathMenu.Combo.delay2:Value()) or 0
      Rdelay2 = GetTickCount() + (delay)
      elseif RCast == 3 then
      local delay = (XerathMenu.Combo.delay:Value() and XerathMenu.Combo.delay3:Value()) or 0
      Rdelay3 = GetTickCount() + (delay)
      end

    end

    if spell.name:lower():find("xerathlocusofpower2") then
    IOW.movementEnabled = false
    IOW.attacksEnabled = false
    IsChanneled = true
    RCast = 1
    lastR = GetTickCount()
    local delay = (XerathMenu.Combo.delay:Value() and XerathMenu.Combo.delay1:Value()) or 0
    Rdelay1 = GetTickCount() + (delay)
    end
	
    if spell.name:lower():find("xeratharcanopulse2") and QCharged then
    QCharged = false
    end

    if spell.name == "XerathArcanopulseChargeUp" then
    QCharged = true
    chargedTime = GetTickCount()
    end
	
  end
end)

OnCreateObj(function(Object)
  if GetObjectBaseName(Object) == "Xerath_Base_Q_cas_charge.troy" and GetDistance(Object) <= 100 then
  QCharged = true
  end
end)

OnDeleteObj(function(Object)
  if GetObjectBaseName(Object) == "Xerath_Base_Q_cas_charge.troy" and GetDistance(Object) <= 50 then
  QCharged = false
  end
end)

AddGapcloseEvent(_E, 666, false, XerathMenu)

PrintChat(string.format("<font color='#1244EA'>Xerath:</font> <font color='#FFFFFF'> By Deftsu Loaded, Have A Good Game ! </font>"))
PrintChat("Have Fun Using D3Carry Scripts: " ..GetObjectBaseName(myHero)) 
