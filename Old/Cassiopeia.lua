if GetObjectName(GetMyHero()) ~= "Cassiopeia" then return end

require('Inspired')
require('DeftLib')
require('DamageLib')

local CassiopeiaMenu = MenuConfig("Cassiopeia", "Cassiopeia")
CassiopeiaMenu:Menu("Combo", "Combo")
CassiopeiaMenu.Combo:Boolean("Q", "Use Q", true)
CassiopeiaMenu.Combo:Boolean("W", "Use W", true)
CassiopeiaMenu.Combo:Boolean("E", "Use E", true)
CassiopeiaMenu.Combo:Boolean("R", "Use R", true)

CassiopeiaMenu:Menu("Harass", "Harass")
CassiopeiaMenu.Harass:Boolean("Q", "Use Q", true)
CassiopeiaMenu.Harass:Boolean("W", "Use W", true)
CassiopeiaMenu.Harass:Boolean("E", "Use E", true)

CassiopeiaMenu:Menu("Killsteal", "Killsteal")
CassiopeiaMenu.Killsteal:Boolean("Q", "Killsteal with Q", true)
CassiopeiaMenu.Killsteal:Boolean("W", "Killsteal with W", true)
CassiopeiaMenu.Killsteal:Boolean("E", "Killsteal with E", true)

CassiopeiaMenu:Menu("Misc", "Misc")
if Ignite ~= nil then CassiopeiaMenu.Misc:Boolean("AutoIgnite", "Auto Ignite", true) end
CassiopeiaMenu.Misc:Slider("E", "E Humanizer", 0, 0, 1, 0.1)

CassiopeiaMenu:Menu("Farm", "Farm")
CassiopeiaMenu.Farm:Boolean("AutoE", "Auto E if pois", true)
CassiopeiaMenu.Farm:Menu("LastHit2", "LastHit with E")
CassiopeiaMenu.Farm.LastHit2:Boolean("EX", "Enabled", true)
CassiopeiaMenu.Farm.LastHit2:Boolean("EXP", "Only if pois", true)
CassiopeiaMenu.Farm:Menu("LaneClear", "LaneClear")
CassiopeiaMenu.Farm.LaneClear:Boolean("Q", "Use Q", true)
CassiopeiaMenu.Farm.LaneClear:Boolean("W", "Use W", true)
CassiopeiaMenu.Farm.LaneClear:Boolean("E", "Use E", true)
CassiopeiaMenu.Farm.LaneClear:Slider("Mana", "Min Mana %", 30, 1, 100, 1)

CassiopeiaMenu:Menu("JungleClear", "JungleClear")
CassiopeiaMenu.JungleClear:Boolean("Q", "Use Q", true)
CassiopeiaMenu.JungleClear:Boolean("W", "Use W", true)
CassiopeiaMenu.JungleClear:Boolean("E", "Use E", true)
CassiopeiaMenu.JungleClear:Slider("Mana", "Min Mana %", 30, 1, 100, 1)

CassiopeiaMenu:Menu("Drawings", "Drawings")
CassiopeiaMenu.Drawings:Boolean("Q", "Draw Q Range", true)
CassiopeiaMenu.Drawings:Boolean("W", "Draw W Range", true)
CassiopeiaMenu.Drawings:Boolean("E", "Draw E Range", true)
CassiopeiaMenu.Drawings:Boolean("R", "Draw R Range", true)
	
CassiopeiaMenu:Menu("Interrupt", "Interrupt (R)")

DelayAction(function()
  local str = {[_Q] = "Q", [_W] = "W", [_E] = "E", [_R] = "R"}
  for i, spell in pairs(CHANELLING_SPELLS) do
    for _,k in pairs(GetEnemyHeroes()) do
        if spell["Name"] == GetObjectName(k) then
        CassiopeiaMenu.Interrupt:Boolean(GetObjectName(k).."Inter", "On "..GetObjectName(k).." "..(type(spell.Spellslot) == 'number' and str[spell.Spellslot]), true)
        end
    end
  end
end, 1)

OnProcessSpell(function(unit, spell)
    if GetObjectType(unit) == Obj_AI_Hero and GetTeam(unit) ~= GetTeam(myHero) and IsReady(_R) then
      if CHANELLING_SPELLS[spell.name] then
        if IsFacing(unit,850) and ValidTarget(unit, 850) and GetObjectName(unit) == CHANELLING_SPELLS[spell.name].Name and CassiopeiaMenu.Interrupt[GetObjectName(unit).."Inter"]:Value() then 
        Cast(_R,unit)
        end
      end
    end
    
    if unit == myHero and spell.name == "CassiopeiaTwinFang" then
    lastE = GetTickCount()
    end
end)

