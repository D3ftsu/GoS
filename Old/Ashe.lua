if GetObjectName(GetMyHero()) ~= "Ashe" then return end

require('Inspired') 
require('DeftLib')
require('DamageLib')

local AsheMenu = MenuConfig("Ashe", "Ashe")
AsheMenu:Menu("Combo", "Combo")
AsheMenu.Combo:Boolean("Q", "Use Q", true)
AsheMenu.Combo:Boolean("W", "Use W", true)
AsheMenu.Combo:Boolean("R", "Use R", true)
AsheMenu.Combo:KeyBinding("FireKey", "Ult Fire Key", string.byte("T"))
AsheMenu.Combo:Boolean("Items", "Use Items", true)
AsheMenu.Combo:Slider("myHP", "if HP % <", 50, 0, 100, 1)
AsheMenu.Combo:Slider("targetHP", "if Target HP % >", 20, 0, 100, 1)
AsheMenu.Combo:Boolean("QSS", "Use QSS", true)
AsheMenu.Combo:Slider("QSSHP", "if HP % <", 75, 0, 100, 1)

AsheMenu:Menu("Harass", "Harass")
AsheMenu.Harass:Boolean("Q", "Use Q", true)
AsheMenu.Harass:Boolean("W", "Use W", true)
AsheMenu.Harass:Slider("Mana", "if Mana % >", 30, 0, 80, 1)
AsheMenu.Harass:Boolean("AutoW", "Auto W", true)
AsheMenu.Harass:Slider("WMana", "if Mana % >", 50, 0, 80, 1)

AsheMenu:Menu("Killsteal", "Killsteal")
AsheMenu.Killsteal:Boolean("W", "Killsteal with W", true)
AsheMenu.Killsteal:Boolean("R", "Killsteal with R", false)

if Ignite ~= nil then 
AsheMenu:Menu("Misc", "Misc")
AsheMenu.Misc:Boolean("AutoIgnite", "Auto Ignite", true) 
end

AsheMenu:Menu("LaneClear", "LaneClear")
AsheMenu.LaneClear:Boolean("Q", "Use Q", false)
AsheMenu.LaneClear:Boolean("W", "Use W", false)
AsheMenu.LaneClear:Slider("Mana", "if Mana % >", 30, 0, 80, 1)

AsheMenu:Menu("JungleClear", "JungleClear")
AsheMenu.JungleClear:Boolean("Q", "Use Q", true)
AsheMenu.JungleClear:Boolean("W", "Use W", true)
AsheMenu.JungleClear:Slider("Mana", "if Mana % >", 30, 0, 80, 1)

AsheMenu:Menu("Drawings", "Drawings")
AsheMenu.Drawings:Boolean("W", "Draw W Range", true)

AsheMenu:Menu("Interrupt", "Interrupt (R)")

DelayAction(function()
  local str = {[_Q] = "Q", [_W] = "W", [_E] = "E", [_R] = "R"}
  for i, spell in pairs(CHANELLING_SPELLS) do
    for _,k in pairs(GetEnemyHeroes()) do
        if spell["Name"] == GetObjectName(k) then
        AsheMenu.Interrupt:Boolean(GetObjectName(k).."Inter", "On "..GetObjectName(k).." "..(type(spell.Spellslot) == 'number' and str[spell.Spellslot]), true)
        end
    end
  end
end, 1)

OnProcessSpell(function(unit, spell)
    if GetObjectType(unit) == Obj_AI_Hero and GetTeam(unit) ~= GetTeam(myHero) and IsReady(_R) then
      if CHANELLING_SPELLS[spell.name] then
        if ValidTarget(unit, 1000) and GetObjectName(unit) == CHANELLING_SPELLS[spell.name].Name and AsheMenu.Interrupt[GetObjectName(unit).."Inter"]:Value() then 
        Cast(_R,unit)
        end
      end
    end
end)

OnDraw(function(myHero)
if AsheMenu.Drawings.W:Value() then DrawCircle(GetOrigin(myHero),1200,1,25,GoS.Yellow) end
end)

local target1 = TargetSelector(1200,TARGET_LESS_CAST_PRIORITY,DAMAGE_PHYSICAL,true,false)
local target2 = TargetSelector(2000,TARGET_LESS_CAST_PRIORITY,DAMAGE_PHYSICAL,true,false)
local QReady = false

