if GetObjectName(GetMyHero()) ~= "Ekko" then return end

require('Inspired')
require('DeftLib')
require('DamageLib')

local EkkoMenu = MenuConfig("Ekko", "Ekko")
EkkoMenu:Menu("Combo", "Combo")
EkkoMenu.Combo:Boolean("Q", "Use Q", true)
EkkoMenu.Combo:Boolean("W", "Use W", true)
EkkoMenu.Combo:Boolean("E", "Use E", true)
EkkoMenu.Combo:Boolean("R", "Use R", true)

EkkoMenu:Menu("Harass", "Harass")
EkkoMenu.Harass:Boolean("Q", "Use Q", true)
EkkoMenu.Harass:Boolean("W", "Use W", true)
EkkoMenu.Harass:Boolean("E", "Use E", true)
EkkoMenu.Harass:Slider("Mana", "if Mana % is More than", 30, 0, 80, 1)

EkkoMenu:Menu("Killsteal", "Killsteal")
EkkoMenu.Killsteal:Boolean("Q", "Killsteal with Q", true)
EkkoMenu.Killsteal:Boolean("E", "Killsteal with E", true)
EkkoMenu.Killsteal:Boolean("R", "Killsteal with R", true)

EkkoMenu:Menu("Misc", "Misc")
if Ignite ~= nil then EkkoMenu.Misc:Boolean("AutoIgnite", "Auto Ignite", true) end
EkkoMenu.Misc:Menu("AutoUlt", "Auto Ult")
EkkoMenu.Misc.AutoUlt:Boolean("Enabled", "Enabled", true)
EkkoMenu.Misc.AutoUlt:Slider("hit", "if Can Hit X Enemies", 3, 0, 5, 1)
EkkoMenu.Misc.AutoUlt:Slider("killable", "if Can Kill X Enemies", 2, 0, 5, 1)

EkkoMenu:Menu("Lasthit", "Lasthit")
EkkoMenu.Lasthit:Boolean("Q", "Use Q", true)
EkkoMenu.Lasthit:Slider("Mana", "if Mana % >", 50, 0, 80, 1)

EkkoMenu:Menu("LaneClear", "LaneClear")
EkkoMenu.LaneClear:Boolean("Q", "Use Q", true)
EkkoMenu.LaneClear:Boolean("W", "Use W", false)
EkkoMenu.LaneClear:Boolean("E", "Use E", false)
EkkoMenu.LaneClear:Slider("Mana", "if Mana % >", 30, 0, 80, 1)

EkkoMenu:Menu("JungleClear", "JungleClear")
EkkoMenu.JungleClear:Boolean("Q", "Use Q", true)
EkkoMenu.JungleClear:Boolean("W", "Use W", true)
EkkoMenu.JungleClear:Boolean("E", "Use E", true)
EkkoMenu.JungleClear:Slider("Mana", "if Mana % >", 30, 0, 80, 1)

EkkoMenu:Menu("Drawings", "Drawings")
EkkoMenu.Drawings:Boolean("Q", "Draw Q Range", true)
EkkoMenu.Drawings:Boolean("W", "Draw W Range", true)
EkkoMenu.Drawings:Boolean("E", "Draw E Range", true)
EkkoMenu.Drawings:Boolean("OP", "OP Drawings", true)

local twin,EkkoQ,QDuration,EkkoW,EkkoWOrigin,WDuration = nil,nil,nil,nil,nil

OnProcessSpell(function(unit, spell)
  if unit == myHero then
    if spell.name == "EkkoQ" then
    QDuration = GetTickCount()+2565-GetLatency()
    end

    if spell.name == "EkkoW" then
    WDuration = GetTickCount()+3000
    EkkoWOrigin = spell.endPos
    DelayAction(function() EkkoWOrigin = nil end, 3000)
    end
  end
end)
 
OnObjectLoad(function(Object) 

  if GetObjectBaseName(Object) == "Ekko" then
  twin = Object
  end

end)

local Objects = {}

