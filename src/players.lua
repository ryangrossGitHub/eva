player_move, bounce, coop, upgrade_item_fall, first_o_press = false, false, false, false, false

init_jenn_x = 9*8
init_jenn_y = 74
init_chad_x = 7*8
init_chad_y = 48

camera_shake_offset = 0

bounce_delay = 18
bounce_count = 0

p2_boss_dir = 0

upgrade_item_y = 0

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
	flip_sprite, trigger, recoil, enemy_collision, enemy_melee_collision, force_special_active, fall, respawn = false, false, false, false, false, false, false, false,
	x = init_jenn_x, 
	y = init_jenn_y, 
	w = 8,
	h = 32,
	last_animation_frame_x = init_jenn_x, 
	last_animation_frame_y = init_jenn_y, 
	animation_frame_delay = 5, 
	weapon = 0,
	weapon_delay = 0,
	stepping, shadow = true, true, 
	recoil_delay = 1,
	recoil_count = 0,
	speed = 1,
	enemy_melee_collision_dist = 30,
	enemy_melee_collision_dist_count = 0,
	force_special_anim_seq = 0,
	force_special_anim_count = 0,
	force_radius = 0,
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
	flip_sprite, trigger, recoil, enemy_collision, enemy_melee_collision, force_special_active, fall, respawn = false, false, false, false, false, false, false, false,
	x = init_chad_x,
	y = init_chad_y, 
	w = 8,
	h = 32,
	last_animation_frame_x = init_chad_x, 
	last_animation_frame_y = init_chad_y, 
	animation_frame_delay = 5, 
	weapon = 0,
	weapon_delay = 0,
	stepping, shadow = true, true, 
	recoil_delay = 1,
	recoil_count = 0,
	speed = 1,
	enemy_melee_collision_dist = 30,
	enemy_melee_collision_dist_count = 0,
	force_special_anim_seq = 0,
	force_special_anim_count = 0,
	force_radius = 0,
}

santa = {
	x = 90,
	y = 70,
	h = 32,
	w = 16
}

p1 = j
p2 = c

