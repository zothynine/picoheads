pico-8 cartridge // http://www.pico-8.com
version 16
__lua__
--catfight

--sfx
-- 00 laser
-- 01 explosion

function _init()
  lvltim=180

  tim={
    game={
      m=0,
      s=0,
      f=0,
      str="0:0:0"
    },
    lvlstart=lvltim,
    cape=12,
    next_cloud=0
  }

  ui_h=8

  score=0

  clouds={}

  maps={
    gnd1_x=0,
    gnd2_x=128,
    plxa1_x=0,
    plxa2_x=128,
    plxb1_x=0,
    plxb2_x=128,
  }

  powerups_defs={
    {cat="shot", type="dbllaser",sx=28,sy=0,w=6,h=6},
    {cat="shot", type="trpllaser",sx=40,sy=0,w=6,h=6},
    {cat="shield", type="common",sx=34,sy=0,w=6,h=6,r=8,lt=3,col=7}
  }

  powerups={}

  -- die ascii
  ascii={
    x=56,
    y=55,
    ghost_x=60,
    ghost_y=100,
    w=8,
    h=7,
    shots={},
    collided=false,
    lives=8,
    cape={9,10,13},
    pwrups={},
    cooldwn=900,
    cdtim=900,
    hitbox={}
  }

  shots={}

  enemy_types={
    mouse={name="mouse",s={22,0,6,5}},
    rat={name="rat",s={16,0,6,5},shots={iv=2}},
    flea={name="flea",s={46,0,9,9},shots={iv=1}},
  }

  swarms={
    single={{0,0}},
    line4={{0,0},{10,0},{20,0},{30,0}},
    line6={{0,0},{10,0},{20,0},{30,0},{40,0},{50,0}},
    stack3={{0,0},{0,10},{0,-10}},
    stack5={{0,0},{0,10},{0,20},{0,-10},{0,-20}},
    tri_s={{0,0},{10,-5},{10,5},{20,-10},{20,0},{20,10}},
    tri_l={{0,0},{10,-5},{10,5},{20,-10},{20,0},{20,10},{30,-15},{30,-5},{30,5},{30,15}},
    circle={name="circle",r=15,n=8,a=0.125}
  }

  levels={
    {
      {tim="0:3:0",
        swarm=swarms.single,
        e_type=enemy_types.flea,
        path="linear",
        x=127,
        y=25,
        count=#swarms.line4,
        dirty=false,
        health=2,
        enemies={},
        stop=64},
      {tim="0:6:0",
        swarm=swarms.circle,
        e_type=enemy_types.rat,
        path="linear",
        x=127,
        y=90,
        count=swarms.circle.n,
        dirty=false,
        enemies={},
        stop=70},
      -- {tim="0:9:0",
      --   swarm=swarms.line4,
      --   e_type=enemy_types.mouse,
      --   path="linear",
      --   x=127,
      --   y=40,
      --   count=#swarms.line4,
      --   dirty=false,
      --   enemies={}},
      -- {tim="0:9:0",
      --   swarm=swarms.line4,
      --   e_type=enemy_types.mouse,
      --   path="linear",
      --   x=127,
      --   y=80,
      --   count=#swarms.line4,
      --   dirty=false,
      --   enemies={}},
      -- {tim="0:11:0",
      --   swarm=swarms.tri_s,
      --   e_type=enemy_types.mouse,
      --   path="linear",
      --   x=127,
      --   y=60,
      --   count=#swarms.tri_s,
      --   dirty=false,
      --   enemies={}},
      -- {tim="0:15:0",
      --   swarm=swarms.circle,
      --   e_type=enemy_types.rat,
      --   path="linear",
      --   x=128,
      --   y=60,
      --   count=swarms.circle.n,
      --   dirty=false,
      --   enemies={}},
      -- {tim="0:15:0",
      --   swarm=swarms.line6,
      --   e_type=enemy_types.rat,
      --   path="wave",
      --   x=128,
      --   y=30,
      --   count=#swarms.line6,
      --   dirty=false,
      --   enemies={}},
      -- {tim="0:15:0",
      --   swarm=swarms.line6,
      --   e_type=enemy_types.rat,
      --   path="wave",
      --   x=128,
      --   y=90,
      --   count=#swarms.line6,
      --   dirty=false,
      --   enemies={}},
      -- {tim="0:30:0",
      --   swarm=swarms.line6,
      --   e_type=enemy_types.mouse,
      --   path="slope",
      --   x=128,
      --   y=25,
      --   count=#swarms.line6,
      --   dirty=false,
      --   enemies={}},
      -- {tim="0:36:0",
      --   swarm=swarms.tri_s,
      --   e_type=enemy_types.mouse,
      --   path="circle",
      --   x=128,
      --   y=40,
      --   count=#swarms.tri_s,
      --   dirty=false,
      --   enemies={}},
      -- {tim="0:42:0",
      --   swarm=swarms.stack3,
      --   e_type=enemy_types.mouse,
      --   path="linear",
      --   x=128,
      --   y=60,
      --   count=#swarms.stack3,
      --   dirty=false,
      --   enemies={}},
      -- {tim="0:42:30",
      --   swarm=swarms.stack5,
      --   e_type=enemy_types.rat,
      --   path="linear",
      --   x=128,
      --   y=60,
      --   count=#swarms.stack5,
      --   dirty=false,
      --   enemies={}},
      -- {tim="0:45:0",
      --   swarm=swarms.circle,
      --   e_type=enemy_types.rat,
      --   path="linear",
      --   x=128,
      --   y=60,
      --   count=swarms.circle.n,
      --   dirty=false,
      --   enemies={}}
    }
  }

  enemy_waves={}

  _update60=update_start
  _draw=draw_start
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

