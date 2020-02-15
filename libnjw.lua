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
