if GetObjectName(GetMyHero()) ~= "Blitzcrank" then return end

require('Inspired')
require('DeftLib')
require('DamageLib')

local BlitzcrankMenu = MenuConfig("Blitzcrank", "Blitzcrank")
BlitzcrankMenu:Menu("Combo", "Combo")
BlitzcrankMenu.Combo:Boolean("Q", "Use Q", true)
BlitzcrankMenu.Combo:Boolean("W", "Use W", true)
BlitzcrankMenu.Combo:Boolean("E", "Use E", true)
BlitzcrankMenu.Combo:Boolean("AutoE", "Auto E after Grab", true)
BlitzcrankMenu.Combo:Boolean("R", "Use R", true)

BlitzcrankMenu:Menu("AutoGrab", "Auto Grab")
BlitzcrankMenu.AutoGrab:Slider("min", "Min Distance", 200, 100, 400, 1)
BlitzcrankMenu.AutoGrab:Slider("max", "Max Distance", 975, 400, 975, 1)
BlitzcrankMenu.AutoGrab:Menu("Enemies", "Enemies to Auto-Grab")

BlitzcrankMenu:Menu("Harass", "Harass")
BlitzcrankMenu.Harass:Boolean("Q", "Use Q", true)
BlitzcrankMenu.Harass:Boolean("E", "Use E", true)
BlitzcrankMenu.Harass:Slider("Mana", "if Mana % is More than", 30, 0, 80, 1)

BlitzcrankMenu:Menu("Killsteal", "Killsteal")
BlitzcrankMenu.Killsteal:Boolean("Q", "Killsteal with Q", true)
BlitzcrankMenu.Killsteal:Boolean("R", "Killsteal with R", true)

if Ignite ~= nil then 
BlitzcrankMenu:Menu("Misc", "Misc")
BlitzcrankMenu.Misc:Boolean("Autoignite", "Auto Ignite", true) 
end

BlitzcrankMenu:Menu("Drawings", "Drawings")
BlitzcrankMenu.Drawings:Boolean("Q", "Draw Q Range", true)
BlitzcrankMenu.Drawings:Boolean("R", "Draw R Range", true)
BlitzcrankMenu.Drawings:Boolean("Stats", "Draw Statistics", true)
	
BlitzcrankMenu:Menu("Interrupt", "Interrupt")
BlitzcrankMenu.Interrupt:Menu("SupportedSpells", "Supported Spells")
BlitzcrankMenu.Interrupt.SupportedSpells:Boolean("Q", "Use Q", true)
BlitzcrankMenu.Interrupt.SupportedSpells:Boolean("R", "Use R", true)

local MissedGrabs = 0
local SuccesfulGrabs = 0
local TotalGrabs = MissedGrabs + SuccesfulGrabs
local Percentage = ((SuccesfulGrabs*100)/TotalGrabs)

DelayAction(function()
  local str = {[_Q] = "Q", [_W] = "W", [_E] = "E", [_R] = "R"}
  for i, spell in pairs(CHANELLING_SPELLS) do
    for _,k in pairs(GetEnemyHeroes()) do
        if spell["Name"] == GetObjectName(k) then
        BlitzcrankMenu.Interrupt:Boolean(GetObjectName(k).."Inter", "On "..GetObjectName(k).." "..(type(spell.Spellslot) == 'number' and str[spell.Spellslot]), true)
        end
    end
  end
  for _,k in pairs(GetEnemyHeroes()) do
  BlitzcrankMenu.AutoGrab.Enemies:Boolean(GetObjectName(k).."AutoGrab", "On "..GetObjectName(k).." ", false)
  end
end, 1)

OnProcessSpell(function(unit, spell)
    if GetObjectType(unit) == Obj_AI_Hero and GetTeam(unit) ~= GetTeam(myHero) then
      if CHANELLING_SPELLS[spell.name] then
        if ValidTarget(unit, 975) and IsReady(_Q) and GetObjectName(unit) == CHANELLING_SPELLS[spell.name].Name and BlitzcrankMenu.Interrupt[GetObjectName(unit).."Inter"]:Value() and BlitzcrankMenu.Interrupt.SupportedSpells.Q:Value() then
        Cast(_Q,unit)
        elseif ValidTarget(unit, 600) and IsReady(_R) and GetObjectName(unit) == CHANELLING_SPELLS[spell.name].Name and BlitzcrankMenu.Interrupt[GetObjectName(unit).."Inter"]:Value() and BlitzcrankMenu.Interrupt.SupportedSpells.R:Value() then
        CastSpell(_R)
        end
      end
    end
	
    if unit == myHero and spell.name == "RocketGrab" then
    MissedGrabs = MissedGrabs + 1
    end
end)

