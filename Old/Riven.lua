if GetObjectName(GetMyHero()) ~= "Riven" then return end

require('MapPositionGOS')
require('Inspired')
require('DeftLib')
require('DamageLib')

local RivenMenu = MenuConfig("Riven", "Riven")
RivenMenu:Menu("Combo", "Combo")
RivenMenu.Combo:Boolean("Q", "Use Q", true)
RivenMenu.Combo:Boolean("W", "Use W", true)
RivenMenu.Combo:Boolean("E", "Use E", true)
RivenMenu.Combo:Boolean("H", "Use Hydra", true)

RivenMenu:Menu("Harass", "Harass")
RivenMenu.Harass:Boolean("Q", "Use Q", true)
RivenMenu.Harass:Boolean("W", "Use W", true)
RivenMenu.Harass:Boolean("E", "Use E", true)
RivenMenu.Harass:Boolean("H", "Use Hydra", true)

RivenMenu:Menu("Killsteal", "Killsteal")
RivenMenu.Killsteal:Boolean("W", "Killsteal with W", true)
RivenMenu.Killsteal:Boolean("R", "Killsteal with R", true)

RivenMenu:Menu("Misc", "Misc")
if Ignite ~= nil then RivenMenu.Misc:Boolean("Autoignite", "Auto Ignite", true) end
RivenMenu.Misc:DropDown("cancel", "Cancel Animation", 1, {"Dance", "Taunt", "Laugh", "Joke", "Off"})
RivenMenu.Misc:KeyBinding("Flee", "Flee", string.byte("T"))
RivenMenu.Misc:KeyBinding("WallJump", "WallJump", string.byte("G"))
RivenMenu.Misc:Boolean("AutoW", "Auto W", true)
RivenMenu.Misc:Slider("AutoWCount", "if Enemies Around >", 3, 1, 5, 1)

RivenMenu:Menu("Drawings", "Drawings")
RivenMenu.Drawings:Boolean("Q", "Draw Q Range", true)
RivenMenu.Drawings:Boolean("W", "Draw W Range", true)
RivenMenu.Drawings:Boolean("E", "Draw E Range", true)
RivenMenu.Drawings:Boolean("R", "Draw R Range", true)
RivenMenu.Drawings:Boolean("EQ", "Draw EQ Range", true)

RivenMenu:Menu("Interrupt", "Interrupt (W)")

DelayAction(function()
  local str = {[_Q] = "Q", [_W] = "W", [_E] = "E", [_R] = "R"}
  for i, spell in pairs(CHANELLING_SPELLS) do
    for _,k in pairs(GetEnemyHeroes()) do
      if spell["Name"] == GetObjectName(k) then
      RivenMenu.Interrupt:Boolean(GetObjectName(k).."Inter", "On "..GetObjectName(k).." "..(type(spell.Spellslot) == 'number' and str[spell.Spellslot]), true)
      end
    end
  end
end, 0.001)

local QCast = 0
local lastE = 0

OnDraw(function(myHero)
local pos = GetOrigin(myHero)
if RivenMenu.Drawings.Q:Value() then DrawCircle(pos,275,1,25,GoS.Pink) end
if RivenMenu.Drawings.W:Value() then DrawCircle(pos,260,1,25,GoS.Yellow) end
if RivenMenu.Drawings.E:Value() then DrawCircle(pos,250,1,50,GoS.Blue) end
if RivenMenu.Drawings.R:Value() then DrawCircle(pos,1100,1,0,GoS.Green) end
if RivenMenu.Drawings.EQ:Value() then DrawCircle(pos,525,1,0,GoS.Red) end
end)

