if GetObjectName(GetMyHero()) ~= "Viktor" then return end

if not pcall( require, "Inspired" ) then PrintChat("You are missing Inspired.lua - Go download it and save it Common!") return end
if not pcall( require, "Deftlib" ) then PrintChat("You are missing Deftlib.lua - Go download it and save it in Common!") return end
if not pcall( require, "DamageLib" ) then PrintChat("You are missing DamageLib.lua - Go download it and save it in Common!") return end

local ViktorMenu = MenuConfig("Viktor", "Viktor")
ViktorMenu:Menu("Combo", "Combo")
ViktorMenu.Combo:Boolean("Q", "Use Q", true)
ViktorMenu.Combo:Boolean("W", "Use W", true)
ViktorMenu.Combo:Boolean("E", "Use E", true)
ViktorMenu.Combo:Boolean("R", "Use R", true)

ViktorMenu:Menu("Harass", "Harass")
ViktorMenu.Harass:Boolean("Q", "Use Q", true)
ViktorMenu.Harass:Boolean("W", "Use W", true)
ViktorMenu.Harass:Boolean("E", "Use E", true)
ViktorMenu.Harass:Slider("Mana", "if Mana % >", 30, 0, 80, 1)

ViktorMenu:Menu("Killsteal", "Killsteal")
ViktorMenu.Killsteal:Boolean("Q", "Killsteal with Q", true)
ViktorMenu.Killsteal:Boolean("E", "Killsteal with E", true)
ViktorMenu.Killsteal:Boolean("R", "Killsteal with R", true)

ViktorMenu:Menu("Misc", "Misc")
ViktorMenu.Misc:Boolean("AutoIgnite", "Auto Ignite", true)
ViktorMenu.Misc:Boolean("Autolvl", "Auto level", true)
ViktorMenu.Misc:DropDown("Autolvltable", "Priority", 1, {"E-Q-W", "Q-E-W"})
	
ViktorMenu:Menu("LaneClear", "LaneClear")
ViktorMenu.LaneClear:Boolean("Q", "Use Q", true)
ViktorMenu.LaneClear:Boolean("E", "Use E", true)
ViktorMenu.LaneClear:Slider("Mana", "if Mana % >", 30, 0, 80, 1)

ViktorMenu:Menu("Drawings", "Drawings")
ViktorMenu.Drawings:Boolean("Q", "Draw Q Range", true)
ViktorMenu.Drawings:Boolean("W", "Draw W Range", true)
ViktorMenu.Drawings:Boolean("E", "Draw E Range", true)
ViktorMenu.Drawings:Boolean("R", "Draw R Range", true)
ViktorMenu.Drawings:ColorPick("color", "Color Picker", {255,255,255,0})

OnDraw(function(myHero)
local col = ViktorMenu.Drawings.color:Value()
if ViktorMenu.Drawings.Q:Value() then DrawCircle(myHeroPos(),700,1,0,col) end
if ViktorMenu.Drawings.W:Value() then DrawCircle(myHeroPos(),700,1,0,col) end
if ViktorMenu.Drawings.E:Value() then DrawCircle(myHeroPos(),1225,1,0,col) end
if ViktorMenu.Drawings.R:Value() then DrawCircle(myHeroPos(),700,1,0,col) end	
end)

local lastlevel = GetLevel(myHero)-1

