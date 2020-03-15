local SIDES = {"left", "right", "front", "back"}

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

function log(msg)
  cprint(msg, colors.cyan)
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