OnTick(function(myHero)
        mousePos = GetMousePos()
	local target = GetCurrentTarget()
	
	if IOW:Mode() == "Combo" then
	  if IsReady(_E) and RivenMenu.Combo.E:Value() and ValidTarget(target, 440) and GetDistance(target) > GetRange(myHero)+GetHitBox(myHero) then
	  CastSkillShot(_E, GetOrigin(target))
	  end
	  
	  if IsReady(_Q) and IsReady(_E) and RivenMenu.Combo.Q:Value() and RivenMenu.Combo.E:Value() and ValidTarget(target, 715) and GetDistance(target) > GetRange(myHero)+GetHitBox(target) then
	  CastSkillShot(_E, GetOrigin(target))
	  DelayAction(function() CastSkillShot(_Q, GetOrigin(target)) end, 0.267)
	  end
	end
	
	if IOW:Mode() == "Harass" then
	  if IsReady(_E) and RivenMenu.Harass.E:Value() and ValidTarget(target, 440) and GetDistance(target) > GetRange(myHero)+GetHitBox(myHero) then
	  CastSkillShot(_E, GetOrigin(target))
	  end
	  
	  if IsReady(_Q) and IsReady(_E) and RivenMenu.Harass.Q:Value() and RivenMenu.Harass.E:Value() and ValidTarget(target, 715) and GetDistance(target) > GetRange(myHero)+GetHitBox(myHero)*3 then
	  CastSkillShot(_E, GetOrigin(target))
	  DelayAction(function() CastSkillShot(_Q, GetOrigin(target)) end, 0.267)
	  end
	end

	if IsReady(_W) and RivenMenu.Misc.AutoW:Value() and EnemiesAround2(GetOrigin(myHero),260,267) >= RivenMenu.Misc.AutoWCount:Value() then
	CastSpell(_W)
	end
	
	if RivenMenu.Misc.Flee:Value() then
          MoveToXYZ(mousePos)
          if IsReady(_E) then
          CastSkillShot(_E, mousePos)
          end
          if not IsReady(_E) and IsReady(_Q) and lastE + 350 < GetTickCount() then
          CastSkillShot(_Q, mousePos)
          end
        end
	
	if RivenMenu.Misc.WallJump:Value() then
          local movePos1  = GetOrigin(myHero) + (Vector(mousePos) - GetOrigin(myHero)):normalized() * 75
          local movePos2 =  GetOrigin(myHero) + (Vector(mousePos) - GetOrigin(myHero)):normalized() * 450
          if QCast < 2 and CanUseSpell(myHero, _Q) ~= ONCOOLDOWN then
          CastSkillShot(_Q, mousePos)
          end
          if not MapPosition:inWall(movePos1) then
            MoveToXYZ(mousePos)
          else
            if not MapPosition:inWall(movePos2) and CanUseSpell(myHero, _Q) ~= ONCOOLDOWN then
            CastSkillShot(_Q, movePos2)
            end
          end
	end
	
	for i,enemy in pairs(GetEnemyHeroes()) do
    	
	  if Ignite and RivenMenu.Misc.Autoignite:Value() then
            if IsReady(Ignite) and 20*GetLevel(myHero)+50 > GetHP(enemy)+GetHPRegen(enemy)*3 and ValidTarget(enemy, 600) then
            CastTargetSpell(enemy, Ignite)
            end
          end
                
  	  if IsReady(_W) and ValidTarget(enemy, 260) and RivenMenu.Killsteal.W:Value() and GetHP(enemy) < getdmg("W",enemy) then
  	  CastSpell(_W)
	  elseif IsReady(_R) and GetCastName(myHero, _R) ~= "RivenFengShuiEngine" and ValidTarget(enemy, 1100) and RivenMenu.Killsteal.R:Value() and GetHP(enemy) < getdmg("R",enemy) then
	  Cast(_R,enemy)
          end

        end
	
end)

