if GetObjectName(GetMyHero()) ~= "Ahri" then return end

require('Inspired')
require('DeftLib')
require('DamageLib')

local AhriMenu = MenuConfig("Ahri", "Ahri")
AhriMenu:Menu("Combo", "Combo")
AhriMenu.Combo:Boolean("Q", "Use Q", true)
AhriMenu.Combo:Boolean("W", "Use W", true)
AhriMenu.Combo:Boolean("E", "Use E", true)
AhriMenu.Combo:Boolean("R", "Use R", true)
AhriMenu.Combo:DropDown("RMode", "R Mode", 1, {"Logic", "to mouse"})

AhriMenu:Menu("Harass", "Harass")
AhriMenu.Harass:Boolean("Q", "Use Q", true)
AhriMenu.Harass:Boolean("W", "Use W", true)
AhriMenu.Harass:Boolean("E", "Use E", true)
AhriMenu.Harass:Slider("Mana", "if Mana % >", 30, 0, 80, 1)

AhriMenu:Menu("Killsteal", "Killsteal")
AhriMenu.Killsteal:Boolean("Q", "Killsteal with Q", true)
AhriMenu.Killsteal:Boolean("W", "Killsteal with W", true)
AhriMenu.Killsteal:Boolean("E", "Killsteal with E", true)

if Ignite ~= nil then 
AhriMenu:Menu("Misc", "Misc")
AhriMenu.Misc:Boolean("Autoignite", "Auto Ignite", true) 
end

AhriMenu:Menu("Lasthit", "Lasthit")
AhriMenu.Lasthit:Boolean("Q", "Use Q", true)
AhriMenu.Lasthit:Slider("Mana", "if Mana % >", 50, 0, 80, 1)

AhriMenu:Menu("LaneClear", "LaneClear")
AhriMenu.LaneClear:Boolean("Q", "Use Q", true)
AhriMenu.LaneClear:Boolean("W", "Use W", false)
AhriMenu.LaneClear:Boolean("E", "Use E", false)
AhriMenu.LaneClear:Slider("Mana", "if Mana % >", 30, 0, 80, 1)

AhriMenu:Menu("JungleClear", "JungleClear")
AhriMenu.JungleClear:Boolean("Q", "Use Q", true)
AhriMenu.JungleClear:Boolean("W", "Use W", true)
AhriMenu.JungleClear:Boolean("E", "Use E", true)
AhriMenu.JungleClear:Slider("Mana", "if Mana % >", 30, 0, 80, 1)

AhriMenu:Menu("Drawings", "Drawings")
AhriMenu.Drawings:Boolean("Orb", "Draw Orb (Q)", true)
AhriMenu.Drawings:Boolean("Q", "Draw Q Range", true)
AhriMenu.Drawings:Boolean("W", "Draw W Range", true)
AhriMenu.Drawings:Boolean("E", "Draw E Range", true)
AhriMenu.Drawings:Boolean("R", "Draw R Range", true)

AhriMenu:Menu("Interrupt", "Interrupt (E)")

DelayAction(function()
  local str = {[_Q] = "Q", [_W] = "W", [_E] = "E", [_R] = "R"}
  for i, spell in pairs(CHANELLING_SPELLS) do
    for _,k in pairs(GetEnemyHeroes()) do
        if spell["Name"] == GetObjectName(k) then
        AhriMenu.Interrupt:Boolean(GetObjectName(k).."Inter", "On "..GetObjectName(k).." "..(type(spell.Spellslot) == 'number' and str[spell.Spellslot]), true)
        end
    end
  end
end, 1)

OnProcessSpell(function(unit, spell)
    if GetObjectType(unit) == Obj_AI_Hero and GetTeam(unit) ~= GetTeam(myHero) and IsReady(_E) then
      if CHANELLING_SPELLS[spell.name] then
        if ValidTarget(unit, 1000) and GetObjectName(unit) == CHANELLING_SPELLS[spell.name].Name and AhriMenu.Interrupt[GetObjectName(unit).."Inter"]:Value() then 
        Cast(_E,unit)
        end
      end
    end
end)

local target1 = TargetSelector(930,TARGET_LESS_CAST_PRIORITY,DAMAGE_MAGIC,true,false)
local target2 = TargetSelector(1030,TARGET_LESS_CAST_PRIORITY,DAMAGE_MAGIC,true,false)
local target3 = TargetSelector(900,TARGET_LESS_CAST_PRIORITY,DAMAGE_MAGIC,true,false)
local UltOn = false
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
  