OnDraw(function(myHero)
local pos = GetOrigin(myHero)
if CassiopeiaMenu.Drawings.Q:Value() then DrawCircle(pos,850,1,25,GoS.Pink) end
if CassiopeiaMenu.Drawings.W:Value() then DrawCircle(pos,925,1,25,GoS.Yellow) end
if CassiopeiaMenu.Drawings.E:Value() then DrawCircle(pos,700,1,25,GoS.Blue) end
if CassiopeiaMenu.Drawings.R:Value() then DrawCircle(pos,825,1,25,GoS.Green) end
end)

local target1 = TargetSelector(900,TARGET_LESS_CAST_PRIORITY,DAMAGE_MAGIC,true,false)
local target2 = TargetSelector(970,TARGET_LESS_CAST_PRIORITY,DAMAGE_MAGIC,true,false)
local target3 = TargetSelector(825,TARGET_LESS_CAST_PRIORITY,DAMAGE_MAGIC,true,false)
local LastE = 0

OnTick(function(myHero)
    local target = GetCurrentTarget()
    local Qtarget = target1:GetTarget()
    local Wtarget = target2:GetTarget()
    local Rtarget = target3:GetTarget()
    
    if IOW:Mode() == "Combo" then

		if IsReady(_R) and IsFacing(Rtarget, 825) and ValidTarget(Rtarget, 825) and CassiopeiaMenu.Combo.R:Value() and GetPercentHP(Rtarget) <= 50 and GetPercentMP(myHero) >= 30 then
		Cast(_R,Rtarget)
		end

	        if GetTickCount() >= LastE*1000 and IsReady(_E) and IsPoisoned(target) and CassiopeiaMenu.Combo.E:Value() and ValidTarget(target, 700) then
		CastTargetSpell(target, _E)
		end
			
		if IsReady(_Q) and CassiopeiaMenu.Combo.Q:Value() then
		Cast(_Q,Qtarget)
		end
		
		if IsReady(_W) and CassiopeiaMenu.Combo.W:Value() then
		Cast(_W,Wtarget)
		end
		
    end

    if IOW:Mode() == "Harass" then
	
	        if GetTickCount() > LastE*1000 and IsReady(_E) and IsPoisoned(target) and CassiopeiaMenu.Harass.E:Value() and ValidTarget(target, 700) then
		CastTargetSpell(target, _E)
		end
			
		if IsReady(_Q) and CassiopeiaMenu.Harass.Q:Value() then
	        Cast(_Q,Qtarget)
		end
		
		if IsReady(_W) and CassiopeiaMenu.Harass.W:Value() then
		Cast(_W,Wtarget)
		end
		
    end

	for i,enemy in pairs(GetEnemyHeroes()) do
		
		if Ignite and CassiopeiaMenu.Misc.AutoIgnite:Value() then
                  if IsReady(Ignite) and 20*GetLevel(myHero)+50 > GetHP(enemy)+GetHPRegen(enemy)*3 and ValidTarget(enemy, 600) then
                  CastTargetSpell(enemy, Ignite)
                  end
		end
		
		if IsReady(_Q) and ValidTarget(enemy, 900) and CassiopeiaMenu.Killsteal.Q:Value() and GetHP2(enemy) < getdmg("Q",enemy) then 
		Cast(_Q,enemy)
		elseif IsReady(_E) and ValidTarget(enemy, 700) and CassiopeiaMenu.Killsteal.E:Value() and GetHP2(enemy) < getdmg("E",enemy) then
		CastTargetSpell(enemy, _E)
		elseif IsReady(_W) and ValidTarget(enemy, 970) and CassiopeiaMenu.Killsteal.W:Value() and GetHP2(enemy) < getdmg("W",enemy) then
		Cast(_W,enemy)
		end
		
	end

        for i,mobs in pairs(minionManager.objects) do
          if GetTeam(mobs) == MINION_ENEMY and IsReady(_E) and IsPoisoned(mobs) and CassiopeiaMenu.Farm.AutoE:Value() and ValidTarget(mobs, 700) and GetCurrentHP(mobs) < getdmg("E",mobs) then
	  CastTargetSpell(mobs, _E)
	  end
        end

        if IOW:Mode() == "LaneClear" then
          if GetPercentMP(myHero) >= CassiopeiaMenu.Farm.LaneClear.Mana:Value() then
          
            if IsReady(_Q) and CassiopeiaMenu.Farm.LaneClear.Q:Value() then
              local BestPos, BestHit = GetFarmPosition(850, 100, MINION_ENEMY)
              if BestPos and BestHit > 0 then 
              CastSkillShot(_Q,BestPos)
              end
	    end
	          
	    if IsReady(_W) and CassiopeiaMenu.Farm.LaneClear.W:Value() then
              local BestPos, BestHit = GetFarmPosition(925, 90, MINION_ENEMY)
              if BestPos and BestHit > 0 then 
              CastSkillShot(_W,BestPos)
              end
	    end
	    
	  end
	  
	  if GetPercentMP(myHero) >= CassiopeiaMenu.JungleClear.Mana:Value() then
	  
	    if IsReady(_Q) and CassiopeiaMenu.JungleClear.Q:Value() then
	      local BestPos, BestHit = GetFarmPosition(850, 100, 300)
              if BestPos and BestHit > 0 then 
              CastSkillShot(_Q,BestPos)
	      end
	    end
            
	    if IsReady(_W) and CassiopeiaMenu.JungleClear.W:Value() then
	      local BestPos, BestHit = GetFarmPosition(925, 90, 300)
              if BestPos and BestHit > 0 then 
              CastSkillShot(_W,BestPos)
	      end
            end
	
            for i,mobs in pairs(minionManager.objects) do
              if GetTeam(mobs) == 300 and GetTickCount() >= LastE*1000 and IsReady(_E) and IsPoisoned(mobs) and CassiopeiaMenu.JungleClear.E:Value() and ValidTarget(mobs, 700) then
	      CastTargetSpell(mobs, _E)
	      end
              if GetTeam(mobs) == MINION_ENEMY and GetTickCount() >= LastE*1000 and IsReady(_E) and IsPoisoned(mobs) and CassiopeiaMenu.Farm.LaneClear.E:Value() and ValidTarget(mobs, 700) and GetCurrentHP(mobs) < getdmg("E",mobs) then
	      CastTargetSpell(mobs, _E)
              end
	    end
	    
	  end
	end
	
        if IOW:Mode() == "LastHit" then
          for i,mobs in pairs(minionManager.objects) do
            if GetTeam(mobs) == MINION_ENEMY then
	      if IsReady(_E) and IsPoisoned(mobs) and CassiopeiaMenu.Farm.LastHit2.EX:Value() and CassiopeiaMenu.Farm.LastHit2.EXP:Value() and ValidTarget(mobs, 700) and GetCurrentHP(mobs) < getdmg("E",mobs) then
	      CastTargetSpell(mobs, _E)
	      elseif IsReady(_E) and CassiopeiaMenu.Farm.LastHit2.EX:Value() and not CassiopeiaMenu.Farm.LastHit2.EXP:Value() and ValidTarget(mobs, 700) and getdmg("E",mobs) then
	      CastTargetSpell(mobs, _E)
	      end
	
	      if CassiopeiaMenu.Farm.AutoE:Value() then
	        if IsReady(_E) and IsPoisoned(mobs) and ValidTarget(mobs, 700) and GetCurrentHP(mobs) < getdmg("E",mobs) and IOW:Mode() ~= "Combo" and IOW:Mode() ~= "Harass" then
	        CastTargetSpell(mobs, _E)
	        end
	      end
	      
	    end
	  end
	end

end)


local poisoned = {}

OnUpdateBuff(function(unit,buff)
  if GetTeam(unit) ~= GetTeam(myHero) and buff.Name:find("poison") then
  poisoned[GetNetworkID(unit)] = buff.Count
  end
end)

OnRemoveBuff(function(unit,buff)
  if GetTeam(unit) ~= GetTeam(myHero) and buff.Name:find("poison") then
  poisoned[GetNetworkID(unit)] = 0
  end
end)

function IsPoisoned(unit)
   return (poisoned[GetNetworkID(unit)] or 0) > 0
end

AddGapcloseEvent(_R, 69, false, CassiopeiaMenu)

PrintChat(string.format("<font color='#1244EA'>Cassiopeia:</font> <font color='#FFFFFF'> By Deftsu Loaded, Have A Good Game ! </font>"))
PrintChat("Have Fun Using D3Carry Scripts: " ..GetObjectBaseName(myHero)) 
