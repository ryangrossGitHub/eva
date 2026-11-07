player_move = false

init_jenn_x = 9*8
init_jenn_y = 74
init_chad_x = 7*8
init_chad_y = 48

camera_shake_offset = 0
camera_shake_offset_amount = 1

bounce_delay = 18
bounce_count = 0
bounce = false

displaying_weapons = false
displaying_weapons_delay = 10
displaying_weapons_count = 0

trail_capture_delay = 4
trail_capture_count = 0
trail_capture_length = 200

p2_boss_dir = 0

j = {
	name = "jenn",
	sprites = {
		head = 2,
		head2 = 3,
		torso = 34,
		legs_standing = 48,
		legs_moving = 50,
		arm_out = 38,
		arm_up = 33
	},
	flip_sprite = false, 
	x = init_jenn_x, 
	y = init_jenn_y, 
	w = 8,
	h = 32,
	last_animation_frame_x = init_jenn_x, 
	last_animation_frame_y = init_jenn_y, 
	animation_frame_delay = 5, 
	weapon = 0, -- weapon: 0 pistol, 1 rifle
	weapon_delay = 0,
	trigger = false, -- trigger pressed,
	kill_count = 0,
	stepping = true, -- movement sprite
	recoil = false, -- arm movement when firing
	recoil_delay = 1,
	recoil_count = 0,
	speed = 1,
	weapon_list_index = 1,
	enemy_collision = false,
	enemy_melee_collision = false,
	enemy_melee_collision_dist = 30,
	enemy_melee_collision_dist_count = 0,
	force_special_active = false,
	force_special_anim_seq = 0,
	force_special_anim_count = 0,
	force_radius = 0,
	trail = {},
	trail_foot_to_capture = 0, -- 0 left foot, 1 right foot
	shadow = true,
	fall = false,
	respawn = false
}

c = {
	name = "chad",
	sprites = {
		head = 0,
		head2 = 4,
		torso = 32,
		legs_standing = 48,
		legs_moving = 50,
		arm_out = 38,
		arm_up = 33
	},
	flip_sprite = false, 
	x = init_chad_x,
	y = init_chad_y, 
	w = 8,
	h = 32,
	last_animation_frame_x = init_chad_x, 
	last_animation_frame_y = init_chad_y, 
	animation_frame_delay = 5, 
	weapon = 0, -- weapon: 0 pistol, 1 rifle
	weapon_delay = 0,
	trigger = false, -- trigger pressed
	kill_count = 0,
	stepping = true, -- movement sprite
	recoil = false, -- arm movement when firing
	recoil_delay = 1,
	recoil_count = 0,
	speed = 1,
	weapon_list_index = 1,
	enemy_collision = false,
	enemy_melee_collision = false,
	enemy_melee_collision_dist = 30,
	enemy_melee_collision_dist_count = 0,
	force_special_active = false,
	force_special_anim_seq = 0,
	force_special_anim_count = 0,
	force_radius = 0,
	trail = {},
	trail_foot_to_capture = 0, -- 0 left foot, 1 right foot
	shadow = true,
	fall = false,
	respawn = false
}

santa = {
	x = 90,
	y = 70
}

p1 = j
p2 = c
coop = false

pistol = {
	id = 0,
	delay = 6,
	damage = 5,
	sprite = 35,
	length = 1,
}

rifle = {
	id = 1,
	delay = 2,
	damage = 2,
	sprite = 36,
	length = 2
}

weapon_list = {pistol, rifle}

function update_p2()
	local c,y = nil
	if p2.x > p1.x + 32 then
		p2.flip_sprite = true
		p2.x -= p2.speed
	elseif p2.x < p1.x - 32 then
		p2.x += p2.speed
		p2.flip_sprite = false
	else
		c,y = closest_enemy()
	end

 	if c then
		if c < 0 then
	  		p2.flip_sprite = true	  
	 	else
	  		p2.flip_sprite = false	  	  
		end

		handle_player_trigger(p2)
	else
		p2.trigger = false
	end
	
	if y and y < 0 then
		p2.y -= 1
	elseif y and y > 0 then
	 	p2.y += 1
	end

	if p2.x < left_bound then p2.x = left_bound + 1 end

	local boss_delta_right = abs(boss.x + 58 - p2.x)
	if  boss_delta_right <= 4 and boss.y > p2.y - 26 then
		p2.x += boss_delta_right
	end

	local boss_delta_left = abs(boss.x - 24 - p2.x)
	if  boss_delta_left <= 4 and boss.y > p2.y - 26 then
		p2.x -= boss_delta_left
	end

	local boss_delta_up = abs(boss.y + 22 - p2.y)
	if boss_delta_up <= 4 and boss.x + 58 > p2.x and boss.x - 28 < p2.x then
		p2.y += boss_delta_up
	end
end

