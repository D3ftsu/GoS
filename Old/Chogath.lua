if GetObjectName(GetMyHero()) ~= "Chogath" then return end

require('Inspired')
require('DeftLib')
require('DamageLib')

local ChogathMenu = MenuConfig("Chogath", "Chogath")
ChogathMenu:Menu("Combo", "Combo")
ChogathMenu.Combo:Boolean("Q", "Use Q", true)
ChogathMenu.Combo:Boolean("W", "Use W", true)
ChogathMenu.Combo:Boolean("R", "Use R", true)

ChogathMenu:Menu("Harass", "Harass")
ChogathMenu.Harass:Boolean("Q", "Use Q", true)
ChogathMenu.Harass:Boolean("W", "Use W", true)
ChogathMenu.Harass:Slider("Mana", "if Mana % >", 30, 0, 80, 1)

ChogathMenu:Menu("Killsteal", "Killsteal")
ChogathMenu.Killsteal:Boolean("Q", "Killsteal with Q", true)
ChogathMenu.Killsteal:Boolean("W", "Killsteal with W", true)
ChogathMenu.Killsteal:Boolean("R", "Killsteal with R", true)

if Ignite ~= nil then
ChogathMenu:Menu("Misc", "Misc")
ChogathMenu.Misc:Boolean("AutoIgnite", "Auto Ignite", true) 
end

ChogathMenu:Menu("LaneClear", "LaneClear")
ChogathMenu.LaneClear:Boolean("Q", "Use Q", true)
ChogathMenu.LaneClear:Boolean("W", "Use W", false)
ChogathMenu.LaneClear:Slider("Mana", "if Mana % >", 30, 0, 80, 1)

ChogathMenu:Menu("JungleClear", "JungleClear")
ChogathMenu.JungleClear:Boolean("Q", "Use Q", true)
ChogathMenu.JungleClear:Boolean("W", "Use W", true)
ChogathMenu.JungleClear:Boolean("R", "Use R", true)
ChogathMenu.JungleClear:Slider("Mana", "if Mana % >", 30, 0, 80, 1)

ChogathMenu:Menu("Drawings", "Drawings")
ChogathMenu.Drawings:Boolean("Q", "Draw Q Range", true)
ChogathMenu.Drawings:Boolean("W", "Draw W Range", true)
ChogathMenu.Drawings:Boolean("R", "Draw R Range", true)

ChogathMenu:Menu("Interrupt", "Interrupt")
ChogathMenu.Interrupt:Menu("SupportedSpells", "Supported Spells")
ChogathMenu.Interrupt.SupportedSpells:Boolean("Q", "Use Q", true)
ChogathMenu.Interrupt.SupportedSpells:Boolean("W", "Use W", true)

DelayAction(function()
  local str = {[_Q] = "Q", [_W] = "W", [_E] = "E", [_R] = "R"}
  for i, spell in pairs(CHANELLING_SPELLS) do
    for _,k in pairs(GetEnemyHeroes()) do
        if spell["Name"] == GetObjectName(k) then
        ChogathMenu.Interrupt:Boolean(GetObjectName(k).."Inter", "On "..GetObjectName(k).." "..(type(spell.Spellslot) == 'number' and str[spell.Spellslot]), true)
        end
    end
  end
end, 1)

OnProcessSpell(function(unit, spell)
    if GetObjectType(unit) == Obj_AI_Hero and GetTeam(unit) ~= GetTeam(myHero) then
      if CHANELLING_SPELLS[spell.name] then
        if ValidTarget(unit, 950) and IsReady(_Q) and GetObjectName(unit) == CHANELLING_SPELLS[spell.name].Name and ChogathMenu.Interrupt[GetObjectName(unit).."Inter"]:Value() and ChogathMenu.Interrupt.SupportedSpells.Q:Value() then
        Cast(_Q,unit)
        elseif ValidTarget(unit, 650) and IsReady(_W) and GetObjectName(unit) == CHANELLING_SPELLS[spell.name].Name and ChogathMenu.Interrupt[GetObjectName(unit).."Inter"]:Value() and ChogathMenu.Interrupt.SupportedSpells.W:Value() then
        Cast(_W,unit)
        end
      end
    end
end)

local target1 = TargetSelector(1075,TARGET_LESS_CAST_PRIORITY,DAMAGE_MAGIC,true,false)
local target2 = TargetSelector(650,TARGET_LESS_CAST_PRIORITY,DAMAGE_MAGIC,true,false)
  
