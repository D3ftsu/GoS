if GetObjectName(GetMyHero()) ~= "Alistar" then return end

require('Inspired')
require('DeftLib')
require('DamageLib')

local AlistarMenu = MenuConfig("Alistar", "Alistar")
AlistarMenu:Menu("Combo", "Combo")
AlistarMenu.Combo:Boolean("Q", "Use Q", true)
AlistarMenu.Combo:Boolean("WQ", "Use W+Q Combo", true)
 
AlistarMenu:Menu("Harass", "Harass")
AlistarMenu.Harass:Boolean("Q", "Use Q", true)
AlistarMenu.Harass:Boolean("WQ", "Use W+Q Combo", true)
AlistarMenu.Harass:Slider("Mana", "if Mana % >", 30, 0, 80, 1)

AlistarMenu:Menu("Killsteal", "Killsteal")
AlistarMenu.Killsteal:Boolean("Q", "Killsteal with Q", true)
AlistarMenu.Killsteal:Boolean("W", "Killsteal with W", true)
AlistarMenu.Killsteal:Boolean("WQ", "Killsteal with W+Q", true)

AlistarMenu:Menu("Misc", "Misc")
if Ignite ~= nil then AlistarMenu.Misc:Boolean("Autoignite", "Auto Ignite", true) end
AlistarMenu.Misc:Boolean("Eme", "Self-Heal", true)
AlistarMenu.Misc:Slider("mpEme", "Minimum Mana %", 25, 0, 100, 0)
AlistarMenu.Misc:Slider("hpEme", "Minimum HP%", 70, 0, 100, 0)
AlistarMenu.Misc:Boolean("Eally", "Heal Allies", true)
AlistarMenu.Misc:Slider("mpEally", "Minimum Mana %", 50, 0, 100, 0)
AlistarMenu.Misc:Slider("hpEally", "Minimum HP %", 35, 0, 100, 0)

AlistarMenu:Menu("Drawings", "Drawings")
AlistarMenu.Drawings:Boolean("Q", "Draw Q Range", true)
AlistarMenu.Drawings:Boolean("W", "Draw W Range", true)
AlistarMenu.Drawings:Boolean("E", "Draw E Range", true)

AlistarMenu:Menu("Interrupt", "Interrupt")
AlistarMenu.Interrupt:Menu("SupportedSpells", "Supported Spells")
AlistarMenu.Interrupt.SupportedSpells:Boolean("Q", "Use Q", true)
AlistarMenu.Interrupt.SupportedSpells:Boolean("W", "Use W", true)

DelayAction(function()
  local str = {[_Q] = "Q", [_W] = "W", [_E] = "E", [_R] = "R"}
  for i, spell in pairs(CHANELLING_SPELLS) do
    for _,k in pairs(GetEnemyHeroes()) do
        if spell["Name"] == GetObjectName(k) then
        AlistarMenu.Interrupt:Boolean(GetObjectName(k).."Inter", "On "..GetObjectName(k).." "..(type(spell.Spellslot) == 'number' and str[spell.Spellslot]), true)
        end
    end
  end
end, 0)

OnProcessSpell(function(unit, spell)
    if GetObjectType(unit) == Obj_AI_Hero and GetTeam(unit) ~= GetTeam(myHero) then
      if CHANELLING_SPELLS[spell.name] then
        if ValidTarget(unit, 650) and IsReady(_W) and GetObjectName(unit) == CHANELLING_SPELLS[spell.name].Name and AlistarMenu.Interrupt[GetObjectName(unit).."Inter"]:Value() and AlistarMenu.Interrupt.SupportedSpells.W:Value() then
        CastTargetSpell(unit, _W)
        elseif ValidTarget(unit, 365) and IsReady(_Q) and GetObjectName(unit) == CHANELLING_SPELLS[spell.name].Name and AlistarMenu.Interrupt[GetObjectName(unit).."Inter"]:Value() and AlistarMenu.Interrupt.SupportedSpells.Q:Value() then
        CastSpell(_Q)
        end
      end
    end
end)
  
OnDraw(function(myHero)
local pos = GetOrigin(myHero)
if AlistarMenu.Drawings.Q:Value() then DrawCircle(pos,365,1,25,GoS.Pink) end
if AlistarMenu.Drawings.W:Value() then DrawCircle(pos,650,1,25,GoS.Yellow) end
if AlistarMenu.Drawings.E:Value() then DrawCircle(pos,575,1,25,GoS.Blue) end
end)

local target1 = TargetSelector(650,TARGET_LESS_CAST_PRIORITY,DAMAGE_MAGIC,true,false)

