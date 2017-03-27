if GetObjectName(GetMyHero()) ~= "Twitch" then return end

require('Inspired')
require('DeftLib')
require('DamageLib')

local TwitchMenu = MenuConfig("Twitch", "Twitch")
TwitchMenu:Menu("Combo", "Combo")
TwitchMenu.Combo:Boolean("Q", "Use Q", true)
TwitchMenu.Combo:Slider("QEnemies", "Use Q if x enemies", 3, 0, 5, 1)
TwitchMenu.Combo:Boolean("Qlow", "Use Q if LowHP", true)
TwitchMenu.Combo:Slider("Qlowhp", "Use Q if My Health % <", 30, 0, 100, 1)
TwitchMenu.Combo:Boolean("W", "Use W", true)
TwitchMenu.Combo:Boolean("E", "Use E", true)
TwitchMenu.Combo:Slider("EStacks", "Use E if x stacks", 6, 0, 6, 0)
TwitchMenu.Combo:Boolean("Erange", "Use E if target is out of range", false)
TwitchMenu.Combo:Boolean("R", "Use R", true)
TwitchMenu.Combo:Slider("REnemies", "Use R if x enemies", 3, 0, 5, 1)
TwitchMenu.Combo:Boolean("Items", "Use Items", true)
TwitchMenu.Combo:Slider("myHP", "if HP % <", 50, 0, 100, 1)
TwitchMenu.Combo:Slider("targetHP", "if Target HP % >", 20, 0, 100, 1)
TwitchMenu.Combo:Boolean("QSS", "Use QSS", true)
TwitchMenu.Combo:Slider("QSSHP", "if My Health % <", 75, 0, 100, 1)

TwitchMenu:Menu("Harass", "Harass")
TwitchMenu.Harass:Boolean("W", "Use W", true)
TwitchMenu.Harass:Boolean("E", "Use E", true)
TwitchMenu.Harass:Slider("EStacks", "Use E if x stacks", 6, 0, 6, 0)
TwitchMenu.Harass:Boolean("Erange", "Use E if target is out of range", false)

TwitchMenu:Menu("Killsteal", "Killsteal")
TwitchMenu.Killsteal:Boolean("E", "Killsteal with E", true)

if Ignite ~= nil then
TwitchMenu:Menu("Misc", "Misc")
TwitchMenu.Misc:Boolean("AutoIgnite", "Auto Ignite", true)
end

TwitchMenu:Menu("Farm", "Farm")
TwitchMenu.Farm:Boolean("ECanon", "Always E Big Minions", false)
TwitchMenu.Farm:Slider("Mana", "if Mana % >", 30, 0, 80, 1)
TwitchMenu.Farm:Menu("Jungle", "Jungle Clear")
TwitchMenu.Farm.Jungle:Boolean("firstmins", "Don't E jungle first 2 minutes", true)
TwitchMenu.Farm.Jungle:List("je", "Jungle Execute:", 3, {"OFF", "Epic Only", "Large & Epic Only", "Everything"})

TwitchMenu:Menu("Drawings", "Drawings")
TwitchMenu.Drawings:Boolean("W", "Draw W Range", true)
TwitchMenu.Drawings:Boolean("E", "Draw E Range", true)
TwitchMenu.Drawings:Boolean("R", "Draw R Range", true)
TwitchMenu.Drawings:Boolean("Edmg", "Draw E Damage %", true)
TwitchMenu.Drawings:Boolean("Vis", "Draw Visibility", true)

local IsInvisible = false

