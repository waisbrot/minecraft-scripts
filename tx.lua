-- Send commands to remote servers

function find_modem()
    local side
    for s in {"left", "right", "front", "back"} do
      if peripheral.isPresent(s) then
        if peripheral.getType(s) == "modem" then
            side = s
            break
        end
      end
    end
    return side
  end
end

assert(#arg >= 2, "Usage: <protocol> <command> <arg1> <arg2> ...")
local protocol = arg[1]
local command = {}
for i = 2, #arg, 1 do
    command[i-1] = arg[i]
end
local modem_side = find_modem()
rednet.open(modem_side)
local hosts = rednet.lookup(protocol)
if hosts == nil || #hosts < 1 then
    print("No host found")
    os.exit()
end
rednet.send(hosts[1], command, protocol)
local response = rednet.receive(protocol, 5)
print(response)
