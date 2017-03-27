if GetObjectName(GetMyHero()) ~= "Syndra" then return end
	
if not pcall( require, "Inspired" ) then PrintChat("You are missing Inspired.lua - Go download it and save it Common!") return end
if not pcall( require, "Deftlib" ) then PrintChat("You are missing Deftlib.lua - Go download it and save it in Common!") return end
if not pcall( require, "DamageLib" ) then PrintChat("You are missing DamageLib.lua - Go download it and save it in Common!") return end

local SyndraMenu = MenuConfig("Syndra", "Syndra")
SyndraMenu:Menu("Combo", "Combo")
SyndraMenu.Combo:Boolean("EQ", "Use EQ Snipe", true)
SyndraMenu.Combo:Boolean("Q", "Use Q", true)
SyndraMenu.Combo:Boolean("W", "Use W", true)
SyndraMenu.Combo:Boolean("E", "Use E", true)
SyndraMenu.Combo:Boolean("R", "Use R", true)

SyndraMenu:Menu("Harass", "Harass")
SyndraMenu.Harass:Boolean("EQ", "Use EQ Snipe", true)
SyndraMenu.Harass:Boolean("Q", "Use Q", true)
SyndraMenu.Harass:Boolean("W", "Use W", true)
SyndraMenu.Harass:Boolean("E", "Use E", false)
SyndraMenu.Harass:Slider("Mana", "if Mana % is More than", 30, 0, 80, 1)
SyndraMenu.Harass:Boolean("AutoQ", "Auto Q", true)
SyndraMenu.Harass:Slider("QMana", "Auto Q if Mana >", 70, 0, 80, 1)

SyndraMenu:Menu("Killsteal", "Killsteal")
SyndraMenu.Killsteal:Boolean("Q", "Killsteal with Q", true)
SyndraMenu.Killsteal:Boolean("W", "Killsteal with W", true)
SyndraMenu.Killsteal:Boolean("E", "Killsteal with E", true)

SyndraMenu:Menu("Misc", "Misc")
if Ignite ~= nil then SyndraMenu.Misc:Boolean("AutoIgnite", "Auto Ignite", true) end
SyndraMenu.Misc:Boolean("Autolvl", "Auto level", true)
SyndraMenu.Misc:DropDown("Autolvltable", "Priority", 1, {"Q-E-W", "Q-W-E"})

SyndraMenu:Menu("LaneClear", "LaneClear")
SyndraMenu.LaneClear:Boolean("Q", "Use Q", true)
SyndraMenu.LaneClear:Boolean("W", "Use W", true)
SyndraMenu.LaneClear:Slider("Mana", "if Mana % is More than", 30, 0, 80, 1)

SyndraMenu:Menu("JungleClear", "JungleClear")
SyndraMenu.JungleClear:Boolean("Q", "Use Q", true)
SyndraMenu.JungleClear:Boolean("W", "Use W", true)
SyndraMenu.JungleClear:Boolean("E", "Use E", true)

SyndraMenu:Menu("Drawings", "Drawings")
SyndraMenu.Drawings:Boolean("Q", "Draw Q Range", true)
SyndraMenu.Drawings:Boolean("W", "Draw W Range", true)
SyndraMenu.Drawings:Boolean("E", "Draw E Range", true)
SyndraMenu.Drawings:Boolean("R", "Draw R Range", true)
SyndraMenu.Drawings:ColorPick("color", "Color Picker", {255,255,255,0})

local InterruptMenu = MenuConfig("Interrupt (E)", "Interrupt")

DelayAction(function()
  local str = {[_Q] = "Q", [_W] = "W", [_E] = "E", [_R] = "R"}
  for i, spell in pairs(CHANELLING_SPELLS) do
    for _,k in pairs(GetEnemyHeroes()) do
        if spell["Name"] == GetObjectName(k) then
        InterruptMenu:Boolean(GetObjectName(k).."Inter", "On "..GetObjectName(k).." "..(type(spell.Spellslot) == 'number' and str[spell.Spellslot]), true)
        end
    end
  end
end, 1)

OnProcessSpell(function(unit, spell)
    if GetObjectType(unit) == Obj_AI_Hero and GetTeam(unit) ~= GetTeam(myHero) and IsReady(_E) then
      if CHANELLING_SPELLS[spell.name] then
        if ValidTarget(unit, 700) and GetObjectName(unit) == CHANELLING_SPELLS[spell.name].Name and InterruptMenu[GetObjectName(unit).."Inter"]:Value() then 
        Cast(_E,unit)
        elseif ValidTarget(unit, 1280) and GetObjectName(unit) == CHANELLING_SPELLS[spell.name].Name and InterruptMenu[GetObjectName(unit).."Inter"]:Value() then 
        Cast(_Q,unit)
        DelayAction(function() Cast(_E,unit) end, 250)
        end
      end
    end
end)