pistol = {
	id = 0,
	delay = 4,
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

	if not p2.fall then
		if p2.y > 60 then
			p2.y -= p2.speed
		elseif p2.y < 40 then
			p2.y += p2.speed
		end
	end

	if boss.y > 8 then
		handle_player_trigger(p2)
	end
end

function closest_enemy()
	local closest = 99
	local c_xdir = 0

	local e_ydir = 0

	local player_weapon_offset = 12

	local hbox = 8 
 
	for e in all(enemies) do
		if not e.dead and e.x > camera_x + 5 and e.x < camera_x + screen_size - 5 then
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
 
	if closest == 99 then 
		return nil, e_ydir
	else
		if e_ydir == 0 then e_ydir = 1 end 
		return c_xdir, e_ydir
	end
end

function update_player_anims(p)
 	if abs(p.x - p.last_animation_frame_x) > p.animation_frame_delay or abs(p.y - p.last_animation_frame_y) > p.animation_frame_delay then
  		p.last_animation_frame_x = p.x
  		p.last_animation_frame_y = p.y
  
  		if p.stepping then
  			p.stepping = false
  		else
			p.stepping = true
		end
 	end
end

function update_player_move(p, ctrl)

	if p.fall then
		p.y += 8
		return 
	end

	local btn_pressed = false

	if btn(0, ctrl) 
		and p.x > left_bound 
		and p.x > camera_x then 
		
		p.flip_sprite = true 
		p.x -= p.speed

		if stage < 8 and p2.x < camera_x + screen_size and p1.x < camera_x + screen_size then
			camera_x -= p.speed
		end
	elseif btn(1, ctrl) 
		and p.x < right_bound 
		and p.x < camera_x + screen_size - 16 
		and not (not p.flip_sprite and p.enemy_collision) then 
		
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
		if stage >= 5 then 
			first_o_press = true
			sfx(3)
			p.force_special_active = true 
		end
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
		sfx(2)
	end

	local boss_delta_left = abs(boss.x - 10 - p.x)
	if  boss_delta_left <= 4 and boss.y > p.y - 26 then
		p.x -= boss_delta_left
		sfx(2)
	end

	local boss_delta_up = abs(boss.y + 22 - p.y)
	if boss_delta_up <= 4 and boss.x + 43 > p.x and boss.x - 10 < p.x then
		p.y += boss_delta_up
		sfx(2)
	end

	return btn_pressed
end

function detect_player_fall(p)
	if p.y > screen_size then
		p.respawn = true
		p.y = -40
		p.x = camera_x + 16
	elseif p.y > 10 * 8 then
		p.shadow, p.fall = false, true
	end

	if p.respawn then
		p.y += (p.y + 75) * 0.07

		if p.y >= 75 then
			p.respawn, p.fall = false, false
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

	local weapon_y = p.y + 11 + bounce_height
	if upgrade_item_fall then
		weapon_y = upgrade_item_y
		upgrade_item_y += 1.5

		if upgrade_item_y > p.y + 8 then
			upgrade_item_fall = false
			upgrade_item_y = 0
			sfx(1)
		end
	end

	if p.force_special_active then
		return 
	elseif stage == 5 and upgrade_item_fall then
		spr(143, p.x, weapon_y, 1, 4)
	elseif p.weapon == 0 then
		if p.flip_sprite then
			spr(pistol.sprite, p.x - 1 + recoil_mult, weapon_y + 1, 1, 1, true)
		else
			spr(pistol.sprite, p.x + 9 - recoil_mult, weapon_y + 1, 1, 1)
		end
	elseif p.weapon == 1 then
		if p.flip_sprite then
			spr(rifle.sprite, p.x - 8 + recoil_mult, weapon_y, rifle.length, 1, true)
		else
			spr(rifle.sprite, p.x + 8 - recoil_mult, weapon_y, rifle.length, 1)
		end
	end
end

function update_player_force(p)
	if p.force_special_active then
		p.force_special_anim_count += 1

		if p.force_special_anim_count == 10 then
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
				kill_enemy(e, 170)
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
			
			for w = 0, 4 do
				local current_r = blast.r - w
				
				local wave_x = flr(blast.x + c * current_r)
				local wave_y = flr(blast.y + s * current_r)
				
				local src_x = flr(blast.x + c * (current_r - 4))
				local src_y = flr(blast.y + s * (current_r - 4))
				
				local col = pget(src_x, src_y)
				pset(wave_x, wave_y, col)
			end
		end
	end
end
	
function handle_player_trigger(p)
	if p.force_special_active then
		return 
	end

	if not p.trigger then
		p.trigger = true
		if p.weapon == 0 and p.weapon_delay == 0 then
			p.weapon_delay = pistol.delay
			handle_player_fire(p)
		end
	end

	if p.weapon == 1 and p.weapon_delay == 0 then
		p.weapon_delay = rifle.delay
		handle_player_fire(p)
	end
end

function draw_player(p)
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

	if p.force_special_active and p.force_special_anim_seq == 0 then
		if p.flip_sprite then
			spr(p.sprites.arm_up, p.x + 10, p.y + bounce_height, 1, 2, p.flip_sprite, false)
			spr(52, p.x, p.y - 2 + bounce_height, 4, 1, true)
		else
			spr(p.sprites.arm_up, p.x, p.y + bounce_height, 1, 2, p.flip_sprite, false)
			spr(52, p.x - 13, p.y - 2 + bounce_height, 4, 1)
		end
	elseif p.force_special_active and p.force_special_anim_seq == 1 then
		if p.flip_sprite then
			spr(p.sprites.arm_out, p.x - 3 + recoil_mult, p.y + 16 + bounce_height, 2, 1, p.flip_sprite, false)
			spr(143, p.x - 6, p.y - 2 + bounce_height, 1, 4, true)
		else
			spr(p.sprites.arm_out, p.x + 3 - recoil_mult, p.y + 16 + bounce_height, 2, 1, p.flip_sprite, false)
			spr(143, p.x + 13, p.y - 2 + bounce_height, 1, 4)
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
		spr(238, p.x + 3, p.y + 24, 2, 2)
	else
		spr(238, p.x - 3, p.y + 24, 2, 2)
	end
end

function draw_santa()
	spr(238, santa.x + 3, santa.y + 32, 4, 4) 
	spr(96, santa.x - 2, santa.y, 2, 2) 
	spr(98, santa.x, santa.y + 16, 2, 2) 
	spr(105, santa.x + 5, santa.y + 32, 1, 1)
end