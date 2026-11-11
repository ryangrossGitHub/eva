screen_size = 128
intro = false
game_over = false
game_over_cnt = 0
p2_join_blink_count = 0
p2_join_blink_total = 30
p2_join_hide = false
camera_shake = 0
credits_cnt = 0
final_music = false

function _init()
	palt(13, true) 
	palt(0, false)
	load_stage(0)
	music(63)
	init_snow(100)
	init_speako8(80, 0.6)
end

function _update()
	if credits_cnt > 200 or game_over then return end

	speako8() 

 	if stage == 0 then
		update_start()
	else
		if stages[stage].enemy_spawn_count > enemey_spawn_stage_count then
			if e_spawn and enemy_spawn_delay_count == 0 then
				local spawn_point = 38 * 8

				spawn_enemy(stages[stage].enemy_speed, spawn_point, 40, get_enemy_type())
				spawn_enemy(stages[stage].enemy_speed, spawn_point - 12, 55, get_enemy_type())
				spawn_enemy(stages[stage].enemy_speed, spawn_point, 70, get_enemy_type())
				spawn_enemy(stages[stage].enemy_speed, spawn_point - 12, 85, get_enemy_type())

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

	if not intro and stage < 8 then
		center_camera_on_players()
	end
 
	if not coop then
		update_p2()
	end

	if stage == 8 and outro_transfer_count >= outro_transfer_total then 
		stage_trans = false
		if not coop then
			update_p2_boss()
		end
		camera_x = 138
		update_boss()
		detect_player_fall(p1)
		detect_player_fall(p2)
	end

	update_enemies()
	snowball_collision_detection(p1)
	snowball_collision_detection(p2)
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

	if stage < 8 and stage_trans then update_stage_trans() end

	if stage == 8 then update_final_stage_trans() end

	update_screen_shake()

end

function _draw()
	cls()

	if game_over then
		music(-1)
		print("\^w\^tgame over", camera_x + 24, 48, 8)
		print("THE WORKSHOP HAS BEEN BREACHED", camera_x + 4, 68, 8)
		print("RESTARTING...", camera_x + 34, 108, 7)
		game_over_cnt += 1
		if game_over_cnt > 10 then 
			if game_over_cnt > 100 then
				run()
			end
			return 
		end
	end

	if credits_cnt > 200 then
		camera(0,0)

		if final_music then
			music(29)
			final_music = false
		end

		if credits_cnt > 566 then
			run()
		else
			print("\^w\^tthe end", 40, 20, 7)
			print("special thanks to:", 33, 50, 7)
			print(" BIKIBIRD: ROBOT VOICE (SPEAKO8)", 0, 58, 8)
			print(" sUNJON:   SANTA CLAUDE GFX", 0, 66, 11)
			print(" rHYS:     SANTA CLAUDE NAME", 0, 74, 8)
			print(" TESTERS:  YOU ALL ROCK!", 0, 82, 11)
			print(" WIFE:     LOCAL CO OP TESTER", 0, 90, 8)
			print("HAPPY HOLIDAYS!!!!!!!", 30, 108, 7)
		end

		credits_cnt += 1
		return
	end

	map(0,0)
	if stage == 0 then
		draw_start()
	elseif not intro and not boss.defeated then
		print("❎ SHOOT", 85, 80, 6)

		if stage >= 5 then
			print("🅾️ SPECIAL", 85, 90, 6)
		end

		print("wave: "..stage.."/8", camera_x + 2, screen_size - 6, 8)

		if stage < 8 then
			spr(132, camera_x + screen_size - 40, screen_size - 8)
			print(stages[stage].enemy_spawn_count*4-enemy_kill_count.."/"..stages[stage].enemy_spawn_count*4, camera_x + screen_size - 30, screen_size - 6, 7)
		else
			print("santa claude!", camera_x + screen_size - 52, screen_size - 6, 11)
		end

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

	draw_player_trail(p2)
	draw_player_trail(p1)
	draw_player_shadow(p1)
	draw_player_shadow(p2)
	draw_enemy_shadows()

	if stage == 8 and boss.active then
		draw_boss()
	end

	draw_darts()
	draw_enemies()
	
	draw_player_weapon(p2)
	draw_player(p2)
	local p2_disp = "cp"
	if coop then
		p2_disp = "p2"
	end
	print(p2_disp, p2.x - 3, p2.y - 7, 3)

	draw_player_weapon(p1)
	draw_player(p1)
	print("p1", p1.x - 3, p1.y - 7, 8)

	
	if intro and camera_x > 35 then
		print("\^w\^tdefend the", camera_x + 20, 68, 8)
		print("\^w\^tworkshop", camera_x + 28, 88, 8)
	elseif stage_trans then
		print("\^w\^twave: "..stage, camera_x + 38, 62, 8)
	end

	draw_snow()
	draw_player_force(p1)
	draw_player_force(p2)

	if boss.defeated then
		draw_santa()

		if santa.x == 142 then
			if not final_music then
				final_music = true
				music(40)
			end
			credits_cnt += 1
		end

		if final_music then
			print_dialog(santa.x, santa.y, "HOW IS THE THIRTY DAY FREE TRIAL OF SANTA CLAUDE!? PRETTY NEAT, RIGHT?", 1, true, true, 0, 7, true)
		end
	end
end