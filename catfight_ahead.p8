pico-8 cartridge // http://www.pico-8.com
version 16
__lua__
--catfight

--sfx
-- 00 laser
-- 01 explosion

-- changes:
-- 	update_game_timer global
-- 	und auch im gover state

--		map sprites in tab1 verschoben
--		parallax animation

function _init()
	⧗={
		game={
		 m=0,
		 s=0,
		 f=0,
		 str="0:0:0"
		},
		cape=12,
		next_cloud=0
	}
	
	ui_h=8
	
	score=0
	
	clouds={}
	
	maps={
		gnd1_x=0,
		gnd2_x=128,
		plx1_x=0,
		plx2_x=128,
	}
	
	ascii={
		x=56,
		y=55,
		ghost_x=60,
		ghost_y=100,
		w=8,
		h=7,
		shots={},
		collided=false,
		lives=2,
		cape={9,10,13},
		cooldwn=900,
		cd⧗=900
	}
	
	enemies={
		rat={16,0,6,5},
		mouse={22,0,6,5}
	}
	
	swarms={
		line4={{0,0},{10,0},{20,0},{30,0}},
		line6={{0,0},{10,0},{20,0},{30,0},{40,0},{50,0}},
		tri_s={{0,0},{10,-5},{10,5},{20,-10},{20,0},{20,10}},
		tri_l={{0,0},{10,-5},{10,5},{20,-10},{20,0},{20,10},{30,-15},{30,-5},{30,5},{30,15}}
	}
	
	enemy_waves={
		{⧗="0:3:0",
			swarm=swarms.tri_s,
			enemy=enemies.mouse,
			path="slope",
			x=128,
			y=50},
		{⧗="0:6:0",
			swarm=swarms.tri_l,
			enemy=enemies.rat,
			path="wave",
			x=128,
			y=50},
		{⧗="0:9:0",
			swarm=swarms.tri_s,
			enemy=enemies.mouse,
			path="circle",
			x=128,
			y=40}
	}
	
	enemies={}
	
	_update60=update_start
	_draw=draw_start
end

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
 ⧗.game.str=⧗.game.m..":"..⧗.game.s..":"..⧗.game.f
end