OnDraw(function(myHero)
local pos = GetOrigin(myHero)
if TwitchMenu.Drawings.W:Value() then DrawCircle(pos,950,1,0,GoS.Pink) end
if TwitchMenu.Drawings.E:Value() then DrawCircle(pos,1200,1,0,GoS.Yellow) end
if TwitchMenu.Drawings.R:Value() then DrawCircle(pos,850,1,0,GoS.Green) end
if TwitchMenu.Drawings.Vis:Value() then
local drawPos = WorldToScreen(1,GetOrigin(myHero))
  if not IsInvisible then
  DrawText("STEALTH", 25, drawPos.x, drawPos.y, ARGB(255, 0, 255, 0))
  else
  DrawText("VISIBLE", 25, drawPos.x, drawPos.y, ARGB(255, 255, 0, 0))
  end
end
if TwitchMenu.Drawings.Edmg:Value() then
  for i,enemy in pairs(GetEnemyHeroes()) do
    local drawPos = WorldToScreen(1,GetOrigin(enemy))
    if Edmg(enemy) > GetCurrentHP(enemy) then
    DrawText("100%",20,drawPos.x,drawPos.y,0xffffffff)
    elseif Edmg(enemy) > 0 then
    DrawText(math.floor(Edmg(enemy)/GetCurrentHP(enemy)*100).."%",20,drawPos.x,drawPos.y,0xffffffff)
    end
  end

  for _,unit in pairs(minionManager.objects) do
    if GetTeam(unit) == 300 and ValidTarget(unit, 2000) then
      local drawPos = WorldToScreen(1,GetOrigin(unit))
      if Edmg(unit) > GetCurrentHP(unit) then
      DrawText("100%",20,drawPos.x,drawPos.y,0xffffffff)
      elseif Edmg(unit) > 0 then
      DrawText(math.floor(Edmg(unit)/GetCurrentHP(unit)*100).."%",20,drawPos.x,drawPos.y,0xffffffff)
      end
    end
  end
end
end)

local Epics = {"SRU_Baron", "SRU_Dragon", "TT_Spiderboss"}
local Mobs = {"SRU_Baron", "SRU_Dragon", "SRU_Red", "SRU_Blue", "SRU_Krug", "SRU_Murkwolf", "SRU_Razorbeak", "SRU_Gromp", "Sru_Crab", "TT_Spiderboss"}
local target1 = TargetSelector(1075,TARGET_LESS_CAST_PRIORITY,DAMAGE_PHYSICAL,true,false)

