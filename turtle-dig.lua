local home_x = 0
local home_y = 0
local direction = 0
local kill = false

function init()
  if turtle.detect() then
    return false
  else
    return true
  end
end

function forward()
  turtle.dig()
  if turtle.forward() then
    turtle.digUp()
    turtle.suck()
    return true
  else
    return false
  end
end

function outAndBack()
  while home_x < 8 do
    if not forward() then
      term.write("Error on forward march\n")
      return false
    end
    home_x = home_x + 1
  end
  turtle.turnLeft()
  if not forward() then
    term.write("Error on turn-back\n")
    return false
  end
  home_y = home_y + 1
  turtle.turnLeft()
  term.write("Coming back!\n")
  while home_x > 0 do
    if not forward() then
      term.write("Error on return march\n")
      return false
    end
    home_x = home_x - 1
  end
  turtle.turnRight()
  if not forward() then
    term.write("Error on turn-back-back\n")
    return false
  end
  home_y = home_y + 1
  turtle.turnRight()
  return true
end

function main()
  while home_y < 8 do
    if not outAndBack() then
      term.write("Bailing out early\n")
      return false
    end
    if turtle.getItemCount(15) > 0 then
      term.write("Out of hunk!\n")
      return false
    end
    term.write("Y = " .. home_y .. "\n")
  end
end

main()
