particles = {}

function particle(x, y, x_speed, y_speed, color, move, life)
	if life == nil then
		life = move
	end
	
	local p = {
		x = x,
		y = y,
		x_speed = x_speed,
		y_speed = y_speed,
		color = color, 
		move = move, --frames of movement
		life = life, -- frames until deletion
	}

	return p
end

function draw_particles(particles)
	for particle in all(particles) do
		if particle.life > 0 then
			if particle.move > 0 then
				particle.y += particle.y_speed
				particle.x += particle.x_speed
				particle.move -= 1
			end
			particle.life -= 1
			pset(particle.x, particle.y, particle.color)
		else
			del(particles, particle)
		end
	end
end