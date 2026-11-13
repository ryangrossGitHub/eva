boss = {
	active, defeated, charge, throwing = false, false, false, false,
	arms_up = true,
	x = right_bound - 40,
	y = 6,
	charge_prob = 0.50,
	charge_pause = 20,
	charge_pause_count = 0, 
	return_speed = 0, 
	throw_delay_count = 0, 
	hit_eye_color_count = 0,
	charge_speed = 0.01,
	x_speed = 0.5,
	throw_delay = 25,
	throw_speed = 50,
	eye_color = -1,
	hit_eye_color_delay = 2,
	sayings = {
		"_/s/-1.43/3/ae/-1.21/n/-1.72/_/t/-1.54/ah/-1.69/_/k/-1.20/l/-1.16/3/ao/-1.69/_/d/-1.20/ih/-1.06/z/-1.69/_/k/-1.19/3/ah/-1.02/-3/m/-1.18/3/ih/1.08/3/ng",
		"_/-1.67/_/t/-1.18/uw/-1.69/-3/_/t/1.29/-3/aw/1.09/-3/n"
	},
	head = {
		x = right_bound - 40 + 8,
		y = 6 + 8,
		w = 4 * 8,
		h = 3 * 8,
		boss_damage = 0,
		hp = 10 * 8,
		hit = false,
		fall_cnt = 0,
		fall_dist = 6
	},
	feet = {
		which = "left", 
		dir = "up",
		y_offset = 0,
		y_offset_max = 2,
		speed = 1,
		charge_speed = 2
	}
}

snowball = {
	y = boss.y - 5,
	x = boss.x + (2 * 8),
	diameter = 2 * 8,
	speed = 4
}

function snowball_reset()
	snowball.y = boss.y - 5
	snowball.x = boss.x + (2 * 8)
	boss.throwing = false
	boss.arms_up = true

	if rnd() < boss.charge_prob then boss.charge = true end
end

function update_boss()
	if boss.charge then
		boss.arms_up = true
		boss.y += (boss.y + 55) * boss.charge_speed

		if boss.y > 55 or 
			(p1.force_special_active and p1.force_special_anim_seq == 1) or 
			(p2.force_special_anim_seq == 1 and p2.force_special_active) then
			
			boss.charge = false
			boss.return_speed = 0
			boss.charge_pause_count = 0
		end
	elseif boss.y > 6 then 
		if boss.charge_pause_count < boss.charge_pause then
			boss.charge_pause_count += 1
		else
			boss.return_speed = min(boss.return_speed + 0.1, 3)
			boss.y -= boss.return_speed

			if boss.y < 6 then boss.y = 6 end 
		end
	else
		if not boss.throwing and not boss.defeated then
			boss_seek_closest_player()
			snowball.x = boss.x + (2 * 8)

			boss.throw_delay_count += 1
			
			if boss.throw_delay_count >= boss.throw_delay then
				boss.throw_delay_count = 0
				boss.arms_up = false
				boss.throwing = true
			end
		elseif not boss.defeated then
			if snowball.y > 128 then
				snowball_reset()
			else 
				snowball.y += snowball.speed
			end
		end
	end

	boss.head.x = boss.x + 8

	if not boss.defeated then
		boss.head.y = boss.y + 8
	else
		boss.arms_up = false
		if boss.head.fall_cnt < boss.head.fall_dist then
			boss.head.fall_cnt += 1
			boss.head.y += 1
		end
	end

	if boss.head.hp - boss.head.hp/4 < boss.head.boss_damage then
		boss.charge_speed = 0.02
		boss.x_speed = 1.5
		snowball.speed = 8
		boss.throw_delay = 15
		boss.charge_prob = 0.25
	elseif boss.head.hp/2 < boss.head.boss_damage then
		boss.charge_speed = 0.015
		boss.x_speed = 1
		snowball.speed = 6
		boss.throw_delay = 20
		boss.charge_prob = 0.40
	end

	if boss.head.boss_damage >= boss.head.hp then boss.defeated = true end

	update_boss_feet()
	update_boss_eyes()

	if boss.defeated and santa.x < 142 then
		santa.x += 1
	end
end

function update_boss_feet()
	if boss.throwing or (boss.defeated and boss.y == 6) then return end
		
	if boss.charge then
		if boss.feet.dir == "up" then
			boss.feet.y_offset += boss.feet.charge_speed
		else
			boss.feet.y_offset -= boss.feet.charge_speed
		end
	else
		if boss.feet.dir == "up" then
			boss.feet.y_offset += boss.feet.speed
		else
			boss.feet.y_offset -= boss.feet.speed
		end
	end

	if boss.feet.y_offset >= boss.feet.y_offset_max then
		boss.feet.dir = "down"
	end
