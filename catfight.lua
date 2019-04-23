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
    gnd_spd=0.5
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
    w=14,
    h=9,
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
  }

  cur_lvl=1

  enemy_waves={}

  _update60=update_start
  _draw=draw_start
end