OnTick(function(myHero)
    local target = GetCurrentTarget()
	
    if IOW:Mode() == "Combo" then
 														
		if IsReady(_E) and ValidTarget(target, 1225) and ViktorMenu.Combo.E:Value() then
                  local StartPos = Vector(myHero) - 525 * (Vector(myHero) - Vector(target)):normalized()
		  local EPred = GetPredictionForPlayer(StartPos,target,GetMoveSpeed(target),1200,0,1225,80,false,true)
                  if EPred.HitChance == 1 then
                  CastSkillShot3(_E,StartPos,EPred.PredPos)
		  end
		end
					
		if IsReady(_Q) and ValidTarget(target, 700) and ViktorMenu.Combo.Q:Value() then
	        CastTargetSpell(target, _Q)
		end
				 
		if IsReady(_W) and ValidTarget(target, 700) and ViktorMenu.Combo.W:Value() and GetPercentHP(target) < 70 then
		Cast(_W,target)
	        end
	
	        if IsReady(_R) and ValidTarget(target, 700) and getdmg("R",target,myHero,2)*4 > GetHP2(target) then
                Cast(_R,target)
                elseif GetCastName(myHero, _R) == "viktorchaosstormguide" and ValidTarget(target, 1000) and ViktorMenu.Combo.R:Value() then
                CastSkillShot(_R,GetOrigin(target))
                end
        
	end
					        
        if IOW:Mode() == "Harass" and GetPercentMP(myHero) >= ViktorMenu.Harass.Mana:Value() then
	                 
		if IsReady(_E) and ValidTarget(target, 1225) and ViktorMenu.Harass.E:Value() then
		  local StartPos = Vector(myHero) - 525 * (Vector(myHero) - Vector(target)):normalized()
		  local EPred = GetPredictionForPlayer(StartPos,target,GetMoveSpeed(target),1200,0,1225,80,false,true)
                  if EPred.HitChance == 1 then
                  CastSkillShot3(_E,StartPos,EPred.PredPos)
		  end
		end
					
		if IsReady(_Q) and ValidTarget(target, 700) and ViktorMenu.Harass.Q:Value() then
		CastTargetSpell(target, _Q)
		end
					  
		if IsReady(_W) and ValidTarget(target, 700) and ViktorMenu.Harass.W:Value() and GetPercentHP(target) < 70 then
		Cast(_W,target)
		end
					 
		if GetCastName(myHero, _R) == "viktorchaosstormguide" and ValidTarget(target, 1000) then
                CastSkillShot(_R,GetOrigin(target))
                end
				
	end

    for i,enemy in pairs(GetEnemyHeroes()) do

	if Ignite and ViktorMenu.Misc.AutoIgnite:Value() then
          if CanUseSpell(myHero, Ignite) == READY and 20*GetLevel(myHero)+50 > GetCurrentHP(enemy)+GetHPRegen(enemy)*3 and GetDistanceSqr(GetOrigin(enemy)) < 600*600 then
          CastTargetSpell(enemy, Ignite)
          end
        end
				
	if IsReady(_Q) and ValidTarget(enemy, 700) and ViktorMenu.Killsteal.Q:Value() and GetHP2(enemy) < getdmg("Q",enemy) then
        CastTargetSpell(enemy, _Q)
        elseif IsReady(_E) and ValidTarget(enemy,1225) and ViktorMenu.Killsteal.E:Value() and GetHP2(enemy) < getdmg("E",enemy) then
	  local StartPos = Vector(myHero) - 525 * (Vector(myHero) - Vector(enemy)):normalized()
	  local EPred = GetPredictionForPlayer(StartPos,enemy,GetMoveSpeed(enemy),1200,0,1225,80,false,true)
          if EPred.HitChance == 1 then
          CastSkillShot3(_E,StartPos,EPred.PredPos)
	  end
	elseif IsReady(_R) and ValidTarget(enemy, 700) and ViktorMenu.Killsteal.R:Value() and GetHP2(enemy) < getdmg("R",enemy) then  
        Cast(_R,enemy)    
        end
		
   end

   if IOW:Mode() == "LaneClear" and GetPercentMP(myHero) >= ViktorMenu.LaneClear.Mana:Value() then
     	
        if IsReady(_E) and ViktorMenu.LaneClear.E:Value() then
          local BestPos, BestHit = GetLineFarmPosition(1225, 80)
          if BestPos and BestHit > 0 then
          StartPos = Vector(myHero) - 525 * (Vector(myHero) - Vector(BestPos)):normalized()		   
          CastSkillShot3(_E, StartPos, BestPos)
          end
	end
       
        for i,mobs in pairs(minionManager.objects) do
          if GetTeam(mobs) == MINION_ENEMY then
            if IsReady(_Q) and ViktorMenu.LaneClear.Q:Value() then
            CastTargetSpell(mobs, _Q)
            end
          end
        end
   
   end

   
       

if ViktorMenu.Misc.Autolvl:Value() then  
  if GetLevel(myHero) > lastlevel then
    if ViktorMenu.Misc.Autolvltable:Value() == 1 then leveltable = {_E, _Q, _W, _E, _E, _R, _E, _Q, _E, _Q, _R, _Q, _Q, _W, _W, _R, _W, _W}
    elseif ViktorMenu.Misc.Autolvltable:Value() == 2 then leveltable = {_E, _Q, _W, _Q, _Q, _R, _Q, _E, _Q, _E, _R, _E, _E, _W, _W, _R, _W, _W}
    end
    DelayAction(function() LevelSpell(leveltable[GetLevel(myHero)]) end, math.random(1000,3000))
    lastlevel = GetLevel(myHero)
  end
end

end)

AddGapcloseEvent(_W, 100, false)
