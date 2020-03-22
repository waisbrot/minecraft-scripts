SAFE = {
  "minecraft:stone" = true
  "minecraft:dirt" = true
  "minecraft:grass" = true
  "minecraft:sand" = true
  "minecraft:gravel" = true
  "minecraft:lapis_ore" = true
  "minecraft:sandstone" = true
  "minecraft:web" = true
  "minecraft:tallgrass" = true
  "minecraft:deadbush" = true
  "minecraft:diamond_ore" = true
  "minecraft:redstone_ore" = true
  "minecraft:lit_redstone_ore" = true
  "minecraft:snow_layer" = true
  "minecraft:ice" = true
  "minecraft:snow" = true
  "minecraft:clay" = true
  "minecraft:netherrack" = true
  "minecraft:soul_sand" = true
  "minecraft:glowstone" = true
}

-- Everything not listed above is unsafe!
setmetatable(SAFE, {__index = function () return false end})
