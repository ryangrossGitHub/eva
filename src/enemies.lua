enemies = {}

e_spawn = false
enemey_spawn_stage_count = 0 -- stage cnt
enemy_spawn_delay_count = 0 
enemy_health = 20
enemy_head_sprite_list = {132, 133, 148, 149, 164, 165, 180, 181}
enemy_dead_frame = 1000 -- how long before removing from table to avoid out of mem error

function spawn_enemy(speed)
	enemy = {
		sprite_number = 144,
		sprite_number_face = rnd(enemy_head_sprite_list),
		speed = speed, -- movement speed
		sprite_flip = true,
		x = rnd({ camera_x-16, camera_x + screen_size + 16 }),
		y = rnd(48) + 48,
		death_animation_frame_delay = 20,
		death_animation_frame_count = 0, -- death animation frame count
		dead = false,
		animation_frame_delay = 7, -- animation frame delay
		animation_frame_count = 0,
		yeeted = false,
		yeet_sprite = 136,
		yeet_sprite_flip = false, --flip of yeeting player
		yeet_animation_frame_delay = 5,
		yeet_animation_frame_count = 0,
		destination = flr(rnd(4)), -- 0,4 = opposite side, 1 = player 1, 2 = player 2
		damage = 0,
		dead_frames = 0
	}

	if enemy.x > camera_x + screen_size/2 then
		enemy.sprite_flip = false
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
	for enemy in all(enemies) do
		if enemy.dead then
			if enemy.dead_frames >= enemy_dead_frame then
				del(enemies, enemy)
			else
				enemy.dead_frames += 1
				enemy.death_animation_frame_count += 1
			
				if enemy.death_animation_frame_count >= enemy.death_animation_frame_delay then
					enemy.death_animation_frame_count = 0
				
					if enemy.sprite_number == 150 then
						enemy.sprite_number = 128
					end
				end
			end
		elseif enemy.yeeted then
			yeet(enemy)
		else

			if enemy.destination == 1 then
				seek_player(enemy, p1)
			elseif enemy.destination == 2 then
				seek_player(enemy, p2)
			else
				if enemy.sprite_flip then
					enemy.x += enemy.speed

					-- Die when walk off screen
					if enemy.x > camera_x + screen_size + 16 then
						enemy_die(enemy, nil, false, false)
					end
				else
					enemy.x -= enemy.speed

					-- Die when walk off screen
					if enemy.x < camera_x - 16 then
						enemy_die(enemy, nil, false, false)
					end
				end
			end

			enemy.animation_frame_count += 1
		
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

function seek_player(enemy, p)
	if p.x < enemy.x - enemy.speed then
		enemy.x -= enemy.speed
		enemy.sprite_flip = false
	elseif p.x > enemy.x + enemy.speed then
		enemy.x += enemy.speed
		enemy.sprite_flip = true
	end

	-- walk to middle before down
	if abs(p.x-enemy.x) < 2 then
		if p.y < enemy.y - 4 - enemy.speed then
			enemy.y -= enemy.speed
		elseif p.y > enemy.y + enemy.speed then
			enemy.y += enemy.speed
		end
	end
end

function draw_enemies()
	for enemy in all(enemies) do
		if enemy.sprite_number == -1 then
			-- shotgun death, don't draw
		elseif enemy.sprite_number == 136 then
			-- wide instead of tall sprite
			spr(enemy.sprite_number, enemy.x, enemy.y, 4, 2, enemy.sprite_flip, false)
		elseif enemy.sprite_number == 128 then
			-- wide instead of tall sprite and need to lower it
			spr(enemy.sprite_number, enemy.x, enemy.y + 16, 3, 1, enemy.sprite_flip, false)
		elseif enemy.sprite_number == 150 then
			spr(enemy.sprite_number, enemy.x, enemy.y, 2, 3, enemy.sprite_flip, false)
		else
			-- body
			spr(enemy.sprite_number, enemy.x, enemy.y, 2, 3, enemy.sprite_flip, false)
			-- head
			if enemy.sprite_flip then
				spr(enemy.sprite_number_face, enemy.x, enemy.y - 4, 1, 1, enemy.sprite_flip, false)
			else
				spr(enemy.sprite_number_face, enemy.x + 8, enemy.y - 4, 1, 1, enemy.sprite_flip, false)
			end
		end
	end
end

function enemy_coll_detect(player) 
	local hbox = 8 -- hit box
 
	if player.weapon == 1 or player.weapon == 7 then
		hbox = 16
	end
 
	for enemy in all(enemies) do
		if not enemy.dead and not enemy.yeeted
		and ((enemy.x - 2 < player.x and player.flip_sprite) or (enemy.x + 2 > player.x and not player.flip_sprite)) 
		and (enemy.y - 4 > player.y - hbox + 12 and enemy.y - 4 < player.y + hbox + 8) then
			
			if player.weapon == 0 then
				enemy.damage += pistol.damage
			elseif player.weapon == 1 then
				enemy.damage += shotgun.damage
			elseif player.weapon == 2 then
				enemy.damage += oozie.damage
			elseif player.weapon == 3 then
				enemy.damage += burst_rifle.damage
			elseif player.weapon == 4 then
				enemy.damage += auto_rifle.damage
			elseif player.weapon == 5 then
				enemy.damage += hunting_rifle.damage
			elseif player.weapon == 6 then
				enemy.damage += revolver.damage
			elseif player.weapon == 7 then
				enemy.damage += long_shotgun.damage
			end
			
			if enemy.damage >= enemy_health then
				enemy_die(enemy, player.weapon, player.flip_sprite, false)
				player.kill_count += 1
			else
				generate_enemy_hit_particles(enemy, player.flip_sprite, 1)
			end
		end
	end
end

function enemy_die(enemy, weapon, flip, rotate)
 	enemy.dead = true
	enemy.yeet = false

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

	generate_enemy_hit_particles(enemy, flip, particle_count)
end

function generate_enemy_hit_particles(enemy, flip, particle_count) 
	for i=1,particle_count do
		local xs = rnd(6)
		if flip then
			xs = -xs
		end
		local ys = rnd(4 - -4) + -4
		local color = 0

		if enemy.sprite_number_face == 132 then
			color = rnd({3, 9, 11})
		else
			color = rnd({3, 11})
		end

		if flip then
			add(particles, particle(enemy.x+20, enemy.y - 4, xs, ys, color, 7, 200))
		else
			add(particles, particle(enemy.x+4, enemy.y - 4, xs, ys, color, 7, 200))
		end
	end
end

function yeet(enemy)
	if enemy.x < camera_x or enemy.x > camera_x + screen_size - 32 then
		enemy_die(enemy, 1, not enemy.sprite_flip, true)
		sfx(0)
	else
		if enemy.yeet_animation_frame_count < enemy.yeet_animation_frame_delay * 0.5 then
			-- pickup animation
			enemy.sprite_number = enemy.yeet_sprite
			if enemy.yeet_sprite_flip then
				enemy.x += 3
				enemy.sprite_flip = true
			else
				enemy.x -= 3
				enemy.sprite_flip = false
			end
		else
			if enemy.yeet_sprite_flip then
				enemy.x -= 15
			else
				enemy.x += 15
			end
		end

		enemy.yeet_animation_frame_count += 1
	end
end