function update_p2_boss()
	if boss.x + 58 > p2.x and boss.x - 28 < p2.x then
		if p2_boss_dir == 0 then
			p2.x += p2.speed
			p2.flip_sprite = true

			if p2.x > camera_x + screen_size - p2.w * 3 then
				p2_boss_dir = 1
			end
		else 
			p2.x -= p2.speed
			p2.flip_sprite = false

			if p2.x < camera_x + p2.w * 2 then
				p2_boss_dir = 0
			end
		end
	end

	if boss.y > 8 then
		handle_player_trigger(p2)
	end
end

function closest_enemy()
	-- which direction to fire
	local closest = 99
	-- neg = left, pos = right
	local c_xdir = 0

	-- which direction to move
	-- neg = up, pos = down
	local e_ydir = 0

	local player_weapon_offset = 12

	local hbox = 8 -- hit box
 
	for e in all(enemies) do
		if not e.dead and e.x > camera_x + 5 and e.x < camera_x + screen_size - 5 then
			-- if left or right then fire at closest enemy
			-- else calculate whether there are more enemies above or below to dictate y movement
			if (e.y-4 > p2.y + player_weapon_offset - hbox and e.y-4 < p2.y + player_weapon_offset + hbox) then
				local dir = e.x - p2.x
				local dif = abs(dir)
				if dif < closest then
					closest = dif
					c_xdir = dir
				end
			elseif e.y-4 < p2.y + player_weapon_offset then
				e_ydir -= 1
			else
				e_ydir += 1
			end
		end
	end
 
	if closest == 99 then -- no enemies in range
		return nil, e_ydir
	else
		if e_ydir == 0 then e_ydir = 1 end -- tie breaker so bot doesn't freeze
		return c_xdir, e_ydir
	end
end

function update_player_anims(p)
	-- leg movement
 	if abs(p.x - p.last_animation_frame_x) > p.animation_frame_delay or abs(p.y - p.last_animation_frame_y) > p.animation_frame_delay then
  		p.last_animation_frame_x = p.x
  		p.last_animation_frame_y = p.y
  
  		-- get next animation frame
  		if p.stepping then
  			p.stepping = false
  		else
			p.stepping = true
		end
 	end
end

function update_player_trail(p)
	if trail_capture_count < trail_capture_delay then
		trail_capture_count += 1
	else
		trail_capture_count = 0
		if p.trail_foot_to_capture == 0 then
			p.trail_foot_to_capture = 1
			add(p.trail, {x = p.x + 4, y = p.y + 30})
		else
			p.trail_foot_to_capture = 0
			add(p.trail, {x = p.x + 4, y = p.y + 32})
		end
	end

	if #p.trail > trail_capture_length then
		del(p.trail, p.trail[1])
	end
end

function update_player_move(p, ctrl)

	if p.fall then
		p.y += 8
		return 
	end

	local btn_pressed = false

	-- ctrl is the controller maping
	if btn(0, ctrl) 
		and p.x > left_bound -- not out of bounds
		and p.x > camera_x then -- in camera frame
		
		p.flip_sprite = true 
		p.x -= p.speed

		if stage < 8 and p2.x < camera_x + screen_size and p1.x < camera_x + screen_size then
			camera_x -= p.speed
		end
	elseif btn(1, ctrl) 
		and p.x < right_bound -- not past the end of the map
		and p.x < camera_x + screen_size - 16 -- both players in camera frame
		and not (not p.flip_sprite and p.enemy_collision) then -- can't move through enemies
		
		p.flip_sprite = false
		p.x += p.speed

		if stage < 8 and p2.x > camera_x and p1.x > camera_x then
			camera_x += p.speed
		end
	end
 
	if btn(2, ctrl) and p.y > 28 then
		p.y -= p.speed
	elseif btn(3, ctrl) and p.y < screen_size - 49 then
		p.y += p.speed
	end
 
	if btn(❎, ctrl) then
		btn_pressed = true
		handle_player_trigger(p)
 	else
  		p.trigger = false
 	end
	
	if btnp(🅾️, ctrl) then
		if stage >= 5 then p.force_special_active = true end
	end

	if p.enemy_melee_collision then
		p.x -= p.enemy_melee_collision_dist_count

		p.enemy_melee_collision_dist_count *= 0.75

		if p.enemy_melee_collision_dist_count < 0 or p.x < left_bound then
			p.enemy_melee_collision = false
		else
			
		end
	end

	if p.x < left_bound then p.x = left_bound + 1 end

	local boss_delta_right = abs(boss.x + 43 - p.x)
	if  boss_delta_right <= 4 and boss.y > p.y - 26 then
		p.x += boss_delta_right
	end

	local boss_delta_left = abs(boss.x - 10 - p.x)
	if  boss_delta_left <= 4 and boss.y > p.y - 26 then
		p.x -= boss_delta_left
	end

	local boss_delta_up = abs(boss.y + 22 - p.y)
	if boss_delta_up <= 4 and boss.x + 43 > p.x and boss.x - 10 < p.x then
		p.y += boss_delta_up
	end

	return btn_pressed
