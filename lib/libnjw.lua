local SIDES = {"left", "right", "front", "back"}
LOG_LEVEL = 5

-- if a modem is connected, return the appropriate side
-- else return nil
function find_modem()
    local side
    for _, s in ipairs(SIDES) do
        if peripheral.isPresent(s) then
            if peripheral.getType(s) == "modem" then
                side = s
                break
            end
        end
    end
    return side
end

function cprint(msg, clr)
  local c = term.getTextColor()
  term.setTextColor(clr)
  print(msg)
  term.setTextColor(c)
end

function log(msg, level)
  local level = level or 0
  if level < LOG_LEVEL then
    cprint(msg, colors.cyan)
  end
end

function success(msg)
  cprint(msg, colors.green)
end

function newline(win)
  win = win or term
  local _,cY = win.getCursorPos()
  win.setCursorPos(1, cY+1)
end

function table.clone(t)
  return {table.unpack(t)}
end
