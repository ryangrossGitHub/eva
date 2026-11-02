screen_size = 128
user_data_memory_address = 0x8000
log_file = "log.txt"
progress_stage = 0
intro = false
game_over = false
game_over_delay = 100
game_over_delay_count = 0
p2_join_blink_count = 0
p2_join_blink_total = 30
p2_join_hide = false
camera_shake = 0

function _init()
	printh("GAME INIT", log_file, true)
	palt(13, true) -- Transparent Color Is Purple (13)
	palt(0, false)
	load_stage(0)
	music(63)
	init_snow(100)
	spk8_pitch,spk8_rate,spk8_volume,spk8_quality,spk8_intonation,spk8_if0,spk8_shift,spk8_bandwidth,spk8_whisper=
	60,0.5,1.75,.5,10,10,1,1,1
end

function _update()
	if stage == 6 then
		return
	end

	speako8()  -- must appear once unconditionally in _update.

 	if stage == 0 then
		update_start()
	else
		if stages[stage].enemy_spawn_count > enemey_spawn_stage_count then
			if e_spawn and enemy_spawn_delay_count == 0 then
				-- spawn in rows
				local spawn_point = 38 * 8
				spawn_enemy(stages[stage].enemy_speed, spawn_point, 40)
				spawn_enemy(stages[stage].enemy_speed, spawn_point - 12, 55)
				spawn_enemy(stages[stage].enemy_speed, spawn_point, 70)
				spawn_enemy(stages[stage].enemy_speed, spawn_point - 12, 85)
				enemy_spawn_delay_count = stages[stage].enemy_spawn_delay
				enemey_spawn_stage_count += 1
			end

			enemy_spawn_delay_count -= 1
		elseif #enemies == 0 then
			stage += 1
			init_snow(stage * 100)
			load_stage(stage)
		end
	end

	if intro then
		update_intro()
	end
 
	if player_move then
		update_player_move(p1,0)

		local btn_pressed = update_player_move(p2,1)

		if not coop and btn_pressed then coop = true end
	end

	if not intro then
		center_camera_on_players()
	end
 
	if not coop then
		update_p2()
	end

	update_enemies()
	update_enemy_trails()
	update_darts(enemies)
	update_player_anims(p1)
	update_player_anims(p2)
	update_player_force(p1)
	update_player_force(p2)
	update_player_trail(p1)
	update_player_trail(p2)

	if p1.weapon_delay > 0 then
		p1.weapon_delay -= 1
	end

	if p2.weapon_delay > 0 then
		p2.weapon_delay -= 1
	end

	if game_over then
		if game_over_delay_count >= game_over_delay then
			game_over_delay_count = 0
			reset()
		else
			game_over_delay_count += 1
		end
	end

	if not coop then
		p2_join_blink_count += 1

		if p2_join_blink_count >= p2_join_blink_total then
			p2_join_blink_count = 0

			if p2_join_hide then
				p2_join_hide = false
			else 
				p2_join_hide = true
			end
		end
	else
		p2_join_hide = true
	end

	if stage_trans then update_stage_trans() end

	update_screen_shake()

end

function _draw()
	cls()

	if stage == 6 then
		print("ENDING UNDER CONSTRUCTION...", camera_x, 0)
		print("ITS GUNA BE EPIC, I PROMISE ; )", camera_x, 20)
		return
	end

	map(0,0)
	if stage == 0 then
		draw_start()
	elseif not intro then
		print("❎ SHOOT", 85, 80, 6)
		print("wave: "..stage.."/8", camera_x + 2, screen_size - 6, 8)
		spr(132, camera_x + screen_size - 40, screen_size - 8)
		print(stages[stage].enemy_spawn_count*4-enemy_kill_count.."/"..stages[stage].enemy_spawn_count*4, camera_x + screen_size - 30, screen_size - 6, 7)

		if not p2_join_hide then
			print("p2 PRESS ❎ TO JOIN", camera_x + 30, 0, 3)
		end
	end

	print_dialog((11 * 8) - 3, (6 * 8) + 2, "\138WORKSHOP", 0, false, false, 0, 4)
	print_dialog(35 * 8, (6 * 8) - 3, "DATA CENTER", 1, false, false, 6, 5)

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

	draw_player_shadow(p1)
	draw_player_shadow(p2)
	draw_enemy_shadows()

	draw_darts()
	
	draw_enemy_trails()
	draw_enemies()
	
	draw_player_trail(p2)
	draw_player_weapon(p2)
	draw_player(p2)
	local p2_disp = "cp"
	if coop then
		p2_disp = "p2"
	end
	print(p2_disp, p2.x - 3, p2.y - 7, 3)

	-- Draw player 1 after player 2 so that player 1 is in front of player 2
	draw_player_trail(p1)
	draw_player_weapon(p1)
	draw_player(p1)
	print("p1", p1.x - 3, p1.y - 7, 8)

	if game_over then
		print("\^w\^tgame over", camera_x + 24, 68, 8)
		print("THE WORKSHOP HAS BEEN BREACHED", camera_x + 4, 88, 8)
	elseif intro and camera_x > 35 then
		print("\^w\^tdefend the", camera_x + 20, 68, 8)
		print("\^w\^tworkshop", camera_x + 28, 88, 8)
	elseif stage_trans then
		print("\^w\^twave: "..stage, camera_x + 38, 62, 8)
	end

	draw_snow()
	draw_player_force(p1)
	draw_player_force(p2)
end