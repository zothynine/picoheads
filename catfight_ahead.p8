pico-8 cartridge // http://www.pico-8.com
version 16
__lua__
--catfight

--sfx
-- 00 laser
-- 01 explosion

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
		tile1_x=0,
		tile2_x=128
	}
	
	ascii={
		x=10,
		y=10,
		w=8,
		h=7,
		shots={},
		cape={9,10,13}
	}
	
	formations={
		linear={}
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
			swarm=swarms.line4,
			enemy=enemies.rat,
			path="linear",
			x=128,
			y=40},
		{⧗="0:6:0",
			swarm=swarms.line6,
			enemy=enemies.mouse,
			path="wave",
			x=128,
			y=100},
		{⧗="0:9:0",
			swarm=swarms.tri_s,
			enemy=enemies.rat,
			path="linear",
			x=128,
			y=90},
		{⧗="0:12:0",
			swarm=swarms.tri_s,
			enemy=enemies.mouse,
			path="linear",
			x=128,
			y=90},
		{⧗="0:15:0",
			swarm=swarms.tri_l,
			enemy=enemies.rat,
			path="linear",
			x=128,
			y=40},
	}
	
	enemies={}
	
	_update60=update_start
	_draw=draw_start
end

function center_text(_txt)
	return (128-(#_txt*4))/2
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
 ⧗.game.str=⧗.game.m..":"..⧗.game.s..":"..⧗.game.f
end

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
 for i=1,#_w.swarm do
		local _x=_w.x+_w.swarm[i][1]
		local _y=_w.y+_w.swarm[i][2]
	
  if _w.path=="linear"
  	or _w.path=="wave" then
   create_enemy(_w.enemy,_x,_y,_w.path)
  elseif _w.path=="circle" then
   create_enemy(_w.enemy,_x,_y,_w.path,87,127,127,0.25-0.03*i)
  end
 end
end

function create_enemy(_sprt,_x,_y,_p,_r,_originx,_originy,_a)
 add(enemies,
  {
  	x=_x, --x position
  	y=_y, --y position
  	w=6,  --width
  	h=5,  --height
  	p=_p, --swarm path
  	r=_r, --circle radius
  	ox=_originx, --circle center x
  	oy=_originy, --circle center y
  	a=_a, --initial angle
  	sprt=_sprt --sprite coordinates
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
  if _e.p=="linear" then
   if _e.x+_e.w<0 then
    del(enemies,_e)
   end
   _e.x-=0.5
  elseif _e.p=="wave" then
   if (_e.x+_e.w<0) del(enemies,_e)
   _e.x-=0.2
   _e.y-=sin(_e.x/12)
  elseif _e.p=="circle" then
   if (_e.y>127) del(enemies,_e)
   _e.a+=0.003
   if (_e.a > 1) _e.a=0
   _e.x=_e.ox+_e.r*cos(_e.a)
   _e.y=_e.oy+_e.r*sin(_e.a)
  end
  
  if collision(_e,ascii) then
  	_update60=update_gover
  	_draw=draw_gover
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
	if ⧗.next_cloud==0
		and #clouds < 25 then
		create_cloud()
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
	maps.tile1_x-=0.5
	maps.tile2_x-=0.5
	if (maps.tile1_x<=-128) maps.tile1_x=128
	if (maps.tile2_x<=-128) maps.tile2_x=128
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
	local _s=_e.sprt
	sspr(_s[1],_s[2],_s[3],_s[4],_e.x,_e.y)
end

function draw_infobar()
	rectfill(0,0,128,ui_h,2)
	print("🐱:"..3,2,2,7)	
	print("score:"..score,99,2,7)	

end

function draw_game()
	cls()
	rectfill(0,0,127,127,1)
	map(0,0,maps.tile1_x,0,16,16)
	map(0,0,maps.tile2_x,0,16,16)
	foreach(clouds,draw_cloud)
	pal(ascii.cape[1],8)
	palt(ascii.cape[2],true)
	palt(ascii.cape[3],true)
	spr(1,ascii.x,ascii.y)
	pal()
	palt()
	foreach(enemies,draw_enemy)
	draw_shots()
	draw_infobar()
	
	--print(⧗.game.m..":"..⧗.game.s..":"..⧗.game.f,5,5,8)
 
 --if #clouds>0 then
 --print(#clouds,5,12,8)
 --end
end
-->8
--game over

function update_gover()
	if btn(5) then
		_init()
		_update60=update_game
		_draw=draw_game
	end
end

function draw_gover()
	cls()
	local _score_txt="your score is "..score
	local _score_x=center_text(_score_txt)
	local _gover_txt="press ❎ to try again"
	print(_score_txt,_score_x,48,7)
	print(_gover_txt,center_text(_gover_txt),60,7)
end
__gfx__
0000000000000707900009f0000f0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000dd000777999999ffffff0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700a8888b7b985589f4ff4f0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000988777770555500ffff00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
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
b3b3b3b3000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
b3b3b3b3000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
3b3b3b3b000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4b4b4b4b000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
44444444000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
44544444000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
46444544000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
44446444000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
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
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2020202020202020202020202020202000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
000200003205032050320502f050270502305023000100000c00014000110000e0000d0000b0000b0000a00008000000000600005000060000600006000060000000000000000000000000000000000000000000
000a00000a6731f6401f6401f6301363013630136200a6200a6100a61000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
