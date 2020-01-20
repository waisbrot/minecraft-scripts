local x, y, z = 0, 0, 0
local gps_id = multishell.launch({}, "rom/programs/gps.lua", "host", x, y, z)
multishell.setTitle(gps_id, "GPS")