OnTick(function(myHero)
    local target = GetCurrentTarget()
    local QSS = GetItemSlot(myHero,3140) > 0 and GetItemSlot(myHero,3140) or GetItemSlot(myHero,3139) > 0 and GetItemSlot(myHero,3139) or nil
    local BRK = GetItemSlot(myHero,3153) > 0 and GetItemSlot(myHero,3153) or GetItemSlot(myHero,3144) > 0 and GetItemSlot(myHero,3144) or nil
    local YMG = GetItemSlot(myHero,3142) > 0 and GetItemSlot(myHero,3142) or nil
    local Wtarget = target1:GetTarget()
    local Rtarget = target2:GetTarget()
    
    if IOW:Mode() == "Combo" then
	
	if IsReady(_Q) and QReady and ValidTarget(target, 600) and AsheMenu.Combo.Q:Value() then
        CastSpell(_Q)
        end
						
        if IsReady(_W) and AsheMenu.Combo.W:Value() then
        Cast(_W,Wtarget)
        end
						
        if IsReady(_R) and ValidTarget(Rtarget, 2000) and GetPercentHP(Rtarget) <= 50 and AsheMenu.Combo.R:Value() then
        Cast(_R,Rtarget)
	end
		
	if QSS and IsReady(QSS) and AsheMenu.Combo.QSS:Value() and IsImmobile(myHero) or IsSlowed(myHero) or toQSS and GetPercentHP(myHero) < AsheMenu.Combo.QSSHP:Value() then
        CastSpell(QSS)
        end

    end

    if IOW:Mode() == "Harass" and GetPercentMP(myHero) >= AsheMenu.Harass.Mana:Value() then 

	if IsReady(_Q) and QReady and ValidTarget(target, 600) and AsheMenu.Harass.Q:Value() then
        CastSpell(_Q)
        end
						
        if IsReady(_W) and ValidTarget(Wtarget) and AsheMenu.Harass.W:Value() then
        Cast(_W,Wtarget)
	end
		
    end

    if AsheMenu.Combo.FireKey:Value() and ValidTarget(Rtarget) and IsReady(_R) then
    Cast(_R,Rtarget)
    end

      if AsheMenu.Harass.AutoW:Value() and IsReady(_W) and GetPercentMP(myHero) >= AsheMenu.Harass.WMana:Value() and not IsRecalling(myHero) then
      Cast(_W,Wtarget)
      end

    for i,enemy in pairs(GetEnemyHeroes()) do
	
      if IOW:Mode() == "Combo" then	
	if BRK and IsReady(BRK) and AsheMenu.Combo.Items:Value() and ValidTarget(enemy, 550) and GetPercentHP(myHero) < AsheMenu.Combo.myHP:Value() and GetPercentHP(enemy) > AsheMenu.Combo.targetHP:Value() then
        CastTargetSpell(enemy, BRK)
        end

        if YMG and IsReady(YMG) and AsheMenu.Combo.Items:Value() and ValidTarget(enemy, 600) then
        CastSpell(YMG)
        end	
      end
      
	if Ignite and AsheMenu.Misc.AutoIgnite:Value() then
          if IsReady(Ignite) and 20*GetLevel(myHero)+50 > GetHP(enemy)+GetHPRegen(enemy)*3 and ValidTarget(enemy, 600) then
          CastTargetSpell(enemy, Ignite)
          end
	end
	
	if IsReady(_W) and ValidTarget(enemy,1200) and AsheMenu.Killsteal.W:Value() and GetHP(enemy) < getdmg("W",enemy) then 
	Cast(_W,enemy)
	end
		  
	if IsReady(_R) and ValidTarget(enemy,3000) and AsheMenu.Killsteal.R:Value() and GetHP2(enemy) < getdmg("R",enemy) then
        Cast(_R,enemy)
	end
		
    end
       
    if IOW:Mode() == "LaneClear" then
    	
      local closeminion = ClosestMinion(GetOrigin(myHero), MINION_ENEMY)
      if GetPercentMP(myHero) >= AsheMenu.LaneClear.Mana:Value() then
      
        if IsReady(_W) and AsheMenu.LaneClear.W:Value() then
          local BestPos, BestHit = GetFarmPosition(1200, 300, MINION_ENEMY)
          if BestPos and BestHit > 2 then
	  CastSkillShot(_W, BestPos)
  	  end
        end  
        
        if IsReady(_Q) and AsheMenu.LaneClear.Q:Value() and QReady and ValidTarget(closeminion, 600) then
        CastSpell(_Q)
        end
	        
      end

      for i,mobs in pairs(minionManager.objects) do
		
        if GetTeam(mobs) == 300 and GetPercentMP(myHero) >= AsheMenu.JungleClear.Mana:Value() then
          if IsReady(_Q) and AsheMenu.JungleClear.Q:Value() and QReady and ValidTarget(mobs, 600) then
          CastSpell(_Q)
          end		

	  if IsReady(_W) and AsheMenu.JungleClear.W:Value() and ValidTarget(mobs, 1200) then
	  CastSkillShot(_W,GetOrigin(mobs))
	  end
        end
      end
      
    end

end)

OnUpdateBuff(function(unit,buff)
  if unit == myHero and buff.Name == "asheqcastready" then 
  QReady = true
  end
end)

OnRemoveBuff(function(unit,buff)
  if unit == myHero and buff.Name == "asheqcastready" then 
  QReady = false
  end
end)

OnCreateObj(function(Object) 
  if GetObjectBaseName(Object) == "Ashe_Base_Q_ready.troy" and GetDistance(Object) < 100 then
  QReady = true
  end
end)

OnDeleteObj(function(Object) 
  if GetObjectBaseName(Object) == "Ashe_Base_Q_ready.troy" and GetDistance(Object) < 100 then
  QReady = false
  end
end)

AddGapcloseEvent(_R, 69, false, AsheMenu)

PrintChat(string.format("<font color='#1244EA'>Ashe:</font> <font color='#FFFFFF'> By Deftsu Loaded, Have A Good Game ! </font>"))
PrintChat("Have Fun Using D3Carry Scripts: " ..GetObjectBaseName(myHero)) 
