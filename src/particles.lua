-- nerf bullet particle system

darts = {}

function spawn_dart(x, y, dx, dy)
    add(darts, {
        x = x,
        y = y,
        dx = dx,
        dy = dy,
        life = 90,
        bounces = 3,
        is_tumbling = false,
        spin_angle = 0,
        spin_speed = 0
    })
end

function update_darts(enemies)
    for d in all(darts) do
        -- 1. physics & drag
        d.dy = d.dy + 0.15   
        d.dx = d.dx * 0.98   
        d.dy = d.dy * 0.98

        -- 2. movement
        d.x = d.x + d.dx
        d.y = d.y + d.dy

        -- 3. update visual tumble/spin rotation
        if d.is_tumbling then
            d.spin_angle = d.spin_angle + d.spin_speed
            -- slowly slow down the spin due to air friction
            d.spin_speed = d.spin_speed * 0.95 
            
            -- stop tumbling if the spin becomes a crawl
            if abs(d.spin_speed) < 0.02 then
                d.is_tumbling = false
            end
        end

        d.life = d.life - 1
        if d.life <= 0 then 
            del(darts, d) 
        end

        -- 4. collision and ricochet
        for e in all(enemies) do
            dart_collision_detection(d, e)
        end

        dart_collision_detection(d, p1)
        dart_collision_detection(d, p2)
    end
end

function dart_collision_detection(d, o)
    if d.x >= o.x and d.x <= o.x + o.w and
        d.y >= o.y and d.y <= o.y + o.h then
        
        local return_dir = 1
        if d.dx > 0 then return_dir = -1 end

        d.dx = (1.0 + rnd(2.0)) * return_dir
        d.dy = -1.5 - rnd(3.0)
        d.life = d.life + 20 
        
        -- activate visual spin on hits
        d.is_tumbling = true
        -- random direction (clockwise/counter-clockwise) and faster speed
        d.spin_speed = 0.15 + rnd(0.2)
        if rnd(1) > 0.5 then d.spin_speed = -d.spin_speed end

        
        if d.dx > 0 then d.x = o.x + o.w + 1 else d.x = o.x - 1 end
        
        d.bounces = d.bounces - 1
        if d.bounces <= 0 then
            del(darts, d)
        end
    end
end

function draw_darts()
    for d in all(darts) do
        local step_x = 0
        local step_y = 0
        
        if d.is_tumbling then
            -- if tumbling, calculate steps using the dedicated spin angle
            -- (using standard sin/cos coordinates for the custom angle)
            step_x = cos(d.spin_angle)
            step_y = sin(d.spin_angle)
        else
            -- standard flight path alignment
            local speed = sqrt(d.dx*d.dx + d.dy*d.dy)
            if speed > 0 then
                step_x = d.dx / speed
                step_y = d.dy / speed
            else
                step_x = 1
            end
        end
        
        -- leading pixel (blue tip)
        local x0 = d.x + step_x
        local y0 = d.y + step_y
        
        -- middle pixel (orange body)
        local x1 = d.x
        local y1 = d.y
        
        -- trailing pixel (orange tail)
        local x2 = d.x - step_x
        local y2 = d.y - step_y
        
        pset(x0, y0, 1) -- blue
        pset(x1, y1, 9)  -- orange
        pset(x2, y2, 9)  -- orange
    end
end