function print_center(_txt,_y,_c)
	local _t=tostr(_txt)
	print(_t,(128-(#_t*4))/2,_y,_c)
end

function print_right(_txt,_y,_c,_o)
	local _t=tostr(_txt)
	_o=_o or 0
	print(_t,128-(#_t*4)-_o,_y,_c)
end

function _update60()
end

function _draw()
end

-->8
--start

function update_start()
	update_clouds()
	update_cape()
	if btn(5) then
		_update60=update_game
		_draw=draw_game
	end
end

function draw_start()
	cls()
	rectfill(0,0,127,127,1)
	foreach(clouds,draw_cloud)
	print_center("catfight",34,0)
	print_center("catfight",35,7)
	draw_ascii(2)
	print_center("press ❎ to start",84,0)
	print_center("press ❎ to start",85,7)
	--print("press ❎ to start",30,69,0)
	--print("press ❎ to start",30,70,7)
end
-->8
--game

function collision(_a,_b)
	--test if shot hits emeny
	
	if _a.x+_a.w>=_b.x
		and _a.x<_b.x+_b.w
		and _a.y+_a.h>=_b.y
		and _a.y<=_b.y+_b.h then
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
		w=3,
		h=1,
		spd=2
	})
	sfx(0)
end

function check_shots()
	for i=#ascii.shots,1,-1 do
		local _shot=ascii.shots[i]
		local _x=_shot.x
		
		_shot.x+=_shot.spd
		
		-- delete shot when out of bounds
		if (_x>127) del(ascii.shots,_shot)
	
		for i=#enemies,1,-1 do
			local _e=enemies[i]
			if collision(_shot,_e) then
				del(enemies,_e)
				del(ascii.shots,_shot)
				sfx(1)
				score+=1
			end
		end
	end
end

function create_wave(_w)
	_w.active=true
 for i=1,#_w.swarm do
 	local _x=_w.x+_w.swarm[i][1]
 	local _y=_w.y+_w.swarm[i][2]
	
  if _w.path=="linear" or
  			_w.path=="wave" or
  			_w.path=="slope" then
   create_enemy(_w,i,_x,_y)
  elseif _w.path=="circle" then
   create_enemy(_w,i,_x,_y,127,127,0.25-0.003)
  end
 end
end

function create_enemy(_w,_si,_x,_y,_originx,_originy,_a)
 add(enemies,
  {
  	x=_x,
  	y=_y,
  	w=6,
  	h=5,
  	r=sqrt((_w.x-127)*(_w.x-127)+(127-_w.y)*(127-_w.y)), --circle radius
  	ox=_originx, --circle center x
  	oy=_originy, --circle center y
  	a=_a, --initial angle
  	∧=_w,
  	si=_si
  })
end

function update_waves()
	local _f=enemy_waves[1]
	if (#enemy_waves==0) return
	if _f.⧗==⧗.game.str then
		create_wave(_f)
		del(enemy_waves,_f)
	end
end

function update_enemies()
 for i=#enemies,1,-1 do
  local _e=enemies[i]
  if _e.∧.path=="linear" then
   if _e.x+_e.w<0 then
    del(enemies,_e)
   end
   _e.∧.x-=0.1
   _e.x=_e.∧.x+_e.∧.swarm[_e.si][1]
  elseif _e.∧.path=="wave" then
   if (_e.x+_e.w<0) del(enemies,_e)
   _e.∧.x-=0.1
   _e.∧.y-=sin(_e.∧.x/24)
   _e.x=_e.∧.x+_e.∧.swarm[_e.si][1]
   _e.y=_e.∧.y+_e.∧.swarm[_e.si][2]
  elseif _e.∧.path=="slope" then
   if _e.x+_e.w<0 then
    del(enemies,_e)
   end
   if _e.∧.x<97 and _e.∧.x>30 and _e.∧.y<87 then
   	_e.∧.y+=0.08
   end
  	_e.∧.x-=0.05
  	
  	_e.x=_e.∧.x+_e.∧.swarm[_e.si][1]
   _e.y=_e.∧.y+_e.∧.swarm[_e.si][2]
  elseif _e.∧.path=="circle" then
   if (_e.y>127) del(enemies,_e)
   _e.a+=0.003
   if (_e.a > 1) _e.a=0
   _e.∧.x=_e.ox+_e.r*cos(_e.a)
   _e.∧.y=_e.oy+_e.r*sin(_e.a)
   _e.x=_e.∧.x+_e.∧.swarm[_e.si][1]
   _e.y=_e.∧.y+_e.∧.swarm[_e.si][2]
  end
  
  if collision(_e,ascii) then
  	if not ascii.collided then
  		ascii.lives-=1
  		ascii.collided=true
  	end
  	
  	if ascii.lives<0 then
  		_update60=update_gover
  		_draw=draw_gover
  	end
  end
  
  if ascii.collided then
  	ascii.cd⧗-=1
  	
  	if ascii.cd⧗==0 then
  		ascii.collided=false
  		ascii.cd⧗=ascii.cooldwn
  	end
  end
 end
end

function create_cloud()
	local _scale=0.8+rnd(1.5)
	local _y=ui_h-((5*_scale)/2)
	
	add(clouds,{
		x=135,
		y=_y+flr(rnd(15)),
		dx=0.2+rnd(0.5),
		scl=_scale
	})
end

function update_clouds()
	if ⧗.next_cloud==0 then
		if (#clouds < 25) create_cloud()
		⧗.next_cloud=flr(10+rnd(15))
	end
	
	for i=#clouds,1,-1 do
		local _cloud=clouds[i]
		_cloud.x-=_cloud.dx
		if (_cloud.x < -8) del(clouds,_cloud)
	end
	
	⧗.next_cloud-=1
end

function update_map()
	maps.gnd1_x-=0.5
	maps.gnd2_x-=0.5
	maps.plx1_x-=0.4
	maps.plx2_x-=0.4
	if (maps.gnd1_x<=-128) maps.gnd1_x=128
	if (maps.gnd2_x<=-128) maps.gnd2_x=128
	if (maps.plx1_x<=-128) maps.plx1_x=128
	if (maps.plx2_x<=-128) maps.plx2_x=128
end

function update_cape()
	⧗.cape-=1
	if ⧗.cape==8 then
		ascii.cape={10,13,9}
	elseif ⧗.cape==4 then
		ascii.cape={13,9,10}
	elseif ⧗.cape==0 then
		ascii.cape={9,10,13}
		⧗.cape=12
	end
end

function update_game()
 update_game_timer()
 update_clouds()
 update_map()
 update_cape()
 update_waves()
 
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

function draw_cloud(cloud)
	sspr(o,8,9,6,cloud.x,cloud.y,9*cloud.scl,5*cloud.scl)
end

function draw_enemy(_e)
	local _s=_e.∧.enemy
	sspr(_s[1],_s[2],_s[3],_s[4],_e.x,_e.y)
end

function draw_infobar()
	rectfill(0,0,128,ui_h,2)
	sspr(13,0,3,4,2,2)
	-- print("🐱:"..ascii.lives,2,2,7)
	print(ascii.lives,7,2,7)
	print_right(score,2,7,1)
end

function draw_ascii(_scale,_ghost)
	local _scale = _scale or 1
	local _ghost = _ghost or false
	pal(ascii.cape[1],8)
	palt(ascii.cape[2],true)
	palt(ascii.cape[3],true)
	sspr(8,0,8,7,ascii.x,ascii.y,8*_scale,7*_scale)
	if _ghost then
		pal(7,6)
		pal(9,6)
		pal(7,6)
		pal(8,6)
		pal(4,6)
		pal(11,6)
		palt(10,true)
		palt(13,true)
		sspr(8,0,8,7,ascii.ghost_x,ascii.ghost_y,8*_scale,7*_scale)
	end
	pal()
	palt()
end

function draw_game()
	cls()
	rectfill(0,0,127,127,1)
	--parallax1
	map(0,9,maps.plx1_x,72,16,6)
	map(0,9,maps.plx2_x,72,16,6)
	--ground
	map(0,15,maps.gnd1_x,120,16,1)
	map(0,15,maps.gnd2_x,120,16,1)
	foreach(clouds,draw_cloud)
	
	
	if ascii.collided then
		if ⧗.game.f%5==0 then
			draw_ascii()
		end		
	else
		draw_ascii()
	end
	
	foreach(enemies,draw_enemy)
	draw_shots()
	draw_infobar()
	
	--print(ascii.cd⧗,5,20,8)
 
 --if #clouds>0 then
 --print(#clouds,5,12,8)
 --end
end
-->8
--game over

function update_gover()
 update_game_timer()
	update_clouds()
	ascii.x=60
	ascii.y=100
	ascii.ghost_y-=0.6
		
	--todo: fertig denken!
	-- loesung = variable fuer die speed
	--ascii.ghost_x-=0.5	
	--if ascii.ghost_x <= 58 then
	--	ascii.ghost_x+=0.5
	--elseif ascii.ghost_x > 62 then
	--	ascii.ghost_x-=0.5
	--end
	
	if ⧗.game.f<30 then
		ascii.ghost_x-=0.2
	else
		ascii.ghost_x+=0.2
	end
	
	if btn(5) then
		_init()
		_update60=update_game
		_draw=draw_game
	end
end

function draw_gover()
	cls()
	rectfill(0,0,127,127,1)
	pal(7,5)
	pal(6,1)
	foreach(clouds,draw_cloud)
	pal()
	local _score_txt="your score is "..score
	print_center("press ❎ to try again",55,0)
	print_center("press ❎ to try again",56,7)
	print_center("your score is "..score,42,0)
	print_center("your score is "..score,43,7)
	if (ascii.ghost_y >= -7) draw_ascii(2,true)
end
__gfx__
0000000000000707900009f0000f0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000dd000777999999ffffff0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700a8888b7b985589f4ff4f0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000988777440555500ffff00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000770000777777000550000ff000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700070000700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000700007000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00677770000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
06777777000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
67777777700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
77777777700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
07767776000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00677760000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
b3b3b3b3000555555555500055555555000000055000000000000007700000000000000000000000000000000000000000000000000000000000000000000000
b3b3b3b3000555d55555500055555555000000055000000000000007700000000000000000000000000000000000000000000000000000000000000000000000
3b3b3b3b005555555555550055555555000000555500000000000075770000000000000000000000000000000000000000000000000000000000000000000000
4b4b4b4b005555555555550055555555000000555500000000000055570000000000000000000000000000000000000000000000000000000000000000000000
444444440555d5555555555055555555000005555550000000000555557000000000000000000000000000000000000000000000000000000000000000000000
44544444055555555555555055555555000005555550000000000555557000000000000000000000000000000000000000000000000000000000000000000000
4644454455d555555555555555555555000055555555000000005555555700000000000000000000000000000000000000000000000000000000000000000000
44446444555555555555555555555555000055555555000000005555555500000000000000000000000000000000000000000000000000000000000000000000
__map__
2121212121212121212121212121212100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000464700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000414200000000000000004647000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0044434345000000000000004142000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0041434342000046470000444343450000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4443434343450041420000414343420000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4143434343424443434544434343434500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4040404040404040404040404040404000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
000200003205032050320502f050270502305023000100000c00014000110000e0000d0000b0000b0000a00008000000000600005000060000600006000060000000000000000000000000000000000000000000
000a00000a6731f6401f6401f6301363013630136200a6200a6100a61000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
