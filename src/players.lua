player_move = false

init_jenn_x = 45
init_chad_x = 67
init_player_y = 64

camera_shake_offset = 0
camera_shake_offset_amount = 1

bot_nerf_multiplier = 1.5 

bounce_delay = 18
bounce_count = 0
bounce = false

displaying_weapons = false
displaying_weapons_delay = 10
displaying_weapons_count = 0

j = {
	name = "jenn",
	sprites = {
		head = 2,
		head2 = 8,
		torso = 34,
		legs_standing = 48,
		legs_moving = 50,
		arm_out = 38,
		arm_up = 3
	},
	yeet_frame_count = 0, 
	yeet_frame_delay = 5,
	flip_sprite = true, 
	x = init_jenn_x, 
	y = init_player_y, 
	last_animation_frame_x = init_jenn_x, 
	last_animation_frame_y = init_player_y, 
	animation_frame_delay = 5, 
	weapon = 0, -- weapon: 0 pistol, 1 shotgun, 2 oozie, 3 burst rifle, 4 auto rifle, 5 hunting rifle, 6 revolver, 7 long shotgun
	weapon_delay = 0,
	trigger = false, -- trigger pressed,
	kill_count = 0,
	stepping = true, -- movement sprite
	yeeting = false,
	recoil = false, -- arm movement when firing
	recoil_delay = 1,
	recoil_count = 0,
	speed = 1,
	weapon_list_index = 1
}

c = {
	name = "chad",
	sprites = {
		head = 0,
		head2 = 9,
		torso = 32,
		legs_standing = 48,
		legs_moving = 50,
		arm_out = 22,
		arm_up = 33
	},
	yeet_frame_count = 0, 
	yeet_frame_delay = 5, 
	flip_sprite = false, 
	x = init_chad_x,
	y = init_player_y, 
	last_animation_frame_x = init_chad_x, 
	last_animation_frame_y = init_player_y, 
	animation_frame_delay = 5, 
	weapon = 0, -- weapon: 0 pistol, 1 shotgun, 2 oozie, 3 burst rifle, 4 auto rifle, 5 hunting rifle, 6 revolver, 7 long shotgun
	weapon_delay = 0,
	trigger = false, -- trigger pressed
	kill_count = 0,
	stepping = true, -- movement sprite
	yeeting = false,
	recoil = false, -- arm movement when firing
	recoil_delay = 1,
	recoil_count = 0,
	speed = 1,
	weapon_list_index = 1
}

p1 = j
p2 = c
coop = false

shotgun = {
	id = 1,
	delay = 10,
	damage = 20,
	sprite = 20,
	length = 1,
	found = false,
	x = 94 * 8,
	y = 4 * 8
}

long_shotgun = {
	id = 7,
	delay = 20,
	damage = 20,
	sprite = 20,
	length = 2,
	found = false,
	x = 30 * 8,
	y = 11 * 8
}

pistol = {
	id = 0,
	delay = 4,
	damage = 5,
	sprite = 4,
	length = 1,
	found = true
}

oozie = {
	id = 2,
	delay = 0,
	damage = 2,
	sprite = 5,
	length = 1,
	found = false,
	x = 120 * 8,
	y = 9 * 8
}

burst_rifle = {
	id = 3,
	delay = 3,
	damage = 2,
	sprite = 36,
	length = 2,
	found = false,
	x = 78 * 8,
	y = 4 * 8
}

auto_rifle = {
	id = 4,
	delay = 0,
	damage = 3,
	sprite = 7,
	length = 1,
	found = false,
	x = 106 * 8,
	y = 4 * 8
}

hunting_rifle = {
	id = 5,
	delay = 20,
	damage = 10,
	sprite = 52,
	length = 2,
	found = false,
	x = 40 * 8,
	y = 10 * 8
}

revolver = {
	id = 6,
	delay = 10,
	damage = 10,
	sprite = 6,
	length = 1,
	found = false,
	x = 84 * 8,
	y = 4 * 8
}

-- 0 pistol, 1 shotgun, 2 oozie, 3 burst rifle, 4 auto rifle, 5 hunting rifle, 6 revolver, 7 long shotgun
weapon_list = {pistol, shotgun, oozie, burst_rifle, auto_rifle, hunting_rifle, revolver, long_shotgun}

