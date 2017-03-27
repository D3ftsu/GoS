if GetObjectName(GetMyHero()) ~= "Nidalee" then return end

require('MapPositionGOS')
require('Inspired')
require('DeftLib')
require('DamageLib')

local NidaleeMenu = MenuConfig("Nidalee", "Nidalee")
NidaleeMenu:Menu("Combo", "Combo")
NidaleeMenu.Combo:Boolean("Q", "Use Q", true)
NidaleeMenu.Combo:Boolean("W", "Use W", true)
NidaleeMenu.Combo:Boolean("E", "Use E", true)
NidaleeMenu.Combo:Boolean("R", "Use R", true)

NidaleeMenu:Menu("Harass", "Harass")
NidaleeMenu.Harass:Boolean("Q", "Use Q", true)
NidaleeMenu.Harass:Boolean("E", "Use E", true)
NidaleeMenu.Harass:Slider("Mana", "if Mana % >", 30, 0, 80, 1)

NidaleeMenu:Menu("Killsteal", "Killsteal")
NidaleeMenu.Killsteal:Boolean("Q", "Killsteal with Q", true)
NidaleeMenu.Killsteal:Boolean("W", "Killsteal with W", true)
NidaleeMenu.Killsteal:Boolean("E", "Killsteal with E", true)
NidaleeMenu.Killsteal:Boolean("R", "Killsteal with R", true)

NidaleeMenu:Menu("Misc", "Misc")
if Ignite ~= nil then NidaleeMenu.Misc:Boolean("AutoIgnite", "Auto Ignite", true) end
NidaleeMenu.Misc:Boolean("Eme", "Self-Heal", true)
NidaleeMenu.Misc:Slider("mpEme", "Minimum Mana %", 25, 0, 100, 0)
NidaleeMenu.Misc:Slider("hpEme", "Minimum HP%", 70, 0, 100, 0)
NidaleeMenu.Misc:Boolean("Eally", "Heal Allies", true)
NidaleeMenu.Misc:Slider("mpEally", "Minimum Mana %", 50, 0, 100, 0)
NidaleeMenu.Misc:Slider("hpEally", "Minimum HP %", 35, 0, 100, 0)
NidaleeMenu.Misc:KeyBinding("Flee", "Flee", string.byte("T"))
NidaleeMenu.Misc:KeyBinding("WallJump", "WallJump", string.byte("G"))

NidaleeMenu:Menu("Drawings", "Drawings")
NidaleeMenu.Drawings:Boolean("Q", "Draw Q Range", true)
NidaleeMenu.Drawings:Boolean("W", "Draw W Range", true)
NidaleeMenu.Drawings:Boolean("E", "Draw E Range", true)
NidaleeMenu.Drawings:Boolean("R", "Draw R Range", true)
NidaleeMenu.Drawings:Boolean("WJ", "Draw WallJump Helper", true)

OnDraw(function(myHero)
local pos = GetOrigin(myHero)
  if IsHuman() then
    if NidaleeMenu.Drawings.Q:Value() then DrawCircle(pos,1450,1,25,GoS.Pink) end
    if NidaleeMenu.Drawings.W:Value() then DrawCircle(pos,900,1,25,GoS.Yellow) end
    if NidaleeMenu.Drawings.E:Value() then DrawCircle(pos,650,1,25,GoS.Blue) end
  else
    if NidaleeMenu.Drawings.Q:Value() then DrawCircle(pos,GetRange(myHero)+GetHitBox(myHero),1,25,GoS.Pink) end
    if NidaleeMenu.Drawings.WJ:Value() then
    DrawCircle(mousePos,400,1,25,MapPosition:inWall(mousePos) and ARGB(255,255,0,0) or ARGB(255, 255, 255, 255))
    DrawCircle(mousePos,133,1,25,MapPosition:inWall(mousePos) and ARGB(255,255,0,0) or ARGB(255, 255, 255, 255))
    end
    if NidaleeMenu.Drawings.E:Value() then DrawCircle(pos,375,1,25,GoS.Blue) end
  end
end)

local QCD = 0
local target1 = TargetSelector(1450,TARGET_LESS_CAST_PRIORITY,DAMAGE_MAGIC,true,false)
  
