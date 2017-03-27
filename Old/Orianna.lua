if GetObjectName(GetMyHero()) ~= "Orianna" then return end

require('Inspired')
require('DeftLib')
require('DamageLib')

local Ball = myHero
	
local OriannaMenu = MenuConfig("Orianna", "Orianna")
OriannaMenu:Menu("Combo", "Combo")
OriannaMenu.Combo:Boolean("Q", "Use Q", true)
OriannaMenu.Combo:Boolean("W", "Use W", true)
OriannaMenu.Combo:Boolean("E", "Use E", true)
OriannaMenu.Combo:Menu("R", "Use R")
OriannaMenu.Combo.R:Boolean("REnabled", "Enabled", true)
OriannaMenu.Combo.R:Boolean("Rkill", "if Can Kill", true)
OriannaMenu.Combo.R:Slider("Rcatch", "if can catch X enemies", 2, 0, 5, 1)

OriannaMenu:Menu("Harass", "Harass")
OriannaMenu.Harass:Boolean("Q", "Use Q", true)
OriannaMenu.Harass:Boolean("W", "Use W", true)
OriannaMenu.Harass:Boolean("E", "Use E", false)
OriannaMenu.Harass:Slider("Mana", "if Mana % is More than", 30, 0, 80, 1)

OriannaMenu:Menu("Killsteal", "Killsteal")
OriannaMenu.Killsteal:Boolean("Q", "Killsteal with Q", false)
OriannaMenu.Killsteal:Boolean("W", "Killsteal with W", true)
OriannaMenu.Killsteal:Boolean("E", "Killsteal with E", false)

OriannaMenu:Menu("Misc", "Misc")
if Ignite ~= nil then OriannaMenu.Misc:Boolean("AutoIgnite", "Auto Ignite", true) end
OriannaMenu.Misc:Menu("AutoUlt", "Auto Ult")
OriannaMenu.Misc.AutoUlt:Boolean("Enabled", "Enabled", true)
OriannaMenu.Misc.AutoUlt:Slider("catchable", "if Can Catch X Enemies", 3, 0, 5, 1)
OriannaMenu.Misc.AutoUlt:Slider("killable", "if Can Kill X Enemies", 2, 0, 5, 1)

OriannaMenu:Menu("JungleClear", "JungleClear")
OriannaMenu.JungleClear:Boolean("Q", "Use Q", true)
OriannaMenu.JungleClear:Boolean("W", "Use W", true)
OriannaMenu.JungleClear:Boolean("E", "Use E", true)

OriannaMenu:Menu("LaneClear", "LaneClear")
OriannaMenu.LaneClear:Boolean("Q", "Use Q", true)
OriannaMenu.LaneClear:Boolean("W", "Use W", true)

OriannaMenu:Menu("Drawings", "Drawings")
OriannaMenu.Drawings:Boolean("Q", "Draw Q Range", true)
OriannaMenu.Drawings:Boolean("W", "Draw W Radius", true)
OriannaMenu.Drawings:Boolean("E", "Draw E Range", true)
OriannaMenu.Drawings:Boolean("R", "Draw R Radius", true)
OriannaMenu.Drawings:Boolean("Ball", "Draw Ball Position", true)

OriannaMenu:Menu("Interrupt", "Interrupt (R)")

DelayAction(function()
  local str = {[_Q] = "Q", [_W] = "W", [_E] = "E", [_R] = "R"}
  for i, spell in pairs(CHANELLING_SPELLS) do
    for _,k in pairs(GetEnemyHeroes()) do
        if spell["Name"] == GetObjectName(k) then
        OriannaMenu.Interrupt:Boolean(GetObjectName(k).."Inter", "On "..GetObjectName(k).." "..(type(spell.Spellslot) == 'number' and str[spell.Spellslot]), true)
        end
    end
  end
end, 1)

OnProcessSpell(function(unit, spell)
    if GetObjectType(unit) == Obj_AI_Hero and GetTeam(unit) ~= GetTeam(myHero) and IsReady(_R) then
      if CHANELLING_SPELLS[spell.name] then
        if ValidTarget(unit, 1000) and GetObjectName(unit) == CHANELLING_SPELLS[spell.name].Name and OriannaMenu.Interrupt[GetObjectName(unit).."Inter"]:Value() and GetDistance(Ball,unit) <= 400 then 
        CastSpell(_R)
        end
      end
    end
end)