OnDraw(function(myHero)
local pos = GetOrigin(myHero)
TotalGrabs = MissedGrabs + SuccesfulGrabs
Percentage = ((SuccesfulGrabs*100)/TotalGrabs)
if BlitzcrankMenu.Drawings.Q:Value() then DrawCircle(pos,975,1,25,GoS.Pink) end
if BlitzcrankMenu.Drawings.R:Value() then DrawCircle(pos,600,1,25,GoS.Green) end
if BlitzcrankMenu.Drawings.Stats:Value() then 
DrawText("Percentage Grab done : " .. tostring(math.ceil(Percentage)) .. "%",12,0,30,0xff00ff00)
DrawText("Grab Done : "..tostring(SuccesfulGrabs),12,0,40,0xff00ff00)
DrawText("Grab Miss : "..tostring(MissedGrabs),12,0,50,0xff00ff00)
DrawText("Total Grabs : "..tostring(TotalGrabs),12,0,60,0xff00ff00)
end

end)

local target1 = TargetSelector(1010,TARGET_LESS_CAST_PRIORITY,DAMAGE_MAGIC,true,false)

OnTick(function(myHero)
    local target = GetCurrentTarget()
    local Qtarget = target1:GetTarget()
    
       if IOW:Mode() == "Combo" then
	
                if IsReady(_Q) and BlitzcrankMenu.Combo.Q:Value() then
                Cast(_Q,Qtarget)
	        end
                
                if IsReady(_W) and ValidTarget(target, 1275) and BlitzcrankMenu.Combo.W:Value() then  
                  if GetCurrentMana(myHero) >= 200 and IsReady(_Q) and GetDistance(target) >= 975 then
                  CastSpell(_W)
                  elseif GetDistance(target) <= 400 then
		  CastSpell(_W)
		  end
		end
		
                if IsReady(_E) and IsInDistance(target, 250) and BlitzcrankMenu.Combo.E:Value() then
                CastSpell(_E)
		end
		              
		if IsReady(_R) and ValidTarget(target, 600) and BlitzcrankMenu.Combo.R:Value() and GetPercentHP(target) < 60 then
                CastSpell(_R)
	        end
	                      
	end	
	
	if IOW:Mode() == "Harass" and GetPercentMP(myHero) >= BlitzcrankMenu.Harass.Mana:Value() then
	
                if IsReady(_Q) and BlitzcrankMenu.Harass.Q:Value() then
                Cast(_Q,Qtarget)
	        end
		
		if IsReady(_E) and IsInDistance(target, 250) and BlitzcrankMenu.Harass.E:Value() then
                CastSpell(_E)
		end
		
	end
	
	for i,enemy in pairs(GetEnemyHeroes()) do
		
		if BlitzcrankMenu.AutoGrab.Enemies[GetObjectName(enemy).."AutoGrab"]:Value() and ValidTarget(enemy) then
		  if IsReady(_Q) and GetDistance(enemy) <= BlitzcrankMenu.AutoGrab.max:Value() and GetDistance(enemy) >= BlitzcrankMenu.AutoGrab.min:Value() then
		  Cast(_Q,enemy)
		  end
		end
		
		if Ignite and BlitzcrankMenu.Misc.Autoignite:Value() then
                  if IsReady(Ignite) and 20*GetLevel(myHero)+50 > GetHP(enemy)+GetHPRegen(enemy)*3 and ValidTarget(enemy, 600) then
                  CastTargetSpell(enemy, Ignite)
                  end
                end
		
  	        if IsReady(_Q) and ValidTarget(enemy, 1010) and BlitzcrankMenu.Killsteal.Q:Value() and GetHP2(enemy) < getdmg("Q",enemy) then 
                Cast(_Q,enemy)
                elseif IsReady(_R) and ValidTarget(enemy, 600) and BlitzcrankMenu.Killsteal.R:Value() and GetHP2(enemy) < getdmg("R",enemy) then
                CastSpell(_R)
	        end
		
	end

end)

OnUpdateBuff(function(unit,buff)
  if buff.Name == "rocketgrab2" and GetObjectType(unit) == Obj_AI_Hero and GetTeam(unit) ~= GetTeam(myHero) then
    SuccesfulGrabs = SuccesfulGrabs + 1
    MissedGrabs = MissedGrabs - 1
		
    if BlitzcrankMenu.Combo.AutoE:Value() then
    CastSpell(_E)
    end
  end
end)

PrintChat(string.format("<font color='#1244EA'>Blitzcrank:</font> <font color='#FFFFFF'> By Deftsu Loaded, Have A Good Game ! </font>"))
PrintChat("Have Fun Using D3Carry Scripts: " ..GetObjectBaseName(myHero)) 
