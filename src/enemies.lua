enemies = {}

e_spawn = false
enemey_spawn_stage_count = 0 -- stage cnt
enemy_spawn_delay_count = 0 
enemy_health = 20
enemy_head_sprite_list = {132, 133, 148, 149, 164, 165, 180, 181}
enemy_dead_frame = 60 -- how long before removing from table to avoid out of mem error
enemy_kill_count = 0

enemy_trails = {}

function spawn_enemy(speed, x, y, type)
	enemy = {
		sprite_number = 144,
		sprite_number_face = 132, --rnd(enemy_head_sprite_list),
		speed = speed, -- movement speed
		rotate_sprite = false,
		x = x,
		y = y,
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
		fire_delay_count = 0,
		melee = type == "melee",
		melee_arm_length = 1,
		melee_deployed = false,
		melee_glove_x = 0,
		shield = type == "shield",
		shield_deployed = false,
		shield_timer = 0,
		shield_timer_max = 40,
	}

	add(enemies, enemy)
end

function get_enemy_type()
	local roll = rnd(1)
	if stage == 2 then
		if roll < 0.50 then
			return "shield"
		end
	elseif stage == 3 then
		if roll < 0.50 then
			return "melee"
		end
	elseif stage >= 4 then
		if roll < 0.30 then
			return "melee"
		elseif roll < 0.80 then
			return "shield"
		end
	elseif stage >= 6 then
		if roll < 0.40 then
			return "melee"
		elseif roll < 1 then
			return "shield"
		end
	end

	return nil
end

function update_enemies()
	p1.enemy_collision = false
	p2.enemy_collision = false

	for enemy in all(enemies) do
		if enemy.dead then
			if enemy.dead_frames >= enemy_dead_frame then
				enemy_kill_count += 1
				del(enemies, enemy)
			else
				enemy.dead_frames += 1
				enemy.death_animation_frame_count += 1

				if enemy.death_animation_frame_count >= enemy.death_animation_frame_delay then
					enemy.death_animation_frame_count = 0

					if enemy.dead_frames % 20 == 0 then
						sfx(0)
						spawn_dart(enemy.x+18, enemy.y, rnd(4) - 2, -3, true)
					end

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
					kill_enemy(enemy)
				end
			else
				-- walk
				enemy.x -= enemy.speed

				if enemy.melee then
					if enemy.melee_deployed then
						if enemy.melee_arm_length < 4 then
						enemy.melee_arm_length += 1
						else
							enemy.melee_arm_length = 0
							enemy.melee_deployed = false
						end
					else
						if (enemy.x - p1.x - p1.w < 32 and (abs(enemy.y - p1.y) < 24))
						or (enemy.x - p2.x - p2.w < 32 and (abs(enemy.y - p2.y) < 24)) then
							enemy.melee_deployed = true
						end
					end

					enemy.melee_glove_x = enemy.x - (enemy.melee_arm_length * 8) - 4
					if (enemy.melee_glove_x - p1.x - p1.w < 0 and (abs(enemy.y - p1.y) < 24)) then
						p1.enemy_melee_collision = true
						p1.enemy_melee_collision_dist_count = p1.enemy_melee_collision_dist
						sfx(2)
					end

					if (enemy.melee_glove_x - p2.x - p2.w < 0 and (abs(enemy.y - p2.y) < 24)) then
						p2.enemy_melee_collision = true
						p2.enemy_melee_collision_dist_count = p2.enemy_melee_collision_dist
						sfx(2)
					end

				else -- range enemy
					-- handle shield
					if enemy.shield_deployed then
						enemy.shield_timer += 1
						if enemy.shield_timer >= enemy.shield_timer_max then
							enemy.shield_deployed = false
							enemy.shield_timer = 0
						end
					end

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

		if enemy.x < left_bound - 24 then game_over = true end
		if enemy.x > right_bound then enemy.x = right_bound end
	end
end

function update_enemy_trails()
	if trail_capture_count == 0 then
		for e in all(enemies) do
			if not e.dead then
				add(enemy_trails, {x = e.x + 8, y = e.y + 24})
			end
		end
	end

	while #enemy_trails > trail_capture_length do
		del(enemy_trails, enemy_trails[1])
	end
end

function draw_enemy_trails()
	for t in all(enemy_trails) do
		pset(t.x, t.y, 6)
		pset(t.x, t.y + 1, 6)
		pset(t.x + 1, t.y, 6)
		pset(t.x + 1, t.y + 1, 6)
	end
end

function kill_enemy(e)
	e.dead = true
	e.sprite_number = 170
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
		elseif enemy.sprite_number == 150 then
			spr(enemy.sprite_number, enemy.x, enemy.y, 2, 3, false, false)
		else
			-- body
			spr(enemy.sprite_number, enemy.x, enemy.y, 2, 3, false, false)
			-- head
			spr(enemy.sprite_number_face, enemy.x + 8, enemy.y - 4, 1, 1, false, false)

			-- arm
			if enemy.melee then
				if not enemy.melee_deployed then
					spr(130, enemy.x + 8, enemy.y + 5, 2, 1, false, false)
					spr(142, enemy.x + 4, enemy.y + 4, 1, 1, false, false)
				else
					for i=0, enemy.melee_arm_length do
						spr(134, enemy.x - (i * 8), enemy.y + 8, 2, 1, false, false)
					end
					spr(142, enemy.melee_glove_x, enemy.y + 4, 1, 1, false, false)
				end
			elseif enemy.shield and enemy.shield_deployed then
				spr(128, enemy.x, enemy.y + 5, 2, 1, false, false)
				spr(158, enemy.x + 5, enemy.y - 2, 1, 2, false, false)
			else 
				spr(128, enemy.x, enemy.y + 5, 2, 1, false, false)
			end
		end
	end
end

function draw_enemy_shadows()
	for e in all(enemies) do
		if not e.dead then
			spr(68, e.x + 4, e.y + 16, 2, 2, false, false)
		end
	end
end