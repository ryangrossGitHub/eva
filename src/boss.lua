boss = {
	active = true,
	arms_up = true,
	x = 174,
	y = 6,
	charge = false,
	charge_prob = 0.50,
	charge_pause = 20,
	charge_pause_count = 0,
	charge_speed = 0.01,
	return_speed = 0,
	throw_delay_count = 0,
	throw_delay = 25,
	throw_speed = 50,
	throwing = false,
	sayings = {
		-- hardward update
		"_/hh/-1.39/3/aa/-1.15/r/-1.74/_/d/-1.10/w/-1.40/eh/-1.09/r/-1.60/ah/-1.56/_/p/-1.72/-3/_/d/-1.13/-3/ey/-1.64/-3/_/t",
		-- complete eat eat eat
		"_/-1.67/_/k/-1.58/ah/-1.03/m/-1.64/-3/_/p/-1.07/-3/l/-1.14/-3/iy/-1.64/-3/_/t/1.15/-3/iy/-1.64/-3/_/t/1.15/-3/iy/-1.64/-3/_/t/1.15/-3/iy/-1.64/-3/_/t"
	},
	head = {
		x = 174 + 8,
		y = 6 + 8,
		w = 2 * 8,
		h = 4 * 8,
		boss_damage = 0
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

		if boss.y > 55 then
			boss.charge = false
			boss.return_speed = 0
			boss.charge_pause_count = 0
		end
	elseif boss.y > 6 then -- return from charge
		if boss.charge_pause_count < boss.charge_pause then
			boss.charge_pause_count += 1
			return
		end
		
		boss.return_speed = min(boss.return_speed + 0.1, 3)
		boss.y -= boss.return_speed

		if boss.y < 6 then boss.y = 6 end -- prevent overshooting
	else
		if not boss.throwing then
			boss.throw_delay_count += 1
			
			if boss.throw_delay_count >= boss.throw_delay then
				boss.throw_delay_count = 0
				boss.arms_up = false
				boss.throwing = true
			end
		else
			if snowball.y > 128 then
				snowball_reset()
			else 
				snowball.y += snowball.speed
			end
		end
	end

	boss.head.x = boss.x + 8
	boss.head.y = boss.y + 8
end

function snowball_collision_detection(p)
	if snowball.x < p.x + p.w -- right bound
		and snowball.x + snowball.diameter > p.x -- left bound
		and snowball.y + snowball.diameter > p.y + 20 then-- bottom bound
			p.y += 5
			snowball_reset()
	end
end

function draw_boss()
	if boss.active then
		spr(238, boss.x - 4, boss.y + 45, 4, 4, false, false) -- shadow
		spr(238, boss.x + 4, boss.y + 47, 4, 4, false, false) -- shadow
		spr(238, boss.x + 12, boss.y + 49, 4, 4, false, false) -- shadow
		spr(238, boss.x + 12, boss.y + 44, 4, 4, false, false) -- shadow
		spr(238, boss.x + 20, boss.y + 49, 4, 4, false, false) -- shadow
		spr(238, boss.x + 20, boss.y + 44, 4, 4, false, false) -- shadow
		spr(238, boss.x + 28, boss.y + 47, 4, 4, false, false) -- shadow
		spr(238, boss.x + 36, boss.y + 45, 4, 4, false, false) -- shadow

		if boss.arms_up then
			spr(13, boss.x, boss.y, 3, 6, false, false) -- arm left up
			spr(13, boss.x + (3 * 8), boss.y, 3, 7, true, false) -- arm right up
			spr(107, boss.x + (2 * 8), boss.y - 5, 2, 2, false, false) -- snow ball
			spr(8, boss.head.x, boss.head.y, 4, 4, false, false) -- head

			-- red eyes
			if boss.charge then
				spr(22, boss.x + 16, boss.y + 29, 2, 1, false, false) -- mouth wide
				rectfill(boss.x + 19, boss.y + 21, boss.x + 21, boss.y + 23, 8)
				rectfill(boss.x + 25, boss.y + 21, boss.x + 27, boss.y + 23, 8)
			end
		else
			spr(68, boss.x - 11, boss.y + 20, 5, 4, false, false) -- arm left down
			spr(68, boss.x + 19, boss.y + 20, 5, 4, true, false) -- arm right down
			spr(8, boss.head.x, boss.head.y, 4, 4, false, false) -- head
			spr(107, snowball.x, snowball.y, 2, 2, false, false) -- snow ball
		end

		spr(73, boss.x - 4, boss.y + 40, 3, 2, false, false) -- leg left
		spr(73, boss.x + 28, boss.y + 40, 3, 2, true, false) -- leg right
	end
end