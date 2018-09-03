pico-8 cartridge // http://www.pico-8.com
version 16
__lua__
--catfight

function _init()
	ascii={
		x=10,
		y=10,
		shots={}
	}
	
	--temp
	enemy={
		x=100,
		y=50,
		h=5
	}
end

function _update60()
	if btn(0) then
		--links ⬅️
		ascii.x=mid(0,ascii.x-1,127)
	elseif btn(1) then
		--rechts ➡️
		ascii.x=mid(0,ascii.x+1,122)
	elseif btn(2) then
		--oben ⬆️
		ascii.y=mid(0,ascii.y-1,127)
	elseif btn(3) then
		--unten ⬇️
		ascii.y=mid(0,ascii.y+1,123)
	end
	
	if btnp(5) then
		add(ascii.shots,{
			x=ascii.x+6,
			y=ascii.y+2,
			l=3
		})
	end
	
	--shots
	for i=#ascii.shots,1,-1 do
		local _shot=ascii.shots[i]
		local _x=_shot.x
		local _y=_shot.y
		local _l=_shot.l		
		ascii.shots[i].x+=1
		-- delete shot when out of bounds
		if (_x>127) del(ascii.shots,_shot)
	
		--test if shot hits emeny
		if _x+_l>=enemy.x
			and _y>=enemy.y
			and _y<=enemy.y+enemy.h then
			enemy.x=-8
		end  
	end
end

function _draw()
	cls()
	spr(1,ascii.x,ascii.y)
	spr(2,enemy.x,enemy.y)
	for i=1,#ascii.shots do
		local _x=ascii.shots[i].x
		local _y=ascii.shots[i].y
		local _l=ascii.shots[i].l
		line(_x,_y,_x+_l,_y,8)
	end
end

__gfx__
00000000500005009000090000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000555555009999990000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700585585009855890000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000055550000555500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000005500000055000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
000100000000030050300503005032050300500f0500c0500a050080500705007050160501e050000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
