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

local function executeCommand()
  os.execute('sudo rm /home/we/dust/data/tts/output.wav')
  os.execute('flite -voice ' .. params:string("voice") ..' -t  "' .. text ..  '" -o /home/we/dust/data/tts/output.wav; mpv --no-video --audio-channels=stereo --jack-port="crone:input_(1|2)" /home/we/dust/data/tts/output.wav &')
end

function enc(n, delta)
  if n == 2 then
    params:delta("voice", delta)   
    screen_dirty = true
    message = params:string("voice")
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
      -- Do something here
    end
    redraw()
  end
end

function init()
  params:add{type = "option", id = "voice", name = "voice", options = {"awb", "kal16", "kal", "rms", "slt", "time awb"}, default = 1}
  params:bang()
  message=params:string("voice")
  screen_dirty = true
  text = ""

  function key(k, z)
    if z == 0 then return end
    if k == 2 then 
      executeCommand()
    end
    if k == 3 then 
      os.execute('killall -KILL mpv')
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
    screen.move(0, 8 * i)
    screen.text(line)
  end
  screen.move(80, 62)
  screen.text("voice: " .. message)
  screen.fill()
  screen.update()
end