OnDraw(function(myHero)
local pos = GetOrigin(myHero)
if ChogathMenu.Drawings.Q:Value() then DrawCircle(pos,950,1,25,GoS.Pink) end
if ChogathMenu.Drawings.W:Value() then DrawCircle(pos,650,1,25,GoS.Yellow) end
if ChogathMenu.Drawings.R:Value() then DrawCircle(pos,235,1,25,GoS.Green) end
end)

OnTick(function(myHero)
    local target = GetCurrentTarget()
    local Qtarget = target1:GetTarget()
    local Wtarget = target2:GetTarget()
    
    if IOW:Mode() == "Combo" then

        if IsReady(_Q) and ChogathMenu.Combo.Q:Value() then
        Cast(_Q,Qtarget)
        end
	       
	if IsReady(_W) and ChogathMenu.Combo.W:Value() then
        Cast(_W,Wtarget)
        end
        
        if IsReady(_R) and ValidTarget(target,235) and ChogathMenu.Combo.R:Value() and GetHP2(target) < getdmg("R", target) then
        CastTargetSpell(target, _R)
        end
        
    end
	
    if IOW:Mode() == "Harass" and GetPercentMP(myHero) >= ChogathMenu.Harass.Mana:Value() then

        if IsReady(_Q) and ChogathMenu.Harass.Q:Value() then
        Cast(_Q,Qtarget)
        end
	       
	if IsReady(_W) and ChogathMenu.Harass.W:Value() then
        Cast(_W,Wtarget)
        end
        
    end
	
  for i,enemy in pairs(GetEnemyHeroes()) do
    	
	if Ignite and ChogathMenu.Misc.AutoIgnite:Value() then
          if IsReady(Ignite) and 20*GetLevel(myHero)+50 > GetHP(enemy)+GetHPRegen(enemy)*3 and ValidTarget(enemy, 600) then
          CastTargetSpell(enemy, Ignite)
          end
        end
                
	if IsReady(_R) and ValidTarget(enemy, 235) and ChogathMenu.Killsteal.R:Value() and GetHP2(enemy) < getdmg("R",enemy) then
	CastTargetSpell(enemy, _R)
	elseif IsReady(_W) and ValidTarget(enemy, 650) and ChogathMenu.Killsteal.W:Value() and GetHP2(enemy) < getdmg("W",enemy) then 
	Cast(_W,enemy)
	elseif IsReady(_Q) and ValidTarget(enemy, 950) and ChogathMenu.Killsteal.Q:Value() and GetHP2(enemy) < getdmg("Q",enemy) then
	Cast(_Q,enemy)
        end

    end
     
    if IOW:Mode() == "LaneClear" then
        if GetPercentMP(myHero) >= ChogathMenu.LaneClear.Mana:Value() then
       	
         if IsReady(_Q) and ChogathMenu.LaneClear.Q:Value() then
           local BestPos, BestHit = GetFarmPosition(950, 250, MINION_ENEMY)
           if BestPos and BestHit > 0 then 
           CastSkillShot(_Q, BestPos)
           end
	 end

         if IsReady(_W) and ChogathMenu.LaneClear.W:Value() then
           local BestPos, BestHit = GetLineFarmPosition(650, 210, MINION_ENEMY)
           if BestPos and BestHit > 0 then 
           CastSkillShot(_W, BestPos)
           end
	 end
        
        end
    end
         
    for i,mobs in pairs(minionManager.objects) do
        if IOW:Mode() == "LaneClear" and GetTeam(mobs) == 300 and GetPercentMP(myHero) >= ChogathMenu.JungleClear.Mana:Value() then
          if IsReady(_Q) and ChogathMenu.JungleClear.Q:Value() and ValidTarget(mobs, 950) then
          CastSkillShot(_Q,GetOrigin(mobs))
	  end
		
	  if IsReady(_W) and ChogathMenu.JungleClear.W:Value() and ValidTarget(mobs, 650) then
	  CastSpell(_W)
	  end
		
	  if IsReady(_R) and ChogathMenu.JungleClear.R:Value() and ValidTarget(mobs, 235) and GetCurrentHP(mobs) < getdmg("R",mobs) then
	  CastTargetSpell(mobs, _R)
          end
        end
    end       

end)
 
AddGapcloseEvent(_Q, 200, false, ChogathMenu)

PrintChat(string.format("<font color='#1244EA'>Chogath:</font> <font color='#FFFFFF'> By Deftsu Loaded, Have A Good Game ! </font>"))
PrintChat("Have Fun Using D3Carry Scripts: " ..GetObjectBaseName(myHero)) 
