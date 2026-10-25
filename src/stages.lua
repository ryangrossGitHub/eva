stage = 0
stage_trans = false
stage_transfer_count = 0
stage_transfer_total = 161 -- stage trans total 
camera_x = 0
camera_y = 0
intro_count = 0
intro_time = 60 * 5 -- 7 seconds
intro = false
floor_color_transition = 100
floor_color_delay = 300
floor_color_count = 0
floor_color = 9
wall_height = 56
map_width = 8

rain_front = {}
rain_back = {}

stages = {
  { 
    enemy_spawn_count = 0,
    enemy_speed = 0.5,
    enemy_spawn_delay = 20,
    music_track = 24,
    weapon_unlock = 1
  },
  { 
    enemy_spawn_count = 9999, -- unlimited
    enemy_speed = 0.4,
    enemy_spawn_delay = 14,
    enemy_spawn_initial_delay = 30,
    enemy_spawn_initial_delay_count = 0,
    music_track = 24,
    weapon_unlock = 1
  },
  { 
    enemy_spawn_count = 0,
    enemy_speed = 0.4,
    enemy_spawn_delay = 8,
    music_track = 56,
    weapon_unlock = 1
  },
}

function load_stage(n)
  stage = n
  
  if n == 0 then
    load_start()
  elseif n == 1 then
    music(24)
    e_spawn = true
    player_move = true
  else
    enemey_spawn_stage_count = 0
    floor_color_count = 0
    
    -- 8 to 9 is transition inside
    if n == 9 then
      j.y = screen_size + init_player_y
      c.y = screen_size + init_player_y-16
      j.x = 16
      c.x = 16
      camera_y = screen_size
      camera_x = 0
      e_spawn = true
      player_move = true
    else
      stage_trans = true
      e_spawn = false
      player_move = false
      j.flip_sprite = false
      c.flip_sprite = false
    end
  end
end

function update_stage_trans()
  if stage_transfer_count < stage_transfer_total then
    stage_transfer_count += 1
    j.x += 0.8
    c.x += 0.8
    camera_x += 0.8
  else
    stage_trans = false
    enemies = {} -- clear
    particles = {} -- clear
    if stage < 16 then
      stage_transfer_count = 0
      e_spawn = true
      player_move = true
    end
  end
end

function load_start()
  player_move = false
  e_spawn = false
  camera_x = 0
  camera_y = 0
  j.y = init_player_y
  c.y = init_player_y
  j.x = init_jenn_x
  c.x = init_chad_x
end

function update_start()
  if btnp(0) or btnp(1) then
    if p1.name == "jenn" then
      p1 = c
      p2 = j
    else
      p1 = j
      p2 = c
    end
  end
 
 if btnp(2) or btnp(3) then
    if coop then
      coop = false
    else 
      coop = true
    end
 end
 
  if btnp(4) or btnp(5) then
    intro = true
    music(-1)
    run_intro()
    printh("GAME START", log_file)
  end
end

function draw_start()
  rect(p1.x - 3, p1.y - 1, p1.x + 16, p1.y + 32, 8)
  
  if coop then
	  rect(p2.x - 3, p2.y - 1, p2.x + 16, p2.y + 32, 12)
  end
  
  say(54,22,"cOPS yEET zOMBIES ii ", 1, true, false, 11, 3)
  say(54,43, "⬆️    ONE PLAYER", 1, true, false, 12, 1)
  say(54,53, "⬇️    TWO PLAYERS", 1, true, false, 12, 1)  
  say(54,110, "⬅️   JENN CHAD    ➡️", 1, true, false, 12, 1)
  say(54,128, "PRESS ❎/🅾️ TO START", 0, true, false, 8, 0)
end

function run_intro()
  if intro_count > 10 and (btnp(🅾️) or btnp(❎)) then
    intro = false
    load_stage(1)
  end

  if intro_count < intro_time then
    intro_count += 1
  else
    intro = false
    load_stage(1)
  end
end