end

function detect_player_fall(p)
	if p.y > screen_size then
		p.respawn = true
		p.y = -40
		p.x = camera_x + 16
	elseif p.y > 10 * 8 then
		p.shadow = false
		p.fall = true
	end

	if p.respawn then
		p.y += (p.y + 75) * 0.07

		if p.y >= 75 then
			p.respawn = false
			p.fall = false
		end
	end
end

function center_camera_on_players()
	local players_center = flr((p1.x + p2.x + 64) / 2)

	camera_x = players_center - screen_size/2
end

function handle_player_fire(p)
	if p.recoil_count < p.recoil_delay then
		p.recoil = true
		p.recoil_count += 1
	else
		p.recoil = false
		p.recoil_count = 0
	end
	
	sfx(0)

	local xd = 8
	if p.flip_sprite then
		xd = -xd
	end

	spawn_dart(p.x+4, p.y + 16, xd, -1, false)
end

function draw_player_weapon(p)
	local recoil_mult = 0

	if p.recoil then
		recoil_mult = 2
	end

	local bounce_height = 0
	if bounce then
		bounce_height = 1
	end

	if p.force_special_active then
		return -- don't draw weapon when force special is active
	elseif p.weapon == 0 then
		if p.flip_sprite then
			spr(pistol.sprite, p.x - 1 + recoil_mult, p.y + 12 + bounce_height, 1, 1, true, false)
		else
			spr(pistol.sprite, p.x + 9 - recoil_mult, p.y + 12 + bounce_height, 1, 1, false, false)
		end
	elseif p.weapon == 1 then
		if p.flip_sprite then
			spr(rifle.sprite, p.x - 8 + recoil_mult, p.y + 11 + bounce_height, rifle.length, 1, true, false)
		else
			spr(rifle.sprite, p.x + 8 - recoil_mult, p.y + 11 + bounce_height, rifle.length, 1, false, false)
		end
	end
end

function draw_player_trail(p)
	for t in all(p.trail) do
		pset(t.x, t.y, 6)
	end
end

function update_player_force(p)
	if p.force_special_active then
		p.force_special_anim_count += 1

		if p.force_special_anim_count == 16 then
			p.force_special_anim_seq = 1
			camera_shake = 3
			p.force_special_active = true
		end
	end

	if p.force_special_active and p.force_special_anim_seq == 1 then
		local rad_max = 120
		if p.force_radius < rad_max - 20  then
			p.force_radius = p.force_radius + (rad_max - p.force_radius) * 0.05
			
		else
			p.force_radius = 0
			p.force_special_anim_count = 0
			p.force_special_anim_seq = 0
			p.force_special_active = false
		end 

		for e in all(enemies) do
			if is_in_circle(e.x, e.y, p.x + 4, p.y + 16, p.force_radius) then
				kill_enemy(e)
			end
		end
	end
end

function is_in_circle(spr_x, spr_y, circ_x, circ_y, circ_r)
  local dx = spr_x - circ_x
  local dy = spr_y - circ_y
  local dist_sq = dx * dx + dy * dy
  local rad_sq = circ_r * circ_r
  
  return dist_sq <= rad_sq
end


function draw_player_force(p)
	if p.force_special_active  then
		print_dialog(p.x, p.y, "YOU SHALL NOT PASS!", 1, false, false, 0, 7)
	end
	
	if p.force_special_active and p.force_special_anim_seq == 1 then
		local blast = {
			x = p.x + 4,
			y = p.y + 16,
			r = p.force_radius      
		}

		for a = 0, 1, 0.005 do
			local c = cos(a)
			local s = sin(a)
			
			-- Loop 5 times to create a 5-pixel thick wave front
			for w = 0, 4 do
				-- Current radius layer we are drawing
				local current_r = blast.r - w
				
				-- Target destination: Where we are drawing the warped pixel
				local wave_x = flr(blast.x + c * current_r)
				local wave_y = flr(blast.y + s * current_r)
				
				-- Source location: Grab a pixel from deeper inside the explosion
				-- We subtract 4 more pixels to create a strong outward "refraction" pinch
				local src_x = flr(blast.x + c * (current_r - 4))
				local src_y = flr(blast.y + s * (current_r - 4))
				
				-- Grab and rewrite the pixel data
				local col = pget(src_x, src_y)
				pset(wave_x, wave_y, col)
			end
		end
	end
end
	
function handle_player_trigger(p)
	if p.force_special_active then
		return -- don't fire when force special is active
	end

	if p.weapon == 0 and p.weapon_delay == 0 then
		p.weapon_delay = pistol.delay
		handle_player_fire(p)
	end

	if p.weapon == 1 and p.weapon_delay == 0 then
		p.weapon_delay = rifle.delay
		handle_player_fire(p)
	end