OnTick(function(myHero)
    local target = GetCurrentTarget()
    local Wtarget = target1:GetTarget()
	
    if IOW:Mode() == "Combo" then

	if IsReady(_Q) and AlistarMenu.Combo.Q:Value() and ValidTarget(target,365) then
        CastSpell(_Q)
        end
		
        if IsReady(_W) and IsReady(_Q) and AlistarMenu.Combo.WQ:Value() and ValidTarget(Wtarget,650) and GetCurrentMana(myHero) >= GetCastMana(myHero,_Q,GetCastLevel(myHero,_Q)) + GetCastMana(myHero,_W,GetCastLevel(myHero,_W)) then
        CastTargetSpell(Wtarget, _W)
	DelayAction(function() CastSpell(_Q) end, (math.max(0 , GetDistance(Wtarget) - 500 ) * 0.4 + 25))*0.001)
        end

    end
    
    if IOW:Mode() == "Harass" and GetPercentMP(myHero) >= AlistarMenu.Harass.Mana:Value() then

	if IsReady(_Q) and AlistarMenu.Harass.Q:Value() and ValidTarget(target,365) then
        CastSpell(_Q)
        end
		
        if IsReady(_W) and IsReady(_Q) and AlistarMenu.Harass.WQ:Value() and ValidTarget(Wtarget,650) and GetCurrentMana(myHero) >= GetCastMana(myHero,_Q,GetCastLevel(myHero,_Q)) + GetCastMana(myHero,_W,GetCastLevel(myHero,_W)) then
        CastTargetSpell(Wtarget, _W)
	DelayAction(function() CastSpell(_Q) end, (math.max(0 , GetDistance(Wtarget) - 500 ) * 0.4 + 25))*0.001)
        end

    end
    
    if not IsRecalling(myHero) and AlistarMenu.Misc.Eme:Value() and AlistarMenu.Misc.mpEme:Value() <= GetPercentMP(myHero) and GetMaxHP(myHero)-GetCurrentHP(myHero) > 30+30*GetCastLevel(myHero,_E)+0.2*GetBonusAP(myHero) and GetPercentHP(myHero) <= AlistarMenu.Misc.hpEme:Value() then
    CastSpell(_E)
    end
	
    if not IsRecalling(myHero) and AlistarMenu.Misc.Eally:Value() and AlistarMenu.Misc.mpEally:Value() <= GetPercentMP(myHero) then
      for k,v in pairs(GetAllyHeroes()) do
        if v ~= nil and not IsRecalling(v) and IsObjectAlive(v) and GetDistance(v) <= 575 and GetMaxHP(v)- GetHP(v) < 15+15*GetCastLevel(myHero,_E)+0.1*GetBonusAP(myHero) and GetPercentHP(v) <= AlistarMenu.Misc.hpEally:Value() then
        CastSpell(_E)
        end
      end
    end
    
    for i,enemy in pairs(GetEnemyHeroes()) do
		
      if Ignite and AlistarMenu.Misc.Autoignite:Value() then
        if IsReady(Ignite) and 20*GetLevel(myHero)+50 > GetHP(enemy)+GetHPRegen(enemy)*3 and ValidTarget(enemy, 600) then
        CastTargetSpell(enemy, Ignite)
        end
      end
		
      if IsReady(_Q) and ValidTarget(enemy, 365) and AlistarMenu.Killsteal.Q:Value() and GetHP2(enemy) < getdmg("Q",enemy) then 
      CastSpell(_Q)
      elseif IsReady(_W) and ValidTarget(enemy, 650) and AlistarMenu.Killsteal.W:Value() and GetHP2(enemy) < getdmg("W",enemy) then
      CastTargetSpell(enemy, _W)
      elseif IsReady(_W) and IsReady(_Q) and GetCurrentMana(myHero) >= GetCastMana(myHero,_Q,GetCastLevel(myHero,_Q)) + GetCastMana(myHero,_W,GetCastLevel(myHero,_W)) and ValidTarget(enemy, 650) and AlistarMenu.Killsteal.WQ:Value() and GetHP2(enemy) < getdmg("Q",enemy)+getdmg("W",enemy) then
      CastTargetSpell(enemy, _W)
      DelayAction(function() CastSpell(_Q) end, (math.max(0 , GetDistance(enemy) - 500 ) * 0.4 + 25))*0.001)
      end
		
    end

end)

AddGapcloseEvent(_Q, 365, false, AlistarMenu)
AddGapcloseEvent(_W, 650, true, AlistarMenu)

PrintChat(string.format("<font color='#1244EA'>Alistar:</font> <font color='#FFFFFF'> By Deftsu Loaded, Have A Good Game ! </font>"))
PrintChat("Have Fun Using D3Carry Scripts: " ..GetObjectBaseName(myHero)) 