function draw_floor()
  if floor_color_count >= floor_color_delay then
    floor_color_count = 0
    if floor_color == 9 then
      floor_color = 2
    elseif floor_color == 2 then
      floor_color = 9
    end
  else
    floor_color_count += 1

    local color = 0
    if floor_color_count < floor_color_delay - floor_color_transition then
      color = floor_color
    end

    rectfill(screen_size, wall_height, 104 * 8, screen_size, color)
  end
end

function draw_gun_shelf(tier)
  local upper_left = 45 * 8
  rectfill(upper_left, 0, 55 * 8, 5 * 8, 7)

  if long_shotgun.found then
    spr(long_shotgun.sprite, upper_left + 6, 3, long_shotgun.length, 1)
  end

  if hunting_rifle.found then
    spr(hunting_rifle.sprite, upper_left + 58, 3, hunting_rifle.length, 1)
  end

  if burst_rifle.found then
    spr(burst_rifle.sprite, upper_left + 34, 3, burst_rifle.length, 1)
  end

  if oozie.found then
    spr(oozie.sprite, upper_left + 50, 15)
  end

  if revolver.found then
    spr(revolver.sprite, upper_left + 16, 15)
  end

  if auto_rifle.found then
    spr(auto_rifle.sprite, upper_left + 66, 15)
  end

  if shotgun.found then
    spr(shotgun.sprite, upper_left + 3, 15)
  end
end

function draw_weapons()
  if not long_shotgun.found then
    spr(long_shotgun.sprite, long_shotgun.x, long_shotgun.y, long_shotgun.length, 1)
  end

  if not hunting_rifle.found then
    spr(hunting_rifle.sprite, hunting_rifle.x, hunting_rifle.y, hunting_rifle.length, 1)
  end

  if not burst_rifle.found then
    spr(burst_rifle.sprite, burst_rifle.x, burst_rifle.y, burst_rifle.length, 1)
  end

  if not oozie.found then
    spr(oozie.sprite, oozie.x, oozie.y)
  end

  if not revolver.found then
    spr(revolver.sprite, revolver.x, revolver.y)
  end

  if not auto_rifle.found then
    spr(auto_rifle.sprite, auto_rifle.x, auto_rifle.y)
  end

  if not shotgun.found then
    spr(shotgun.sprite, shotgun.x, shotgun.y)
  end
end

function init_rain()
  for i = 1, 200 do
    add(rain_front, {
      x = flr(rnd(screen_size*2)) - screen_size,
      y = flr(rnd(screen_size)),
      spd = 2 + rnd(3)
    })
  end

  local back_x_start = 104 * 8
  for i = 1, 200 do
    add(rain_back, {
      x = flr(rnd(back_x_start) + screen_size * 2 + back_x_start),
      y = flr(rnd(screen_size)),
      spd = 2 + rnd(3)
    })
  end
end

function draw_rain()
  for drop in all(rain_front) do
    drop.y += drop.spd
    drop.x -= 1 -- slight wind angle
    
    if (drop.y > screen_size - 1) drop.y = -4
    if (drop.x < -screen_size) drop.x = screen_size - 1

    line(drop.x, drop.y, drop.x - 1, drop.y + 3, 1)
  end

  local back_x_start = 104 * 8
  for drop in all(rain_back) do
    drop.y += drop.spd
    drop.x -= 1 -- slight wind angle
    
    if (drop.y > screen_size - 1) drop.y = -4
    if (drop.x < back_x_start) drop.x = back_x_start + screen_size * 2 - 1

    line(drop.x, drop.y, drop.x - 1, drop.y + 3, 1)
  end
end

function reset()
  stage_trans = false
  enemies = {} -- clear
  particles = {} -- clear
  stage_transfer_count = 0
  e_spawn = false
  player_move = false
  progress_stage = 0
  stage = 0
  j.x = init_jenn_x
	j.y = init_player_y
  j.kill_count = 0
  c.x = init_chad_x 
	c.y = init_player_y
  c.kill_count = 0
  music(24)  
end


function run_ending()
  if j.x >= screen_size * map_width + 16 or c.x >= screen_size * map_width + 16 then
    -- walk in place
    c.last_animation_frame_x -= 1
    j.last_animation_frame_x -= 1
  else
    j.x += 1
    c.x += 1
  end

  ending_dialog()
end