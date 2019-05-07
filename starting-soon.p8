pico-8 cartridge // http://www.pico-8.com
version 18
__lua__
--intro

function _init()
	mx=40
	ix=60
	kx=80
	y=0
	timer=0
	bubbles={}
	splashes={}
end

function _update60()
	timer+=1
	local _mtrigger = 45 --mario
	-- local _itrigger = 23 --guest
	local _ktrigger = 90 --klemens
	if (timer==120) timer=0
	y=mid(0,y+1, 112)

	if y==112 then
		--mario
		if timer==_mtrigger then
			add(bubbles,{bx=mx+4,by=y+6,s=flr(rnd(4))})
		end

		--guest
		-- if timer==_itrigger then
		-- 	add(bubbles,{bx=ix+4,by=y+6,s=flr(rnd(4))})
		-- end

		--klemens
		if timer==_ktrigger then
			add(bubbles,{bx=kx+4,by=y+6,s=flr(rnd(4))})
		end
	end

	if (y>54 and y<64) addsplashes()

	updatesplashes()

	if btn(❎)
	 or btn(🅾️)
	 or btn(⬅️)
	 or btn(➡️)
	 or btn(⬆️)
	 or btn(⬇️) then
	 load("intro")
	end
end

function updatesplashes()
	for i = #splashes,1,-1 do
		local s = splashes[i]

		if s.d == "l" then
			s.x -= 1+flr(rnd(3))
		else
			s.x += 1+flr(rnd(3))
		end


		s.y += -3+flr(rnd(3))
		s.lt -= 1
		if s.lt < 1 then
			del(splashes,s)
		end
	end
end

function addsplashes()
	local _y = 63
	--mario
	add(splashes,{d="l",x=mx,y=_y,lt=flr(rnd(6))})
	add(splashes,{d="l",x=mx,y=_y,lt=flr(rnd(6))})
	add(splashes,{d="l",x=mx,y=_y,lt=flr(rnd(6))})
	add(splashes,{d="r",x=mx+7,y=_y,lt=flr(rnd(6))})
	add(splashes,{d="r",x=mx+7,y=_y,lt=flr(rnd(6))})
	add(splashes,{d="r",x=mx+7,y=_y,lt=flr(rnd(6))})
	--guest
	-- add(splashes,{d="l",x=ix,y=_y,lt=flr(rnd(6))})
	-- add(splashes,{d="l",x=ix,y=_y,lt=flr(rnd(6))})
	-- add(splashes,{d="l",x=ix,y=_y,lt=flr(rnd(6))})
	-- add(splashes,{d="r",x=ix+7,y=_y,lt=flr(rnd(6))})
	-- add(splashes,{d="r",x=ix+7,y=_y,lt=flr(rnd(6))})
	-- add(splashes,{d="r",x=ix+7,y=_y,lt=flr(rnd(6))})
	--klemens
	add(splashes,{d="l",x=kx,y=_y,lt=flr(rnd(6))})
	add(splashes,{d="l",x=kx,y=_y,lt=flr(rnd(6))})
	add(splashes,{d="l",x=kx,y=_y,lt=flr(rnd(6))})
	add(splashes,{d="r",x=kx+7,y=_y,lt=flr(rnd(6))})
	add(splashes,{d="r",x=kx+7,y=_y,lt=flr(rnd(6))})
	add(splashes,{d="r",x=kx+7,y=_y,lt=flr(rnd(6))})
end

function pixel_under_water(c,r)
	return fget(mget(flr((mx+c)/8),flr((y+r)/8)),0)
end

function _draw()
	cls()
	map(0,0,0,0,16,16)
	print("wir entwickeln",6,15,6)
	print("presented by picoheads",6,25,6)
	print("episode #32 startet in kuerze",6,35,6)
	spr(0,mx,y,1,2) --mario
	-- spr(33,ix,y,1,2) --guest
	spr(32,kx,y,1,2) --klemens


	for row=0,16 do
		for colm=0,8 do
			if not pixel_under_water(colm,row) then
				local mpixel = pget(mx+colm,y+row)
				local ipixel = pget(ix+colm,y+row)
				local kpixel = pget(kx+colm,y+row)

				--mario
 				if mpixel != 1
 							and mpixel >= 1
 							and mpixel != 7 then
 					pset(mx+colm,y+row,6)
 				end

				--guest
 				-- if ipixel != 1
 				-- 			and ipixel >= 1
 				-- 			and ipixel != 7 then
 				-- 	pset(ix+colm,y+row,6)
 				-- end

				--klemens
 				if kpixel != 1
 							and kpixel >= 1
 							and kpixel != 7 then
 					pset(kx+colm,y+row,6)
 				end
			end
		end
	end

	for bubble in all(bubbles) do
		local x=bubble.bx
		local y=bubble.by
		local size=bubble.s

		--pset(x,y,7)
		sspr(8,8,6,6,x,y,size,size)

		bubble.by-=0.3
		bubble.s+=0.05
		if bubble.by < 64 then
			del(bubbles,bubble)
		end
	end


	for splash in all(splashes) do
		local x = splash.x
		local y = splash.y
		local lt = splash.lt
		pset(x,y,12)
	end
