end_dialog_delay = 120
end_dialog_cnt = 0
end_dt_cnt = 1
end_dt = {
  {"jenn", "YEEEEEEHAW!"},	
  {"chad", "JUST ANOTHER DAY ON THE JOB"},
  {"jenn", "YEP, LIVING THE DREAM"},	
  {"jenn", "ONE CRIME SCENE AT A TIME"},	
  {"chad", "WELL, GREAT JOB OUT THERE"},
  {"chad", "I'LL PUT IN YOUR PROMOTION PACKAGE AGAIN"},
  {"jenn", "WHY, SO BILL CAN REJECT IT AGAIN?"},
  {"chad", "I'M A LOT OF THINGS"},
  {"chad", "BUT A QUITTER AINT ONE OF THEM"},
  {"chad", "I'LL GET IT THROUGH. I PROMISE."},
  {"jenn", "THANKS CHAD."},
  {"jenn", "ALRIGHT ENOUGH BLABBERING"},
  {"jenn", "ON TO THE NEXT ONE"},
  {"jenn", "BATTLE BOSS BABE AND GRANITE JAW LINE TO THE RESCUE!"},
  {"chad", "HA HA. LET'S DO IT!"},
  {"", "to be continued... "},
  {"", "to be continued... "},
  {"", "to be continued... "},
  {"", "to be continued... "},
  {"", "to be continued... "},
  {"", "to be continued... "},
  {"", "to be continued... "},
  {"", "to be continued... "},
  {"", "to be continued... "},
  {"", "to be continued... "},
  {"", "to be continued... "},
  {"", "to be continued... "},
  {"", "to be continued... "},
  {"", "to be continued... "},
  {"", "to be continued... "}
}

function print_dialog(x, y, msg, border, wide, bounded, color, background, tail)    
  if not color then
    color = 0
  end

  if not background then
    background = 7
  end

  local max_w = 42 
  if wide then
   max_w = 86
  end

	 -- 1. split text into words using pico-8's native split  
  local words = split(msg, " ")
  local lines = {}
  local curr = ""
  
  for w in all(words) do
    -- puny font characters are ~4 pixels wide
    if #curr * 4 + #w * 4 + 6 
     > max_w then
      add(lines, curr)
      curr = w
    else
      curr = (curr == "") and w or curr.." "..w
    end
  end
  add(lines, curr)

  -- 2. calculate dimensions (puny is 5px tall)
  local line_h = 6 
  local b_w = max_w
  local b_h = #lines * line_h + 3
  local bx = x - b_w/2 + 8
  local by = y - b_h - 2

	 -- 3. keep dialog in screen
  if bounded then
	  if bx - b_w/2 < camera_x then
	   bx = camera_x
	  elseif bx + b_w > camera_x + screen_size then
	   bx = camera_x + screen_size - b_w
	  end
	 end

  -- 4. draw bubble body and tail
  rectfill(bx, by, bx + b_w, by + b_h, background)
  
  if border==1 then
   rect(bx, by, bx+b_w, by+b_h, color)
  
	  -- simple triangle tail
    if tail then
      line(x+6, by+b_h, x+7, by+b_h+2, color)
      line(x+8, by+b_h, x+7, by+b_h+2, color)
      pset(x+7, by+b_h, 7)
    end
  end

  -- 5. print each line with \v (puny font)
  for i=1,#lines do
    print(lines[i], bx+2, by+2 + (i-1)*line_h, color)
  end
end