function update_p2()
	enemy_collision(p2)

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

	-- Ensure player gets first shots
	if p1.kill_count < 5 then
		return -- early exit
	end

 	if c then
		if c < 0 then
	  		p2.flip_sprite = true	  
	  		if p2.x > camera_x+32 then
	   			p2.x -= 1
	  		end
	 	else
	  		p2.flip_sprite = false	  	  
	  		if p2.x < camera_x+screen_size-32 then
	   			p2.x += 1
	  		end
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

	local hbox = 4 -- hit box
	if p2.weapon == 1 or p2.weapon == 2 or p2.weapon == 7 then
		hbox = 8
	end
 
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
 
 	enemy_collision(p)

	-- yeet
	if p.yeeting then
 		p.yeet_frame_count += 1
 	
		if p.yeet_frame_count >= p.yeet_frame_delay then
			p.yeet_frame_count = 0
			p.yeeting = false
		end
 	end
end

function draw_boss(armed)
 	if armed then
	 	spr(36,boss.x,boss.y,2,2,false,false)
 	else
  		spr(38,boss.x,boss.y,2,2,false,false)
 	end
end

function enemy_collision(p)
	if p.yeeting then
		return -- early exit
	end
	
	for e in all(enemies) do
		if not e.dead and not e.yeeted and e.x > p.x-8 and  e.x < p.x+8 and e.y-4 > p.y-8 and e.y-4 < p.y+8 then
			p.yeeting = true
			e.yeeted = true
			e.yeet_sprite_flip = p.flip_sprite
			p.kill_count += 1
		end
	end 
end

function check_weapon_found()
	for w in all(weapon_list) do
		if not w.found and ((w.x > p1.x and w.x < p1.x + 16) and (w.y > p1.y and w.y < p1.y + 32)
			or (w.x > p2.x and w.x < p2.x + 16) and (w.y > p2.y and w.y < p2.y + 32)) then
			w.found = true
			p1.weapon = w.id
			p2.weapon = w.id
			sfx(57)
		end
	end
end

function update_player_move(p, ctrl)
	if p.yeeting then
		return -- early exit
	end

	-- ctrl is the controller maping
	if btn(0, ctrl) 
		and p.x > 0 -- not out of bounds
		and p.x > camera_x + 16 then -- in camera frame
		p.flip_sprite = true 
		p.x -= p.speed

		if p2.x < camera_x + screen_size and p1.x < camera_x + screen_size then
			camera_x -= p.speed
		end
	elseif btn(1, ctrl) 
		and p.x < screen_size * map_width - 16 -- not past the end of the map
		and p.x < camera_x + screen_size - 16 then -- both players in camera frame
		p.flip_sprite = false
		p.x += p.speed
		
		if p2.x > camera_x and p1.x > camera_x then
			camera_x += p.speed
		end
	end
 
	if btn(2, ctrl) and p.y > 24 then
		p.y -= p.speed
	elseif btn(3, ctrl) and p.y < screen_size - 43 then
		p.y += p.speed
	end
 
	if btn(🅾️, ctrl) then
		handle_player_trigger(p)
 	else
  		p.trigger = false
 	end
	
	if btnp(❎, ctrl) then
		if at_bar1(p) then 
			for i=1, #weapon_list do
				p.weapon_list_index += 1
				if p.weapon_list_index > #weapon_list then
					p.weapon_list_index = 1
				end
				if weapon_list[p.weapon_list_index].found then
					p.weapon = weapon_list[p.weapon_list_index].id
					break
				end
			end
		end
	end

	if btn(❎, ctrl) and not displaying_weapons then
		p.speed = 2

		if not coop then
			p2.speed = 2
		end
	else
		p.speed = 1

		if not coop then
			p2.speed = 1
		end
	end

	if p.weapon == 3 and p.weapon_delay > 0 then
		handle_player_fire(p)
	end

	-- bar proxy detection
	if at_bar1(p) then
		displaying_weapons = true
		displaying_weapons_count = 0
	end
end

function center_camera_on_players()
	-- local camera_center = flr(camera_x + screen_size/2)
	local players_center = flr((p1.x + p2.x) / 2)

	camera_x = players_center - screen_size/2
end

function at_bar1(p)
	if p.x > 43 * 8 and p.x < 56 * 8 and p.y < 30 then 
		return true
	else
		return false
	end
end

