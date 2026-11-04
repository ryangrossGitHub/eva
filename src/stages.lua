stage = 0
stage_trans = false
stage_transfer_count = 0
stage_transfer_total = 120 -- stage trans total 
camera_x = 0
camera_y = 0
wall_height = 56
map_width = 8
intro_camera_pause = 0--260
intro_camera_pause_count = 0

left_bound = 7 * 8
right_bound = 38 * 8

snow = {}

stages = {
  { -- 1
    enemy_spawn_count = 5, 
    enemy_speed = 0.385,
    enemy_spawn_delay = 130
  },
  { -- 2
    enemy_spawn_count = 20, 
    enemy_speed = 0.5,
    enemy_spawn_delay = 60
  },
  { -- 3
    enemy_spawn_count = 10, 
    enemy_speed = 0.5,
    enemy_spawn_delay = 80
  },
  { -- 4
    enemy_spawn_count = 10, 
    enemy_speed = 0.7,
    enemy_spawn_delay = 70
  },
  { -- 5
    enemy_spawn_count = 20, 
    enemy_speed = 1,
    enemy_spawn_delay = 40
  },
  { -- 6
    enemy_spawn_count = 60, 
    enemy_speed = 1.5,
    enemy_spawn_delay = 20
  },
  { -- 7
    enemy_spawn_count = 100, 
    enemy_speed = 2,
    enemy_spawn_delay = 15
  },
  { -- 8
    enemy_spawn_count = 1, 
    enemy_speed = 2,
    enemy_spawn_delay = 15
  }
}

function load_stage(n)
  stage = n
  
  if n == 0 then
    load_start()
  elseif n == 1 then
    music(0)
    e_spawn = true
  else
    if not speaking() then
      say("_/s/-1.39/3/ao/-1.22/f/-1.74/_/t/-1.10/w/-1.40/eh/-1.09/r/-1.60/ah/-1.56/_/p/-1.72/-3/_/d/-1.13/-3/ey/-1.64/-3/_/t/_/-1.67/_/k/-1.58/ah/-1.03/m/-1.64/-3/_/p/-1.07/-3/l/-1.14/-3/iy/-1.64/-3/_/t/1.15/-3/iy/-1.64/-3/_/t/1.15/-3/iy/-1.64/-3/_/t/1.15/-3/iy/-1.64/-3/_/t/1.15/-3/iy/-1.64/-3/_/t")
    end
    enemy_kill_count = 0
    enemey_spawn_stage_count = 0
    stage_trans = true
    e_spawn = false
  end

  if n == 6 then
    p1.weapon = 1
    p2.weapon = 1
    sfx(1) -- rifle
  end

  if n == 5 then
    sfx(1) -- special
  end
end

function update_stage_trans()
  if stage_transfer_count < stage_transfer_total then
    stage_transfer_count += 1
  else
    stage_transfer_count = 0
    enemy_spawn_delay_count = 0
    stage_trans = false
    e_spawn = true
  end
end

function load_start()
  player_move = false
  e_spawn = false
  camera_x = 0
  camera_y = 0
  j.y = init_jenn_y
  c.y = init_chad_y
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
 
  if btnp(4) or btnp(5) then
    music(-1)
    printh("GAME START", log_file)
    intro = true
    load_stage(1)
  end
end

-- camera pan
function update_intro()
    if intro_camera_pause_count < intro_camera_pause then
      camera_x = right_bound - screen_size/1.5
    elseif camera_x > 35 then
      camera_x -= 2
    else
      intro = false
      player_move = true
    end

    intro_camera_pause_count += 1
end

function draw_start()
  print_dialog(91,22,"\^w\^telves vs ai", 0, true, false, 7, 0)
  print_dialog(94,36,"BATTLE FOR THE NORTH", 0, true, false, 8, 0)
  print_dialog(94,131, "PRESS ❎ TO START", 0, true, false, 8, 0)
end

function init_snow(n)
 snow = {} -- ensure array is initialized
 for i = 1, n do
  add(snow, {
   x = camera_x + rnd(128), -- spawn initially within the current camera view
   y = rnd(128),
   spd = 0.3 + rnd(0.5),
   sine_offset = rnd(100),
   sine_spd = 0.02 + rnd(0.03)
  })
 end
end

function draw_snow()
 for flake in all(snow) do
  -- fall down slowly
  flake.y += flake.spd

  -- update the swaying angle
  flake.sine_offset += flake.sine_spd

  -- calculate horizontal position with a wind bias + wave motion
  local drift_x = flake.x + sin(flake.sine_offset) * 4 - 2

  -- screen wrap thresholds relative to the camera
  if (flake.y > 128) then
   flake.y = -2
   flake.x = camera_x + rnd(128) -- respawn at the top, inside the current camera view
  end

  -- if a flake goes off the left side of the camera, wrap to the right side
  if (flake.x < camera_x - 4) then
   flake.x += 136
  -- if a flake goes off the right side of the camera, wrap to the left side
  elseif (flake.x > camera_x + 132) then
   flake.x -= 136
  end

  -- draw flake using its world coordinates
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
  game_over = false
  intro = false
  progress_stage = 0
  stage = 0
  j.x = init_jenn_x
	j.y = init_jenn_y
  j.kill_count = 0
  c.x = init_chad_x 
	c.y = init_chad_y
  c.kill_count = 0
  music(0)  
end

function update_screen_shake()
  if camera_shake < 0.5 then 
    camera_shake = 0
    camera_y = 0 
  else
    camera_shake *= 0.85
    camera_x = camera_x + (rnd(camera_shake * 2) - camera_shake)
    camera_y = camera_y + (rnd(camera_shake * 2) - camera_shake)
  end
end
