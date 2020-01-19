
local SETTINGS_FILE = "pull.settings"

local SETTINGS = {"orgname", "reponame", "clobber"}
local SETTING_DEFAULTS = {"", "", true}

function error(str)
  term.setTextColor(colors.red)
  print(str)
  term.setTextColor(colors.white)
end

function newline(win)
  local _,cY = win.getCursorPos()
  win.setCursorPos(1, cY+1)
end

function config_init()
  settings.clear()
  for i=1,#SETTINGS do
    settings.set(SETTINGS[i], SETTING_DEFAULTS[i])
  end
  settings.save(SETTINGS_FILE)
end

function print_config_item(win, selected, name)
  local val = settings.get(name)
  if selected then
    win.write("> ")
  else
    win.write("  ")
  end
  win.write(name .. ": ")
  win.setTextColor(colors.yellow)
  win.write(tostring(val))
  win.setTextColor(colors.white)
  newline(win)
end

function print_config_menu(win, selected)
  win.clear()
  win.setCursorPos(1, 1)
  win.setTextColor(colors.green)
  win.write("up/down to select, space to edit")
  newline(win)
  win.write("enter to save changes")
  newline(win)
  win.setTextColor(colors.white)
  for i=1,#SETTINGS do
    print_config_item(win, selected == i, SETTINGS[i])
  end
end

function config_menu()
  local w, h = term.getSize()
  local win = window.create(term.current(), 1, 1, w - 2, h - 2)
  selected = 1
  local done = false
  while not done do
    print_config_menu(win, selected)
    local event, key, isHeld = os.pullEvent("key")
    if key == keys.up then
      selected = (selected - 1) % #SETTINGS
    elseif key == keys.down then
      selected = (selected + 1) % #SETTINGS
    elseif key == keys.enter then
      done = true
    elseif key == keys.space then
      newline(win)
      win.setTextColor(colors.green)
      win.write(SETTINGS[selected] .. ": ")
      local val = read()
      settings.set(SETTINGS[selected], val)
    else
      done = true
      print("ERROR bad key " .. key)
    end
    if selected == 0 then
      selected = #SETTINGS
    end
  end
  settings.save(SETTINGS_FILE)
end

function configure()
  if not settings.load(SETTINGS_FILE) then
    config_init()
  end
  config_menu()
  print("goodbye")
end

function pull(file)
  local url = "https://raw.githubusercontent.com/" .. settings.get("orgname") .. "/" .. settings.get("reponame") .. "/master/" .. file .. ".lua"
  local dataHandle = http.get(url)
  local outHandle = fs.open(file, "w")
  outHandle.write(dataHandle.readAll())
  outHandle.close()
  dataHandle.close()
  print("Wrote " .. file)
end

function main()
  if #arg == 1 then
  else
    return error("Usage: pull ( name | --config )")
  end
  if arg[1] == "--config" then
    configure()
  else
    pull(arg[1])
  end
end

main()