function draw_info_bar(count)
	rectfill(camera_x, screen_size - 12, camera_x + screen_size, screen_size, 0)
	spr(enemy_head_sprite_list[2], camera_x + 5, screen_size - 10, 1, 1, true, false)
	
	local color = 6
	if count >= 100 then color = 10 end
	print(100, camera_x + 34, screen_size - 6, color)
	rectfill(camera_x + 39, screen_size - 9, camera_x + 39.5, screen_size - 8, color)

	color = 6
	if count >= 250 then color = 9 end
	print(250, camera_x + 48, screen_size - 6, color)
	rectfill(camera_x + 53, screen_size - 9, camera_x + 53.5, screen_size - 8, color)

	color = 6
	if count >= 500 then color = 8 end
	print(500, camera_x + 70, screen_size - 6, color)
	rectfill(camera_x + 75, screen_size - 9, camera_x + 75.5, screen_size - 8, color)

	color = 6
	if count >= 1000 then color = 2 end
	print(1000, camera_x + 113, screen_size - 6, color)
	rectfill(camera_x + 120, screen_size - 9, camera_x + 120.5, screen_size - 8, color)
	
	-- bar starts at camera_x + 30 and ends at camera_x + 119.5, which is 89.5 in length
	local bar_start = camera_x + 30
	local percent_complete = count / 1000
	local bar_length = flr(percent_complete * 89.5)

	if count >= 1000 then 
		color = 2
	elseif count >= 500 then 
		color = 8
	elseif count >= 250 then 
		color = 9
	elseif count >= 100 then 
		color = 10
	else
		color = 11
	end
	print(count, camera_x + 14, screen_size - 10, color)
	rectfill(bar_start, screen_size - 10, bar_start + bar_length, screen_size - 9.5, color)
end

function handle_player_fire(p)
	if p.recoil_count < p.recoil_delay then
		p.recoil = true
		p.recoil_count += 1
	else
		p.recoil = false
		p.recoil_count = 0
	end
	if p.weapon == 0 or p.weapon == 3 or p.weapon == 5 or p.weapon == 6 then
		if p.weapon == 0 then
			sfx(0)
		elseif p.weapon == 3 then
			sfx(4)
		elseif p.weapon == 5 or p.weapon == 6 then
			sfx(5)

			if p.flip_sprite then
				p.x += 3
				camera_x += 3
			else
				p.x -= 3
				camera_x -= 3
			end

			if p.flip_sprite then
				camera_x -= camera_shake_offset_amount
				camera_shake_offset -= camera_shake_offset_amount
			else
				camera_x += camera_shake_offset_amount
				camera_shake_offset += camera_shake_offset_amount
			end
		end

		enemy_coll_detect(p)

		local xs = 15
		if p.flip_sprite then
			xs = -xs
		end
		add(particles, particle(p.x+4, p.y + 15, xs, 0, 0, 7))
	elseif p.weapon == 1 or p.weapon == 7 then
		if p.flip_sprite then
				p.x += 3
				camera_x += 3
			else
				p.x -= 3
				camera_x -= 3
			end

		sfx(1)

		for i=1,10 do
			local ys = rnd(1 - -1) + -1
			local xs = 12 + rnd(3)
			if p.flip_sprite then
				xs = -xs
			end
			add(particles, particle(p.x+4, p.y + 15, xs, ys, 0, 14))
		end

		if p.flip_sprite then
			camera_x -= camera_shake_offset_amount
			camera_shake_offset -= camera_shake_offset_amount
		else
			camera_x += camera_shake_offset_amount
			camera_shake_offset += camera_shake_offset_amount
		end
	elseif p.weapon == 2 or p.weapon == 4 then
		if p.weapon == 2 then
			sfx(0)
		elseif p.weapon == 4 then
			sfx(4)
		end
		
		local ys = rnd(0.5 - -0.5) + -0.5
		local xs = 14 + rnd(1)
		if p.flip_sprite then
			xs = -xs
		end
		add(particles, particle(p.x+4, p.y + 15, xs, ys, 0, 14))
	end
	enemy_coll_detect(p)
end

