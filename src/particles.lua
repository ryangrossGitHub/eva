darts = {}

bounce_cooldown = 10 

function spawn_dart(x, y, dx, dy, e)
    add(darts, {
        x = x,
        y = y,
        dx = dx,
        dy = dy,
        enemy_fire = e,
        life = 50,
        bounces = 3,
        is_tumbling = false,
        spin_angle = 0,
        spin_speed = 0,
        cooldown = 0
    })
end

function update_darts(enemies)
    for d in all(darts) do
        d.dy = d.dy + 0.15   
        d.dx = d.dx * 0.98   
        d.dy = d.dy * 0.98

        d.x = d.x + d.dx
        d.y = d.y + d.dy

        if d.is_tumbling then
            d.spin_angle = d.spin_angle + d.spin_speed
            d.spin_speed = d.spin_speed * 0.95 
            
            if abs(d.spin_speed) < 0.02 then
                d.is_tumbling = false
            end
        end

        d.life = d.life - 1
        if d.life <= 0 or d.y > 128 or d.x < camera_x - 8 or d.x > camera_x + screen_size + 8 then
            del(darts, d) 
        end


        if d.cooldown > 0 then
            d.cooldown -= 1 
        else
            if d.enemy_fire then
                dart_collision_detection(d, p1, 1, 1)
                dart_collision_detection(d, p2, 1, 1)
            else
                local damage = 1
                local force = 4
                if p1.weapon == 1 then 
                    force = 2
                end

                if stage < 8 then
                    for e in all(enemies) do
                        if not e.dead then
                            dart_collision_detection(d, e, damage, force)
                        end
                    end
                else
                    dart_collision_detection(d, boss.head, 0.1, 1)

                    if boss.defeated then
                        dart_collision_detection(d, santa, 1, 1)
                    end
                end

                if d.x - d.dx > right_bound then
                    dart_collision_response(d, -1)
                end
            end
        end
    end
end

function dart_collision_detection(d, o, damage, force)
    if d.x >= o.x and d.x <= o.x + o.w and
        d.y >= o.y and d.y <= o.y + o.h then
        
        local return_dir = 1
        if d.dx > 0 then return_dir = -1 end

        local back_shot = false
        if d.x > o.x + o.w / 2 then
            back_shot = true
        end

        if o.damage then 
            if back_shot then
                o.damage += damage
                o.hit = true
            elseif not o.shield then
                o.damage += damage
                o.hit = true
            elseif o.shield and not o.shield_deployed then
                o.hit = true
                o.damage += damage 

                if o.shield then
                    o.shield_deployed = true
                end
            end

            if not back_shot then
                if return_dir == 1 then
                    o.x -= force
                else
                    o.x += force
                end
            end
        else 
            if o.boss_damage then 
                o.boss_damage += damage
                o.hit = true
            end

            if return_dir == 1 then
                o.x -= force
            else
                o.x += force
            end
        end
    
        dart_collision_response(d, return_dir)
    end
end

function dart_collision_response(d, dir)
    d.life += 40 
    d.cooldown = bounce_cooldown
    
    if not d.is_tumbling then 
        d.dx = (1.0 + rnd(2.0)) * dir
        d.dy = -1.5 - rnd(3.0)
        d.is_tumbling = true
        d.spin_speed = 0.15 + rnd(0.2)
        if rnd(1) > 0.5 then d.spin_speed = -d.spin_speed end
    else
        d.dx = (0.2 + rnd(1)) * dir
        d.dy = -0 - rnd(1)
    end
    
    d.bounces = d.bounces - 1
    if d.bounces <= 0 then
        del(darts, d)
    end
end

function draw_darts()
    for d in all(darts) do
        local step_x = 0
        local step_y = 0
        
        if d.is_tumbling then
            step_x = cos(d.spin_angle)
            step_y = sin(d.spin_angle)
        else
            local speed = sqrt(d.dx*d.dx + d.dy*d.dy)
            if speed > 0 then
                step_x = d.dx / speed
                step_y = d.dy / speed
            else
                step_x = 1
            end
        end
        
        local x0 = d.x + step_x
        local y0 = d.y + step_y
        
        local x1 = d.x
        local y1 = d.y
        
        local x2 = d.x - step_x
        local y2 = d.y - step_y
        
        pset(x0, y0, 1)
        pset(x1, y1, 9)
        pset(x2, y2, 9)
    end
end