OnDraw(function(myHero)
local pos = GetOrigin(myHero)
if AhriMenu.Drawings.Orb:Value() then
  for _,Orb in pairs(Missiles) do
    if Orb ~= nil and GetObjectSpellOwner(Orb) == myHero and GetObjectSpellName(Orb) == "AhriOrbMissile" or GetObjectSpellName(Orb) == "AhriOrbReturn" then
    DrawRectangleOutline(pos, GetOrigin(Orb), 80)
    DrawCircle(GetOrigin(Orb),80,2,30,ARGB(255, 255, 0, 0)) 
    end
  end
end
if AhriMenu.Drawings.Q:Value() then DrawCircle(pos,880,1,25,GoS.Pink) end
if AhriMenu.Drawings.W:Value() then DrawCircle(pos,700,1,25,GoS.Yellow) end
if AhriMenu.Drawings.E:Value() then DrawCircle(pos,975,1,25,GoS.Blue) end
if AhriMenu.Drawings.R:Value() then DrawCircle(pos,550,1,25,GoS.Green) end
end)

OnTick(function(myHero)

    local target = GetCurrentTarget()
    local Qtarget = target1:GetTarget()
    local Etarget = target2:GetTarget()
    local Rtarget = target3:GetTarget()
    local mousePos = GetMousePos()
    
    if IOW:Mode() == "Combo" then

        if IsReady(_E) and AhriMenu.Combo.E:Value() then
        Cast(_E,Etarget)
        end
	
        if AhriMenu.Combo.RMode:Value() == 1 and AhriMenu.Combo.R:Value() and ValidTarget(Rtarget,900) then
          local BestPos = Vector(Rtarget) - (Vector(Rtarget) - Vector(myHero)):perpendicular():normalized() * 350
	  if UltOn and BestPos then
          CastSkillShot(_R,BestPos)
          elseif IsReady(_R) and BestPos and getdmg("Q",Rtarget)+getdmg("W",Rtarget,myHero,3)+getdmg("E",Rtarget)+getdmg("R",Rtarget) > GetHP2(Rtarget) then
	  CastSkillShot(_R,BestPos)
	  end
	end

        if AhriMenu.Combo.RMode:Value() == 2 and AhriMenu.Combo.R:Value() and ValidTarget(Rtarget,900)then
          local AfterTumblePos = GetOrigin(myHero) + (Vector(mousePos) - GetOrigin(myHero)):normalized() * 550
          local DistanceAfterTumble = GetDistance(AfterTumblePos, Rtarget)
   	  if UltOn and DistanceAfterTumble < 550 then
	  CastSkillShot(_R,mousePos)
          elseif IsReady(_R) and getdmg("Q",Rtarget)+getdmg("W",Rtarget,myHero,3)+getdmg("E",Rtarget)+getdmg("R",Rtarget) > GetHP2(Rtarget) then
	  CastSkillShot(_R,mousePos) 
          end
	end
			
	if IsReady(_W) and ValidTarget(target,700) and AhriMenu.Combo.W:Value() then
	CastSpell(_W)
	end
		
	if IsReady(_Q) and AhriMenu.Combo.Q:Value() then
        Cast(_Q,Qtarget)
        end
					
    end
	
    if IOW:Mode() == "Harass" and GetPercentMP(myHero) >= AhriMenu.Harass.Mana:Value() then

        if IsReady(_E) and AhriMenu.Harass.E:Value() then
        Cast(_E,target)
        end
				
        if IsReady(_W) and ValidTarget(target, 700) and AhriMenu.Harass.W:Value() then
	CastSpell(_W)
	end
		
	if IsReady(_Q) and AhriMenu.Harass.Q:Value() then
        Cast(_Q,target)
        end
		
    end
	
    for i,enemy in pairs(GetEnemyHeroes()) do
    	
	if Ignite and AhriMenu.Misc.Autoignite:Value() then
          if IsReady(Ignite) and 20*GetLevel(myHero)+50 > GetHP(enemy)+GetHPRegen(enemy)*3 and ValidTarget(enemy, 600) then
          CastTargetSpell(enemy, Ignite)
          end
        end
                
	if IsReady(_W) and ValidTarget(enemy, 930) and AhriMenu.Killsteal.W:Value() and GetHP2(enemy) < getdmg("W",enemy,myHero,3) then
	CastSpell(_W)
	elseif IsReady(_Q) and ValidTarget(enemy, 700) and AhriMenu.Killsteal.Q:Value() and GetHP2(enemy) < getdmg("Q",enemy) then 
	Cast(_Q,enemy)
	elseif IsReady(_E) and ValidTarget(enemy, 1030) and AhriMenu.Killsteal.E:Value() and GetHP2(enemy) < getdmg("E",enemy) then
	Cast(_E,enemy)
        end

    end
     
    if IOW:Mode() == "LaneClear" then
     	
        local closeminion = ClosestMinion(GetOrigin(myHero), MINION_ENEMY)
        if GetPercentMP(myHero) >= AhriMenu.LaneClear.Mana:Value() then
       	
         if IsReady(_Q) and AhriMenu.LaneClear.Q:Value() then
           local BestPos, BestHit = GetLineFarmPosition(880, 50, MINION_ENEMY)
           if BestPos and BestHit > 2 then 
           CastSkillShot(_Q, BestPos)
           end
	 end

         if IsReady(_W) and AhriMenu.LaneClear.W:Value() then
           if GetCurrentHP(closeminion) < getdmg("W",closeminion,myHero,3) and ValidTarget(closestminion, 700) then
           CastSpell(_W)
           end
         end

         if IsReady(_E) and AhriMenu.LaneClear.E:Value() then
           if GetCurrentHP(closeminion) < getdmg("E",closeminion) and ValidTarget(closestminion, 1000) then
           CastSkillShot(_E, GetOrigin(closeminion))
           end
         end
        
        end

    end
         
    for i,mobs in pairs(minionManager.objects) do
        if IOW:Mode() == "LaneClear" and GetTeam(mobs) == 300 and GetPercentMP(myHero) >= AhriMenu.JungleClear.Mana:Value() then
          if IsReady(_Q) and AhriMenu.JungleClear.Q:Value() and ValidTarget(mobs, 880) then
          CastSkillShot(_Q,GetOrigin(mobs))
	  end
		
	  if IsReady(_W) and AhriMenu.JungleClear.W:Value() and ValidTarget(mobs, 700) then
	  CastSpell(_W)
	  end
		
	  if IsReady(_E) and AhriMenu.JungleClear.E:Value() and ValidTarget(mobs, 1000) then
	  CastSkillShot(_E,GetOrigin(mobs))
          end
        end
     	
	if IOW:Mode() == "LastHit" and GetTeam(mobs) == MINION_ENEMY and GetPercentMP(myHero) >= AhriMenu.Lasthit.Mana:Value() then
	  if IsReady(_Q) and ValidTarget(mobs, 880) and AhriMenu.Lasthit.Q:Value() and GetCurrentHP(mobs)-GetDamagePrediction(mobs, 250+GetDistance(mobs)/2500) < getdmg("Q",mobs) and GetCurrentHP(mobs)-GetDamagePrediction(mobs, 250+GetDistance(mobs)/2500) > 0 then
          CastSkillShot(_Q, GetOrigin(mobs))
       	  end
        end
    end       

end)
 