OnTick(function(myHero)
    local target = GetCurrentTarget()
    local Qtarget = target1:GetTarget()
    mousePos = GetMousePos()
	
    if IOW:Mode() == "Combo" then
	  
      if IsHuman() then
	    
	if IsReady(_Q) and IsHuman() and NidaleeMenu.Combo.Q:Value() and ValidTarget(Qtarget,1450) then
        Cast(_Q,Qtarget)
        end
		
        if IsReady(_R) and IsHunted(target) and ValidTarget(target,800) and NidaleeMenu.Combo.R:Value() then
        CastSpell(_R)
        end 
		
	if IsReady(_W) and not IsHunted(target) and NidaleeMenu.Combo.W:Value() and ValidTarget(target,900) then
        Cast(_W,target)
        end
		
      else
	  
        if IsReady(_W) and ValidTarget(target,765) and IsHunted(target) and NidaleeMenu.Combo.W:Value() then
        CastSkillShot(_W,GetOrigin(target))
	elseif IsReady(_W) and not IsHunted(target) and ValidTarget(target,400) and NidaleeMenu.Combo.W:Value() then
	CastSkillShot(_W,GetOrigin(target))
        end
	
        if ValidTarget(target,375) then
          if IsReady(_E) and NidaleeMenu.Combo.E:Value() then
          CastSkillShot(_E,GetOrigin(target))
          elseif IsReady(_Q) and NidaleeMenu.Combo.Q:Value() then
          CastSpell(_Q)
          end
        end

        if ValidTarget(target,1500) then
          if GetDistance(target) > 425 then
          CastSpell(_R)
          elseif QCD < GetTickCount() then
          CastSpell(_R)
          end
        end	

      end
	  
    end
	
    if IOW:Mode() == "Harass" then
	
      if IsHuman() and GetPercentHP(myHero) >= NidaleeMenu.Harass.Mana:Value() and NidaleeMenu.Harass.Q:Value() and ValidTarget(Qtarget,1450) then
      Cast(_Q,Qtarget)
      else
        if not IsHuman() and ValidTarget(target,375) then
          if IsReady(_E) and NidaleeMenu.Harass.E:Value() then
          CastSkillShot(_E,GetOrigin(target))
          elseif IsReady(_Q) and NidaleeMenu.Harass.Q:Value() then
          CastSpell(_Q)
          end
        end
      end
      
    end

    if NidaleeMenu.Misc.WallJump:Value() then
      if IsHuman() then CastSpell(_R) end
      local movePos1 = GetOrigin(myHero) + (Vector(mousePos) - GetOrigin(myHero)):normalized() * 150
      local movePos2 = GetOrigin(myHero) + (Vector(mousePos) - GetOrigin(myHero)):normalized() * 400
      if MapPosition:inWall(movePos1) and not MapPosition:inWall(movePos2) then
      CastSkillShot(_W, movePos2)
      else
      MoveToXYZ(mousePos)
      end
    end
    
    if NidaleeMenu.Misc.Flee:Value() then
      if IsHuman() then
      CastSpell(_R)
      else
      CastSkillShot(_W, mousePos)
      MoveToXYZ(mousePos)
      end
    end
	
    if not IsRecalling(myHero) and IsHuman() and NidaleeMenu.Misc.Eme:Value() and NidaleeMenu.Misc.mpEme:Value() <= GetPercentMP(myHero) and GetMaxHP(myHero)-GetCurrentHP(myHero) > 5+40*GetCastLevel(myHero,_E)+0.5*GetBonusAP(myHero) and GetPercentHP(myHero) <= NidaleeMenu.Misc.hpEme:Value() then
    CastSpell(_E)
    end
	
    if not IsRecalling(myHero) and IsHuman() and NidaleeMenu.Misc.Eally:Value() and NidaleeMenu.Misc.mpEally:Value() <= GetPercentMP(myHero) then
      for k,v in pairs(GetAllyHeroes()) do
        if v ~= nil and not IsRecalling(v) and IsObjectAlive(v) and GetDistance(v) <= 650 and GetMaxHP(v)- GetHP(v) < 5+40*GetCastLevel(myHero,_E)+0.5*GetBonusAP(myHero) and GetPercentHP(v) <= NidaleeMenu.Misc.hpEally:Value() then
        CastTargetSpell(v,_E)
        end
      end
    end
	
    for i,enemy in pairs(GetEnemyHeroes()) do
    	
        if Ignite and NidaleeMenu.Misc.AutoIgnite:Value() then
          if IsReady(Ignite) and 20*GetLevel(myHero)+50 > GetHP(enemy)+GetHPRegen(enemy)*3 and ValidTarget(enemy, 600) then
          CastTargetSpell(enemy, Ignite)
          end
        end
	  
        if IsReady(_Q) and ValidTarget(enemy, 1450) and NidaleeMenu.Killsteal.Q:Value() and IsHuman() and GetHP2(enemy) < getdmg("QM",enemy) then
        Cast(_Q, enemy)
        end
		
        if IsReady(_Q) and ValidTarget(enemy, 1450) and NidaleeMenu.Killsteal.Q:Value() and not IsHuman() and GetHP2(enemy) < getdmg("QM",enemy) then
        CastSpell(_R)
        DelayAction(function() Cast(_Q, enemy) end, 0.125)
        end
		
    end
	
end)

OnProcessSpell(function(unit, spell)
  if unit == myHero and spell.name == "JavelinToss" then 
  QCD = GetTickCount()+6000
  end
end)

local hunted = {}

OnUpdateBuff(function(unit,buff)
  if GetTeam(unit) ~= GetTeam(myHero) and buff.Name == "nidaleepassivehunted" then
  hunted[GetNetworkID(unit)] = buff.Count
  end
end)

OnRemoveBuff(function(unit,buff)
  if GetTeam(unit) ~= GetTeam(myHero) and buff.Name == "nidaleepassivehunted" then
  hunted[GetNetworkID(unit)] = 0
  end
end)

function IsHuman()
    return GetCastName(myHero,_Q) == "JavelinToss"
end

function IsHunted(unit)
   return (hunted[GetNetworkID(unit)] or 0) > 0
end

PrintChat(string.format("<font color='#1244EA'>Nidalee:</font> <font color='#FFFFFF'> By Deftsu Loaded, Have A Good Game ! </font>"))