OnCreateObj(function(Object) 

  if GetObjectBaseName(Object) == "Ekko" then
  twin = Object
  end
  
  if GetObjectBaseName(Object) == "missile" then
  table.insert(Objects,Object) 
  end
  
end)

OnDeleteObj(function(Object) 

  if GetObjectBaseName(Object) == "missile" then
    for i,deletedObjects in pairs(Objects) do
      if GetNetworkID(Object) == GetNetworkID(deletedObjects) then
      table.remove(Objects,i) 
      end
    end
  end
  
  if GetObjectBaseName(Object) == "Ekko_Base_R_TrailEnd.troy" then
  twin = nil
  end

end)

OnDraw(function(myHero)
local pos = GetOrigin(myHero)
if EkkoMenu.Drawings.Q:Value() then DrawCircle(pos,925,1,25,GoS.Pink) end
if EkkoMenu.Drawings.W:Value() then DrawCircle(pos,1600,1,25,GoS.Yellow) end
if EkkoMenu.Drawings.E:Value() then DrawCircle(pos,350,1,25,GoS.Blue) end
if EkkoMenu.Drawings.OP:Value() then
  for _,Object in pairs(Objects) do
    if Object ~= nil and GetObjectSpellOwner(Object) == myHero then
      if GetObjectSpellName(Object) == "ekkoqmis" then 
      DrawRectangleOutline(pos, GetOrigin(Object), 90)
      local wts = WorldToScreen(0,GetOrigin(Object))
      DrawText((math.floor((QDuration-GetTickCount()))/1000).."s", 25, wts.x-35, wts.y-50, ARGB(255, 255, 0, 0)) 
      elseif GetObjectSpellName(Object) == "ekkoqreturn" then
      DrawRectangleOutline(pos, GetOrigin(Object), 90)
      end
    end
  end
  if EkkoWOrigin ~= nil then
  DrawCircle(EkkoWOrigin,400,2,100,ARGB(255, 155, 150, 250))
  local wts = WorldToScreen(0,EkkoWOrigin)
  DrawText((math.floor((WDuration-GetTickCount()))/1000).."s", 25, wts.x-35, wts.y-50, ARGB(255, 255, 0, 0)) 
  end
  if twin then
  DrawCircle(GetOrigin(twin),400,2,100,ARGB(255, 0, 255, 0)) 
  DrawCircle(GetOrigin(twin),GetHitBox(myHero),2,100,ARGB(255, 255, 0, 0)) 
  DrawLine3D(pos.x,pos.y,pos.z,GetOrigin(twin).x,GetOrigin(twin).y,GetOrigin(twin).z,2,ARGB(255, 0, 255, 0))
  end
end
 
end)

local target1 = TargetSelector(995,TARGET_LESS_CAST_PRIORITY,DAMAGE_MAGIC,true,false)
local target2 = TargetSelector(1900,TARGET_LESS_CAST_PRIORITY,DAMAGE_MAGIC,true,false)