OnUpdateBuff(function(unit,buff)
  if buff.Name == "ahritumble" then 
  UltOn = true
  end
end)

OnRemoveBuff(function(unit,buff)
  if buff.Name == "ahritumble" then 
  UltOn = false
  end
end)

function DrawRectangleOutline(startPos, endPos, width)
	local c1 = startPos+Vector(Vector(endPos)-startPos):perpendicular():normalized()*width/2
	local c2 = startPos+Vector(Vector(endPos)-startPos):perpendicular2():normalized()*width/2
	local c3 = endPos+Vector(Vector(startPos)-endPos):perpendicular():normalized()*width/2
	local c4 = endPos+Vector(Vector(startPos)-endPos):perpendicular2():normalized()*width/2
	DrawLine3D(c1.x,c1.y,c1.z,c2.x,c2.y,c2.z,math.ceil(width/100),ARGB(255, 255, 255, 255))
	DrawLine3D(c3.x,c3.y,c3.z,c4.x,c4.y,c4.z,math.ceil(width/100),ARGB(255, 255, 255, 255))
	local c1 = startPos+Vector(Vector(endPos)-startPos):perpendicular():normalized()*width
	local c2 = startPos+Vector(Vector(endPos)-startPos):perpendicular2():normalized()*width
	local c3 = endPos+Vector(Vector(startPos)-endPos):perpendicular():normalized()*width
	local c4 = endPos+Vector(Vector(startPos)-endPos):perpendicular2():normalized()*width
	DrawLine3D(c1.x,c1.y,c1.z,c2.x,c2.y,c2.z,math.ceil(width/100),ARGB(255, 255, 255, 255))
	DrawLine3D(c2.x,c2.y,c2.z,c3.x,c3.y,c3.z,math.ceil(width/100),ARGB(255, 255, 255, 255))
	DrawLine3D(c3.x,c3.y,c3.z,c4.x,c4.y,c4.z,math.ceil(width/100),ARGB(255, 255, 255, 255))
	DrawLine3D(c1.x,c1.y,c1.z,c4.x,c4.y,c4.z,math.ceil(width/100),ARGB(255, 255, 255, 255))
end

function DrawLine3D(x,y,z,a,b,c,width,col)
	local p1 = WorldToScreen(0, Vector(x,y,z))
	local p2 = WorldToScreen(0, Vector(a,b,c))
	DrawLine(p1.x, p1.y, p2.x, p2.y, width, col)
end

AddGapcloseEvent(_E, 666, false, AhriMenu)

PrintChat(string.format("<font color='#1244EA'>Ahri:</font> <font color='#FFFFFF'> By Deftsu Loaded, Have A Good Game ! </font>")) 
PrintChat("Have Fun Using D3Carry Scripts: " ..GetObjectBaseName(myHero)) 