OnProcessSpell(function(unit,spell)
  if GetObjectType(unit) == Obj_AI_Hero and GetTeam(unit) ~= GetTeam(myHero) and IsReady(_W) then
    if CHANELLING_SPELLS[spell.name] then
      if ValidTarget(unit, 260) and GetObjectName(unit) == CHANELLING_SPELLS[spell.name].Name and RivenMenu.Interrupt[GetObjectName(unit).."Inter"]:Value() then 
      CastSpell(_W)
      end
    end
  end
  
  if unit == myHero then
  
    if spell.name == "RivenFeint" then
    lastE = GetTickCount()
    end
	
    local target = IOW:GetTarget()
	
    if spell.name:lower():find("attack") then
    DelayAction(function()
    	
      if IOW:Mode() == "Combo" and ValidTarget(target) then
      	if IsReady(_W) and RivenMenu.Combo.W:Value() then
	CastSpell(_W)
        elseif GetItemSlot(myHero, 3074) > 0 and IsReady(GetItemSlot(myHero, 3074)) and RivenMenu.Combo.H:Value() then
	CastSpell(GetItemSlot(myHero, 3074))
	elseif GetItemSlot(myHero, 3077) > 0 and IsReady(GetItemSlot(myHero, 3077)) and RivenMenu.Combo.H:Value() then
	CastSpell(GetItemSlot(myHero, 3077))
	elseif IsReady(_Q) and RivenMenu.Combo.Q:Value() then
	CastSkillShot(_Q, GetOrigin(target))
	end
      end
	   
      if IOW:Mode() == "Harass" and ValidTarget(target) then
      	if IsReady(_W) and RivenMenu.Harass.W:Value() then
	CastSpell(_W)
        elseif GetItemSlot(myHero, 3074) > 0 and IsReady(GetItemSlot(myHero, 3074)) and RivenMenu.Harass.H:Value() then
	CastSpell(GetItemSlot(myHero, 3074))
	elseif GetItemSlot(myHero, 3077) > 0 and IsReady(GetItemSlot(myHero, 3077)) and RivenMenu.Harass.H:Value() then
	CastSpell(GetItemSlot(myHero, 3077))
	elseif IsReady(_Q) and RivenMenu.Harass.Q:Value() then
	CastSkillShot(_Q, GetOrigin(target)) 
	end
      end

    end, GetWindUp(myHero) )
    end
	
    if spell.name == "RivenMartyr" then
    DelayAction(function()
      if IOW:Mode() == "Combo" and ValidTarget(target) then
        if IsReady(_Q) and RivenMenu.Combo.Q:Value() then
	CastSkillShot(_Q, GetOrigin(target)) 
	end
      end
	  
      if IOW:Mode() == "Harass" and ValidTarget(target) then
        if IsReady(_Q) and RivenMenu.Harass.Q:Value() then
	CastSkillShot(_Q, GetOrigin(target)) 
	end
      end

    end, spell.windUpTime )
    end
	
    if spell.name == "RivenTriCleave" then
    IOW:ResetAA()
    end
	
    if spell.name == "ItemTiamatCleave" then
    IOW:ResetAA()
    DelayAction(function()
      if IOW:Mode() == "Combo" and ValidTarget(target) then
        if IsReady(_Q) and RivenMenu.Combo.Q:Value() then
	CastSkillShot(_Q, GetOrigin(target)) 
	end
      end
	  
      if IOW:Mode() == "Harass" and ValidTarget(target) then
        if IsReady(_Q) and RivenMenu.Harass.Q:Value() then
	CastSkillShot(_Q, GetOrigin(target)) 
	end
      end
    end, spell.windUpTime )
    end
	
    if spell.name == "RivenFengShuiEngine" then
    IOW:ResetAA()
    DelayAction(function()
	  if IOW:Mode() == "Combo" and ValidTarget(target) then
	    if IsReady(_Q) and RivenMenu.Combo.Q:Value() then
	    CastSkillShot(_Q, GetOrigin(target)) 
	    end
	  end
	  
	  if IOW:Mode() == "Harass" and ValidTarget(target) then
	    if IsReady(_Q) and RivenMenu.Harass.Q:Value() then
	    CastSkillShot(_Q, GetOrigin(target)) 
	    end
	  end
    end, spell.windUpTime )
    end
	
    if spell.name == "rivenizunablade" then
    IOW:ResetAA()
    DelayAction(function()
      if IOW:Mode() == "Combo" and ValidTarget(target) then
        if IsReady(_Q) and RivenMenu.Combo.Q:Value() then
        CastSkillShot(_Q, GetOrigin(target)) 
        end
      end
	  
      if IOW:Mode() == "Harass" and ValidTarget(target) then
        if IsReady(_Q) and RivenMenu.Harass.Q:Value() then
        CastSkillShot(_Q, GetOrigin(target)) 
	end
      end
    end, spell.windUpTime )
    end
	
  end 
end)

OnProcessSpellComplete(function(unit,spell)
  if unit == myHero and spell.name == "RivenTriCleave" then 
    local Emotes = {EMOTE_DANCE, EMOTE_TAUNT, EMOTE_LAUGH, EMOTE_JOKE}
    if RivenMenu.Misc.cancel:Value() ~= 5 then
    CastEmote(Emotes[RivenMenu.Misc.cancel:Value()])
    end
  end
end)

OnUpdateBuff(function(unit,buff)
  if unit == myHero and buff.Name == "RivenTriCleave" then
  QCast = buff.Count
  end
end)

OnRemoveBuff(function(unit,buff)
  if unit == myHero and buff.Name == "RivenTriCleave" then
  QCast = 0
  end
end)

AddGapcloseEvent(_W, 260, false, RivenMenu)

PrintChat(string.format("<font color='#1244EA'>Riven:</font> <font color='#FFFFFF'> By Deftsu Loaded, Have A Good Game ! </font>")) 
PrintChat("Have Fun Using D3Carry Scripts: " ..GetObjectBaseName(myHero)) 