OnTick(function(myHero)
    local target = GetCurrentTarget()
    local QSS = GetItemSlot(myHero,3140) > 0 and GetItemSlot(myHero,3140) or GetItemSlot(myHero,3139) > 0 and GetItemSlot(myHero,3139) or nil
    local BRK = GetItemSlot(myHero,3153) > 0 and GetItemSlot(myHero,3153) or GetItemSlot(myHero,3144) > 0 and GetItemSlot(myHero,3144) or nil
    local YMG = GetItemSlot(myHero,3142) > 0 and GetItemSlot(myHero,3142) or nil
    local Wtarget = target1:GetTarget()
    
    if IOW:Mode() == "Combo" then

      if IsReady(_Q) and TwitchMenu.Combo.Q:Value() and EnemiesAround(GetOrigin(myHero), 1000) >= TwitchMenu.Combo.QEnemies:Value() then
      CastSpell(_Q)
      end
	  
      if IsReady(_Q) and TwitchMenu.Combo.Qlow:Value() and GetPercentHP(myHero) <= TwitchMenu.Combo.Qlowhp:Value() then
      CastSpell(_Q)
      end
	  
      if IsReady(_E) and ValidTarget(target,1200) and TwitchMenu.Combo.E:Value() then
        if Estacks(target) == TwitchMenu.Combo.EStacks:Value() then
	CastSpell(_E)
	elseif TwitchMenu.Combo.Erange:Value() and GetDistance(target) >= 1100 then
        CastSpell(_E)
	end
      end
		
      if IsReady(_W) and TwitchMenu.Combo.W:Value() then
      Cast(_W,Wtarget)
      end
	 
      if IsReady(_R) and TwitchMenu.Combo.R:Value() and ValidTarget(target, 850) and EnemiesAround(GetOrigin(target), 500) >= TwitchMenu.Combo.REnemies:Value() then
      CastSpell(_R)
      end
     
      if QSS and IsReady(QSS) and TwitchMenu.Combo.QSS:Value() and IsImmobile(myHero) or IsSlowed(myHero) or toQSS and GetPercentHP(myHero) < TwitchMenu.Combo.QSSHP:Value() then
      CastSpell(QSS)
      end
					
   end
   
   if IOW:Mode() == "Harass" then

     if IsReady(_E) and ValidTarget(target,1200) and TwitchMenu.Harass.E:Value() then
       if Estacks(target) == TwitchMenu.Harass.EStacks:Value() then
       CastSpell(_E)
       elseif TwitchMenu.Harass.Erange:Value() and GetDistance(target) >= 1100 then
       CastSpell(_E)
       end
     end
		
     if IsReady(_W) and TwitchMenu.Harass.W:Value() then
     Cast(_W,Wtarget)
     end
					
   end
	
   for i,enemy in pairs(GetEnemyHeroes()) do
   
     if IOW:Mode() == "Combo" then	
       if BRK and IsReady(BRK) and TwitchMenu.Combo.Items:Value() and ValidTarget(enemy, 550) and GetPercentHP(myHero) < TwitchMenu.Combo.myHP:Value() and GetPercentHP(enemy) > TwitchMenu.Combo.targetHP:Value() then
       CastTargetSpell(enemy, BRK)
       end

       if YMG and IsReady(YMG) and TwitchMenu.Combo.Items:Value() and ValidTarget(enemy, 600) then
       CastSpell(YMG)
       end	
     end
      
     if Ignite and TwitchMenu.Misc.Autoignite:Value() then
       if IsReady(Ignite) and 20*GetLevel(myHero)+50 > GetHP(enemy)+GetHPRegen(enemy)*3 and ValidTarget(enemy, 600) then
       CastTargetSpell(enemy, Ignite)
       end
     end
                
     if IsReady(_E) and TwitchMenu.Killsteal.E:Value() and GetHP(enemy) < Edmg(enemy) then
     CastSpell(_E)
     end

   end

   for i,unit in pairs(minionManager.objects) do
     	
     if GetTeam(unit) == MINION_ENEMY then
       if Edmg(unit) > 0 and Edmg(unit) > GetCurrentHP(unit) and (GetObjectName(unit):find("Siege")) and ValidTarget(unit, 1200) and TwitchMenu.Farm.ECanon:Value() and 100*GetCurrentMana(myHero)/GetMaxMana(myHero) > TwitchMenu.Farm.Mana:Value() then 
       CastSpell(_E)
       end
	  
       if Edmg(unit) > 0 and Edmg(unit) > GetCurrentHP(unit) and (GetObjectName(unit):find("super")) and ValidTarget(unit, 1200) and TwitchMenu.Farm.ECanon:Value() and 100*GetCurrentMana(myHero)/GetMaxMana(myHero) > TwitchMenu.Farm.Mana:Value() then 
       CastSpell(_E)
       end
     end
       
     if GetTeam(unit) == 300 and ValidTarget(unit, 1200) and IsReady(_E) and TwitchMenu.Farm.Jungle.je:Value() ~= 1 then
    	
       if TwitchMenu.Farm.Jungle.je:Value() == 2 then
         for i,Epic in pairs(Epics) do
           if GetObjectName(unit) == Epic and GetCurrentHP(unit) < Edmg(unit) then  
           CastSpell(_E)
           end
         end
       end 
      
       if TwitchMenu.Farm.Jungle.je:Value() == 3 then
         for i,Mob in pairs(Mobs) do
           if GetObjectName(unit) == Mob and GetCurrentHP(unit) < Edmg(unit) then  
           CastSpell(_E)
           end
         end
       end 
      
       if TwitchMenu.Farm.Jungle.je:Value() == 4 then
         if GetCurrentHP(unit) < Edmg(unit) then  
         CastSpell(_E)
         end
       end
      
     end

   end

end)

local Estack = {}

OnUpdateBuff(function(unit,buff)
  if GetTeam(unit) ~= GetTeam(myHero) and buff.Name == "twitchdeadlyvenom" then
  Estack[GetNetworkID(unit)] = buff.Count
  end
  if unit == myHero and buff.type == 6 then
  IsInvisible = true
  end
end)

OnRemoveBuff(function(unit,buff)
  if GetTeam(unit) ~= GetTeam(myHero) and buff.Name == "twitchdeadlyvenom" then
  Estack[GetNetworkID(unit)] = 0
  end
  if unit == myHero and buff.type == 6 then
  IsInvisible = false
  end
end)

function Estacks(unit)
   return (Estack[GetNetworkID(unit)] or 0)
end

function Edmg(unit)	
  return CalcDamage(myHero,unit,(5*GetCastLevel(myHero,_E)+10+.2*GetBonusAP(myHero)+.25*(GetBonusDmg(myHero)))*Estacks(unit))
end

PrintChat(string.format("<font color='#1244EA'>Twitch:</font> <font color='#FFFFFF'> By Deftsu Loaded, Have A Good Game ! </font>")) 
PrintChat("Have Fun Using D3Carry Scripts: " ..GetObjectBaseName(myHero)) 
