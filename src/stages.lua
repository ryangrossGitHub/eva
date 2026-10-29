stage = 0
stage_trans = false
stage_transfer_count = 0
stage_transfer_total = 161 -- stage trans total 
camera_x = 0
camera_y = 0
wall_height = 56
map_width = 8

snow = {}

stages = {
  { 
    enemy_spawn_count = 2, -- unlimited
    enemy_speed = 0.4,
    enemy_spawn_delay = 14,
    enemy_spawn_initial_delay = 0,
    enemy_spawn_initial_delay_count = 0,
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
    music(-1)
    printh("GAME START", log_file)
    load_stage(1)
  end
end

function draw_start()
  rect(p1.x - 3, p1.y - 1, p1.x + 16, p1.y + 32, 8)
  
  if coop then
	  rect(p2.x - 3, p2.y - 1, p2.x + 16, p2.y + 32, 3)
  end
  
  print_dialog(51,22,"\^w\^telves vs ai", 0, true, false, 7, 0)
  print_dialog(54,36,"BATTLE FOR THE NORTH", 0, true, false, 8, 0)
  print_dialog(54,110, "⬆️   ONE PLAYER", 0, true, false, 8, 7)
  print_dialog(54,117, "⬇️   TWO PLAYERS", 0, true, false, 8, 7)  
  print_dialog(54,124, "⬅️   CHOOSE ELF   ➡️", 0, true, false, 8, 7)
  print_dialog(54,131, "PRESS ❎/🅾️ TO START", 0, true, false, 3, 7)
end

function draw_weapons()
  if not rifle.found then
    spr(rifle.sprite, rifle.x, rifle.y, rifle.length, 1)
  end
end

function init_snow()
  for i = 1, 120 do -- slightly fewer particles for a cleaner snow look
    add(snow, {
      x = rnd(128),
      y = rnd(128),
      spd = 0.3 + rnd(0.5), -- significantly slower falling speed
      sine_offset = rnd(100), -- unique offset for the swaying pattern
      sine_spd = 0.02 + rnd(0.03) -- how fast each flake sways left and right
    })
  end
end

function draw_snow()
  for flake in all(snow) do
    -- fall down slowly
    flake.y += flake.spd
    
    -- update the swaying angle
    flake.sine_offset += flake.sine_spd
    
    -- calculate final horizontal position with a wind bias + wave motion
    -- pset requires integers, so we use flr() when drawing
    local drift_x = flake.x + sin(flake.sine_offset) * 4 - 2 -- 4 is the sway width, -2 shifts it slightly left for wind
    
    -- screen wrap thresholds
    if (flake.y > 128) then
      flake.y = -2
      flake.x = rnd(128)
    end
    if (flake.x < -4) flake.x = 132
    if (flake.x > 132) flake.x = -4

    -- draw flake as a single pixel (color 7 is white, color 6 is light gray for variety if desired)
    pset(flr(drift_x), flr(flake.y), 7)
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
  music(0)  
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
end