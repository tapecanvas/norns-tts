-- tts
-- norns text to speech
-- by @tapecanvas
-- v0.0.1
-- flite and mpv required
-- external kb required
-- e2 change voice
-- k2 play text
-- k3 stop playback

local text = ""
local message = ""
local message2 = ""

local function executeCommand()
            local scale = params:get("scale")
        local speed = params:get("speed")
  os.execute('sudo rm /home/we/dust/data/tts/output.wav')
  os.execute('flite -voice ' .. params:string("voice") ..' -t  "' .. text ..  '" -o /home/we/dust/data/tts/output.wav; mpv --no-video --audio-channels=stereo  --af=scaletempo=scale=' .. scale .. ':speed=tempo' .. ' --speed=' .. speed .. ' --jack-port="crone:input_(1|2)" /home/we/dust/data/tts/output.wav &')
end

-- try using flite speed/pitch instead of mpv

function enc(n, delta)
  if n == 2 then
    params:delta("voice", delta)   
    screen_dirty = true
    message = params:string("voice")
    redraw()
  elseif n == 3 then
    params:delta("speed", delta)
    screen_dirty =true
    message2 = params:string("speed")
    redraw()
    end
end

function keyboard.char(character)
  text = text..character
  redraw()
end

function keyboard.code(code,value)
  if value == 1 or value == 2 then -- 1 is down, 2 is held, 0 is release
    if code == "BACKSPACE" then
      text = text:sub(1, -2) -- erase chars from text
    elseif code == "ENTER" then
      executeCommand()
    elseif code:match("%a") or code:match("%d") or code == "SPACE" then
      -- work on new line/wrap
    end
    redraw()
  end
end

function init()
  params:add{type = "option", id = "voice", name = "voice", options = {"awb", "kal16", "kal", "rms", "slt", "time awb"}, default = 1}
  -- remove duplicate (kal or time) - maybe kal16 too? 
  params:add_separator("pitch and speed")
  params:add_control("speed", "pitch:", controlspec.new(0.1, 4.0, 'lin', 0.02, 1, ""))
  params:add_control("scale", "speed:", controlspec.new(0.1, 2.0, 'lin', 0.02, 1, ""))
  params:bang()
  message=params:string("voice")
  message2=params:string("speed")
  screen_dirty = true
  text = ""

  function key(k, z)
    if z == 0 then return end
    if k == 2 then 
      executeCommand()
    end
    if k == 3 then 
      os.execute('killall -KILL mpv') -- force kill mpv
    end
    screen_dirty = true
  end
end

function textwrap(text, len)
  local lines = {}
  local line = ""
  for word in text:gmatch("%S+[^%s]*") do
    if #line + #word + 1 > len then
      table.insert(lines, line)
      line = word
    else
      line = line .. (line == "" and "" or " ") .. word
    end
  end
  table.insert(lines, line)
  return lines
end

function redraw()
  screen.clear()
  screen.aa(1)
  screen.font_face(1)
  screen.font_size(8)
  screen.level(15)
  local lines = textwrap(text, 20)  -- max line length (20)
  for i, line in ipairs(lines) do
    screen.move(0, 6 * i)
    screen.text(line)
  end
  screen.move(81, 56)
    screen.text("voice: " .. message)
  screen.move(81, 62)
    screen.text("speed: " .. message2)

  screen.fill()
  screen.update()
end