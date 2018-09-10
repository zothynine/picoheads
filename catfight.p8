pico-8 cartridge // http://www.pico-8.com
version 16
__lua__
--catfight

function _init()
	⧗={
		spawn_e=120 --temp
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
			end
		end
	end
end

function create_enemy(_x,_y)
 add(enemies,
  {
  	x=_x,
  	y=_y,
  	w=6,
  	h=5
  })
end

function update_game()
	⧗.spawn_e-=1
	
	if ⧗.spawn_e==0 then
		⧗.spawn_e=flr(30+rnd(120))
		create_enemy(100,flr(10+rnd(90)))
	end
	
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
	
	print(#enemies,5,5,8)
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
