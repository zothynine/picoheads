pico-8 cartridge // http://www.pico-8.com
version 16
__lua__
--catfight

function _init()
	⧗={
		game={
		 m=0,
		 s=0,
		 f=0
		}
	}
	
	ascii={
		x=10,
		y=10,
		shots={}
	}
	
	--temp
	enemies={}
	
	_update60=update_start
	_draw=draw_start
end

function _update60()
end

function _draw()
end

-->8
--start

function update_start()
	if btn(5) then
		_update60=update_game
		_draw=draw_game
	end
end

function draw_start()
	cls()
	print("press ❎ to start",30,60,7)
end
-->8
--game
function update_game_timer()
 ⧗.game.f+=1
 if ⧗.game.f==59 then
  ⧗.game.f=0
  ⧗.game.s+=1
 end
 if ⧗.game.s==59 then
  ⧗.game.s=0
  ⧗.game.m+=1
 end
end

function collision(_a,_b)
	--test if shot hits emeny
	local _x=_a.x
	local _y=_a.y
	local _w=_a.w
	
	if _x+_w>=_b.x
		and _x<_b.x+_b.w
		and _y>=_b.y
		and _y<=_b.y+_b.h then
		_b.x=-8
		return true
	else
		return false
	end 
end

function move_ascii()
	if btn(0) then
		--links ⬅️
		ascii.x=mid(0,ascii.x-1,127)
	elseif btn(1) then
		--rechts ➡️
		ascii.x=mid(0,ascii.x+1,120)
	elseif btn(2) then
		--oben ⬆️
		ascii.y=mid(0,ascii.y-1,127)
	elseif btn(3) then
		--unten ⬇️
		ascii.y=mid(0,ascii.y+1,121)
	end
end

function shoot()
	add(ascii.shots,{
		x=ascii.x+6,
		y=ascii.y+2,
		w=3
	})
end

function check_shots()
	for i=#ascii.shots,1,-1 do
		local _shot=ascii.shots[i]
		local _x=_shot.x
		
		ascii.shots[i].x+=1
		
		-- delete shot when out of bounds
		if (_x>127) del(ascii.shots,_shot)
	
		for i=#enemies,1,-1 do
			local _e=enemies[i]
			if collision(_shot,_e) then
				del(enemies,_e)
				del(ascii.shots,_shot)
			end
		end
	end
end

function create_formation(_name,_amount)
 for i=1,_amount do
  if _name=="linear" then
   create_enemy(127+i*10,20,_name)
  elseif _name=="wave" then
   create_enemy(127+i*10,40,_name)
  elseif _name=="circle" then
   create_enemy(127+i*10,40,_name,87,127,127,0.25-0.03*i)
  end
 end
end

function create_enemy(_x,_y,_f,_r,_originx,_originy,_a)
 add(enemies,
  {
  	x=_x,
  	y=_y,
  	w=6,
  	h=5,
  	f=_f,
  	r=_r, --circle radius
  	ox=_originx, --circle center x
  	oy=_originy, --circle center y
  	a=_a --initial angle
  })
end

function update_enemies()
 for i=#enemies,1,-1 do
  local _e=enemies[i]
  if _e.f=="linear" then
   if _e.x+_e.w<0 then
    del(enemies,_e)
   end
   _e.x-=0.5
  elseif _e.f=="wave" then
   if (_e.x+_e.w<0) del(enemies,_e)
   _e.x-=0.2
   _e.y-=sin(_e.x/12)
  elseif _e.f=="circle" then
   if (_e.y>127) del(enemies,_e)
   _e.a+=0.003
   if (_e.a > 1) _e.a=0
   _e.x=_e.ox+_e.r*cos(_e.a)
   _e.y=_e.oy+_e.r*sin(_e.a)
  end
 end
end

function update_game()
 update_game_timer()
 
 if ⧗.game.s==3
  and ⧗.game.f==0
  and ⧗.game.m==0 then
  create_formation("circle",6)
 end
 
 update_enemies()
	
	move_ascii()
		
	if btnp(5) then
		shoot()
	end
	
	check_shots()
end


function draw_shots()
	for i=1,#ascii.shots do
		local _x=ascii.shots[i].x
		local _y=ascii.shots[i].y
		local _w=ascii.shots[i].w
		line(_x,_y,_x+_w,_y,8)
	end
end

function draw_enemy(_e)
	spr(2,_e.x,_e.y)
end

function draw_game()
	cls()
	spr(1,ascii.x,ascii.y)
	foreach(enemies,draw_enemy)
	draw_shots()
	
	print(⧗.game.m..":"..⧗.game.s..":"..⧗.game.f,5,5,8)
 print(#enemies,5,12,8)
end
__gfx__
00000000000007079000090000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000007779999990000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0070070008888b7b9855890000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000888777770555500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000077777700055000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700070000700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000700007000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
000100000000030050300503005032050300500f0500c0500a050080500705007050160501e050000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
