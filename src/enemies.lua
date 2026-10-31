enemies = {}

e_spawn = false
enemey_spawn_stage_count = 0 -- stage cnt
enemy_spawn_delay_count = 0 
enemy_health = 20
enemy_head_sprite_list = {132, 133, 148, 149, 164, 165, 180, 181}
enemy_dead_frame = 60 -- how long before removing from table to avoid out of mem error

function spawn_enemy(speed)
	enemy = {
		sprite_number = 144,
		sprite_number_face = 132, --rnd(enemy_head_sprite_list),
		speed = speed, -- movement speed
		rotate_sprite = false,
		x = 38 * 8,
		y = rnd(40) + 48,
		w = 8,
		h = 32,
		death_animation_frame_delay = 4,
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

					sfx(0)
					spawn_dart(enemy.x+18, enemy.y, rnd(4) - 2, -3, true)

					if enemy.sprite_number == 170 then
						enemy.sprite_number = 138
					elseif enemy.sprite_number == 138 then
						enemy.sprite_number = 170
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
                	enemy.sprite_number = 170
				end
			else
				-- walk
				enemy.x -= enemy.speed

				-- register pushing effect on player1 collision
				if enemy.x - p1.x - p1.w < 8 -- x collision
					and (abs(enemy.y - p1.y) < 32) then -- y collision
					p1.enemy_collision = true
				end

				-- register pushing effect on player2 collision
				if enemy.x - p2.x - p2.w < 8 -- x collision
					and (abs(enemy.y - p2.y) < 32) then -- y collision
					p2.enemy_collision = true
				end

				-- prevent firing from off screen
				if abs(p1.x - enemy.x) < screen_size - 30 or abs(p2.x - enemy.x) < screen_size - 30 then
					handle_enemy_fire(enemy)
				end

				if enemy.animation_frame_count >= enemy.animation_frame_delay then
					enemy.animation_frame_count = 0
					
					-- enemy animation
					if enemy.sprite_number == 144 then
						enemy.sprite_number = 146
					elseif enemy.sprite_number == 146 then
						enemy.sprite_number = 144
						enemy.rotate_sprite = true
					end
				end 
			end
		end

	if enemy.x > right_bound then enemy.x = right_bound - 1 end
	
	end
end

function handle_enemy_fire(e)
	if e.fire_delay_count < e.fire_delay then
		e.fire_delay_count += 1
	else
		e.fire_delay_count = 0

		sfx(0)
		spawn_dart(e.x+4, e.y+6, -8, -1, true)
	end
end

function draw_enemies()
	for enemy in all(enemies) do
		if enemy.sprite_number == -1 then
			-- shotgun death, don't draw
		elseif enemy.sprite_number == 170 or enemy.sprite_number == 138 then
			-- wide instead of tall sprite
			spr(enemy.sprite_number, enemy.x, enemy.y+8, 4, 2, false, false)
		elseif enemy.sprite_number == 134 then
			-- wide instead of tall sprite and need to lower it
			spr(enemy.sprite_number, enemy.x, enemy.y-8, 4, 4, false, false)
		elseif enemy.sprite_number == 150 then
			spr(enemy.sprite_number, enemy.x, enemy.y, 2, 3, false, false)
		else
			-- body
			spr(enemy.sprite_number, enemy.x, enemy.y, 2, 3, false, false)
			-- head
			spr(enemy.sprite_number_face, enemy.x + 8, enemy.y - 4, 1, 1, false, false)
		end
	end
end