end

function draw_player(p)
	-- head
	if bounce_count < bounce_delay then
		bounce_count += 1
	else
		bounce_count = 0
		bounce = not bounce
	end

	local bounce_height = 0
	if bounce then
		bounce_height = 1
	end

	if p.name == "chad" then
		local c_head_x = p.x - 8

		if p.flip_sprite then
			c_head_x = p.x + 8
		end

		if p.trigger or (p.force_special_active and p.force_special_anim_seq == 1) then
			spr(p.sprites.head2, c_head_x, p.y + bounce_height, 2, 2, p.flip_sprite, false)
		else
			spr(p.sprites.head, c_head_x, p.y + bounce_height, 2, 2, p.flip_sprite, false)
		end
	else
		if p.flip_sprite then
			if p.recoil or (p.force_special_active and p.force_special_anim_seq == 1) then
				spr(p.sprites.head2, p.x + 8, p.y + bounce_height, 1, 2, p.flip_sprite, false)
			else
				spr(p.sprites.head, p.x + 8, p.y + bounce_height, 1, 2, p.flip_sprite, false)
			end
		else
			if p.recoil or (p.force_special_active and p.force_special_anim_seq == 1) then
				spr(p.sprites.head2, p.x, p.y + bounce_height, 1, 2, p.flip_sprite, false)
			else
				spr(p.sprites.head, p.x, p.y + bounce_height, 1, 2, p.flip_sprite, false)
			end
			
		end
	end

	--torso
	if p.flip_sprite then
		spr(p.sprites.torso, p.x + 7, p.y + 16 + bounce_height, 1, 1, p.flip_sprite, false)
	else
		spr(p.sprites.torso, p.x + 1, p.y + 16 + bounce_height, 1, 1, p.flip_sprite, false)
	end

	local recoil_mult = 0

	if p.recoil then
		recoil_mult = 2
		p.recoil = false
	end

	-- arm
	if p.force_special_active and p.force_special_anim_seq == 0 then
		if p.flip_sprite then
			spr(p.sprites.arm_up, p.x + 10, p.y + bounce_height, 1, 2, p.flip_sprite, false)
			spr(52, p.x, p.y - 2 + bounce_height, 4, 1, true, false)
		else
			spr(p.sprites.arm_up, p.x, p.y + bounce_height, 1, 2, p.flip_sprite, false)
			spr(52, p.x - 13, p.y - 2 + bounce_height, 4, 1, false, false)
		end
	elseif p.force_special_active and p.force_special_anim_seq == 1 then
		if p.flip_sprite then
			spr(p.sprites.arm_out, p.x - 3 + recoil_mult, p.y + 16 + bounce_height, 2, 1, p.flip_sprite, false)
			spr(143, p.x - 6, p.y - 2 + bounce_height, 1, 4, true, false)
		else
			spr(p.sprites.arm_out, p.x + 3 - recoil_mult, p.y + 16 + bounce_height, 2, 1, p.flip_sprite, false)
			spr(143, p.x + 13, p.y - 2 + bounce_height, 1, 4, false, false)
		end
	else
		if p.flip_sprite then
			spr(p.sprites.arm_out, p.x - 3 + recoil_mult, p.y + 16 + bounce_height, 2, 1, p.flip_sprite, false)
		else
			spr(p.sprites.arm_out, p.x + 3 - recoil_mult, p.y + 16 + bounce_height, 2, 1, p.flip_sprite, false)
		end
	end

	if p.stepping then
		spr(p.sprites.legs_moving, p.x, p.y + 24, 2, 1, p.flip_sprite, false)
	else
		if p.flip_sprite then
			spr(p.sprites.legs_standing, p.x + 7, p.y + 24, 1, 1, p.flip_sprite, false)
		else
			spr(p.sprites.legs_standing, p.x + 1, p.y + 24, 1, 1, p.flip_sprite, false)
		end
	end
	
end

function draw_player_shadow(p)
	if not p.shadow then return end

	if p.flip_sprite then
		spr(238, p.x + 3, p.y + 24, 2, 2, false, false)
	else
		spr(238, p.x - 3, p.y + 24, 2, 2, false, false)
	end
end

function draw_santa()
	spr(238, santa.x + 3, santa.y + 32, 4, 4, false, false) -- shadow
	spr(96, santa.x - 2, santa.y, 2, 2, false, false) -- head
	spr(98, santa.x, santa.y + 16, 2, 2, false, false) -- body
	spr(105, santa.x + 5, santa.y + 32, 1, 1, false, false) -- feet
	-- spr(106, santa.x + 5, santa.y + 32, 1, 1, false, false) -- feet walking
end