OnDraw(function(myHero)
if OriannaMenu.Drawings.Ball:Value() then DrawCircle(GetOrigin(Ball),150,1,25,0xffffffff) end
if OriannaMenu.Drawings.W:Value() then DrawCircle(GetOrigin(Ball),250,1,25,0xffffffff) end
if OriannaMenu.Drawings.R:Value() then DrawCircle(GetOrigin(Ball),400,1,25,0xffffffff) end
if OriannaMenu.Drawings.Q:Value() then DrawCircle(GetOrigin(myHero),825,1,25,0xff00ff00) end
if OriannaMenu.Drawings.E:Value() then DrawCircle(myHeroPos(),1000,2,25,0xff00ff00) end
end)

local Missiles = {}

OnCreateObj(function(Object) 
  if GetObjectBaseName(Object) == "missile" then
  table.insert(Missiles,Object) 
  end
end)

OnDeleteObj(function(Object)
  if GetObjectBaseName(Object) == "missile" then
    for i,rip in pairs(Missiles) do
      if GetNetworkID(Object) == GetNetworkID(rip) then
      table.remove(Missiles,i) 
      end
    end
  end
end)

OnTick(function(myHero)
     local target = GetCurrentTarget()	
     
     for _,missile in pairs(Missiles) do
       if GetObjectSpellOwner(missile) == myHero and GetObjectSpellName(missile) == "orianaizuna" then
       Ball = missile
       end
     end

     if IOW:Mode() == "Combo" then
     	
	if IsReady(_R) and OriannaMenu.Combo.R.REnabled:Value() then
	  if EnemiesAround2(GetOrigin(Ball), 400) >= OriannaMenu.Combo.R.Rcatch:Value() then
	  CastSpell(_R)
	  end
	end
	
	if IsReady(_R) then
	  if IsReady(_Q) and OriannaMenu.Combo.Q:Value() and EnemiesAround(myHeroPos(), 825) < 2 and ValidTarget(target, 825) then
          Cast(_Q,target,Ball)   
	  end
	elseif CanUseSpell(myHero, _R) ~= READY then
          if IsReady(_Q) and OriannaMenu.Combo.Q:Value() and ValidTarget(target, 825) then
          Cast(_Q,target,Ball)
	  end
	end
		
	if IsReady(_W) and OriannaMenu.Combo.W:Value() and ValidTarget(target, 1200) and GetDistance(Ball, target) <= 250 then
	CastSpell(_W)
        end

        if Ball ~= myHero and IsReady(_E) and ValidTarget(target, 1000) and OriannaMenu.Combo.E:Value() then
          local pointSegment,pointLine,isOnSegment  = VectorPointProjectionOnLineSegment(myHeroPos(), GetOrigin(target), Vector(Ball))
          if pointLine and GetDistance(pointSegment, target) < 80 then
          CastTargetSpell(myHero, _E)
          end
        end	
     end
	
     if IOW:Mode() == "Harass" and GetPercentMP(myHero) >= OriannaMenu.Harass.Mana:Value() then

	if IsReady(_Q) and OriannaMenu.Harass.Q:Value() and EnemiesAround(myHeroPos(), 825) < 2 and ValidTarget(target, 825) then
        Cast(_Q,target,Ball)   
	end
	
	if IsReady(_W) and OriannaMenu.Harass.W:Value() and ValidTarget(target, 825) and GetDistance(Ball, target) <= 250 then
	 CastSpell(_W)
         end

        if Ball ~= myHero and IsReady(_E) and ValidTarget(target, 1000) and OriannaMenu.Harass.E:Value() then
          local pointSegment,pointLine,isOnSegment  = VectorPointProjectionOnLineSegment(myHeroPos(), GetOrigin(target), Vector(Ball))
          if pointLine and GetDistance(pointSegment, target) <= 80 then
          CastTargetSpell(myHero, _E)
          end
        end	
     end
    
	local KillableEnemies = 0
	
        for i,enemy in pairs(GetEnemyHeroes()) do
		
	    if Ignite and OriannaMenu.Misc.AutoIgnite:Value() then
              if IsReady(Ignite) and 20*GetLevel(myHero)+50 > GetHP(enemy)+GetHPRegen(enemy)*3 and ValidTarget(enemy, 600) then
              CastTargetSpell(enemy, Ignite)
              end
            end
						
  	    if IOW:Mode() == "Combo" and ValidTarget(enemy, 1200) and OriannaMenu.Combo.R.Rkill:Value() and GetDistance(Ball, enemy) < 400 and GetCurrentHP(enemy)+GetMagicShield(enemy)+GetDmgShield(enemy) < CalcDamage(myHero, enemy, 0, 75*GetCastLevel(myHero, _R)+75+0.7*GetBonusAP(myHero) + Ludens()) then 
            CastSpell(_R)
            end
		
	    if IsReady(_R) and OriannaMenu.Misc.AutoUlt.Enabled:Value() then
              if ValidTarget(enemy, 1200) and GetDistance(Ball, enemy) <= 400 and GetHP2(enemy) < getdmg("R",enemy) then 
              KillableEnemies = KillableEnemies + 1
              end
		  
	      if KillableEnemies >= OriannaMenu.Misc.AutoUlt.killable:Value() then
	      CastSpell(_R)
	      end
	    end
		
	    if IsReady(_W) and OriannaMenu.Killsteal.W:Value() and ValidTarget(enemy, 1200) and GetDistance(Ball, enemy) <= 250 and GetCurrentHP(enemy)+GetMagicShield(enemy)+GetDmgShield(enemy) < getdmg("W",enemy) then
	    CastSpell(_W)
	    elseif IsReady(_Q) and ValidTarget(enemy, 825) and OriannaMenu.Killsteal.Q:Value() and GetCurrentHP(enemy)+GetMagicShield(enemy)+GetDmgShield(enemy) < getdmg("Q",enemy) then 
            Cast(_Q,enemy,Ball)
            elseif Ball ~= myHero and IsReady(_E) and ValidTarget(enemy, 1000) and OriannaMenu.Killsteal.E:Value() then
              local pointSegment,pointLine,isOnSegment  = VectorPointProjectionOnLineSegment(myHeroPos(), GetOrigin(enemy), Vector(Ball))
              if pointLine and GetDistance(pointSegment, enemy) <= 80 and GetCurrentHP(enemy)+GetMagicShield(enemy)+GetDmgShield(enemy) < getdmg("E",enemy) then
              CastTargetSpell(myHero, _E)
              end 
	    end
		
		local QThrowPos = GetMEC(400,GetEnemyHeroes()) 
		if IOW:Mode() == "Combo" and EnemiesAround2(myHeroPos(), 825) >= 2 and ValidTarget(enemy, 825) and IsReady(_R) and OriannaMenu.Combo.Q:Value() then 
                CastSkillShot(_Q, QThrowPos.x, QThrowPos.y, QThrowPos.z)
                end
		
	end
	
	if IsReady(_R) and OriannaMenu.Misc.AutoUlt.Enabled:Value() then
	  if EnemiesAround2(GetOrigin(Ball), 400) >= OriannaMenu.Misc.AutoUlt.catchable:Value() then
	  CastSpell(_R)
	  end
	end
	
	if IOW:Mode() == "LaneClear" then
		
          if IsReady(_Q) and OriannaMenu.LaneClear.Q:Value() then
            local BestPos, BestHit = GetFarmPosition(825, 80)
            if BestPos and BestHit > 2 then 
            CastSkillShot(_Q,BestPos)
            end
	  end
	  
	  if IsReady(_W) and OriannaMenu.LaneClear.W:Value() and MinionsAround(GetOrigin(Ball), 250) > 2 then 
	  CastSpell(_W)
          end
          
          for _,mob in pairs(minionManager.objects) do
            if GetTeam(mob) == 300 then
	    
		if IsReady(_W) and OriannaMenu.JungleClear.W:Value() and ValidTarget(mob, 1200) and GetDistance(Ball, mob) <= 250 then
		CastSpell(_W)
		end
		
		if IsReady(_Q) and OriannaMenu.JungleClear.Q:Value() and ValidTarget(mob, 825) then
		CastSkillShot(_Q, GetOrigin(mob)) 
		end
		
		if Ball ~= myHero and IsReady(_E) and OriannaMenu.JungleClear.E:Value() and ValidTarget(mob, 1000) then
		  local pointSegment,pointLine,isOnSegment  = VectorPointProjectionOnLineSegment(GetOrigin(myHero), GetOrigin(mob), GetOrigin(Ball))
                  if pointLine and GetDistance(pointSegment, mob) <= 80 then
		  CastTargetSpell(myHero, _E)
		  end
		end
		
            end
          end

        end

end)

OnProcessSpell(function(unit, spell)
  if unit == myHero and spell.name == "OrianaRedactCommand" then 
  Ball = spell.target
  end
end)

OnObjectLoad(function(Object)  
  if GetObjectBaseName(Object) == "Orianna_Base_Q_yomu_ring_green.troy" then
  Ball = Object
  end
end)

OnCreateObj(function(Object) 
  if GetObjectBaseName(Object) == "Orianna_Base_Q_yomu_ring_green.troy" then
  Ball = Object
  end
end)

OnUpdateBuff(function(unit,buff)
  if unit == myHero and buff.Name == "orianaghostself" then
  Ball = myHero
  end
end)

PrintChat(string.format("<font color='#1244EA'>Orianna:</font> <font color='#FFFFFF'> By Deftsu Loaded, Have A Good Game ! </font>"))
PrintChat("Have Fun Using D3Carry Scripts: " ..GetObjectBaseName(myHero)) 