function update_game_timer()
  tim.game.f+=1
  if tim.game.f==59 then
    tim.game.f=0
    tim.game.s+=1
  end
  if tim.game.s==59 then
    tim.game.s=0
    tim.game.m+=1
  end
  tim.game.str=tim.game.m..":"..tim.game.s..":"..tim.game.f
end

function shallowcopy(_orig, _kv)
  local _copy={}
  if _kv then
    for k,v in pairs(_orig) do
      _copy[k]=v
    end
  else
    for i=1,#_orig do
      add(_copy,_orig[i])
    end
  end

  return _copy
end

function setuplvl()
  tim.game={
    m=0,
    s=0,
    f=0,
    str="0:0:0"
  }
  enemy_waves=shallowcopy(levels[1])
  shots={}
  ascii.x=56
  ascii.y=55
  ascii.collided=false
  tim.lvlstart=lvltim
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
    _update60=update_lvlstart
    _draw=draw_lvlstart
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
--game start
function update_lvlstart()
  update_clouds()
  update_cape()
  tim.lvlstart -= 1
  if tim.lvlstart < 1 then
    setuplvl()
    _update60=update_game
    _draw=draw_game
  end
end

function draw_lvlstart()
  cls()
  rectfill(0,0,127,127,1)
  foreach(clouds,draw_cloud)
  draw_ascii(2)
  print_center("level 1", 84, 0)
  print_center("level 1", 85, 7)
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

function update_ascii(_shield)
  ascii.has_shield=_shield~=nil

  if ascii.has_shield then
    ascii.hitbox={
      x=ascii.x+(ascii.w/2)-_shield.r,
      y=ascii.y+(ascii.h/2)-_shield.r,
      w=_shield.r*2,
      h=_shield.r*2
    }
  else
    ascii.hitbox={
      x=ascii.x,
      y=ascii.y,
      w=ascii.w,
      h=ascii.h
    }
  end

  if btn(0) then
    --links ⬅️
    ascii.x=mid(0,ascii.x-1,127)
  elseif btn(1) then
    --rechts ➡️
    ascii.x=mid(0,ascii.x+1,120)
  elseif btn(2) then
    --oben ⬆️
    ascii.y=mid(ui_h+1,ascii.y-1,127)
  elseif btn(3) then
    --unten ⬇️
    ascii.y=mid(0,ascii.y+1,121)
  end
end

function get_powerup(_cat)
  for i=1,#ascii.pwrups do
    if (ascii.pwrups[i].cat==_cat) return ascii.pwrups[i]
  end
  return nil
end