OnTick(function(myHero)
   local target = GetCurrentTarget()	
   local Qtarget = target1:GetTarget()
   local Wtarget = target2:GetTarget()
    
   if IOW:Mode() == "Combo" then
	
     if IsReady(_Q) and EkkoMenu.Combo.Q:Value() then
     Cast(_Q,Qtarget)
     end
	   
     if IsReady(_W) and EkkoMenu.Combo.W:Value() then
       if GetCurrentMana(myHero) < (GetCastMana(myHero,_Q,GetCastLevel(myHero,_Q)) + GetCastMana(myHero,_W,GetCastLevel(myHero,_W))) and GetCurrentMana(myHero) >= GetCastMana(myHero,_W,GetCastLevel(myHero,_W)) and GetCurrentHP(myHero)-GetCurrentHP(Wtarget) > 60+20*GetCastLevel(myHero,_W)+1.5*GetBonusAP(myHero) then
       Cast(_W,Wtarget)
       elseif GetDistance(Wtarget) > 925 then
       Cast(_W,Wtarget)
       end
     end
     
     if IsReady(_E) and ValidTarget(target,800) and GetDistance(target) > (GetRange(myHero)+GetHitBox(myHero)) and EkkoMenu.Combo.E:Value() then
       local BestPos = Vector(target) - (Vector(target) - Vector(myHero)):perpendicular():normalized() * 350
       if BestPos then 
       CastSkillShot(_E,BestPos)
       else
       CastSkillShot(_E,GetMousePos())
       end
     end
	   
     if IsReady(_R) and IsDead(target) and EkkoMenu.Combo.R:Value() then
       for _,turret in pairs(Turrets) do
         if GetHP(myHero) < IOW:GetDmg(turret, myHero) and IsUnderTower(myHero) then
	 CastSpell(_R)
	 end
       end
     end
	   
     if twin and EnemiesAround2(GetOrigin(twin),400) >= 1 and EkkoMenu.Combo.R:Value() then
       if IsReady(_R) and IsReady(_Q) and IsReady(_E) and ValidTarget(target,20000) and GetCurrentMana(myHero) >= (GetCastMana(myHero,_Q,GetCastLevel(myHero,_Q)) + GetCastMana(myHero,_E,GetCastLevel(myHero,_E)) + GetCastMana(myHero,_R,GetCastLevel(myHero,_R))) and GetHP2(target) < getdmg("Q",target)+getdmg("E",target)+getdmg("R",target)+IOW:GetDmg(myHero, target) then
       CastSpell(_R)
       elseif IsReady(_R) and IsReady(_Q) and ValidTarget(target,20000) and GetCurrentMana(myHero) >= (GetCastMana(myHero,_Q,GetCastLevel(myHero,_Q)) + GetCastMana(myHero,_R,GetCastLevel(myHero,_R))) and GetHP2(target) < getdmg("Q",target)+getdmg("R",target)+IOW:GetDmg(myHero, target) then
       CastSpell(_R)
       elseif IsReady(_R) and IsReady(_E) and ValidTarget(target,20000) and GetCurrentMana(myHero) >= (GetCastMana(myHero,_E,GetCastLevel(myHero,_E)) + GetCastMana(myHero,_R,GetCastLevel(myHero,_R))) and GetHP2(target) < getdmg("E",target)+getdmg("R",target)+IOW:GetDmg(myHero, target) then
       CastSpell(_R)
       elseif IsReady(_R) and ValidTarget(target,20000) and GetHP2(target) <= getdmg("R",target)+IOW:GetDmg(myHero, target) then
       CastSpell(_R)
       end
     end
	      
   end 

   if IOW:Mode() == "Harass" and GetPercentMP(myHero) >= EkkoMenu.Harass.Mana:Value() then
	
     if IsReady(_Q) and EkkoMenu.Harass.Q:Value() then
     Cast(_Q,Qtarget)
     end
	   
     if IsReady(_W) and EkkoMenu.Harass.W:Value() then
     Cast(_W,Wtarget)
     end
       
     if IsReady(_E) and ValidTarget(target,800) and GetDistance(target) < (GetRange(myHero)+GetHitBox(myHero)*2) and EkkoMenu.Harass.E:Value() then
       local BestPos = Vector(target) - (Vector(target) - Vector(myHero)):perpendicular():normalized() * 350
       if BestPos then 
       CastSkillShot(_E,BestPos)
       else
       CastSkillShot(_E,GetMousePos())
       end
     end
	   
   end	   
	 
   if twin and IsReady(_R) and EkkoMenu.Misc.AutoUlt.Enabled:Value() then
     if EnemiesAround2(GetOrigin(twin), 400) >= EkkoMenu.Misc.AutoUlt.hit:Value() then
     CastSpell(_R)
     end
   end
	
   local KillableEnemies = 0
		
   for i,enemy in pairs(GetEnemyHeroes()) do
    	
     if Ignite and EkkoMenu.Misc.AutoIgnite:Value() then
       if IsReady(Ignite) and 20*GetLevel(myHero)+50 > GetHP(enemy)+GetHPRegen(enemy)*3 and ValidTarget(enemy, 600) then
       CastTargetSpell(enemy, Ignite)
       end
     end
		
     if IsReady(_R) and EkkoMenu.Misc.AutoUlt.Enabled:Value() then
       if ValidTarget(enemy, 20000) and twin and GetDistance(twin, GetPredictedPos(enemy,250)) <= 400 and GetHP2(enemy) < getdmg("R",enemy) then 
       KillableEnemies = KillableEnemies + 1
       end
		  
       if KillableEnemies >= EkkoMenu.Misc.AutoUlt.killable:Value() then
       CastSpell(_R)
       end
     end
                
     if IsReady(_Q) and ValidTarget(enemy, 995) and EkkoMenu.Killsteal.Q:Value() and GetHP2(enemy) < getdmg("Q",enemy,myHero,3) then 
     Cast(_Q,enemy)
     elseif IsReady(_E) and ValidTarget(enemy, 800) and EkkoMenu.Killsteal.E:Value() and GetHP2(enemy) < getdmg("E",enemy) then
     CastSkillShot(_E,GetOrigin(enemy))
     DelayAction(function() AttackUnit(enemy) end, 250)
     elseif twin and IsReady(_R) and GetDistance(twin, target) <= 400 and ValidTarget(enemy, 20000) and EkkoMenu.Killsteal.R:Value() and GetHP2(enemy) < getdmg("R",enemy) then
     CastSpell(_R)
     end

   end
	
   if IOW:Mode() == "LaneClear" then
     	
     local closeminion = ClosestMinion(GetOrigin(myHero), MINION_ENEMY)
     if GetPercentMP(myHero) >= EkkoMenu.LaneClear.Mana:Value() then
       	
       if IsReady(_Q) and EkkoMenu.LaneClear.Q:Value() then
         local BestPos, BestHit = GetLineFarmPosition(925, 140, MINION_ENEMY)
         if BestPos and BestHit > 1 then 
         CastSkillShot(_Q, BestPos)
         end
       end

       if IsReady(_E) and EkkoMenu.LaneClear.E:Value() then
         if GetCurrentHP(closeminion) < getdmg("E",closeminion) and ValidTarget(closestminion, 800) then
         CastSkillShot(_E, GetOrigin(closeminion))
         end
       end
        
     end

   end
         
   for i,mobs in pairs(minionManager.objects) do
     if IOW:Mode() == "LaneClear" and GetTeam(mobs) == 300 and GetPercentMP(myHero) >= EkkoMenu.JungleClear.Mana:Value() then
       if IsReady(_Q) and EkkoMenu.JungleClear.Q:Value() and ValidTarget(mobs, 925) then
       CastSkillShot(_Q,GetOrigin(mobs))
       end
		
       if IsReady(_W) and EkkoMenu.JungleClear.W:Value() and ValidTarget(mobs, 1000) then
       CastSpell(_W)
       end
		
       if IsReady(_E) and EkkoMenu.JungleClear.E:Value() and ValidTarget(mobs, 800) then
       CastSkillShot(_E,GetOrigin(mobs))
       end
     end
     	
     if IOW:Mode() == "LastHit" and GetTeam(mobs) == MINION_ENEMY and GetPercentMP(myHero) >= EkkoMenu.Lasthit.Mana:Value() then
       if IsReady(_Q) and ValidTarget(mobs, 925) and EkkoMenu.Lasthit.Q:Value() and GetCurrentHP(mobs) < getdmg("Q",mobs) then
       CastSkillShot(_Q, GetOrigin(mobs))
       end
     end
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

PrintChat(string.format("<font color='#1244EA'>Ekko:</font> <font color='#FFFFFF'> By Deftsu Loaded, Have A Good Game ! </font>"))
PrintChat("Have Fun Using D3Carry Scripts: " ..GetObjectBaseName(myHero)) 