OnDraw(function(myHero)
local col = SyndraMenu.Drawings.color:Value()
if SyndraMenu.Drawings.Q:Value() then DrawCircle(myHeroPos(),790,1,0,col) end
if SyndraMenu.Drawings.W:Value() then DrawCircle(myHeroPos(),925,1,0,col) end
if SyndraMenu.Drawings.E:Value() then DrawCircle(myHeroPos(),700,1,0,col) end
if SyndraMenu.Drawings.R:Value() then DrawCircle(myHeroPos(),725,1,0,col) end
end)

Balls = {}
local lastlevel = GetLevel(myHero)-1

OnTick(function(myHero)
  local target = GetCurrentTarget()
  
  if IOW:Mode() == "Combo" then

	if IsReady(_R) and SyndraMenu.Combo.R:Value() and ValidTarget(target, 725) and GetHP2(target) < CalcDamage(myHero, target, 0, (45*GetCastLevel(myHero,_R)+45+.2*GetBonusAP(myHero))*(table.getn(Balls)+3) + Ludens()) then
	CastTargetSpell(target, _R)
        end
        
        if IsReady(_Q) and IsReady(_E) and SyndraMenu.Combo.EQ:Value() then
        CastSkillShot(_Q, GetOrigin(target))
        DelayAction(function() Cast(_E,target,myHero,1,1600,0,1280,60,false) end, 250)
        end

	if IsReady(_Q) and SyndraMenu.Combo.Q:Value() and ValidTarget(target, 790) then
        Cast(_Q,target)
	end
	
	for _,Ball in pairs(Balls) do
	  if IsReady(_E) and ValidTarget(target, 1250) and SyndraMenu.Combo.E:Value() then
            local pointSegment,pointLine,isOnSegment = VectorPointProjectionOnLineSegment(myHeroPos(), GetPredictedPos(target), GetOrigin(Ball))
            if isOnSegment and GetDistance(pointSegment, GetPredictedPos(target)) < 125 then
            CastSkillShot(_E,GetOrigin(Ball))
            end
          end
        end
	
	if GetCastName(myHero, _W) ~= "SyndraW" and SyndraMenu.Combo.W:Value() and ValidTarget(target, 925) then
        Cast(_W,target)
        elseif IsReady(_W) and GetCastName(myHero, _W) == "SyndraW" and ValidTarget(target, 925) and SyndraMenu.Combo.W:Value() then
          for _,Ball in pairs(Balls) do
            if GetDistance(Ball) <= 925 then
            CastSkillShot(_W,GetOrigin(Ball))
            end
          end	  
          for i,mobs in pairs(minionManager.objects) do
	    if GetDistance(mobs) <= 925 then
	    CastSkillShot(_W,GetOrigin(mobs))
	    end
	  end
	end

  end
  
  if IOW:Mode() == "Harass" and GetPercentMP(myHero) >= SyndraMenu.Harass.Mana:Value() then
	  
        if IsReady(_Q) and IsReady(_E) and SyndraMenu.Harass.EQ:Value() then
        Cast(_Q,target,myHero,1,1600,0,1280,60,false)
        DelayAction(function() Cast(_E,target,myHero,1,1600,0,1280,60,false) end, 250)
        end

	if IsReady(_Q) and SyndraMenu.Harass.Q:Value() and ValidTarget(target, 790) then
        Cast(_Q,target)
	end
	
	for _,Ball in pairs(Balls) do
	  if IsReady(_E) and ValidTarget(target, 1250) and SyndraMenu.Harass.E:Value() then
            local pointSegment,pointLine,isOnSegment = VectorPointProjectionOnLineSegment(myHeroPos(), GetPredictedPos(target), GetOrigin(Ball))
            if isOnSegment and GetDistance(pointSegment, GetPredictedPos(target)) < 125 then
            CastSkillShot(_E,GetOrigin(Ball))
            end
          end
        end
	
	if GetCastName(myHero, _W) ~= "SyndraW" and SyndraMenu.Harass.W:Value() and ValidTarget(target, 925) then
        Cast(_W,target)
        elseif IsReady(_W) and GetCastName(myHero, _W) == "SyndraW" and ValidTarget(target, 925) and SyndraMenu.Harass.W:Value() then
          for _,Ball in pairs(Balls) do
            if GetDistance(Ball) <= 925 then
            CastSkillShot(_W,GetOrigin(Ball))
            end
          end	  
          for i,mobs in pairs(minionManager.objects) do
	    if GetDistance(mobs) <= 925 then
	    CastSkillShot(_W,GetOrigin(mobs))
	    end
	  end
        end

   end

   if SyndraMenu.Harass.AutoQ:Value() then
     if IsReady(_Q) and ValidTarget(target, 790) and GetPercentMP(myHero) >= SyndraMenu.Harass.QMana:Value() then
     Cast(_Q,target)
     end
   end
	
   for i,enemy in pairs(GetEnemyHeroes()) do
		
     if Ignite and SyndraMenu.Misc.AutoIgnite:Value() then
       if IsReady(Ignite) and 20*GetLevel(myHero)+50 > GetHP(enemy)+GetHPRegen(enemy)*3 and ValidTarget(enemy, 600) then
       CastTargetSpell(enemy, Ignite)
       end
     end
		
     if IsReady(_Q) and ValidTarget(enemy, 790) and SyndraMenu.Killsteal.Q:Value() and GetHP2(enemy) < getdmg("Q",enemy) then 
     Cast(_Q,enemy)
     end

     if GetCastName(myHero,_W) ~= "SyndraW" and ValidTarget(enemy, 925) and SyndraMenu.Killsteal.E:Value() and GetHP2(enemy) < getdmg("W",enemy) then 
     Cast(_W,enemy)
     end

     if IsReady(_E) and ValidTarget(enemy, 700) and SyndraMenu.Killsteal.E:Value() and GetHP2(enemy) < getdmg("E",enemy) then 
     Cast(_E,enemy)
     end
   end
   
   if IOW:Mode() == "LaneClear" then
     
     if GetPercentMP(myHero) > SyndraMenu.LaneClear.Mana:Value() then
       if IsReady(_Q) and SyndraMenu.LaneClear.Q:Value() then
         local BestPos, BestHit = GetFarmPosition(790, 125)
         if BestPos and BestHit > 0 then 
         CastSkillShot(_Q,BestPos)
         end
       end
       
       if GetCastName(myHero,_W) ~= "SyndraW" and SyndraMenu.LaneClear.W:Value() then
         local BestPos, BestHit = GetFarmPosition(925, 190)
         if BestPos and BestHit > 0 then 
         CastSkillShot(_W,BestPos)
         end
       elseif IsReady(_W) and GetCastName(myHero, _W) == "SyndraW" and SyndraMenu.LaneClear.W:Value() then
         for _,mobs in pairs(minionManager.objects) do
	   if GetDistance(mobs) <= 925 then
	   CastSkillShot(_W,GetOrigin(mobs))
	   end
         end
       end
       
      end
     
     for _,mobs in pairs(minionManager.objects) do
       if GetTeam(mobs) == 300 then
         if IsReady(_Q) and SyndraMenu.JungleClear.Q:Value() and ValidTarget(mobs, 790) then
	 CastSkillShot(_Q,GetOrigin(mobs))
	 end
		
	 if GetCastName(myHero, _W) ~= "SyndraW" and SyndraMenu.JungleClear.W:Value() and ValidTarget(mobs, 925) then
         CastSkillShot(_W,GetOrigin(mobs))
         end
	  
	 if IsReady(_W) and GetCastName(myHero, _W) == "SyndraW" and ValidTarget(mobs, 925) and SyndraMenu.JungleClear.W:Value() then
	   if GetDistance(mobs) <= 925 then
	   CastSkillShot(_W,GetOrigin(mobs))
	   end
         end
               
         for _,Ball in pairs(Balls) do
           if IsReady(_E) and ValidTarget(mob, 1250) and SyndraMenu.JungleClear.E:Value() then
             local pointSegment,pointLine,isOnSegment = VectorPointProjectionOnLineSegment(myHeroPos(), GetOrigin(mobs), GetOrigin(Ball))
             if isOnSegment and GetDistance(pointSegment, mobs) < 125 then
             CastSkillShot(_E,GetOrigin(Ball))
             end
           end	
         end
       end
     end
     
   end
  
if SyndraMenu.Misc.Autolvl:Value() then
  if GetLevel(myHero) > lastlevel then
    if SyndraMenu.Misc.Autolvltable:Value() == 1 then leveltable = {_Q, _W, _E, _Q, _Q, _R, _Q, _E, _Q, _E, _R, _E, _E, _W, _W, _R, _W, _W}
    elseif SyndraMenu.Misc.Autolvltable:Value() == 2 then leveltable = {_Q, _W, _E, _Q, _Q, _R, _Q, _W, _Q, _W, _R, _W, _W, _E, _E, _R, _E, _E}
    end
    DelayAction(function() LevelSpell(leveltable[GetLevel(myHero)]) end, math.random(1000,3000))
    lastlevel = GetLevel(myHero)
  end
end

end)
	
OnCreateObj(function(Object) 
  if GetObjectBaseName(Object) == "Seed" then
  table.insert(Balls, Object)
  DelayAction(function() table.remove(Balls, 1) end, 6900)
  end
end)

AddGapcloseEvent(_E, 500, false) 
