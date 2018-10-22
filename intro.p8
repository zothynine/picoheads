pico-8 cartridge // http://www.pico-8.com
version 16
__lua__
--picoheads intro

function _init()
	--texts
	text={
		ln1="",
		ln2="",
		ln3="",
		ln4="",
		txt1="wir entwickeln",
		txt2="presented by picoheads",
		txt3="episode #8:",
		txt4="jetzt aber ernsthaft",
		x=10,
		ln1_y=15,
		ln2_y=26,
		ln3_y=98,
		ln4_y=112,
		speed=5,
		⧗=5
	}
	
	--cursor
	cur={
		x=-10,
		y=-10,
		c=8,
		blink=30
	}
	--avatars
	mspr=1
	ml="mario"
	mx=-7-(#ml*4)
	mtx=38
	kl="klemens"
	kspr=2
	kx=128+(#kl*4)
	ktx=78
	avy=50
	av_done=false
	⧗={
		ending=120,
		cur=30,
		glitches=80
	}
	
	music(0)
end

--function center_text(_t)
--	return (128-(#_t*4))/2
--end

function _update60()
	⧗.cur-=1
	if (⧗.cur==0) ⧗.cur=cur.blink
	
	--cursor blinking
	if ⧗.cur<cur.blink/2 then
		cur.c=1
	else
		cur.c=8
	end
	
	--typing timer
	text.⧗-=1
	if (text.⧗==0) then
		text.⧗=text.speed+flr(rnd(10))
	end
	
	--title animation
	if #text.ln1<#text.txt1 then
		if text.⧗==1 then
			text.ln1=sub(text.txt1,0,#text.ln1+1)
		end
		cur.x = text.x+#text.ln1*4
		cur.y = text.ln1_y-1
	
	elseif #text.ln2<#text.txt2 then
		if text.⧗==1 then
			text.ln2=sub(text.txt2,0,#text.ln2+1)
		end
		cur.x = text.x+#text.ln2*4
		cur.y = text.ln2_y-1
	else
		titles_done=true
	end
	
	--avatars animation
	if titles_done then
		if not av_done then
			local mdx=((mtx-mx)/4)*0.4
			local kdx=((kx-ktx)/4)*0.4
			mx+=mdx
			kx-=kdx
 		if (mdx==0
 					and kdx==0) then
				av_done=true
 		end
		end
	end
	
	if av_done then
		if #text.ln3<#text.txt3 then
			if text.⧗==1 then
				text.ln3=sub(text.txt3,0,#text.ln3+1)
			end
			cur.x = text.x+#text.ln3*4
			cur.y = text.ln3_y-1
		elseif #text.ln4<#text.txt4 then
			if text.⧗==1 then
				text.ln4=sub(text.txt4,0,#text.ln4+1)
			end
			cur.x = text.x+#text.ln4*4
			cur.y = text.ln4_y-1
		end
	end
		
	--ending
	if #text.ln4==#text.txt4 then
		if ⧗.ending>0 then
			⧗.ending-=1
		end
	end		
end

function _draw()
	cls()
	rectfill(0,0,127,127,1)
	rectfill(cur.x,cur.y,cur.x+4,cur.y+5,cur.c)
	print(text.ln1,text.x,text.ln1_y,6) --title
	print(text.ln2,text.x,text.ln2_y,6) --tagline
	print(text.ln3,text.x,text.ln3_y,6) --tagline
	print(text.ln4,text.x,text.ln4_y,6) --tagline
	--mario
	sspr(8,0,7,16,mx,avy)
	print(ml,mx-(#ml*2)+3,avy+18,6)
	--klemens
	sspr(16,0,7,16,kx,avy)
	print(kl,kx-(#kl*2)+3,avy+18,6)

	if ⧗.ending==0 then
		
		if (⧗.glitches>0) ⧗.glitches-=1
		
		if ⧗.glitches==79 then
			music(2)
		elseif ⧗.glitches==40 then
			poke(0x5f2c, 1) -- horizontal stretch, 64x128
		elseif ⧗.glitches==30 then
			poke(0x5f2c, 2) -- vertical stretch, 128x64
		elseif ⧗.glitches > 0 then
			pal(flr(rnd(16)),flr(rnd(16)))
		end
	end
end
__gfx__
00000000004444000044400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000044444400444440000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700111144401111111000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000131f14401c1f1c1000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000111f1140111f111000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
007007000fffff400f444f0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000f777f000477740000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000055fff5505444445000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000505550505044405000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000050555050f05a50f000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000050555050f0a5a0f000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000f0ccc0f0f05550f000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000c0c00000ccc00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000c0c00000c0c00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000c0c00000c0c00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000004040000050500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
01100000100333270510033144002d6330400332705140001003314000327053e2002d6331400032705110001003314000327050f0002d63314000327050c0001003314000327050c1002d63314000327022d633
01100000030500f00503055030500f005030550f0050f005030500f005030553e200030500f0050305511000030500f005030550f0000f005030500f00503055030500f005030550c1000f005140001d00500000
011000001d5501b5501d5502055020550195001d5501b5501d55022550225501a5001d5501d55019500185001d5501b5501d55020550205501f5001d5501b5501d55022550225502450024550245500050000500
01100000167532a155162530635416155164541d453140521f0000c3000730005300073000e30013300153000d000183001a3001d300183000e30009300073000d0000c30011300133001330016300183001b300
01100000155521335314452125531035513052114530e0540015000150001500015000150001500015000155183000e30009300073000d0000c30011300133001330016300183001b30000000000000000000000
01100000137551725616557117550e5560f1570c555124560d0070d0000d0000d0000d0000d0000d0000d0000d0000d0000d0000d0000d0000d0000d0000d0000070000700007000070000700007000070000700
01100000362532a355064530625406555367541165411650116501165011600116501165011650116501165500000000000000000000000000000000000000000000000000000000000000000000000000000000
0110000030100301000c30011300133000c3000015100151001510015100151001510015100151001510015100151001510910005100051000510005100051000520005200052000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__music__
01 00014243
02 00010243
04 03050406
04 04050607
04 04050607
00 00000000
00 00000000
00 00000000
00 00000000
00 00000000
00 00000000
00 00000000
00 00000000
00 00000000
00 00000000
00 00000000
00 00000000
00 00000000
00 00000000
00 00000000
00 00000000
00 00000000
00 00000000
00 00000000
00 00000000
00 00000000
00 00000000
00 00000000
00 00000000
00 00000000
00 00000000
00 00000000
00 00000000
00 00000000
00 00000000
00 00000000
00 00000000
00 00000000
00 00000000
00 00000000
00 00000000
00 00000000
00 00000000
00 00000000
00 00000000
00 00000000
00 00000000
00 00000000
00 00000000
00 00000000
00 00000000
00 00000000
00 00000000
00 00000000
00 00000000
00 00000000
00 00000000
00 00000000
00 00000000
00 00000000
00 00000000
00 00000000
00 00000000
00 00000000