function shoot()
  local _p=get_powerup("shot")
  local _shot_w=3
  if _p and _p.type=="dbllaser" then
    add(ascii.shots,{
      x=ascii.x+6,
      y=ascii.y+1,
      x_end=ascii.x+6+_shot_w,
      y_end=ascii.y+1,
      w=_shot_w,
      h=1,
      spd=2,
      dir=0
    })
    add(ascii.shots,{
      x=ascii.x+6,
      y=ascii.y+3,
      x_end=ascii.x+6+_shot_w,
      y_end=ascii.y+3,
      w=_shot_w,
      h=1,
      spd=2,
      dir=0
    })
  elseif _p and _p.type=="trpllaser" then
    add(ascii.shots,{
      x=ascii.x+6,
      y=ascii.y+1,
      x_end=ascii.x+9,
      y_end=ascii.y,
      w=3,
      h=1,
      spd=2,
      dir=-1
    })
    add(ascii.shots,{
      x=ascii.x+6,
      y=ascii.y+3,
      x_end=ascii.x+9,
      y_end=ascii.y+3,
      w=3,
      h=1,
      spd=2,
      dir=0
    })
    add(ascii.shots,{
      x=ascii.x+6,
      y=ascii.y+5,
      x_end=ascii.x+9,
      y_end=ascii.y+6,
      w=3,
      h=1,
      spd=2,
      dir=1
    })
  else
    add(ascii.shots,{
      x=ascii.x+6,
      y=ascii.y+2,
      x_end=ascii.x+9,
      y_end=ascii.y+2,
      w=3,
      h=1,
      spd=2,
      dir=0
    })
  end
  sfx(0)
end