end

function update_boss_eyes()
	if boss.head.hit then 
		if boss.hit_eye_color_count < boss.hit_eye_color_delay then
			boss.hit_eye_color_count += 1
		else
			boss.hit_eye_color_count = 0
			boss.head.hit = false
		end

		boss.eye_color = 7
	elseif boss.charge then
		boss.eye_color = 8
	elseif boss.defeated then
		boss.eye_color = 1
	elseif boss.head.hp - boss.head.hp/4 < boss.head.boss_damage then
		boss.eye_color = 8
	else
		boss.eye_color = -1
	end
end

function boss_seek_closest_player()
	local p1_delta = boss.head.x + boss.head.w/2 - p1.x + p1.w/2
	boss_seek_player(p1_delta)
end

function boss_seek_player(delta)
	if delta > 0 then
		boss.x -= boss.x_speed
	else
		boss.x += boss.x_speed
	end
end

function snowball_collision_detection(p)
	if not p.fall and snowball.x < p.x + p.w 
		and snowball.x + snowball.diameter > p.x 
		and snowball.y + snowball.diameter > p.y + 20 
		and snowball.y < p.y + 20 then
			p.y += 30
			sfx(2)
			snowball_reset()
	end
end

function draw_boss()
	if boss.active then
		spr(238, boss.x - 4, boss.y + 45, 4, 4)
		spr(238, boss.x + 4, boss.y + 47, 4, 4)
		spr(238, boss.x + 12, boss.y + 49, 4, 4)
		spr(238, boss.x + 12, boss.y + 44, 4, 4)
		spr(238, boss.x + 20, boss.y + 49, 4, 4)
		spr(238, boss.x + 20, boss.y + 44, 4, 4)
		spr(238, boss.x + 28, boss.y + 47, 4, 4)
		spr(238, boss.x + 36, boss.y + 45, 4, 4)

		if boss.arms_up then
			spr(13, boss.x, boss.y, 3, 6) 
			spr(13, boss.x + (3 * 8), boss.y, 3, 7, true) 
			spr(107, boss.x + (2 * 8), boss.y - 5, 2, 2) 
		else
			spr(68, boss.x - 11, boss.y + 20, 5, 4) 
			spr(68, boss.x + 19, boss.y + 20, 5, 4, true) 
		end

		if boss.feet.which == "left" then
			spr(73, boss.x - 4, boss.y + 40 + boss.feet.y_offset, 3, 2) 
			spr(73, boss.x + 28, boss.y + 40, 3, 2, true) 

			if boss.feet.y_offset <= 0 then
				boss.feet.which = "right"
				boss.feet.dir = "up"
			end
		else
			spr(73, boss.x - 4, boss.y + 40, 3, 2) 
			spr(73, boss.x + 28, boss.y + 40 + boss.feet.y_offset, 3, 2, true) 

			if boss.feet.y_offset <= 0 then
				boss.feet.which = "left"
				boss.feet.dir = "up"
			end
		end

		if boss.arms_up then
			spr(8, boss.head.x, boss.head.y, 4, 4) 
		else
			if boss.defeated and boss.head.fall_cnt >= boss.head.fall_dist then
				spr(238, boss.head.x + 6, boss.head.y + 22, 2, 2)
				spr(238, boss.head.x + 10, boss.head.y + 22, 2, 2)
				spr(8, boss.head.x, boss.head.y, 4, 4, false, true) 
			else
				spr(8, boss.head.x, boss.head.y, 4, 4) 
			end
		end

		draw_boss_eyes()

		if not boss.arms_up and not boss.defeated then
			spr(107, snowball.x, snowball.y, 2, 2) 
		end

		draw_boss_health()
	end
end

function draw_boss_health()
	if boss.defeated then return end

	local color = 9
	if boss.eye_color != -1 then
		color = boss.eye_color
	end

	rectfill(159, 0, 161 + boss.head.hp, 6, 6)
	rectfill(160, 1, 160 + boss.head.hp, 5, 5)
	rectfill(160 + boss.head.boss_damage, 1, 160 + boss.head.hp, 5, color)
end

function draw_boss_eyes()
	if boss.eye_color == -1 then return end

	local y_ofs = 0
	if boss.defeated then y_ofs = 3 end
	rectfill(boss.head.x + 11, boss.head.y + 13 + y_ofs, boss.head.x + 13, boss.head.y + 15 + y_ofs, boss.eye_color)
	rectfill(boss.head.x + 17, boss.head.y + 13 + y_ofs, boss.head.x + 19, boss.head.y + 15 + y_ofs, boss.eye_color)

	if boss.eye_color == 8 then
		spr(22, boss.x + 16, boss.y + 29, 2, 1) 
	end
end