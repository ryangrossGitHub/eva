particles = {}

function particle(x, y, x_speed, y_speed, color, move, life, flip)
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
		flip = flip -- flip direction
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

			if particle.flip then
				pset(particle.x, particle.y, 9)
				pset(particle.x-1, particle.y, 9)
				pset(particle.x-2, particle.y, 9)
				pset(particle.x-3, particle.y, 1)
			else
				pset(particle.x, particle.y, 9)
				pset(particle.x+1, particle.y, 9)
				pset(particle.x+2, particle.y, 9)
				pset(particle.x+3, particle.y, 1)
			end
			
		else
			del(particles, particle)
		end
	end
end