function draw_player_weapon(p)
	if p.yeeting then
		return -- early exit
	end

	local recoil_mult = 0

	if p.recoil then
		recoil_mult = 2
	end

	local bounce_height = 0
	if bounce then
		bounce_height = 1
	end

	if p.weapon == 0 then
		if p.flip_sprite then
			spr(4, p.x - 1 + recoil_mult, p.y + 12 + bounce_height, 1, 1, true, false)
		else
			spr(4, p.x + 9 - recoil_mult, p.y + 12 + bounce_height, 1, 1, false, false)
		end
	elseif p.weapon == 1 then
		if p.flip_sprite then
			spr(20, p.x - 2 + recoil_mult, p.y + 11 + bounce_height, 1, 1, true, false)
		else
			spr(20, p.x + 10 - recoil_mult, p.y + 11 + bounce_height, 1, 1, false, false)
		end
	elseif p.weapon == 2 then
		if p.flip_sprite then
			spr(5, p.x - 1 + recoil_mult, p.y + 12 + bounce_height, 1, 1, true, false)
		else
			spr(5, p.x + 9 - recoil_mult, p.y + 12 + bounce_height, 1, 1, false, false)
		end
	elseif p.weapon == 3 then
		if p.flip_sprite then
			spr(36, p.x - 8 + recoil_mult, p.y + 11 + bounce_height, 2, 1, true, false)
		else
			spr(36, p.x + 8 - recoil_mult, p.y + 11 + bounce_height, 2, 1, false, false)
		end
	elseif p.weapon == 4 then
		if p.flip_sprite then
			spr(7, p.x + recoil_mult, p.y + 11 + bounce_height, 1, 1, true, false)
		else
			spr(7, p.x + 8 - recoil_mult, p.y + 11 + bounce_height, 1, 1, false, false)
		end
	elseif p.weapon == 5 then
		if p.flip_sprite then
			spr(52, p.x - 8 + recoil_mult, p.y + 12 + bounce_height, 2, 1, true, false)
		else
			spr(52, p.x + 8 - recoil_mult, p.y + 12 + bounce_height, 2, 1, false, false)
		end
	elseif p.weapon == 6 then
		if p.flip_sprite then
			spr(6, p.x - 3 + recoil_mult, p.y + 11 + bounce_height, 1, 1, true, false)
		else
			spr(6, p.x + 11 - recoil_mult, p.y + 11 + bounce_height, 1, 1, false, false)
		end
	elseif p.weapon == 7 then
		if p.flip_sprite then
			spr(20, p.x - 8 + recoil_mult, p.y + 11 + bounce_height, 2, 1, true, false)
		else
			spr(20, p.x + 10 - recoil_mult, p.y + 11 + bounce_height, 2, 1, false, false)
		end
	end
end

function handle_player_trigger(p)
	if not p.yeeting then
		if not p.trigger then
			p.trigger = true

			if p.weapon == 0 and p.weapon_delay == 0 then
				p.weapon_delay = pistol.delay
				handle_player_fire(p)
			elseif p.weapon == 1 and p.weapon_delay == 0 then
				p.weapon_delay = shotgun.delay
				handle_player_fire(p)
			elseif p.weapon == 3 and p.weapon_delay == 0 then
				p.weapon_delay = burst_rifle.delay
				handle_player_fire(p)
			elseif p.weapon == 5 and p.weapon_delay == 0 then
				p.weapon_delay = hunting_rifle.delay
				handle_player_fire(p)
			elseif p.weapon == 6 and p.weapon_delay == 0 then
				p.weapon_delay = revolver.delay
				handle_player_fire(p)
			elseif p.weapon == 7 and p.weapon_delay == 0 then
				p.weapon_delay = long_shotgun.delay
				handle_player_fire(p)
			end
		end

		if p.weapon == 2 or p.weapon == 4 then
			p.weapon_delay = 0
			handle_player_fire(p)
		end
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
		if p.trigger or p.yeeting then
			if p.recoil then
				spr(p.sprites.head2, p.x-1, p.y + bounce_height, 2, 2, p.flip_sprite, false)
			else
				spr(p.sprites.head2, p.x, p.y + bounce_height, 2, 2, p.flip_sprite, false)
			end
		else
			spr(p.sprites.head, p.x, p.y + bounce_height, 2, 2, p.flip_sprite, false)
		end
	else
		if p.flip_sprite then
			if p.recoil or p.yeeting then
				spr(p.sprites.head2, p.x + 8, p.y + bounce_height, 1, 2, p.flip_sprite, false)
			else
				spr(p.sprites.head, p.x + 8, p.y + bounce_height, 1, 2, p.flip_sprite, false)
			end
		else
			if p.recoil or p.yeeting then
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
	if p.flip_sprite then
		if p.yeeting then
			spr(p.sprites.arm_up, p.x + 5, p.y + 5 + bounce_height, 1, 2, p.flip_sprite, false)
			say(p.x, p.y, "YEEEEEET!", 1, false, false)
		else
			spr(p.sprites.arm_out, p.x - 3 + recoil_mult, p.y + 16 + bounce_height, 2, 1, p.flip_sprite, false)
		end
	else
		if p.yeeting then
			spr(p.sprites.arm_up, p.x + 3, p.y + 5 + bounce_height, 1, 2, p.flip_sprite, false)
			say(p.x, p.y, "YEEEEEET!", false, false, false)
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