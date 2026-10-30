enemies = {}

e_spawn = false
enemey_spawn_stage_count = 0 -- stage cnt
enemy_spawn_delay_count = 0 
enemy_health = 20
enemy_head_sprite_list = {132, 133, 148, 149, 164, 165, 180, 181}
enemy_dead_frame = 40 -- how long before removing from table to avoid out of mem error

function spawn_enemy(speed)
	enemy = {
		sprite_number = 144,
		sprite_number_face = 132, --rnd(enemy_head_sprite_list),
		speed = speed, -- movement speed
		flip_sprite = true,
		x = camera_x + screen_size + 16,
		y = rnd(48) + 48,
		w = 8,
		h = 32,
		death_animation_frame_delay = 7,
		death_animation_frame_count = 0, -- death animation frame count
		dead = false,
		hit = false,
		hit_anim_delay = 30,
		hit_anim_count = 0,
		animation_frame_delay = 7, -- animation frame delay
		animation_frame_count = 0,
		destination = flr(rnd(2)) + 1, -- 1 = player 1, 2 = player 2
		damage = 0,
		max_damage = 10,
		dead_frames = 0,
		fire_delay = 10,
		fire_delay_count = 0
	}

	if enemy.x > camera_x + screen_size/2 then
		enemy.flip_sprite = false
	end
	
	-- if wall spawn support then 25% chance of wall spawn
	if stages[stage].enemy_wall_spawn_range and rnd() < 0.25 then
	 	local r = 1 + flr(rnd(#stages[stage].enemy_wall_spawn_range)) -- which wall opening
	 	local xr = stages[stage].enemy_wall_spawn_range[r] -- get range and index r
	 	local xs = xr[1] + rnd(xr[2] - xr[1]) -- choose spawn point in range

  		enemy.x = xs * 8 + camera_x
  		enemy.y = 42
	end
	
	add(enemies, enemy)
end

function update_enemies()
	p1.enemy_collision = false
	p2.enemy_collision = false
	for enemy in all(enemies) do
		if enemy.dead then
			if enemy.dead_frames >= enemy_dead_frame then
				del(enemies, enemy)
			else
				enemy.dead_frames += 1
				enemy.death_animation_frame_count += 1
			
				if enemy.death_animation_frame_count >= enemy.death_animation_frame_delay then
					enemy.death_animation_frame_count = 0
				
					if enemy.sprite_number == 134 then
						enemy.sprite_number = 186
					end
				end
			end
		else
			enemy.animation_frame_count += 1
			
			if enemy.hit then
				if enemy.hit_anim_count < enemy.hit_anim_delay then
					enemy.hit_anim_count += 1
					enemy.sprite_number_face = 148
				else
					enemy.sprite_number_face = 132
					enemy.hit_anim_count = 0
					enemy.hit = false
				end

				if enemy.damage >= enemy.max_damage then
					enemy.dead = true
                	enemy.sprite_number = 134
				end
			else
				-- walk and fire	
				seek_players(enemy)

				if enemy.animation_frame_count >= enemy.animation_frame_delay then
					enemy.animation_frame_count = 0
					
					-- enemy animation
					if enemy.sprite_number == 144 then
						enemy.sprite_number = 146
					elseif enemy.sprite_number == 146 then
						enemy.sprite_number = 144
					end
				end 
			end
		end
	end
end

function seek_players(enemy)
	if p1.x < enemy.x - enemy.speed 
		and p2.x < enemy.x - enemy.speed then
		enemy.x -= enemy.speed
		enemy.flip_sprite = false

		-- pushing effect
		if enemy.x - p1.x - p1.w < 8 -- x collision
			and (abs(enemy.y - p1.y) < 32) then -- y collision
			p1.enemy_collision = true
		end

		if enemy.x - p2.x - p2.w < 8 -- x collision
			and (abs(enemy.y - p2.y) < 32) then -- y collision
			p2.enemy_collision = true
		end
	elseif p1.x > enemy.x + enemy.speed 
		and p2.x > enemy.x + enemy.speed then
		enemy.x += enemy.speed
		enemy.flip_sprite = true
	end

	-- prevent firing from off screen
	if abs(p1.x - enemy.x) < screen_size - 30 or abs(p2.x - enemy.x) < screen_size - 30 then
		handle_enemy_fire(enemy)
	end
end

function handle_enemy_fire(e)
	if e.fire_delay_count < e.fire_delay then
		e.fire_delay_count += 1
	else
		e.fire_delay_count = 0

		local xd = 8
		if not e.flip_sprite then
			xd = -xd
		end
		sfx(0)
		spawn_dart(e.x+4, e.y+6, xd, -1, true)
	end
end

function draw_enemies()
	for enemy in all(enemies) do
		if enemy.sprite_number == -1 then
			-- shotgun death, don't draw
		elseif enemy.sprite_number == 186 then
			-- wide instead of tall sprite
			spr(enemy.sprite_number, enemy.x, enemy.y+14, 4, 1, enemy.flip_sprite, false)
		elseif enemy.sprite_number == 134 then
			-- wide instead of tall sprite and need to lower it
			spr(enemy.sprite_number, enemy.x, enemy.y-8, 4, 4, enemy.flip_sprite, false)
		elseif enemy.sprite_number == 150 then
			spr(enemy.sprite_number, enemy.x, enemy.y, 2, 3, enemy.flip_sprite, false)
		else
			-- body
			spr(enemy.sprite_number, enemy.x, enemy.y, 2, 3, enemy.flip_sprite, false)
			-- head
			if enemy.flip_sprite then
				spr(enemy.sprite_number_face, enemy.x, enemy.y - 4, 1, 1, enemy.flip_sprite, false)
			else
				spr(enemy.sprite_number_face, enemy.x + 8, enemy.y - 4, 1, 1, enemy.flip_sprite, false)
			end
		end
	end
end

function enemy_die(enemy, weapon, flip, rotate)
 	enemy.dead = true

	if weapon == 1 or weapon == 7 or weapon == nil then
		enemy.sprite_number = -1
	else
		enemy.sprite_number = 150
	end

	if weapon == nil then
		return -- early exit, no particles
	end
   
	local particle_count = 10

	if weapon == 1 or weapon == 7 then
		particle_count = 30
	end
end