end
__gfx__
00444400cccccccc1111111133333333000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
04444440cccccccc1111111133333333000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
11114440cccccccc1111111133333333000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
131f1440cccccccc1111111133333333000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
111f1140cccccccc1111111133333333000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0fffff40cccccccc1111111133333333000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0f777f00cccccccc1111111133333333000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
88fff880cccccccc1111111133333333000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
80888080077770000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
80888080700007000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
80888080707007000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
f01110f0700007000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00101000700007000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00101000077770000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00101000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00404000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00444000044444000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
04444400444444400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1111111044f444400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1c1f1c1044ff44400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
111f111044cfc4400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0f444f0044ffff400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0477740044777f400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
5444445014fff4100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
50444050141614100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
f05a50f0101610100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
f0a5a0f0106660100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
f05550f0f01610f00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00111000001110000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00101000005050000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00101000005050000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00505000001010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__label__
88888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888
88888eeeeee888888888888888888888888888888888888888888888888888888888888888888888888ff8ff8888228822888222822888888822888888228888
8888ee888ee88888888888888888888888888888888888888888888888888888888888888888888888ff888ff888222222888222822888882282888888222888
888eee8e8ee88888e88888888888888888888888888888888888888888888888888888888888888888ff888ff888282282888222888888228882888888288888
888eee8e8ee8888eee8888888888888888888888888888888888888888888888888888888888888888ff888ff888222222888888222888228882888822288888
888eee8e8ee88888e88888888888888888888888888888888888888888888888888888888888888888ff888ff888822228888228222888882282888222288888
888eee888ee888888888888888888888888888888888888888888888888888888888888888888888888ff8ff8888828828888228222888888822888222888888
888eeeeeeee888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111eee1eee11111616111111111cc11cc11ccc11111eee1ee11ee1111116661666166616661666111111111ccc11111eee1e1e1eee1ee11111111111111111
111111e11e11111116161777177711c111c1111c11111e1e1e1e1e1e111111611161166616111616177717771c1c111111e11e1e1e111e1e1111111111111111
111111e11ee1111116661111111111c111c11ccc11111eee1e1e1e1e111111611161161616611661111111111c1c111111e11eee1ee11e1e1111111111111111
111111e11e11111111161777177711c111c11c1111111e1e1e1e1e1e111111611161161616111616177717771c1c111111e11e1e1e111e1e1111111111111111
11111eee1e1111111666111111111ccc1ccc1ccc11111e1e1e1e1eee111111611666161616661616111111111ccc111111e11e1e1eee1e1e1111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
111111111bbb1bb11bb11171166616161666166616111666116611111177166616161111161611111c1c1111166616161111161611111c111771117111111111
111111111b1b1b1b1b1b1711161616161616161616111611161111111171161616161777161611711c1c1111161616161777161611711c111171111711111111
111111111bbb1b1b1b1b1711166116161661166116111661166611111771166111611111116117771ccc1111166116661111166617771ccc1177111711111111
111111111b1b1b1b1b1b171116161616161616161611161111161171117116161616177716161171111c1171161611161777111611711c1c1171111711111111
111111111b1b1bbb1bbb117116661166166616661666166616611711117716661616111116161111111c1711166616661111166611111ccc1771117111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111eee1ee11ee11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111e111e1e1e1e1111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111ee11e1e1e1e1111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111e111e1e1e1e1111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111eee1e1e1eee1111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
1eee1ee11ee111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
1e111e1e1e1e11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
1ee11e1e1e1e11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
1e111e1e1e1e11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
1eee1e1e1eee11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
1eee1e1e1ee111ee1eee1eee11ee1ee1111116661666161616661611111116161661166116661666111116161666166616661666117111661111166611711111
1e111e1e1e1e1e1111e111e11e1e1e1e111116161161161616111611111116161616161716111616111116161616116116111616171116111111161611171111
1ee11e1e1e1e1e1111e111e11e1e1e1e111116661161116116611611111116161616161771611661111116161666116116611661171116111111166111171111
1e111e1e1e1e1e1111e111e11e1e1e1e111116111161161616111611111116161616161777111616111116661616116116111616171116111171161611171111
1e1111ee1e1e11ee11e11eee1ee11e1e111116111666161616661666166611661616161777711616166616661616116116661616117111661711161611711111
11111111111111111111111111111111888881111111111111111111111111111111111771111111111111111111111111111111111111111111111111111111
11111eee1eee1eee1e1e1eee1ee111118bbb81bb1bbb1bbb11711bbb11bb1bbb1bbb1171171b1b111bbb11711171161611111166117111171ccc117111111bbb
11111e1e1e1111e11e1e1e1e1e1e11118b888b111b1111b117111bbb1b111b1111b117111b111b111b1b17111711161611711611111711711c1c111711111b11
11111ee11ee111e11e1e1ee11e1e11118bb88b111bb111b117111b1b1b111bb111b117111bb11b111bb117111711116117771611111711711ccc111711111bb1
11111e1e1e1111e11e1e1e1e1e1e11118b888b1b1b1111b117111b1b1b1b1b1111b117111b111b111b1b17111711161611711611111711711c1c111711711b11
11111e1e1eee11e111ee1e1e1e1e11118b888bbb1bbb11b111711b1b1bbb1bbb11b111711b111bbb1b1b11711171161611111166117117111ccc117117111b11
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
1eee1ee11ee111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
1e111e1e1e1e11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
1ee11e1e1e1e11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
1e111e1e1e1e11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
1eee1e1e1eee11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
1eee1e1e1ee111ee1eee1eee11ee1ee1111111111661166616661616117111711111111111111111111111111111111111111111111111111111111111111111
1e111e1e1e1e1e1111e111e11e1e1e1e111111111616161616161616171111171111111111111111111111111111111111111111111111111111111111111111
1ee11e1e1e1e1e1111e111e11e1e1e1e111111111616166116661616171111171111111111111111111111111111111111111111111111111111111111111111
1e111e1e1e1e1e1111e111e11e1e1e1e111111111616161616161666171111171111111111111111111111111111111111111111111111111111111111111111
1e1111ee1e1e11ee11e11eee1ee11e1e111116661666161616161666117111711111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
111111bb1b1111bb1171117111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111b111b111b111711111711111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111b111b111bbb1711111711111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111b111b11111b1711111711111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
111111bb1bbb1bb11171117111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111bbb1bbb1bbb11711ccc11111ccc11111ccc11111ccc11111cc11c1111111cc11c1111711111111111111111111111111111111111111111111111111111
11111bbb1b1b1b1b17111c1c11111c1c11111c1c11111c1c111111c11c11111111c11c1111171111111111111111111111111111111111111111111111111111
11111b1b1bbb1bbb17111c1c11111c1c11111c1c11111c1c111111c11ccc111111c11ccc11171111111111111111111111111111111111111111111111111111
11111b1b1b1b1b1117111c1c11711c1c11711c1c11711c1c117111c11c1c117111c11c1c11171111111111111111111111111111111111111111111111111111
11111b1b1b1b1b1111711ccc17111ccc17111ccc17111ccc17111ccc1ccc17111ccc1ccc11711111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
111111bb1bbb1bbb11711ccc111116161111161611111cc111111ccc117111111111111111111111111111111111111111111111111111111111111111111111
11111b111b1b1b1b17111c1c1111161611111616111111c11111111c111711111111111111111111111111111111111111111111111111111111111111111111
11111bbb1bbb1bb117111c1c1111116111111666111111c111111ccc111711111111111111111111111111111111111111111111111111111111111111111111
1111111b1b111b1b17111c1c1171161611711116117111c111711c11111711111111111111111111111111111111111111111111111111111111111111111111
11111bb11b111b1b11711ccc171116161711166617111ccc17111ccc117111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111eee11ee1eee1111166611111ccc11111cc11c1111111ee111ee111111111111111111111111111111111111111111111111111111111111111111111111
11111e111e1e1e1e1111161617771c1c111111c11c1111111e1e1e1e111111111111111111111111111111111111111111111111111111111111111111111111
11111ee11e1e1ee11111166111111c1c111111c11ccc11111e1e1e1e111111111111111111111111111111111111111111111111111111111111111111111111
11111e111e1e1e1e1111161617771c1c117111c11c1c11111e1e1e1e111111111111111111111111111111111111111111111111111111111111111111111111
11111e111ee11e1e1111161611111ccc17111ccc1ccc11111eee1ee1111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
111111111eee11ee1eee1111116611111ccc11111ccc11111ee111ee111111111111111111111111111111111111111111111111111111111111111111111111
111111111e111e1e1e1e1111161117771c1c11111c1c11111e1e1e1e111111111111111111111111111111111111111111111111111111111111111111111111
111111111ee11e1e1ee11111161111111c1c11111ccc11111e1e1e1e111111111111111111111111111111111111111111111111111111111111111111111111
111111111e111e1e1e1e1111161117771c1c11711c1c11111e1e1e1e111111111111111111111111111111111111111111111111111111111111111111111111
111111111e111ee11e1e1111116611111ccc17111ccc11111eee1ee1111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
1111111111111eee1eee11111ee111ee1eee11111666166616161666161111111616166116611666166611111616166616661666166611711166111116661171
11111111111111e11e1111111e1e1e1e11e111111616116116161611161111111616161616161611161611111616161611611611161617111611111116161117
11111111111111e11ee111111e1e1e1e11e111111666116111611661161111111616161616161661166111111616166611611661166117111611111116611117
11111111111111e11e1111111e1e1e1e11e111111611116116161611161111111616161616161611161611111666161611611611161617111611117116161117
1111111111111eee1e1111111e1e1ee111e111111611166616161666166616661166161616661666161616661666161611611666161611711166171116161171
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111e1111ee11ee1eee1e111111166616661616166616111111111111111bbb11bb1bbb1bbb1171161611111166111116161111166611711111
11111111111111111e111e1e1e111e1e1e111111161611611616161116111111177711111b1b1b111b1111b11711161611711611111116161171161611171111
11111111111111111e111e1e1e111eee1e111111166611611161166116111111111111111bbb1b111bb111b11711116117771611111116661777166111171111
11111111111111111e111e1e1e111e1e1e111111161111611616161116111111177711111b111b1b1b1111b11711161611711611117111161171161611171111
11111111111111111eee1ee111ee1e1e1eee1111161116661616166616661111111111111b111bbb1bbb11b11171161611111166171116661111161611711111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111eee1eee1111166616661616166616111111171111111cc111111eee1ee11ee111111666166616161666161111111171111111111ccc1111
111111111111111111e11e1111111616116116161611161111111171111111c111111e1e1e1e1e1e1111161611611616161116111111117117771111111c1111
111111111111111111e11ee111111666116111611661161111111117111111c111111eee1e1e1e1e1111166611611161166116111111117111111111111c1111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
88888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888
82888222822882228888822282228882822282228888888888888888888888888888888888888888888888888222822282228882822282288222822288866688
82888828828282888888888288828828828882888888888888888888888888888888888888888888888888888882888288828828828288288282888288888888
82888828828282288888822288228828822282228888888888888888888888888888888888888888888888888222822288228828822288288222822288822288
82888828828282888888828888828828888288828888888888888888888888888888888888888888888888888288828888828828828288288882828888888888
82228222828282228888822282228288822282228888888888888888888888888888888888888888888888888222822282228288822282228882822288822288
88888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888

__gff__
0001000000000000000000000000000000000000000000000000000000000000000000010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
0202020202020202020202020202020200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0202020202020202020202020202020200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0202020202020202020202020202020200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0202020202020202020202020202020200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0202020202020202020202020202020200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0202020202020202020202020202020200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0202020202020202020202020202020200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0202020202020202020202020202020200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0101010101010101010101010101010100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0101010101010101010101010101010100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0101010101010101010101010101010100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0101010101010101010101010101010100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0101010101010101010101010101010100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0101010101010101010101010101010100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0101010101010101010101010101010100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0101010101010101010101010101010100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
011e00001f0521f05224052240521f0521f0521c0521d0521f0521f05224052240521f0521f05200000000001f0521f05224052240521f0521f05224052240522805228052000002605224052230522105220052
011e00001f0521f05224052240521f0521f0521c0521d0521f0521f05224052240521f0521f052000000000024052240001f000210521f052000001d052000001c052000001a0520000018052260002400023000
__music__
00 00424344
00 00424344
00 01424344

