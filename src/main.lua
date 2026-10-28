screen_size = 128
user_data_memory_address = 0x8000
log_file = "log.txt"
progress_stage = 0

function _init()
	printh("GAME INIT", log_file, true)
	palt(13, true) -- Transparent Color Is Purple (13)
	palt(0, false)
	load_stage(0)
	-- music(0)
	init_snow()
	spk8_pitch,spk8_rate,spk8_volume,spk8_quality,spk8_intonation,spk8_if0,spk8_shift,spk8_bandwidth,spk8_whisper=
	100,0.7,1.5,.5,10,10,1,1,1
end

function _update()
	speako8()  -- must appear once unconditionally in _update.

 	if stage == 0 then
  		update_start()
	else
		-- Initial delay before spawning enemies for this stage
		if stages[stage].enemy_spawn_initial_delay and 
			stages[stage].enemy_spawn_initial_delay_count <  stages[stage].enemy_spawn_initial_delay then
			
			stages[stage].enemy_spawn_initial_delay_count += 1
		elseif stages[stage].enemy_spawn_count > enemey_spawn_stage_count then
			enemy_spawn_delay_count += 1
				
			if e_spawn and enemy_spawn_delay_count >= stages[stage].enemy_spawn_delay then
				spawn_enemy(stages[stage].enemy_speed)
				enemy_spawn_delay_count = 0
				enemey_spawn_stage_count += 1
			end
		end
	end
 
	if player_move then
		update_player_move(p1,0)
		
		if coop then
			update_player_move(p2,1)
		end
	end
 
	if not coop then
		update_p2()
	end

	check_weapon_found()
	center_camera_on_players()
	update_darts(enemies)
	update_enemies()
	update_player_anims(p1)
	update_player_anims(p2)

	if p1.weapon_delay > 0 then
		p1.weapon_delay -= 1
	end

	if p2.weapon_delay > 0 then
		p2.weapon_delay -= 1
	end
end

function _draw()
	cls()

	map(0,0)
	if stage == 0 then
		draw_start()
	end

	print_dialog(20 * 8, 5 * 8, "santa's workshop", 1, false, false, 8, 3)

	local s = stages[stage]
	if not s then
		s = stages[1]
	end

	camera(camera_x,camera_y)
	if camera_shake_offset < 0 then
		camera_shake_offset += 1
		camera_x += 1
	elseif camera_shake_offset > 0 then
		camera_shake_offset -= 1
		camera_x -= 1
	end

	draw_weapons()

	draw_darts()
	
	draw_enemies()
	
	draw_player_weapon(p2)
	draw_player(p2)
	local p2_disp = "cp"
	if coop then
		p2_disp = "p2"
	end
	print(p2_disp, p2.x - 3, p2.y - 7, 3)

	-- Draw player 1 after player 2 so that player 1 is in front of player 2
	draw_player_weapon(p1)
	draw_player(p1)
	print("p1", p1.x - 3, p1.y - 7, 8)

	draw_snow()

	if not stage_trans and stage > 1 then
		local count = c.kill_count + j.kill_count
		if progress_stage < 4 and count >= 1000 then 
			progress_stage = 4
			stage = 3
			-- enemies = {} -- clear
			music(56)
			c.flip_sprite = false
			j.flip_sprite = false
			player_move = false
		elseif progress_stage < 3 and count >= 500 then 
			progress_stage = 3
			music(32)
			stages[2].enemy_spawn_delay = 7
			stages[2].enemy_speed = 0.9
		elseif progress_stage < 2 and count >= 250 then 
			progress_stage = 2
			music(8)
			stages[2].enemy_spawn_delay = 12
			stages[2].enemy_speed = 0.7
		elseif progress_stage < 1 and count >= 100 then 
			progress_stage = 1
			music(0)
			stages[2].enemy_spawn_delay = 13
			stages[2].enemy_speed = 0.5
		end
	end

	if stage == 3 then
		run_ending()
	end
end