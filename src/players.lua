player_move = false

init_jenn_x = 40
init_chad_x = 65
init_player_y = 64

camera_shake_offset = 0
camera_shake_offset_amount = 1

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
	flip_sprite = true, 
	x = init_jenn_x, 
	y = init_player_y, 
	w = 8,
	h = 32,
	last_animation_frame_x = init_jenn_x, 
	last_animation_frame_y = init_player_y, 
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
	enemy_collision = false
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
	flip_sprite = false, 
	x = init_chad_x,
	y = init_player_y, 
	w = 8,
	h = 32,
	last_animation_frame_x = init_chad_x, 
	last_animation_frame_y = init_player_y, 
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
	enemy_collision = false
}

p1 = j
p2 = c
coop = false

pistol = {
	id = 0,
	delay = 4,
	damage = 5,
	sprite = 4,
	length = 1,
	found = true
}

rifle = {
	id = 1,
	delay = 3,
	damage = 2,
	sprite = 36,
	length = 2,
	found = false,
	x = 30 * 8,
	y = 11 * 8
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

function draw_boss(armed)
 	if armed then
	 	spr(36,boss.x,boss.y,2,2,false,false)
 	else
  		spr(38,boss.x,boss.y,2,2,false,false)
 	end
end

function check_weapon_found()
	for w in all(weapon_list) do
		if not w.found and ((w.x > p1.x and w.x < p1.x + 16) and (w.y > p1.y and w.y < p1.y + 32)
			or (w.x > p2.x and w.x < p2.x + 16) and (w.y > p2.y and w.y < p2.y + 32)) then
			w.found = true
			p1.weapon = w.id
			p2.weapon = w.id
		end
	end
end

function update_player_move(p, ctrl)
	-- ctrl is the controller maping
	if btn(0, ctrl) 
		and p.x > 0 -- not out of bounds
		and p.x > camera_x then -- in camera frame
		p.flip_sprite = true 
		p.x -= p.speed

		if p2.x < camera_x + screen_size and p1.x < camera_x + screen_size then
			camera_x -= p.speed
		end
	elseif btn(1, ctrl) 
		and p.x < screen_size * map_width - 16 -- not past the end of the map
		and p.x < camera_x + screen_size - 16 -- both players in camera frame
		and not (not p.flip_sprite and p.enemy_collision) then -- can't move through enemies
		p.flip_sprite = false
		p.x += p.speed
		
		if p2.x > camera_x and p1.x > camera_x then
			camera_x += p.speed
		end
	end
 
	if btn(2, ctrl) and p.y > 24 then
		p.y -= p.speed
	elseif btn(3, ctrl) and p.y < screen_size - 33 then
		p.y += p.speed
	end
 
	if btn(🅾️, ctrl) then
		handle_player_trigger(p)
 	else
  		p.trigger = false
 	end
	
	if btnp(❎, ctrl) then
		-- if not speaking() then
		-- 	say("_/-1.67/_/g/-1.27/3/eh/-1.69/_/t/-1.12/dh/-1.33/ae/-1.69/_/t/-1.12/3/eh/-1.20/l/-1.20/f")
		-- end
		-- 	for i=1, #weapon_list do
		-- 		p.weapon_list_index += 1
		-- 		if p.weapon_list_index > #weapon_list then
		-- 			p.weapon_list_index = 1
		-- 		end
		-- 		if weapon_list[p.weapon_list_index].found then
		-- 			p.weapon = weapon_list[p.weapon_list_index].id
		-- 			break
		-- 		end
		-- 	end
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
	-- add(particles, particle(p.x+4, p.y + 15, xs, 0, 9, 7, nil, p.flip_sprite))
	spawn_dart(p.x+4, p.y + 15, xd, -1, false)
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

	if p.weapon == 0 then
		if p.flip_sprite then
			spr(4, p.x - 1 + recoil_mult, p.y + 12 + bounce_height, 1, 1, true, false)
		else
			spr(4, p.x + 9 - recoil_mult, p.y + 12 + bounce_height, 1, 1, false, false)
		end
	elseif p.weapon == 1 then
		if p.flip_sprite then
			spr(rifle.sprite, p.x - 8 + recoil_mult, p.y + 11 + bounce_height, rifle.length, 1, true, false)
		else
			spr(rifle.sprite, p.x + 8 - recoil_mult, p.y + 11 + bounce_height, rifle.length, 1, false, false)
		end
	end
end

function handle_player_trigger(p)
	if not p.trigger then
		p.trigger = true

		if p.weapon == 0 and p.weapon_delay == 0 then
			p.weapon_delay = pistol.delay
			handle_player_fire(p)
		end
	end

	if p.weapon == 1 then
		p.weapon_delay = 0
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

		if p.trigger then
			spr(p.sprites.head2, c_head_x, p.y + bounce_height, 2, 2, p.flip_sprite, false)
		else
			spr(p.sprites.head, c_head_x, p.y + bounce_height, 2, 2, p.flip_sprite, false)
		end
	else
		if p.flip_sprite then
			if p.recoil then
				spr(p.sprites.head2, p.x + 8, p.y + bounce_height, 1, 2, p.flip_sprite, false)
			else
				spr(p.sprites.head, p.x + 8, p.y + bounce_height, 1, 2, p.flip_sprite, false)
			end
		else
			if p.recoil then
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
		spr(p.sprites.arm_out, p.x - 3 + recoil_mult, p.y + 16 + bounce_height, 2, 1, p.flip_sprite, false)
	else
		spr(p.sprites.arm_out, p.x + 3 - recoil_mult, p.y + 16 + bounce_height, 2, 1, p.flip_sprite, false)
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