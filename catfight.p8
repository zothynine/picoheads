pico-8 cartridge // http://www.pico-8.com
version 18
__lua__
--catfight

--sfx
-- 00 laser
-- 01 explosion
-- 02 explosion low
-- 03 hit by bullet (not exploding)
-- 15 vaccuming

--todo
  --sfx bei explosions als parameter
  --sounds generell (bis slot 15)
    --gegner schuesse
    --verschiedene projektile
  --musik (ab slot 16)
  --3 leveldefinitionen
  --wave wird aktiv wenn vorige wave weg
    --screen verlassen oder komplett abgeschossen
  --vulkanausbrueche bei den bergen

-- ❎🅾️⬆️⬇️⬅️➡️

function _init()
  debug=""

  lvltim=180

  tim={
    f=0,
    game={
      m=0,
      s=0,
      f=0,
      str="0:0:0"
    },
    lvlstart=lvltim,
    cape=12,
    next_cloud=0,
    credits=600
  }

  cam={
    x=0,
    y=0,
    d=1,
    t=0
  }

  -- height of the top info bar
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
    gnd_spd=0.5
  }

  powerups_defs={
    {cat="shot", type="dbllaser",sx=28,sy=0,w=6,h=6},
    {cat="shot", type="trpllaser",sx=40,sy=0,w=6,h=6},
    {cat="shield", type="common",sx=34,sy=0,w=6,h=6,r=10,lt=3,col=7}
  }

  powerups={}

  -- die ascii
  ascii={
    x=56,
    y=55,
    ghost_x=60,
    ghost_y=100,
    w=14,
    h=9,
    shots={},
    collided=false,
    lives=8,
    cape={9,10,13},
    pwrups={},
    cooldwn=180,
    cdtim=180,
    hitbox={},
    spd={x=1,y=1},
    keypress=true
  }

  shots={}

  enemy_types={
    mouse={name="mouse",s={77,0,11,8}},
    rat={name="rat",s={64,0,12,8},shots={iv=2,unit="s"}},
    flea={name="flea",s={46,0,9,9},shots={iv=1,unit="s"}},
    cannon={name="cannon",s={89,0,9,10},shots={iv=15,unit="f"}}
  }

  swarms={
    line={name="line"},
    stack={name="stack"},
    tri={name="tri"},
    circle={name="circle",r=15,n=8,a=0.125}
  }

  levels={
    {
      {tim="0:3:0",
        swarm=swarms.stack,
        e_type=enemy_types.rat,
        path="linear",
        x=127,
        y=24,
        count=5,
        dirty=false,
        health=2,
        enemies={},
        stop=30},
      {tim="0:9:0",
        swarm=swarms.line,
        e_type=enemy_types.cannon,
        path="floor",
        x=127,
        y=120-enemy_types.cannon.s[4],
        count=1,
        dirty=false,
        health=5,
        enemies={}},
    }
  }

  cur_lvl=1

  boss={
    nozzle={x=95,y=52,w=3,h=8,oy=-12,ox=-5},
    hose={x=98,y=56,w=2,h=8,oy=-8,ox=-2},
    body={x=100,y=60,w=16,h=8,oy=-4,ox=0},
    active=false,
    maxhealth=100,
    health=3,
    dying=600,
    t={
      idle=119+ceil(rnd(120)),
      fire=479+ceil(rnd(240)),
      vacuum=200
    },
    t_names={
      "idle",
      "fire",
      "vacuum"
    },
    timer=119+ceil(rnd(120)),
    state=1,
    shots={},
    shots_tim={iv=30,unit="f"},
    dy=-0.5,
    dx=0,
    ay=64,
    ax=100,
    vacuum_force=0
  }

  enemy_waves={}

  particles={}

  fade_i=0
  fadeout_table={
    {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
    {1,1,1,1,1,1,1,0,0,0,0,0,0,0,0},
    {2,2,2,2,2,2,1,1,1,0,0,0,0,0,0},
    {3,3,3,3,3,3,1,1,1,0,0,0,0,0,0},
    {4,4,4,2,2,2,2,2,1,1,0,0,0,0,0},
    {5,5,5,5,5,1,1,1,1,1,0,0,0,0,0},
    {6,6,13,13,13,13,5,5,5,5,1,1,1,0,0},
    {7,6,6,6,6,13,13,13,5,5,5,1,1,0,0},
    {8,8,8,8,2,2,2,2,2,2,0,0,0,0,0},
    {9,9,9,4,4,4,4,4,4,5,5,0,0,0,0},
    {10,10,9,9,9,4,4,4,5,5,5,5,0,0,0},
    {11,11,11,3,3,3,3,3,3,3,0,0,0,0,0},
    {12,12,12,12,12,3,3,1,1,1,1,1,1,0,0},
    {13,13,13,5,5,5,5,1,1,1,1,1,0,0,0},
    {14,14,14,13,4,4,2,2,2,2,2,1,1,0,0},
    {15,15,6,13,13,13,5,5,5,5,5,1,1,0,0}
  }

  won_y=35
  score_y=92
  credit_y=128

  _update60=update_start
  _draw=draw_start
end

function fade(i)
  for c=0,15 do
    if flr(i+1)>=16 then
      pal(c,0)
    else
      pal(c,fadeout_table[c+1][flr(i+1)])
    end
  end
end

function update_particles()
  for i=#particles,1,-1 do
    local _p=particles[i]
    if _p.t=="dust" then
      _p.lt-=1
      _p.x=boss.nozzle.x-_p.lt
      _p.y=boss.nozzle.y+_p.oy
    elseif _p.t=="explosion" then
      _p.lt-=1
      _p.x=_p.x+_p.dx
      _p.y=_p.y+_p.dy
    end

    if (_p.pt=="circ") _p.r=max(0,_p.r-0.06)
    if (_p.lt<=0) del(particles,_p)
  end
end

function draw_particles()
  for i=1,#particles do
    local _p=particles[i]
    if _p.pt=="px" then
      pset(_p.x,_p.y,_p.col)
    elseif _p.pt=="circ" then
      circfill(_p.x,_p.y,_p.r,_p.col)
    end
  end
end

function update_cam()
  if cam.t==0 then
    cam.x=0
    cam.y=0
    return
  end

  local _td=cam.t/10
  cam.t-=1
  cam.x=cam.x*cam.d+_td
  cam.y=cam.y*cam.d+_td
  cam.d*=-1
end

function camshake(_dur)
  _dur=_dur or 30
  cam.t=_dur
end


function explosion(_x,_y,_c,_bs,_blt,_type,_sfx)
  _c=_c or 10 --particle count
  _bs=_bs or -2 --base speed
  _blt=_blt or 30 --base lifetime
  _sfx=_sfx or 1 --slot number of sfx to play
  local _t=_type or "px" --px, circ

  for i=1,_c do
    add(particles,{
      x=_x,
      y=_y,
      r=3,
      dx=_bs+rnd(abs(_bs)*2),
      dy=_bs+rnd(abs(_bs)*2),
      col=8+flr(rnd(3)),
      lt=_blt+flr(rnd(_blt+1)),
      t="explosion",
      pt=_t
    })

    sfx(_sfx)
  end
end

function get_print_x(_txt)
  local _t=tostr(_txt)
  return 64-(#_t*2)
end

function print_center(_txt,_y,_c,_r)
  local _t=tostr(_txt)
  local _txt_x=get_print_x(_txt)
  if (_r) draw_ribbon(_txt_x,_y,#_t*4)
  print(_txt,_txt_x,_y,_c)
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

function ascii_goto(_x,_y)
  ascii.keypress=false
  if (ascii.x < _x) ascii.x+=1
  if (ascii.y < _y) ascii.y+=1
  if (ascii.x > _x) ascii.x-=1
  if (ascii.y > _y) ascii.y-=1
end

function setuplvl()
  tim.game={
    m=0,
    s=0,
    f=0,
    str="0:0:0"
  }
  if cur_lvl>#levels then
    _update60=update_bosslvl
    _draw=draw_bosslvl
    boss.active=true
  else
    enemy_waves=shallowcopy(levels[cur_lvl])
  end
  tim.lvlstart=lvltim
  reset_state()
end

function reset_state()
  powerups={}
  shots={}
  ascii.shots={}
  ascii.x=56
  ascii.y=55
  ascii.collided=false
  ascii.keypress=true
end

function _update60()
end

function _draw()
end
-->8
--start

function update_start()
  tim.f=(tim.f+1)%60
  update_clouds()
  update_map()
  update_cape()
  if btn(5) then
    _update60=update_lvlstart
    _draw=draw_lvlstart
  end
end

function print_shadow(_txt,_x,_y,_col,_anim,_center)
  if (_center) _x=get_print_x(_txt)

  print(_txt,_x,_y+1,0)
  if _anim then

    if tim.f<30 then
      print(_txt,_x,_y,_col)
    else
      print(_txt,_x,_y+1,_col)
    end
  else

    print(_txt,_x,_y,_col)
  end
end

function draw_ribbon(_txt_x,_txt_y,_txt_l)
  local _x=_txt_x-13
  local _y=_txt_y-3
  --ribbon with shadow
  pal(12,0)
  pal(14,0)
  sspr(0,48,10,14,_x,_y+2)
  sspr(10,48,1,15,_x+10,_y+2,_txt_l+5,15)
  sspr(39,48,10,14,_x+_txt_l+15,_y+2)
  pal(12,12)
  pal(14,14)
  sspr(0,48,10,14,_x,_y)
  sspr(10,48,1,15,_x+10,_y,_txt_l+5,15)
  sspr(39,48,10,14,_x+_txt_l+15,_y)
end

function draw_start()
  cls()
  rectfill(0,0,127,127,1)
  pal(5,0)
  pal(6,0)
  pal(7,0)
  pal(13,0)
  foreach(clouds,draw_cloud)
  draw_map({l1=true})
  pal()
  rectfill(0,119,127,127,0) --black floor
  print_center("catfight",36,7,true)
  draw_ascii()
  print_shadow("press   to start",0,84,7,false,true)
  print_shadow("❎",54,84,7,true,false)
  print(debug,15,20,8)
end
-->8
--game start
function update_lvlstart()
  tim.f=(tim.f+1)%60
  update_clouds()
  update_cape()
  ascii.x=56
  ascii.y=55
  tim.lvlstart -= 1
  if tim.lvlstart < 1 then
    setuplvl()
    if cur_lvl>#levels then
      _update60=update_bosslvl
      _draw=draw_bosslvl
    else
      _update60=update_game
      _draw=draw_game
    end
  end
end

function draw_lvlstart()
  cls()
  rectfill(0,0,127,127,1)
  foreach(clouds,draw_cloud)
  draw_ascii()
  local _txt="level "..cur_lvl
  if cur_lvl>#levels then
    _txt="boss battle"
  end
  print_center(_txt,35,7,true)
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

function boss_collision(_thing)
  if (not boss.active) return
  return collision(_thing, boss.nozzle) or
  collision(_thing, boss.hose) or
  collision(_thing, boss.body)
end

function update_ascii(_shield)
  ascii.has_shield=_shield~=nil
  ascii.spd.x=1

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

  if ascii.keypress then
    if btn(0) then
      --links ⬅️
      ascii.x=mid(0,ascii.x-ascii.spd.x,127)
    end
    if btn(1) then
      --rechts ➡️
      ascii.x=mid(0,ascii.x+1,120)
    end
    if btn(2) then
      --oben ⬆️
      ascii.y=mid(ui_h+12,ascii.y-1,127)
    end
    if btn(3) then
      --unten ⬇️
      ascii.y=mid(0,ascii.y+1,110)
    end
  end

  if ascii.collided then
    ascii.cdtim-=1

    if ascii.cdtim==0 then
      ascii.collided=false
      ascii.cdtim=ascii.cooldwn
    end
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
        local _sfx=1
        if _w.e_type.name=="cannon" then
          _sfx=2
        end
        if collision(_shot,_e) then
          if _e.health>1 then
            _e.health-=1
            sfx(3)
          else
            spawn_pwrup(_e.x, _e.y)
            explosion(_e.x+(_e.w/2),_e.y+(_e.h/2),10,-2,30,"px",_sfx)
            camshake(10)
            delete_enemy(_w,_e)
            score+=1
          end
          del(ascii.shots,_shot)
        end
      end
    end

    if boss.active then
      if collision(_shot,boss.nozzle) then
        explosion(_shot.x, _shot.y,4,-1,5)
        camshake(3)
        del(ascii.shots,_shot)
        if (boss.health>0) then
          sfx(3)
          boss.health-=1
        end
        score+=1
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

function update_enemy(_w, _i)
  if _w.swarm.name=="line" then
    _x=_w.x+(_i-1)*10
    _y=_w.y
    return _x,_y
  elseif _w.swarm.name=="stack" then
    _x=_w.x
    _y=_w.y+(_i-1)*10
    return _x,_y
  elseif _w.swarm.name=="tri" then
    row=flr((sqrt(8*_i-7)-1)/2)
    _x=_w.x+row*10
    _y=_w.y+(row*(row+2)-2*_i+2)*5
    return _x,_y
  end
end

function create_wave(_w)
  local _n=_w.count
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
      _x,_y = update_enemy(_w, i)
    end

    if _w.path=="circle" then
      add(_w.enemies, {
        si=i,
        x=_x,
        y=_y,
        ox=127,
        oy=127,
        a=0.25-0.003,
        w=_w.e_type.s[3],
        h=_w.e_type.s[4],
        health=_w.health or 1,
        r=sqrt((_w.x-127)*(_w.x-127)+(127-_w.y)*(127-_w.y))})
    elseif _w.path=="floor" then
      add(_w.enemies,{
        si=i,
        x=_x,
        y=_y,
        ox=nil,
        oy=nil,
        a=_a,
        w=_w.e_type.s[3],
        h=_w.e_type.s[4],
        health=_w.health or 1
      })
    else
      add(_w.enemies,{
        si=i,
        x=_x,
        y=_y,
        ox=nil,
        oy=nil,
        a=_a,
        w=_w.e_type.s[3],
        h=_w.e_type.s[4],
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
        if (_e.x+_e.w<0) delete_enemy(_w,_e)

        if not _dirty then
          if _w.stop and _w.x < _w.stop then
            _w.stopped=true
          else
            _w.x-=0.5
          end
        end
        _e.x,_e.y=update_enemy(_w,_e.si)
      elseif _w.path=="wave" then
        if (_e.x+_e.w<0) delete_enemy(_w,_e)
        if (not _dirty) _w.x-=0.5
        local _wave_y=_w.y+(sin(_w.x/12)*10)
        _e.x,_e.y=update_enemy(_w,_e.si)
      elseif _w.path=="slope" then
        if (_e.x+_e.w<0) delete_enemy(_w,_e)
        if _w.x<97 and _w.x>30 and _w.y<87 then
          if (not _dirty) _w.y+=0.4
        end
        if (not _dirty) _w.x-=0.5
        _e.x,_e.y=update_enemy(_w,_e.si)
      elseif _w.path=="circle" then
        if (_e.y>127) delete_enemy(_w,_e)
        _e.a+=0.003
        if (_e.a > 1) _e.a=0
        if (not _dirty) _w.x=_e.ox+_e.r*cos(_e.a)
        if (not _dirty) _w.y=_e.oy+_e.r*sin(_e.a)
        _e.x,_e.y=update_enemy(_w,_e.si)
      elseif _w.path=="floor" then
        if (_e.x+_e.w<0) delete_enemy(_w,_e)
        if (not _dirty) _w.x-=maps.gnd_spd
        _e.x,_e.y=update_enemy(_w,_e.si)
      end

      if _w.e_type.shots then
        if (_w.stop and _w.stopped)
          or not _w.stop then
          if tim.game[_w.e_type.shots.unit]%_w.e_type.shots.iv==0
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
            elseif _w.e_type.name=="cannon" then
              add(shots,{x=_e.x+4,y=_e.y+1,w=2,h=4,dx=0,dy=-1,c=2,type="ball"})
            else
              add(shots,{x=_e.x,y=_e.y+5,w=3,h=1,dx=-1,dy=0})
            end
          end
        end
      end
      if collision(_e,ascii.hitbox) then
        ascii_hit()
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
    ascii.collided=false
    ascii.cdtim=ascii.cooldwn
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
  local _m=maps
  _m.gnd1_x-=_m.gnd_spd
  _m.gnd2_x-=_m.gnd_spd
  _m.plxa1_x-=_m.gnd_spd/2
  _m.plxa2_x-=_m.gnd_spd/2
  _m.plxb1_x-=_m.gnd_spd/4
  _m.plxb2_x-=_m.gnd_spd/4
  if (_m.gnd1_x<=-128) _m.gnd1_x=128
  if (_m.gnd2_x<=-128) _m.gnd2_x=128
  if (_m.plxa1_x<=-128) _m.plxa1_x=128
  if (_m.plxa2_x<=-128) _m.plxa2_x=128
  if (_m.plxb1_x<=-128) _m.plxb1_x=128
  if (_m.plxb2_x<=-128) _m.plxb2_x=128
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
  tim.f=(tim.f+1)%60
  update_game_timer()
  update_clouds()
  update_particles()
  update_map()
  update_cape()
  update_waves()
  update_enemies()
  update_pwrups()
  update_cam()

  if #enemy_waves==0 and cur_lvl<=#levels and #particles == 0 then
    _update60=update_lvlend
    _draw=draw_lvlend
  end

  update_ascii(get_powerup("shield"))

  if btnp(5) and ascii.keypress then
    shoot()
  end

  update_shots()
end

function update_boss()
  tim.f=(tim.f+1)%60
  if boss.timer > 0 then
    boss.timer-=1
  elseif boss.timer==0 then
    boss.vacuum_force=0
    boss.state=boss.state%3+1
    boss.timer=boss.t[boss.t_names[boss.state]]
  end

  if boss.ay<24 or boss.ay>116 then
    boss.dy*=-1
  end

  if boss.active then
    boss.body.y=boss.ay+boss.body.oy
    boss.nozzle.y=boss.ay+boss.nozzle.oy
    boss.hose.y=boss.ay+boss.hose.oy
    boss.body.x=boss.ax+boss.body.ox
    boss.nozzle.x=boss.ax+boss.nozzle.ox
    boss.hose.x=boss.ax+boss.hose.ox
    boss.ay+=boss.dy
    boss.ax+=boss.dx

    if boss.state ~= 3 then
      snd2=false
      sfx(-2,2)
    end

    if boss.state==2 then --shooting
      if tim.game[boss.shots_tim.unit]%boss.shots_tim.iv==0 then
        add(boss.shots,{
          x=boss.nozzle.x-6,
          y=boss.nozzle.y+3,
          x_end=boss.nozzle.x-1,
          y_end=boss.nozzle.y+4,
          w=5,
          h=2,
          spd=2,
          dir=0
        })
      end
    elseif boss.state==3 then --vacuuming
      if (not snd2) sfx(15,2)
      snd2=true
      if boss.vacuum_force < 3 then
        boss.vacuum_force+=0.01
      end
      update_vacuuming()
    end
  end

  if boss_collision(ascii.hitbox) then
    ascii_hit()
  end

  if boss.health<=0 and boss.active then
    boss.active=false
    sfx(-2,2)
    score+=100
  end
end

function update_vacuuming()
  ascii.spd.x=max(1,boss.vacuum_force-0.1)
  ascii.x=mid(0,ascii.x+boss.vacuum_force,105)
  ascii.y-=sgn(ascii.y-boss.nozzle.y)*0.5

  if #particles<8 and tim.game.f%10==0 then
    local _lt=flr(rnd(21))
    local _oy=ceil(rnd(boss.nozzle.h))

    add(particles,{
      x=boss.nozzle.x-_lt,
      y=boss.nozzle.y+_oy,
      dx=1,
      dy=0,
      oy=_oy,
      col=6,
      lt=_lt,
      t="dust",
      pt="px"
    })
  end
end

function update_bossfire()
  for i=#boss.shots,1,-1 do
    local _shot=boss.shots[i]
    _shot.x-=_shot.spd
    _shot.x_end-=_shot.spd

    if collision(_shot,ascii.hitbox) then
      ascii_hit()
    end
  end
end

function update_bosslvl()
  update_game_timer()
  update_clouds()
  update_map()
  update_particles()
  update_cape()
  update_pwrups()
  update_cam()

  update_ascii(get_powerup("shield"))

  update_boss()
  update_bossfire()

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
    local _c=_s.c or 11
    local _t=_s.type or "laser"
    if _t=="ball" then
      circfill(_x,_y,2.5,_c)
    else
      line(_x,_y,_x+(_dx*_w),_y+(_dy*_w),_c)
    end
  end

  for i=1,#boss.shots do
    local _xs=boss.shots[i].x
    local _ys=boss.shots[i].y
    local _xe=boss.shots[i].x_end
    local _ye=boss.shots[i].y_end
    local _w=boss.shots[i].w
    rectfill(_xs,_ys,_xe,_ye,8)
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

function draw_ascii(_ghost)
  local _scale=1
  local _ghost=_ghost or false

  if (ascii.has_shield) draw_shield(get_powerup("shield"),_scale)
  if ascii.collided
    and not ascii.has_shield
    and tim.game.f%5~=0 then
    return
  end

  pal(ascii.cape[1],8)
  palt(ascii.cape[2],true)
  palt(ascii.cape[3],true)
  sspr(98,0,ascii.w,ascii.h,ascii.x,ascii.y,ascii.w*_scale,ascii.h*_scale)
  if _ghost then
    pal(7,6)
    pal(9,6)
    pal(7,6)
    pal(8,6)
    pal(4,6)
    pal(11,6)
    palt(10,true)
    palt(13,true)
    sspr(98,0,ascii.w,ascii.h,ascii.ghost_x,ascii.ghost_y,ascii.w*_scale,ascii.h*_scale)
  end
  pal()
  palt()
end

function draw_map(_layers)
  --layer 1
  if not _layers or _layers.l1 then
    map(0,10,maps.plxb1_x,80,16,5)
    map(0,10,maps.plxb2_x,80,16,5)
  end
  --layer 2
  if not _layers or _layers.l2 then
    map(0,8,maps.plxa1_x,110,16,2)
    map(0,8,maps.plxa2_x,110,16,2)
  end
  --layer 3
  if not _layers or _layers.l3 then
    map(0,15,maps.gnd1_x,120,16,1)
    map(0,15,maps.gnd2_x,120,16,1)
  end
end

function draw_pwrups(_p)
  sspr(_p.sx,_p.sy,_p.w,_p.h,_p.x,_p.y)
end

function draw_shield(_shield,_scale)
  local _scale=_scale or 1
  if _shield.lt==2 then
    _shield.col=9
  elseif _shield.lt==1 then
    _shield.col=8
  end
  if ascii.collided
    and tim.game.f%5~=0 then
    return
  else
    circ(ascii.x+(ascii.w*_scale/2),ascii.y+(ascii.h*_scale/2),_shield.r*_scale,_shield.col)
  end
end

function draw_game()
  cls()
  camera(cam.x,cam.y)
  rectfill(0,0,127,127,1)
  draw_map()
  draw_particles()
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

  print(debug,15,20,8)
end

function draw_boss_health()
  rect(29,1,29+(boss.maxhealth/2)+2,7,7)
  if(boss.health>0) rectfill(30,2,30+(boss.health/2),6,8)
end

function draw_boss()
  if boss.dying>0 then
    sspr(112,32,boss.body.w,boss.body.h,boss.body.x,boss.body.y)
    sspr(122,40,boss.hose.w,boss.hose.h,boss.hose.x,boss.hose.y)
    sspr(125,40,boss.nozzle.w,boss.nozzle.h,boss.nozzle.x,boss.nozzle.y)
  end

  if not boss.active then
    if boss.dying%5==0 and boss.dying>0 then
      local _sfx=1+flr(rnd(2))
      if (boss.dying==1) _sfx=2

      if boss.dying%35==0 then
        explosion(
          boss.body.x+flr(rnd(16)),
          boss.body.y+flr(rnd(8)),
          1+flr(rnd(2)),
          flr(rnd(1))*-1,
          30,
          "circ",
          _sfx
        )
      end

      camshake(12)
    end

    if (boss.dying>120) ascii_goto(64-(ascii.hitbox.w/2),boss.body.y-4)
    if (boss.dying<=120) ascii_goto(138,ascii.y)

    if boss.dying==0 then
      _update60=update_game_end
      _draw=draw_game_end
      ascii.pwrups={}
      ascii.x=ascii.hitbox.w*-1
      ascii.y=64-(ascii.hitbox.h/2)
    end

    boss.dying-=1
  end
end

function draw_bosslvl()
  cls()
  camera(cam.x,cam.y)
  rectfill(0,0,127,127,1)
  draw_map()
  foreach(clouds,draw_cloud)
  draw_ascii()
  draw_shots()
  draw_boss()
  draw_particles()

  draw_infobar()
  draw_boss_health()
  foreach(powerups, draw_pwrups)

  print(debug,15,20,8)
end

-->8
--game over
function update_lvlend()
  tim.f=(tim.f+1)%60
  update_clouds()
  update_cape()
  ascii_goto(138,ascii.y)

  -- button c
  if btn(4) then
    cur_lvl+=1
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
  -- shadow; todo: move to function
  print_center("level "..cur_lvl.." finished", 49, 0)
  -- text
  print_center("level "..cur_lvl.." finished", 50, 7)
  -- shadow
  print_center("press c to continue", 59, 0)
  -- text
  print_center("press c to continue", 60, 7)
end
-->8
--game end

function update_game_end()
  update_clouds()
  update_cape()
  update_ascii()
  if tim.credits>0 then
    ascii_goto(64-(ascii.hitbox.w/2),64-(ascii.hitbox.h/2))
    tim.credits-=1
  end
  if tim.credits==0 then
    if (won_y>-16) won_y-=1
    if (score_y>-16) score_y-=1
    ascii_goto(ascii.x,-16)
    if (fade_i==0) fade_i=1
  end
end

function draw_game_end()
  cls()
  rectfill(0,0,127,127,1)
  foreach(clouds,draw_cloud)
  draw_map()
  print_center("awesome! you won!",won_y,7,true)
  draw_ascii()
  print_center("final score: "..score,score_y,7,true)
  if fade_i>0 then
    fade(fade_i)
    if flr(fade_i+1)<16 then
      fade_i+=0.1
    else
      pal(7,7)
      _draw=draw_credits
      _update60=update_credits
    end
  end
end

-->8
--credits

function update_credits()
  if credit_y>-140 then
    credit_y-=0.5
  end
end

function draw_credits()
  cls()
  pal()
  local y_off=8
  print_center("*concept and programming*",credit_y,7)
  print_center("mario zoth",credit_y+y_off,7)
  print_center("klemens kunz",credit_y+y_off*2,7)

  print_center("*graphics*",credit_y+y_off*5,7)
  print_center("mario zoth",credit_y+y_off*6,7)
  print_center("klemens kunz",credit_y+y_off*7,7)
  print_center("peter hofmann",credit_y+y_off*8,7)

  print_center("*sound effects*",credit_y+y_off*11,7)
  print_center("mario zoth",credit_y+y_off*12,7)

  print_center("*music*",credit_y+y_off*15,7)
  print_center("klemens kunz",credit_y+y_off*16,7)

  print_center("*special thanks*",credit_y+y_off*19,7)
  print_center("mischa magyar",credit_y+y_off*20,7)
  print_center("ingrid menzl",credit_y+y_off*21,7)
  print_center("tobias lendl",credit_y+y_off*22,7)
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
    draw_ascii(true)
  else
    draw_ascii()
  end
end
__gfx__
000000000000070750000570000700990000660000220050005000500000000000065000000000007f000000000099a000ddd000000060060000000000000000
00000000dd00077755555577777709889006776002882005055505000004000000065000000000077f000000000099a000ddddd0000067770000000000000000
00700700a8888b7b585585747747988889677776288882005777500000090000f550558840000d70778890000004444900aa8888888873730000000000000000
0007700098877777055550077770988889677776288882057777750000494000075555889000007777270066600099a000999888885677f70000000000000000
00077000077777700055000077000988900677600288205577777550049994000005522500fff00772777060000099a000099757565775250000000000000000
00700700070000700000000000000099000066000022000577777500049994000065225500f00006277766600005454400000777777777700000000000000000
000000007000070000000000000000000000000000000000577750004999994000002555fff00000077700000054494440000677755567000000000000000000
00000000000000000000000000000000000000000000000505550500499999400005555000000000666000000054454440007770000077000000000000000000
00677770000000000000000000000000000000000000005000500050000000000000000000000000000000000544454444077000000770000000000000000000
06777777000000000000000000000000000000000000000000000000000000000000000000000000000000000555555554000000000000000000000000000000
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
b3b3b3b3000555555555500055555555000000055000000000000007700000000000000000000000000000000000000000000000000000000022222222222200
b3b3b3b3000555d55555500055555555000000055000000000000007700000000000000000000000000000000000000000000000000000000222222222222220
3b3b3b3b00555555555555005555555500000055550000000000007577000000000000000000000000000000000000000000000000000000222ee2eeeeee2222
4b4b4b4b00555555555555005555555500000055550000000000005557000000000000000000000000000000000000000000000000000000222ee2eeeee22222
444444440555d5555555555055555555000005555550000000000555557000000000000000000000000000000000000000000000000000002222222222222222
44544444055555555555555055555555000005555550000000000555557000000000000000000000000000000000000000000000000000002222222222222222
4644454455d555555555555555555555000055555555000000005555555700000000000000000000000000000000000000000000000000000222222222222220
44446444555555555555555555555555000055555555000000005555555500000000000000000000000000000000000000000000000000000022222222222200
000000000000000000000000003333000000000000000000333333330000000000000000000000000000000000000000000000000000000000000000002e0200
00000000000000000000000033333333333333330000000033333333000000000000000000000000000000000000000000000000000000000000000000e20220
00000000000000333330000033333333333333330000000033333333000000000000000000000000000000000000000000000000000000000000000000220222
000000000000033333333000333333333333333300000000333333330000000000000000000000000000000000000000000000000000000000000000002e0222
000000000003b3333333330033333333333333330000000033333333000000000000000000000000000000000000000000000000000000000000000000e20222
00000000033333333333333033333333333333330000330033333333000000000000000000000000000000000000000000000000000000000000000000220222
00000000333b333333333333333333333333333303b33330333333330000000000000000000000000000000000000000000000000000000000000000002e0220
00000000333333333333333333333333333333333333333333333333000000000000000000000000000000000000000000000000000000000000000000e20200
000000ccccccccccccccccccccccccccccccccccccc0000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000ceeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeec0000000000000000000000000000000000000000000000000000000000000000000000000000000000000
ccccccceeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeccccccc0000000000000000000000000000000000000000000000000000000000000000000000000000000
ceeeeeceeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeceeeeec0000000000000000000000000000000000000000000000000000000000000000000000000000000
0ceeeeceeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeceeeec00000000000000000000000000000000000000000000000000000000000000000000000000000000
00ceeeceeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeceeec000000000000000000000000000000000000000000000000000000000000000000000000000000000
000ceeceeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeceec0000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000ceceeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeecec00000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000ceceeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeecec00000000000000000000000000000000000000000000000000000000000000000000000000000000000
000ceeceeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeceec0000000000000000000000000000000000000000000000000000000000000000000000000000000000
00ceeeccccccccccccccccccccccccccccccccccccceeec000000000000000000000000000000000000000000000000000000000000000000000000000000000
0ceeeeec000000000000000000000000000000000ceeeeec00000000000000000000000000000000000000000000000000000000000000000000000000000000
ceeeeeeec0000000000000000000000000000000ceeeeeeec0000000000000000000000000000000000000000000000000000000000000000000000000000000
cccccccccc00000000000000000000000000000cccccccccc0000000000000000000000000000000000000000000000000000000000000000000000000000000
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
000a00000a6730364004640046500265001650006500065000650006500064000630006200000000000000000000000000000000000000000000001b600000000000000000000000000000000000000000000000
000200003e0503a000360000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000a00000a6030360004600046000260001600006000060000600006000060000600006000000000000000000000000000000000000000000000001b600000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0010000c0c6100c6200c6200c6200c6200c6100c6100c6200c6200c6200c6100c6100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