function spawn_pwrup(_x, _y)
  local _chance=rnd(100) < 100
  local _i=ceil(rnd(#powerups_defs))
  local _p=shallowcopy(powerups_defs[_i],true)
  powerupdebug=powerups_defs[_i]
  _p.x=_x
  _p.y=_y
  if _chance then
    add(powerups, _p)
  end
end

function update_shots()
  for i=#ascii.shots,1,-1 do
    local _shot=ascii.shots[i]
    local _x=_shot.x
    local _p=get_powerup("shot")

    _shot.x+=_shot.spd
    _shot.x_end+=_shot.spd
    _shot.y=_shot.y_end
    _shot.y_end=_shot.y+_shot.dir

    -- delete shot when out of bounds
    if (_x>127) del(ascii.shots,_shot)

    for i=#enemy_waves,1,-1 do
      local _w=enemy_waves[i]

      for j=#_w.enemies,1,-1 do
        local _e=_w.enemies[j]
        if collision(_shot,_e) then
          if _e.health>1 then
            _e.health-=1
          else
            spawn_pwrup(_e.x, _e.y)
            delete_enemy(_w,_e)
            sfx(1)
            score+=1
          end
          del(ascii.shots,_shot)
        end
      end
    end
  end

  for i=#shots,1,-1 do
    local _shot=shots[i]
    local _x=_shot.x

    _shot.x+=_shot.dx
    _shot.y+=_shot.dy

    -- delete shot when out of bounds
    if (_x+_shot.w<0) del(shots,_shot)

    if collision(_shot,ascii.hitbox) then
      ascii_hit()
      del(shots,_shot)
      sfx(1)
    end
  end
end

function create_wave(_w)
  local _n=#_w.swarm
  if (_w.swarm.name=="circle") _n=_w.swarm.n
  local _x=0
  local _y=0
  for i=1,_n do
    local _a=nil
    if _w.swarm.name=="circle" then
      _a=i*_w.swarm.a
      _x=_w.x+_w.swarm.r*cos(_a)
      _y=_w.y+_w.swarm.r*sin(_a)
    else
      _x=_w.x+_w.swarm[i][1]
      _y=_w.y+_w.swarm[i][2]
    end

    if _w.path=="circle" then
      add(_w.enemies, {
        si=i,
        x=_x,
        y=_y,
        ox=127,
        oy=127,
        a=0.25-0.003,
        w=6,
        h=5,
        health=_w.health or 1,
        r=sqrt((_w.x-127)*(_w.x-127)+(127-_w.y)*(127-_w.y))})
    else
      add(_w.enemies, {
        si=i,
        x=_x,
        y=_y,
        ox=nil,
        oy=nil,
        a=_a,
        w=6,
        h=5,
        health=_w.health or 1,
        r=sqrt((_w.x-127)*(_w.x-127)+(127-_w.y)*(127-_w.y))})
    end
  end
end

function update_waves()
  for i=1,#enemy_waves do
    local _w=enemy_waves[i]
    if _w.tim==tim.game.str then
      if not _w.created then
        create_wave(_w)
        _w.created=true
      end
    end
  end
end

function delete_enemy(_w,_e)
  del(_w.enemies,_e)
  if (#_w.enemies==0) del(enemy_waves, _w)
end

function update_enemies()
  for i=#enemy_waves,1,-1 do
    local _w=enemy_waves[i]
    local _dirty = _w.dirty
    for j=#_w.enemies,1,-1 do
      if (j==#_w.enemies-1) _dirty=true
      local _e=_w.enemies[j]

      if _w.path=="linear" and _w.swarm.name=="circle" then
        if _e.x+_e.w<0 then
          delete_enemy(_w,_e)
        end
        if (not _dirty and _w.x>70) _w.x-=0.5
        _e.x=_w.x+_w.swarm.r*cos(_e.a)
        _e.y=_w.y+_w.swarm.r*sin(_e.a)
        
        if _w.x<=_w.stop then
          _w.stopped=true
          _e.a+=0.01
          _e.x=_w.x+_w.swarm.r*cos(_e.a)
          _e.y=_w.y+_w.swarm.r*sin(_e.a)
        end
      elseif _w.path=="linear" then
        if _e.x+_e.w<0 then
          delete_enemy(_w,_e)
        end
        
        if _w.stop and _w.x >= _w.stop then
          if (not _dirty) _w.x-=0.5
          _e.x=_w.x+_w.swarm[_e.si][1]
        elseif _w.stop and _w.x < _w.stop then
          _w.stopped=true
        end
      elseif _w.path=="wave" then
        if (_e.x+_e.w<0) delete_enemy(_w,_e)
        if (not _dirty) _w.x-=0.5
        local _wave_y=_w.y+(sin(_w.x/12)*10)
        _e.x=_w.x+_w.swarm[_e.si][1]
        _e.y=_wave_y+_w.swarm[_e.si][2]
      elseif _w.path=="slope" then
        if (_e.x+_e.w<0) delete_enemy(_w,_e)
        if _w.x<97 and _w.x>30 and _w.y<87 then
          if (not _dirty) _w.y+=0.4
        end
        if (not _dirty) _w.x-=0.5
        _e.x=_w.x+_w.swarm[_e.si][1]
        _e.y=_w.y+_w.swarm[_e.si][2]
      elseif _w.path=="circle" then
        if (_e.y>127) delete_enemy(_w,_e)
        _e.a+=0.003
        if (_e.a > 1) _e.a=0
        if (not _dirty) _w.x=_e.ox+_e.r*cos(_e.a)
        if (not _dirty) _w.y=_e.oy+_e.r*sin(_e.a)
        _e.x=_w.x+_w.swarm[_e.si][1]
        _e.y=_w.y+_w.swarm[_e.si][2]
      end

      if _w.e_type.shots then
        if (_w.stop and _w.stopped)
          or not _w.stop then
          if tim.game.s%_w.e_type.shots.iv==0
            and tim.game.f==0
            and _e.x < 128-_e.w then
            if _w.e_type.name=="flea" then
              add(shots,{x=_e.x+5,y=_e.y+5,w=4,h=1,dx=-1,dy=0})
              add(shots,{x=_e.x+5,y=_e.y+5,w=4,h=1,dx=-1,dy=-1})
              add(shots,{x=_e.x+5,y=_e.y+5,w=4,h=1,dx=0,dy=-1})
              add(shots,{x=_e.x+5,y=_e.y+5,w=4,h=1,dx=1,dy=-1})
              add(shots,{x=_e.x+5,y=_e.y+5,w=4,h=1,dx=1,dy=0})
              add(shots,{x=_e.x+5,y=_e.y+5,w=4,h=1,dx=1,dy=1})
              add(shots,{x=_e.x+5,y=_e.y+5,w=4,h=1,dx=0,dy=1})
              add(shots,{x=_e.x+5,y=_e.y+5,w=4,h=1,dx=-1,dy=1})
            else
              add(shots,{x=_e.x,y=_e.y+4,w=3,h=1,dx=-1,dy=0})
            end
          end
        end
      end
      if collision(_e,ascii.hitbox) then
        ascii_hit()
      end

      if ascii.collided then
        ascii.cdtim-=1

        if ascii.cdtim==0 then
          ascii.collided=false
          ascii.cdtim=ascii.cooldwn
        end
      end
    end
    _dirty=false
  end
end

function ascii_hit()
  local _shield=get_powerup("shield")
  if _shield and not ascii.collided then
    _shield.lt-=1
    ascii.collided=true
    if _shield.lt==0 then
      ascii.has_shield=false
      del(ascii.pwrups,_shield)
    end
  elseif not ascii.collided then
    ascii.lives-=1
    ascii.collided=true
  end

  if ascii.lives<0 then
    _update60=update_gover
    _draw=draw_gover
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
  if tim.next_cloud==0 then
    if (#clouds < 25) create_cloud()
    tim.next_cloud=flr(10+rnd(15))
  end

  for i=#clouds,1,-1 do
    local _cloud=clouds[i]
    _cloud.x-=_cloud.dx
    if (_cloud.x < (-8*_cloud.scl)) del(clouds,_cloud)
  end

  tim.next_cloud-=1
end

function update_map()
  maps.gnd1_x-=1
  maps.gnd2_x-=1
  maps.plxa1_x-=0.5
  maps.plxa2_x-=0.5
  maps.plxb1_x-=0.2
  maps.plxb2_x-=0.2
  if (maps.gnd1_x<=-128) maps.gnd1_x=128
  if (maps.gnd2_x<=-128) maps.gnd2_x=128
  if (maps.plxa1_x<=-128) maps.plxa1_x=128
  if (maps.plxa2_x<=-128) maps.plxa2_x=128
  if (maps.plxb1_x<=-128) maps.plxb1_x=128
  if (maps.plxb2_x<=-128) maps.plxb2_x=128
end

function update_cape()
  tim.cape-=1
  if tim.cape==8 then
    ascii.cape={10,13,9}
  elseif tim.cape==4 then
    ascii.cape={13,9,10}
  elseif tim.cape==0 then
    ascii.cape={9,10,13}
    tim.cape=12
  end
end

function update_pwrups()
  for i=#powerups,1,-1 do
    local _p=powerups[i]
    if collision(ascii,_p) then
      for i=#ascii.pwrups,1,-1 do
        if (ascii.pwrups[i].cat==_p.cat) del(ascii.pwrups,ascii.pwrups[i])
      end
      add(ascii.pwrups,_p)
      del(powerups,_p)
    end
  end
end

function update_game()
  update_game_timer()
  update_clouds()
  update_map()
  update_cape()
  update_waves()
  update_enemies()
  update_pwrups()

  if #enemy_waves==0 then
    _update60=update_lvlend
    _draw=draw_lvlend
  end

  update_ascii(get_powerup("shield"))

  if btnp(5) then
    shoot()
  end

  update_shots()
end

function draw_shots()
  for i=1,#ascii.shots do
    local _xs=ascii.shots[i].x
    local _ys=ascii.shots[i].y
    local _xe=ascii.shots[i].x_end
    local _ye=ascii.shots[i].y_end
    local _w=ascii.shots[i].w
    line(_xs,_ys,_xe,_ye,8)
  end

  for i=1,#shots do
    local _s=shots[i]
    local _x=_s.x
    local _y=_s.y
    local _dx=_s.dx
    local _dy=_s.dy
    local _w=_s.w
    line(_x,_y,_x+(_dx*_w),_y+(_dy*_w),11)
  end
end

function draw_cloud(cloud)
  sspr(o,8,9,6,cloud.x,cloud.y,9*cloud.scl,5*cloud.scl)
end

function draw_enemy(_w,_e)
  local _s=_w.e_type.s
  sspr(_s[1],_s[2],_s[3],_s[4],_e.x,_e.y)
end

function draw_infobar()
  rectfill(0,0,128,ui_h,2)
  sspr(13,0,3,4,2,2)
  print(ascii.lives,7,2,7)
  print_right(score,2,7,1)
end

function draw_ascii(_scale,_ghost)
  local _scale=_scale or 1
  local _ghost=_ghost or false

  if (ascii.has_shield) draw_shield(get_powerup("shield"))
  if ascii.collided
    and not ascii.has_shield
    and tim.game.f%5~=0 then
    return
  end

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

function draw_map()
  --parallax b
  map(0,10,maps.plxb1_x,80,16,6)
  map(0,10,maps.plxb2_x,80,16,6)
  --parallax a
  map(0,8,maps.plxa1_x,110,16,2)
  map(0,8,maps.plxa2_x,110,16,2)
  --ground
  map(0,15,maps.gnd1_x,120,16,1)
  map(0,15,maps.gnd2_x,120,16,1)
end

function draw_pwrups(_p)
  sspr(_p.sx,_p.sy,_p.w,_p.h,_p.x,_p.y)
end

function draw_shield(_shield)
  if _shield.lt==2 then
    _shield.col=9
  elseif _shield.lt==1 then
    _shield.col=8
  end
  if ascii.collided
    and tim.game.f%5~=0 then
    return
  else
    circ(ascii.x+(ascii.w/2),ascii.y+(ascii.h/2),_shield.r,_shield.col)
  end
end

function draw_game()
  cls()
  rectfill(0,0,127,127,1)
  draw_map()
  foreach(clouds,draw_cloud)
  draw_ascii()
  draw_shots()

  for i=1,#enemy_waves do
    local _w=enemy_waves[i]
    local _we=_w.enemies

    if #_we>0 then
      for j=1,#_we do
        draw_enemy(_w,_we[j])
      end
    end
  end

  draw_infobar()
  foreach(powerups, draw_pwrups)
end
-->8
--game over
function update_lvlend()
  update_clouds()
  update_cape()
  if (ascii.x < 128) ascii.x+=1

  if btn(5) then
    _update60=update_lvlstart
    _draw=draw_lvlstart
  end
end

function draw_lvlend()
  cls()
  rectfill(0,0,127,127,1)
  foreach(clouds,draw_cloud)
  draw_map()
  draw_infobar()
  draw_ascii()
  print_center("level 1 finished", 49, 0)
  print_center("level 1 finished", 50, 7)
  print_center("press x to continue", 59, 0)
  print_center("press x to continue", 60, 7)
end
-->8
--game over

function update_gover()
  update_game_timer()
  update_clouds()
  ascii.x=60
  ascii.y=100
  ascii.ghost_y-=0.6
  ascii.ghost_x=ascii.x+(sin(ascii.ghost_y/12)*10)

  if btn(5) then
    _init()
    _update60=update_lvlstart
    _draw=draw_lvlstart
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
  if ascii.ghost_y >= -7 then
    draw_ascii(2,true)
  else
    draw_ascii(2)
  end
end
__gfx__
00000000000007075000057000070099000066000022005000500050000000000000000000000000000000000000000000000000000000000000000000000000
00000000dd0007775555557777770988900677600288200505550500000000000000000000000000000000000000000000000000000000000000000000000000
00700700a8888b7b5855857477479888896777762888820057775000000000000000000000000000000000000000000000000000000000000000000000000000
00077000988777770555500777709888896777762888820577777500000000000000000000000000000000000000000000000000000000000000000000000000
00077000077777700055000077000988900677600288205577777550000000000000000000000000000000000000000000000000000000000000000000000000
00700700070000700000000000000099000066000022000577777500000000000000000000000000000000000000000000000000000000000000000000000000
00000000700007000000000000000000000000000000000057775000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000505550500000000000000000000000000000000000000000000000000000000000000000000000000
00677770000000000000000000000000000000000000005000500050000000000000000000000000000000000000000000000000000000000000000000000000
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
00000000000000000000000000333300000000000000000033333333000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000033333333333333330000000033333333000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000333330000033333333333333330000000033333333000000000000000000000000000000000000000000000000000000000000000000000000
00000000000003333333300033333333333333330000000033333333000000000000000000000000000000000000000000000000000000000000000000000000
000000000003b3333333330033333333333333330000000033333333000000000000000000000000000000000000000000000000000000000000000000000000
00000000033333333333333033333333333333330000000033333333000000000000000000000000000000000000000000000000000000000000000000000000
0000000033b333333333333333333333333333333333333333333333000000000000000000000000000000000000000000000000000000000000000000000000
00000000333333333333333333333333333333333333333333333333000000000000000000000000000000000000000000000000000000000000000000000000
__map__
2121212121212121212121212121212100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
5452555154525551545352555152515400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
5656565656565656565656565656565600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000464700000000000000004647000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000414200000000000000004142000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0044434345000046470000444343450000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0041434342000041420000414343420000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4443434343454443434544434343434500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4040404040404040404040404040404000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
000200003205032050320502f050270502305023000100000c00014000110000e0000d0000b0000b0000a00008000000000600005000060000600006000060000000000000000000000000000000000000000000
000a00000a6731f6401f6401f6301363013630136200a6200a6100a61000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
